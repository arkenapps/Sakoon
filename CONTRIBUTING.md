# Contributing to Sakoon

Thank you for helping improve Sakoon.

This repository is a public home for documentation, verified table-format
knowledge, translations, issue tracking, and official release binaries. The Go
application source code is private and is not accepted through this repository.

## Contributions we welcome

### Bug reports

Use the bug-report form and include:

- the exact Sakoon release;
- Windows version;
- steps that reproduce the problem;
- expected and actual behaviour;
- whether the problem affects timing, import, audio, the app window, tray
  behaviour, startup,
  sleep/wake, or display;
- sanitised screenshots or logs where useful.

Before uploading a log, remove names, usernames, paths, table contents, and
other private information.

### Region and authority-table requests

Use the region-table request form. Provide:

- country and city/emirate/region;
- authority name;
- official publication link;
- month and year;
- original format;
- a description of the header and date/time layout.

A request does not guarantee that ArkenApps can redistribute the authority's
file. Copyright and reuse conditions still apply.

### Documentation corrections

Small corrections may be submitted as pull requests. Keep changes narrowly
focused and explain why the correction is needed.

### Translations

Translation contributions should preserve these meanings:

- calculated times are **unofficial**;
- Sakoon is **not a religious authority**;
- the mosque and relevant authority take precedence;
- privacy and audio-recovery statements must not be exaggerated.

Open an issue before translating a large section so terminology can be agreed.

## Contributions we do not accept here

- Go source-code pull requests;
- decompiled or reverse-engineered application code;
- unofficial binaries, installers, forks, mirrors, or download links;
- secret keys, credentials, certificates, or private signing material;
- scraped tables presented as official without a verifiable authority source;
- religious rulings or debates unrelated to a reproducible software issue;
- feature requests that would require hidden telemetry or cloud tracking.

## Timing-table contribution checklist

Before submitting a table-format example:

1. Confirm the issuing authority.
2. Confirm the exact month, year, and region.
3. Preserve the published times; do not add or remove precaution minutes.
4. Do not convert local time to UTC.
5. Remove decorative layout only when necessary for import.
6. State every transformation you made.
7. Verify that dates remain aligned with the correct prayer-time row.
8. Confirm that you have permission to share the file or share only a format
   description and official link.

## Pull requests

A useful documentation pull request should:

- have a clear title;
- change one subject;
- use plain Markdown;
- preserve the project's humble, non-authoritative tone;
- avoid adding external trackers or remote scripts;
- pass link and spelling checks where available.

By submitting content, you confirm that you have the right to contribute it
and grant ArkenApps permission to use, edit, display, and redistribute that
contribution as part of Sakoon's documentation and support materials.

## Questions

Use GitHub Issues for public support questions that do not contain sensitive
information. Security issues must follow [SECURITY.md](SECURITY.md).
