#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "   Lumina System Manager - Linux Installer"
echo "=========================================================="

RELEASE_BASE="https://raw.githubusercontent.com/Petr-Harnach/lumina-releases/main"
INSTALL_DIR="/usr/local/share/lumina"
BIN_DIR="/usr/local/bin"
DESKTOP_DIR="/usr/share/applications"

# 1. Install runtime dependencies based on distro
echo "[1/4] Kontrola a instalace systémových závislostí..."
if command -v apt-get &> /dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq curl unzip libgtk-3-0 libwebkit2gtk-4.1-0 || sudo apt-get install -y -qq libwebkit2gtk-4.0-37
elif command -v pacman &> /dev/null; then
    sudo pacman -Sy --noconfirm curl unzip gtk3 webkit2gtk-4.1
elif command -v dnf &> /dev/null; then
    sudo dnf install -y curl unzip gtk3 webkit2gtk4.1
fi

# 2. Prepare directories
echo "[2/4] Příprava instalačních adresářů..."
sudo mkdir -p "$INSTALL_DIR"
sudo mkdir -p "$BIN_DIR"
sudo mkdir -p "$DESKTOP_DIR"

# 3. Download public UI payload and assets
echo "[3/4] Stahování aplikačních součástí z lumina-releases..."
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

curl -sSL "$RELEASE_BASE/public.zip" -o "$TMP_DIR/public.zip"
sudo rm -rf "$INSTALL_DIR/public"
sudo unzip -q "$TMP_DIR/public.zip" -d "$INSTALL_DIR/public"

curl -sSL "$RELEASE_BASE/app.ico" -o "$TMP_DIR/app.ico"
sudo cp "$TMP_DIR/app.ico" "$INSTALL_DIR/app.ico"

# 4. Download Linux executable or compile micro-runner if architecture specific
echo "[4/4] Konfigurace spouštěče Lumina..."
ARCH=$(uname -m)
if curl --output /dev/null --silent --head --fail "$RELEASE_BASE/lumina-$ARCH"; then
    sudo curl -sSL "$RELEASE_BASE/lumina-$ARCH" -o "$BIN_DIR/lumina"
    sudo chmod +x "$BIN_DIR/lumina"
elif curl --output /dev/null --silent --head --fail "$RELEASE_BASE/lumina"; then
    sudo curl -sSL "$RELEASE_BASE/lumina" -o "$BIN_DIR/lumina"
    sudo chmod +x "$BIN_DIR/lumina"
fi

# Create standard Desktop Entry
cat << 'EOF' | sudo tee "$DESKTOP_DIR/lumina.desktop" > /dev/null
[Desktop Entry]
Name=Lumina System Manager
Comment=Nativní nástroj pro optimalizaci, čištění a správu systému
Exec=lumina
Icon=/usr/local/share/lumina/app.ico
Terminal=false
Type=Application
Categories=System;Utility;Settings;
StartupNotify=true
EOF

echo "=========================================================="
echo "  Instalace dokončena! Aplikaci spustíte příkazem: lumina"
echo "  nebo vyhledáním 'Lumina' v systémovém menu aplikací."
echo "=========================================================="
