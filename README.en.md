# Debian XFCE Setup

[![Bash](https://img.shields.io/badge/Bash-5%2B-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Debian](https://img.shields.io/badge/Debian-XFCE-A81D33?logo=debian&logoColor=white)](https://www.debian.org/)
[![Status](https://img.shields.io/badge/status-active-success)](#)
[![Shell](https://img.shields.io/badge/type-shell%20script-blue)](#)

> **Language:** [Português](README.md) | English

Interactive script for preparing and configuring a Debian XFCE environment, focused on a simple, repeatable and reviewable setup process.

The project uses `whiptail` to provide a terminal menu and lets the user choose exactly which tools or settings should be applied.

---

## Table of contents

- [1. Purpose](#1-purpose)
- [2. Features](#2-features)
- [3. Requirements](#3-requirements)
- [4. Installation and execution](#4-installation-and-execution)
- [5. Usage](#5-usage)
- [6. Available options](#6-available-options)
- [7. Detection of existing software](#7-detection-of-existing-software)
- [8. Important behavior](#8-important-behavior)
- [9. Project structure](#9-project-structure)
- [10. Validation](#10-validation)
- [11. Known limitations](#11-known-limitations)
- [12. Security](#12-security)

---

## 1. Purpose

`Debian XFCE Setup` automates common tasks after installing Debian with XFCE.

Its goal is to replace a long sequence of manual commands with a single script that can handle:

- system updates;
- development tools;
- desktop applications;
- Zsh and Oh My Zsh;
- Inter font configuration in XFCE;
- timezone and NTP configuration;
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
- automatic `whiptail` installation when missing;
- IntelliJ detection through JetBrains Toolbox;
- preservation of the current font size when XFCE already uses Inter;
- scrollable long help dialogs;
- menu sized for terminals around `80x24`.

---

## 3. Requirements

The script expects:

- Debian;
- an interactive terminal;
- Bash;
- internet access for downloads and package installation;
- configured `sudo` access for administrative tasks;
- XFCE for font configuration;
- `systemd`/`timedatectl` for timezone and NTP configuration.

> **Note:** run the script as a normal user. Do not execute it with `sudo ./setup.sh`.

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
[INSTALLED]
[NOT INSTALLED]
[CONFIGURED]
[PENDING]
[UNAVAILABLE]
```

The actual script currently uses Portuguese status labels in the terminal interface.

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

and then installs Oh My Zsh when needed.

A valid installation requires:

```text
~/.oh-my-zsh/oh-my-zsh.sh
```

An existing `.zshrc` is preserved. If it does not appear to load Oh My Zsh, the script shows a warning instead of overwriting it.

The registered login shell is checked through `getent passwd` before `chsh` is used.

### 6.5 Inter font

The status is considered configured when:

- `fonts-inter` is actually installed;
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

The setup currently configures:

```text
America/Sao_Paulo
```

and uses:

```text
systemd-timesyncd
```

for time synchronization.

### 6.7 Audio and microphone

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

## 7. Detection of existing software

Statuses displayed in the menu are informational.

Some tasks explicitly detect existing installations and skip installation when possible, including:

- VS Code;
- IntelliJ IDEA.

Other tasks still use APT normally. Selecting an already installed package is safe: Debian simply reports that it is already at the newest version.

The `ALL` option includes every task even if some are already shown as installed or configured.

---

## 8. Important behavior

### `sudo`

The script must not be started as root.

It requests `sudo` only when at least one selected task requires administrative access.

Selecting only `AUDIO` should not request an administrative password.

### Errors

The script uses:

```bash
set -Eeuo pipefail
```

and tracks the current task.

A real failure stops execution and prints a message similar to:

```text
ERROR: TASK_NAME failed at line X (code Y). Setup interrupted.
```

The current implementation prints this message in Portuguese.

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
script-debian-xfce/
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

Before publishing changes to the script, run:

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
ALL
```

and remember that a highlighted menu entry is not selected until `SPACE` is pressed.

---

## 11. Known limitations

- Debian-specific;
- font configuration requires a working XFCE session;
- timezone is currently hard-coded to `America/Sao_Paulo`;
- IntelliJ has explicit support for `amd64` and `arm64`;
- VS Code has explicit support for `amd64`, `arm64` and `armhf`;
- `AUDIO` only displays guidance and does not automatically configure audio devices;
- some tasks may run `apt update` even when the requested package is already installed.

---

## 12. Security

The script:

- uses `sudo` to modify packages and system settings;
- adds Microsoft's official repository for VS Code;
- downloads IntelliJ directly from JetBrains;
- downloads the official Oh My Zsh installer;
- can change the default login shell when Zsh is selected;
- can modify XFCE settings and system timezone.

> **Recommendation:** review `setup.sh` before running it, especially on production machines or environments with existing custom configuration.

---

`Debian XFCE Setup` aims to make a Debian XFCE installation faster, more predictable and reproducible without hiding what the script is doing.
