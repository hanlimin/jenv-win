Dim objfs
Dim objws

Dim strJenvHome

Dim objCmdExec



Set objfs       = CreateObject("Scripting.FileSystemObject")
Set objws       = WScript.CreateObject("WScript.Shell")
strJenvHome     = objfs.getParentFolderName(objfs.getParentFolderName(WScript.ScriptFullName)) & "\jenv-win"
' objws.Environment("User").Item("JENV_ROOT")="%ProgramFiles%\Java"

set objCmdExec = objws.exec(strJenvHome & "\bin\jenv.bat versions")

WScript.Echo objCmdExec.StdOut.ReadAll

' objws.Environment("User").Remove("JENV_ROOT")
