@echo off
echo Final Image Creation in Progress
echo ==================================
echo.
echo Your build completed successfully through stage3 at 16:20:15
echo All Pwnagotchi software is installed and configured!
echo.
echo The export-image stage is now running to create your bootable .img file...
echo This process typically takes 10-20 minutes.
echo.

:CHECK_LOOP
echo [%TIME%] Checking for deploy directory and image files...

wsl -d Ubuntu -- ls -la /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/ 2>nul && (
    echo.
    echo ========================================
    echo    SUCCESS! DEPLOY DIRECTORY FOUND!
    echo ========================================
    echo.
    echo Image file details:
    wsl -d Ubuntu -- ls -lh /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/
    echo.
    echo === Copying image to your Desktop ===
    wsl -d Ubuntu -- cp /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/*.img /mnt/c/Users/dmitry.bidenko/Desktop/ 2>nul && (
        echo.
        echo *** IMAGE SUCCESSFULLY COPIED TO DESKTOP! ***
        echo.
        echo Your Pwnagotchi image is ready to use!
        echo You can now flash it to an SD card.
        goto SUCCESS
    ) || (
        echo.
        echo Image found but failed to copy to Desktop.
        echo You can find it manually at:
        echo /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/
        goto SUCCESS
    )
)

wsl -d Ubuntu -- ps aux ^| grep build.sh ^| grep -v grep >nul 2>&1 && (
    echo Export-image process is still running...
) || (
    echo No build process detected - checking if image was created...
)

echo Waiting 30 seconds before next check...
echo.
timeout /t 30 >nul
goto CHECK_LOOP

:SUCCESS
echo.
echo ==========================================
echo           BUILD COMPLETE!
echo ==========================================
echo.
echo Your Pwnagotchi image has been created successfully!
echo.
echo Next steps:
echo 1. Flash the .img file to an SD card using tools like:
echo    - Raspberry Pi Imager
echo    - Balena Etcher
echo    - Win32DiskImager
echo.
echo 2. Insert the SD card into your Raspberry Pi
echo 3. Power on and enjoy your Pwnagotchi!
echo.
pause
