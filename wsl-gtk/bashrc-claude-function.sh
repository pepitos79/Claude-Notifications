#!/bin/bash
# Claude Code wrapper pour WSL - à ajouter dans ~/.bashrc ou ~/.zshrc
# Sauvegarde les infos de session pour les notifications

claude() {
    # Capturer le TTY
    local current_tty=$(tty)

    # Stocker les infos de session
    echo "$current_tty" > /tmp/claude_session_wsl

    # Lancer le vrai claude
    command claude "$@"
}
