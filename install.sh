#!/bin/bash

cd "$(dirname "$0")"

[[ ! -f /etc/arch-release ]] && echo "This script is designed for Arch Linux." && exit 1
[[ ! -d config ]] && echo "Can't find config directory in repository." && exit 1

install_deps() {
  echo "Installing official packages..."
  sudo pacman -S --needed hyprland hyprlock hypridle kitty thunar swww swaync cava fastfetch starship python-pywal kdeconnect grim slurp mpd mpc ttf-jetbrains-mono-nerd alsa-utils networkmanager bluez bluez-utils wireplumber brightnessctl playerctl imagemagick fish neovim || exit 1

  if command -v yay &>/dev/null; then
    echo "Installing AUR packages via yay..."
    yay -S --needed gpu-screen-recorder rmpc mpd-mpris quickshell-git swayosd-git
  elif command -v paru &>/dev/null; then
    echo "Installing AUR packages via paru..."
    paru -S --needed gpu-screen-recorder rmpc mpd-mpris quickshell-git swayosd-git
  else
    echo "No AUR helper found, skipping AUR packages."
    echo "Please install: yay -S gpu-screen-recorder rmpc mpd-mpris quickshell-git swayosd-git"
  fi

  sudo systemctl enable --now NetworkManager 2>/dev/null
  sudo systemctl enable --now bluetooth 2>/dev/null
}

install_configs() {
  mkdir -p ~/.config ~/.local/bin ~/wallpapers

  backup=~/.dotfiles-backup-$(date +%s)
  mkdir -p "$backup"
  echo "Created backup directory at $backup"

  # Config directories
  CONFIG_DIRS=(
    "hypr"
    "kitty"
    "quickshell"
    "swaync"
    "scripts"
    "wal"
    "templates"
    "fastfetch"
    "cava"
    "fish"
    "swayosd"
    "gtk-3.0"
    "Thunar"
    "nvim"
  )

  for dir in "${CONFIG_DIRS[@]}"; do
    if [[ -e ~/.config/"$dir" ]]; then
      mv ~/.config/"$dir" "$backup"/
    fi
    if [[ -d config/"$dir" ]]; then
      cp -r config/"$dir" ~/.config/
    fi
  done

  # Individual config files
  CONFIG_FILES=(
    "QtProject.conf"
    "dolphinrc"
    "mimeapps.list"
    "pavucontrol.ini"
    "starship.toml"
  )

  for file in "${CONFIG_FILES[@]}"; do
    if [[ -e ~/.config/"$file" ]]; then
      mv ~/.config/"$file" "$backup"/
    fi
    if [[ -f config/"$file" ]]; then
      cp config/"$file" ~/.config/
    fi
  done

  # Home directory configuration files
  HOME_FILES=(
    ".zshrc"
    ".p10k.zsh"
    ".zprofile"
    ".bashrc"
    ".profile"
  )

  for file in "${HOME_FILES[@]}"; do
    # File name in repository does not start with a dot
    repo_file="${file#.}"
    if [[ -e ~/"$file" ]]; then
      mv ~/"$file" "$backup"/
    fi
    if [[ -f "$repo_file" ]]; then
      cp "$repo_file" ~/"$file"
    fi
  done

  # Wallpapers
  if [[ -d wallpapers ]]; then
    echo "Installing wallpapers to ~/wallpapers/..."
    cp -n wallpapers/* ~/wallpapers/ 2>/dev/null
  fi

  # Helper script for quickshell
  echo '#!/bin/bash
pkill quickshell; nohup quickshell &>/dev/null &' > ~/.local/bin/start-quickshell.sh
  chmod +x ~/.local/bin/start-quickshell.sh

  # Ensure scripts are executable
  chmod +x ~/.config/scripts/* 2>/dev/null

  echo "Configs successfully installed!"
}

case "$1" in
  deps)
    install_deps
    echo "Dependencies installed."
    ;;
  configs)
    install_configs
    echo "Configs installed. Please log out and back in."
    ;;
  *)
    echo "First time setup? [y/n]"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      install_deps
      install_configs
      echo ""
      echo "Done! Please log out and log back in."
      echo "Then you can run: ~/.config/scripts/random-wallpaper.sh"
    else
      install_configs
      echo ""
      echo "Configs updated. Please log out and log back in."
    fi
    ;;
esac
