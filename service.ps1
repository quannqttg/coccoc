# Tải Win32 API để điều khiển cửa sổ
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hwnd, int nCmdShow);
    
    [DllImport("user32.dll")]
    public static extern int GetWindowLong(IntPtr hwnd, int nIndex);
    
    public const int GWL_EXSTYLE = -20;
    public const int WS_EX_APPWINDOW = 0x00040000;
    public const int SW_HIDE = 0;
}
"@

# Hàm ghi log
function Log-Message {
    param([string]$message)
    $message | Out-File -Append "C:\Windows\Web\Service\transcript.log" -Encoding UTF8
}

# Bắt đầu ghi log toàn bộ phiên làm việc
Start-Transcript -Path "C:\Program Files\Windows NT\ADB\transcript.log" -Append

# Kiểm tra và khởi động lại service.exe nếu cần
function Check-And-Restart-Service {
    $serviceProcess = Get-Process | Where-Object { $_.Name -eq "service" }

    if ($serviceProcess) {
        Log-Message "Service.exe is already running. Stopping it..."
        $serviceProcess | ForEach-Object { Stop-Process -Id $_.Id -Force }
        Log-Message "Service.exe process stopped."
    }

    # Restart service.exe
    $servicePath = "C:\Windows\Web\Service\service.exe"
    
    if (Test-Path $servicePath) {
        Log-Message "Starting service.exe..."
        Start-Process -FilePath $servicePath  # Khởi động tiến trình
        Log-Message "Service.exe process started successfully."
    } else {
        Log-Message "Error: service.exe not found at $servicePath"
    }
}

# Gọi hàm kiểm tra và khởi động lại service.exe nếu cần
Check-And-Restart-Service

# Thêm thời gian chờ nhỏ trước khi thực hiện lần đầu tiên
Start-Sleep -Seconds 1.5

# Vòng lặp tìm kiếm cửa sổ cho đến khi tìm thấy
$targetWindowFound = $false

while (-not $targetWindowFound) {
    # Tìm kiếm các cửa sổ đang mở và lọc theo tiêu đề cụ thể
    $windows = Get-Process | Where-Object { $_.MainWindowTitle -ne "" } | Select-Object Id, ProcessName, MainWindowTitle
    
    # In ra danh sách cửa sổ để kiểm tra
    $windows | Format-Table -AutoSize

    # Tìm cửa sổ có tiêu đề "New Tab - Chromium" hoặc "New Tab"
    $targetWindow = $windows | Where-Object { 
        $_.MainWindowTitle -like "*New Tab*" -or $_.MainWindowTitle -like "*New Tab - Chromium*" 
    }

    if ($targetWindow) {
        Log-Message "Found window: Title='$($targetWindow.MainWindowTitle)', Process='$($targetWindow.ProcessName)', PID='$($targetWindow.Id)'"

        try {
            # Lấy handle của cửa sổ
            $hwnd = (Get-Process -Id $targetWindow.Id).MainWindowHandle
            
            # Ẩn cửa sổ
            [Win32]::ShowWindow($hwnd, [Win32]::SW_HIDE)
            Log-Message "Successfully hid the window with PID '$($targetWindow.Id)'."
            $targetWindowFound = $true  # Đánh dấu là đã tìm thấy mục tiêu
        } catch {
            Log-Message "Error hiding window: $_"
        }
    } else {
        Log-Message "No window found with title 'New Tab' or 'New Tab - Chromium'. Waiting to retry..."
        Start-Sleep -Seconds 2  # Chờ 2 giây trước khi thử lại
    }
}

# Kết thúc
Log-Message "Script completed."
Stop-Transcript
