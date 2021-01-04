@echo off
set JENV_SHELL=cmd

IF EXIST "%~dp0"..\exec.bat (
    del /F /Q "%~dp0"..\exec.bat >nul
)

call cscript //nologo "%~dp0"..\libexec\jenv.vbs %*

IF EXIST "%~dp0"..\exec.bat (
    "%~dp0"..\exec.bat
)
