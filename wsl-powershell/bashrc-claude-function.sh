#!/bin/bash
# Claude Code wrapper pour WSL (PowerShell) - à ajouter dans ~/.bashrc ou ~/.zshrc
# Sauvegarde les infos de session pour les notifications

claude() {
    # Capturer le PID du terminal Windows (si disponible)
    local wt_pid=""
    if command -v powershell.exe &> /dev/null; then
        wt_pid=$(powershell.exe -Command "(Get-Process -Name WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1).Id" 2>/dev/null | tr -d '\r')
    fi

    # Capturer le TTY
    local current_tty=$(tty)

    # Stocker les infos de session
    echo "${wt_pid},${current_tty}" > /tmp/claude_session_wsl

    # Lancer le vrai claude
    command claude "$@"
}
