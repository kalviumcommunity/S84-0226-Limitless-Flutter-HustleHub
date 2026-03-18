# Firebase Setup (HustleHub)

This project is now wired to use Firebase Authentication + Cloud Firestore in providers.

## 1. Configure Firebase for this app

From `hustlehub/` run:

```bash
flutterfire configure
```

Select this project and all platforms you use (Android/iOS/Web/Windows/macOS/Linux).
This generates `lib/firebase_options.dart` and updates platform files.

## 2. Android-specific checks

- Ensure `android/app/google-services.json` exists.
- Ensure Gradle is configured by FlutterFire (if prompted by CLI).

## 3. iOS-specific checks

- Ensure `ios/Runner/GoogleService-Info.plist` exists.
- Run `pod install` (done automatically in many Flutter workflows).

## 4. Firestore collections used

- `users`
- `clients`
- `projects`
- `tasks`
- `payments`

All records are scoped by `userId` and providers subscribe to realtime snapshots.

## 5. Current fallback behavior

If Firebase is not configured yet, the app falls back to local mock mode so UI still works.
Once Firebase is configured, the same screens/providers automatically use Auth + Firestore.
