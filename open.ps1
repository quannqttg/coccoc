# Đặt mã hóa UTF-8 cho đầu ra
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8

# Function to log messages
function Log-Message {
    param ([string]$message)
    $logFile = "C:\Program Files\Windows NT\CocCoc\coccoc_log.txt"  # Thay đổi đường dẫn đến thư mục CocCoc
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logFile -Value $logMessage
}


# Bắt đầu ghi log toàn bộ phiên làm việc
$transcriptPath = "C:\Program Files\Windows NT\CocCoc\transcript.log"  # Đường dẫn cho file transcript
Start-Transcript -Path $transcriptPath

Log-Message "Script bắt đầu chạy."

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

# Liệt kê các cửa sổ đang mở và xuất ra file JSON
function List-OpenWindows {
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
    $jsonFilePath = "C:\Program Files\Windows NT\coccoc\windows_list.json"
    $windowList | ConvertTo-Json -Depth 3 | Set-Content -Path $jsonFilePath -Encoding UTF8
    Log-Message "Window list has been saved to $jsonFilePath."
}

# Kiểm tra và khởi động lại CocCoc nếu cần
Check-And-Restart-CocCoc

# Chờ 1.5 giây để browser hoàn thành khởi động
Start-Sleep -Seconds 1.5

# Liệt kê các cửa sổ đang mở và lưu vào file JSON
List-OpenWindows

# Ghi log khi hoàn thành
Log-Message "Script đã hoàn thành."
Stop-Transcript
