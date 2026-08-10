#!/bin/bash

# --- MENU KONFIGURACJI ASCII ---
clear
echo -e "\e[35m\e[1m𐙚 Wybierz jaki ASCII art chcesz wyświetlić: 𐙚\e[0m\n"
echo -e "  \e[36m1)\e[0m Astolfo"
echo -e "  \e[36m2)\e[0m Nazuna"
echo -e "  \e[36m3)\e[0m Flaga Femboy's"
echo -e "  \e[36m4)\e[0m H3nta1 (Opcjonalne ~w~)"
echo -e "  \e[36m5)\e[0m Felix"
echo ""
read -p "Wpisz numer (1-5) [domyślnie 1]: " CHOICE

case $CHOICE in
    2) ASCII_FILE="nazuna-ascii" ;;
    3) ASCII_FILE="femboy-ascii" ;;
    4) ASCII_FILE="hentai-ascii" ;;
    5) ASCII_FILE="felix-ascii" ;;
    1|*) ASCII_FILE="astolfo-ascii" ;;
esac

# --- INTERAKTYWNE MENU WYBORU SEKCJI ---
clear
echo -e "\e[35m\e[1m𐙚 Konfiguracja danych do wyświetlenia (T/n): 𐙚\e[0m\n"

ask_option() {
    local prompt="$1"
    local default="$2"
    read -p "$(echo -e "\e[36m?\e[0m $prompt [T/n]: ")" res
    res=$(echo "$res" | tr '[:upper:]' '[:lower:]')
    if [[ "$res" == "t" || "$res" == "tak" || -z "$res" ]]; then
        return 0
    else
        return 1
    fi
}

ask_option "Pokazać podstawowe info (OS, Host, Kernel, Uptime, Packages)?" && SHOW_BASIC=1 || SHOW_BASIC=0
ask_option "Pokazać środowisko (Shell, Display, Terminal, DE/WM)?" && SHOW_ENV=1 || SHOW_ENV=0
ask_option "Pokazać sprzęt (CPU, GPU, RAM, SWAP)?" && SHOW_HARDWARE=1 || SHOW_HARDWARE=0
ask_option "Pokazać pamięć masową (Dyski)?" && SHOW_DISKS=1 || SHOW_DISKS=0
ask_option "Pokazać sieć i system (IP, Bateria, Locale)?" && SHOW_SYS=1 || SHOW_SYS=0
ask_option "Pokazać aktualnie graną piosenkę (Media/Player)?" && SHOW_MEDIA=1 || SHOW_MEDIA=0
ask_option "Pokazać statystyki Waifu (Nazuna, Astolfo, Felix)?" && SHOW_WAIFUS=1 || SHOW_WAIFUS=0
ask_option "Pokazać flagę Femboyów na dole?" && SHOW_FLAG=1 || SHOW_FLAG=0

# --- KOLORY ---
RESET="\e[0m"
BOLD="\e[1m"
CYAN="\e[36m"
MAGENTA="\e[35m"

PINK_BG="\e[48;2;213;98;151m"
WHITE_BG="\e[48;2;255;255;255m"
PURPLE_BG="\e[48;2;170;111;182m"
FEMBOY_FLAG="${PINK_BG}   ${WHITE_BG}   ${PURPLE_BG}   ${WHITE_BG}   ${PINK_BG}   ${RESET}"

# --- POBIERANIE DANYCH ---
OS="Arch Linux"
HOST=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || hostname)
KERNEL=$(uname -r)
UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "N/A")
PACKAGES="$(pacman -Q 2>/dev/null | wc -l) (pacman)"
SHELL_NAME=$(basename "$SHELL")
DISPLAY_RES=$(xrandr 2>/dev/null | grep '\*' | awk '{print $1}' | head -n 1 || echo "$DISPLAY")
TERMINAL=${TERM_PROGRAM:-$TERM}
DE_WM="${XDG_CURRENT_DESKTOP:-$WM}"
[ -z "$DE_WM" ] && DE_WM="$(basename "$XDG_DATA_DIRS" 2>/dev/null | head -n 1)"

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
MAIN_DISK=$(lsblk -d -n -o NAME,TYPE 2>/dev/null | grep 'disk' | head -n 1 | awk '{print $1}')
if [ -n "$MAIN_DISK" ]; then
    DISK_SDA=$(df -h "/dev/$MAIN_DISK" 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}' || echo "N/A")
else
    DISK_SDA="N/A"
fi

BATTERY=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1 | awk '{print $1 "%"}' || echo "100%")
LOCALE=$LANG
LOCAL_IP=$(ip route get 1 2>/dev/null | awk '{print $7; exit}' || echo "N/A")
MEDIA_SONG=$(playerctl metadata --format '{{title}} - {{artist}}' 2>/dev/null || echo "Brak / Pausa")

# --- PRZYGOTOWANIE TEKSTU ---
INFO_TEXT=(
    "${MAGENTA}${BOLD}𐙚⋆°.🏳️‍⚧️ ˖˚.${RESET}"
    "${MAGENTA}${BOLD}${USER}@${HOSTNAME}${RESET}"
    "${CYAN}-------------------------${RESET}"
)

[ $SHOW_BASIC -eq 1 ] && INFO_TEXT+=(
    "$(printf "${BOLD}%-14s${RESET} %s" "OS:" "$OS")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Host:" "$HOST")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Kernel:" "$KERNEL")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Uptime:" "$UPTIME")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Packages:" "$PACKAGES")"
)

[ $SHOW_ENV -eq 1 ] && INFO_TEXT+=(
    "$(printf "${BOLD}%-14s${RESET} %s" "Shell:" "$SHELL_NAME")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Display:" "$DISPLAY_RES")"
    "$(printf "${BOLD}%-14s${RESET} %s" "DE/WM:" "$DE_WM")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Terminal:" "$TERMINAL")"
)

[ $SHOW_HARDWARE -eq 1 ] && INFO_TEXT+=(
    "$(printf "${BOLD}%-14s${RESET} %s" "CPU:" "$CPU")"
    "$(printf "${BOLD}%-14s${RESET} %s" "GPU:" "$GPU")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Memory:" "$MEMORY")"
    "$(printf "${BOLD}%-14s${RESET} %s" "SWAP:" "$SWAP")"
)

[ $SHOW_DISKS -eq 1 ] && INFO_TEXT+=(
    "$(printf "${BOLD}%-14s${RESET} %s" "Disk (/):" "$DISK_ROOT")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Disk (sys):" "$DISK_SDA")"
)

[ $SHOW_SYS -eq 1 ] && INFO_TEXT+=(
    "$(printf "${BOLD}%-14s${RESET} %s" "Local IP:" "$LOCAL_IP")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Battery:" "$BATTERY")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Locale:" "$LOCALE")"
)

[ $SHOW_MEDIA -eq 1 ] && INFO_TEXT+=(
    "$(printf "${BOLD}%-14s${RESET} %s" "Song:" "$MEDIA_SONG")"
)

[ $SHOW_WAIFUS -eq 1 ] && INFO_TEXT+=(
    "$(printf "${BOLD}%-14s${RESET} %s" "Nazuna:" "True")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Astolfo:" "True")"
    "$(printf "${BOLD}%-14s${RESET} %s" "Felix:" "True")"
)

INFO_TEXT+=("${CYAN}-------------------------${RESET}")
[ $SHOW_FLAG -eq 1 ] && INFO_TEXT+=("$FEMBOY_FLAG")

# --- WYŚWIETLANIE ---
clear

if [ -f "$ASCII_FILE" ]; then
    mapfile -t ASCII_LINES < "$ASCII_FILE"
else
    ASCII_LINES=("Brak pliku: $ASCII_FILE")
fi

MAX_LINES=${#ASCII_LINES[@]}
[ ${#INFO_TEXT[@]} -gt $MAX_LINES ] && MAX_LINES=${#INFO_TEXT[@]}

for ((i=0; i<MAX_LINES; i++)); do
    art_line="${ASCII_LINES[$i]}"
    info_line="${INFO_TEXT[$i]}"
    printf "${CYAN}%-45s${RESET} %b\n" "$art_line" "$info_line"
done

echo -e "\n"