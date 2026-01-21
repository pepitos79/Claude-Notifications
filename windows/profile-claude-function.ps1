# Claude Code wrapper pour Windows - à ajouter dans $PROFILE
# Sauvegarde les infos de session pour les notifications

function claude {
    # Capturer le PID de Windows Terminal
    $wtProcess = Get-Process -Name "WindowsTerminal" -ErrorAction SilentlyContinue | Select-Object -First 1
    $wtPid = if ($wtProcess) { $wtProcess.Id } else { "" }

    # Capturer le PID du processus courant
    $currentPid = $PID

    # Stocker les infos de session
    "$wtPid,$currentPid" | Out-File -FilePath "$env:TEMP\claude_session_windows" -Encoding UTF8 -NoNewline

    # Lancer le vrai claude
    & claude.exe $args
}

# Alias pour s'assurer que la fonction est utilisée
Set-Alias -Name claude -Value claude -Option AllScope -Force
