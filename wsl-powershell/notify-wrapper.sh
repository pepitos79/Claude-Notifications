#!/bin/bash
# Wrapper de notification pour Claude Code - Version WSL avec PowerShell
# Utilise PowerShell pour afficher la notification Windows native

HOOKS_DIR="$HOME/.claude/hooks"

# Lire le JSON depuis stdin
INPUT=$(cat)

# Extraire le type de notification
NOTIF_TYPE=$(echo "$INPUT" | grep -o '"notification_type":"[^"]*"' | cut -d'"' -f4)

# Déterminer le message et le son selon le type
if [ "$NOTIF_TYPE" = "permission_prompt" ]; then
    MESSAGE="Claude a besoin de votre intervention"
    SOUND="Asterisk"
else
    MESSAGE="Claude a terminé de réaliser votre demande"
    SOUND="Exclamation"
fi

# Jouer le son via PowerShell (Windows)
powershell.exe -Command "[System.Media.SystemSounds]::${SOUND}.Play()" 2>/dev/null &

# Lancer la notification via PowerShell
HOOKS_WIN=$(wslpath -w "$HOOKS_DIR")
powershell.exe -ExecutionPolicy Bypass -File "${HOOKS_WIN}\\floatbar.ps1" -Message "$MESSAGE" -NoSound 2>/dev/null &
