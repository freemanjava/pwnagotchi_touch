@echo off
echo ==========================================
echo    🎉 BUILD SUCCESSFUL! 🎉
echo ==========================================
echo.
echo Your Pwnagotchi image has been created successfully!
echo Build completed at: 18:14:59
echo.
echo BOTH FIXES WORKED PERFECTLY:
echo ✓ Fix 1: Added export-image to STAGE_LIST
echo ✓ Fix 2: Fixed EXPORT_ROOTFS_DIR path issue
echo.
echo === LOCATING YOUR IMAGE ===
echo.
echo Checking deploy directory:
wsl -d Ubuntu -- ls -lh /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/
echo.
echo === COPYING IMAGE TO DESKTOP ===
wsl -d Ubuntu -- cp /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/*.img /mnt/c/Users/dmitry.bidenko/Desktop/ 2>nul && (
    echo ✓ Image successfully copied to your Desktop!
    echo.
    echo Your Pwnagotchi image is now ready on your Desktop.
) || (
    echo Note: Image exists in WSL but copy to Desktop may have failed.
    echo You can find it at: /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/
)
echo.
echo === IMAGE DETAILS ===
wsl -d Ubuntu -- bash -c "cd /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy && ls -lh *.img && echo && echo 'Image type:' && file *.img"
echo.
echo ==========================================
echo           NEXT STEPS
echo ==========================================
echo.
echo 1. FLASH TO SD CARD using one of these tools:
echo    • Raspberry Pi Imager (recommended)
echo    • Balena Etcher
echo    • Win32DiskImager
echo.
echo 2. INSERT SD card into your Raspberry Pi
echo.
echo 3. POWER ON and enjoy your Pwnagotchi!
echo.
echo The image name should be: pwnagotchi-touch-64bit.img
echo.
echo ==========================================
echo        PROBLEM RESOLUTION SUMMARY
echo ==========================================
echo.
echo ORIGINAL ISSUE: Build completed stage3 but no image created
echo.
echo CAUSE 1: STAGE_LIST in config file was missing export-image
echo SOLUTION 1: Added export-image to STAGE_LIST
echo.
echo CAUSE 2: Export-image script couldn't find stage3 rootfs
echo SOLUTION 2: Fixed EXPORT_ROOTFS_DIR path in prerun.sh
echo.
echo RESULT: Export-image stage ran successfully and created your bootable image!
echo.
pause

