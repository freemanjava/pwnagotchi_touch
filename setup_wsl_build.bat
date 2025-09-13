@echo off
echo ===============================================
echo Setting up WSL2 for Pwnagotchi Build
echo ===============================================
echo.

echo Installing WSL2 with Ubuntu...
wsl --install Ubuntu

echo.
echo After restart, run these commands in Ubuntu terminal:
echo.
echo sudo apt update
echo sudo apt install git build-essential qemu-user-static debootstrap
echo cd /mnt/c/Users/dmitry.bidenko/IdeaProjects/My/pwnagotchi_touch/pwn-gen/pi-gen-64bit
echo sudo ./build.sh
echo.
echo This will build your Pwnagotchi Touch image successfully!

pause
