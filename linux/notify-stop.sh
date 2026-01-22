#!/bin/bash
# Notification quand Claude termine - Version Linux
# À utiliser avec le hook "Stop"

HOOKS_DIR="$HOME/.claude/hooks"

MESSAGE="Claude a terminé de réaliser votre demande"
SOUND="/usr/share/sounds/freedesktop/stereo/complete.oga"

# Jouer le son
if [ -f "$SOUND" ]; then
    paplay "$SOUND" 2>/dev/null &
fi

# Lire les infos de session
SESSION_FILE="/tmp/claude_session_linux"
WINDOW_ID=""
if [ -f "$SESSION_FILE" ]; then
    WINDOW_ID=$(cat "$SESSION_FILE")
fi

# Lancer la notification
python3 "$HOOKS_DIR/floatbar.py" --message "$MESSAGE" --window-id "$WINDOW_ID" --no-sound &
