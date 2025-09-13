@echo off
echo Searching for your Pwnagotchi image...
echo.

echo === Checking for deploy directory ===
wsl -d Ubuntu -- ls -la /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/deploy/ 2>nul || echo Deploy directory not found

echo.
echo === Searching for .img files ===
wsl -d Ubuntu -- sudo find /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit -name "*.img" -type f 2>nul || echo No .img files found

echo.
echo === Checking work directory contents ===
wsl -d Ubuntu -- sudo ls -la /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/work/ 2>nul || echo Work directory not accessible

echo.
echo === Checking for any image files ===
wsl -d Ubuntu -- sudo find /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/work -name "*image*" -o -name "*.zip" 2>nul || echo No image files found

echo.
echo === Checking build log tail ===
wsl -d Ubuntu -- sudo tail -10 /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/work/build.log 2>nul || echo Build log not found

echo.
echo === Checking if build actually finished ===
wsl -d Ubuntu -- sudo ls -la /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit/work/ | grep -E "(stage|export)" || echo No stage directories found

echo.
pause
