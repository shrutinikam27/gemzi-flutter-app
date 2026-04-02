@echo off
REM Set JAVA_HOME to Android Studio JBR (Java 21)
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%
echo JAVA_HOME set to %JAVA_HOME%
java -version
echo Run this before flutter build/run
pause
