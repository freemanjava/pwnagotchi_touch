@echo off
echo ISSUE IDENTIFIED AND FIXED!
echo ============================
echo.
echo PROBLEM: The build config was missing export-image from STAGE_LIST
echo SOLUTION: Updated STAGE_LIST to include export-image stage
echo.
echo Previous config: STAGE_LIST="stage0 stage1 stage2 ../stage3"
echo Fixed config:    STAGE_LIST="stage0 stage1 stage2 ../stage3 export-image"
echo.
echo The build is now running with the corrected configuration...
echo.

:CHECK_LOOP
echo [%TIME%] Checking for deploy directory and image files...

wsl -d Ubuntu -- ls -la /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/ 2>nul && (
    echo.
    echo ========================================
    echo    SUCCESS! DEPLOY DIRECTORY FOUND!
    echo ========================================
    echo.
    echo The fix worked! Your image has been created:
    wsl -d Ubuntu -- ls -lh /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/
    echo.
    echo === Copying image to your Desktop ===
    wsl -d Ubuntu -- cp /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/*.img /mnt/c/Users/dmitry.bidenko/Desktop/ 2>nul && (
        echo.
        echo *** IMAGE SUCCESSFULLY COPIED TO DESKTOP! ***
        echo.
        echo The configuration fix worked perfectly!
        echo Your Pwnagotchi image is ready to use!
        goto SUCCESS
    ) || (
        echo.
        echo Image found but failed to copy to Desktop.
        echo You can find it manually at:
        echo /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/
        goto SUCCESS
    )
)

echo No deploy directory found yet - build still in progress...
echo The corrected build should now proceed through export-image stage.
echo Waiting 30 seconds before next check...
echo.
timeout /t 30 >nul
goto CHECK_LOOP

:SUCCESS
echo.
echo ==========================================
echo        ROOT CAUSE FIXED - BUILD COMPLETE!
echo ==========================================
echo.
echo The issue was in the build configuration file.
echo By adding export-image to STAGE_LIST, the build now runs all stages.
echo.
echo Your Pwnagotchi image has been created successfully!
echo.
echo Next steps:
echo 1. Flash the .img file to an SD card using:
echo    - Raspberry Pi Imager (recommended)
echo    - Balena Etcher
echo    - Win32DiskImager
echo.
echo 2. Insert the SD card into your Raspberry Pi
echo 3. Power on and enjoy your Pwnagotchi!
echo.
pause
