#!/bin/bash
# Wrapper de notification pour Claude Code
# Joue le son immédiatement puis affiche la notification glassmorphism

HOOKS_DIR="$HOME/.claude/hooks"

# Lire le JSON depuis stdin
INPUT=$(cat)

# Extraire le type de notification
NOTIF_TYPE=$(echo "$INPUT" | grep -o '"notification_type":"[^"]*"' | cut -d'"' -f4)

# Déterminer le message et le son selon le type
if [ "$NOTIF_TYPE" = "permission_prompt" ]; then
    MESSAGE="Claude a besoin de votre intervention"
    SOUND="/System/Library/Sounds/Sosumi.aiff"
else
    MESSAGE="Claude a terminé de réaliser votre demande"
    SOUND="/System/Library/Sounds/Hero.aiff"
fi

# Jouer le son IMMÉDIATEMENT (avant le chargement Python)
afplay "$SOUND" &

# Lire les infos de session via TERM_SESSION_ID
SESSION_FILE="/tmp/claude_session_${TERM_SESSION_ID}"

if [ -f "$SESSION_FILE" ]; then
    SESSION_INFO=$(cat "$SESSION_FILE")
    WINDOW_ID=$(echo "$SESSION_INFO" | cut -d',' -f1)
    CURRENT_TTY=$(echo "$SESSION_INFO" | cut -d',' -f2)
else
    WINDOW_ID=""
    CURRENT_TTY=""
fi

# Lancer la notification (sans son, il est déjà joué)
python3 "$HOOKS_DIR/floatbar.py" "$WINDOW_ID" "$CURRENT_TTY" --no-sound --message "$MESSAGE" &
