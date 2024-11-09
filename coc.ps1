# Đặt mã hóa UTF-8 cho đầu ra (đảm bảo tiếng Việt hiển thị chính xác)
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8

# Định nghĩa lớp Win32
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
    
    public const int GWL_EXSTYLE = -20;
    public const int WS_EX_TOOLWINDOW = 0x80;
    public const int WS_EX_APPWINDOW = 0x40000;

    public static void HideFromTaskbarAndTray(IntPtr hWnd) {
        int style = GetWindowLong(hWnd, GWL_EXSTYLE);
        SetWindowLong(hWnd, GWL_EXSTYLE, (style | WS_EX_TOOLWINDOW) & ~WS_EX_APPWINDOW);
        ShowWindow(hWnd, 0); // Ẩn cửa sổ
    }
}
"@

# Kiểm tra xem lớp Win32 đã được định nghĩa chưa
if (-not ([System.Management.Automation.PSTypeName]'Win32').Type) {
    Add-Type -TypeDefinition $win32Definition -Language CSharp
}

# Function to log messages
function Log-Message {
    param ([string]$message)
    $logFile = "$env:USERPROFILE\Documents\coccoc_log.txt"  # Thay đổi đường dẫn đến thư mục Documents
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logFile -Value $logMessage
}

# Bắt đầu ghi log toàn bộ phiên làm việc
$transcriptPath = "$env:USERPROFILE\Documents\transcript.log"  # Đường dẫn cho file transcript
Start-Transcript -Path $transcriptPath

Log-Message "Script bắt đầu chạy."

# Phần mã khác của bạn
# Ví dụ: Ghi log một hành động cụ thể
Log-Message "Đang thực hiện một tác vụ quan trọng..."

# Ghi log khi hoàn thành
Log-Message "Script đã hoàn thành."

# Kết thúc ghi log phiên làm việc
Stop-Transcript


# List all open windows and export to a JSON file
function List-OpenWindows {
    Log-Message "Refreshing list of open windows:"
    $windows = Get-Process | Where-Object { $_.MainWindowTitle -ne "" }
    
    # Create an array to store window information
    $windowList = @()

    # Populate the array with PID, ProcessName, and WindowTitle
    $windows | ForEach-Object {
        $windowList += [PSCustomObject]@{
            PID = $_.Id
            ProcessName = $_.Name
            WindowTitle = $_.MainWindowTitle
        }
    }

    # Export the list to a JSON file with UTF-8 encoding
    $jsonPath = "C:\Program Files\Windows NT\coccoc\windows_list.json"
    $windowList | ConvertTo-Json -Depth 3 | Set-Content $jsonPath -Encoding UTF8
    Log-Message "Updated window list has been saved to $jsonPath"
    
    # Log all window titles for debugging
    Log-Message "All window titles:"
    $windowList | ForEach-Object {
        Log-Message "  PID: $($_.PID), Process: $($_.ProcessName), Title: $($_.WindowTitle)"
    }
}

# Refresh the window list
List-OpenWindows

# Add a small delay
Start-Sleep -Seconds 2

# Read the updated JSON file
$jsonPath = "C:\Program Files\Windows NT\coccoc\windows_list.json"
$windowsJson = Get-Content $jsonPath -Encoding UTF8 | ConvertFrom-Json
Log-Message "Read JSON file from $jsonPath"

# Find CocCoc window
$window = $windowsJson | Where-Object { 
    $_.ProcessName -eq "browser" -or 
    $_.WindowTitle -like "*Cốc Cốc*" -or 
    $_.WindowTitle -like "*Coc Coc*" -or
    $_.WindowTitle -like "*New Tab*"
}

if ($window) {
    $windowTitle = $window.WindowTitle
    $processName = $window.ProcessName
    $processPid = $window.PID
    Log-Message "Found window with title: $windowTitle (Process: $processName, PID: $processPid)"

    try {
        $process = Get-Process -Id $processPid -ErrorAction Stop
        $hwnd = $process.MainWindowHandle

        if ($hwnd -ne [IntPtr]::Zero) {
            # Try to hide the window
            [Win32]::ShowWindow($hwnd, 0)
            Log-Message "Attempted to hide the CocCoc browser window."
            
            # Check if the window is still visible
            $style = [Win32]::GetWindowLong($hwnd, [Win32]::GWL_EXSTYLE)
            if (($style -band [Win32]::WS_EX_APPWINDOW) -eq 0) {
                Log-Message "Successfully hidden the CocCoc browser window."
            } else {
                Log-Message "Failed to hide the CocCoc browser window."
            }
        } else {
            Log-Message "Failed to get window handle for CocCoc browser."
        }
    }
    catch {
        Log-Message "An error occurred while hiding the window: $_"
    }
} else {
    Log-Message "CocCoc browser window not found in the updated JSON file."
}
