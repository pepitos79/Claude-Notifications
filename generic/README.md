# Claude Code - Notification Glassmorphism pour macOS

Système de notification desktop pour Claude Code avec :
- Notification flottante style glassmorphism (420x70, radius 22)
- Sons différents selon le contexte (Sosumi / Hero)
- Messages contextuels (intervention demandée / tâche terminée)
- Ciblage automatique du bon onglet Terminal (même avec plusieurs fenêtres/onglets)

## Prérequis

- macOS
- Python 3.x
- PyObjC (pour AppKit/Quartz)

## Installation

### 1. Créer le dossier hooks
```bash
mkdir -p ~/.claude/hooks
```

### 2. Copier les scripts
```bash
cp floatbar.py ~/.claude/hooks/
cp notify-wrapper.sh ~/.claude/hooks/
cp capture-session.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh ~/.claude/hooks/*.py
```

### 3. Installer les dépendances Python
```bash
cd ~/.claude/hooks
python3 -m venv venv
source venv/bin/activate
pip install pyobjc-framework-Cocoa pyobjc-framework-Quartz
```

### 4. Ajouter la fonction claude dans ~/.zshrc
Copie le contenu de `zshrc-claude-function.sh` dans ton `~/.zshrc` :
```bash
cat zshrc-claude-function.sh >> ~/.zshrc
source ~/.zshrc
```

### 5. Configurer le hook Claude Code
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

1. Lance `claude` dans un terminal (la fonction wrapper capture automatiquement l'onglet)
2. Quand Claude demande une validation, la notification apparaît
3. Clique sur la notification pour revenir au bon onglet Terminal

## Fonctionnement

- `floatbar.py` : Crée la notification glassmorphism avec PyObjC
- `notify-wrapper.sh` : Joue le son et lance la notification
- `capture-session.sh` : Capture les infos de session (window ID + TTY)
- `zshrc-claude-function.sh` : Wrapper qui capture les infos au lancement de Claude

## Messages et Sons

| Type | Message | Son |
|------|---------|-----|
| Permission demandée | "Claude a besoin de votre intervention" | Sosumi |
| Tâche terminée | "Claude a terminé de réaliser votre demande" | Hero |

## Personnalisation

### Changer les sons
Dans `notify-wrapper.sh`, modifie les chemins des sons :
```bash
SOUND="/System/Library/Sounds/Sosumi.aiff"  # Pour intervention
SOUND="/System/Library/Sounds/Hero.aiff"    # Pour terminé
```

Sons disponibles dans `/System/Library/Sounds/` :
- Sosumi.aiff
- Glass.aiff
- Hero.aiff
- Ping.aiff
- Pop.aiff
- Purr.aiff
- etc.

### Changer les messages
Dans `notify-wrapper.sh`, modifie les valeurs de `MESSAGE` :
```bash
MESSAGE="Claude a besoin de votre intervention"      # Pour permission
MESSAGE="Claude a terminé de réaliser votre demande" # Pour terminé
```

### Changer la durée d'affichage
Dans `floatbar.py`, modifie le timer (en secondes) :
```python
NSTimer.scheduledTimerWithTimeInterval_repeats_block_(10.0, False, lambda t: close_window())
```
