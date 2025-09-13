@echo off
echo Starting Pwnagotchi build in WSL...
echo.
echo Step 1: Entering WSL and navigating to project directory
wsl -d Ubuntu -e bash -c "cd /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit && pwd && ls -la config"
echo.
echo Step 2: Starting build process (this will take 30-60 minutes)
wsl -d Ubuntu -e bash -c "cd /home/dmitrybidenko/pwnagotchi-build/pi-gen-64bit && sudo ./build.sh"
echo.
echo Build completed. Check the deploy directory for your image.
pause

