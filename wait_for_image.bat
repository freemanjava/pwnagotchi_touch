@echo off
echo Monitoring Export-Image Progress
echo =================================
echo.
echo Your build completed successfully through stage3 at 15:57:14
echo The export-image stage is now running to create your final .img file
echo.

:CHECK_LOOP
echo Checking for deploy directory and image files...
wsl -d Ubuntu -- ls -la /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/ 2>nul && (
    echo.
    echo === SUCCESS! DEPLOY DIRECTORY FOUND ===
    echo.
    wsl -d Ubuntu -- ls -lh /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/
    echo.
    echo === Copying image to Desktop ===
    wsl -d Ubuntu -- cp /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/*.img /mnt/c/Users/dmitry.bidenko/Desktop/ 2>nul && (
        echo Image successfully copied to Desktop!
        echo.
        echo Your Pwnagotchi image is ready!
        goto END
    ) || (
        echo Failed to copy image to Desktop, but it's available in the deploy directory.
        goto END
    )
)

echo Deploy directory not found yet - export still in progress...
echo Waiting 30 seconds before checking again...
timeout /t 30 >nul
goto CHECK_LOOP

:END
echo.
echo === BUILD COMPLETE ===
echo Your Pwnagotchi image should be on your Desktop or in:
echo /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/
echo.
pause
