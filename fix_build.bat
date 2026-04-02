@echo off
echo Setting JAVA_HOME...
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%
java -version
echo Cleaning Flutter...
flutter clean
echo Cleaning Gradle...
cd android
gradlew.bat --stop
gradlew.bat clean
cd ..
echo Pub get...
flutter pub get
echo Build test...
flutter build apk --debug
echo Done! Run 'flutter run' to test.
pause

