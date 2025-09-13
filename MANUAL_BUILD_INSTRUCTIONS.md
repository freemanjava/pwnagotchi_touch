# Manual Build Instructions for Pwnagotchi Touch Image

## Step-by-Step Manual Build Process

Since the automated scripts are encountering Docker syntax issues on Windows, here are the manual commands to build your image:

### 1. Open Command Prompt (not PowerShell)
Press `Win+R`, type `cmd`, press Enter

### 2. Navigate to the build directory
```cmd
cd "C:\Users\dmitry.bidenko\IdeaProjects\My\pwnagotchi_touch\pwn-gen\pi-gen-64bit"
```

### 3. Copy the config file
```cmd
copy "..\config-64bit" "config"
```

### 4. Build the Docker image
```cmd
docker build -t pwnagotchi-pi-gen .
```

### 5. Run the actual build (this takes 30-60 minutes)
```cmd
docker run --rm --privileged -v "%cd%:/pi-gen" pwnagotchi-pi-gen bash -c "cd /pi-gen && chmod +x build.sh && ./build.sh"
```

### 6. Monitor progress
The build will show progress in real-time. Watch for:
- Stage0: Base system setup
- Stage1: Boot files
- Stage2: Desktop environment 
- Stage3: Pwnagotchi installation (your custom stage)

### 7. Find your image
When complete, the image will be in:
```
C:\Users\dmitry.bidenko\IdeaProjects\My\pwnagotchi_touch\pwn-gen\pi-gen-64bit\deploy\
```

### Alternative: Use WSL
If Command Prompt fails, you can use WSL:
1. Install WSL: `wsl --install`
2. Restart computer
3. Run the build in WSL Linux environment

### Troubleshooting
- Ensure Docker Desktop is running
- Make sure you have at least 8GB free disk space
- If build fails, check Docker has enough memory allocated (4GB+)
