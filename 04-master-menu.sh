#!/bin/bash
while true; do
  echo "1) Install Panels"
  echo "2) Install Themes"
  echo "3) Install Addons"
  echo "4) Exit"
  read -rp "Choose: " c
  case $c in
    1) bash 01-install-panels.sh ;;
    2) bash 02-install-themes.sh ;;
    3) bash 03-install-addons.sh ;;
    4) exit 0 ;;
  esac
done
