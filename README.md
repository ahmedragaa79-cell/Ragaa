# Ragaa
Roads map

## Strata · Outlets Revenue Management System

Strata manages collection outlets on a **single device**, online or offline. The directory starts empty. Add an outlet by code and name, search it, edit it, or change its status without losing its history. The dashboard follows the real total, active and inactive counts. Revenue recording, monetary totals and reports are not available yet. English/Arabic and light/dark preferences apply immediately.

[Storage, migrations, platform locations & recovery](docs/local-storage.md) · [Architecture](docs/architecture.md) · [Historical Phase 1 inspection and renders](docs/initialization.md)

### Run from a clean checkout

Use **Flutter 3.50.0 stable** (Dart 3.14.0). The application lockfile is checked in. Start in the repository root:

```sh
flutter doctor -v
flutter pub get --enforce-lockfile
flutter gen-l10n
flutter devices
flutter run -d chrome          # or an available device ID
```

For a local web release with the renderer served alongside the application:

```sh
flutter build web --release --no-web-resources-cdn
python3 tool/prepare_offline_web.py
python3 -m http.server 8080 --directory build/web
```

Use HTTPS (or loopback HTTP), not `file://`. Hash routes such as `/#/outlets` work without rewrites. The packaged release includes the engine, fonts, SQLite Wasm/worker and an offline service worker. Complete the first install online. Return to the **same origin and browser profile**; clearing site data can erase the directory. See the [browser storage contract](docs/local-storage.md#offline-browser-delivery).

### Host requirements

| Target | Build host and tooling | Example |
| --- | --- | --- |
| Android | Linux, macOS or Windows; Android SDK, accepted licenses, JDK 17-compatible toolchain. Template minimum API 24, compile SDK 36. | `flutter build apk --debug` |
| iOS | **macOS** with compatible Xcode, command-line tools and simulator runtime. Signing/team configuration is required for distribution to devices. Template target: iOS 15+. | `flutter build ios --simulator --debug` |
| Windows | **Windows** with Visual Studio's Desktop development with C++ workload and Windows SDK. Enable Developer Mode if plugin symlinks require it. | `flutter build windows --debug` |
| macOS | **macOS** with Xcode and desktop tooling. Template deployment target: macOS 12+. Signing/notarization is separate from a debug build. | `flutter build macos --debug` |
| Linux | **Linux** with clang, CMake, Ninja, pkg-config, GTK 3 and C++ development headers. A graphical session is needed to run the desktop app. | `flutter build linux --debug` |
| Web | Any Flutter-supported development host; a modern browser for interactive testing or an HTTP server for the release bundle. | `flutter build web --release --no-web-resources-cdn` |

Use `flutter doctor -v` on the intended host. Run native builds with **Flutter's CLI** so it prepares the generated plugin registrants, Android wrapper, and Apple Swift package metadata. The checked-in application IDs are development placeholders; do not publish them or use Android's debug signing for distribution.

### Project map

```text
lib/
  main.dart                      # restore device preferences, inject dependencies
  app/
    app.dart                     # MaterialApp.router and locale/theme binding
    router/                      # destinations and persistent shell route
    theme/                       # light/dark palettes, typography, accent roles
    localization/                # ARB catalogs, generated delegates, formatters
  core/database/                 # versioned Drift schema, native/web openers
  core/widgets/                  # shared surface and type primitives
  features/
    dashboard/presentation/
    outlets/{domain,application,data,presentation}/
    revenue/presentation/
    reports/presentation/
    settings/{application,data,presentation}/
  shared/
    domain/                      # ledger entities, queries, read contract
    application/                 # reactive workspace counts
    data/                        # shared database/repository injection
    presentation/                # sidebar/drawer, toolbar, common page layout
android/ ios/ linux/ macos/ web/ windows/    # real Flutter platform hosts
assets/                          # local typefaces + OFL licenses, brand, artwork
test/                            # widget, domain, formatting and preference tests
docs/                            # architecture, verification and rendered previews
```

### Review checks

```sh
flutter pub get --enforce-lockfile
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test
```

Native tests use memory databases, temporary SQLite files and independent connections. The widget suite includes desktop and compact layouts, validation/cancel, all four empty states, both directions/themes, live counts and storage failure/retry. No test opens a real user directory. The original dashboard renders in `docs/previews/` are Phase 1 history, not current balances.

### Extend the shell

- Add user-facing text to **both** `lib/app/localization/app_en.arb` and `app_ar.arb`, then run `flutter gen-l10n`. Use `context.l10n`, `context.formats` and directional alignment/padding in widgets. Never edit generated translations.
- Put workflow logic in its feature, not in a navigation widget. Only move concepts into `shared/domain` when more than one module needs them.
- Keep revenue additions behind their own domain/repository contract. The shared overview currently projects only real outlet counts. Preferences storage is not a ledger.

CI checks lockfile resolution, generated Drift bindings, locale generation, SDK formatting, analysis, tests and per-host builds. The **packaged Chrome release** test restarts a disposable browser profile and edits an outlet offline. To repeat after the web build/packaging steps above, install `playwright==1.65.2` in a temporary Python environment and run `python tool/check_web.py` with Chrome on `PATH`. No Playwright dependency ships in the Flutter application.
