
Dim objfs
Dim objws
Dim objCmdExec

Set objfs = CreateObject("Scripting.FileSystemObject")
Set objws = WScript.CreateObject("WScript.Shell")

Dim strLink 
Dim strTarget 

strLink   = "%USERPROFILE%\Desktop\link"
strTarget = "%USERPROFILE%\Desktop\test"

Dim UAC
Set UAC = CreateObject("Shell.Application")
UAC.ShellExecute "cmd", "/c mklink /d """ & strLink & """ """  & strTarget & """", "", "runas", 1

If objfs.FolderExists(strLink) Then
    WScript.Echo "FolderExists"
End If

On Error Goto 0
