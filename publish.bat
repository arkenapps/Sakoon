@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ================================================================
rem  Sakoon public repository + v1.0.0 release publisher
rem  Usage:
rem      publish.bat
rem      publish.bat --dry-run
rem ================================================================

set "OWNER=arkenapps"
set "REPO_NAME=Sakoon"
set "REPO=%OWNER%/%REPO_NAME%"
set "TAG=v1.0.0"
set "RELEASE_TITLE=Sakoon v1.0.0"
set "DESCRIPTION=A local-first Windows desktop app that mutes PC audio around official azaan times."
set "HOMEPAGE=https://arkenapps.com/"
set "EXE=release-assets\Sakoon.exe"
set "SAMPLE=release-assets\Sakoon-Table-Format-Example-NOT-OFFICIAL.csv"
set "CHECKSUMS=release-assets\SHA256SUMS.txt"
set "NOTES=releases\v1.0.0.md"
set "DRY_RUN=0"

:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="--dry-run" set "DRY_RUN=1"
if /I "%~1"=="/dry-run" set "DRY_RUN=1"
shift
goto parse_args

:args_done
echo.
echo ================================================================
echo  SAKOON GITHUB PUBLISHER
echo ================================================================
echo  Repository : %REPO%
echo  Release    : %TAG%
if "%DRY_RUN%"=="1" (
    echo  Mode       : DRY RUN - no GitHub or Git changes will be made
) else (
    echo  Mode       : LIVE
)
echo ================================================================
echo.

rem Always run from the folder containing this script.
cd /d "%~dp0"

rem ----------------------------------------------------------------
rem Public-repository safety checks
rem ----------------------------------------------------------------
for %%D in (cmd internal pkg vendor secrets certificates private-tables official-tables) do (
    if exist "%%D\" (
        echo [BLOCKED] Private or unsafe folder detected: %%D\
        echo Remove it from this public scaffold before publishing.
        exit /b 20
    )
)

for %%P in (*.go go.mod go.sum *.pfx *.p12 *.pem *.key *.cer *.crt .env .env.*) do (
    for /r %%F in (%%P) do (
        if exist "%%F" (
            echo [BLOCKED] Private source or secret-like file detected:
            echo           %%F
            echo Remove it from this public scaffold before publishing.
            exit /b 21
        )
    )
)

if not exist "%SAMPLE%" (
    echo [ERROR] Missing sample asset: %SAMPLE%
    exit /b 22
)

if not exist "%NOTES%" (
    echo [ERROR] Missing release notes: %NOTES%
    exit /b 23
)

if "%DRY_RUN%"=="0" (
    if not exist "%EXE%" (
        echo [ERROR] Missing final executable:
        echo         %EXE%
        echo.
        echo Copy the final Sakoon.exe into release-assets and run again.
        exit /b 24
    )
)

rem ----------------------------------------------------------------
rem Tool checks
rem ----------------------------------------------------------------
if "%DRY_RUN%"=="0" (
    where git >nul 2>nul
    if errorlevel 1 (
        echo [ERROR] Git is not installed or not available in PATH.
        exit /b 30
    )

    where gh >nul 2>nul
    if errorlevel 1 (
        echo [ERROR] GitHub CLI ^(gh^) is not installed or not available in PATH.
        exit /b 31
    )

    gh auth status >nul 2>nul
    if errorlevel 1 (
        echo [ERROR] GitHub CLI is not authenticated.
        echo Run: gh auth login
        exit /b 32
    )
) else (
    echo [DRY RUN] Would check: git --version
    echo [DRY RUN] Would check: gh --version
    echo [DRY RUN] Would check: gh auth status
)

rem ----------------------------------------------------------------
rem Generate release checksums
rem ----------------------------------------------------------------
if "%DRY_RUN%"=="1" (
    echo [DRY RUN] Would generate SHA-256 checksums for:
    echo           %EXE%
    echo           %SAMPLE%
    echo           into %CHECKSUMS%
) else (
    echo [1/6] Generating release checksums...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "$files = @('%EXE%', '%SAMPLE%');" ^
      "$lines = foreach ($f in $files) {" ^
      "  $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLower();" ^
      "  $name = [System.IO.Path]::GetFileName($f);" ^
      "  ($hash + '  ' + $name)" ^
      "};" ^
      "Set-Content -LiteralPath '%CHECKSUMS%' -Value $lines -Encoding ascii"
    if errorlevel 1 (
        echo [ERROR] Failed to generate SHA-256 checksums.
        exit /b 40
    )
)

rem ----------------------------------------------------------------
rem Initialise and commit public files
rem ----------------------------------------------------------------
if "%DRY_RUN%"=="1" (
    echo [DRY RUN] git init
    echo [DRY RUN] git checkout -B main
    echo [DRY RUN] git add .
    echo [DRY RUN] git commit -m "Prepare Sakoon public repository"
) else (
    echo [2/6] Preparing local Git repository...
    if not exist ".git\" (
        git init
        if errorlevel 1 exit /b 41
    )

    git checkout -B main
    if errorlevel 1 exit /b 42

    git add .
    if errorlevel 1 exit /b 43

    git diff --cached --quiet
    if errorlevel 1 (
        git commit -m "Prepare Sakoon public repository"
        if errorlevel 1 exit /b 44
    ) else (
        echo [INFO] No new committed-file changes detected.
    )
)

rem ----------------------------------------------------------------
rem Create or connect repository and push
rem ----------------------------------------------------------------
if "%DRY_RUN%"=="1" (
    echo [DRY RUN] Would test whether %REPO% already exists.
    echo [DRY RUN] If missing:
    echo           gh repo create %REPO% --public --source=. --remote=origin --description "%DESCRIPTION%" --homepage "%HOMEPAGE%" --push
    echo [DRY RUN] If present:
    echo           git remote set-url origin https://github.com/%REPO%.git
    echo           git push -u origin main
) else (
    echo [3/6] Creating or connecting GitHub repository...
    gh repo view "%REPO%" --json name >nul 2>nul

    if errorlevel 1 (
        gh repo create "%REPO%" --public --source=. --remote=origin --description "%DESCRIPTION%" --homepage "%HOMEPAGE%" --push
        if errorlevel 1 (
            echo [ERROR] GitHub repository creation failed.
            exit /b 50
        )
    ) else (
        git remote get-url origin >nul 2>nul
        if errorlevel 1 (
            git remote add origin "https://github.com/%REPO%.git"
        ) else (
            git remote set-url origin "https://github.com/%REPO%.git"
        )
        if errorlevel 1 exit /b 51

        git push -u origin main
        if errorlevel 1 (
            echo [ERROR] Push failed.
            exit /b 52
        )
    )
)

rem ----------------------------------------------------------------
rem Prevent accidental duplicate release
rem ----------------------------------------------------------------
if "%DRY_RUN%"=="1" (
    echo [DRY RUN] Would ensure release %TAG% does not already exist.
) else (
    echo [4/6] Checking release tag...
    gh release view "%TAG%" --repo "%REPO%" >nul 2>nul
    if not errorlevel 1 (
        echo [ERROR] Release %TAG% already exists.
        echo Edit or delete the existing release manually rather than overwriting it.
        exit /b 60
    )
)

rem ----------------------------------------------------------------
rem Create release
rem ----------------------------------------------------------------
if "%DRY_RUN%"=="1" (
    echo [DRY RUN] gh release create %TAG% ^
      "%EXE%#Sakoon for Windows" ^
      "%SAMPLE%#Timing-table format example - not official" ^
      "%CHECKSUMS%#SHA-256 checksums" ^
      --repo %REPO% ^
      --title "%RELEASE_TITLE%" ^
      --notes-file "%NOTES%" ^
      --latest
) else (
    echo [5/6] Creating GitHub release and uploading assets...
    gh release create "%TAG%" ^
      "%EXE%#Sakoon for Windows" ^
      "%SAMPLE%#Timing-table format example - not official" ^
      "%CHECKSUMS%#SHA-256 checksums" ^
      --repo "%REPO%" ^
      --title "%RELEASE_TITLE%" ^
      --notes-file "%NOTES%" ^
      --latest

    if errorlevel 1 (
        echo [ERROR] Release creation or asset upload failed.
        exit /b 61
    )
)

rem ----------------------------------------------------------------
rem Final verification
rem ----------------------------------------------------------------
if "%DRY_RUN%"=="1" (
    echo [DRY RUN] Would open:
    echo           https://github.com/%REPO%
    echo           https://github.com/%REPO%/releases/tag/%TAG%
    echo.
    echo Dry run completed. No changes were made.
) else (
    echo [6/6] Verifying published release...
    gh release view "%TAG%" --repo "%REPO%" --json name,tagName,url,isDraft,isPrerelease
    if errorlevel 1 exit /b 62

    echo.
    echo ================================================================
    echo  SAKOON PUBLISHED SUCCESSFULLY
    echo ================================================================
    echo  Repository: https://github.com/%REPO%
    echo  Release   : https://github.com/%REPO%/releases/tag/%TAG%
    echo ================================================================
)

exit /b 0
