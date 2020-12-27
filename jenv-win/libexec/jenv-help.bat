@echo off
setlocal

if "%1" == "--help" (
echo Usage: jenv ^<command^> [^<args^>]
echo.
echo Some useful jenv commands are:
echo    commands    List all available pyenv commands
echo    envs List all available pyenv invokes environment variables
echo    local       Set or show the local application-specific Python version
echo    global      Set or show the global Python version
echo    shell       Set or show the shell-specific Python version
echo    rehash      Rehash pyenv shims (run this after installing executables)
echo    version     Show the current Python version and its origin
echo    versions    List all Python versions available to pyenv
echo.
echo See `jenv help ^<command^>' for information on a specific command.
echo For full documentation, see: https://github.com/pyenv-win/pyenv-win#readme
echo.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file
