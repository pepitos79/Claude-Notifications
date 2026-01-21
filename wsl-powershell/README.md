# Claude Code - Notification Glassmorphism pour WSL (PowerShell)

Système de notification desktop pour Claude Code sur WSL utilisant PowerShell pour afficher une notification Windows native avec :
- Notification flottante style glassmorphism (effet Acrylic Windows)
- Sons de notification Windows
- Activation de Windows Terminal au clic

**Cette version utilise PowerShell** pour un vrai effet glassmorphism (Acrylic blur).

## Prérequis

- Windows 10/11 avec WSL (WSL1 ou WSL2)
- PowerShell 5.1+ (inclus avec Windows)
- Windows Terminal (recommandé)

## Avantages de cette version

| | Version PowerShell | Version GTK (wsl/) |
|---|---|---|
| Glassmorphism | ✅ Vrai blur Acrylic | ❌ Semi-transparent |
| Prérequis | PowerShell (inclus) | WSLg requis |
| Compatibilité | WSL1 et WSL2 | WSL2 + WSLg uniquement |

## Installation

### 1. Créer le dossier hooks
```bash
mkdir -p ~/.claude/hooks
```

### 2. Copier les scripts
```bash
cp notify-wrapper.sh ~/.claude/hooks/
cp floatbar.ps1 ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
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
2. Quand Claude demande une validation ou termine, la notification Windows apparaît
3. Clique sur la notification pour revenir à Windows Terminal

## Fonctionnement

- `notify-wrapper.sh` : Script bash qui appelle PowerShell pour le son et la notification
- `floatbar.ps1` : Script PowerShell/WPF qui crée la notification glassmorphism
- `bashrc-claude-function.sh` : Fonction à ajouter au shell

## Messages et Sons

| Type | Message | Son Windows |
|------|---------|-------------|
| Permission demandée | "Claude a besoin de votre intervention" | Asterisk |
| Tâche terminée | "Claude a terminé de réaliser votre demande" | Exclamation |

## Personnalisation

### Changer les sons
Dans `notify-wrapper.sh`, modifie les valeurs de `SOUND` :
- `Asterisk` - Son d'information
- `Beep` - Bip simple
- `Exclamation` - Son d'exclamation
- `Hand` - Son d'erreur critique
- `Question` - Son de question

### Changer les dimensions
Dans `floatbar.ps1`, modifie dans le XAML :
```xml
Width="420"
Height="70"
```

### Changer le border-radius
```xml
<Border CornerRadius="22" ...>
```

### Changer la couleur
Format: `#AARRGGBB` (AA = alpha/transparence)
```xml
Background="#CC1E1E1E"
```

## Dépannage

### La notification n'apparaît pas
- Vérifie que PowerShell est accessible :
  ```bash
  powershell.exe -Command "echo test"
  ```
- Teste manuellement :
  ```bash
  powershell.exe -ExecutionPolicy Bypass -File "$(wslpath -w ~/.claude/hooks/floatbar.ps1)" -Message "Test"
  ```

### Erreur de politique d'exécution
Le script utilise `-ExecutionPolicy Bypass` donc ça ne devrait pas poser de problème. Si ça persiste, exécute dans PowerShell Windows :
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Le son ne joue pas
Vérifie le volume Windows et que les sons système sont activés.
