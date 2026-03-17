# FirebaseError Fix Plan for Gemzi Flutter App

**Status: Approved - Implementing step-by-step**

## Current Analysis:
- FirebaseError in firebase_core_web core.dart line 60 (JS interop failure on web).
- Works on Android (assumed). Web-specific: SDK loading/init issue.
- Fix: Add Firebase JS SDK + config to web/index.html.

## Steps:
- [x] 1. Analyzed files (pubspec.yaml, main.dart, firebase_options.dart, index.html, configs).
- [x] 2. Created TODO.md with plan.
- [x] 3. Edit web/index.html to add Firebase SDK and initializeApp config.
- [x] 4. Add error handling to lib/main.dart.

- [x] 5. flutter clean && flutter pub get.

- [x] 6. Test `flutter run -d chrome`.

- [ ] 7. attempt_completion if resolved.

Progress tracked here.

