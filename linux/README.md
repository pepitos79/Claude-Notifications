# Claude Code - Notification Glassmorphism pour Linux

Système de notification desktop pour Claude Code sur Linux avec :
- Notification flottante style glassmorphism (fond semi-transparent)
- Sons de notification (PulseAudio/ALSA)
- Activation de la fenêtre Terminal au clic

## Prérequis

- Linux avec X11 (Wayland: support partiel)
- Python 3.x
- GTK 3
- PyGObject (python3-gi)
- wmctrl ou xdotool (pour le ciblage de fenêtre)
- PulseAudio ou ALSA (pour le son)

## Installation des dépendances

### Debian/Ubuntu
```bash
sudo apt install python3-gi gir1.2-gtk-3.0 wmctrl xdotool pulseaudio-utils
```

### Fedora
```bash
sudo dnf install python3-gobject gtk3 wmctrl xdotool pulseaudio-utils
```

### Arch Linux
```bash
sudo pacman -S python-gobject gtk3 wmctrl xdotool pulseaudio
```

## Installation

### 1. Créer le dossier hooks
```bash
mkdir -p ~/.claude/hooks
```

### 2. Copier les scripts
```bash
cp floatbar.py ~/.claude/hooks/
cp notify-wrapper.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.py ~/.claude/hooks/*.sh
```

### 3. Ajouter la fonction claude dans ~/.bashrc ou ~/.zshrc
```bash
cat bashrc-claude-function.sh >> ~/.bashrc
source ~/.bashrc
```

### 4. Configurer le hook Claude Code
Dans `~/.claude/settings.json`, ajoute :
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/notify-wrapper.sh"
          }
        ]
      }
    ]
  }
}
```

## Utilisation

1. Lance `claude` dans un terminal
2. Quand Claude demande une validation ou termine, la notification apparaît
3. Clique sur la notification pour revenir au terminal

## Fonctionnement

- `floatbar.py` : Script Python/GTK3 qui crée la notification glassmorphism
- `notify-wrapper.sh` : Wrapper bash qui joue le son et lance la notification
- `bashrc-claude-function.sh` : Fonction à ajouter au shell

## Messages et Sons

| Type | Message | Son |
|------|---------|-----|
| Permission demandée | "Claude a besoin de votre intervention" | message.oga |
| Tâche terminée | "Claude a terminé de réaliser votre demande" | complete.oga |

## Personnalisation

### Changer les sons
Dans `notify-wrapper.sh`, modifie les chemins des sons :
```bash
SOUND="/usr/share/sounds/freedesktop/stereo/message.oga"
SOUND="/usr/share/sounds/freedesktop/stereo/complete.oga"
```

Sons freedesktop disponibles :
- `/usr/share/sounds/freedesktop/stereo/message.oga`
- `/usr/share/sounds/freedesktop/stereo/complete.oga`
- `/usr/share/sounds/freedesktop/stereo/bell.oga`
- `/usr/share/sounds/freedesktop/stereo/dialog-warning.oga`

### Changer les dimensions
Dans `floatbar.py`, modifie :
```python
self.width = 420
self.height = 70
self.radius = 22
```

### Changer la couleur de fond
Dans `floatbar.py`, modifie dans `on_draw` :
```python
cr.set_source_rgba(0.12, 0.12, 0.12, 0.85)  # R, G, B, Alpha
```

### Changer la durée d'affichage
Dans `floatbar.py`, modifie :
```python
GLib.timeout_add_seconds(10, self.close_window)  # 10 secondes
```

## Effet Blur (Glassmorphism complet)

Le vrai effet de blur nécessite un compositeur avec support du blur :
- **KDE Plasma** : Activer "Blur" dans les effets de bureau
- **GNOME** : Extension "Blur my Shell"
- **Picom** : Configurer `blur-background = true`

Sans compositeur avec blur, la notification aura un fond semi-transparent sans flou.

## Dépannage

### La notification n'apparaît pas
- Vérifie les dépendances :
  ```bash
  python3 -c "import gi; gi.require_version('Gtk', '3.0')"
  ```
- Teste manuellement :
  ```bash
  python3 ~/.claude/hooks/floatbar.py --message "Test"
  ```

### La fenêtre n'est pas transparente
- Un compositeur est requis (Mutter, KWin, Picom, Compton)
- Vérifie que le compositeur est actif

### wmctrl ne trouve pas la fenêtre
- Installe xdotool comme alternative
- Vérifie que tu es sur X11 (pas Wayland natif)

### Le son ne joue pas
- Vérifie PulseAudio : `paplay /usr/share/sounds/freedesktop/stereo/bell.oga`
- Ou ALSA : `aplay /usr/share/sounds/sound-icons/*.wav`

## Support Wayland

Le support Wayland est partiel :
- La notification fonctionne via XWayland
- Le ciblage de fenêtre peut ne pas fonctionner
- Pour un support complet Wayland, utiliser `notify-send` comme alternative
