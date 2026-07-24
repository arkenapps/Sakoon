# Security Policy

Sakoon changes system audio state and stores local timing information, so
security and predictable recovery matter.

## Supported versions

Security fixes are provided for the latest public release.

| Version | Supported |
|---|---|
| Latest stable release | Yes |
| Older releases | Best effort only |
| Unofficial or modified copies | No |

Always reproduce a problem using the latest official binary from:

`https://github.com/arkenapps/Sakoon/releases/latest`

## Report a vulnerability privately

**Do not open a public GitHub issue for a suspected vulnerability.**

Send a private report to:

`arkenapps@outlook.com`

Use the subject:

`[SAKOON SECURITY] Short description`

Include only what is necessary:

- Sakoon version;
- Windows version and architecture;
- clear reproduction steps;
- expected and observed behaviour;
- security impact;
- whether audio state, local files, startup behaviour, or the local web
  interface is involved;
- a minimal proof of concept, if safe;
- your preferred contact details.

Do not include real prayer tables, personal names, Windows usernames, machine
names, private paths, access tokens, or unrelated logs.

## Response process

ArkenApps will aim to:

1. acknowledge a complete report;
2. reproduce and assess the issue;
3. keep the reporter informed when practical;
4. prepare a fix or mitigation;
5. coordinate public disclosure after users can update.

No fixed response or remediation deadline is guaranteed.

## Scope priorities

Reports are especially useful when they concern:

- any network listener or network exposure at all (Sakoon v2 is designed to
  open no network ports);
- arbitrary file read or write;
- command execution;
- unsafe startup persistence;
- tampering with timing-table integrity or checksum handling;
- failure to restore audio after a crash;
- privilege escalation;
- release-binary or update-channel integrity.

General bugs, unsupported spreadsheet layouts, feature requests, and timing
disagreements should use the normal issue templates unless they create a
security impact.

## Safe-harbour intent

Good-faith research that avoids privacy violations, data destruction, service
disruption, social engineering, and unnecessary access will be handled
constructively. This statement is not a waiver of legal rights and does not
authorise testing against systems you do not own or have permission to test.
