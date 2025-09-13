@echo off
echo Creating Final Pwnagotchi Image
echo =================================
echo.
echo Your build completed successfully through stage3!
echo Now we need to run the export-image stage to create the bootable .img file.
echo.
echo Step 1: Running export-image stage...
wsl -d Ubuntu -- bash -c "cd /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit && sudo STAGE_LIST=export-image ./build.sh"
echo.
echo Step 2: Checking for created image...
wsl -d Ubuntu -- ls -la /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/
echo.
echo Step 3: If image found, copying to Windows Desktop...
wsl -d Ubuntu -- bash -c "if [ -f /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/*.img ]; then cp /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/*.img /mnt/c/Users/dmitry.bidenko/Desktop/ && echo 'Image copied to Desktop successfully!'; else echo 'Image not found - export may still be running'; fi"
echo.
echo Done! Check your Desktop for the Pwnagotchi .img file.
pause

