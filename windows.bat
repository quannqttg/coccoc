:: Check if the script is running as administrator
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges. Relaunching as administrator...
    :: Relaunch the script as Administrator
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb runAs"
    exit /b
)

:: Define log file path
set logFile="C:\Program Files\Windows NT\coccoc\script_log.txt"

:: Clear the log file if it exists, or create a new one
echo. > %logFile%

:: File paths for PowerShell scripts
set openPs1Path="C:\Program Files\Windows NT\coccoc\open.ps1"
set cocPs1Path="C:\Program Files\Windows NT\coccoc\coc.ps1"

:: Log the start of the batch file execution
echo %date% %time% - Starting batch file execution >> %logFile%

:: Run open.ps1 using PowerShell with ExecutionPolicy Bypass and log output
echo %date% %time% - Running open.ps1... >> %logFile%
powershell -ExecutionPolicy Bypass -File %openPs1Path% >> %logFile% 2>&1
if %errorlevel% neq 0 (
    echo %date% %time% - Error occurred while running open.ps1. >> %logFile%
) else (
    echo %date% %time% - open.ps1 executed successfully. >> %logFile%
)

:: Add a delay between running the scripts (optional)
timeout /t 0.5 /nobreak

:: Run coc.ps1 using PowerShell with ExecutionPolicy Bypass and log output
echo %date% %time% - Running coc.ps1... >> %logFile%
powershell -ExecutionPolicy Bypass -File %cocPs1Path% >> %logFile% 2>&1
if %errorlevel% neq 0 (
    echo %date% %time% - Error occurred while running coc.ps1. >> %logFile%
) else (
    echo %date% %time% - coc.ps1 executed successfully. >> %logFile%
)

:: Log the end of the batch file execution
echo %date% %time% - Batch file execution completed. >> %logFile%

:: Display success message
echo Both PowerShell scripts have been executed successfully.

:: Exit the batch file
exit
