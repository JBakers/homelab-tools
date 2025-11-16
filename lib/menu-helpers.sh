#!/bin/bash
# Shared menu helper functions for Homelab Tools
# Provides arrow key navigation, consistent colors, and menu rendering
# Author: J.Bakers
# Version: 3.5.0-dev.16

# Standard menu colors
readonly MENU_CYAN='\033[0;36m'
readonly MENU_GREEN='\033[0;32m'
readonly MENU_YELLOW='\033[1;33m'
readonly MENU_RED='\033[0;31m'
readonly MENU_MAGENTA='\033[0;35m'
readonly MENU_BOLD='\033[1m'
readonly MENU_RESET='\033[0m'
readonly MENU_INVERSE='\033[7m'

# Read a single key including arrow keys and ESC
# Returns: KEY_UP, KEY_DOWN, KEY_ENTER, KEY_ESC, or typed character
read_key() {
    local key
    read -rsn1 key 2>/dev/null

    # Handle ESC sequences (arrow keys)
    if [[ $key == $'\x1b' ]]; then
        # Read next 2 characters
        read -rsn2 -t 0.1 key 2>/dev/null
        case "$key" in
            '[A') echo "KEY_UP" ;;
            '[B') echo "KEY_DOWN" ;;
            '') echo "KEY_ESC" ;;  # Just ESC, no follow-up
            *) echo "KEY_ESC" ;;   # Unknown ESC sequence
        esac
    elif [[ $key == "" ]]; then
        echo "KEY_ENTER"
    else
        # Regular character (for easter eggs, etc.)
        echo "$key"
    fi
}

# Render a menu with arrow key navigation
# Usage: show_arrow_menu "Title" "Option 1|desc" "Option 2|desc" ...
# Last options can be: "HELP" "BACK" "QUIT"
# Returns: Selected index (0-based)
show_arrow_menu() {
    local title="$1"
    shift
    local -a options=("$@")
    local selected=0
    local option_count=${#options[@]}
    local key
    local typed_buffer=""  # For easter egg detection

    while true; do
        # Clear screen and render menu
        clear

        # Title box
        echo -e "${MENU_BOLD}${MENU_CYAN}╔══════════════════════════════════════════════════════════╗"
        printf "║ %-56s ║\n" "$title"
        echo -e "╚══════════════════════════════════════════════════════════╝${MENU_RESET}"
        echo ""

        # Render options
        local idx=0
        local is_footer=false
        for option in "${options[@]}"; do
            # Check if this is a footer option
            if [[ "$option" == "HELP" ]] || [[ "$option" == "BACK" ]] || [[ "$option" == "QUIT" ]]; then
                if [[ "$is_footer" == "false" ]]; then
                    echo ""
                    echo -e "${MENU_CYAN}────────────────────────────────────────────────────────────${MENU_RESET}"
                    is_footer=true
                fi
            fi

            # Parse option (format: "Label|Description" or just "HELP"/"BACK"/"QUIT")
            local label desc color
            if [[ "$option" =~ \| ]]; then
                label="${option%%|*}"
                desc="${option##*|}"
            else
                label="$option"
                desc=""
            fi

            # Determine color based on option type
            if [[ "$label" == "HELP" ]]; then
                color="$MENU_CYAN"
                label="Help"
                desc="Show detailed help"
            elif [[ "$label" == "BACK" ]]; then
                color="$MENU_YELLOW"
                label="Back"
                desc="Return to previous menu"
            elif [[ "$label" == "QUIT" ]]; then
                color="$MENU_RED"
                label="Quit"
                desc="Exit homelab tools"
            else
                color="$MENU_GREEN"
            fi

            # Highlight if selected
            if [[ $idx -eq $selected ]]; then
                echo -e "  ${MENU_INVERSE}${MENU_BOLD}> ${label}${MENU_RESET}${MENU_BOLD}${desc:+ - $desc}${MENU_RESET}"
            else
                echo -e "  ${color}  ${label}${MENU_RESET}${desc:+ - $desc}"
            fi

            ((idx++))
        done

        echo ""
        echo -e "${MENU_CYAN}════════════════════════════════════════════════════════════${MENU_RESET}"
        echo -e "${MENU_BOLD}Use ↑/↓ to navigate, Enter to select, ESC to go back${MENU_RESET}"

        # Read key
        key=$(read_key)

        # Handle input
        case "$key" in
            KEY_UP)
                ((selected--))
                if [[ $selected -lt 0 ]]; then
                    selected=$((option_count - 1))
                fi
                ;;
            KEY_DOWN)
                ((selected++))
                if [[ $selected -ge $option_count ]]; then
                    selected=0
                fi
                ;;
            KEY_ENTER)
                echo "$selected"
                return 0
                ;;
            KEY_ESC)
                # ESC behavior: return special code -1
                echo "-1"
                return 0
                ;;
            *)
                # Typed character - add to buffer for easter egg detection
                typed_buffer="${typed_buffer}${key}"

                # Keep buffer at max 10 chars
                if [[ ${#typed_buffer} -gt 10 ]]; then
                    typed_buffer="${typed_buffer: -10}"
                fi

                # Check for easter egg
                if [[ "$typed_buffer" == *"iddqd"* ]]; then
                    echo "IDDQD"
                    return 0
                fi
                ;;
        esac
    done
}

# Simple confirmation dialog
# Usage: confirm_dialog "Question?" ["Yes text" "No text"]
# Returns: 0 for yes, 1 for no
confirm_dialog() {
    local question="$1"
    local yes_text="${2:-Yes}"
    local no_text="${3:-No}"

    local result
    result=$(show_arrow_menu "$question" "$yes_text" "$no_text")

    if [[ "$result" == "0" ]]; then
        return 0
    else
        return 1
    fi
}

# Show a progress bar (for bulk operations)
# Usage: show_progress current total hostname status
show_progress() {
    local current=$1
    local total=$2
    local hostname=$3
    local status=$4

    # Calculate percentage
    local percent=$(( current * 100 / total ))

    # Progress bar (20 chars wide)
    local filled=$(( percent / 5 ))
    local empty=$(( 20 - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done

    # Move cursor to top and render
    tput cup 0 0
    echo -e "${MENU_BOLD}${MENU_CYAN}╔══════════════════════════════════════════════════════════╗"
    echo -e "║         📝 Processing MOTDs...                           ║"
    echo -e "╚══════════════════════════════════════════════════════════╝${MENU_RESET}"
    echo ""
    echo -e "${MENU_BOLD}Progress:${MENU_RESET} [${MENU_CYAN}${bar}${MENU_RESET}] ${MENU_BOLD}${percent}%${MENU_RESET} (${current}/${total} hosts)"
    echo ""
    echo -e "${MENU_BOLD}Current:${MENU_RESET}  ${MENU_CYAN}${hostname}${MENU_RESET}"
    echo -e "${MENU_BOLD}Status:${MENU_RESET}   ${status}"
    echo ""
}

# Initialize progress display (clear screen, hide cursor)
init_progress() {
    clear
    tput civis  # Hide cursor
}

# Finalize progress display (show cursor)
finish_progress() {
    tput cnorm  # Show cursor
}
