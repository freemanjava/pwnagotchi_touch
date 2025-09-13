# Pwnagotchi Touch - Pi Zero 2W Image Build Guide

## Prerequisites (Windows 11 Enterprise)

1. **Install Docker Desktop**
   - Download from: https://www.docker.com/products/docker-desktop
   - Install and restart your computer
   - Enable WSL 2 backend when prompted
   - Ensure Docker Desktop is running before building

## Build Process Options

### ⚠️ Docker Limitation on Windows
The automated Docker build has limitations on Windows due to `binfmt_misc` kernel module requirements for ARM emulation. Here are your options:

### Option 1: WSL2 Build (Recommended)
1. **Install WSL2 with Ubuntu:**
   ```powershell
   wsl --install Ubuntu
   ```
   
2. **Restart computer and open Ubuntu terminal**

3. **Install dependencies in WSL:**
   ```bash
   sudo apt update
   sudo apt install git build-essential qemu-user-static
   ```

4. **Clone and build in WSL:**
   ```bash
   cd /mnt/c/Users/dmitry.bidenko/IdeaProjects/My/pwnagotchi_touch/pwn-gen/pi-gen-64bit
   sudo ./build.sh
   ```

### Option 2: Pre-built Image Download
Since building requires Linux kernel features, you can:
1. Use a pre-built Pwnagotchi image
2. Manually install your touch interface on top of it
3. Flash Raspberry Pi OS and install manually

### Option 3: Linux VM Build
1. Install VirtualBox or VMware
2. Create Ubuntu VM with 8GB+ RAM and 20GB+ disk
3. Run the build process inside the VM

### Step 2: Manual Installation (Simplest)
If building an image is problematic:

1. **Flash Raspberry Pi OS Lite 64-bit**
   - Use [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
   - Enable SSH in advanced options
   - Set username: `pi`, password: `raspberry`

2. **Boot Pi Zero 2W and connect via SSH**

3. **Install your pwnagotchi_touch manually:**
   ```bash
   sudo apt update
   sudo apt install git python3-pip python3-venv
   git clone https://github.com/freemanjava/pwnagotchi_touch.git
   cd pwnagotchi_touch
   python3 -m venv venv
   source venv/bin/activate
   pip install pygame
   pip install -e .
   ```

### Step 3: Flash to SD Card (for built images)
1. Extract the `.img.xz` file
2. Use [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
3. Flash the extracted `.img` file to your SD card (8GB+ recommended)

### Step 4: Boot Your Pi Zero 2W
1. Insert SD card into Pi Zero 2W
2. Connect power
3. Default credentials: `pi` / `raspberry`
4. SSH is enabled by default

## Configuration
The image includes:
- Pwnagotchi Touch interface
- All required dependencies
- Default configuration in `/etc/pwnagotchi/config_interactive.toml`

## Troubleshooting
- **Docker binfmt_misc error**: Use WSL2 or manual installation instead
- **Build fails**: Ensure you have 8GB+ RAM and 20GB+ free disk space
- **Line ending errors**: Convert files using `dos2unix` in Linux environment

## Recommended Approach: Manual Installation
Given the Docker limitations on Windows, the manual installation approach is often more reliable:

1. Flash standard Raspberry Pi OS Lite 64-bit
2. SSH into the Pi
3. Clone and install your pwnagotchi_touch project
4. Configure as needed

This avoids the complex cross-compilation issues and gives you more control over the installation process.
