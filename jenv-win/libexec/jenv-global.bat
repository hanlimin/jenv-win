@echo off
setlocal

if "%1" == "--help" (
echo Usage: jenv global ^<version^>
echo.
echo Sets the global Java version. You can override the global version at
echo any time by setting a directory-specific version with `jenv local'
echo or by setting the `JENV_VERSION' environment variable.
echo.
EXIT /B
)

:: Implementation of this command is in the pyenv.vbs file
