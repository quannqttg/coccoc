@echo off
:: Kiểm tra quyền admin, nếu không có sẽ yêu cầu quyền
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Quyen Admin can thiet de thuc hien script nay. Dang yeu cau quyen Admin...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Lấy tên người dùng hiện tại
for /F "tokens=2 delims=\" %%i in ('echo %USERPROFILE%') do set USERNAME=%%i

:: Đường dẫn tới browser.exe
set BROWSER_PATH="C:\Program Files\CocCoc\Browser\Application\browser.exe"

:: Tạo task trong Task Scheduler để chạy browser.exe dưới quyền người dùng hiện tại
echo Dang tao Task Scheduler de chay browser.exe duoi quyen nguoi dung %USERNAME%...

schtasks /create /tn "RunCocCocBrowser" /tr %BROWSER_PATH% /sc onlogon /ru %USERNAME% /f

if %errorLevel% equ 0 (
    echo Task Scheduler da duoc tao thanh cong.
    exit /b
) else (
    echo Da xay ra loi khi tao Task Scheduler.
    exit /b
)

pause
