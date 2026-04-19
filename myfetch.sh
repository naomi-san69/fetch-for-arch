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

RAM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
RAM_USED=$(free -h | awk '/^Mem:/ {print $3}')

GPU=$(lspci | grep -i 'vga\|3d' | cut -d ':' -f3 | sed 's/\[.*\]//g' | xargs | cut -c1-25)

# NOWE: Pobieranie wszystkich fizycznych dysków (filtrujemy śmieci systemowe)
# Wyświetli: / (2G/20G) oraz inne punkty montowania
DISKS_DATA=$(df -h -x tmpfs -x devtmpfs -x squashfs -x efivarfs | awk 'NR>1 {print $6 " (" $3 "/" $2 " - " $5 ")"}')

# --- WYŚWIETLANIE ---
clear

echo -e "${CYAN}${BOLD}"
figlet -f small "I use Arch, BTW"
echo -e "${RESET}"

if [ -f "$IMAGE_PATH" ]; then
    chafa -s "${IMG_WIDTH}x${IMG_HEIGHT}" "$IMAGE_PATH"
else
    echo -e "Nie znaleziono pliku: $IMAGE_PATH"
fi

# Pozycjonowanie tekstu
MOVE_UP="\e[${IMG_HEIGHT}A"
MOVE_RIGHT="\e[$((IMG_WIDTH + 6))C"

echo -e "${MOVE_UP}${MOVE_RIGHT}${MAGENTA}${BOLD}${USER}@${HOSTNAME}${RESET}"
echo -e "${MOVE_RIGHT}${CYAN}-------------------------${RESET}"
echo -e "${MOVE_RIGHT}${BOLD}OS:${RESET}      $OS"
echo -e "${MOVE_RIGHT}${BOLD}Kernel:${RESET}  $KERNEL"
echo -e "${MOVE_RIGHT}${BOLD}Uptime:${RESET}  $UPTIME"
echo -e "${MOVE_RIGHT}${BOLD}Pkgs:${RESET}    $PACKAGES (pacman)"
echo -e "${MOVE_RIGHT}${BOLD}Shell:${RESET}   $SHELL_NAME"
echo -e "${MOVE_RIGHT}${CYAN}-------------------------${RESET}"
echo -e "${MOVE_RIGHT}${BOLD}GPU:${RESET}     $GPU"
echo -e "${MOVE_RIGHT}${BOLD}RAM:${RESET}     $RAM_USED / $RAM_TOTAL"

# NOWA PĘTLA WYŚWIETLAJĄCA DYSKI
while read -r line; do
    [ -z "$line" ] && continue
    echo -e "${MOVE_RIGHT}${BOLD}Disk:${RESET}    $line"
done <<< "$DISKS_DATA"

echo -e "${MOVE_RIGHT}${CYAN}-------------------------${RESET}"

# Kolorowe kwadraciki
echo -ne "${MOVE_RIGHT}"
echo -e "\e[41m   \e[42m   \e[43m   \e[44m   \e[45m   \e[46m   \e[0m"

echo -e "\n"