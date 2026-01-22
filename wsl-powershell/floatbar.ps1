param(
    [string]$Message = "Claude a besoin de votre intervention",
    [string]$Title = "Claude Code",
    [switch]$NoSound
)

# Utiliser les Toast Notifications Windows (fonctionne depuis WSL)
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

# Déterminer le son
$silentAttr = if ($NoSound) { "true" } else { "false" }

# Template XML pour la notification toast
$toastXml = @"
<toast duration="long">
    <visual>
        <binding template="ToastGeneric">
            <text>$Title</text>
            <text>$Message</text>
        </binding>
    </visual>
    <audio silent="$silentAttr" />
</toast>
"@

# Créer la notification
$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($toastXml)

$toast = New-Object Windows.UI.Notifications.ToastNotification $xml

# Variable pour savoir si on doit activer le terminal
$script:shouldActivate = $false
$script:dismissed = $false

# Événement au clic sur la notification
Register-ObjectEvent -InputObject $toast -EventName Activated -Action {
    $script:shouldActivate = $true
    $script:dismissed = $true
} | Out-Null

# Événement quand la notification est fermée
Register-ObjectEvent -InputObject $toast -EventName Dismissed -Action {
    $script:dismissed = $true
} | Out-Null

# Liste des AppId à essayer
$appIds = @(
    "Microsoft.WindowsTerminal_8wekyb3d8bbwe!App",
    "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe",
    "Windows.SystemToast.Default"
)

$success = $false
foreach ($appId in $appIds) {
    try {
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
        $success = $true
        break
    } catch {
        continue
    }
}

if ($success) {
    # Attendre que la notification soit cliquée ou fermée (max 15 secondes)
    $timeout = 15
    $elapsed = 0
    while (-not $script:dismissed -and $elapsed -lt $timeout) {
        Start-Sleep -Milliseconds 500
        $elapsed += 0.5
    }

    # Si l'utilisateur a cliqué, activer Windows Terminal
    if ($script:shouldActivate) {
        $activated = $false

        # Méthode 1: WScript.Shell AppActivate (fonctionne mieux depuis contexte externe)
        try {
            $shell = New-Object -ComObject WScript.Shell
            $activated = $shell.AppActivate("Windows Terminal")
        } catch {
            $activated = $false
        }

        # Méthode 2: Si AppActivate échoue, essayer avec le PID
        if (-not $activated) {
            try {
                $wt = Get-Process -Name "WindowsTerminal" -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($wt) {
                    $shell = New-Object -ComObject WScript.Shell
                    $activated = $shell.AppActivate($wt.Id)
                }
            } catch {
                $activated = $false
            }
        }

        # Méthode 3: Fallback avec Microsoft.VisualBasic
        if (-not $activated) {
            try {
                Add-Type -AssemblyName Microsoft.VisualBasic
                [Microsoft.VisualBasic.Interaction]::AppActivate("Windows Terminal")
            } catch {
                # Ignorer les erreurs
            }
        }
    }
} else {
    # Fallback ultime : MessageBox
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
