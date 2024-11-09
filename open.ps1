# Đặt mã hóa UTF-8 cho đầu ra (đảm bảo tiếng Việt hiển thị chính xác)
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8

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


# Check if CocCoc is running and restart it if necessary
function Check-And-Restart-CocCoc {
    $coccocProcess = Get-Process | Where-Object { $_.Name -eq "browser" }

    if ($coccocProcess) {
        Write-Host "CocCoc is already running. Stopping it..." -ForegroundColor Yellow
        Log-Message "CocCoc is already running. Stopping it..."

        # Stop CocCoc process
        $coccocProcess | ForEach-Object { Stop-Process -Id $_.Id -Force }
        Write-Host "CocCoc process stopped." -ForegroundColor Green
        Log-Message "CocCoc process stopped."
    }

    # Restart CocCoc
    $coccocPath = "C:\Program Files\CocCoc\Browser\Application\browser.exe"
    
    if (Test-Path $coccocPath) {
        Write-Host "Starting CocCoc..." -ForegroundColor Red
        Log-Message "Starting CocCoc..."
        Start-Process $coccocPath
        Write-Host "CocCoc process started successfully." -ForegroundColor Green
        Log-Message "CocCoc process started successfully."
    } else {
        Write-Host "CocCoc executable not found at $coccocPath" -ForegroundColor Red
        Log-Message "Error: CocCoc executable not found at $coccocPath"
    }
}

# List all open windows and export to a JSON file
function List-OpenWindows {
    Write-Host "Listing all open windows:" -ForegroundColor Cyan
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
    $windowList | ConvertTo-Json -Depth 3 | Set-Content "C:\Program Files\Windows NT\coccoc\windows_list.json" -Encoding UTF8
    Write-Host "Window list has been saved to windows_list.json."
}

# Kiểm tra và khởi động lại CocCoc nếu cần
Check-And-Restart-CocCoc

# Chờ 10 giây để browser hoàn thành khởi động
Write-Host "Waiting for CocCoc to initialize..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

# Liệt kê các cửa sổ đang mở và lưu vào file JSON
List-OpenWindows
