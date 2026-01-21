#!/bin/bash
# Claude Code wrapper pour Linux - à ajouter dans ~/.bashrc ou ~/.zshrc
# Sauvegarde les infos de session pour les notifications

claude() {
    # Capturer l'ID de la fenêtre active (X11)
    local window_id=""
    if command -v xdotool &>/dev/null; then
        window_id=$(xdotool getactivewindow 2>/dev/null)
    elif command -v xprop &>/dev/null; then
        window_id=$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | awk '{print $5}')
    fi

    # Stocker les infos de session
    echo "$window_id" > /tmp/claude_session_linux

    # Lancer le vrai claude
    command claude "$@"
}
