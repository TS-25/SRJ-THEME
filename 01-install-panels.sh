#!/bin/bash
set -e
warning() {
  echo "WARNING: Panel may reset. Backup first."
  read -rp "Continue? (yes/no): " c
  [[ $c =~ ^(yes|y)$ ]] || exit 1
}
install_reviactyl() {
  warning
  bash <(curl -s https://raw.githubusercontent.com/TS-25/SRJ-THEME/refs/heads/main/reviactyl)
}
echo "1) Install Reviactyl"
read -rp "Choose: " c
case $c in
  1) install_reviactyl ;;
esac
