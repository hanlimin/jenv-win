@echo off
setlocal

if "%1" == "--help" (
echo Usage: jenv local ^<version^>
echo        jenv local --unset
echo.
echo Sets the local application-specific Java version by writing the
echo version name to a file named `.java-version'.
echo.
echo When you run a Java command, jenv will look for a `.java-version'
echo file in the current directory and each parent directory. If no such
echo file is found in the tree, jenv will use the global Java version
echo specified with `jenv global'. A version specified with the
echo `JENV_VERSION' environment variable takes precedence over local
echo and global versions.
echo.
EXIT /B
)

:: Implementation of this command is in the jenv.vbs file
