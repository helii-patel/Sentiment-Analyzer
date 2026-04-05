# Release Build Guide

## Branding and versioning

- App name: `SentimentPro Analyzer`
- Android application ID: `com.sentimentpro.analyzer`
- Flutter version: `1.0.1+2`
- Launcher icon and splash assets are generated from `assets/icon/app_icon.png` and `assets/splash/splash.png`

## Generate branding assets

```powershell
flutter pub get
flutter pub run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Create the Android signing key

If `keytool` is not on `PATH`, use Android Studio's bundled JDK:

```powershell
& 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe' -genkey -v -keystore android\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Copy `android/key.properties.example` to `android/key.properties`, then fill in the real passwords.

## Build production artifacts

```powershell
flutter build apk --release
flutter build appbundle --release
```

Without `android/key.properties`, the project falls back to debug signing for local release-mode testing only. Add the keystore before distributing the APK or AAB.

## Backend access on a real phone

`localhost` works only on the same machine as the API server. For phone testing:

1. Start the backend on your laptop with `python backend\run.py`
2. Put your laptop and phone on the same Wi-Fi
3. Replace `API_BASE_URL` in `.env` with your laptop IPv4, for example `http://192.168.1.100:8000`
4. Rebuild the APK after changing `.env`

## Install and test

```powershell
flutter install
```

Release validation checklist:

- App launches without crash
- Login flow works
- Review analysis works
- Saved history opens correctly
- Notifications and internet-backed features behave as expected
