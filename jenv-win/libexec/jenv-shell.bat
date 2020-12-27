@echo off
setlocal

if "%1" == "--help" (
echo Usage: jenv shell ^<version^>
echo        jenv shell --unset
echo.
echo Sets a shell-specific Python version by setting the `JENV_VERSION'
echo environment variable in your shell. This version overrides local
echo application-specific versions and the global version.
echo.
EXIT /B
)

:: Implementation of this command is in the jenv.vbs file
