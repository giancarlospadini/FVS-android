# La Sfida della Fede (FVS)

Catholic daily saint quote and prayer app — PWA + Android TWA.

## Structure

```
fvs-app/
├── site-files/          # PWA (deploy to GitHub Pages)
│   ├── index.html       # Main SPA
│   ├── manifest.json    # PWA manifest
│   ├── sw.js            # Service worker
│   ├── offline.html     # Offline fallback
│   └── .well-known/     # Digital Asset Links
├── app/                 # Android TWA module
├── build.gradle         # Root Gradle config
├── settings.gradle
└── gradle/
```

## PWA Deployment (GitHub Pages)

1. Push the `site-files/` directory contents to the `gh-pages` branch (or configure Pages to serve from `site-files/` on `main`).
2. Generate app icons (192×192 and 512×512 PNG) and place them in `site-files/icons/`.
3. The PWA fetches daily saints from: `https://www.fede-vita-speranza.it/wp-json/wp/v2/posts?per_page=7&_embed`

## Android TWA Build

### Prerequisites
- Android Studio or command-line SDK (API 34)
- Java 8+

### Build
```bash
./gradlew assembleRelease
```

### Signing & Asset Links
1. Generate a signing key:
   ```bash
   keytool -genkey -v -keystore fvs-release.keystore -alias fvs -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Get the SHA-256 fingerprint:
   ```bash
   keytool -list -v -keystore fvs-release.keystore -alias fvs | grep SHA256
   ```
3. Update `site-files/.well-known/assetlinks.json` with the fingerprint.
4. Deploy the updated `assetlinks.json` to GitHub Pages.

## Data Source

Content comes from the WordPress REST API at [fede-vita-speranza.it](https://www.fede-vita-speranza.it/).

## Colors
| Role       | Hex       |
|------------|-----------|
| Primary    | `#1a237e` |
| Accent     | `#c9a84c` |
| Background | `#f5f0e8` |

## License

Private — © Fede Vita Speranza
