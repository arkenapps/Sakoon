# Official Timing-Table Format Guide

This guide explains how to prepare a monthly prayer-time table for Sakoon
without changing the authority's published times.

> Sakoon is not a religious authority. Use the relevant authority's original
> publication as the source of truth. The import preview and Verify view are
> safeguards, not approval from an authority.

## Recommended portable layout

Use one row for each local calendar date.

| Date | Fajr | Sunrise | Dhuhr | Asr | Maghrib | Isha |
|---|---|---|---|---|---|---|
| `YYYY-MM-DD` | `HH:MM` | `HH:MM` | `HH:MM` | `HH:MM` | `HH:MM` | `HH:MM` |

Example structure only:

```csv
Date,Fajr,Sunrise,Dhuhr,Asr,Maghrib,Isha
2099-01-01,05:15,06:35,12:20,15:40,18:05,19:25
2099-01-02,05:15,06:35,12:21,15:41,18:06,19:26
```

The year 2099 sample is synthetic and exists only to demonstrate structure.
It is not an official table and must never be activated for real use.

## Recommended headers

| Meaning | Recommended English header | Common Arabic equivalent |
|---|---|---|
| Local date | `Date` | `التاريخ` |
| Fajr | `Fajr` | `الفجر` |
| Sunrise | `Sunrise` | `الشروق` |
| Dhuhr | `Dhuhr` | `الظهر` |
| Asr | `Asr` | `العصر` |
| Maghrib | `Maghrib` | `المغرب` |
| Isha | `Isha` | `العشاء` |

Header spelling in a source file may differ. Always inspect Sakoon's mapping
preview rather than assuming that a column was recognised correctly.

## Date rules

Preferred:

- ISO date: `YYYY-MM-DD`
- one date per row;
- one calendar month per file;
- local Gregorian date matching the authority's row.

Avoid ambiguous formats such as `03/04/2026`, which can mean 3 April or
4 March depending on locale.

When an official file uses day numbers only, confirm the month and year before
import. Never infer a month from the computer's current date without checking.

## Time rules

Preferred:

- 24-hour time;
- zero-padded `HH:MM`;
- local civil time;
- no seconds unless the importer explicitly supports them;
- plain values, not formulas.

Examples:

- `05:07`
- `12:27`
- `15:49`
- `18:58`

Do not:

- convert local times to UTC;
- add daylight-saving adjustments unless the issuing authority did so;
- round values;
- remove or normalise official precaution offsets;
- copy a neighbouring city's row merely because it looks similar.

## CSV guidance

Use UTF-8 encoding so Arabic headers remain readable.

Recommended CSV characteristics:

- comma delimiter;
- one header row;
- no merged cells;
- no decorative title rows;
- no blank columns inside the table;
- no comments mixed into timing rows;
- no duplicate date rows.

Before saving from Excel, confirm that dates have not been silently converted
to another locale or serial-number display.

## Excel guidance

For `.xlsx` files:

- keep the timing table on one clearly named worksheet;
- put headers on the first data row;
- use plain cell values;
- avoid merged cells and floating text boxes over the table;
- remove hidden rows that contain alternate or obsolete schedules;
- avoid formulas linked to external workbooks;
- ensure the active sheet is the intended month.

Preserve the original authority file separately. Prepare a cleaned copy for
import rather than overwriting the source publication.

## Suggested filename

A clear filename reduces accidental reuse:

```text
authority-region-YYYY-MM.csv
authority-region-YYYY-MM.xlsx
```

Example:

```text
example-awqaf-dubai-2026-07.csv
```

Use the authority's real name in actual files. Do not label a calculated,
community-created, or copied schedule as official.

## Import checklist

Before activation:

1. Confirm the region.
2. Confirm authority, month, and year.
3. Confirm first and last dates.
4. Confirm all seven columns.
5. Spot-check at least Fajr, Dhuhr, Asr, Maghrib, and Isha against the original.
6. Check for duplicated or skipped dates.
7. Review official-versus-calculated deltas.
8. Investigate sudden jumps rather than automatically accepting them.
9. Keep the checksum and original publication reference.
10. Retain the authority's original file for audit and comparison.

## Verify-view interpretation

A small stable difference can reflect an authority's deliberate precaution
offset or local convention. It is not automatically an error.

Investigate:

- a sudden jump on one day;
- all prayers shifted by one column;
- a repeated date;
- values outside a plausible clock-time range;
- a large difference caused by the wrong city, month, timezone, or method.

The astronomical calculation is a watchdog and fallback. It does not certify
the uploaded table.

## Sharing a table format

When opening a region request, provide an official publication link and
describe the layout. Do not upload a copyrighted authority file unless you
have permission to redistribute it.
