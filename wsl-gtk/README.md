# Claude Code - Notification Glassmorphism pour WSL

Système de notification desktop pour Claude Code sur WSL (Windows Subsystem for Linux) avec :
- Notification flottante style glassmorphism via WSLg (GTK3)
- Sons de notification (PulseAudio via WSLg)
- Activation de Windows Terminal au clic

**Cette version n'utilise PAS PowerShell** - tout est en bash/Python via WSLg.

## Prérequis

- **Windows 11** ou **Windows 10 21H2+** avec WSLg
- WSL2 avec une distribution Linux (Ubuntu, Debian, etc.)
- WSLg activé (GUI Linux)
- Python 3 + GTK3 + PyGObject

### Vérifier WSLg
```bash
# Si cette commande ouvre une fenêtre, WSLg fonctionne
xeyes
```

## Installation des dépendances

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install python3-gi gir1.2-gtk-3.0 pulseaudio-utils
```

### Pour le son (optionnel)
```bash
sudo apt install sound-theme-freedesktop
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

1. Lance `claude` dans WSL
2. Quand Claude demande une validation ou termine, la notification apparaît
3. Clique sur la notification pour activer Windows Terminal

## Fonctionnement

- `floatbar.py` : Script Python/GTK3 qui crée la notification (via WSLg)
- `notify-wrapper.sh` : Wrapper bash qui joue le son et lance la notification
- `bashrc-claude-function.sh` : Fonction à ajouter au shell

## Messages et Sons

| Type | Message | Son |
|------|---------|-----|
| Permission demandée | "Claude a besoin de votre intervention" | message.oga |
| Tâche terminée | "Claude a terminé de réaliser votre demande" | complete.oga |

## Personnalisation

### Changer les sons
Dans `notify-wrapper.sh`, modifie les chemins :
```bash
SOUND="/usr/share/sounds/freedesktop/stereo/message.oga"
```

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

## Comparaison avec la version PowerShell

| | Version GTK (cette version) | Version PowerShell |
|---|---|---|
| Dépendances | Python, GTK3, WSLg | PowerShell uniquement |
| Glassmorphism | Semi-transparent | Acrylic (vrai blur) |
| Son | PulseAudio (Linux) | SystemSounds (Windows) |
| Compatibilité | WSL2 + WSLg requis | Tout WSL |
| Code | Identique à Linux | Spécifique Windows |

## Dépannage

### La notification n'apparaît pas
1. Vérifier WSLg :
   ```bash
   echo $DISPLAY  # Doit afficher quelque chose comme ":0"
   xeyes  # Doit ouvrir une fenêtre
   ```

2. Vérifier GTK :
   ```bash
   python3 -c "import gi; gi.require_version('Gtk', '3.0'); from gi.repository import Gtk; print('OK')"
   ```

3. Tester manuellement :
   ```bash
   python3 ~/.claude/hooks/floatbar.py --message "Test"
   ```

### Le son ne joue pas
```bash
# Installer les sons
sudo apt install sound-theme-freedesktop

# Tester
paplay /usr/share/sounds/freedesktop/stereo/bell.oga
```

### WSLg n'est pas disponible
- Mise à jour Windows requise (Windows 11 ou Windows 10 21H2+)
- Alternative : utiliser la version PowerShell dans le dossier `windows/`

### La fenêtre n'est pas transparente
La transparence nécessite que WSLg soit correctement configuré. Si ça ne fonctionne pas, la notification aura un fond opaque.
