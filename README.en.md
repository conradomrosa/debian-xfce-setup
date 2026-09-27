# Debian XFCE Setup

[![Bash](https://img.shields.io/badge/Bash-5%2B-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Debian](https://img.shields.io/badge/Debian-XFCE-A81D33?logo=debian&logoColor=white)](https://www.debian.org/)
![Status](https://img.shields.io/badge/status-active-success)
![Type](https://img.shields.io/badge/type-shell%20script-blue)

> **Language:** [Português](README.md) | English

Interactive script for preparing and configuring a Debian XFCE environment through a simple, repeatable, and reviewable setup process.

The project uses `whiptail` to provide a terminal menu and lets the user choose exactly which tools or settings should be applied.

---

## Table of contents

- [1. Purpose](#1-purpose)
- [2. Features](#2-features)
- [3. Requirements](#3-requirements)
- [4. Installation and execution](#4-installation-and-execution)
- [5. Usage](#5-usage)
- [6. Available options](#6-available-options)
- [7. Software and configuration detection](#7-software-and-configuration-detection)
- [8. Important behavior](#8-important-behavior)
- [9. Project structure](#9-project-structure)
- [10. Validation](#10-validation)
- [11. Known limitations](#11-known-limitations)
- [12. Security](#12-security)

---

## 1. Purpose

`Debian XFCE Setup` automates common tasks after installing Debian with XFCE.

Its purpose is to replace a long sequence of manual commands with a single script that can handle:

- system updates;
- development tools;
- desktop applications;
- Docker installation and detection;
- Zsh and Oh My Zsh;
- Inter font configuration in XFCE;
- timezone and NTP configuration;
- an optional fix for keyboards that cannot correctly produce `\` and `|` under X11/XFCE;
- audio and microphone guidance.

The script is designed specifically for **Debian** and stops when executed on another distribution.

---

## 2. Features

- interactive `whiptail` interface;
- individual task selection;
- `ALL` option for running all tasks;
- current installation/configuration status in the menu;
- task-aware error reporting;
- `sudo` authentication only when an administrative task actually needs it;
- automatic `whiptail` installation when needed;
- IntelliJ detection through JetBrains Toolbox;
- Docker installation through Docker's official repository;
- persistent and reversible keycode 77 mapping for `\` and `|` under X11/XFCE;
- preservation of the current font size when XFCE already uses Inter;
- scrollable long help dialogs;
- menu usable in terminals around `80x24`.

### 2.1 Installed or managed tools

[![Java](https://img.shields.io/badge/Java-default--jdk-ED8B00?logo=openjdk&logoColor=white)](https://openjdk.org/)
[![Maven](https://img.shields.io/badge/Apache_Maven-APT-C71A36?logo=apachemaven&logoColor=white)](https://maven.apache.org/)
[![Git](https://img.shields.io/badge/Git-APT-F05032?logo=git&logoColor=white)](https://git-scm.com/)
[![VS Code](https://img.shields.io/badge/Visual_Studio_Code-Microsoft-007ACC?logo=visualstudiocode&logoColor=white)](https://code.visualstudio.com/)
[![IntelliJ IDEA](https://img.shields.io/badge/IntelliJ_IDEA-JetBrains-000000?logo=intellijidea&logoColor=white)](https://www.jetbrains.com/idea/)
[![KeePassXC](https://img.shields.io/badge/KeePassXC-APT-6CAC4D?logo=keepassxc&logoColor=white)](https://keepassxc.org/)
[![Zsh](https://img.shields.io/badge/Zsh-Shell-F15A24?logo=zsh&logoColor=white)](https://www.zsh.org/)
[![Oh My Zsh](https://img.shields.io/badge/Oh_My_Zsh-Framework-1A2C34)](https://ohmyz.sh/)
[![Docker](https://img.shields.io/badge/Docker-Engine-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Docker Compose](https://img.shields.io/badge/Docker_Compose-Plugin-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![Docker Buildx](https://img.shields.io/badge/Docker_Buildx-Plugin-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/build/buildx/)
[![Whiptail](https://img.shields.io/badge/whiptail-Terminal_UI-4EAA25?logo=gnubash&logoColor=white)](https://packages.debian.org/search?keywords=whiptail)

### 2.2 Environment configuration and support

[![XFCE](https://img.shields.io/badge/XFCE-Desktop-2284F2?logo=xfce&logoColor=white)](https://www.xfce.org/)
[![Inter](https://img.shields.io/badge/Inter-Font-111111)](https://rsms.me/inter/)
[![systemd](https://img.shields.io/badge/systemd-timesyncd-000000?logo=systemd&logoColor=white)](https://systemd.io/)
[![Timezone](https://img.shields.io/badge/Timezone-America%2FSao__Paulo-555555)](#66-timezone-and-ntp)
[![X11](https://img.shields.io/badge/X11-xmodmap-F28834)](#68-keyboard-backslash-and-pipe)
[![Keycode 77](https://img.shields.io/badge/Keycode_77-Num_Lock_%E2%86%92_%5C_%7C-555555)](#68-keyboard-backslash-and-pipe)
[![ALSA](https://img.shields.io/badge/ALSA-alsamixer-6A5ACD)](#69-audio-and-microphone)

The badges provide a quick visual overview only. The behavior of each option is documented in text below.

---

## 3. Requirements

The script expects:

- Debian;
- an interactive terminal;
- Bash;
- internet access for downloads and package installation;
- configured `sudo` access for administrative tasks;
- XFCE for desktop-specific configuration;
- X11/XFCE for the optional keyboard fix using `xmodmap`;
- `systemd`/`timedatectl` for timezone and NTP configuration.

> **Note:** run the script as a normal user. Do not use `sudo ./setup.sh`.

---

## 4. Installation and execution

From the project directory, make the script executable:

```bash
chmod +x setup.sh
```

Then run:

```bash
./setup.sh
```

To validate Bash syntax without running the setup:

```bash
bash -n setup.sh
```

---

## 5. Usage

The menu uses a `whiptail` checklist.

- use the arrow keys to navigate;
- press `SPACE` to select or deselect an option;
- a selected option appears as `[*]`;
- press `TAB` to move to `OK`;
- press `Enter` to confirm.

> **Important:** highlighting a row does not select it. You must press `SPACE`.

The menu can display states such as:

```text
[INSTALADO]
[NÃO INSTALADO]
[CONFIGURADO]
[PENDENTE]
[INDISPONÍVEL]
```

The terminal interface currently uses Portuguese status labels.

---

## 6. Available options

| Option | Purpose |
|---|---|
| `ALL` | Runs all available tasks |
| `UPDATE` | Updates package indexes and installed packages |
| `JAVA` | Installs Debian `default-jdk` |
| `MAVEN` | Installs Apache Maven |
| `GIT` | Installs Git |
| `VSCODE` | Installs Visual Studio Code from Microsoft's official repository |
| `INTELLIJ` | Detects or installs IntelliJ IDEA |
| `KEEPASSXC` | Installs KeePassXC |
| `ZSH` | Installs Zsh and Oh My Zsh |
| `FONT` | Installs and configures the Inter font in XFCE |
| `TIME` | Configures timezone and NTP synchronization |
| `DOCKER` | Detects or installs Docker Engine from Docker's official repository |
| `KEYBOARD` | Fixes backslash and pipe using the Num Lock key (keycode 77) under X11/XFCE |
| `AUDIO` | Shows audio and microphone configuration guidance |

### 6.1 Java

Java status is based on the presence of `javac`.

When `JAVA` is selected, the script ensures Debian's `default-jdk` package is installed and prints:

```bash
java -version
```

If a JDK already exists through another installation method, APT may only add Debian meta packages or report that `default-jdk` is already at the newest version.

### 6.2 Visual Studio Code

VS Code is installed using Microsoft's official repository.

Architectures handled by the script:

- `amd64`;
- `arm64`;
- `armhf`.

If `code` is already available in `PATH`, installation is skipped.

### 6.3 IntelliJ IDEA

The script considers IntelliJ installed when any of these are found:

```text
~/.local/share/JetBrains/Toolbox/apps/intellij-idea/bin/idea
idea in PATH
/opt/intellij/bin/idea.sh
```

This allows installations managed by **JetBrains Toolbox** to be detected and prevents an unnecessary second installation.

When IntelliJ is not found, the script can install it under:

```text
/opt/intellij
```

and create:

```text
/usr/local/bin/idea
```

Supported architectures:

- `amd64`;
- `arm64`.

### 6.4 Zsh and Oh My Zsh

The script installs:

```text
zsh
curl
git
```

and installs Oh My Zsh when needed.

A valid installation requires:

```text
~/.oh-my-zsh/oh-my-zsh.sh
```

An existing `.zshrc` is preserved. If it does not appear to load Oh My Zsh, the script shows a warning instead of overwriting it.

The registered login shell is checked through `getent passwd` before `chsh` is used.

### 6.5 Inter font

The status is considered configured when:

- `fonts-inter` is installed;
- XFCE is using a font whose name starts with `Inter`.

Accepted examples:

```text
Inter 11
Inter 12
Inter 13
```

When configuration runs:

- if the current font is already Inter, its exact size is preserved;
- otherwise, `Inter 11` is used as the default.

The XFCE property is:

```text
/Gtk/FontName
```

### 6.6 Timezone and NTP

The setup configures:

```text
America/Sao_Paulo
```

and uses:

```text
systemd-timesyncd
```

for time synchronization.

### 6.7 Docker

The `DOCKER` option considers Docker installed when the `docker` command is available in `PATH`.

If Docker is already installed, the script does not reinstall it: it prints `docker --version` and, when available, `docker compose version`.

If Docker is not installed yet, the script uses the **official Docker APT repository for Debian** and installs:

```text
docker-ce
docker-ce-cli
containerd.io
docker-buildx-plugin
docker-compose-plugin
```

Before installation, the script checks for packages known to conflict with Docker's official packages. If a conflict is found, the Docker task stops without removing anything automatically.

The installation also:

- detects the architecture with `dpkg --print-architecture`;
- uses `/etc/apt/keyrings/docker.asc`;
- creates `/etc/apt/sources.list.d/docker.sources`;
- enables and starts the `docker` service when `systemd` is available;
- validates `docker --version` and `docker compose version`;
- does not run `docker run hello-world`;
- **does not automatically add the user to the `docker` group**.

If access to the daemon requires privileges, use `sudo docker ...`.

### 6.8 Keyboard: backslash and pipe

Some keyboards or layouts under X11/XFCE may not allow these characters to be typed correctly:

```text
\  backslash
|  pipe
```

The `KEYBOARD` option provides a specific workaround by repurposing the **Num Lock** key, which corresponds to **keycode 77**.

While this configuration is active:

```text
Num Lock          -> \
Shift + Num Lock  -> |
```

> **Important:** the Num Lock key stops working as Num Lock while this configuration is active.

The change is persisted in project-owned files:

```text
~/.config/debian-xfce-setup/keycode77.xmodmap
~/.config/autostart/debian-xfce-setup-keyboard.desktop
```

The autostart reapplies the configuration on new XFCE logins. In the current session, the script checks the X11 keymap before reapplying the change: if keycode 77 is already correct, the task succeeds without repeating an unnecessary operation.

If `xmodmap` is missing, the option can install Debian's:

```text
x11-xserver-utils
```

In that case, and only in that case within the `KEYBOARD` task, `sudo` is required.

Before changing anything, the script displays a confirmation explaining the effect on Num Lock, the files that will be created, and how to undo the configuration.

To remove the configuration manually:

```bash
rm ~/.config/debian-xfce-setup/keycode77.xmodmap
rm ~/.config/autostart/debian-xfce-setup-keyboard.desktop
```

Then log out and log back in. On the next login, this change will no longer be applied.

> **Limit:** this fix is specific to X11/XFCE. The script does not attempt to adapt this remapping to Wayland.

### 6.9 Audio and microphone

The `AUDIO` option does not modify the system and does not require `sudo`.

It displays instructions for:

```bash
alsamixer
```

Main shortcuts:

```text
F3  Audio output
F4  Input / microphone / Capture
F6  Select sound card
Esc Exit
```

If `alsamixer` is missing, the script explains that it is provided by the `alsa-utils` package.

---

## 7. Software and configuration detection

Statuses shown in the menu are informational and are calculated before task selection.

Some options explicitly detect existing software or configuration to avoid unnecessary work:

- Java checks for `javac`;
- VS Code checks for `code`;
- IntelliJ recognizes JetBrains Toolbox, `idea` in `PATH`, and `/opt/intellij`;
- Docker checks for `docker` in `PATH`;
- Zsh checks Zsh and the Oh My Zsh installation;
- font configuration checks the Inter package and the current XFCE property;
- timezone checks `America/Sao_Paulo` and NTP;
- keyboard configuration checks the two persistent files managed by the project.

The `ALL` option includes every task even when some are already shown as installed or configured. Each task keeps its own installation or reapplication logic.

---

## 8. Important behavior

### `sudo`

The script must not be started as root.

It requests `sudo` only when at least one selected task requires administrative access.

Important cases:

- `AUDIO` does not require `sudo`;
- `DOCKER` does not request `sudo` merely to display versions when Docker is already installed;
- `KEYBOARD` only needs `sudo` when `xmodmap` must be installed through `x11-xserver-utils`.

### Errors

The script uses:

```bash
set -Eeuo pipefail
```

and tracks the current task.

A real failure normally stops execution and prints a message similar to:

```text
ERROR: TASK_NAME failed at line X (code Y). Setup interrupted.
```

The current implementation prints this message in Portuguese.

The `DOCKER` task is isolated: if it fails, the script records the failure, continues the remaining selected tasks, and exits with an error status at the end.

For keyboard configuration, the final state of keycode 77 is validated. An intermediate command is not treated as a definitive failure when the session has already reached the desired state.

### Whiptail

If `whiptail` is missing, the script attempts to install it automatically:

```bash
sudo apt update
sudo apt install -y whiptail
```

---

## 9. Project structure

Minimal structure:

```text
debian-xfce-setup/
├── setup.sh
├── README.md
└── README.en.md
```

The main executable file is:

```text
setup.sh
```

---

## 10. Validation

Before publishing changes to the script:

```bash
bash -n setup.sh
```

If `shellcheck` is already installed:

```bash
shellcheck setup.sh
```

It is also useful to test these tasks individually:

```text
AUDIO
JAVA
FONT
INTELLIJ
DOCKER
KEYBOARD
ALL
```

When testing the menu, remember that a highlighted entry is not selected until `SPACE` is pressed.

---

## 11. Known limitations

- Debian-specific;
- font configuration requires a working XFCE session;
- timezone is currently hard-coded to `America/Sao_Paulo`;
- IntelliJ has explicit support for `amd64` and `arm64`;
- VS Code has explicit support for `amd64`, `arm64`, and `armhf`;
- the `KEYBOARD` fix is specific to X11/XFCE and is not applied under Wayland;
- `KEYBOARD` repurposes the Num Lock key, which no longer performs its normal function while the configuration is active;
- the official Docker installation stops when known conflicting packages are found; they are not removed automatically;
- `AUDIO` only displays guidance and does not automatically configure audio devices;
- some tasks may run `apt update` even when the requested package is already installed.

---

## 12. Security

The script:

- uses `sudo` to modify packages and system settings;
- adds Microsoft's official repository for VS Code;
- adds Docker's official repository when Docker Engine needs to be installed;
- downloads IntelliJ directly from JetBrains;
- downloads the official Oh My Zsh installer;
- can change the default login shell when Zsh is selected;
- can modify XFCE settings and system timezone;
- can create an XFCE autostart entry and a project-owned `xmodmap` file for the optional keycode 77 fix;
- does not automatically remove conflicting packages found by the Docker task;
- does not automatically add the user to the `docker` group.

> **Recommendation:** review `setup.sh` before running it, especially on production machines or environments with existing custom configuration.

---

`Debian XFCE Setup` aims to make a Debian XFCE installation faster, more predictable, and reproducible without hiding what the script is doing.
