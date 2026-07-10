#!/bin/bash

# Directory where this script resides (the repo root)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Syncing configs from home directories to repo..."

# Create necessary directories
mkdir -p "$REPO_DIR/config"

# Config directories to copy
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
  if [ -d "$HOME/.config/$dir" ]; then
    echo "Copying ~/.config/$dir..."
    rm -rf "$REPO_DIR/config/$dir"
    cp -r "$HOME/.config/$dir" "$REPO_DIR/config/"
  fi
done

# Individual config files to copy
CONFIG_FILES=(
  "QtProject.conf"
  "dolphinrc"
  "mimeapps.list"
  "pavucontrol.ini"
  "starship.toml"
)

for file in "${CONFIG_FILES[@]}"; do
  if [ -f "$HOME/.config/$file" ]; then
    echo "Copying ~/.config/$file..."
    cp "$HOME/.config/$file" "$REPO_DIR/config/"
  fi
done

# Home files to copy
HOME_FILES=(
  ".zshrc"
  ".p10k.zsh"
  ".zprofile"
  ".bashrc"
  ".profile"
)

for file in "${HOME_FILES[@]}"; do
  if [ -f "$HOME/$file" ]; then
    # strip dot from filename for repo
    repo_file="${file#.}"
    echo "Copying ~/$file -> $repo_file..."
    cp "$HOME/$file" "$REPO_DIR/$repo_file"
  fi
done

# Wallpapers
if [ -d "$HOME/wallpapers" ]; then
  echo "Copying ~/wallpapers..."
  rm -rf "$REPO_DIR/wallpapers"
  cp -r "$HOME/wallpapers" "$REPO_DIR/"
fi

# Clean up Rust target directories
echo "Cleaning up build artifacts/target directories..."
find "$REPO_DIR" -type d -name "target" -exec rm -rf {} + 2>/dev/null

# Clean up nested git folders
echo "Cleaning up nested git directories..."
find "$REPO_DIR" -mindepth 2 -type d -name ".git" -exec rm -rf {} + 2>/dev/null

echo "Sync complete!"
