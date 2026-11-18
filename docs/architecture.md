# Architecture notes

## What the shell guarantees

`main()` restores preferences before the first Flutter frame and injects a `PreferenceStore` and initial snapshot into Riverpod. `StrataApp` observes those preferences but retains its router. A locale or theme change therefore updates the current route instead of restarting the app or discarding navigation. The five destinations share one `ShellRoute`; the URL, selected navigation item, and page content have one source of truth.

At 980 logical pixels the shell uses a persistent directional sidebar; below that it uses a modal navigation drawer. Panels independently stack according to their available content width. The shell does not require a desktop browser or assume a left-to-right coordinate system.

## Language, typography and preferences

- English and Arabic are code-generated from ARB messages. Both use Flutter's widgets and the official Material UI library's localization delegates. On an unconfigured installation the first supported device language wins, otherwise English. The initial theme follows the device.
- `WorkspaceFormats` takes `Localizations.localeOf(context)` rather than changing a process-wide `Intl.defaultLocale`. The Arabic display profile uses `ar_EG` CLDR symbols (e.g. `١٬٢٣٤٫٥٦`), not string substitution. Dates are localized Gregorian display dates, not definitions of a business-day boundary. Currency is deliberately **not inferred** from the language.
- Manrope and Noto Sans Arabic are bundled with their SIL Open Font Licenses. There is no runtime web-font dependency. Shell strings, empty states, tooltips, preference labels and error messages all come from the catalogs.
- `SharedPreferencesAsync` stores **only** a versioned locale/theme document on the current device/browser origin. The controller applies a choice immediately and serializes saves. Failed reads fall back to defaults; failed writes keep the selected session values and show a localized warning. A later successful snapshot saves both choices and clears the warning. This is not an account profile, credential vault or financial database.

## Single-device collection directory

```text
Routes /outlets and /
  → Riverpod directory query / shared reactive overview
  → OutletRepository (mutations, watched filtered directory) / WorkspaceReader (counts)
  → SqliteOutletRepository → StrataDatabase → native file or durable browser VFS
```

- `features/outlets/domain` defines normalized input, typed validation errors, a status filter and repository contract. The immutable outlet entity and count projection are shared. No SQL, generated database classes or platform paths are exposed as presentation state.
- `shared/data/workspace_providers.dart` is the composition root for business storage: injectable connection factory, async initialization, repository lifetime and the read-only overview interface. Preferences still restore independently, so storage problems do not prevent access to Settings or a retry.
- `core/database` owns the generated Drift schema, explicit migration and conditional connection openers. `features/outlets/data` maps rows to domain entities and translates database uniqueness errors. Create, edit and status changes update watched queries; there is no `invalidate dashboard after save` convention to remember.
- The directory search/status controller lives outside locale/theme widgets. Editors own only outstanding text, progress and feedback. A confirmed status action writes only the flag and timestamp; no destructive delete or cascading history rewrite.
- `BusinessDay`, `RevenueKey`, `RevenueShift`, `LedgerAmount` and `RevenueQuery` in `shared/domain/revenue.dart` remain design primitives, not a pretend ledger. Revenue workflows and exports remain placeholders, and the dashboard explicitly says the revenue total is not available.

See [local storage](local-storage.md) for schema, platform paths, offline deployment, migration/recovery policy, exact future revenue uniqueness and the proposed manual backup process. Before the revenue phase, confirm currency/scale and accepted ranges, business-day rules and correction policy; do not introduce multi-device identities or synchronization into this single-device workflow.
