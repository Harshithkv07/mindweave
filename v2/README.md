# MindWeave v2

A calm, frontend-only rebuild of MindWeave. React + Vite + Tailwind v4.
No backend, no network calls — everything persists in `localStorage`.

## Run

```bash
npm install
npm run dev
```

Then open http://localhost:5173.

## Install it as an app on your phone

Both devices must be on the same Wi-Fi.

```bash
npm run dev -- --host
```

Open the printed `http://192.168.x.x:5173` address on your phone, then
**Add to Home Screen**. The manifest makes it launch fullscreen with its own
icon — no browser chrome.

For a permanent install, `npm run build` produces a static `dist/` you can drop
on any host (Netlify, Vercel, GitHub Pages).

## Layout

```
src/
  lib/
    store.jsx      localStorage-backed state + derived metrics
    adaptive.js    the rule-based difficulty engine, carried from v1
    speech.js      Web Speech synthesis + the five care scripts
  components/      Blob mascot, icons, glass primitives, nav, trend chart
  screens/         one file per screen
  App.jsx          push/pop navigation stack
```

## What v1 feature maps where

See `FEATURES.md` for the full inventory extracted from v1.

---

## Building the Android APK

The web app is wrapped with [Capacitor](https://capacitorjs.com). The whole
build is bundled into the APK — fonts included — so the app works with no
network connection at all.

### Prerequisites

- Android SDK (platform 34+, build-tools 35+)
- JDK 17 or newer. The JDK that ships with Android Studio works:
  `C:\Program Files\Android\Android Studio\jbr`
- `android/local.properties` pointing at your SDK. **Use forward slashes** —
  a `.properties` file treats `\U`, `\A` etc. as escape sequences and will
  silently mangle a Windows path:
  ```
  sdk.dir=C:/Users/<you>/AppData/Local/Android/Sdk
  ```

### Build

```bash
npm run build          # bundle the web app into dist/
npx cap sync android   # copy dist/ into the native project
cd android
JAVA_HOME="/c/Program Files/Android/Android Studio/jbr" ./gradlew assembleDebug
```

The APK lands at `android/app/build/outputs/apk/debug/app-debug.apk`.

### Regenerating icons and splash

Sources live in `assets/*.svg`. To rasterise and fan out every density:

```bash
node -e "const sharp=require('sharp'),fs=require('fs');(async()=>{for(const [s,o,n] of [['assets/icon.svg','assets/icon.png',1024],['assets/icon-foreground.svg','assets/icon-foreground.png',1024],['assets/icon-background.svg','assets/icon-background.png',1024],['assets/splash.svg','assets/splash.png',2732],['assets/splash.svg','assets/splash-dark.png',2732]])await sharp(fs.readFileSync(s),{density:400}).resize(n,n).png().toFile(o)})()"
npx capacitor-assets generate --android --iconBackgroundColor '#d9f0e9' --splashBackgroundColor '#d9f0e9'
```

### Native behaviour

- **Portrait locked** (`android:screenOrientation="portrait"` in the manifest).
- **Hardware back button** pops the in-app navigation stack and only exits at
  the root — see the `backButton` listener in `src/App.jsx`. Capacitor's default
  is `history.back()`, which would quit immediately since this app keeps its own
  stack rather than browser history.
- **Adaptive launcher icon** with the companion blob on the mint wash.

### Release build

The debug APK is signed with the shared debug key — fine for sideloading, not
for the Play Store. For a release build, generate a keystore and configure
`android/app/build.gradle` signing configs, then `./gradlew assembleRelease`.
