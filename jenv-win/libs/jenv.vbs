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

Import "jenv-lib.vbs"


Sub ExecCommand(str)
    ' WScript.echo "kkotari: pyenv.vbs exec command..!"
    Dim utfStream
    Dim outStream
    Set utfStream = CreateObject("ADODB.Stream")
    Set outStream = CreateObject("ADODB.Stream")
    With utfStream
        .CharSet = "utf-8"
        .Mode = 3 ' adModeReadWrite
        .Open
        .WriteText("chcp 1250 > NUL" & vbCrLf)
        .WriteText(str & vbCrLf)
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
    ' WScript.echo "kkotari: pyenv.vbs command exec..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv-exec", 0
    End If

    Dim str
    Dim dstr
    dstr = GetBinDir(GetCurrentVersion()(0))
    str = "set PATH="& dstr &";%PATH:&=^&%"& vbCrLf
    If arg.Count > 1 Then
        str = str &""""& dstr &"\"& arg(1) &""""
        Dim idx
        If arg.Count > 2 Then
            For idx = 2 To arg.Count - 1
                str = str &" """& arg(idx) &""""
            Next
        End If
    End If
    ExecCommand(str)
End Sub

Sub PrintHelp(cmd, exitCode)
    ' WScript.echo "kkotari: pyenv.vbs print help..!"
    Dim help
    help = getCommandOutput("cmd /c "& strDirLibs &"\"& cmd &".bat --help")
    WScript.Echo help
    WScript.Quit exitCode
End Sub

Sub ShowHelp()
     WScript.echo "jenv.vbs show help..!"
     WScript.Echo "jenv " & objfs.OpenTextFile(strJenvParent & "\.version").ReadAll
     WScript.Echo "Usage: jenv <command> [<args>]"
     WScript.Echo ""
     WScript.Echo "Some useful jenv commands are:"
     WScript.Echo "   commands     List all available jenv commands"
     WScript.Echo "   local        Set or show the local application-specific Python version"
     WScript.Echo "   global       Set or show the global Python version"
     WScript.Echo "   shell        Set or show the shell-specific Python version"
     WScript.echo "   rehash       Rehash jenv shims (run this after installing executables)"
     WScript.Echo "   version      Show the current Python version and its origin"
     WScript.Echo "   versions     List all Python versions available to jenv"
     WScript.Echo "   which        Display the full path to an executable"
     WScript.Echo ""
     WScript.Echo "See `jenv help <command>' for information on a specific command."
     WScript.Echo "For full documentation, see: https://github.com/jenv-win/#readme"
End Sub

Sub CommandScriptVersion(arg)
    ' WScript.echo "kkotari: pyenv.vbs command script version..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv---version", 0
    End If

    If arg.Count = 1 Then
        Dim list
        Set list = GetCommandList
        If list.Exists(arg(0)) Then
            PrintVersion "jenv---version", 0
        Else
             WScript.Echo "unknown jenv command '"& arg(0) &"'"
        End If
    Else
        ShowHelp
    End If
End Sub

Sub CommandRehash(arg)
    ' WScript.echo "kkotari: pyenv.vbs command rehash..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv-rehash", 0
    End If

    Rehash
End Sub

Sub CommandGlobal(arg)
    ' WScript.echo "kkotari: pyenv.vbs command global..!"
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
        ver = Check32Bit(arg(1))
        SetGlobalVersion ver
    End If
End Sub

Sub CommandLocal(arg)
    ' WScript.echo "kkotari: pyenv.vbs command local..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv-local", 0
    End If

    Dim ver
    If arg.Count < 2 Then
        ver = GetCurrentVersionLocal(strCurrent)
        If IsNull(ver) Then
            WScript.Echo "no local version configured for this directory"
        Else
            WScript.Echo ver(0)
        End If
    Else
        If arg(1) = "--unset" Then
            ver = ""
            objfs.DeleteFile strCurrent & strVerFile, True
            Exit Sub
        Else
            ver = Check32Bit(arg(1))
            GetBinDir(ver)
        End If

        Dim ofile
        If objfs.FileExists(strCurrent & strVerFile) Then
            Set ofile = objfs.OpenTextFile(strCurrent & strVerFile, 2)
        Else
            Set ofile = objfs.CreateTextFile(strCurrent & strVerFile, True)
        End If
        ofile.WriteLine(ver)
        ofile.Close()
    End If
End Sub

Sub CommandShell(arg)
    ' WScript.echo "kkotari: pyenv.vbs command shell..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv-shell", 0
    End If

    Dim ver
    If arg.Count < 2 Then
        ver = GetCurrentVersionShell
        If IsNull(ver) Then
            WScript.Echo "no shell-specific version configured"
        Else
            WScript.Echo ver(0)
        End If
    Else
        If arg(1) = "--unset" Then
            ver = ""
        Else
            ver = Check32Bit(arg(1))
            GetBinDir(ver)
        End If
        ExecCommand("endlocal"& vbCrLf &"set JENV_VERSION="& ver)
    End If
End Sub

Sub CommandVersion(arg)
    ' WScript.echo "kkotari: pyenv.vbs command version..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv-version", 0
    End If

    If Not objfs.FolderExists(strDirVers) Then objfs.CreateFolder(strDirVers)

    Dim curVer
    curVer = GetCurrentVersion
    WScript.Echo curVer(0) &" (set by "& curVer(1) &")"
End Sub

Sub CommandVersionName(arg)
    ' WScript.echo "kkotari: pyenv.vbs command version-name..!"
    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv-vname", 0
    End If

    If Not objfs.FolderExists(strDirVers) Then objfs.CreateFolder(strDirVers)

    WScript.Echo GetCurrentVersion()(0)
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

    If Not objfs.FolderExists(strDirVers) Then
        If strJavaRoot = "" Then
            objfs.CreateFolder(strDirVers)
        Else
            Dim objCmdExec
            Dim strCmd
            strCmd="cmd /c mklink /d """ & strDirVers & """ """  & strJavaRoot & """"
            Set objCmdExec = objws.exec(strCmd)
            Select Case objCmdExec.Status
                case 0 
                    Dim errMsg 
                    Dim re
                    errMsg = objCmdExec.StdErr.ReadAll
                    Set re = new regexp
                    re.Pattern = "You do not have sufficient privilege to perform this operation"
                    if re.Test(errMsg) Then
                        Dim objsa
                        Set objsa = CreateObject("Shell.Application")
                        objsa.ShellExecute "cmd", "/c mklink /d """ & strDirVers & """ """  & strJavaRoot & """", "", "runas", 1
                    Else
                        WScript.Echo errMsg
                    End If
                case 1
                    WScript.Echo objCmdExec.StdOut.ReadAll
            End Select
        End If
    End If


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

Sub CommandCommands(arg)
    ' WScript.echo "kkotari: pyenv.vbs command commands..!"
    Dim cname

    If arg.Count >= 2 Then
        If arg(1) = "--help" Then PrintHelp "jenv-commands", 0
    End If

    For Each cname In GetCommandList()
        WScript.Echo cname
    Next
End Sub

Sub CommandShims(arg)
    ' WScript.echo "kkotari: pyenv.vbs command shims..!"
     Dim shims_files
     If arg.Count < 2 Then
     ' WScript.Echo join(arg.ToArray(), ", ")
     ' if --short passed then remove /s from cmd
        shims_files = getCommandOutput("cmd /c dir "& strDirShims &"/s /b")
     ElseIf arg(1) = "--short" Then
        shims_files = getCommandOutput("cmd /c dir "& strDirShims &" /b")
     Else
        shims_files = getCommandOutput("cmd /c "& strDirLibs &"\jenv-shims.bat --help")
     End IF
     WScript.Echo shims_files
End Sub

Sub CommandWhich(arg)
    ' WScript.echo "kkotari: pyenv.vbs command which..!"
    If arg.Count < 2 Then
        PrintHelp "jenv-which", 1
    ElseIf arg(1) = "--help" Or arg(1) = "" Then
        PrintHelp "jenv-which", Abs(arg(1) = "")
    End If

    Dim path
    Dim program
    Dim exts
    Dim ext
    Dim version

    program = arg(1)
    version = objws.Environment("Process")("JENV_VERSION")

    If program = "" Then PrintHelp "jenv-which", 1
    If version = "" Then version = GetCurrentVersion()(0)
    If Right(program, 1) = "." Then program = Left(program, Len(program)-1)

    Set exts = GetExtensions(True)

    If Not objfs.FolderExists(strDirVers &"\"& version) Then
        WScript.Echo "jenv: version `"& version &"' is not installed (set by "& version &")"
        WScript.Quit 1
    End If

    If objfs.FileExists(strDirVers &"\"& version &"\"& program) Then
        WScript.Echo objfs.GetFile(strDirVers &"\"& version &"\"& program).Path
        WScript.Quit 0
    End If

    For Each ext In exts.Keys
        If objfs.FileExists(strDirVers &"\"& version &"\"& program & ext) Then
            WScript.Echo objfs.GetFile(strDirVers &"\"& version &"\"& program & ext).Path
            WScript.Quit 0
        End If
    Next

    If objfs.FolderExists(strDirVers &"\"& version & "\Scripts") Then
        If objfs.FileExists(strDirVers &"\"& version &"\Scripts\"& program) Then
            WScript.Echo objfs.GetFile(strDirVers &"\"& version &"\Scripts\"& program).Path
            WScript.Quit 0
        End If

        For Each ext In exts.Keys
            If objfs.FileExists(strDirVers &"\"& version &"\Scripts\"& program & ext) Then
                WScript.Echo objfs.GetFile(strDirVers &"\"& version &"\Scripts\"& program & ext).Path
                WScript.Quit 0
            End If
        Next
    End If
    WScript.Echo "jenv: "& arg(1) &": command not found"

    version = getCommandOutput("cscript //Nologo "& WScript.ScriptFullName &" whence "& program)
    If Trim(version) <> "" Then
        WScript.Echo
        WScript.Echo "The `"& arg(1) &"' command exists in these Python versions:"
        WScript.Echo "  "& Replace(version, vbCrLf, vbCrLf &"  ")
    End If

    WScript.Quit 127
End Sub

Sub CommandHelp(arg)
    ' WScript.echo "kkotari: pyenv.vbs command help..!"
    If arg.Count > 1 Then
        Dim list
        Set list = GetCommandList
        If list.Exists(arg(1)) Then
            ExecCommand(list(arg(1)) & " --help")
        Else
             WScript.Echo "unknown pyenv command '"& arg(1) &"'"
        End If
    Else
        ShowHelp
    End If
End Sub

Sub PlugIn(arg)
    ' WScript.echo "kkotari: pyenv.vbs plugin..!"

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
    ' WScript.echo "kkotari: pyenv.vbs main..!"
    ' WScript.echo "kkotari: "&arg(0)
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
           Case "vname"        CommandVersionName(arg)
           Case "versions"     CommandVersions(arg)
           Case "commands"     CommandCommands(arg)
           Case "shims"        CommandShims(arg)
           Case "which"        CommandWhich(arg)
           Case "help"         CommandHelp(arg)
           Case "--help"       CommandHelp(arg)
           Case Else           PlugIn(arg)
        End Select
    End If
End Sub

main(WScript.Arguments)
