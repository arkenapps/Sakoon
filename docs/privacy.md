# Privacy and Local Data

Sakoon is designed as a local-first Windows utility.

## Network behaviour

The application interface runs inside the app's own window; no network
ports are opened. Sakoon does not require
a cloud account, advertising service, analytics platform, or telemetry
collector for its core operation.

A loopback address is accessible only from the local machine under normal
network configuration. Security reports involving unintended exposure beyond
loopback should be reported privately under [SECURITY.md](../SECURITY.md).

## Data kept locally

Depending on the installed release and enabled features, local data can include:

- selected region and preferences;
- mute lead-in and mute-window settings;
- imported timing tables;
- table versions and checksums;
- recovery state needed to restore audio safely;
- local diagnostic information;
- theme and startup preferences.

## User control

Users should be able to read, back up, replace, or remove their local Sakoon
data. Exact locations may vary by release and are shown in the application or
release documentation.

## What Sakoon does not need

Sakoon's stated core design does not require:

- an ArkenApps account;
- contact lists;
- browser history;
- microphone recordings;
- cloud prayer-time lookups;
- behavioural advertising;
- sale of user information.

## Diagnostic sharing

Never upload an entire data folder publicly. Before sharing a diagnostic file,
remove:

- Windows usernames and machine names;
- personal folder paths;
- private authority documents;
- meeting information;
- tokens, credentials, or unrelated application data.

## Timing-source privacy

Official tables uploaded by the user remain local. Users are responsible for
their right to use or redistribute those files.

## Changes

Material privacy changes should be documented in release notes. A future
optional network feature must be clearly disclosed and should not silently
change the local-first nature of the application.
