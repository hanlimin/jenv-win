Option Explicit

Const FILE_ATTRIBUTE_REPARSE_POINT = &H0400

Dim objfs
Dim objws

Set objfs = CreateObject("Scripting.FileSystemObject")
Set objws = CreateObject("WScript.Shell")

Dim strJenvDebug
Dim strJenvShell
Dim strJenvVersions

strJenvDebug    = objws.Environment("User").Item("JENV_DEBUG")
strJenvShell    = objws.Environment("Process").Item("JENV_SHELL")
strJenvVersions = objws.Environment("User").Item("JENV_VERSIONS")

Dim strCurrent
Dim strJenvHome
Dim strJenvParent

Dim strDirVers
Dim strOriginDirVers
Dim strDirLibs
Dim strDirShims
Dim strVerFile

strCurrent       = objfs.GetAbsolutePathName(".")
strJenvHome      = objfs.getParentFolderName(objfs.getParentFolderName(WScript.ScriptFullName))
strJenvParent    = objfs.getParentFolderName(strJenvHome)
strDirVers       = strJenvHome & "\versions"
strOriginDirVers = strJenvHome & "\origin-versions"
strDirLibs       = strJenvHome & "\libexec"
strDirShims      = strJenvHome & "\shims"
strVerFile       = "\.java-version"

Dim objCmdExec

Sub PrintLog(log)
    If Not IsEmpty(strJenvDebug) Then 
        WScript.Echo log
    End If
End Sub

Function IsCmd()
    If strJenvShell = "cmd" Then
        IsCmd = True
    Else
        IsCmd = False
    End If
End Function

Function IsVersion(version)
    Dim re
    Set re = new regexp
    re.Pattern = "^[a-zA-Z_0-9-.]+$"
    IsVersion = re.Test(version)
End Function

Function getCommandOutput(theCommand)
    Set objCmdExec = objws.exec(thecommand)
    getCommandOutput = objCmdExec.StdOut.ReadAll
end Function

Function GetBinDir(version)
    Dim strBinDir
    strBinDir = strDirVers &"\"& version & "\bin"
    If Not(IsVersion(version) And objfs.FolderExists(strBinDir)) Then
        WScript.Echo "jenv specific java requisite didn't meet. Project is using different version of java."
        WScript.Echo "Install java '"& version &"' by typing: 'jenv install "& version &"'"
    WScript.Quit
    End If
    GetBinDir = strBinDir
End Function

Sub ScriptExecute(strCmd)
    PrintLog "pyenv.vbs: ScriptExecute"
    Dim utfStream
    Dim outStream
    Set utfStream = CreateObject("ADODB.Stream")
    Set outStream = CreateObject("ADODB.Stream")
    With utfStream
        .CharSet = "utf-8"
        .Mode = 3 ' adModeReadWrite
        .Open
        .WriteText(strCmd & vbCrLf)
        .Position = 3
    End With
    With outStream
        .Type = 1 ' adTypeBinary
        .Mode = 3 ' adModeReadWrite
        .Open
        utfStream.CopyTo outStream
        If IsCmd() Then
            .SaveToFile strJenvHome & "\exec.bat", 2
        Else
            .SaveToFile strJenvHome & "\exec.ps1", 2
        End If
        
        .Close
    End With
    utfStream.Close
End Sub

Function GetCurrentVersionGlobal()
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
    GetCurrentVersionLocal = Null

    Dim strVersionFile
    Dim objFile
    Do While path <> ""
        strVersionFile = path & strVerFile
        If objfs.FileExists(strVersionFile) Then
            Set objFile = objfs.OpenTextFile(strVersionFile)
            If objFile.AtEndOfStream <> True Then
               GetCurrentVersionLocal = Array(objFile.ReadLine, strVersionFile)
            End If
            objFile.Close
            Exit Function
        End If
        path = objfs.GetParentFolderName(path)
    Loop
End Function

Function GetCurrentVersionShell()
    GetCurrentVersionShell = Null

    Dim str
    str = objws.Environment("Process")("JENV_VERSION")
    If str <> "" Then _
        GetCurrentVersionShell = Array(str, "%JENV_VERSION%")
End Function

Function GetCurrentVersion()
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
    PrintLog "jenv-lib.vbs: GetCurrentVersionNoError"
    Dim str
    str = GetCurrentVersionShell
    If IsNull(str) Then str = GetCurrentVersionLocal(strCurrent)
    If IsNull(str) Then str = GetCurrentVersionGlobal
    GetCurrentVersionNoError = str
End Function

Sub SetGlobalVersion(ver)
    GetBinDir(ver)

    With objfs.CreateTextFile(strJenvHome &"\version" , True)
        .WriteLine(ver)
        .Close
    End With
End Sub

Sub WriteScript(baseName)
    With objfs.CreateTextFile(strDirShims &"\"& baseName &".bat")
        .WriteLine("@echo off")
        .WriteLine("setlocal")
        .WriteLine("jenv exec " & baseName & " %*")
        .Close
    End With
End Sub

Function GetExtensions()
    Dim exts
    exts = ";"& objws.Environment("Process")("PATHEXT") &";"
    Set GetExtensions = CreateObject("Scripting.Dictionary")

    Dim ext
    For Each ext In Split(exts, ";")
        If Left(ext, 1) = "." Then
            GetExtensions.Item(LCase(Mid(ext, 2))) = Empty
        Else
            GetExtensions.Item(LCase(ext)) = Empty
        End If
    Next
End Function



Sub Rehash()
    PrintLog "jenv-lib.vbs: Rehash"
    
    Dim file

    If Not objfs.FolderExists(strDirShims) Then objfs.CreateFolder(strDirShims)
    For Each file In objfs.GetFolder(strDirShims).Files
        file.Delete True
    Next

    Dim strVersion
    Dim strBinDir
    Dim dictExts
    Dim strBaseName
    ' test files exist
    strVersion = GetCurrentVersionNoError()
    If IsNull(strVersion) Then
        WScript.Echo "Please set the global Java version at least"
        Exit Sub
    End If
    strBinDir = GetBinDir(strVersion(0))


    If objfs.FolderExists(strBinDir) Then
        Set dictExts = GetExtensions()
        For Each file In objfs.GetFolder(strBinDir).Files
            If dictExts.Exists(LCase(objfs.GetExtensionName(file))) Then
                strBaseName = objfs.GetBaseName(file)
                WriteScript strBaseName
            End If
        Next
    End If
End Sub

Sub CreateVersionsFolder()
    PrintLog "jenv-lib.vbs: CreateVersionsFolder"

    Dim objsa
    Dim objVersFolder
    Dim strLinkTarget
    Dim boolDirVersExists

    If objfs.FolderExists(strDirVers) Then
        set objVersFolder = objfs.GetFolder(strDirVers)
        ' get symbolic link target
        If objVersFolder.Attributes And FILE_ATTRIBUTE_REPARSE_POINT Then
            Set objCmdExec = objws.exec("cmd /c dir """& strJenvHome & """ /AL")
            Dim objRegexpTartget
            Dim objMatches
            Set objRegexpTartget = new regexp
            objRegexpTartget.Pattern = "<SYMLINKD>.*versions.*\[(.*)]"
            Set objMatches = objRegexpTartget.Execute(objCmdExec.StdOut.ReadAll)
            If objMatches.Count > 0 Then strLinkTarget = objMatches(0).SubMatches(0)
        End If
    End If
    ' %JENV_VERSIONS% no change
    If strLinkTarget = strJenvVersions Then Exit Sub
    '%JENV_VERSIONS% changed
    If strJenvVersions <> "" Then
        If objfs.FolderExists(strJenvVersions) Then
            ' versions exists and it is normal folder
            If IsEmpty(strLinkTarget) And Not IsEmpty(objVersFolder) Then
                objfs.MoveFolder strDirVers, strOriginDirVers
            Else
                objws.Exec("cmd /c rmdir """ & objVersFolder & """")
            End If
            If strJenvVersions <> strLinkTarget Then
                Set objsa = CreateObject("Shell.Application")
                objsa.ShellExecute "cmd", " /c mklink /d """ & strDirVers & """ """ & strJenvVersions & """", "", "runas", 1
            End If
            Exit Sub
        End If
    End If
    
    If IsEmpty(objVersFolder) Then
        objfs.CreateFolder(objVersFolder)
    Else
        If Not IsEmpty(strLinkTarget) Then
            objws.Exec("cmd /c rmdir """ & objVersFolder & """")
            Do While objfs.FolderExists(objVersFolder)
                
            Loop
            If objfs.FolderExists(strOriginDirVers) Then
                objfs.MoveFolder strOriginDirVers, strDirVers
            Else
                objfs.CreateFolder(strDirVers)
            End If
        End If
    End If
End Sub
