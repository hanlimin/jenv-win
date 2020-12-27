@echo off
setlocal
set KNOWN_VER=0.1

if "%1" == "--help" (
echo Usage: jenv --version
echo.
echo Displays the version number of this pyenv release, including the
echo current revision from git, if available.
echo.
echo The format of the git revision is:
echo   ^<major_version^>-^<train^>-^<minor_version^>
echo where `num_commits` is the number of commits since `minor_version` was
echo tagged.
echo.
EXIT /B
)

IF "%JENV%" == "" (
    set version=%KNOWN_VER%
    echo JENV variable is not set, recommended to set the variable.
) ELSE IF EXIST %JENV%\version (
    set version=<%JENV%\version
    IF "%version%" == "" set version=%KNOWN_VER%
) ELSE (
    set version=%KNOWN_VER%
)
echo jenv %version%

:: done..!
