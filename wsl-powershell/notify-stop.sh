#!/bin/bash
# Notification quand Claude termine - Version WSL avec PowerShell
# À utiliser avec le hook "Stop"

HOOKS_DIR="$HOME/.claude/hooks"

MESSAGE="Claude a terminé de réaliser votre demande"
SOUND="Exclamation"

# Jouer le son via PowerShell (Windows)
powershell.exe -Command "[System.Media.SystemSounds]::${SOUND}.Play()" 2>/dev/null &

# Lancer la notification via PowerShell
HOOKS_WIN=$(wslpath -w "$HOOKS_DIR")
powershell.exe -ExecutionPolicy Bypass -File "${HOOKS_WIN}\\floatbar.ps1" -Message "$MESSAGE" -NoSound 2>/dev/null &
