@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"

set "REPO=arkenapps/Sakoon"
set "PAGES_URL=https://arkenapps.github.io/Sakoon/"

echo.
echo ================================================================
echo        SAKOON WEBSITE + README UPDATE PUBLISHER
echo ================================================================
echo.
echo This will:
echo   - push the real application screenshots
echo   - update README.md
echo   - publish docs\index.html
echo   - enable GitHub Pages from main /docs
echo.
set /p "CONFIRM=Type UPDATE to continue: "
if /I not "%CONFIRM%"=="UPDATE" (
    echo Cancelled.
    pause
    exit /b 0
)

where git >nul 2>nul || (
    echo [ERROR] Git is not available in PATH.
    pause
    exit /b 10
)

where gh >nul 2>nul || (
    echo [ERROR] GitHub CLI is not available in PATH.
    pause
    exit /b 11
)

gh auth status >nul 2>nul || (
    echo [ERROR] GitHub CLI is not authenticated.
    echo Run: gh auth login
    pause
    exit /b 12
)

if not exist ".git\" (
    echo [ERROR] This folder is not the local Sakoon Git repository.
    echo Run this file from the same Sakoon folder that was previously published.
    pause
    exit /b 13
)

if not exist "docs\index.html" (
    echo [ERROR] docs\index.html is missing.
    pause
    exit /b 14
)

echo.
echo [1/5] Staging website and screenshot changes...
git add README.md assets\screenshots docs\index.html docs\404.html docs\.nojekyll docs\sakoon-assets
if errorlevel 1 goto failed

git diff --cached --quiet
if errorlevel 1 (
    echo [2/5] Creating update commit...
    git commit -m "Add Sakoon product website and real screenshots"
    if errorlevel 1 goto failed
) else (
    echo [2/5] No new file changes need committing.
)

echo [3/5] Pushing main branch...
git push origin main
if errorlevel 1 goto failed

echo [4/5] Configuring GitHub Pages from main /docs...
gh api "repos/%REPO%/pages" >nul 2>nul
if errorlevel 1 (
    gh api --method POST "repos/%REPO%/pages" ^
      -f "build_type=legacy" ^
      -f "source[branch]=main" ^
      -f "source[path]=/docs"
    if errorlevel 1 goto pages_failed
) else (
    gh api --method PUT "repos/%REPO%/pages" ^
      -f "build_type=legacy" ^
      -f "source[branch]=main" ^
      -f "source[path]=/docs" ^
      -F "https_enforced=true" >nul
    if errorlevel 1 goto pages_failed
)

echo [5/5] Checking Pages configuration...
gh api "repos/%REPO%/pages" --jq "{url: .html_url, status: .status, source: .source}"
echo.
echo ================================================================
echo  UPDATE PUSHED SUCCESSFULLY
echo ================================================================
echo.
echo GitHub Pages:
echo   %PAGES_URL%
echo.
echo GitHub repository:
echo   https://github.com/%REPO%
echo.
echo Pages may take a few minutes to complete its first deployment.
echo Check the Actions tab if the page initially shows 404.
echo.
pause
exit /b 0

:pages_failed
echo.
echo [WARNING] The files were pushed, but automatic Pages configuration failed.
echo.
echo Configure it manually:
echo   Repository Settings ^> Pages
echo   Source: Deploy from a branch
echo   Branch: main
echo   Folder: /docs
echo   Save
echo.
echo Expected URL:
echo   %PAGES_URL%
echo.
pause
exit /b 20

:failed
echo.
echo [ERROR] The update did not complete.
echo Review the message above.
pause
exit /b 30
