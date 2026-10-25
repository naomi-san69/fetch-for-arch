#!/bin/bash

# Sprawdź czy figlet jest zainstalowany, jak nie to poinformuj
if ! command -v figlet &> /dev/null; then
    echo "Brak narzędzia figlet! Zainstaluj je poleceniem: sudo pacman -S figlet"
    exit 1
fi

# --- AUTOMATYCZNE POBIERANIE DANYCH ---
OS="Arch Linux"
HOST=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || hostname)
KERNEL=$(uname -r)
UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "N/A")
PACKAGES="$(pacman -Q 2>/dev/null | wc -l) (pacman)"
SHELL_NAME=$(basename "$SHELL")
DISPLAY_RES=$(xrandr 2>/dev/null | grep '\*' | awk '{print $1}' | head -n 1 || echo "$DISPLAY")
TERMINAL=${TERM_PROGRAM:-$TERM}

CPU=$(lscpu 2>/dev/null | grep -E 'Model name|Nazwa modelu' | cut -d ':' -f2 | xargs | cut -c1-28)
[ -z "$CPU" ] && CPU=$(grep -m 1 'model name' /proc/cpuinfo 2>/dev/null | cut -d ':' -f2 | xargs | cut -c1-28)

GPU=$(lspci 2>/dev/null | grep -i 'vga\|3d' | cut -d ':' -f3 | sed 's/\[.*\]//g' | xargs | cut -c1-25)

# RAM
MEM_TOTAL_KB=$(awk '/MemTotal:/ {print $2}' /proc/meminfo 2>/dev/null)
MEM_AVAIL_KB=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo 2>/dev/null)
if [ -n "$MEM_TOTAL_KB" ] && [ -n "$MEM_AVAIL_KB" ]; then
    MEM_USED_KB=$((MEM_TOTAL_KB - MEM_AVAIL_KB))
    RAM_USED=$(awk "BEGIN {printf \"%.1f\", $MEM_USED_KB/1048576}")
    RAM_TOTAL=$(awk "BEGIN {printf \"%.1f\", $MEM_TOTAL_KB/1048576}")
    MEMORY="${RAM_USED}GiB / ${RAM_TOTAL}GiB"
else
    MEMORY="N/A"
fi

# SWAP
SWAP_USED=$(free -m 2>/dev/null | awk '/^Swap:/ {printf "%.1f", $3/1024}')
SWAP_TOTAL=$(free -m 2>/dev/null | awk '/^Swap:/ {printf "%.1f", $2/1024}')
if [ -z "$SWAP_TOTAL" ] || [ "$SWAP_TOTAL" = "0.0" ]; then
    SWAP="Brak"
else
    SWAP="${SWAP_USED}GiB / ${SWAP_TOTAL}GiB"
fi

# DYSKI
DISK_ROOT=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
DISK_SDA=$(df -h /dev/sda 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
[ -z "$DISK_SDA" ] && DISK_SDA="N/A"

BATTERY=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1 | awk '{print $1 "%"}' || echo "N/A")
LOCALE=$LANG

# --- KOLORY I STYLE ---
RESET="\e[0m"
BOLD="\e[1m"
CYAN="\e[36m"
MAGENTA="\e[35m"

# --- PRZYGOTOWANIE LISTY INFORMACJI ---
INFO_TEXT=(
    "${MAGENTA}${BOLD}${USER}@${HOSTNAME}${RESET}"
    "${CYAN}-------------------------${RESET}"
    "$(printf "${BOLD}%-14s${RESET} %s" "OS:" "$OS")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Host:" "$HOST")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Kernel:" "$KERNEL")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Uptime:" "$UPTIME")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Packages:" "$PACKAGES")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Shell:" "$SHELL_NAME")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Display:" "$DISPLAY_RES")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Terminal:" "$TERMINAL")"
    "$(printf "${BOLD}%-14s${RESET} %s" "CPU:" "$CPU")"
    "$(printf "${BOLD}%-14s${RESET} %s" "GPU:" "$GPU")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Memory:" "$MEMORY")"
    "$(printf "${BOLD}%-14s${RESET} %s" "SWAP:" "$SWAP")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Disk (/):" "$DISK_ROOT")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Disk (/dev/sda):" "$DISK_SDA")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Battery:" "$BATTERY")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Locale:" "$LOCALE")"
    "${CYAN}-------------------------${RESET}"
    "$(printf "${BOLD}%-14s${RESET} %s" "Nazuna:" "True")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Astolfo:" "True")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Felix:" "True")"
)

# --- WYŚWIETLANIE OBOK FIGLETA ---
clear

# Generowanie napisu figlet do tablicy linii (używam czcionki 'standard' lub domyślnej)
mapfile -t ASCII_LINES < <(figlet -f standard "Fem-Arch")

MAX_LINES=${#ASCII_LINES[@]}
[ ${#INFO_TEXT[@]} -gt $MAX_LINES ] && MAX_LINES=${#INFO_TEXT[@]}

for ((i=0; i<MAX_LINES; i++)); do
    art_line="${ASCII_LINES[$i]}"
    info_line="${INFO_TEXT[$i]}"
    # szerokość bloku figleta ustawiona na 45 znaków
    printf "${MAGENTA}%-45s${RESET} %b\n" "$art_line" "$info_line"
done

echo -e "\n"
