# Flutter Setup &amp; Device Fix - Progress Tracker

## Approved Plan Steps:

**Step 1: [x] Fix PowerShell << error in diagnostic.ps1**
- Update to use `flutter doctor -v | Out-String -Stream`
- Test execution.

**Step 2: [x] Test diagnostics**
- Flutter PATH OK, Java 24, no ADB.
- Flutter corrupted - use fix_flutter.bat instructions to reinstall.

**Step 3: [TODO] JDK17 install**
- `choco install temurin17`
- set_java_home.bat update if needed.

**Step 4: [TODO] Android SDK**
- `choco install androidstudio`
- Accept licenses: `flutter doctor --android-licenses`

**Step 5: [TODO] Device/Emulator**
- AVD Manager create/start.
- `flutter devices`

**Step 6: [TODO] Complete verification**
- `flutter run`
- Mark all [x] done.

