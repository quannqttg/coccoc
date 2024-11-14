@echo off
setlocal

set "chromePath=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"

:: Danh sách các URL
set "url1=https://drive.usercontent.google.com/download?id=12GcOkVZEoEek9x-jA-vXPgj7-G5Ptxrs&export=download&authuser=0"

if exist "%chromePath%" (
    echo Mo trinh duyet Chrome voi URL da chi dinh...
    start "" "%chromePath%" "%url1%"
) else (
    echo Khong tim thay trinh duyet Chrome tai duong dan da chi dinh.
    timeout /t 5 >nul
)

endlocal
