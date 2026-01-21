# Wrapper de notification pour Claude Code - Version Windows
# Joue le son et affiche la notification glassmorphism

param(
    [Parameter(ValueFromPipeline=$true)]
    [string]$InputJson
)

$HooksDir = "$env:USERPROFILE\.claude\hooks"

# Lire le JSON depuis stdin si pas passé en paramètre
if (-not $InputJson) {
    $InputJson = $input | Out-String
}

# Extraire le type de notification
$notifType = ""
if ($InputJson -match '"notification_type"\s*:\s*"([^"]*)"') {
    $notifType = $matches[1]
}

# Déterminer le message et le son selon le type
if ($notifType -eq "permission_prompt") {
    $Message = "Claude a besoin de votre intervention"
    $Sound = "Asterisk"
} else {
    $Message = "Claude a terminé de réaliser votre demande"
    $Sound = "Exclamation"
}

# Jouer le son immédiatement
[System.Media.SystemSounds]::$Sound.Play()

# Lire les infos de session
$SessionFile = "$env:TEMP\claude_session_windows"
$SessionInfo = ""
if (Test-Path $SessionFile) {
    $SessionInfo = Get-Content $SessionFile -Raw
}

# Lancer la notification en arrière-plan
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$HooksDir\floatbar.ps1`" -Message `"$Message`" -SessionInfo `"$SessionInfo`" -NoSound" -WindowStyle Hidden
