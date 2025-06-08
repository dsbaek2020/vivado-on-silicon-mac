# Vivado on Apple Silicon (M4 Max) with Docker + Rosetta2 (Offline Installation)

> 🚀 Run **Vivado 2024.1** natively on **Apple Silicon** using **Docker**, **Rosetta2**, and a fully offline installer
> ⚙️ Real SoC RTL/FPGA workflow – now feasible on macOS!

---

## 📦 Environment Summary

| 항목             | 사용 구성                                                                                         |
| -------------- | --------------------------------------------------------------------------------------------- |
| 💻 Mac         | MacBook Pro M4 Max 36GB (Apple Silicon)                                                       |
| 🐳 Docker      | `linux/amd64` platform with Rosetta2 emulation                                                |
| 🚰 Vivado 설치파일 | `FPGAs_AdaptiveSoCs_Unified_2024.1_0522_2023`<br>＊ 야 300GB 오프라인 설치 파일 (AMD 공식 웹사이트에서 다운로드 필요) |
| 💮 가상 모니터      | Dummy HDMI + VNC 설정 (headless 대응)                                                             |
| 🔐 원격 데스크톱     | macOS 기본 `Screen Sharing (VNC)` 앱                                                             |
| 👚 쉘 환경        | `zsh`, 컨테이너 지정 Dockerfile 및 Shell Scripts                                                     |

---

## ⚙️ 설치 및 실행 향방 요약

### 1. Vivado 설치 파일 준비

* AMD 공식 홈페이지에서 오프라인 설치 파일(`FPGAs_AdaptiveSoCs_Unified_2024.1_0522_2023`) 다운로드 후 압축 해제
* 루트 디렉터리 `vivado-on-silicon-mac/` 아래에 위치시키며 사용

### 2. 디렉터리 구성 예시

```
vivado-on-silicon-mac/
├── scripts/
│   ├── setup.sh
│   ├── install_vivado.sh
│   ├── start_container.sh
│   └── install_configs/202410.txt
├── FPGAs_AdaptiveSoCs_Unified_2024.1_0522_2023/  ← xsetup 포함
```

### 3. 설치 및 실행 명령어

```bash
# 오프라인 설치 (야 10분)
./scripts/setup.sh

# 설치 후 Vivado 실행 (야 40초)
./scripts/start_container.sh
```

> 설치 완료 후 자동으로 Docker 커테이너가 실행되고, VNC 연결 창이 발생합니다:
> `vnc://user:비밀번호@localhost:5901` 로 접속 가능

---

## 💡 안정성 핀

Vivado 사용 중 다음과 같은 증상이 나타날 수 있습니다:

* **합성(Synthesis)** 또는 **임플리먼티언(Implementation)** 동안 트입기
* **비트스트림(Bitstream)** 생성 중 중단

🔧 이러한 경우에는 먼저 `RTL Analysis` 기능을 이용하여 Design을 열어주는 것이 안정성을 향상시키는데 도움이 되었습니다.

---

## 📁 설치 용량 및 실행 성능

* 설치 완료 후 `/home/user/Xilinx/` 폴더 기준 대략 **50GB**
* `Vivado + Vitis IDE` 포함 (Vitis IDE는 Docker 환경의 그래픽 UI 엔진 부재(추정)으로 GUI 실행 안됨)
* **USB 기본 장비와 연결** 및 **비트스트림 다운로드 가능** 🎉

---

## 🧠 소개
원 제작자 Michael Mösch
(ichi4096) (https://github.com/ichi4096/vivado-on-silicon-mac) 감사드립니다.  
그리고 한국에서 도움을 받은 [@vantaa89 버프러드](https://velog.io/@vantaa89/Apple-Silicon에서-Vivado-돌리기)에게 감사를 드림니다.
웹사이트 구조 문제 때문에 오프라인 설치 형식으로 확장해 공유할 수 있게 되었습니다. 🙏

---

> **"즐거운 RTL/임베디드 설계, 이제는 macOS에서도 😄"**



Michael Mösch의 글은 지적이고 열정이 담겨 있어 참 좋습니다. 그의 분석력과 연구가 인상적이며, 노력에 감사드립니다.


# vivado-on-silicon-mac
This is a tool for installing [Vivado™](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools.html) on Arm®-based Apple Silicon Macs in a Rosetta-enabled virtual machine. It is in no way associated with Xilinx or AMD.

*Updated for 2024!*

The supported versions are:
- 2021.1
- 2022.2
- 2023.1
- 2023.2
- 2024.1

Due to unexpected behaviour in Rosetta emulation, most versions of macOS 14 (including 14.5) are not supported. macOS 13 may work, but the above versions were tested on macOS 15.

## How to install
Expect the installation process to last about one to two hours and download ~20 GB for the web installer.

### Preparations
You first need to install [Docker®](https://www.docker.com/products/docker-desktop/) (make sure to choose "Apple Chip" instead of "Intel Chip"). You may find it useful to disable the option "Open Docker Dashboard when Docker Desktop starts".

Rosetta must be installed on your Mac. The installer will ask you to install it if it is not already installed.

You will also need the Vivado installer file (the "Linux® Self Extracting Web Installer").


### Installation
1. Download this [tool](https://github.com/ichi4096/vivado-on-silicon-mac/archive/refs/heads/main.zip).
2. Extract the ZIP file.
3. Copy the Vivado installer into the extracted folder.
4. Open a terminal. Then copy & paste:
```
cd Downloads/vivado-on-silicon-mac-main
caffeinate -dim zsh ./scripts/setup.sh
```
5. Follow the instructions (in yellow) from the terminal.

Note that the installation requires You to log into Your AMD account. When asked to, allow "Terminal" to access data of other apps (the installation may succeed regardless).

### Usage
Run
```
Downloads/vivado-on-silicon-mac-main/scripts/start_container.sh
```
inside the terminal. The container can be stopped by pressing `Ctrl-C` inside the terminal or by logging out inside the container.

USB flashing support is limited, see the "USB Connection" paragraph below.

If you want to exchange files with the container, you need to store them inside the "vivado-on-silicon-mac-main" folder. Inside Vivado, the files will be accessible via the "/home/user" folder.

You can allocate more/less memory and CPU resources to Vivado by going to the Resources tab in the Docker settings.

### Notes

If the installation fails or Vivado crashes, consider:
- deleting the folder and go through the above steps again
- establishing a more reliable internet connection
- trying a different version of Vivado
- increasing RAM / Swap / CPU allocations in the Docker settings.

You may download via `git` instead of downloading the ZIP file and/or modify the scripts. The installation is wholly contained in the repository folder, which is exposed in the Docker container as the `/home/user` folder.

Installation on external storage media may work but can cause issues, such as a file system (like FAT32, exFAT, NTFS) that does not support UNIX file permissions.

## Installing other software
If you want to use additional Ubuntu packages, specify them in the Dockerfile. If you want to install further AMD / Xilinx software, you can do so by copying the corresponding installer into the folder containing the Vivado installation and launching it via the GUI. __Attention!__ You must install it into the folder `/home/user/Xilinx` because any data outside of `/home/user` does not persist between VM reboots. You can even skip installing Vivado entirely by commenting out the last line of `setup.sh`. I do not plan on supporting this out of the box.

## How it works
### Docker, Rosetta & VNC
This collection of scripts creates an x64 Docker container running Linux® that is accelerated by [Rosetta 2](https://developer.apple.com/documentation/apple-silicon/about-the-rosetta-translation-environment) via the Apple Virtualization framework. The container has all the necessary libraries preinstalled for running Vivado. It is installed automatically given an installer file that the user must provide. GUI functionality is provided via VNC and the built-in "Screen Sharing" app.

### USB connection
A drawback of the Apple Virtualization framework is that there is no implementation for USB forwarding as of when I'm writing this. Therefore, these scripts set up the [Xilinx Virtual Cable protocol](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/644579329/Xilinx+Virtual+Cable). Intended to let a computer connect to an FPGA plugged into a remote computer, it allows for the host system to run an XVC server (in this case a software called [xvcd](https://github.com/tmbinc/xvcd) by Felix Domke), to which the docker container can connect.

xvcd is contained in this repository, but with slight changes to make it compile on modern day macOS (compilation requires libusb and libftdi installed via homebrew, though there is a compiled version included). It runs continuously while the docker container is running.

This version of xvcd only supports the FT2232C chip. There are forks of this software supporting other boards such as [xvcserver by Xilinx](https://github.com/Xilinx/XilinxVirtualCable).

## Files overview
- `header.sh`: Common shell functions
- `setup.sh`: Setup file, to be run once in the beginning
- `start_container.sh`: Starts the container and "Screen Sharing" session
- `configure_docker.sh`: Automatically set necessary Docker settings
- `gen_image.sh`: Generates the Docker image to be used according to the Dockerfile
- `hashes.sh`: Contains the hashes of installer files and associated Vivado versions
- `linux_start.sh`: Docker container start script
- `de_start.sh`: Script to be executed when the desktop environment has started
- `cleanup.sh`: Removes Vivado and dotfiles.
- `xvcd`: [xvcd](https://github.com/tmbinc/xvcd) source and binary copy
- `install_bin`: Full path to Vivado installation binary
- `vnc_resolution`: Manually adjustable resolution of the container GUI, formatted like "widthxheight"
- `vncpasswd`: Password for the VNC connection. It is purposefully weak, as it serves no security function. The VNC server inside the container will not allow outside connections. The password can be changed manually nonetheless.

## License, copyright and trademark information
The repository's contents are licensed under the Creative Commons Zero v1.0 Universal license.

Note that the scripts are configured such that you automatically agree to Xilinx' and 3rd party EULAs (which can be obtained by extracting the installer yourself) by running them. You also automatically agree to [Apple's software license agreement](https://www.apple.com/legal/sla/) for Rosetta 2.

If you are installing Vivado version 2021.1:
- WebTalk data collection is enabled, and you automatically agree to the corresponding terms.
- For more information, see: https://docs.amd.com/r/2021.1-English/ug973-vivado-release-notes-install-license/WebTalk-Participation.

This repository contains the modified source code of [xvcd](https://github.com/tmbinc/xvcd) as well as a compiled version which is statically linked against [libusb](https://libusb.info/) and [libftdi](https://www.intra2net.com/en/developer/libftdi/). This is in accordance to the [LGPL Version 2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html), under which both of those libraries are licensed.

Vivado and Xilinx are trademarks of Xilinx, Inc.

Arm is a registered trademark of Arm Limited (or its subsidiaries) in the US and/or elsewhere.

Apple, Mac, MacBook, MacBook Air, macOS and Rosetta are trademarks of Apple Inc., registered in the U.S. and other countries and regions.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein.

Intel and the Intel logo are trademarks of Intel Corporation or its subsidiaries.

Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

Oracle, Java, MySQL, and NetSuite are registered trademarks of Oracle and/or its affiliates. Other names may be trademarks of their respective owners.

X Window System is a trademark of the Massachusetts Institute of Technology.
