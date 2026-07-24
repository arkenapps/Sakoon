@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
cd /d "%~dp0"

rem ================================================================
rem  Sakoon v2.0.0 repository update + release publisher
rem
rem  Use this when arkenapps/Sakoon ALREADY EXISTS on GitHub and you
rem  are pushing the updated documentation and cutting the v2.0.0
rem  release. (publish.bat was the first-time publisher.)
rem
rem  Usage:
rem      PUBLISH-V2-UPDATE.bat              docs + release  (LIVE)
rem      PUBLISH-V2-UPDATE.bat --dry-run    rehearse, change nothing
rem      PUBLISH-V2-UPDATE.bat --docs-only  push docs, skip release
rem      PUBLISH-V2-UPDATE.bat --force-push local folder wins on push
rem ================================================================

set "OWNER=arkenapps"
set "REPO_NAME=Sakoon"
set "REPO=%OWNER%/%REPO_NAME%"
set "TAG=v2.0.0"
set "RELEASE_TITLE=Sakoon v2.0.0"
set "EXPECTED_VER=2.0.0"
set "DESCRIPTION=A local-first Windows desktop app that mutes PC audio around official azaan times."
set "HOMEPAGE=https://arkenapps.com/"
set "EXE=release-assets\Sakoon.exe"
set "SAMPLE=release-assets\Sakoon-Table-Format-Example-NOT-OFFICIAL.csv"
set "CHECKSUMS=release-assets\SHA256SUMS.txt"
set "NOTES=releases\v2.0.0.md"
set "COMMIT_MSG=Sakoon v2.0.0 - standalone desktop app; docs updated for mute behaviour and no network ports"

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
echo  SAKOON v2.0.0 - REPOSITORY UPDATE
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
rem [1/7]  Public-repository safety checks
rem        The Go source stays private. Refuse to publish if any of it
rem        wandered into this folder.
rem ----------------------------------------------------------------
echo [1/7] Running safety checks...
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
rem [2/7]  Tooling
rem ----------------------------------------------------------------
echo [2/7] Checking Git and GitHub CLI...
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

rem ----------------------------------------------------------------
rem [3/7]  Confirm the exe really is the v2 build
rem        Sakoon's oldest footgun is shipping yesterday's binary.
rem        The version resource comes from build\windows\info.json, so
rem        a v1 exe cannot fake %EXPECTED_VER%.
rem ----------------------------------------------------------------
if "%DOCS_ONLY%"=="1" (
    echo [3/7] Skipping executable check ^(--docs-only^).
    goto after_exe
)
echo [3/7] Verifying %EXE% ...
if not exist "%EXE%" (
    echo   [ERROR] Missing executable: %EXE%
    echo.
    echo   Build it first:  cd Sakoon  ^&^&  build.bat
    echo   then copy the new Sakoon.exe into release-assets\
    echo.
    echo   Or run with --docs-only to publish just the documentation.
    exit /b 24
)
set "EXEVER="
for /f "delims=" %%v in ('powershell -NoProfile -Command "(Get-Item '%EXE%').VersionInfo.ProductVersion" 2^>nul') do set "EXEVER=%%v"
if not defined EXEVER (
    echo   [WARN] Could not read the version resource from the exe.
) else (
    echo   Version resource: !EXEVER!
    echo !EXEVER! | find "%EXPECTED_VER%" >nul
    if errorlevel 1 (
        echo.
        echo   [STOP] That exe reports !EXEVER!, not %EXPECTED_VER%.
        echo   This looks like the OLD build. Rebuild and copy the new
        echo   Sakoon.exe into release-assets\ before publishing.
        echo.
        choice /c YN /m "Publish it anyway"
        if not !errorlevel!==1 exit /b 25
    )
)
for %%A in ("%EXE%") do echo   Size: %%~zA bytes   Built: %%~tA

:after_exe

rem ----------------------------------------------------------------
rem [4/7]  Checksums
rem ----------------------------------------------------------------
if "%DOCS_ONLY%"=="1" (
    echo [4/7] Skipping checksums ^(--docs-only^).
    goto after_sums
)
if "%DRY_RUN%"=="1" (
    echo [4/7] [DRY RUN] Would write SHA-256 sums to %CHECKSUMS%
    goto after_sums
)
echo [4/7] Generating SHA-256 checksums...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$files = @('%EXE%', '%SAMPLE%');" ^
  "$lines = foreach ($f in $files) {" ^
  "  if (Test-Path -LiteralPath $f) {" ^
  "    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $f).Hash.ToLower();" ^
  "    ($hash + '  ' + [System.IO.Path]::GetFileName($f))" ^
  "  }" ^
  "};" ^
  "Set-Content -LiteralPath '%CHECKSUMS%' -Value $lines -Encoding ascii"
if errorlevel 1 (
    echo   [ERROR] Checksum generation failed.
    exit /b 40
)
type "%CHECKSUMS%"

:after_sums

rem ----------------------------------------------------------------
rem [5/7]  Commit
rem ----------------------------------------------------------------
echo [5/7] Committing changes...
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

rem ---- Graft onto the published history ------------------------
rem  This folder is usually a fresh "git init", so its history has
rem  nothing in common with origin/main and a plain push is rejected
rem  as non-fast-forward. Rather than force-pushing over the v1
rem  history, re-parent this exact folder ON TOP of origin/main:
rem  "git reset --soft" moves HEAD to the published commit while
rem  leaving the staged tree - this folder - completely untouched.
rem  The result is one honest commit on top of the real history,
rem  the contents are exactly what is in this folder, and the push
rem  is an ordinary fast-forward. Nothing on GitHub is discarded.
echo   Checking the published history on GitHub...
git fetch origin main >nul 2>nul
if errorlevel 1 (
    echo   No published main branch yet - this will be the first push.
    goto after_commit
)
git rev-parse --verify --quiet FETCH_HEAD >nul
if errorlevel 1 goto after_commit

git merge-base --is-ancestor FETCH_HEAD HEAD >nul 2>nul
if not errorlevel 1 (
    echo   Already up to date with the published history.
    goto after_commit
)

echo   Re-parenting this folder onto the published history...
git reset --soft FETCH_HEAD
if errorlevel 1 (
    echo   [ERROR] Could not read the published history.
    exit /b 45
)
git add -A
git diff --cached --quiet
if errorlevel 1 (
    git commit -m "%COMMIT_MSG%" >nul
    if errorlevel 1 exit /b 46
    echo   Committed on top of the published history.
) else (
    echo   Nothing differs from what is already published.
)

:after_commit

rem ----------------------------------------------------------------
rem [6/7]  Push
rem ----------------------------------------------------------------
echo [6/7] Pushing to %REPO% ...
if "%DRY_RUN%"=="1" (
    echo   [DRY RUN] git push -u origin main
    goto after_push
)
if "%FORCE_PUSH%"=="1" (
    git push --force origin main
) else (
    git push -u origin main
)
if errorlevel 1 (
    echo.
    echo   [ERROR] Push was rejected.
    echo.
    echo   The script already re-parents this folder onto the published
    echo   history, so this is unusual - it normally means someone else
    echo   pushed to main in the last few seconds.
    echo.
    echo   Try once more:  PUBLISH-V2-UPDATE.bat
    echo.
    echo   Only if that keeps failing and THIS folder is definitely the
    echo   version to keep:  PUBLISH-V2-UPDATE.bat --force-push
    echo   ^(that discards the published commit history; releases, issues
    echo    and stars are not affected^)
    exit /b 52
)

:after_push

rem ----------------------------------------------------------------
rem [7/7]  Release
rem ----------------------------------------------------------------
if "%DOCS_ONLY%"=="1" (
    echo [7/7] Skipping release ^(--docs-only^).
    goto done
)
echo [7/7] Creating the %TAG% release...
if "%DRY_RUN%"=="1" (
    echo   [DRY RUN] gh release create %TAG% with %EXE%, %SAMPLE%, %CHECKSUMS%
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
        rem Older gh builds do not know --cleanup-tag; retry without it.
        gh release delete "%TAG%" --repo "%REPO%" --yes
        if errorlevel 1 (
            echo   [ERROR] Could not remove the existing release.
            exit /b 60
        )
        git push --delete origin "%TAG%" >nul 2>nul
    )
)
gh release create "%TAG%" ^
  "%EXE%#Sakoon for Windows (single file)" ^
  "%SAMPLE%#Timing-table format example - not official" ^
  "%CHECKSUMS%#SHA-256 checksums" ^
  --repo "%REPO%" ^
  --title "%RELEASE_TITLE%" ^
  --notes-file "%NOTES%" ^
  --latest
if errorlevel 1 (
    echo   [ERROR] Release creation or asset upload failed.
    exit /b 61
)

rem Keep the repo blurb in step with the new behaviour.
gh repo edit "%REPO%" --description "%DESCRIPTION%" --homepage "%HOMEPAGE%" >nul 2>nul

:done
echo.
echo ================================================================
if "%DRY_RUN%"=="1" (
    echo  DRY RUN COMPLETE - nothing was changed.
) else (
    echo  DONE.
    echo  Repository : https://github.com/%REPO%
    if "%DOCS_ONLY%"=="0" echo  Release    : https://github.com/%REPO%/releases/tag/%TAG%
    echo  Pages site : https://%OWNER%.github.io/%REPO_NAME%/
    echo.
    echo  GitHub Pages can take a couple of minutes to rebuild.
    echo  If the site is not enabled yet, run ENABLE-SAKOON-GITHUB-PAGES.bat
)
echo ================================================================
echo.
pause
exit /b 0
