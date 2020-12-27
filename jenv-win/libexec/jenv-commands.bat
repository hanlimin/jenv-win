@echo off
setlocal
if "%1" == "--help" (
echo Usage: pyenv environment
echo.
echo List all available pyenv environment
echo.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file
