@echo off
setlocal
if "%1" == "--help" (
echo Usage: pyenv env
echo.
echo List all available pyenv invokes environment variables
echo        JENV                The directory where jenv home
echo        JENV_VERSIONS       The directory where jdk root  
echo options 
echo        --init              setting environment variables
echo        --unset             remove environment variables
echo.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file
