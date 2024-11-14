@echo off
set "chromePath=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"

:: Danh sách các URL
set "url1=https://drive.usercontent.google.com/download?id=19y142bMxYDcv7whyt5XrGkchM38dwRKW&export=download&authuser=0"


if exist "%chromePath%" (
    start "" "%chromePath%" "%url1%"
) else (
    echo Khong tim thay trinh d
