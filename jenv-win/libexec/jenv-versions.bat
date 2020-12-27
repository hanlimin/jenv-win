@echo off
setlocal

if "%1" == "--help" (
echo Usage: jenv versions [--bare] [--skip-aliases]
echo.
echo Lists all Python versions found in `$JENV_ROOT/versions/*'.
EXIT /B
)

:: Implementation of this command is in the jenv.vbs file
