# Debian XFCE Setup — documentation

> **Language:** English | [Português)](DOCS.md)

This document describes the current technical behavior of the **Debian XFCE Setup** project's `setup.sh`. It is reference documentation for the script, not the project's presentation README.

The setup uses `whiptail` to provide an interactive terminal interface, allows tasks to be selected individually, and provides a complete `pt-BR` and `en` interface.

---

## Table of contents

- [1. Purpose and scope](#1-purpose-and-scope)
- [2. Requirements](#2-requirements)
- [3. Execution and language](#3-execution-and-language)
- [4. Interface and statuses](#4-interface-and-statuses)
- [5. Available options](#5-available-options)
- [6. Task behavior](#6-task-behavior)
- [7. Detection and idempotency](#7-detection-and-idempotency)
- [8. `sudo` and error handling](#8-sudo-and-error-handling)
- [9. Managed files and integrations](#9-managed-files-and-integrations)
- [10. Validation](#10-validation)
- [11. Known limitations](#11-known-limitations)
- [12. Security](#12-security)

---

## 1. Purpose and scope

`Debian XFCE Setup` automates common tasks used to prepare a Debian XFCE environment.

The script combines in one interface:

- system updates;
- Java, Maven, and Git installation;
- Visual Studio Code and IntelliJ IDEA installation;
- KeePassXC installation;
- Zsh and Oh My Zsh installation;
- Inter font availability;
- timezone and NTP configuration;
- Docker Engine, Docker Compose, and Buildx installation and verification;
- an optional keyboard fix for `\` and `|` under X11/XFCE;
- optional Chicago95 integration;
- audio and microphone guidance through `alsamixer`.

The script is specific to **Debian**. If `/etc/os-release` identifies another distribution, execution stops.

---

## 2. Requirements

The setup expects:

- Debian;
- Bash;
- an interactive terminal;
- internet access for downloads and package installation;
- configured `sudo` access for administrative tasks;
- XFCE for desktop-specific integrations;
- X11/XFCE for the optional `xmodmap` keyboard fix;
- `systemd` and `timedatectl` for timezone and NTP configuration;
- a working graphical GTK3 session for the initial Chicago95 installation.

> **Note:** run the script as a normal user. Do not use `sudo ./setup.sh`.

The script itself attempts to install `whiptail` when it is unavailable.

---

## 3. Execution and language

Make the script executable:

```bash
chmod +x setup.sh
```

Run it:

```bash
./setup.sh
```

### 3.1 Language selection

On every run, after the initial checks and once `whiptail` is available, the script displays a manual selection:

```text
pt-BR  Português (Brasil)
en     English
```

The selection has these properties:

- it does not use `LANG`, `LANGUAGE`, `LC_ALL`, or another locale to choose a language;
- it performs no automatic language detection;
- it does not persist the choice between runs;
- the choice is kept only in memory for the current execution;
- cancelling or leaving the language screen exits without running setup tasks.

Messages that may appear before language selection, such as distribution errors or missing `whiptail`, are displayed bilingually.

---

## 4. Interface and statuses

The main menu uses a `whiptail` checklist.

- use the arrow keys to navigate;
- press `SPACE` to select or deselect an option;
- a selected option appears as `[*]`;
- use `TAB` to reach the buttons;
- press `Enter` to confirm.

> **Note:** highlighting a row does not select it. It must be marked with `SPACE`.

### 4.1 Displayed statuses

Internally, the script keeps stable Portuguese status values so presentation is not mixed with control flow. The interface localizes them according to the selected language.

| Internal status | `pt-BR` | `en` |
|---|---|---|
| `[INSTALADO]` | `[INSTALADO]` | `[INSTALLED]` |
| `[NÃO INSTALADO]` | `[NÃO INSTALADO]` | `[NOT INSTALLED]` |
| `[CONFIGURADO]` | `[CONFIGURADO]` | `[CONFIGURED]` |
| `[PENDENTE]` | `[PENDENTE]` | `[PENDING]` |
| `[PARCIAL]` | `[PARCIAL]` | `[PARTIAL]` |
| `[INDISPONÍVEL]` | `[INDISPONÍVEL]` | `[UNAVAILABLE]` |

Localization changes presentation only. Internal comparisons, such as those used by `status_font()` and `status_keyboard()`, remain independent of the selected language.

---

## 5. Available options

| Option | Purpose |
|---|---|
| `ALL` | Runs every available task |
| `UPDATE` | Updates package indexes and installed packages |
| `JAVA` | Installs Debian's `default-jdk` |
| `MAVEN` | Installs Apache Maven |
| `GIT` | Installs Git |
| `VSCODE` | Installs Visual Studio Code from Microsoft's official repository |
| `INTELLIJ` | Detects or installs IntelliJ IDEA |
| `KEEPASSXC` | Installs KeePassXC |
| `ZSH` | Installs Zsh and Oh My Zsh |
| `FONT` | Installs/makes the `fonts-inter` package available |
| `TIME` | Configures timezone and NTP synchronization |
| `DOCKER` | Detects or installs Docker Engine, Compose, and Buildx |
| `KEYBOARD` | Fixes `\` and `|` using Num Lock (`keycode 77`) under X11/XFCE |
| `CHICAGO95` | Installs or integrates Chicago95 under project-controlled restrictions |
| `AUDIO` | Shows audio and microphone configuration guidance |

The `ALL` option expands to every option above, including `UPDATE`, `CHICAGO95`, and `AUDIO`.

---

## 6. Task behavior

### 6.1 `UPDATE`

Runs:

```bash
sudo apt update
sudo apt upgrade -y
```

The script keeps an internal flag to avoid repeating `apt update` unnecessarily within the same run when tasks use the shared APT helper.

### 6.2 `JAVA`

Java status is based on the presence of `javac`.

The task installs:

```text
default-jdk
```

Then prints:

```bash
java -version
```

### 6.3 `MAVEN`

Installs the Debian package:

```text
maven
```

Then prints:

```bash
mvn --version
```

### 6.4 `GIT`

Installs the Debian package:

```text
git
```

Then prints:

```bash
git --version
```

### 6.5 `VSCODE`

If `code` is already available in `PATH`, the task returns without reinstalling VS Code.

Accepted architectures:

- `amd64`;
- `arm64`;
- `armhf`.

When installation is needed, the script:

1. installs `wget`, `gpg`, and `ca-certificates`;
2. adds Microsoft's official key to `/usr/share/keyrings/microsoft.gpg`;
3. creates `/etc/apt/sources.list.d/vscode.sources`;
4. installs the `code` package from Microsoft's official repository.

### 6.6 `INTELLIJ`

IntelliJ is considered installed when one of these is available:

```text
~/.local/share/JetBrains/Toolbox/apps/intellij-idea/bin/idea
idea in PATH
/opt/intellij/bin/idea.sh
```

Architectures supported by the automated installation:

- `amd64`;
- `arm64`.

When needed, the script downloads IntelliJ IDEA Ultimate directly from JetBrains, validates the extracted structure, and publishes the installation to:

```text
/opt/intellij
```

It also creates:

```text
/usr/local/bin/idea
```

If something already exists at `/opt/intellij` during publication of a new installation, the previous content is preserved in a backup directory under `/opt`.

### 6.7 `KEEPASSXC`

Installs the Debian package:

```text
keepassxc
```

### 6.8 `ZSH`

Installs:

```text
zsh
curl
git
```

Oh My Zsh is installed only when `~/.oh-my-zsh/oh-my-zsh.sh` is missing.

The installation uses the project's official installer with:

```text
RUNZSH=no
CHSH=no
KEEP_ZSHRC=yes
```

Important behavior:

- an empty `~/.oh-my-zsh` directory may be removed so installation can proceed;
- non-empty incomplete content is preserved and the task stops;
- `.zshrc` is not overwritten;
- if loading Oh My Zsh cannot be identified in `.zshrc`, the script only prints a warning;
- the registered shell is queried through `getent passwd` before `chsh` is used;
- when needed, the default shell is changed to the resolved Zsh path.

### 6.9 `FONT`

The `FONT` task is deliberately simple: it makes Inter available through the Debian package.

Its status checks only whether:

```text
fonts-inter
```

is installed.

If the package is already installed, the task performs no APT work. Otherwise, it installs the package and confirms the final state.

The setup does **not**:

- select Inter as the interface font;
- change `/Gtk/FontName`;
- change font size;
- run `fc-cache` manually;
- write fonts to `~/.fonts`, `~/.local/share/fonts`, or `/usr/share/fonts`;
- modify `/etc/fonts`.

Interface font selection is left to the user.

### 6.10 `TIME`

The task requires an environment where `systemctl` and `timedatectl` are available and functional.

It installs:

```text
systemd-timesyncd
```

And configures:

```text
Timezone: America/Sao_Paulo
NTP: true
```

It also enables and starts `systemd-timesyncd`.

### 6.11 `DOCKER`

Docker is shown as `[INSTALLED]` only when all these checks pass:

- `docker` exists in `PATH`;
- `dockerd` exists in `PATH`;
- `docker --version` works;
- `docker compose version` works;
- `docker buildx version` works.

If `docker` or `dockerd` exists but the full set is incomplete, the menu shows `[PARTIAL]`.

When the installation is already complete, the task only prints Docker, Compose, and Buildx versions and does not require `sudo` to reinstall components.

Before installing Docker's official packages, the script checks for these conflicting packages:

```text
docker.io
docker-compose
docker-doc
docker-buildx
podman-docker
containerd
runc
```

If any are installed, the task stops and **does not remove packages automatically**.

When installation can proceed, the script:

1. uses Docker's official APT repository for Debian;
2. stores the key in `/etc/apt/keyrings/docker.asc`;
3. creates `/etc/apt/sources.list.d/docker.sources`;
4. installs:

```text
docker-ce
docker-ce-cli
containerd.io
docker-buildx-plugin
docker-compose-plugin
```

5. validates Docker, Compose, and Buildx;
6. when `systemd` is available, enables and starts the `docker` service and verifies that it is active.

The script:

- does not run `docker run hello-world`;
- does not automatically add the user to the `docker` group.

If daemon access requires privileges, use `sudo docker ...`.

### 6.12 `KEYBOARD`

This option handles a specific X11/XFCE keyboard/layout case where these characters cannot be typed correctly:

```text
\  backslash
|  pipe
```

The workaround repurposes **Num Lock**, `keycode 77`:

```text
Num Lock          -> \
Shift + Num Lock  -> |
```

> **Restriction:** while this configuration is active, the Num Lock key no longer performs its normal function.

Managed files:

```text
~/.config/debian-xfce-setup/keycode77.xmodmap
~/.config/autostart/debian-xfce-setup-keyboard.desktop
```

The autostart reapplies the map on XFCE logins. In the current session, the script validates the X11 map before and after applying it.

If `xmodmap` is missing, the task can install:

```text
x11-xserver-utils
```

Only in that case does the `KEYBOARD` task require `sudo`.

The script also recognizes a specific legacy pair:

```text
~/.Xmodmap
~/.config/autostart/xmodmap.desktop
```

When that pair exactly matches the known format, it can be migrated to the project-specific files. Unrecognized old files are preserved.

To remove the current configuration manually:

```bash
rm ~/.config/debian-xfce-setup/keycode77.xmodmap
rm ~/.config/autostart/debian-xfce-setup-keyboard.desktop
```

Then log out and back in.

### 6.13 `CHICAGO95`

This option integrates the official **Chicago95** project without allowing the upstream installer to control components that Debian XFCE Setup has decided to manage separately or leave manual.

#### Detection

The theme is considered installed when these files exist and are non-empty:

```text
~/.themes/Chicago95/gtk-2.0/gtkrc
~/.themes/Chicago95/xfwm4/themerc
~/.themes/Chicago95/gtk-3.0/gtk.css
```

#### Dependencies

Integration dependencies include:

```text
git
python3
gnome-session-canberra
sox
libcanberra-gtk3-module
```

When the theme is not installed yet, these may also be required:

```text
xfce4-panel-profiles
gtk2-engines-pixbuf
python3-gi
gir1.2-gtk-3.0
```

#### Official installer and restrictions

When the theme is not installed, the script temporarily clones:

```text
https://github.com/grassmunk/Chicago95.git
```

Before running `installer.py`, the setup analyzes the file through Python's AST and requires all these flags to exist:

```text
install_sounds
install_fonts
install_background
panel
bash
zsh
terminal_colors
thunar
```

If any expected flag is missing, installation stops. This validation is **fail-closed**: a structural upstream installer change is not ignored.

When the structure is recognized, every flag above is forced to `False` before execution. Installer calls to `xfconf` properties whose names contain `font` are also blocked.

This prevents the official installer from automatically installing or configuring fonts, sounds, background, panel, or shell/terminal customizations controlled by those flags.

#### Sounds

Sounds are copied separately to:

```text
~/.local/share/sounds/Chicago95
```

The project keeps a hash manifest so files that still match the previously managed version can be updated without overwriting user customizations.

The classic startup sound is stored as:

```text
~/.local/share/sounds/Chicago95/startup.ogg
```

The project also creates:

```text
~/.config/autostart/debian-xfce-setup-chicago95-startup.desktop
```

This autostart waits a few seconds and plays the sound with `/usr/bin/play`.

When `xfconf-query` is available in an accessible XFCE session, the setup sets:

```text
/Net/SoundThemeName = Chicago95
```

#### Helvetica

The bitmap Helvetica supplied by Chicago95 is **downloaded as data but not installed**.

Files are stored in:

```text
~/.local/share/debian-xfce-setup/chicago95-fonts/cronyx-cyrillic
```

The directory uses a manifest and SHA-256 checks to verify the managed copy. Pre-existing or customized files that differ from the official content are preserved and cause integrity verification to report a difference.

The font is not copied into user or system font directories, and the setup does not automatically enable bitmap fonts.

> **Note:** legacy bitmap fonts can cause rendering problems in modern applications, including Electron/Chromium and Visual Studio Code.

The script itself displays an optional workaround for a single VS Code process if the user manually installed Helvetica and encounters problems:

```bash
cat > /tmp/vscode-fontconfig.conf <<'EOF_FONTCONFIG'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <include ignore_missing="no">/etc/fonts/fonts.conf</include>
  <match target="pattern">
    <test name="family" compare="eq">
      <string>Helvetica</string>
    </test>
    <edit name="family" mode="assign_replace" binding="strong">
      <string>Noto Sans</string>
    </edit>
  </match>
</fontconfig>
EOF_FONTCONFIG

FONTCONFIG_FILE=/tmp/vscode-fontconfig.conf \
FONTCONFIG_PATH=/etc/fonts \
code
```

This workaround is not executed automatically by the setup and does not modify `/etc/fonts`.

#### Manual items

The setup does not automatically configure:

- the Start button/menu icon;
- wallpaper;
- Helvetica installation.

The installed theme contains resources under `~/.themes/Chicago95/misc`, and the official repository provides wallpapers under `Extras/Backgrounds`.

### 6.14 `AUDIO`

The `AUDIO` option does not modify the system and does not require `sudo`.

It displays guidance for:

```bash
alsamixer
```

Main shortcuts:

```text
F3  Audio output
F4  Input / microphone / Capture
F6  Select audio device
Esc Exit
```

For a distorted or clipping microphone, the guidance highlights controls such as:

```text
Capture
Mic Boost
Internal Mic Boost
```

If `alsamixer` is not installed, the script explains that it is provided by the `alsa-utils` package; the option does not install that package automatically.

---

## 7. Detection and idempotency

Menu statuses are calculated before task selection.

Main detections:

- Java: presence of `javac`;
- Maven: presence of `mvn`;
- Git: presence of `git`;
- VS Code: presence of `code`;
- IntelliJ: JetBrains Toolbox, `idea` in `PATH`, or `/opt/intellij/bin/idea.sh`;
- KeePassXC: presence of `keepassxc`;
- Zsh: presence of `zsh` and `~/.oh-my-zsh/oh-my-zsh.sh`;
- Inter: `fonts-inter` package state;
- timezone: `America/Sao_Paulo` and active NTP;
- Docker: working CLI, `dockerd`, Compose, and Buildx;
- keyboard: exact content of the two persistent project files;
- Chicago95: essential theme files under `~/.themes/Chicago95`.

The `ALL` option still includes tasks that are already shown as installed or configured. Each task applies its own early-return, reapplication, or validation logic.

---

## 8. `sudo` and error handling

### 8.1 `sudo`

The setup must not be started as root.

After task selection, it calculates whether any selected task needs `sudo` and only then requests administrative authentication.

Exceptions and details:

- initial `whiptail` installation, when needed, happens before the menu and may require `sudo`;
- `AUDIO` does not require `sudo`;
- `KEYBOARD` requests `sudo` only when `x11-xserver-utils` must be installed;
- an already installed `FONT` task does not invoke APT or `sudo` for that task;
- a complete `DOCKER` installation does not require reinstallation or authentication merely to display versions;
- `CHICAGO95` requires `sudo` only when Debian integration packages are missing.

### 8.2 Errors

The script starts with:

```bash
set -Eeuo pipefail
```

It keeps the current task in `CURRENT_TASK`.

Normal failures are reported in the selected language with an equivalent format:

```text
ERRO: TAREFA falhou na linha X (código Y). Setup interrompido.
```

or:

```text
ERROR: TASK failed at line X (code Y). Setup aborted.
```

Normal `whiptail` cancellations remain separate from real errors.

The `DOCKER` task is isolated: if it fails, the error is recorded, the remaining selected tasks continue, and the process exits with a non-zero status at the end.

---

## 9. Managed files and integrations

Core files documented here:

```text
debian-xfce-setup/
├── setup.sh
├── DOCS.md
└── DOCS-en.md
```

The repository README is a separate artifact and is not replaced by these technical documents.

Files created or managed by the setup may include:

```text
/etc/apt/sources.list.d/vscode.sources
/usr/share/keyrings/microsoft.gpg
/etc/apt/sources.list.d/docker.sources
/etc/apt/keyrings/docker.asc
/opt/intellij
/usr/local/bin/idea
~/.config/debian-xfce-setup/keycode77.xmodmap
~/.config/autostart/debian-xfce-setup-keyboard.desktop
~/.local/share/sounds/Chicago95
~/.config/autostart/debian-xfce-setup-chicago95-startup.desktop
~/.local/share/debian-xfce-setup/chicago95-fonts/cronyx-cyrillic
```

Not every path is created on every run; they depend on selected options and the current system state.

---

## 10. Validation

To validate Bash syntax only:

```bash
bash -n setup.sh
```

To detect whitespace and patch issues before a commit:

```bash
git diff --check
```

If `shellcheck` is already installed:

```bash
shellcheck setup.sh
```

Useful manual checks include:

- open the selector and test `pt-BR`;
- open the selector and test `en`;
- cancel the language selector;
- verify localized menu statuses;
- select an already installed task and verify its idempotent return;
- test `FONT` without automatic interface font changes;
- test complete and partial `DOCKER` states;
- test `KEYBOARD` under X11/XFCE;
- test `CHICAGO95` in a graphical XFCE session;
- test `AUDIO` without system changes;
- verify `ALL` expansion.

> **Note:** automated tests should avoid real installation, `sudo`, APT, clones, or user-configuration changes when the goal is only to validate logic.

---

## 11. Known limitations

- Debian-specific;
- language selection is manual on every run and is not persisted;
- timezone is fixed to `America/Sao_Paulo`;
- IntelliJ automated installation supports only `amd64` and `arm64`;
- VS Code accepts `amd64`, `arm64`, and `armhf`;
- `KEYBOARD` is specific to X11/XFCE and does not adapt the mapping to Wayland;
- `KEYBOARD` repurposes Num Lock, which loses its normal function while the mapping is active;
- `CHICAGO95` depends on the known upstream installer structure and fails safely when expected flags disappear;
- initial Chicago95 installation requires a working graphical GTK3 session;
- Chicago95 Helvetica is preserved as data only, not installed;
- Chicago95 wallpapers and Start button configuration remain manual;
- `DOCKER` stops when known conflicting packages are detected;
- `AUDIO` provides guidance but does not configure devices or install `alsa-utils`;
- some installation tasks may refresh APT indexes before installing packages.

---

## 12. Security

The script performs administrative operations and external downloads. Review `setup.sh` and the selected options before using it on an important machine.

Main security and impact characteristics:

- refuses to run as root;
- uses `sudo` only where privileges are needed, in addition to possible initial `whiptail` installation;
- adds Microsoft's official repository for VS Code;
- adds Docker's official repository for Docker Engine;
- downloads IntelliJ directly from JetBrains;
- downloads and executes the official Oh My Zsh installer;
- clones and executes the official Chicago95 installer in a temporary directory after applying and validating project restrictions;
- does not automatically remove conflicting packages detected by the Docker task;
- does not add the user to the `docker` group;
- preserves customized files found in Chicago95-managed directories instead of silently overwriting them;
- rejects symbolic links or unexpected destinations in Chicago95 managed-copy flows;
- preserves `.zshrc` and incomplete Oh My Zsh content instead of overwriting them;
- does not install Helvetica or modify global font configuration.

---

`Debian XFCE Setup` aims to make Debian XFCE preparation repeatable and inspectable without hiding administrative actions, managed files, or the limits of each integration.
