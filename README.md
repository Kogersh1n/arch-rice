# Arch Linux Rice 🏔️

A beautifully customized and dynamic Hyprland desktop environment rice, featuring automated color themes powered by Pywal, custom UI components via Quickshell, and custom scripts.

## Components & Tools
* **WM**: [Hyprland](https://hyprland.org/)
* **Shell**: `zsh` (with [Powerlevel10k](https://github.com/romkatv/powerlevel10k)) / `fish`
* **Terminal**: [Kitty](https://sw.kovidgoyal.net/kitty/)
* **Shell UI/Bar**: [Quickshell](https://github.com/outfoxxed/quickshell)
* **Themes**: [Pywal](https://github.com/dylanaraps/pywal) (generates color palettes from wallpapers)
* **Notification Daemon**: [SwayNC](https://github.com/ErikReider/SwayNotificationCenter)
* **OSD**: [SwayOSD](https://github.com/ErikReider/SwayOSD) (Volume, Brightness, Caps Lock overlays)
* **File Manager**: Thunar / Dolphin
* **Visualizer**: [Cava](https://github.com/karlstav/cava)
* **System Info**: [Fastfetch](https://github.com/fastfetch-cli/fastfetch)

---

## Installation

### First Time Setup
To install all package dependencies and configs, clone the repository and run:
```bash
chmod +x install.sh
./install.sh
```
Follow the interactive prompt to choose a full setup (dependencies + configuration files) or just configuration files.

### Manual Actions
If you prefer to install things separately:
* To install dependencies only: `./install.sh deps`
* To apply/update configurations only: `./install.sh configs`

---

## Syncing & Backups
This repository includes a built-in `sync.sh` script to pull any active changes from your system back into this repository directory:
```bash
./sync.sh
```
This script automatically ignores heavy build target folders (e.g. Rust build directories) and collects everything neatly so you can easily run `git push`.

---

## License
MIT License
