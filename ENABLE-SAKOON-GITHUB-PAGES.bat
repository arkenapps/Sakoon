@echo off
setlocal EnableExtensions
chcp 65001 >nul

set "REPO=arkenapps/Sakoon"
set "SITE=https://arkenapps.github.io/Sakoon/"

echo.
echo ================================================================
echo              ENABLE SAKOON GITHUB PAGES
echo ================================================================
echo.
echo Repository:
echo   https://github.com/%REPO%
echo.
echo Website:
echo   %SITE%
echo.
echo Publishing source:
echo   Branch: main
echo   Folder: /docs
echo.

where gh >nul 2>nul
if errorlevel 1 (
    echo [ERROR] GitHub CLI ^(gh^) is not installed or not available in PATH.
    pause
    exit /b 10
)

gh auth status >nul 2>nul
if errorlevel 1 (
    echo [ERROR] GitHub CLI is not authenticated.
    echo Run:
    echo   gh auth login
    pause
    exit /b 11
)

gh repo view "%REPO%" >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Cannot access repository %REPO%.
    echo Check the active account with:
    echo   gh auth status
    pause
    exit /b 12
)

echo Checking whether GitHub Pages is already configured...
gh api "repos/%REPO%/pages" >nul 2>nul

if errorlevel 1 (
    echo.
    echo Creating GitHub Pages configuration...
    gh api --method POST "repos/%REPO%/pages" ^
      -f "build_type=legacy" ^
      -f "source[branch]=main" ^
      -f "source[path]=/docs"

    if errorlevel 1 goto manual
) else (
    echo.
    echo Updating GitHub Pages configuration...
    gh api --method PUT "repos/%REPO%/pages" ^
      -f "build_type=legacy" ^
      -f "source[branch]=main" ^
      -f "source[path]=/docs" ^
      -F "https_enforced=true"

    if errorlevel 1 goto manual
)

echo.
echo Current GitHub Pages status:
gh api "repos/%REPO%/pages" --jq "{url: .html_url, status: .status, source: .source}"

echo.
echo ================================================================
echo  GITHUB PAGES CONFIGURED
echo ================================================================
echo.
echo Your Sakoon website will be available at:
echo.
echo   %SITE%
echo.
echo The first deployment may take a few minutes.
echo If it initially shows 404, wait and refresh, or inspect:
echo.
echo   https://github.com/%REPO%/actions
echo.
set /p "OPEN=Open the website now? Type Y or press Enter to finish: "
if /I "%OPEN%"=="Y" start "" "%SITE%"

pause
exit /b 0

:manual
echo.
echo ================================================================
echo  AUTOMATIC ACTIVATION DID NOT COMPLETE
echo ================================================================
echo.
echo The website files are already in the repository.
echo Enable Pages manually:
echo.
echo   1. Open https://github.com/%REPO%/settings/pages
echo   2. Under Build and deployment, choose:
echo        Source: Deploy from a branch
echo        Branch: main
echo        Folder: /docs
echo   3. Click Save
echo.
echo Expected website:
echo   %SITE%
echo.
start "" "https://github.com/%REPO%/settings/pages"
pause
exit /b 20
