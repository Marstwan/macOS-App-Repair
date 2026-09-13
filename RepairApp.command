#!/bin/bash
# RepairApp.command - Professional Standard Edition v3
# https://github.com/Marstwan/macOS-App-Repair/

RESET='\033[0m'
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'

# --- Path cleanup helper (handles quoting/escaping from drag & drop) ---
clean_path() {
    local raw="$1"
    local cleaned="$raw"
    cleaned="${cleaned#"${cleaned%%[![:space:]]*}"}"   # ltrim
    cleaned="${cleaned%"${cleaned##*[![:space:]]}"}"   # rtrim

    if [[ "$cleaned" == \"*\" && "$cleaned" == *\" ]]; then
        cleaned="${cleaned%\"}"
        cleaned="${cleaned#\"}"
    elif [[ "$cleaned" == \'*\' && "$cleaned" == *\' ]]; then
        cleaned="${cleaned%\'}"
        cleaned="${cleaned#\'}"
    else
        cleaned="${cleaned//\\ / }"
        cleaned="${cleaned//\\\(/\(}"
        cleaned="${cleaned//\\\)/\)}"
        cleaned="${cleaned//\\\'/\'}"
    fi
    printf '%s' "$cleaned"
}

prompt_for_app() {
    local app_path cleaned_path
    while true; do
        read -rep "Application path (.app): " app_path
        cleaned_path="$(clean_path "$app_path")"
        if [ -d "$cleaned_path" ]; then
            printf '%s' "$cleaned_path"
            return 0
        else
            echo -e "${RED}ERROR:${RESET} The path '$cleaned_path' is NOT a valid directory."
        fi
    done
}

continue_message() {
    echo -e ""
    read -rp "Press Enter to continue..." _
}

# --- Option 1: Repair app (remove quarantine attributes) ---
repair_app() {
    local path
    path="$(prompt_for_app)"

    echo -e ""
    echo -e "Checking extended attributes for $path..."
    xattr_output=$(xattr -l "$path" 2>&1)
    xattr_exit_code=$?
    
    if [ $xattr_exit_code -ne 0 ]; then
        echo -e "${RED}CRITICAL ERROR:${RESET} Failed to read attributes."
        echo -e "$xattr_output"
        continue_message
        return
    elif [ -z "$xattr_output" ]; then
        echo -e "${YELLOW}NOTICE:${RESET} No extended attributes found. App may already be clean."
    else
        echo -e "Attributes found. Removing..."
    fi
    
    sudo xattr -cr "$path"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}SUCCESS:${RESET} Quarantine attributes removed from $path."
        echo -e "If the app still refuses to open or says it's 'damaged', try option 2 (Self-sign)."
    else
        echo -e "${RED}FATAL ERROR:${RESET} Something went wrong removing attributes."
    fi
    continue_message
}

# --- Option 2: Self-sign the app (fixes "app is damaged" after modification) ---
self_sign_app() {
    local path
    path="$(prompt_for_app)"

    echo -e "Self-signing (ad-hoc) $path..."
    sudo codesign -f -s - --deep "$path"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}SUCCESS:${RESET} App re-signed. It should open normally now."
    else
        echo -e "${RED}ERROR:${RESET} codesign failed. Try running the repair (option 1) first."
    fi
    continue_message
}

# --- Option 3: Show Gatekeeper status ---
show_status() {
    echo -e "${CYAN}Checking Gatekeeper status...${RESET}"
    sudo spctl --status
    continue_message
}

show_menu() {
    clear
    echo -e "====================================================="
    echo -e "   App Repair Tool for macOS (xattr / codesign)      "
    echo -e "====================================================="
    echo -e ""
    echo -e "${BOLD}1)${RESET} Repair app (remove quarantine attributes)  ${CYAN}<- most common fix${RESET}"
    echo -e "${BOLD}2)${RESET} Self-sign app (fixes 'app is damaged')"
    echo -e "${BOLD}3)${RESET} Show Gatekeeper status"
    echo -e "${BOLD}4)${RESET} Quit"
    echo -e ""
}

while true; do
    show_menu
    read -rp "Select an option [1-4]: " option
    case "$option" in
        1) repair_app ;;
        2) self_sign_app ;;
        3) show_status ;;
        4) echo -e "Bye."; exit 0 ;;
        *) echo -e "${RED}Invalid option.${RESET}"; sleep 1 ;;
    esac
done
