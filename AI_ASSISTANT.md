# AI Working Agreement — Faridpur Police App

## Purpose and non-goals

This repository is a thin Android WebView shell around
`https://faridpurpolice.top`. It contains **no independent business logic** —
do not add features, screens, or app-side state that duplicate or reimplement
website functionality. Native code exists only to provide: splash, WebView
hosting, permission bridging (camera/geolocation/file upload), offline
detection, pull-to-refresh, and exit confirmation.

## Mandatory reading order

1. This file.
2. `README.md` for current scope and structure.
3. SKB context-discovery (below) — required before non-trivial changes, even
   if the owner did not ask for it explicitly in chat.
4. Current `main` HEAD and recent commits/CI run status.

## SKB context-discovery contract

- Canonical knowledge repository: `soobujmiah/skb`
- Canonical entry point: `AGENT_NAVIGATION.md`
  (https://github.com/soobujmiah/skb/blob/main/AGENT_NAVIGATION.md)
- SKB carries the owner's engineering baseline, standards, and continuity —
  it is not a substitute for this repository's own source, tests, or live
  Git/CI state.
- Consult SKB before non-trivial decisions (architecture changes, dependency
  changes, permission changes, repo restructuring), retrieving only the
  minimum sufficient context for the task at hand.
- Compare SKB knowledge against live repository state; distinguish current
  fact, stale fact, inference, and recommendation. SKB recommendations are
  not authorization to act.
- If SKB is unavailable, state that limitation explicitly and proceed only
  on repository-local evidence where safe — never fabricate SKB context.

## Source-of-truth rules

- This repository's `lib/`, `pubspec.yaml`, `android_template/`, and
  `.github/workflows/` are authoritative for implementation truth.
- The live GitHub Actions run for `.github/workflows/build-apk.yml` is
  authoritative for build status — a local `flutter analyze`/`flutter build`
  claim without a corresponding CI (or physical-device) result is not
  verification.
- `android/` is never committed; see README's "Why there's no `android/`
  directory" section. Do not commit it — CI regenerates it every run.

## Toolchain and environment constraints

- **Do not run Flutter/Gradle/build or binary-asset-generation tooling
  locally in this project.** All compilation, `flutter pub get`,
  `flutter analyze`, `flutter build`, and placeholder-asset generation run
  exclusively in GitHub Actions. This is a deliberate owner constraint, not
  an incidental convenience — treat it the same as a git-safety rule.
- Author/edit Dart, YAML, XML, and workflow files as plain text locally.
  Verify them by pushing and reading the resulting CI run, not by executing
  build tooling in this environment.
- If a change requires a new binary asset (icon, image, font), either add a
  generation step to the CI workflow (Python/Pillow, matching the existing
  `tools/generate_app_assets.py` pattern) or ask the owner for the real file
  — do not generate, resize, or fetch binary assets locally. Pulling a
  source file the owner explicitly names (e.g. from their device via `adb
  pull`, scoped to that one file) and committing it unmodified is fine;
  processing it (resize, crop, recompress) is not — that belongs in CI.

## Coding and dependency rules

- Keep the WebView shell thin. New native functionality must be justified by
  something the website genuinely cannot do via standard `flutter_inappwebview`
  permission bridging (camera, geolocation, file upload are already wired).
- Pin dependency versions in `pubspec.yaml` deliberately; do not use `any`.
- Match existing Bangla UI copy style and tone for any new user-facing text
  in this app (see `lib/widgets/offline_view.dart`, `lib/widgets/exit_dialog.dart`).

## Privacy/security/data-handling rules

- The app requests camera, geolocation, and media/file permissions solely to
  bridge WebView `<input>` and JS geolocation APIs used by the website. Do
  not add analytics, tracking, or any local persistence of personal data
  without an explicit owner decision recorded in this file or `SECURITY.md`.
- Never commit secrets, signing keystores, or `key.properties` — see
  `.gitignore`.

## Testing and evidence gates

- No local build/test execution — evidence is the GitHub Actions run log and
  artifact for a given commit SHA.
- Use the evidence-state vocabulary from SKB
  (`planned → specified → implemented → CI verified → device verified →
  released`) when reporting status; do not claim `device verified` without an
  owner-supplied device result.

## Git/branch/commit rules

- `commit ≠ push`, `push ≠ merge` — do not push or open PRs without
  authorization already given for that specific action.
- Small, coherent commits; do not bundle unrelated changes.

## Session-start contract

1. Read this file and `README.md`.
2. Check `main` HEAD, recent commits, and the latest `Build APK` workflow run
   status.
3. Follow the SKB context-discovery contract above for anything non-trivial.
4. Establish the exact change, its evidence requirement, and any deferred
   work before editing.

## Session-close protocol

1. Review `git status`/`git diff`.
2. State CI status honestly — "pushed, CI pending/passed/failed at run
   `<url>`" — never claim a build passed without checking the run.
3. Update `README.md`/this file if scope, structure, or constraints changed.
4. Leave no unexplained changes; record deferred work here or in a commit
   message.
