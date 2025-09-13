Write-Host "===============================================" -ForegroundColor Green
Write-Host "Building Pwnagotchi Touch image for Pi Zero 2W" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "Docker is available. Starting build process..." -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker is not running or not installed." -ForegroundColor Red
    Write-Host "Please install Docker Desktop and ensure it's running." -ForegroundColor Red
    Write-Host "Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Navigate to the pi-gen-64bit directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$piGenDir = Join-Path $scriptDir "pwn-gen\pi-gen-64bit"
Set-Location $piGenDir

# Create work and deploy directories
if (!(Test-Path "work")) { New-Item -ItemType Directory -Name "work" | Out-Null }
if (!(Test-Path "deploy")) { New-Item -ItemType Directory -Name "deploy" | Out-Null }

Write-Host "Building Docker image..." -ForegroundColor Yellow
docker build -t pwnagotchi-pi-gen .

Write-Host ""
Write-Host "Starting image build (this may take 30-60 minutes)..." -ForegroundColor Yellow
Write-Host "Progress will be shown below:" -ForegroundColor Yellow
Write-Host ""

# Copy config file to pi-gen-64bit directory for the build
Copy-Item "..\config-64bit" "config" -Force

Write-Host "Executing build in Docker container..." -ForegroundColor Yellow

# Get the current directory in Windows format and convert to Unix format for Docker
$currentPath = (Get-Location).Path
$unixPath = $currentPath -replace '^([A-Za-z]):', '/$1' -replace '\\', '/'

# Use the proper Docker syntax for Windows
docker run --rm --privileged -v "${currentPath}:/pi-gen" pwnagotchi-pi-gen /bin/bash -c "cd /pi-gen && chmod +x build.sh && ./build.sh"

$buildResult = $LASTEXITCODE

Write-Host ""
if ($buildResult -eq 0) {
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host "BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host "Your Pwnagotchi Touch image is ready!" -ForegroundColor Green
    Write-Host "Location: pwn-gen\pi-gen-64bit\deploy\" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Extract the .img.xz file" -ForegroundColor White
    Write-Host "2. Flash it to your SD card using Raspberry Pi Imager" -ForegroundColor White
    Write-Host "3. Insert SD card into your Pi Zero 2W and boot" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "===============================================" -ForegroundColor Red
    Write-Host "BUILD FAILED!" -ForegroundColor Red
    Write-Host "===============================================" -ForegroundColor Red
    Write-Host "Check the output above for error details." -ForegroundColor Red
}

Read-Host "Press Enter to exit"
