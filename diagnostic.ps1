Write-Host "Flutter Device Diagnostic"
Write-Host "1. Check Flutter..."
flutter --version
Write-Host "`n2. Doctor..."
flutter doctor -v | Out-String -Stream
Write-Host "`n3. Devices..."
flutter devices
Write-Host "`n4. ADB..."
adb devices
Write-Host "`n5. JAVA..."
java -version
Write-Host "`n6. PATH has Flutter? "
$env:PATH.Split(';') | Where-Object { $_ -like "*flutter*" }
Read-Host "Press Enter to exit"

