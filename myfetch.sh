#!/bin/bash

# --- KONFIGURACJA ---
IMAGE_PATH="gg.jpg" 
IMG_WIDTH=35
IMG_HEIGHT=15

# --- KOLORY ---
RESET="\e[0m"
BOLD="\e[1m"
CYAN="\e[36m"
MAGENTA="\e[35m"
GREEN="\e[32m"

# --- POBIERANIE DANYCH ---
OS="Arch Linux"
KERNEL=$(uname -r)
UPTIME=$(uptime -p | sed 's/up //')
SHELL_NAME=$(basename "$SHELL")
PACKAGES=$(pacman -Q | wc -l)

# RAM: Pobieranie użytego i całkowitego (np. 2.4G / 16G)
RAM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
RAM_USED=$(free -h | awk '/^Mem:/ {print $3}')

# GPU: Wyciąganie nazwy karty graficznej (lspci)
GPU=$(lspci | grep -i 'vga\|3d' | cut -d ':' -f3 | sed 's/\[.*\]//g' | xargs | cut -c1-25)

# DYSK: Użycie partycji głównej /
DISK_INFO=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')

# --- WYŚWIETLANIE ---
clear

echo -e "${CYAN}${BOLD}"
figlet -f small "I use Arch, BTW"
echo -e "${RESET}"

# 1. Rysujemy obrazek (Chafa lub Kitty icat)
if [ -f "$IMAGE_PATH" ]; then
    # Jeśli używasz Kitty, możesz zmienić chafa na: kitten icat --align left "$IMAGE_PATH"
    chafa -s "${IMG_WIDTH}x${IMG_HEIGHT}" "$IMAGE_PATH"
else
    echo -e "Nie znaleziono pliku: $IMAGE_PATH"
fi

# 2. Ustawienie tekstu obok obrazka
MOVE_UP="\e[${IMG_HEIGHT}A"
MOVE_RIGHT="\e[$((IMG_WIDTH + 6))C"

echo -e "${MOVE_UP}${MOVE_RIGHT}${MAGENTA}${BOLD}${USER}@$(hostname)${RESET}"
echo -e "${MOVE_RIGHT}${CYAN}-------------------------${RESET}"
echo -e "${MOVE_RIGHT}${BOLD}OS:${RESET}      $OS"
echo -e "${MOVE_RIGHT}${BOLD}Kernel:${RESET}  $KERNEL"
echo -e "${MOVE_RIGHT}${BOLD}Uptime:${RESET}  $UPTIME"
echo -e "${MOVE_RIGHT}${BOLD}Pkgs:${RESET}    $PACKAGES (pacman)"
echo -e "${MOVE_RIGHT}${BOLD}Shell:${RESET}   $SHELL_NAME"
echo -e "${MOVE_RIGHT}${CYAN}-------------------------${RESET}"
echo -e "${MOVE_RIGHT}${BOLD}GPU:${RESET}     $GPU"
echo -e "${MOVE_RIGHT}${BOLD}RAM:${RESET}     $RAM_USED / $RAM_TOTAL"
echo -e "${MOVE_RIGHT}${BOLD}Disk /:${RESET}  $DISK_INFO"
echo -e "${MOVE_RIGHT}${CYAN}-------------------------${RESET}"

# Kolorowe kwadraciki
echo -ne "${MOVE_RIGHT}"
echo -e "\e[41m   \e[42m   \e[43m   \e[44m   \e[45m   \e[46m   \e[0m"

echo -e "\n"
