#!/bin/bash
# Wrapper de notification pour Claude Code - Version WSL (sans PowerShell)
# Utilise GTK via WSLg pour afficher la notification

HOOKS_DIR="$HOME/.claude/hooks"

# Lire le JSON depuis stdin
INPUT=$(cat)

# Extraire le type de notification
NOTIF_TYPE=$(echo "$INPUT" | grep -o '"notification_type":"[^"]*"' | cut -d'"' -f4)

# Déterminer le message selon le type
if [ "$NOTIF_TYPE" = "permission_prompt" ]; then
    MESSAGE="Claude a besoin de votre intervention"
    SOUND="/usr/share/sounds/freedesktop/stereo/message.oga"
else
    MESSAGE="Claude a terminé de réaliser votre demande"
    SOUND="/usr/share/sounds/freedesktop/stereo/complete.oga"
fi

# Jouer le son IMMÉDIATEMENT
if [ -f "$SOUND" ]; then
    paplay "$SOUND" 2>/dev/null &
else
    # Fallback: beep Windows
    cmd.exe /c "echo ^G" 2>/dev/null &
fi

# Lancer la notification GTK via WSLg
python3 "$HOOKS_DIR/floatbar.py" --message "$MESSAGE" --no-sound &
