@echo off
setlocal

if "%1" == "--help" (
echo Usage: jenv shims
echo        jenv shims --short
echo.
echo List the existing jenv shims
echo.
EXIT /B
)

:: Implementation of this command is in the jenv.vbs file
