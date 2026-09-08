# Faridpur Police App

Official Android WebView wrapper app for Faridpur District Police
(`https://faridpurpolice.top`), built with Flutter.

## Status

`implemented` (source complete) → not yet CI-verified / device-verified. See
the latest run of **Build APK** under the Actions tab for build status.

## Scope

- Single-purpose WebView shell around the district police website.
- Bangla-language splash screen, offline screen, pull-to-refresh, and exit
  confirmation, per the product spec below.
- Android only. No native business logic — all content and functionality
  live on the website; this app only provides the native chrome around it
  (splash, connectivity handling, permission bridging, exit UX).

## Product spec

| Area | Behavior |
|---|---|
| App name | Faridpur Police |
| Package | `com.onskillit.faridpurpolice` |
| Primary color | `#0A3D91` |
| Splash | 3s, logo + Bangla title + "Powered by Onskill-iT" subtitle |
| Main screen | Fullscreen `flutter_inappwebview`, JS/geolocation/camera/file upload enabled |
| Pull to refresh | Native pull-to-refresh, brand-colored indicator |
| Offline | Full-screen Bangla offline message with retry button |
| Back button | Confirms exit with a Bangla dialog (after exhausting in-site WebView history) |

## Why there's no `android/` directory in this repo

The Android platform folder (Gradle wrapper, generated Kotlin
`MainActivity`, manifest, etc.) is intentionally **not committed**. It is
scaffolded fresh by `flutter create --platforms=android` inside CI on every
build, then two hand-written overrides are applied:

- `android_template/AndroidManifest.xml` — adds the app label and the
  camera/geolocation/media permissions the WebView needs.
- `android_template/launch_background.xml` — matches the native launch
  background to the app's primary color so there's no white flash before the
  Flutter splash screen appears.

This avoids hand-maintaining fragile, Flutter-SDK-version-coupled Gradle
boilerplate; it always matches whatever Flutter version the workflow pins.

## Assets

`assets/icon.png` (launcher icon) and `assets/logo.png` (splash screen) are
**placeholder** artwork — a simple generated shield glyph, not the
department's real emblem — generated at CI build time by
`tools/generate_placeholder_assets.py` (not committed as binary files). To
ship with the official Faridpur Police emblem:

1. Replace the placeholder script's output by committing real
   `assets/icon.png` (square, ≥1024×1024) and `assets/logo.png` files, and
   remove the "Generate placeholder icon/logo" step from
   `.github/workflows/build-apk.yml`, **or**
2. Keep the CI-generation step but point it at the real artwork files
   instead of the procedural shield.

## Build

All builds run on GitHub Actions (`.github/workflows/build-apk.yml`) —
push to `main`, open a PR, or trigger the workflow manually
(`workflow_dispatch`). The release APK is published as a downloadable
workflow artifact named `faridpur-police-release-apk`.

There is no local build step in this project's workflow by design.

## Repository structure

```text
lib/
  main.dart               # App entry point, MaterialApp
  theme/app_colors.dart   # Brand color constants
  screens/
    splash_screen.dart    # 3s branded splash
    webview_screen.dart   # Fullscreen WebView + offline/pull-to-refresh/exit
  widgets/
    offline_view.dart     # Offline state UI
    exit_dialog.dart      # Exit confirmation dialog
android_template/         # Hand-written overrides applied after `flutter create` in CI
tools/                    # CI-only placeholder asset generator (Python/Pillow)
.github/workflows/        # CI build pipeline
```

## AI agent continuity

See `AI_ASSISTANT.md` for the working agreement, SKB context-discovery
path, and session contract for any AI agent picking up this project.
