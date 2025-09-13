@echo off
echo Manual Image Location Check
echo ============================
echo.
echo Please run these commands manually in a new PowerShell window:
echo.
echo 1. Check if build completed all stages:
echo    wsl -d Ubuntu -- sudo ls -la /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/work/
echo.
echo 2. Look for any .img files:
echo    wsl -d Ubuntu -- sudo find /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit -name "*.img"
echo.
echo 3. Check build log status:
echo    wsl -d Ubuntu -- sudo tail -20 /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/work/build.log
echo.
echo 4. Check if export-image stage ran:
echo    wsl -d Ubuntu -- sudo ls -la /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/work/export-image/
echo.
echo 5. If no deploy directory exists, try to manually run export-image:
echo    wsl -d Ubuntu -- bash -c "cd /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit && sudo CONTINUE=1 ./build.sh"
echo.
echo The CONTINUE=1 flag will skip completed stages and continue from where it left off.
echo.
pause

