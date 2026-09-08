# Security

## Scope

This app is a WebView shell that loads a single remote origin,
`https://faridpurpolice.top`, and bridges three sensitive Android
permissions to it: camera, geolocation, and media/file access (for
`<input type="file">` uploads). There is no local data store, no
analytics SDK, and no server the app talks to other than that origin.

## Threat model notes

- **Remote content trust**: because the app grants the loaded origin camera,
  geolocation, and file-upload access by default
  (`lib/screens/webview_screen.dart`), the app implicitly trusts
  `faridpurpolice.top` to request these responsibly. If the app is ever
  pointed at a different or attacker-controlled origin, these permissions
  must be re-reviewed before shipping.
- **Cleartext traffic**: the app only loads `https://` URLs; no cleartext
  HTTP exception is configured.
- **WebView JS**: JavaScript is enabled (required by the site) — this is a
  first-party, owner-controlled origin, not arbitrary user-supplied content.

## Reporting

This is an internal project maintained via `soobujmiah/skb`-tracked
workflow, not a public bug bounty program. Report security concerns to the
repository owner directly rather than filing a public issue with exploit
details.

## Data handling

- No personally identifiable information is collected, stored, or
  transmitted by the native app layer itself; any data collection happens
  web-side on `faridpurpolice.top` and is out of this repository's scope.
- Do not add local logging of camera, location, or uploaded-file contents.
