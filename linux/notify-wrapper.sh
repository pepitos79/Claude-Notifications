#!/bin/bash
# Wrapper de notification pour Claude Code - Version Linux
# Joue le son immédiatement puis affiche la notification

HOOKS_DIR="$HOME/.claude/hooks"

# Lire le JSON depuis stdin
INPUT=$(cat)

# Extraire le type de notification
NOTIF_TYPE=$(echo "$INPUT" | grep -o '"notification_type":"[^"]*"' | cut -d'"' -f4)

# Déterminer le message et le son selon le type
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
elif command -v beep &>/dev/null; then
    beep &
fi

# Lire les infos de session
SESSION_FILE="/tmp/claude_session_linux"
WINDOW_ID=""
if [ -f "$SESSION_FILE" ]; then
    WINDOW_ID=$(cat "$SESSION_FILE")
fi

# Lancer la notification
python3 "$HOOKS_DIR/floatbar.py" --message "$MESSAGE" --window-id "$WINDOW_ID" --no-sound &
