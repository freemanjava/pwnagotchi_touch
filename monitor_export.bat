@echo off
echo Monitoring Export-Image Progress
echo =================================
echo.

:LOOP
echo Checking for deploy directory and image files...
wsl -d Ubuntu -- ls -la /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/ 2>nul && (
    echo.
    echo === DEPLOY DIRECTORY FOUND! ===
    echo Listing contents:
    wsl -d Ubuntu -- ls -la /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/
    echo.
    echo === Searching for .img files ===
    wsl -d Ubuntu -- find /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy -name "*.img" -exec ls -lh {} \;
    echo.
    echo Build completed successfully!
    echo Your Pwnagotchi image is ready!
    goto END
)

echo Deploy directory not found yet, export still in progress...
echo Waiting 30 seconds before checking again...
timeout /t 30 >nul
goto LOOP

:END
echo.
echo === FINAL IMAGE LOCATION ===
echo Your Pwnagotchi image should be in:
echo /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/
echo.
echo To copy it to Windows, run:
echo wsl -d Ubuntu -- cp /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/*.img /mnt/c/Users/dmitry.bidenko/Desktop/
echo.
pause
