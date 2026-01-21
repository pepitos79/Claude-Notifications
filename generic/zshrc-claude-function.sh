#!/bin/bash
# Claude Code wrapper - à ajouter dans ~/.zshrc
# Sauvegarde le TTY et Window ID pour les notifications

claude() {
    local current_tty=$(tty)
    # Trouver le window ID qui contient cet onglet (pas juste front window)
    local window_id=$(osascript -e '
    tell application "Terminal"
        set currentTTY to "'"$current_tty"'"
        repeat with w in windows
            repeat with t in tabs of w
                if tty of t is currentTTY then
                    return id of w
                end if
            end repeat
        end repeat
        return ""
    end tell
    ' 2>/dev/null)
    # Stocker avec TERM_SESSION_ID comme clé unique
    echo "${window_id},${current_tty}" > "/tmp/claude_session_${TERM_SESSION_ID}"
    # Lancer le vrai claude
    command claude "$@"
}
