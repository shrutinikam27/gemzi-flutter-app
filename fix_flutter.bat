@echo off
echo Reinstalling Flutter...
REM Remove old
rmdir /s /q C:\flutter_old
ren C:\flutter C:\flutter_old
echo Download latest stable Flutter zip from https://docs.flutter.dev/get-started/install/windows
echo Extract to C:\flutter
echo Update PATH: replace old C:\flutter\bin with new.
echo Then run flutter doctor -v
pause
