# Sakoon GitHub repo — v2.0.0 content sweep

`Sakoon_Repo_v2/` is the **complete repository**, not a patch set. Replace your
local `Sakoon` repo folder with it (or copy it over the top) and publish.

## How to publish — the short version

```bat
cd Sakoon_Repo_v2
PUBLISH-V2-UPDATE.bat --dry-run     rehearse, changes nothing
PUBLISH-V2-UPDATE.bat               push docs + cut the v2.0.0 release
```

Before the live run: build the app (`build.bat` in the private source folder)
and copy the new `Sakoon.exe` into `release-assets\`. If you only want the docs
live now and the release later, use `--docs-only`.

`START-HERE.bat` also has the new options as menu items **6** (live) and
**7** (dry run).

### What the script does

1. Refuses to run if any private Go source or secret-like file is in the folder.
2. Checks `git` and `gh` are installed and signed in.
3. **Reads the version resource inside `release-assets\Sakoon.exe` and stops if
   it does not say 2.0.0.** Your oldest footgun on this project is testing or
   shipping yesterday's binary — this closes it at the publish step too.
4. Regenerates `SHA256SUMS.txt`.
5. Commits, then **re-parents this folder on top of the already-published
   history** so the push is a normal fast-forward (see below).
6. Pushes to `main`.
7. Creates the `v2.0.0` release with the exe, sample table, and checksums
   attached, notes from `releases/v2.0.0.md`, marked latest. Asks first if
   `v2.0.0` already exists. Then updates the repo description and homepage.

### About that push rejection

Your folder is a fresh `git init`, so it shares no history with the `main`
already on GitHub — a plain push can only be rejected. The fix is not a force
push. The script now fetches `origin/main` and runs `git reset --soft` to give
this exact folder a real parent commit: the staged tree is untouched, it just
lands on top of the v1.0.0 commit instead of floating free.

Result: ordinary fast-forward push, v1.0.0 history preserved, repository
contents identical to this folder, files that existed only on GitHub recorded
as deletions. I tested this against a simulated already-published repo before
shipping it. `--force-push` is still there as a last resort but you should not
need it.

---

## Every content change

### "Fade" is gone — the app mutes

**Zero** occurrences of fade/fades/fading remain anywhere in the repo. Fixed in:

| File | Was | Now |
|---|---|---|
| `docs/index.html`, `docs/404.html` | 8 mentions each — meta description, OG description, hero paragraph, "Gentle audio fade" trust badge, story copy ×2, settings caption, "Fade, never hard-cut" rule card | mute wording throughout; the trust badge is now "Your volume untouched — it mutes; it never moves the slider", and rule 01 is "Mute, never re-level" |
| `docs/about.md` | "gently fades your audio… and fades back", "Fade, don't cut — audio ramps down over ~5 s" | mute/unmute; rule 1 is now "Mute the endpoint, never move the slider" |
| `docs/troubleshooting.md` | heading "Audio did not fade" | "Audio did not mute" |
| `docs/privacy.md` | "fade and mute-window settings" | "mute lead-in and mute-window settings" |
| `README.md` | how-it-works step 2, "Fade, never hard-cut" bullet, feature-table Audio row | mute wording |
| `CHANGELOG.md` | v1.0.0 entry "Configurable audio fade" | "Configurable mute lead-in" |
| `releases/v1.0.0.md` | "gently fades system audio", "Audio fades instead of cutting abruptly" | mute wording |
| `.github/ISSUE_TEMPLATE/bug_report.yml` | dropdown option "Audio fade or mute" | "Audio mute" |
| `publish.bat`, `PUBLISHING.md` | repo description string | "…desktop app that mutes PC audio…" |

I corrected the historical v1.0.0 entries too, since the shipped v1.0.0 was the
mute build — the old copy was describing a version that never existed.

### Architecture — standalone app, no ports

- `README.md` — "tray app" → "desktop app"; privacy row now reads "no open
  network ports"; new interface row; install steps cover the app window, tray,
  and the automatic startup shortcut; WebView2 requirements note added.
- `SECURITY.md` — scope item is now "any network listener at all", since v2
  opens none.
- `CHANGELOG.md` — new `[2.0.0]` section covering the native window, the removed
  loopback interface, OS-level single-instance lock, and close-to-tray.
- `releases/v2.0.0.md` — new release notes.
- `docs/about.md`, `docs/privacy.md` — 127.0.0.1 wording removed.
- `docs/index.html` / `docs/404.html` — trust badge is "No open network ports";
  feature card is "Native app window"; tray gallery caption says "Open the
  Sakoon window"; **two new FAQ entries** ("Does Sakoon open a browser or a local
  web server?" and "What happens when I close the window?"); eyebrow and version
  chip now say v2.0.0.
- `docs/troubleshooting.md` — first check now warns that a hidden window means
  Sakoon is in the tray, not stopped.
- `CONTRIBUTING.md`, `REPOSITORY-CHECKLIST.md`, `assets/screenshots/README.md`,
  `bug_report.yml` version placeholders — v2 wording.

### Distribution

The site's download buttons pointed at `Sakoon.zip`, but `publish.bat` only ever
uploaded `Sakoon.exe` — a broken link since v1. All three buttons on both pages
now point at `Sakoon.exe`, and the download panel says one self-contained file
instead of "extract it".

### Removed from `release-assets/`

The **v1.0.0 `Sakoon.exe` (9.4 MB) and `Sakoon_App.zip` (4 MB)**. Leaving a stale
binary next to a new release is exactly how the wrong file gets uploaded, and the
publisher's version check would have rejected it anyway. `PUT-Sakoon.exe-HERE.txt`
now explains what belongs there and `.gitignore` covers the zip.

### Added

- `PUBLISH-V2-UPDATE.bat` — the updater described above.
- `PUBLISHING.md` — new section at the top for updating an already-published
  repo; the first-time instructions are kept below it.
- `START-HERE.bat` — menu options 6 and 7.
- `releases/v2.0.0.md`, and `FOLDER-TREE.txt` / `repository-manifest.json`
  regenerated to match the folder exactly.

---

## Two things worth a look before you push

1. **Screenshots are still v1.** `assets/screenshots/*.png` and
   `docs/sakoon-assets/*.webp` show the old browser-tab UI with the classic
   Windows title bar and the `ARMED` pill. Fresh captures of the frameless
   window would be worth taking before or shortly after publishing.
2. **`docs/index.html` still says the source code is not published.** Still true
   — just confirming that's intentional.
