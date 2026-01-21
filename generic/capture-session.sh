#!/bin/bash
# Capture le window ID et TTY de l'onglet Terminal courant au démarrage de Claude
# Ce script peut être appelé manuellement ou intégré dans un wrapper

CURRENT_TTY=$(tty)
SESSION_ID="$TERM_SESSION_ID"

# Récupérer l'ID de la fenêtre qui contient cet onglet
WINDOW_ID=$(osascript -e '
tell application "Terminal"
    set currentTTY to "'"$CURRENT_TTY"'"
    repeat with w in windows
        repeat with t in tabs of w
            if tty of t is currentTTY then
                return id of w
            end if
        end repeat
    end repeat
    return ""
end tell
')

# Stocker les infos avec TERM_SESSION_ID comme identifiant unique
echo "${WINDOW_ID},${CURRENT_TTY}" > "/tmp/claude_session_${SESSION_ID}"
