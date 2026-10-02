# Debian XFCE Setup

<p align="center">
  <strong>A small interactive setup script for turning a fresh Debian XFCE installation into a ready-to-use development environment.</strong>
</p>

<p align="center">
  <a href="https://www.debian.org/"><img src="https://img.shields.io/badge/Debian-XFCE-A81D33?logo=debian&logoColor=white" alt="Debian XFCE"></a>
  <a href="https://www.gnu.org/software/bash/"><img src="https://img.shields.io/badge/Bash-5%2B-4EAA25?logo=gnubash&logoColor=white" alt="Bash 5+"></a>
  <img src="https://img.shields.io/badge/UI-pt--BR%20%7C%20English-555555" alt="pt-BR and English">
  <img src="https://img.shields.io/badge/status-active-success" alt="Status: active">
</p>

<p align="center">
  <img src="assets/demo.gif" alt="Debian XFCE Setup interface" width="800">
</p>

## What it does

`Debian XFCE Setup` provides a `whiptail` interface where you choose exactly what you want to install or configure.

It can handle development tools, desktop applications, Docker, Zsh + Oh My Zsh, timezone/NTP, an optional X11 keyboard fix, Chicago95 integration, Inter font availability, and audio/microphone guidance.

The interface is available in **English** and **Portuguese**, selected manually on every run.

## Highlights

- Interactive and selective — run one task or use `ALL`.
- Java, Maven, Git, VS Code, IntelliJ IDEA and KeePassXC.
- Docker Engine + Compose + Buildx from Docker's official repository.
- Zsh + Oh My Zsh.
- Optional Chicago95 integration with project-controlled safeguards.
- Persistent X11/XFCE fix for `\\` and `|` on affected keyboards.
- Re-runnable: existing installations and managed configuration are detected where appropriate.

## Quick start

```bash
git clone https://github.com/conradomrosa/debian-xfce-setup.git
cd debian-xfce-setup
chmod +x setup.sh
./setup.sh
```

> Run it as a normal user — **do not use `sudo ./setup.sh`**.

## Documentation

This README is intentionally short.

For installation behavior, task details, managed files, limitations and security notes, see the **[full English documentation](DOCS-en.md)**.

Also available in **[Portuguese](DOCS.md)**.

---

<p align="center">
  <sub>Built for Debian + XFCE, with explicit choices and as little hidden behavior as possible.</sub>
</p>
