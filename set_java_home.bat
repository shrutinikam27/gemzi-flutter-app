@echo off
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.12.7-hotspot

set PATH=%JAVA_HOME%\bin;%%PATH%%
echo JAVA_HOME set to %%JAVA_HOME%%
echo PATH updated.
java -version
echo Run this before Flutter/Gradle cmds, or set permanently via System Properties.
pause

