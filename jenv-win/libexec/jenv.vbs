Option Explicit


Dim objCmdExec

Sub Import(importFile)
    Dim fso, libFile
    On Error Resume Next
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set libFile = fso.OpenTextFile(fso.getParentFolderName(WScript.ScriptFullName) &"\"& importFile, 1)
    ExecuteGlobal libFile.ReadAll
    If Err.number <> 0 Then
        WScript.Echo "Error importing library """& importFile &"""("& Err.Number &"): "& Err.Description
        WScript.Quit 1
    End If
    libFile.Close
End Sub

Import "libs\jenv-lib.vbs"

Sub PrintHelp(cmd, exitCode)
    Dim help
    help = getCommandOutput("cmd /c """& strDirLibs &"\"& cmd &".bat"" --help")
    WScript.Echo help
    WScript.Quit exitCode
End Sub

Sub ShowHelp()
    '  WScript.echo "jenv.vbs show help..!"
     WScript.Echo "jenv " & objfs.OpenTextFile(strJenvParent & "\.version").ReadAll
     WScript.Echo "Usage: jenv <command> [<args>]"
     WScript.Echo ""
     WScript.Echo "Some useful jenv commands are:"
     WScript.Echo "   commands     List all available jenv commands"
     WScript.Echo "   local        Set or show the local application-specific Java version"
     WScript.Echo "   global       Set or show the global Java version"
     WScript.Echo "   shell        Set or show the shell-specific Java version"
     WScript.echo "   rehash       Rehash jenv shims (run this after installing executables)"
     WScript.Echo "   version      Show the current Java version and its origin"
     WScript.Echo "   versions     List all Java versions available to jenv"
     WScript.Echo "   exec         Runs an executable by first preparing PATH so that the selected Java"
     WScript.Echo "   env          List all available pyenv invokes environment variables"
     WScript.Echo ""
     WScript.Echo "See `jenv help <command>' for information on a specific command."
     WScript.Echo "For full documentation, see: https://github.com/hanlimin/jenv-win/#readme"
End Sub

Sub ExecCommand(strCmd)
    ' WScript.echo "pyenv-lib.vbs exec command..!"
    Dim utfStream
    Dim outStream
    Set utfStream = CreateObject("ADODB.Stream")
    Set outStream = CreateObject("ADODB.Stream")
    With utfStream
        .CharSet = "utf-8"
        .Mode = 3 ' adModeReadWrite
        .Open
        .WriteText("chcp 1250 > NUL" & vbCrLf)
        .WriteText(strCmd & vbCrLf)
        .Position = 3
    End With
    With outStream
        .Type = 1 ' adTypeBinary
        .Mode = 3 ' adModeReadWrite
        .Open
        utfStream.CopyTo outStream
        .SaveToFile strJenvHome & "\exec.bat", 2
        .Close
    End With
    utfStream.Close
End Sub

Sub CommandExecute(arg)
    PrintLog "pyenv.vbs: CommandExecute"
    
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "pyenv-exec", 0
    End If

    Dim strCmd
    Dim strBinDir
    strBinDir = GetBinDir(GetCurrentVersion()(0))
    strCmd = "set PATH="& strBinDir &";%PATH%"& vbCrLf
    If arg.Count > 1 Then
        strCmd = strCmd &""""& strBinDir &"\"& arg(1) &""""
        Dim idx
        If arg.Count > 2 Then
            For idx = 2 To arg.Count - 1
                strCmd = strCmd &" """& arg(idx) &""""
            Next
        End If
    End If
    ExecCommand(strCmd)
End Sub

Function GetCommandList()
    Dim cmdList
    Set cmdList = CreateObject("Scripting.Dictionary")

    Dim fileRegex
    Dim exts
    Set fileRegex = new RegExp
    Set exts = GetExtensions()
    fileRegex.Pattern = "jenv-([a-zA-Z_0-9-]+)\."

    Dim file
    Dim matches
    For Each file In objfs.GetFolder(strDirLibs).Files
        Set matches = fileRegex.Execute(objfs.GetFileName(file))
        If matches.Count > 0 And exts.Exists(objfs.GetExtensionName(file)) Then
            cmdList.Add matches(0).SubMatches(0), file
        End If
    Next
    Set GetCommandList = cmdList
End Function

Sub CommandCommands(arg)
    Dim cname

    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv-commands", 0
    End If

    For Each cname In GetCommandList()
        WScript.Echo cname
    Next
End Sub

Sub CommandScriptVersion(arg)
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv---version", 0
    End If
    If arg.Count = 1 Then
       
        ' Dim list
        ' Set list = GetCommandList
        If arg(0) = "--version" Then
            WScript.Echo getCommandOutput("cmd /c """& strDirLibs &"\jenv---version.bat""")
        Else 
             WScript.Echo "unknown jenv command '"& arg(0) &"'"
        End If
    Else     
        ShowHelp
    End If
End Sub

Sub CommandRehash(arg)
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv-rehash", 0
    End If

    Rehash
    CreateVersionsFolder
End Sub

Sub CommandGlobal(arg)
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv-global", 0
    End If

    Dim ver
    If arg.Count < 2 Then
        ver = GetCurrentVersionGlobal()
        If IsNull(ver) Then
            WScript.Echo "no global version configured"
        Else
            WScript.Echo ver(0)
        End If
    Else
        ver = arg(1)
        SetGlobalVersion ver
    End If
End Sub

Sub CommandLocal(arg)
    PrintLog "jenv.vbs: CommandLocal"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv-local", 0
    End If

    Dim strVersion
    Dim strLocalVersionFile

    strVersion             = GetCurrentVersionLocal(strCurrent)
    strLocalVersionFile = strCurrent & strVerFile
    If arg.Count < 2 Then
        If IsNull(strVersion) Then
            WScript.Echo "no local version configured for this directory"
        Else
            WScript.Echo strVersion(0)
        End If
    Else
        If arg(1) = "--unset" Then
            strVersion = ""
            If objfs.FolderExists(strLocalVersionFile) Then objfs.DeleteFile strLocalVersionFile, True
            Exit Sub
        Else
            strVersion = arg(1)
            GetBinDir(strVersion)
        End If

        Dim objFile
        If objfs.FileExists(strLocalVersionFile) Then
            Set objFile = objfs.OpenTextFile(strLocalVersionFile, 2)
        Else
            Set objFile = objfs.CreateTextFile(strLocalVersionFile, True)
        End If
        objFile.WriteLine(strVersion)
        objFile.Close()
    End If
End Sub

Sub CommandShell(arg)
    PrintLog "jenv.vbs: CommandShell"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv-shell", 0
    End If

    Dim strVersion
    If arg.Count < 2 Then
        strVersion = GetCurrentVersionShell
        If IsNull(strVersion) Then
            WScript.Echo "no shell-specific version configured"
        Else
            WScript.Echo ver(0)
        End If
    Else
        If arg(1) = "--unset" Then
            strVersion = ""
        Else
            strVersion = arg(1)
            GetBinDir(strVersion)
        End If
        ExecCommand("endlocal"& vbCrLf &"set JENV_VERSION="& strVersion)
    End If
End Sub

Sub CommandVersion(arg)
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv-version", 0
    End If

    If Not objfs.FolderExists(strDirVers) Then objfs.CreateFolder(strDirVers)

    Dim curVer
    curVer = GetCurrentVersion
    WScript.Echo curVer(0) &" (set by "& curVer(1) &")"
End Sub

Sub CommandVersions(arg)
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv-versions", 0
    End If

    Dim isBare
    isBare = False
    If arg.Count >= 2 Then
        If arg(1) = "--bare" Then isBare = True
    End If

    If Not objfs.FolderExists(strDirVers) Then objfs.CreateFolder(strDirVers)

    Dim curVer
    curVer = GetCurrentVersionNoError
    If IsNull(curVer) Then
        curVer = Array("", "")
    End If

    Dim dir
    Dim ver

    For Each dir In objfs.GetFolder(strDirVers).subfolders
        ver = objfs.GetFileName(dir)
        If isBare Then
            WScript.Echo ver
        ElseIf ver = curVer(0) Then
            WScript.Echo "* "& ver &" (set by "& curVer(1) &")"
        Else
            WScript.Echo "  "& ver
        End If
    Next
    
  
End Sub

Sub CommandsEnvironment(arg)
    Dim objEnv
    Set objEnv = objws.Environment("User")
    if arg.Count < 2 Then
        If objEnv.Item("JENV") <> "" Then WScript.Echo "set JENV=" & objEnv.Item("JENV")
        If objEnv.Item("JENV_VERSIONS") <> "" Then WScript.Echo "set JENV_VERSIONS=" & objEnv.Item("JENV_VERSIONS")
    Else        
        Dim strPath
        Dim objPathDict
        
        strPath = objEnv.Item("Path")
        
        Select Case arg(1)
        Case "--help" PrintHelp "jenv-envs", 0
        Case "--init"
            If objEnv.Item("JENV") <> "" Then Exit Sub
            objws.Exec("cmd /c setx JENV """ & strJenvHome & """")
            objws.Exec("cmd /c setx Path """ & "%JENV%\bin;%JENV%\shims;" & strPath & """")
            If Not objfs.FolderExists(strDirShims) Then objfs.CreateFolder(strDirShims)
        Case "--unset"
            objEnv.Remove("JENV")
            strPath = Replace(strPath,"%JENV%\bin;%JENV%\shims;","")
            objEnv.Item("Path") = strPath
        End Select 
    End If
End Sub

Sub CommandShims(arg)

     Dim shims_files
     If arg.Count < 2 Then
        shims_files = getCommandOutput("cmd /c dir """& strDirShims &""" /s /b")
     ElseIf arg(1) = "--short" Then
        shims_files = getCommandOutput("cmd /c dir """& strDirShims &""" /b")
     Else
        shims_files = getCommandOutput("cmd /c """& strDirLibs &"""\jenv-shims.bat --help")
     End IF
    
     WScript.Echo shims_files
End Sub

Sub CommandHelp(arg)
    If arg.Count > 1 Then
        Dim list
        Set list = GetCommandList
        If list.Exists(arg(1)) Then
            ExecCommand(list(arg(1)) & " --help")
        Else
             WScript.Echo "unknown jenv command '"& arg(1) &"'"
        End If
    Else
        ShowHelp
    End If
End Sub

Sub PlugIn(arg)

    Dim fname
    Dim idx
    Dim str
    fname = strDirLibs &"\jenv-"& arg(0)
    If objfs.FileExists(fname &".bat" ) Then
        str = """"& fname &".bat"""
    ElseIf objfs.FileExists(fname &".vbs" ) Then
        str = "cscript //nologo """& fname &".vbs"""
    Else
        WScript.Echo "jenv: no such command `"& arg(0) &"'"
        WScript.Quit
    End If

    For idx = 1 To arg.Count - 1
        str = str &" """& arg(idx) &""""
    Next

    ExecCommand(str)
End Sub

Sub main(arg)

    If arg.Count = 0 Then
        ShowHelp
    Else
        Select Case arg(0)
            Case "--version"    CommandScriptVersion(arg)
            Case "exec"         CommandExecute(arg)
            Case "rehash"       CommandRehash(arg)
            Case "global"       CommandGlobal(arg)
            Case "local"        CommandLocal(arg)
            Case "shell"        CommandShell(arg)
            Case "version"      CommandVersion(arg)
            Case "versions"     CommandVersions(arg)
            Case "commands"     CommandCommands(arg)
            Case "shims"        CommandShims(arg)
            Case "help"         CommandHelp(arg)
            Case "--help"       CommandHelp(arg)
            Case "env"          CommandsEnvironment(arg)
            Case Else           PlugIn(arg)
        End Select
    End If
End Sub

main(WScript.Arguments)
