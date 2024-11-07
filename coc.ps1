# Define the Win32 class
$win32Definition = @"
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

    public const int GWL_EXSTYLE = -20;
    public const int WS_EX_TOOLWINDOW = 0x80;
    public const int WS_EX_APPWINDOW = 0x40000;

    public static void HideFromTaskbarAndTray(IntPtr hWnd) {
        int style = GetWindowLong(hWnd, GWL_EXSTYLE);
        SetWindowLong(hWnd, GWL_EXSTYLE, (style | WS_EX_TOOLWINDOW) & ~WS_EX_APPWINDOW);
        ShowWindow(hWnd, 0); // Hide window
    }
}
"@

# Add the Win32 type if it's not already defined
if (-not ([System.Management.Automation.PSTypeName]'Win32').Type) {
    Add-Type -TypeDefinition $win32Definition -Language CSharp
}

$processName = "browser"
$exePath = "C:\Program Files\CocCoc\Browser\Application\browser.exe"

# Function to find or start the process
function Get-OrStartProcess {
    $proc = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($null -eq $proc) {
        $proc = Start-Process -FilePath $exePath -PassThru
    }
    return $proc
}

# Get or start the process
$proc = Get-OrStartProcess

# Wait until the window handle is available or timeout after 60 seconds
$timeout = 60
$sw = [System.Diagnostics.Stopwatch]::StartNew()
while (($sw.ElapsedMilliseconds -lt ($timeout * 1000)) -and ($proc.MainWindowHandle -eq [IntPtr]::Zero)) {
    Start-Sleep -Milliseconds 500
    $proc.Refresh()
    
    # Try to find the window by class name or window title
    $hwnd = [Win32]::FindWindow($null, $processName)
    if ($hwnd -ne [IntPtr]::Zero) {
        $proc.MainWindowHandle = $hwnd
        break
    }

    # If the process has exited, try to start it again
    if ($proc.HasExited) {
        $proc = Get-OrStartProcess
    }
}
$sw.Stop()

if ($proc.MainWindowHandle -eq [IntPtr]::Zero) {
    Write-Output "Failed to retrieve window handle. The process may not have a visible window."
    exit
}

$hwnd = $proc.MainWindowHandle

try {
    [Win32]::HideFromTaskbarAndTray($hwnd)
    Write-Output "Successfully hidden the application from the taskbar and system tray."
}
catch {
    Write-Output "An error occurred while trying to hide the application: $_"
    exit 1
}

# Exit the script after success
exit 0
