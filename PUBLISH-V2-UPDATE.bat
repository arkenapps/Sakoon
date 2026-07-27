@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem ================================================================
rem  This script has been folded into publish.bat.
rem
rem  publish.bat is now the single publisher and always ships BOTH
rem  downloads as zips (Sakoon.zip + Sakoon-Setup.zip),
rem  whether the repo is being created for the first time or updated.
rem
rem  This shim just forwards to it so old habits keep working.
rem ================================================================

echo Redirecting to publish.bat ...
echo.
call "%~dp0publish.bat" %*
exit /b %errorlevel%
