@echo off
setlocal

if "%1" == "--help" (
echo Usage: jenv version
echo.
echo Shows the currently selected Python version and how it was selected.
echo To obtain only the version string, use `jenv vname'.
EXIT /B
)

:: Implementation of this command is in the jenv.vbs file
