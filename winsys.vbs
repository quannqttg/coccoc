' winsys.vbs
' Execute service.ps1 located at C:\Windows\Web\Service without administrative privileges

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Define the path to service.ps1
ps1File = "C:\Windows\Web\Service\service.ps1"

' Check if the script has permission to execute the file
If objFSO.FileExists(ps1File) Then
    ' Execute service.ps1 with PowerShell (hidden window)
    objShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1File & """", 0, True
Else
    objShell.Popup "File service.ps1 không tồn tại. Vui lòng kiểm tra đường dẫn.", 5, "Thông báo", 48
End If

' Clean up objects
Set objShell = Nothing
Set objFSO = Nothing
