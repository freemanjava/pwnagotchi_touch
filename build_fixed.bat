@echo off
echo ===============================================
echo Fixed Docker Build Command for Windows
echo ===============================================

cd /d "C:\Users\dmitry.bidenko\IdeaProjects\My\pwnagotchi_touch\pwn-gen\pi-gen-64bit"

echo Copying config file...
copy "..\config-64bit" "config" >nul

echo Rebuilding Docker image with fixes...
docker build -t pwnagotchi-pi-gen . --no-cache

echo.
echo Starting build process (30-60 minutes)...
echo Using absolute path for volume mount...

REM Run with additional Docker flags for cross-platform support
docker run --rm --privileged --platform linux/amd64 ^
    -v "C:/Users/dmitry.bidenko/IdeaProjects/My/pwnagotchi_touch/pwn-gen/pi-gen-64bit:/pi-gen" ^
    pwnagotchi-pi-gen /bin/bash -c "find /pi-gen -type f -exec file {} \; | grep -E '(ASCII|text|shell)' | cut -d: -f1 | xargs -I {} sed -i 's/\r$//' {} && find /pi-gen -type f -name '*.sh' -exec chmod +x {} \; && chmod +x /pi-gen/build.sh && cd /pi-gen && ./build.sh"

echo.
if %errorlevel% equ 0 (
    echo ===============================================
    echo BUILD SUCCESSFUL!
    echo ===============================================
    echo Your Pwnagotchi Touch image is ready!
    echo Location: deploy folder
) else (
    echo ===============================================
    echo BUILD FAILED!
    echo ===============================================
    echo Exit code: %errorlevel%
)
pause
