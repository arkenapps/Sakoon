@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"

:menu
cls
echo.
echo ================================================================
echo                 SAKOON - GITHUB START MENU
echo ================================================================
echo.
echo   1. Check Git, GitHub CLI and login
echo   2. Test everything safely - DRY RUN
echo   3. Publish repository and v1.0.0 release - LIVE  (first time only)
echo   6. UPDATE the published repo and cut v2.0.0 - LIVE
echo   7. UPDATE - dry run first (recommended)
echo   4. Open this folder
echo   5. Open publishing instructions
echo   0. Exit
echo.
echo ================================================================
set /p "CHOICE=Choose an option: "

if "%CHOICE%"=="1" goto check
if "%CHOICE%"=="2" goto dryrun
if "%CHOICE%"=="3" goto live
if "%CHOICE%"=="4" goto folder
if "%CHOICE%"=="5" goto instructions
if "%CHOICE%"=="6" goto v2live
if "%CHOICE%"=="7" goto v2dry
if "%CHOICE%"=="0" exit /b 0

echo.
echo Invalid option.
pause
goto menu

:check
cls
echo.
echo ================================================================
echo                    CHECKING YOUR SETUP
echo ================================================================
echo.

where git >nul 2>nul
if errorlevel 1 (
    echo [MISSING] Git for Windows is not installed or not in PATH.
    echo           Install it, restart this window, then run this check again.
    echo.
    echo           Official download:
    echo           https://git-scm.com/download/win
) else (
    echo [OK] Git is installed:
    git --version
    echo.
    git config --global user.name >nul 2>nul
    if errorlevel 1 (
        echo [MISSING] Git author name is not configured.
        echo           Example:
        echo           git config --global user.name "ArkenApps"
    ) else (
        echo [OK] Git author name:
        git config --global user.name
    )
    echo.
    git config --global user.email >nul 2>nul
    if errorlevel 1 (
        echo [MISSING] Git author email is not configured.
        echo           Use your GitHub email or GitHub no-reply email:
        echo           git config --global user.email "YOUR_EMAIL"
    ) else (
        echo [OK] Git author email:
        git config --global user.email
    )
)

echo.
where gh >nul 2>nul
if errorlevel 1 (
    echo [MISSING] GitHub CLI is not installed or not in PATH.
    echo           Install it, restart this window, then run this check again.
    echo.
    echo           Official download:
    echo           https://cli.github.com/
) else (
    echo [OK] GitHub CLI is installed:
    gh --version
)

echo.
where gh >nul 2>nul
if not errorlevel 1 (
    gh auth status
    if errorlevel 1 (
        echo.
        echo [ACTION REQUIRED] Sign in with:
        echo.
        echo     gh auth login
        echo.
        echo Choose:
        echo   - GitHub.com
        echo   - HTTPS
        echo   - Login with a web browser
    ) else (
        echo.
        echo [OK] GitHub CLI authentication is active.
        echo.
        echo Active GitHub account:
        gh api user --jq ".login" 2>nul
        echo.
        echo This account must be allowed to create repositories under:
        echo   arkenapps
    )
)

echo.
if exist "release-assets\Sakoon.exe" (
    echo [OK] Found release-assets\Sakoon.exe
) else (
    echo [MISSING] release-assets\Sakoon.exe
    echo           Copy your final compiled Sakoon.exe into that folder.
)

echo.
if exist "assets\screenshots\dashboard-placeholder.svg" (
    echo [NOTICE] Screenshot placeholders are still present.
    echo          You can publish now, but final screenshots are recommended.
)

echo.
echo Check complete.
pause
goto menu

:dryrun
cls
echo.
echo Running the safe dry run...
echo Nothing will be uploaded or changed on GitHub.
echo.
call "%~dp0publish.bat" --dry-run
echo.
pause
goto menu

:live
cls
echo.
echo ================================================================
echo                     LIVE PUBLICATION
echo ================================================================
echo.
echo This will create or update:
echo.
echo   https://github.com/arkenapps/Sakoon
echo.
echo It will also create the public v1.0.0 release and upload Sakoon.exe.
echo.
echo Before continuing, confirm that:
echo   - release-assets\Sakoon.exe is the final tested build
echo   - no private source code is inside this folder
echo   - the active GitHub account can create repos under arkenapps
echo.
set /p "CONFIRM=Type PUBLISH to continue: "
if /I not "%CONFIRM%"=="PUBLISH" (
    echo.
    echo Publication cancelled.
    pause
    goto menu
)

call "%~dp0publish.bat"
echo.
pause
goto menu

:folder
start "" "%~dp0"
goto menu

:instructions
start "" "%~dp0PUBLISHING.md"
goto menu

:v2dry
cls
call "%~dp0PUBLISH-V2-UPDATE.bat" --dry-run
pause
goto menu

:v2live
cls
echo.
echo This pushes the updated documentation to GitHub and creates the
echo v2.0.0 release. Build Sakoon.exe first and copy it into
echo release-assets\ - the script checks its version and will stop if
echo it is still the old build.
echo.
pause
call "%~dp0PUBLISH-V2-UPDATE.bat"
pause
goto menu
