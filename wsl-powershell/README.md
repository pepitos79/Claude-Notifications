# Claude Code - Notification Toast pour WSL (PowerShell)

Système de notification desktop pour Claude Code sur WSL utilisant PowerShell pour afficher une **Toast Notification Windows native** avec :
- Notification Windows native (style Windows 10/11)
- Sons de notification Windows
- Fonctionne depuis WSL sans problème de contexte graphique

**Cette version utilise les Toast Notifications Windows** (pas WPF) car WPF ne fonctionne pas correctement depuis WSL.

## Pourquoi Toast et pas WPF ?

WPF (Windows Presentation Foundation) nécessite un contexte graphique complet qui n'est pas disponible quand PowerShell est lancé depuis WSL. Les Toast Notifications passent par le système de notifications Windows et fonctionnent parfaitement depuis WSL.

## Prérequis

- Windows 10/11 avec WSL (WSL1 ou WSL2)
- PowerShell 5.1+ (inclus avec Windows)
- Windows Terminal (recommandé)

## Comparaison des versions WSL

| | Version Toast (cette version) | Version GTK (wsl-gtk/) |
|---|---|---|
| Type | Toast Notification Windows | Fenêtre GTK flottante |
| Style | Notification système native | Glassmorphism semi-transparent |
| Prérequis | PowerShell (inclus) | WSLg requis |
| Compatibilité | WSL1 et WSL2 | WSL2 + WSLg uniquement |
| Position | Centre de notifications | Bas de l'écran |

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
2. Quand Claude demande une validation ou termine, une Toast Notification Windows apparaît
3. Clique sur la notification pour l'ouvrir

## Fonctionnement

- `notify-wrapper.sh` : Script bash qui appelle PowerShell pour le son et la notification
- `floatbar.ps1` : Script PowerShell qui affiche une Toast Notification Windows
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

### Changer le titre
Dans `floatbar.ps1`, modifie le paramètre par défaut :
```powershell
[string]$Title = "Claude Code"
```

## Dépannage

### La notification n'apparaît pas
- Vérifie que PowerShell est accessible :
  ```bash
  powershell.exe -Command "echo test"
  ```
- Vérifie que les notifications sont activées dans Windows :
  Paramètres → Système → Notifications
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

### Fallback MessageBox
Si les Toast Notifications ne fonctionnent pas, le script affiche automatiquement une MessageBox comme fallback.
