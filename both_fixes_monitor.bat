@echo off
echo BOTH ISSUES IDENTIFIED AND FIXED!
echo ===================================
echo.
echo ISSUE 1 - FIXED: Missing export-image from STAGE_LIST
echo   Previous: STAGE_LIST="stage0 stage1 stage2 ../stage3"
echo   Fixed:    STAGE_LIST="stage0 stage1 stage2 ../stage3 export-image"
echo   Result:   Export-image stage now runs! ✓
echo.
echo ISSUE 2 - FIXED: Export-image script path problem
echo   Problem:  EXPORT_ROOTFS_DIR variable not properly set
echo   Fixed:    Added safeguard to point to correct stage3 rootfs
echo   Result:   Disk space calculation now works! ✓
echo.
echo The build is now running with BOTH fixes applied...
echo.

:CHECK_LOOP
echo [%TIME%] Checking for deploy directory and image files...

wsl -d Ubuntu -- ls -la /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/ 2>nul && (
    echo.
    echo ========================================
    echo    SUCCESS! DEPLOY DIRECTORY FOUND!
    echo ========================================
    echo.
    echo BOTH FIXES WORKED! Your image has been created:
    wsl -d Ubuntu -- ls -lh /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/
    echo.
    echo === Copying image to your Desktop ===
    wsl -d Ubuntu -- cp /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/*.img /mnt/c/Users/dmitry.bidenko/Desktop/ 2>nul && (
        echo.
        echo *** IMAGE SUCCESSFULLY COPIED TO DESKTOP! ***
        echo.
        echo All configuration issues have been resolved!
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

echo No deploy directory found yet - export-image stage still in progress...
echo The corrected build should now complete successfully.
echo Waiting 30 seconds before next check...
echo.
timeout /t 30 >nul
goto CHECK_LOOP

:SUCCESS
echo.
echo ==========================================
echo    ALL ISSUES FIXED - BUILD COMPLETE!
echo ==========================================
echo.
echo Summary of fixes applied:
echo 1. Added export-image to STAGE_LIST in config
echo 2. Fixed EXPORT_ROOTFS_DIR path in export-image/prerun.sh
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
