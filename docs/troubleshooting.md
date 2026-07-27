# Troubleshooting

## Audio did not mute

Check:

1. Sakoon is running — check the system tray. Closing the window only hides
   Sakoon to the tray, so a hidden window does not mean it stopped.
2. The selected date and region are correct.
3. The active timing source is the intended official table.
4. The mute window has not been snoozed.
5. The current Windows output device is the expected endpoint.
6. The event was not already stale after sleep or wake.
7. The user did not manually override the mute window.

Include the Sakoon version and Windows version in a bug report.

## Audio did not restore

Do not repeatedly toggle settings.

1. Reopen Sakoon so crash-recovery logic can inspect stored restore state.
2. Confirm the current Windows output device.
3. Check whether the user or another audio utility changed mute or volume.
4. Record the exact sequence, including sleep, docking, Bluetooth, or headphone
   changes.
5. Report the problem if restoration remains incorrect.

A repeatable failure to restore audio is treated as a high-priority defect.

## A missed azaan played after wake

Sakoon is intended not to replay stale events after sleep. Record:

- sleep time;
- wake time;
- scheduled prayer time;
- timing source;
- Sakoon version;
- Windows power state used.

Open a bug report with sanitised details.

## Imported columns are wrong

Do not activate the table.

- compare the preview with the original publication;
- check date locale;
- remove decorative rows and merged cells from a copy;
- use canonical headers from the table-format guide;
- confirm that Dhuhr, Asr, Maghrib, and Isha have not shifted one column;
- inspect duplicate or blank dates.

## Calculated and official times differ

A stable difference can be deliberate. Authorities may use precaution offsets,
local longitude conventions, or a different method.

Investigate large or sudden changes, but do not "correct" the authority's
published values using Sakoon's calculation.

## Windows warns about the executable

New or unsigned Windows applications can trigger reputation warnings.

- download only from `https://github.com/arkenapps/Sakoon/releases`;
- compare SHA-256 with `SHA256SUMS.txt`;
- do not download Sakoon from mirrors or attachment sites;
- report a hash mismatch privately.

## Still need help?

Use the repository's issue templates. Remove personal information and private
file content before posting.
