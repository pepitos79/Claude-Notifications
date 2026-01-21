#!/usr/bin/env python3
"""
Notification glassmorphism pour Claude Code - Version WSL (via WSLg)
Affiche une notification flottante quand Claude attend une réponse
Nécessite: WSL2 + WSLg, GTK3, python3-gi
"""
import subprocess
import sys
import os
import gi

gi.require_version('Gtk', '3.0')
gi.require_version('Gdk', '3.0')
from gi.repository import Gtk, Gdk, GLib, Pango

# Récupérer les arguments
MESSAGE = "Claude a besoin de votre intervention"
NO_SOUND = '--no-sound' in sys.argv

if '--message' in sys.argv:
    msg_idx = sys.argv.index('--message')
    if msg_idx + 1 < len(sys.argv):
        MESSAGE = sys.argv[msg_idx + 1]


class FloatbarWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title="Claude Notification")

        # Configuration de la fenêtre
        self.set_decorated(False)
        self.set_resizable(False)
        self.set_keep_above(True)
        self.set_skip_taskbar_hint(True)
        self.set_skip_pager_hint(True)
        self.set_type_hint(Gdk.WindowTypeHint.NOTIFICATION)

        # Dimensions
        self.width = 420
        self.height = 70
        self.radius = 22
        self.set_default_size(self.width, self.height)

        # Transparence
        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual:
            self.set_visual(visual)
        self.set_app_paintable(True)

        # Contenu
        self.box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        self.box.set_margin_start(20)
        self.box.set_margin_end(15)

        # Label message
        self.label = Gtk.Label(label=MESSAGE)
        self.label.set_xalign(0)
        self.label.set_hexpand(True)
        self.label.modify_font(Pango.FontDescription("Sans 12"))
        self.box.pack_start(self.label, True, True, 0)

        # Bouton fermer
        self.close_btn = Gtk.Label(label="✕")
        self.close_btn.modify_font(Pango.FontDescription("Sans 14"))
        self.box.pack_end(self.close_btn, False, False, 0)

        # Event box pour les clics
        self.event_box = Gtk.EventBox()
        self.event_box.add(self.box)
        self.event_box.connect("button-press-event", self.on_click)
        self.add(self.event_box)

        # Positionnement en bas au centre
        display = Gdk.Display.get_default()
        monitor = display.get_primary_monitor()
        geometry = monitor.get_geometry()
        x = (geometry.width - self.width) // 2
        y = geometry.height - self.height - 100
        self.move(x, y)

        # Dessiner le fond
        self.connect("draw", self.on_draw)

        # Auto-fermeture après 10 secondes
        GLib.timeout_add_seconds(10, self.close_window)

        # Appliquer le CSS
        self.apply_css()

    def apply_css(self):
        css = b"""
        * {
            color: white;
        }
        window {
            background-color: transparent;
        }
        """
        style_provider = Gtk.CssProvider()
        style_provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            style_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

    def on_draw(self, widget, cr):
        # Fond semi-transparent avec coins arrondis
        cr.set_source_rgba(0.12, 0.12, 0.12, 0.85)

        # Dessiner un rectangle arrondi
        width = self.get_allocated_width()
        height = self.get_allocated_height()
        radius = self.radius

        cr.new_sub_path()
        cr.arc(width - radius, radius, radius, -1.5708, 0)
        cr.arc(width - radius, height - radius, radius, 0, 1.5708)
        cr.arc(radius, height - radius, radius, 1.5708, 3.1416)
        cr.arc(radius, radius, radius, 3.1416, 4.7124)
        cr.close_path()
        cr.fill()

        return False

    def on_click(self, widget, event):
        self.activate_terminal()
        self.close_window()

    def activate_terminal(self):
        """Active Windows Terminal via cmd.exe"""
        try:
            # Méthode 1: Utiliser wslview pour focus Windows Terminal
            subprocess.run(
                ["cmd.exe", "/c", "start", "", "wt.exe", "-w", "0"],
                capture_output=True,
                stderr=subprocess.DEVNULL
            )
        except Exception:
            pass

    def close_window(self):
        Gtk.main_quit()
        return False


def play_sound():
    """Joue un son de notification"""
    if NO_SOUND:
        return

    # Essayer via PulseAudio (WSLg)
    sounds = [
        "/usr/share/sounds/freedesktop/stereo/message.oga",
        "/usr/share/sounds/freedesktop/stereo/complete.oga",
    ]

    for sound in sounds:
        if os.path.exists(sound):
            try:
                subprocess.Popen(
                    ["paplay", sound],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL
                )
                return
            except FileNotFoundError:
                continue

    # Fallback: son Windows via cmd.exe
    try:
        subprocess.Popen(
            ["cmd.exe", "/c", "echo \x07"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
    except Exception:
        pass


if __name__ == "__main__":
    # Jouer le son
    play_sound()

    # Créer et afficher la fenêtre
    win = FloatbarWindow()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()
