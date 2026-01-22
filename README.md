# Claude Code Desktop Notifications

Système de notification desktop glassmorphism pour [Claude Code](https://claude.ai/claude-code) (CLI d'Anthropic).

![Notification Preview](https://img.shields.io/badge/style-glassmorphism-blueviolet)
![Platforms](https://img.shields.io/badge/platforms-macOS%20|%20Linux%20|%20Windows%20|%20WSL-blue)

## Fonctionnalités

- 🔔 **Notification flottante** style glassmorphism
- 🔊 **Sons distincts** selon le contexte (intervention demandée / tâche terminée)
- 🎯 **Ciblage automatique** du bon onglet Terminal
- ⏱️ **Auto-fermeture** après 10 secondes
- 🖱️ **Clic pour focus** - retourne directement au bon terminal

## Messages

| Contexte | Message | Son |
|----------|---------|-----|
| Permission demandée | "Claude a besoin de votre intervention" | Notification |
| Tâche terminée | "Claude a terminé de réaliser votre demande" | Succès |

## Versions disponibles

| Dossier | Plateforme | Technologie | Glassmorphism |
|---------|------------|-------------|---------------|
| `generic/` | macOS | Python + AppKit (PyObjC) | ✅ Vrai blur |
| `linux/` | Linux | Python + GTK3 | Semi-transparent |
| `windows/` | Windows | PowerShell + WPF | ✅ Vrai blur (Acrylic) |
| `wsl-powershell/` | WSL | Bash + PowerShell | Toast Notification Windows |
| `wsl-gtk/` | WSL | Python + GTK3 via WSLg | Semi-transparent |

## Installation rapide

### macOS
```bash
# Copier les scripts
mkdir -p ~/.claude/hooks
cp generic/*.py generic/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*

# Installer les dépendances
cd ~/.claude/hooks
python3 -m venv venv
source venv/bin/activate
pip install pyobjc-framework-Cocoa pyobjc-framework-Quartz

# Ajouter la fonction au shell
cat generic/zshrc-claude-function.sh >> ~/.zshrc
source ~/.zshrc
```

### Linux
```bash
# Installer les dépendances
sudo apt install python3-gi gir1.2-gtk-3.0 wmctrl pulseaudio-utils

# Copier les scripts
mkdir -p ~/.claude/hooks
cp linux/*.py linux/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*

# Ajouter la fonction au shell
cat linux/bashrc-claude-function.sh >> ~/.bashrc
source ~/.bashrc
```

### Windows
```powershell
# Copier les scripts
New-Item -ItemType Directory -Path "$env:USERPROFILE\.claude\hooks" -Force
Copy-Item windows\*.ps1 "$env:USERPROFILE\.claude\hooks\"

# Ajouter la fonction au profil PowerShell
Get-Content windows\profile-claude-function.ps1 | Add-Content $PROFILE
. $PROFILE
```

### WSL (option PowerShell - recommandé)
```bash
# Copier les scripts
mkdir -p ~/.claude/hooks
cp wsl-powershell/*.ps1 wsl-powershell/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# Ajouter la fonction au shell
cat wsl-powershell/bashrc-claude-function.sh >> ~/.bashrc
source ~/.bashrc
```

### WSL (option GTK via WSLg)
```bash
# Vérifier WSLg
echo $DISPLAY  # Doit afficher ":0" ou similaire

# Installer les dépendances
sudo apt install python3-gi gir1.2-gtk-3.0 pulseaudio-utils

# Copier les scripts
mkdir -p ~/.claude/hooks
cp wsl-gtk/*.py wsl-gtk/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*

# Ajouter la fonction au shell
cat wsl-gtk/bashrc-claude-function.sh >> ~/.bashrc
source ~/.bashrc
```

## Configuration du Hook Claude Code

Ajouter dans `~/.claude/settings.json` (macOS/Linux/WSL) ou `%USERPROFILE%\.claude\settings.json` (Windows) :

### macOS / Linux / WSL
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

### Windows
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File \"%USERPROFILE%\\.claude\\hooks\\notify-wrapper.ps1\""
          }
        ]
      }
    ]
  }
}
```

## Personnalisation

Consultez le README de chaque version pour les options de personnalisation :
- Dimensions de la notification
- Couleurs et transparence
- Sons
- Durée d'affichage

## Prérequis par plateforme

| Plateforme | Prérequis |
|------------|-----------|
| macOS | Python 3, PyObjC |
| Linux | Python 3, GTK3, PyGObject, wmctrl |
| Windows | PowerShell 5.1+, Windows 10/11 |
| WSL | WSL2 + WSLg, Python 3, GTK3 |

## Aperçu

La notification apparaît en bas au centre de l'écran avec :
- Fond glassmorphism (semi-transparent avec blur sur macOS/Windows)
- Texte blanc
- Bouton de fermeture
- Coins arrondis (radius 22px)

## Notes et limitations

⚠️ **Versions non testées** : `wsl-gtk/`, `windows/` et `linux/` n'ont pas été testées en conditions réelles.

⚠️ **WSL-PowerShell** : Le clic sur la notification ne redirige pas vers le bon terminal ou le bon onglet. C'est une limitation de l'API Toast Notification Windows depuis le contexte WSL.

## Licence

MIT License - Libre d'utilisation et de modification.

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.
