# Sakoon standalone installer (Inno Setup)

Self-contained folder that builds **`Sakoon-Setup.exe`** — a per-user
installer for Sakoon. It carries its own icon and wizard artwork under
`assets\`, so it doesn't depend on the app source tree.

## Contents

```
Sakoon.iss              the Inno Setup script
BUILD-INSTALLER.bat     one-click build (finds iscc, checks the exe, compiles)
assets\
  Sakoon.ico            multi-resolution icon (16 → 256 px) for the setup,
                        shortcuts, and Add/Remove Programs entry
  WizardImage.bmp       164×314 welcome/finish side banner (logo on Night navy)
  WizardSmallImage.bmp  55×55 header badge for interior pages
  sakoon-256/512/1024.png   PNG logos, for reference or a desktop.ini icon
README.md               this file
```

You add two things at build time:

- **`Sakoon.exe`** — the built v2.0.1 app, copied into this folder.
- optionally **`README-FIRST.txt`** and **`LICENSE.txt`** — bundled into the
  install if present.

## Build

1. Install Inno Setup 6:

   ```
   winget install JRSoftware.InnoSetup
   ```

2. Build the app (in the Sakoon source): `build.bat`, then copy the new
   `Sakoon.exe` into this folder next to `Sakoon.iss`.

3. Double-click **`BUILD-INSTALLER.bat`** (or run `iscc Sakoon.iss`).

   Output: `output\Sakoon-Setup.exe`

## What the installer does

- Installs to `%LOCALAPPDATA%\Programs\Sakoon` — **per-user, no admin, no UAC.**
- Start Menu shortcut + uninstaller entry, both using the Sakoon icon.
- Desktop shortcut — only if the user ticks it (unchecked by default).
- **Startup shortcut in `shell:startup` — checked by default.** Creating the
  Windows-startup shortcut is the whole reason to use the installer instead of
  the portable zip, so the task is ticked by default; the user can still untick
  it. This is the one and only path by which Sakoon ends up in Windows startup —
  the app itself never writes one. Windows then lets the user manage it under
  Settings ▸ Apps ▸ Startup.
- Leaves user data in `%LOCALAPPDATA%\Sakoon` on uninstall, so a reinstall
  keeps settings, tables, and logs.

## Important: this does not fix Defender or SmartScreen

An installer wraps the **same unsigned `Sakoon.exe`**, and `Setup.exe` is
itself unsigned, so:

- Defender may still flag the inner exe by its ML profile.
- SmartScreen will still show "Windows protected your PC" for the unsigned
  `Setup.exe` until it earns reputation.

The real fixes remain, in order of effectiveness:

1. **Submit the exact detected exe to Microsoft** (free; often cleared within
   days) — do this on each release until signing is in place.
2. **Code-sign** both `Sakoon.exe` and `Setup.exe`. An EV certificate clears
   SmartScreen almost immediately; an OV certificate builds reputation over
   time. SignPath Foundation offers free signing to qualifying open-source
   projects.

The installer is distribution polish and gives clean install/uninstall plus a
proper, user-consented startup option — it is not, on its own, a detection fix.

## Replacing the artwork

If you want different wizard art, drop in your own BMPs at exactly
`164×314` (`WizardImage.bmp`) and `55×55` (`WizardSmallImage.bmp`), 24-bit,
and rebuild. The icon can be replaced with any `.ico` named `Sakoon.ico`.
