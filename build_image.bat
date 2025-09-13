@echo off
echo ===============================================
echo Building Pwnagotchi Touch image for Pi Zero 2W
echo ===============================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running or not installed.
    echo Please install Docker Desktop and ensure it's running.
    echo Download from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo Docker is available. Starting build process...
echo.

REM Navigate to the pi-gen-64bit directory
cd /d "%~dp0pwn-gen\pi-gen-64bit"

REM Create work and deploy directories
if not exist "work" mkdir work
if not exist "deploy" mkdir deploy

echo Building Docker image...
docker build -t pwnagotchi-pi-gen .

echo.
echo Starting image build (this may take 30-60 minutes)...
echo Progress will be shown below:
echo.

REM Copy config file to pi-gen-64bit directory for the build
copy "..\config-64bit" "config" >nul

REM Run the build with proper volume mounts and execute the build script
docker run --rm --privileged ^
    -v "%cd%:/pi-gen" ^
    -v "%cd%\work:/pi-gen/work" ^
    -v "%cd%\deploy:/pi-gen/deploy" ^
    -v "%~dp0pwn-gen\stage3:/pi-gen/stage3" ^
    -e "IMG_NAME=pwnagotchi-touch-64bit" ^
    -e "CONTINUE=1" ^
    pwnagotchi-pi-gen ^
    bash -c "cd /pi-gen && ./build.sh"

echo.
if %errorlevel% equ 0 (
    echo ===============================================
    echo BUILD SUCCESSFUL!
    echo ===============================================
    echo Your Pwnagotchi Touch image is ready!
    echo Location: pwn-gen\pi-gen-64bit\deploy\
    echo.
    echo Next steps:
    echo 1. Extract the .img.xz file
    echo 2. Flash it to your SD card using Raspberry Pi Imager
    echo 3. Insert SD card into your Pi Zero 2W and boot
    echo.
) else (
    echo ===============================================
    echo BUILD FAILED!
    echo ===============================================
    echo Check the output above for error details.
)

pause
