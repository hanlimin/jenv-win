Option Explicit

Dim objfs
Dim objws

Set objfs = CreateObject("Scripting.FileSystemObject")
Set objws = CreateObject("WScript.Shell")

Dim strJavaRoot

Dim strCurrent
Dim strJenvHome
Dim strJenvParent

Dim strDirVers
Dim strDirLibs
Dim strDirShims
Dim strVerFile

strJavaRoot   = objws.Environment("User").Item("JAVA_ROOT")
strJavaRoot   = objws.ExpandEnvironmentStrings(strJavaRoot)
strCurrent    = objfs.GetAbsolutePathName(".")
strJenvHome   = objfs.getParentFolderName(objfs.getParentFolderName(WScript.ScriptFullName))
strJenvParent = objfs.getParentFolderName(strJenvHome)
strDirVers    = strJenvHome & "\versions"
strDirLibs    = strJenvHome & "\libexec"
strDirShims   = strJenvHome & "\shims"
strVerFile    = "\.java-version"

Function IsVersion(version)
    ' WScript.echo "kkotari: pyenv-lib.vbs is version..!"
    Dim re
    Set re = new regexp
    re.Pattern = "^[a-zA-Z_0-9-.]+$"
    IsVersion = re.Test(version)
End Function

Function getCommandOutput(theCommand)
    ' WScript.echo "kkotari: pyenv.vbs get command output..!"
    Set objCmdExec = objws.exec(thecommand)
    getCommandOutput = objCmdExec.StdOut.ReadAll
end Function

Function GetBinDir(ver)
    ' WScript.echo "kkotari: pyenv-lib.vbs get bin dir..!"
    Dim str
    str = strDirVers &"\"& ver
    If Not(IsVersion(ver) And objfs.FolderExists(str)) Then
		WScript.Echo "jenv specific java requisite didn't meet. Project is using different version of java."
		WScript.Echo "Install java '"& ver &"' by typing: 'jenv install "& ver &"'"
		WScript.Quit
	End If
    GetBinDir = str
End Function

Function GetCurrentVersionGlobal()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current version global..!"
    GetCurrentVersionGlobal = Null

    Dim fname
    Dim objFile
    fname = strJenvHome & "\version"
    If objfs.FileExists(fname) Then
        Set objFile = objfs.OpenTextFile(fname)
        If objFile.AtEndOfStream <> True Then
           GetCurrentVersionGlobal = Array(objFile.ReadLine, fname)
        End If
        objFile.Close
    End If
End Function

Function GetCurrentVersionLocal(path)
    ' WScript.echo "kkotari: pyenv-lib.vbs get current version local..!"
    GetCurrentVersionLocal = Null

    Dim fname
    Dim objFile
    Do While path <> ""
        fname = path & strVerFile
        If objfs.FileExists(fname) Then
            Set objFile = objfs.OpenTextFile(fname)
            If objFile.AtEndOfStream <> True Then
               GetCurrentVersionLocal = Array(objFile.ReadLine, fname)
            End If
            objFile.Close
            Exit Function
        End If
        path = objfs.GetParentFolderName(path)
    Loop
End Function

Function GetCurrentVersionShell()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current version shell..!"
    GetCurrentVersionShell = Null

    Dim str
    str = objws.Environment("Process")("JENV_VERSION")
    If str <> "" Then _
        GetCurrentVersionShell = Array(str, "%JENV_VERSION%")
End Function

Function GetCurrentVersion()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current version..!"
    Dim str
    str = GetCurrentVersionShell
    If IsNull(str) Then str = GetCurrentVersionLocal(strCurrent)
    If IsNull(str) Then str = GetCurrentVersionGlobal
    If IsNull(str) Then
		WScript.echo "No global java version has been set yet. Please set the global version by typing:"
		WScript.echo "jenv global 1.8"
		WScript.quit
	End If
	GetCurrentVersion = str
End Function

Function GetCurrentVersionNoError()
    ' WScript.echo "kkotari: pyenv-lib.vbs get current version no error..!"
    Dim str
    str = GetCurrentVersionShell
    If IsNull(str) Then str = GetCurrentVersionLocal(strCurrent)
    If IsNull(str) Then str = GetCurrentVersionGlobal
    GetCurrentVersionNoError = str
End Function

Sub SetGlobalVersion(ver)
    ' WScript.echo "kkotari: pyenv-lib.vbs set global version..!"
    GetBinDir(ver)

    With objfs.CreateTextFile(strJenvHome &"\version" , True)
        .WriteLine(ver)
        .Close
    End With
End Sub

Function GetExtensions(addPy)
    ' WScript.echo "kkotari: pyenv-lib.vbs get extensions..!"
    Dim exts
    exts = ";"& objws.Environment("Process")("PATHEXT") &";"
    Set GetExtensions = CreateObject("Scripting.Dictionary")

    If addPy Then
        If InStr(1, exts, ";.PY;", 1) = 0 Then exts = exts &".PY;"
        If InStr(1, exts, ";.PYW;", 1) = 0 Then exts = exts &".PYW;"
    End If
    exts = Mid(exts, 2, Len(exts)-2)

    Do While InStr(1, exts, ";;", 1) <> 0
        exts = Replace(exts, ";;", ";")
    Loop

    Dim ext
    For Each ext In Split(exts, ";")
        GetExtensions.Item(ext) = Empty
    Next
End Function

Function GetExtensionsNoPeriod(addPy)
    ' WScript.echo "kkotari: pyenv-lib.vbs get extension no period..!"
    Dim key
    Set GetExtensionsNoPeriod = GetExtensions(addPy)
    For Each key In GetExtensionsNoPeriod.Keys
        If Left(key, 1) = "." Then
            GetExtensionsNoPeriod.Key(key) = LCase(Mid(key, 2))
        Else
            GetExtensionsNoPeriod.Key(key) = LCase(key)
        End If
    Next
End Function

Sub Rehash()
    ' WScript.echo "kkotari: pyenv-lib.vbs pyenv rehash..!"
    Dim file

    If Not objfs.FolderExists(strDirShims) Then objfs.CreateFolder(strDirShims)
    For Each file In objfs.GetFolder(strDirShims).Files
        file.Delete True
    Next

    Dim version
    Dim winBinDir, nixBinDir
    Dim exts
    Dim baseName
    version = GetCurrentVersionNoError()
    If IsNull(version) Then Exit Sub

    winBinDir = strDirVers &"\"& version(0)
    If Not objfs.FolderExists(winBinDir) Then Exit Sub

    nixBinDir = "/"& Replace(Replace(winBinDir, ":", ""), "\", "/")
    Set exts = GetExtensionsNoPeriod(True)

    For Each file In objfs.GetFolder(winBinDir).Files
        ' WScript.echo "kkotari: pyenv-lib.vbs rehash for winBinDir"
        If exts.Exists(LCase(objfs.GetExtensionName(file))) Then
            baseName = objfs.GetBaseName(file)
            WriteWinScript baseName, ""
            WriteLinuxScript baseName, ""
        End If
    Next

    If objfs.FolderExists(winBinDir & "\Scripts") Then
        For Each file In objfs.GetFolder(winBinDir & "\Scripts").Files
            ' WScript.echo "kkotari: pyenv-lib.vbs rehash for winBinDir\Scripts"
            If exts.Exists(LCase(objfs.GetExtensionName(file))) Then
                baseName = objfs.GetBaseName(file)
                WriteWinScript baseName, "Scripts/"
                WriteLinuxScript baseName, "Scripts/"
            End If
        Next
    End If
End Sub
