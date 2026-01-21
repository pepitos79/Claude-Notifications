#!/usr/bin/env python3
"""
Notification glassmorphism pour Claude Code
Affiche une notification flottante quand Claude attend une réponse
Cliquer dessus active la bonne fenêtre Terminal et le bon onglet
"""
import subprocess
import threading
import sys
import os

# Activer le venv
venv_path = os.path.join(os.path.dirname(__file__), 'venv', 'lib', 'python3.14', 'site-packages')
sys.path.insert(0, venv_path)

from AppKit import (
    NSApplication, NSWindow, NSWindowStyleMaskBorderless,
    NSBackingStoreBuffered, NSColor, NSFont, NSTextField,
    NSVisualEffectView, NSVisualEffectBlendingModeBehindWindow,
    NSVisualEffectMaterialDark, NSView, NSMakeRect,
    NSFloatingWindowLevel, NSApplicationActivationPolicyAccessory,
    NSButton, NSBezelStyleInline, NSTimer, NSWorkspace,
    NSApplicationActivateIgnoringOtherApps
)
from Quartz import CGMainDisplayID, CGDisplayPixelsWide, CGDisplayPixelsHigh
import objc

# Récupérer l'ID de la fenêtre et le TTY depuis les arguments
WINDOW_ID = sys.argv[1] if len(sys.argv) > 1 else ''
CLAUDE_TTY = sys.argv[2] if len(sys.argv) > 2 else ''
NO_SOUND = '--no-sound' in sys.argv

# Récupérer le message personnalisé
MESSAGE = "Claude a besoin de votre intervention"  # Par défaut
if '--message' in sys.argv:
    msg_idx = sys.argv.index('--message')
    if msg_idx + 1 < len(sys.argv):
        MESSAGE = sys.argv[msg_idx + 1]

def play_sound():
    if not NO_SOUND:
        subprocess.run(["afplay", "/System/Library/Sounds/Sosumi.aiff"])

def activate_terminal_window():
    """Active la fenêtre Terminal avec le bon onglet via AppleScript"""
    if WINDOW_ID and CLAUDE_TTY:
        script = '''
        tell application "Terminal"
            activate
            delay 0.5
            set targetWindow to window id %s
            set frontmost of targetWindow to true
            set index of targetWindow to 1
            repeat with t in tabs of targetWindow
                if tty of t is "%s" then
                    set selected of t to true
                    exit repeat
                end if
            end repeat
        end tell
        ''' % (WINDOW_ID, CLAUDE_TTY)
    else:
        script = '''
        tell application "Terminal"
            activate
        end tell
        '''
    subprocess.run(["osascript", "-e", script], capture_output=True, text=True)

# Classe personnalisée pour gérer les clics
class ClickableView(NSView):
    def initWithFrame_callback_(self, frame, callback):
        self = objc.super(ClickableView, self).initWithFrame_(frame)
        if self is None:
            return None
        self.callback = callback
        return self

    def mouseDown_(self, event):
        if self.callback:
            self.callback()

def create_floatbar():
    app = NSApplication.sharedApplication()
    app.setActivationPolicy_(NSApplicationActivationPolicyAccessory)

    # Dimensions
    width = 420
    height = 70
    radius = 22

    # Position centrée en bas
    screen_width = CGDisplayPixelsWide(CGMainDisplayID())
    screen_height = CGDisplayPixelsHigh(CGMainDisplayID())
    x = (screen_width - width) // 2
    y = 100  # Distance du bas

    # Créer la fenêtre
    window = NSWindow.alloc().initWithContentRect_styleMask_backing_defer_(
        NSMakeRect(x, y, width, height),
        NSWindowStyleMaskBorderless,
        NSBackingStoreBuffered,
        False
    )
    window.setLevel_(NSFloatingWindowLevel)
    window.setOpaque_(False)
    window.setBackgroundColor_(NSColor.clearColor())
    window.setHasShadow_(True)

    content_view = window.contentView()

    # Fonction pour ouvrir Terminal et fermer la notification
    def open_terminal_and_close():
        activate_terminal_window()
        window.close()
        app.stop_(None)

    # NSVisualEffectView pour le blur/glassmorphism
    blur_view = NSVisualEffectView.alloc().initWithFrame_(NSMakeRect(0, 0, width, height))
    blur_view.setMaterial_(NSVisualEffectMaterialDark)
    blur_view.setBlendingMode_(NSVisualEffectBlendingModeBehindWindow)
    blur_view.setState_(1)
    blur_view.setWantsLayer_(True)
    blur_view.layer().setCornerRadius_(radius)
    blur_view.layer().setMasksToBounds_(True)

    content_view.addSubview_(blur_view)

    # Vue cliquable par-dessus tout
    clickable = ClickableView.alloc().initWithFrame_callback_(
        NSMakeRect(0, 0, width, height),
        open_terminal_and_close
    )
    clickable.setWantsLayer_(True)

    # Label texte
    label_height = 20
    label_y = (height - label_height) / 2
    label = NSTextField.alloc().initWithFrame_(NSMakeRect(20, label_y, width - 70, label_height))
    label.setStringValue_(MESSAGE)
    label.setBezeled_(False)
    label.setDrawsBackground_(False)
    label.setEditable_(False)
    label.setSelectable_(False)
    label.setTextColor_(NSColor.whiteColor())
    label.setFont_(NSFont.systemFontOfSize_weight_(14, 0.3))
    blur_view.addSubview_(label)

    # Bouton X
    close_btn = NSTextField.alloc().initWithFrame_(NSMakeRect(width - 40, label_y, 26, label_height))
    close_btn.setStringValue_("✕")
    close_btn.setBezeled_(False)
    close_btn.setDrawsBackground_(False)
    close_btn.setEditable_(False)
    close_btn.setSelectable_(False)
    close_btn.setTextColor_(NSColor.grayColor())
    close_btn.setFont_(NSFont.systemFontOfSize_(16))
    blur_view.addSubview_(close_btn)

    # Ajouter la vue cliquable par-dessus
    content_view.addSubview_(clickable)

    window.makeKeyAndOrderFront_(None)

    # Son
    threading.Thread(target=play_sound, daemon=True).start()

    # Auto-fermeture après 10 secondes
    def close_window():
        window.close()
        app.stop_(None)

    NSTimer.scheduledTimerWithTimeInterval_repeats_block_(10.0, False, lambda t: close_window())

    app.run()

if __name__ == "__main__":
    create_floatbar()
