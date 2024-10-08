# Zephyr-Dev-Container-Template

## Brief
This repository is a template for creating a new Zephyr project. The development environment runs in a docker container from the Windows subsystem for Linux (WSL2). You will need to install USBIP tools to be able to use USB programmers/debuggers.
  
## Setup
 - Install Ubuntu in [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install)
 - Install USBIP [tools](https://learn.microsoft.com/en-us/windows/wsl/connect-usb)
 - Install [vscode](https://code.visualstudio.com/download)
 - Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
 - [Generate SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) keys and link the public key to your GitHub account. You should not enter a passphrase when generating the SSH keys.

 You will need to set your global gitconfig user.name, email, and optionally trust all folders so you don't have to deal with annoying pop-ups suggesting dubious ownership (this is because the container is run as root -- not ideal but good for now). Run the following comands from within WSL.
 ```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@address"
git config --global --add safe.directory '*'
 ```
When the container is started your gitconfig is automatically copied into the container by the Dev Container extension in vscode.
  

## Start Developing
To create a new project from this template follow the procedure documented [here](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template).
  
You can startup the development environment by opening a wsl (Ubuntu) terminal and cloning the repository you created from this template.
```bash
mkdir ~/GitHub
cd ~/GitHub
git clone git@github.com:[YOUR_USERNAME/YOUR_REPO_NAME]
code .
```
It is **very important** that you change the "PRJ_ROOT_DIR" and other related environment variables defined in [devcontainer.json](.devcontainer/devcontainer.json) to the folder you cloned your project into. If you cloned with the command above, the base folder is the same name as the repository and you should find and replace 'PROJECT_REPO' with the name of the repository.

You should also update the project name in "app/CmakeLists.txt".
```cmake
project(Zephyr-Dev-Container-Template)
```

You will also need to update the board you want to build with in the ".vscode/tasks.json" file. By default it is set to build "qemu_x86_64".

Open vscode from Windows and install the "Remote Explorer", "Dev Containers", and "Docker" extensions. Once that has completed open the command palette (Ctrl+Shift+P) and start typing "Open Folder in Container...". Once you see that option click on it to start building the development container. 


### Connecting a USB Programmer/Debugger
To connect a USB programmer/debugger to the development container open a Powershell prompt as an Administrator and enter one of the following lines depending on which programer you want to use.
```powershell
#STMicro ST-Link NUCLEO-L552ZE-Q Programmer with JLink firmware
PS C:\WINDOWS\system32> usbipd wsl attach --hardware-id 1366:0105 --auto-attach
```
If you have the devcontainer open in vscode you will have to close and re-open it for the USB device to mount properly in the container.

You can allow the container to access any programmer if you know the VID:PID. Just replace the "hardware-id" parameter value with your device's VID:PID. To get a list of devices and their PID:VID type "usbipd wsl list" into a powershell. The list of devices connected to your computer will be different but should look similar to the following:
```powershell
PS C:\WINDOWS\system32> usbipd wsl list

BUSID  VID:PID    DEVICE                                                        STATE
1-2    1462:7d25  USB Input Device                                              Not attached
1-11   046d:c53f  USB Input Device                                              Not attached
1-12   046d:c547  USB Input Device                                              Not attached
1-14   8087:0026  Intel(R) Wireless Bluetooth(R)                                Not attached
1-20   04e8:4001  USB Attached SCSI (UAS) Mass Storage Device                   Not attached
4-4    0bda:8153  Realtek USB GbE Family Controller                             Not attached
7-4    1852:50d1  USB Input Device, FiiO USB DAC-E07K                           Not attached

usbipd: warning: Unknown USB filter 'nxusbf' may be incompatible with this software; 'bind --force' may be required.
```

**Required Nucleo L552ZEQ Firmware Upgrade**  
  
If you are using the ST-Link Nucleo L552ZEQ board and its built in programmer you will need to upgrade the stock firmware to JLink firmware. The process is documented [here](https://www.segger.com/products/debug-probes/j-link/models/other-j-links/st-link-on-board/). If you are using the Nucleo U575ZIQ board you should use an external JLink programmer.

### Sysbuild
The "app/sysbuild" folder contains some example configs/overlays for the app and mcuboot. These are only present to give guidance on how you can add your own files. If you don't want to use sysbuild you can move the "prj.conf" in the "sysbuild/app" folder into "app" and delete the sysbuild folder. You will also need to remove "test_sysbuild()" from "app/CMakeLists.txt". For more infomartion on sysbuild refer to [Zephyr's documentation](https://docs.zephyrproject.org/latest/build/sysbuild/index.html).

# Static Code Analysis
Static code analysis is completed at build and served at "http://localhost:8001" using CodeChecker. Once the dev container has finished launching the CodeChecker server will be accessible.

# References
  
The Zephyr SDK installation portion of the Dockerfile is base on https://github.com/beriberikix/zephyr-docker