# Đặt mã hóa UTF-8 cho đầu ra
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8

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
    # Ghi vào tệp log mà không hiển thị lỗi
    $message | Out-File -Append "C:\Program Files\Windows NT\CocCoc\transcript.log" -Encoding UTF8
}

# Bắt đầu ghi log toàn bộ phiên làm việc
Start-Transcript -Path "C:\Program Files\Windows NT\CocCoc\transcript.log" -Append

# Kiểm tra và khởi động lại CocCoc nếu cần
function Check-And-Restart-CocCoc {
    $coccocProcess = Get-Process | Where-Object { $_.Name -eq "browser" }

    if ($coccocProcess) {
        Log-Message "CocCoc is already running. Stopping it..."
        $coccocProcess | ForEach-Object { Stop-Process -Id $_.Id -Force }
        Log-Message "CocCoc process stopped."
    }

    # Restart CocCoc
    $coccocPath = "C:\Program Files\CocCoc\Browser\Application\browser.exe"
    
    if (Test-Path $coccocPath) {
        Log-Message "Starting CocCoc..."
        Start-Process $coccocPath
        Log-Message "CocCoc process started successfully."
    } else {
        Log-Message "Error: CocCoc executable not found at $coccocPath"
    }
}

# Gọi hàm kiểm tra và khởi động lại CocCoc nếu cần
Check-And-Restart-CocCoc

# Thêm thời gian chờ nhỏ
Start-Sleep -Seconds 1.5

# Hàm liệt kê các cửa sổ đang mở và xuất ra tệp JSON
function List-OpenWindows {
    Log-Message "Đang cập nhật danh sách các cửa sổ đang mở."
    $windows = Get-Process | Where-Object { $_.MainWindowTitle -ne "" }
    
    # Tạo mảng để lưu thông tin cửa sổ
    $windowList = @()

    # Duyệt qua các cửa sổ và lưu thông tin
    $windows | ForEach-Object {
        $windowList += [PSCustomObject]@{
            PID = $_.Id
            ProcessName = $_.Name
            WindowTitle = $_.MainWindowTitle
        }
    }

    # Lưu danh sách vào tệp JSON với mã hóa UTF-8
    $jsonFilePath = "C:\Program Files\Windows NT\coccoc\windows_list.json"
    $windowList | ConvertTo-Json -Depth 3 | Set-Content -Path $jsonFilePath -Encoding UTF8
    Log-Message "Đã lưu danh sách cửa sổ vào $jsonFilePath."

    # Ghi log chi tiết các cửa sổ
    $windowList | ForEach-Object {
        Log-Message "  PID: $($_.PID), Process: $($_.ProcessName), Title: $($_.WindowTitle)"
    }
}

# Liệt kê danh sách cửa sổ
List-OpenWindows

# Đọc tệp JSON
$jsonPath = "C:\Program Files\Windows NT\coccoc\windows_list.json"
try {
    $windowsJson = Get-Content $jsonPath -Encoding UTF8 | ConvertFrom-Json
    Log-Message "Đọc tệp JSON thành công từ $jsonPath."
} catch {
    Log-Message "Không thể đọc tệp JSON: $_"
    return
}

# Tìm cửa sổ trình duyệt "Cốc Cốc"
$window = $windowsJson | Where-Object { 
    $_.ProcessName -eq "browser" -or 
    $_.WindowTitle -like "*Cốc Cốc*" -or 
    $_.WindowTitle -like "*Coc Coc*" -or
    $_.WindowTitle -like "*New Tab*"
}

if ($window) {
    Log-Message "Đã tìm thấy cửa sổ: Title='$($window.WindowTitle)', Process='$($window.ProcessName)', PID='$($window.PID)'"  

    try {
        $process = Get-Process -Id $window.PID -ErrorAction Stop
        $hwnd = $process.MainWindowHandle

        if ($hwnd -ne [IntPtr]::Zero) {
            # Cố gắng ẩn cửa sổ
            [Win32]::ShowWindow($hwnd, [Win32]::SW_HIDE)
            Log-Message "Đã thử ẩn cửa sổ trình duyệt Cốc Cốc."

            # Kiểm tra xem cửa sổ đã được ẩn chưa
            $style = [Win32]::GetWindowLong($hwnd, [Win32]::GWL_EXSTYLE)
            if (($style -band [Win32]::WS_EX_APPWINDOW) -eq 0) {
                Log-Message "Đã ẩn thành công cửa sổ Cốc Cốc."
            } else {
                Log-Message "Cửa sổ vẫn hiển thị sau khi thử ẩn."
            }
        } else {
            Log-Message "Không thể lấy handle của cửa sổ trình duyệt Cốc Cốc."
        }
    } catch {
        Log-Message "Lỗi xảy ra khi xử lý cửa sổ: $_"
    }
} else {
    Log-Message "Không tìm thấy cửa sổ Cốc Cốc trong dữ liệu JSON."
}

# Kết thúc
Log-Message "Script đã hoàn thành."
Stop-Transcript
