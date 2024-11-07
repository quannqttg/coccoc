# Check if the Win32 type is already defined
if (-not ([System.Management.Automation.PSTypeName]'Win32').Type) {
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public class Win32 {
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        [DllImport("user32.dll")]
        public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
        [DllImport("user32.dll")]
        public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
        [DllImport("user32.dll")]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

        private const int GWL_EXSTYLE = -20;
        private const int WS_EX_TOOLWINDOW = 0x80;
        private const int WS_EX_APPWINDOW = 0x40000;

        public static void HideFromTray(IntPtr hWnd) {
            int style = GetWindowLong(hWnd, GWL_EXSTYLE);
            if (style == 0) {
                int error = Marshal.GetLastWin32Error();
                if (error != 0) {
                    throw new System.ComponentModel.Win32Exception(error);
                }
            }
            // Remove the app window from taskbar and notification area
            SetWindowLong(hWnd, GWL_EXSTYLE, (style | WS_EX_TOOLWINDOW) & ~WS_EX_APPWINDOW);
            ShowWindow(hWnd, 0); // Hide window
        }
    }
"@ -Language CSharp
}

$processName = "Grass" # Make sure this matches your application's process name
$exePath = "C:\Program Files\Grass\Grass.exe"

# Start the process if it's not already running
$proc = Get-Process -Name $processName -ErrorAction SilentlyContinue
if ($proc -eq $null) {
    $proc = Start-Process -FilePath $exePath -PassThru
}

# Wait until the window handle is available or timeout after 60 seconds
$timeout = 60
$sw = [System.Diagnostics.Stopwatch]::StartNew()
while (($sw.ElapsedMilliseconds -lt ($timeout * 1000)) -and ($proc.MainWindowHandle -eq [IntPtr]::Zero)) {
    Start-Sleep -Milliseconds 500
    $proc.Refresh()
    
    # Try to find the window by class name or window title
    $hwnd = [Win32]::FindWindow($null, $processName) # Adjust if necessary based on actual window title
    if ($hwnd -ne [IntPtr]::Zero) {
        $proc.MainWindowHandle = $hwnd
        break
    }
}
$sw.Stop()

if ($proc.MainWindowHandle -eq [IntPtr]::Zero) {
    Write-Output "Failed to retrieve window handle. The process may not have a visible window."
    exit
}

$hwnd = $proc.MainWindowHandle

try {
    [Win32]::HideFromTray($hwnd)
    Write-Output "Successfully hidden the icon from the system tray."
}
catch {
    Write-Output "An error occurred while trying to hide the icon from the system tray: $_"
}
