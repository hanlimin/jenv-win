
$env:JENV_SHELL="ps"
$jenv_home=$PSScriptRoot+"\.."

if(Test-Path $jenv_home\exec.ps1)
{
    Remove-Item $jenv_home\exec.ps1
}

cscript.exe //nologo $jenv_home\libexec\jenv.vbs $args

if(Test-Path $jenv_home\exec.ps1)
{
    . $jenv_home\exec.ps1
}
