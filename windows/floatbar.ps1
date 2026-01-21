param(
    [string]$Message = "Claude a besoin de votre intervention",
    [string]$SessionInfo = "",
    [switch]$NoSound
)

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# API pour l'effet Acrylic/Blur (Windows 10/11)
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class AcrylicHelper {
    [DllImport("user32.dll")]
    public static extern int SetWindowCompositionAttribute(IntPtr hwnd, ref WindowCompositionAttributeData data);

    [StructLayout(LayoutKind.Sequential)]
    public struct WindowCompositionAttributeData {
        public WindowCompositionAttribute Attribute;
        public IntPtr Data;
        public int SizeOfData;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct AccentPolicy {
        public AccentState AccentState;
        public int AccentFlags;
        public int GradientColor;
        public int AnimationId;
    }

    public enum WindowCompositionAttribute {
        WCA_ACCENT_POLICY = 19
    }

    public enum AccentState {
        ACCENT_DISABLED = 0,
        ACCENT_ENABLE_GRADIENT = 1,
        ACCENT_ENABLE_TRANSPARENTGRADIENT = 2,
        ACCENT_ENABLE_BLURBEHIND = 3,
        ACCENT_ENABLE_ACRYLICBLURBEHIND = 4,
        ACCENT_INVALID_STATE = 5
    }

    public static void EnableAcrylic(IntPtr handle, int gradientColor) {
        var accent = new AccentPolicy();
        accent.AccentState = AccentState.ACCENT_ENABLE_ACRYLICBLURBEHIND;
        accent.GradientColor = gradientColor;

        var accentSize = Marshal.SizeOf(accent);
        var accentPtr = Marshal.AllocHGlobal(accentSize);
        Marshal.StructureToPtr(accent, accentPtr, false);

        var data = new WindowCompositionAttributeData();
        data.Attribute = WindowCompositionAttribute.WCA_ACCENT_POLICY;
        data.SizeOfData = accentSize;
        data.Data = accentPtr;

        SetWindowCompositionAttribute(handle, ref data);

        Marshal.FreeHGlobal(accentPtr);
    }
}

public class WindowHelper {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
}
"@

# Créer la fenêtre XAML
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Claude Notification"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        ShowInTaskbar="False"
        Width="420"
        Height="70"
        ResizeMode="NoResize">
    <Border CornerRadius="22" Background="#CC1E1E1E">
        <Grid>
            <TextBlock Text="MESSAGE_PLACEHOLDER"
                       Foreground="White"
                       FontSize="14"
                       FontWeight="Medium"
                       FontFamily="Segoe UI"
                       VerticalAlignment="Center"
                       Margin="20,0,50,0"/>
            <TextBlock Text="✕"
                       Foreground="Gray"
                       FontSize="16"
                       HorizontalAlignment="Right"
                       VerticalAlignment="Center"
                       Margin="0,0,15,0"
                       Name="CloseButton"
                       Cursor="Hand"/>
        </Grid>
    </Border>
</Window>
"@

# Remplacer le placeholder par le vrai message
$xaml.Window.Border.Grid.TextBlock[0].Text = $Message

# Charger la fenêtre
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Positionner en bas au centre
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$window.Left = ($screen.Width - $window.Width) / 2
$window.Top = $screen.Height - $window.Height - 100

# Appliquer l'effet Acrylic après l'affichage
$window.Add_Loaded({
    $hwnd = (New-Object System.Windows.Interop.WindowInteropHelper $window).Handle
    # Couleur: AABBGGRR format, AA=alpha (CC = 80% opaque)
    [AcrylicHelper]::EnableAcrylic($hwnd, 0xCC1E1E1E)
})

# Fonction pour activer Windows Terminal
function Activate-WindowsTerminal {
    # Chercher Windows Terminal
    $wtProcess = Get-Process -Name "WindowsTerminal" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($wtProcess) {
        [WindowHelper]::SetForegroundWindow($wtProcess.MainWindowHandle) | Out-Null
    }
}

# Clic sur la fenêtre = activer Terminal et fermer
$window.Add_MouseLeftButtonDown({
    Activate-WindowsTerminal
    $window.Close()
})

# Auto-fermeture après 10 secondes
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(10)
$timer.Add_Tick({
    $timer.Stop()
    $window.Close()
})
$timer.Start()

# Afficher la fenêtre
$window.ShowDialog() | Out-Null
