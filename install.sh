#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "       Lumina System Manager 1.3.0 - Linux Installer      "
echo "=========================================================="

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "--> Stahuji Lumina System Manager release balíček..."
if command -v curl &> /dev/null; then
    curl -sSL "https://raw.githubusercontent.com/Petr-Harnach/lumina-releases/main/lumina-linux.tar.gz" -o "$TMP_DIR/lumina.tar.gz"
elif command -v wget &> /dev/null; then
    wget -q "https://raw.githubusercontent.com/Petr-Harnach/lumina-releases/main/lumina-linux.tar.gz" -O "$TMP_DIR/lumina.tar.gz"
else
    echo "Chyba: V systému není nainstalován curl ani wget pro stažení."
    exit 1
fi

echo "--> Rozbaluji..."
tar -xzf "$TMP_DIR/lumina.tar.gz" -C "$TMP_DIR"

echo "--> Spouštím instalaci a sestavení..."
cd "$TMP_DIR/lumina-linux"
chmod +x install.sh
./install.sh
