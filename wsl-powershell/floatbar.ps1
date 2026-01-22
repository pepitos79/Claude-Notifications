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
# launch="wt://" ouvre Windows Terminal au clic
$toastXml = @"
<toast launch="wt://" activationType="protocol" duration="long">
    <visual>
        <binding template="ToastGeneric">
            <text>$Title</text>
            <text>$Message</text>
        </binding>
    </visual>
    <audio silent="$silentAttr" />
</toast>
"@

# Créer et afficher la notification
$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($toastXml)

$toast = New-Object Windows.UI.Notifications.ToastNotification $xml

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

if (-not $success) {
    # Fallback ultime : MessageBox
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
