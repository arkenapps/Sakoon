# Changelog

All notable public Sakoon releases are documented here.

## [Unreleased]

- Public documentation and repository preparation.

## [2.0.0] — Standalone desktop app

### Changed

- Rebuilt as a single-exe native desktop application (Wails). The interface
  now renders in its own app window instead of a browser tab.
- No network ports are opened at all: the previous `127.0.0.1` loopback
  interface has been removed entirely.
- Single-instance protection now uses an OS-level app lock instead of the
  loopback port. Launching Sakoon while it is already running brings the
  existing window to the front.
- Closing the window hides Sakoon to the system tray; the audio guard keeps
  running. Quit is available from the tray menu.
- The tray "Open dashboard" action is now "Open Sakoon" and shows the app
  window.

### Unchanged

- All timing, mute/unmute, verification, recovery, snooze, and Jumu'ah behaviour.
- The interface itself, including the Night, Pearl, Oasis, and Amber themes.
- Data location (`%LOCALAPPDATA%\Sakoon`): settings, uploaded tables, and
  logs from v1 carry over automatically.
- Automatic, visible start-with-Windows shortcut created on first run; no
  administrator rights at any point.

## [1.0.0] — Initial public release

### Added

- Windows system-tray application.
- Official CSV/XLSX timing-table import.
- Versioned and checksummed timing data.
- Local astronomical fallback labelled unofficial.
- Official-versus-calculated verification view.
- Configurable mute lead-in and silent windows.
- Jumu'ah-aware Friday window.
- Tray snooze options.
- Crash-recovery audio restoration.
- Sleep/wake stale-event protection.
- Night, Pearl, Oasis, and Amber themes.
- Local-first operation without accounts, ads, or telemetry.

[Unreleased]: https://github.com/arkenapps/Sakoon/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/arkenapps/Sakoon/releases/tag/v2.0.0
[1.0.0]: https://github.com/arkenapps/Sakoon/releases/tag/v1.0.0
