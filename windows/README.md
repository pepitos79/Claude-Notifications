# Claude Code - Notification Glassmorphism pour Windows

Système de notification desktop pour Claude Code sur Windows avec :
- Notification flottante style glassmorphism (effet Acrylic Windows 10/11)
- Sons de notification Windows
- Activation de Windows Terminal au clic

## Prérequis

- Windows 10 (1803+) ou Windows 11
- PowerShell 5.1+ (inclus avec Windows)
- Windows Terminal (recommandé)

## Installation

### 1. Créer le dossier hooks
```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\.claude\hooks" -Force
```

### 2. Copier les scripts
```powershell
Copy-Item floatbar.ps1 "$env:USERPROFILE\.claude\hooks\"
Copy-Item notify-wrapper.ps1 "$env:USERPROFILE\.claude\hooks\"
```

### 3. Autoriser l'exécution des scripts (si nécessaire)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 4. Ajouter la fonction claude au profil PowerShell
```powershell
# Ouvrir le profil
notepad $PROFILE

# Ou créer le profil s'il n'existe pas
if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

# Copier le contenu de profile-claude-function.ps1 dans le profil
Get-Content profile-claude-function.ps1 | Add-Content $PROFILE

# Recharger le profil
. $PROFILE
```

### 5. Configurer le hook Claude Code
Dans `%USERPROFILE%\.claude\settings.json`, ajoute :
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

## Utilisation

1. Lance `claude` dans PowerShell/Windows Terminal
2. Quand Claude demande une validation ou termine, la notification apparaît
3. Clique sur la notification pour revenir à Windows Terminal

## Fonctionnement

- `floatbar.ps1` : Script PowerShell/WPF qui crée la notification glassmorphism
- `notify-wrapper.ps1` : Wrapper qui joue le son et lance la notification
- `profile-claude-function.ps1` : Fonction à ajouter au profil PowerShell

## Messages et Sons

| Type | Message | Son |
|------|---------|-----|
| Permission demandée | "Claude a besoin de votre intervention" | Asterisk |
| Tâche terminée | "Claude a terminé de réaliser votre demande" | Exclamation |

## Personnalisation

### Changer les sons
Dans `notify-wrapper.ps1`, modifie les valeurs de `$Sound` :
```powershell
$Sound = "Asterisk"     # Son d'information
$Sound = "Beep"         # Bip simple
$Sound = "Exclamation"  # Son d'exclamation
$Sound = "Hand"         # Son d'erreur critique
$Sound = "Question"     # Son de question
```

### Changer les dimensions
Dans `floatbar.ps1`, modifie dans le XAML :
```xml
Width="420"
Height="70"
```

### Changer le border-radius
Dans `floatbar.ps1`, modifie :
```xml
<Border CornerRadius="22" ...>
```

### Changer la couleur de fond
Format: `#AARRGGBB` (AA = alpha/transparence)
```xml
Background="#CC1E1E1E"
```

### Changer la durée d'affichage
Dans `floatbar.ps1`, modifie :
```powershell
$timer.Interval = [TimeSpan]::FromSeconds(10)
```

## Dépannage

### La notification n'apparaît pas
- Vérifie que l'exécution des scripts est autorisée :
  ```powershell
  Get-ExecutionPolicy -Scope CurrentUser
  ```
- Teste manuellement :
  ```powershell
  powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\hooks\floatbar.ps1" -Message "Test"
  ```

### L'effet blur ne fonctionne pas
L'effet Acrylic nécessite Windows 10 1803+ ou Windows 11. Sur les versions antérieures, la notification aura un fond semi-transparent sans blur.

### Erreur "cannot be loaded because running scripts is disabled"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Le son ne joue pas
Vérifie le volume Windows et que les sons système sont activés dans les paramètres.
