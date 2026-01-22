#!/bin/bash
# Notification quand Claude termine - Version WSL GTK
# À utiliser avec le hook "Stop"

HOOKS_DIR="$HOME/.claude/hooks"

MESSAGE="Claude a terminé de réaliser votre demande"
SOUND="/usr/share/sounds/freedesktop/stereo/complete.oga"

# Jouer le son
if [ -f "$SOUND" ]; then
    paplay "$SOUND" 2>/dev/null &
else
    cmd.exe /c "echo ^G" 2>/dev/null &
fi

# Lancer la notification GTK via WSLg
python3 "$HOOKS_DIR/floatbar.py" --message "$MESSAGE" --no-sound &
