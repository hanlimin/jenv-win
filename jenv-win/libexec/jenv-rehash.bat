@echo off
setlocal

if "%1" == "--help" (
echo Usage: jenv rehash
echo.
echo Rehash jenv shims ^(run this after installing executables^)
echo.
EXIT /B
)

:: Implementation of this command is in the jenv.vbs file
