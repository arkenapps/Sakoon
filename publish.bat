@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
cd /d "%~dp0"

rem ================================================================
rem  Sakoon publisher - two separate downloads, both .zip
rem
rem  This is the ONE script to run. It works whether the repo is
rem  being created for the first time OR updated. It does NOT build
rem  or rebuild anything - it uploads the two zips you already made:
rem
rem      release-assets\Sakoon.zip         direct exe   (Sakoon.exe)
rem      release-assets\Sakoon-Setup.zip   installer    (Sakoon-Setup.exe)
rem
rem  Those two names are exactly what docs\index.html links to via
rem  releases/latest/download/... so the website buttons resolve.
rem
rem  Usage:
rem      publish.bat                first-time OR update  (LIVE)
rem      publish.bat --dry-run      rehearse, change nothing
rem      publish.bat --docs-only    push docs, skip the release
rem      publish.bat --force-push   local folder wins on push
rem ================================================================

set "OWNER=arkenapps"
set "REPO_NAME=Sakoon"
set "REPO=%OWNER%/%REPO_NAME%"

set "TAG=v2.0.1"
set "RELEASE_TITLE=Sakoon v2.0.1"
set "DESCRIPTION=A local-first Windows desktop app that mutes PC audio around official azaan times."
set "HOMEPAGE=https://arkenapps.com/"

set "PORTZIP=release-assets\Sakoon.zip"
set "SETUPZIP=release-assets\Sakoon-Setup.zip"
set "SAMPLE=release-assets\Sakoon-Table-Format-Example-NOT-OFFICIAL.csv"
set "CHECKSUMS=release-assets\SHA256SUMS.txt"
set "NOTES=releases\v2.0.1.md"
set "COMMIT_MSG=Sakoon %TAG% - direct + installer zip downloads, docs updated"

set "DRY_RUN=0"
set "DOCS_ONLY=0"
set "FORCE_PUSH=0"

:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="--dry-run"    set "DRY_RUN=1"
if /I "%~1"=="/dry-run"     set "DRY_RUN=1"
if /I "%~1"=="--docs-only"  set "DOCS_ONLY=1"
if /I "%~1"=="/docs-only"   set "DOCS_ONLY=1"
if /I "%~1"=="--force-push" set "FORCE_PUSH=1"
if /I "%~1"=="/force-push"  set "FORCE_PUSH=1"
shift
goto parse_args

:args_done
echo.
echo ================================================================
echo  SAKOON PUBLISHER  -  two downloads, both .zip
echo ================================================================
echo  Repository : %REPO%
echo  Release    : %TAG%
if "%DRY_RUN%"=="1" (
    echo  Mode       : DRY RUN - nothing will be changed
) else if "%DOCS_ONLY%"=="1" (
    echo  Mode       : LIVE - documentation only, no release
) else (
    echo  Mode       : LIVE - documentation + %TAG% release
)
if "%FORCE_PUSH%"=="1" echo  Push       : FORCED - this local folder overwrites origin/main
echo ================================================================
echo.

rem ----------------------------------------------------------------
rem [1/8]  Public-repository safety checks
rem ----------------------------------------------------------------
echo [1/8] Running safety checks...
for %%D in (cmd internal pkg vendor secrets certificates private-tables official-tables frontend) do (
    if exist "%%D\" (
        echo   [BLOCKED] Private or unsafe folder present: %%D\
        echo   Remove it from this public folder before publishing.
        exit /b 20
    )
)
for %%P in (*.go go.mod go.sum *.pfx *.p12 *.pem *.key *.cer *.crt .env) do (
    for /r %%F in (%%P) do (
        if exist "%%F" (
            echo   [BLOCKED] Private source or secret-like file present:
            echo             %%F
            exit /b 21
        )
    )
)
if not exist "%NOTES%" (
    echo   [ERROR] Missing release notes: %NOTES%
    exit /b 22
)
if not exist "docs\index.html" (
    echo   [ERROR] Missing docs\index.html - the GitHub Pages site.
    exit /b 23
)
echo   OK - no private source, release notes and site present.

rem ----------------------------------------------------------------
rem [2/8]  Tooling
rem ----------------------------------------------------------------
echo [2/8] Checking Git and GitHub CLI...
where git >nul 2>nul
if errorlevel 1 (
    echo   [ERROR] Git is not installed or not on PATH.
    echo   Install:  winget install Git.Git
    exit /b 30
)
where gh >nul 2>nul
if errorlevel 1 (
    echo   [ERROR] GitHub CLI ^(gh^) is not installed or not on PATH.
    echo   Install:  winget install GitHub.cli
    exit /b 31
)
if "%DRY_RUN%"=="0" (
    gh auth status >nul 2>nul
    if errorlevel 1 (
        echo   [ERROR] GitHub CLI is not signed in.
        echo   Run:  gh auth login
        exit /b 32
    )
)
echo   OK - git and gh available.

if "%DOCS_ONLY%"=="1" (
    echo [3/8] Skipping download check ^(--docs-only^).
    echo [4/8] Skipping checksums ^(--docs-only^).
    goto after_package
)

rem ----------------------------------------------------------------
rem [3/8]  Both download zips must already be present
rem        You build them; this script only uploads them. If either
rem        is missing it STOPS - it never ships a half release.
rem ----------------------------------------------------------------
echo [3/8] Checking the two download zips...
if not exist "%PORTZIP%" (
    echo   [ERROR] Missing direct-exe download: %PORTZIP%
    echo           Put your zipped Sakoon.exe there as  Sakoon.zip
    exit /b 24
)
if not exist "%SETUPZIP%" (
    echo   [ERROR] Missing installer download: %SETUPZIP%
    echo           Put your zipped Sakoon-Setup.exe there as  Sakoon-Setup.zip
    exit /b 25
)
for %%A in ("%PORTZIP%")  do echo   Sakoon.zip        %%~zA bytes   %%~tA
for %%A in ("%SETUPZIP%") do echo   Sakoon-Setup.zip  %%~zA bytes   %%~tA

rem ---- Light sanity peek: each zip should contain an .exe ---------
call :peek_exe "%PORTZIP%"
call :peek_exe "%SETUPZIP%"

rem ----------------------------------------------------------------
rem  Sample table lives in samples\ ; stage a copy if not already
rem  beside the zips so it can ride along on the release.
rem ----------------------------------------------------------------
set "HAVE_SAMPLE=1"
if not exist "%SAMPLE%" (
    if exist "samples\Sakoon-Table-Format-Example-NOT-OFFICIAL.csv" (
        copy /y "samples\Sakoon-Table-Format-Example-NOT-OFFICIAL.csv" "%SAMPLE%" >nul
    )
)
if not exist "%SAMPLE%" set "HAVE_SAMPLE=0"

rem ----------------------------------------------------------------
rem [4/8]  Checksums over exactly what users download
rem ----------------------------------------------------------------
if "%DRY_RUN%"=="1" (
    echo [4/8] [DRY RUN] Would write SHA-256 sums for both zips to %CHECKSUMS%
    goto after_package
)
echo [4/8] Generating SHA-256 checksums...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$files = @('%PORTZIP%', '%SETUPZIP%', '%SAMPLE%');" ^
  "$lines = foreach ($f in $files) {" ^
  "  if (Test-Path -LiteralPath $f) {" ^
  "    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLower();" ^
  "    ($hash + '  ' + [System.IO.Path]::GetFileName($f))" ^
  "  }" ^
  "};" ^
  "Set-Content -LiteralPath '%CHECKSUMS%' -Value $lines -Encoding ascii"
if errorlevel 1 ( echo   [ERROR] Checksum generation failed. & exit /b 40 )
type "%CHECKSUMS%"

:after_package

rem ----------------------------------------------------------------
rem [5/8]  Commit
rem ----------------------------------------------------------------
echo [5/8] Committing changes...
if "%DRY_RUN%"=="1" (
    echo   [DRY RUN] git init / checkout -B main / add -A / commit
    goto after_commit
)
if not exist ".git\" (
    git init
    if errorlevel 1 exit /b 41
)
git remote get-url origin >nul 2>nul
if errorlevel 1 (
    git remote add origin "https://github.com/%REPO%.git"
) else (
    git remote set-url origin "https://github.com/%REPO%.git"
)
git checkout -B main
if errorlevel 1 exit /b 42
git add -A
if errorlevel 1 exit /b 43
git diff --cached --quiet
if errorlevel 1 (
    git commit -m "%COMMIT_MSG%" >nul
    if errorlevel 1 exit /b 44
) else (
    echo   No local file changes detected.
)

:after_commit

rem ----------------------------------------------------------------
rem [6/8]  Create the repo (first time) or graft + push (update)
rem ----------------------------------------------------------------
echo [6/8] Publishing repository...
if "%DRY_RUN%"=="1" (
    echo   [DRY RUN] Would create %REPO% if missing, else fast-forward push to main.
    goto after_push
)

gh repo view "%REPO%" --json name >nul 2>nul
if errorlevel 1 (
    echo   Repository does not exist yet - creating it public and pushing...
    gh repo create "%REPO%" --public --source=. --remote=origin --description "%DESCRIPTION%" --homepage "%HOMEPAGE%" --push
    if errorlevel 1 ( echo   [ERROR] Repository creation failed. & exit /b 50 )
    goto after_push
)

echo   Repository exists - reconciling with the published history...
git fetch origin main >nul 2>nul
if errorlevel 1 (
    echo   No published main branch yet - pushing as the first commit.
    goto do_push
)
git rev-parse --verify --quiet FETCH_HEAD >nul
if errorlevel 1 goto do_push
git merge-base --is-ancestor FETCH_HEAD HEAD >nul 2>nul
if not errorlevel 1 (
    echo   Already based on the published history.
    goto do_push
)
echo   Re-parenting this folder onto origin/main...
git reset --soft FETCH_HEAD
if errorlevel 1 ( echo   [ERROR] Could not read the published history. & exit /b 51 )
git add -A
git diff --cached --quiet
if errorlevel 1 (
    git commit -m "%COMMIT_MSG%" >nul
    if errorlevel 1 exit /b 52
    echo   Committed on top of the published history.
) else (
    echo   Nothing differs from what is already published.
)

:do_push
if "%FORCE_PUSH%"=="1" (
    git push --force origin main
) else (
    git push -u origin main
)
if errorlevel 1 (
    echo.
    echo   [ERROR] Push was rejected.
    echo   Usually this means someone pushed to main seconds ago.
    echo   Try again:  publish.bat
    echo   Only if this folder is definitely the version to keep:
    echo               publish.bat --force-push
    exit /b 53
)

:after_push

rem ----------------------------------------------------------------
rem [7/8]  Release with BOTH zips (exact names the website links to)
rem ----------------------------------------------------------------
if "%DOCS_ONLY%"=="1" (
    echo [7/8] Skipping release ^(--docs-only^).
    goto done
)
echo [7/8] Creating the %TAG% release...
if "%DRY_RUN%"=="1" (
    echo   [DRY RUN] gh release create %TAG% with:
    echo             %PORTZIP%   -^> asset "Sakoon.zip"        (direct exe)
    echo             %SETUPZIP%  -^> asset "Sakoon-Setup.zip"  (installer)
    if "%HAVE_SAMPLE%"=="1" echo             %SAMPLE%
    echo             %CHECKSUMS%
    echo   [DRY RUN] notes from %NOTES%, marked --latest
    goto done
)

gh release view "%TAG%" --repo "%REPO%" >nul 2>nul
if not errorlevel 1 (
    echo.
    echo   Release %TAG% already exists on GitHub.
    choice /c YN /m "Replace its assets and notes"
    if not !errorlevel!==1 (
        echo   Left the existing release alone.
        goto done
    )
    gh release delete "%TAG%" --repo "%REPO%" --yes --cleanup-tag
    if errorlevel 1 (
        gh release delete "%TAG%" --repo "%REPO%" --yes
        if errorlevel 1 ( echo   [ERROR] Could not remove the existing release. & exit /b 60 )
        git push --delete origin "%TAG%" >nul 2>nul
    )
)

set "SAMPLE_ASSET="
if "%HAVE_SAMPLE%"=="1" set "SAMPLE_ASSET="%SAMPLE%#Timing-table format example - not official""

gh release create "%TAG%" ^
  "%PORTZIP%#Sakoon direct download (unzip and run Sakoon.exe)" ^
  "%SETUPZIP%#Sakoon installer (unzip and run Sakoon-Setup.exe)" ^
  %SAMPLE_ASSET% ^
  "%CHECKSUMS%#SHA-256 checksums" ^
  --repo "%REPO%" ^
  --title "%RELEASE_TITLE%" ^
  --notes-file "%NOTES%" ^
  --latest
if errorlevel 1 ( echo   [ERROR] Release creation or asset upload failed. & exit /b 61 )

gh repo edit "%REPO%" --description "%DESCRIPTION%" --homepage "%HOMEPAGE%" >nul 2>nul

:done

rem ----------------------------------------------------------------
rem [8/8]  Summary
rem ----------------------------------------------------------------
echo.
echo ================================================================
if "%DRY_RUN%"=="1" (
    echo  DRY RUN COMPLETE - nothing was changed.
    echo ================================================================
    echo.
    pause
    exit /b 0
)
echo  DONE.
echo  Repository : https://github.com/%REPO%
if "%DOCS_ONLY%"=="0" (
    echo  Release    : https://github.com/%REPO%/releases/tag/%TAG%
    echo.
    echo  Website download buttons map to these release assets:
    echo    Direct exe ^-^> releases/latest/download/Sakoon.zip
    echo    Installer  ^-^> releases/latest/download/Sakoon-Setup.zip
    echo  Both were just uploaded, and the release is marked --latest,
    echo  so those two links now resolve.
)
echo  Pages site : https://%OWNER%.github.io/%REPO_NAME%/
echo.
echo  Reminders:
echo    - Make the repo PUBLIC if it is not already
echo      ^(gh repo edit %REPO% --visibility public^).
echo    - Enable GitHub Pages from main /docs ^(ENABLE-SAKOON-GITHUB-PAGES.bat^).
echo ================================================================
echo.
pause
exit /b 0

rem ----------------------------------------------------------------
rem  Subroutine: warn if a zip has no .exe inside (non-fatal)
rem ----------------------------------------------------------------
:peek_exe
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Add-Type -AssemblyName System.IO.Compression.FileSystem;" ^
  "$z=[System.IO.Compression.ZipFile]::OpenRead((Resolve-Path '%~1'));" ^
  "$hit=$z.Entries ^| Where-Object { $_.Name -like '*.exe' } ^| Select-Object -First 1;" ^
  "$z.Dispose();" ^
  "if(-not $hit){ exit 1 }" 2>nul
if errorlevel 1 echo   [WARN] %~1 does not appear to contain an .exe - double-check it.
goto :eof
