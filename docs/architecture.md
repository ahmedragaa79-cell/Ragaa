# Architecture notes

## What the shell guarantees

`main()` restores preferences before the first Flutter frame and injects a `PreferenceStore` and initial snapshot into Riverpod. `StrataApp` observes those preferences but retains its router. A locale or theme change therefore updates the current route instead of restarting the app or discarding navigation. The five destinations share one `ShellRoute`; the URL, selected navigation item, and page content have one source of truth.

At 980 logical pixels the shell uses a persistent directional sidebar; below that it uses a modal navigation drawer. Panels independently stack according to their available content width. The shell does not require a desktop browser or assume a left-to-right coordinate system.

## Language, typography and preferences

- English and Arabic are code-generated from ARB messages. Both use Flutter's widgets and the official Material UI library's localization delegates. On an unconfigured installation the first supported device language wins, otherwise English. The initial theme follows the device.
- `WorkspaceFormats` takes `Localizations.localeOf(context)` rather than changing a process-wide `Intl.defaultLocale`. The Arabic display profile uses `ar_EG` CLDR symbols (e.g. `١٬٢٣٤٫٥٦`), not string substitution. Dates are localized Gregorian display dates, not definitions of a business-day boundary. Currency is deliberately **not inferred** from the language.
- Manrope and Noto Sans Arabic are bundled with their SIL Open Font Licenses. There is no runtime web-font dependency. Shell strings, empty states, tooltips, preference labels and error messages all come from the catalogs.
- `SharedPreferencesAsync` stores **only** a versioned locale/theme document on the current device/browser origin. The controller applies a choice immediately and serializes saves. Failed reads fall back to defaults; failed writes keep the selected session values and show a localized warning. A later successful snapshot saves both choices and clears the warning. This is not an account profile, credential vault or financial database.

## Ledger boundary, without choosing a database

```text
Dashboard presentation → overviewProvider → WorkspaceReader
                                                  ↑
                                       EmptyWorkspaceReader
```

`WorkspaceReader` exposes outlet listing, filtered revenue history and a dashboard projection. Only the overview is consumed in the shell. Reading an aggregate projection will not require loading an entire ledger into memory. Loading and failure states are distinct from a successful, empty result. The default adapter returns empty immutable lists and zero totals. It contains no write methods or sample business records.

- **Outlet:** stable ID, display name and active flag. Historical revenue can reference a stable outlet identity regardless of future name/status changes.
- **RevenueRecord:** stable record ID; natural key of `(outletId, BusinessDay, RevenueShift)`; scaled integer amount; optional future recorder ID. A `BusinessDay` compares calendar components without converting the supplied day across time zones. Both shifts are explicitly modeled; no morning/evening times have been invented.
- **LedgerAmount:** integer units and explicit precision, not a stored `double`. The empty dashboard's `0.00` is a display convention, not a mandated currency or two-decimal validation rule. Formatting splits integer and fractional parts without binary floating-point division. Confirm valid ranges (including JavaScript's safe integer range) before accepting monetary input.
- **RevenueQuery:** immutable outlet selection and optional inclusive day bounds. Empty selection means all outlets; reversed ranges are rejected. A database adapter can translate this into indexed queries later.

The natural key **describes** duplicate prevention; it is not yet an implemented database constraint. No records can be created in this release. When writes are introduced, require transactional uniqueness in the adapter as well as user feedback in the entry form. Don't rely on a preliminary read or a disabled save button alone.

## Before the first real write

| Decision to confirm | Why it matters |
| --- | --- |
| Single device, offline-first, or shared online workspace? Which hosts must retain data offline? | Determines storage/encryption, migration, backup and recovery requirements. |
| Which currency, precision, accepted ranges and rounding rules apply? | Determines input validation and which totals can be aggregated. |
| What defines a business day and when can a closed shift be corrected? | Determines the calendar key and correction/audit behavior. |
| How are users and outlets identified across devices? What happens when offline edits conflict? | Determines the eventual sync protocol, write revisions and conflict handling. |

**Next slice:** agree on these constraints, select a persistence adapter in an architecture decision record, and implement outlet create/edit/activate/deactivate with repository contract tests. Revenue writes, reconciliation, reports, PDF/XLSX export and user management remain separate future tasks.
