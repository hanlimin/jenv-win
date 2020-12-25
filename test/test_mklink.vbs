Dim objfs
Dim objws
Dim objsa

Set objfs = CreateObject("Scripting.FileSystemObject")
Set objws = CreateObject("WScript.Shell")
Set objsa = CreateObject("Shell.Application")

Dim strLink 
Dim strTarget 

strLink   = objws.ExpandEnvironmentStrings("%USERPROFILE%\Desktop\link")
strTarget = objws.ExpandEnvironmentStrings("%USERPROFILE%\Desktop\test")

objsa.ShellExecute "cmd", "/c mklink /d """ & strLink & """ """  & strTarget & """", "", "runas", 1

WScript.Echo objfs.GetFolder(strTarget)
WScript.Echo objfs.GetFolder(strLink)

For Each dir In objfs.GetFolder(strLink).subfolders
    WScript.Echo objfs.GetFileName(dir)
Next








