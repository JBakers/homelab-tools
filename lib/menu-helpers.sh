#!/bin/bash
# Shared menu helper functions for Homelab Tools
# Provides arrow key navigation, consistent colors, and menu rendering
# Author: J.Bakers
# Version: See VERSION file

# Standard menu colors
# Note: Using bright/bold variants for better readability on dark terminals
readonly MENU_CYAN='\033[0;96m'      # Bright cyan
readonly MENU_GREEN='\033[0;92m'     # Bright green
readonly MENU_YELLOW='\033[0;93m'    # Bright yellow
readonly MENU_RED='\033[0;95m'       # Magenta (more readable than red)
readonly MENU_BOLD='\033[1m'
readonly MENU_DIM='\033[2m'
readonly MENU_RESET='\033[0m'
readonly MENU_INVERSE='\033[7m'

 

# Read a single key including arrow keys and ESC
# Sets global variable MENU_KEY instead of echoing (to avoid subshell issues)
# MENU_KEY values: KEY_UP, KEY_DOWN, KEY_ENTER, KEY_ESC, KEY_Q, or the typed character
read_key() {
    local key key2 key3 read_status
    MENU_KEY=""
    key=""
    
    # Temporarily disable set -e to handle read timeout properly
    set +e
    
    # Read from the real terminal with timeout
    IFS= read -rsn1 -t 1 key < /dev/tty 2>/dev/null
    read_status=$?
    
    # Re-enable set -e
    set -e
    
    # Timeout returns status > 128
    if [[ $read_status -gt 128 ]]; then
        MENU_KEY=""
        return 0
    fi

    # Handle ESC sequences (arrow keys)
    if [[ $key == $'\x1b' ]]; then
        # Read the bracket (with set +e for timeout safety)
        set +e
        IFS= read -rsn1 -t 0.1 key2 < /dev/tty 2>/dev/null
        set -e
        if [[ $key2 == "[" ]]; then
            # Read the letter (A/B/C/D)
            set +e
            IFS= read -rsn1 -t 0.1 key3 < /dev/tty 2>/dev/null
            set -e
            case "$key3" in
                'A') MENU_KEY="KEY_UP" ;;
                'B') MENU_KEY="KEY_DOWN" ;;
                'C') MENU_KEY="KEY_RIGHT" ;;
                'D') MENU_KEY="KEY_LEFT" ;;
                *) MENU_KEY="KEY_ESC" ;;
            esac
        else
            MENU_KEY="KEY_ESC"
        fi
    elif [[ -z "$key" ]]; then
        # Empty key with successful read (status 0) = ENTER pressed
        MENU_KEY="KEY_ENTER"
    elif [[ "$key" == "q" || "$key" == "Q" ]]; then
        MENU_KEY="KEY_Q"
    elif [[ "$key" == "j" ]]; then
        MENU_KEY="KEY_DOWN"  # vim style
    elif [[ "$key" == "k" ]]; then
        MENU_KEY="KEY_UP"    # vim style
    else
        MENU_KEY="$key"
    fi
    
    return 0
}

# Render a menu with arrow key navigation
# Usage: show_arrow_menu "Title" "Option 1|desc" "Option 2|desc" ...
# Last options can be: "HELP" "BACK" "QUIT"
# Sets global MENU_RESULT to: Selected index (0-based), -1 for ESC/quit, or "IDDQD" for easter egg
show_arrow_menu() {
    local title="$1"
    shift
    local -a options=("$@")
    local selected=0
    local option_count=${#options[@]}
    local typed_buffer=""  # For easter egg detection
    local needs_redraw=1   # Flag to control redrawing
    
    MENU_RESULT=""  # Global result variable

    while true; do
        # Only redraw if needed
        if [[ $needs_redraw -eq 1 ]]; then
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
                label="❓ Help"
                desc="Show detailed help"
            elif [[ "$label" == "BACK" ]]; then
                color="$MENU_YELLOW"
                label="← Back"
                desc=""
            elif [[ "$label" == "QUIT" ]]; then
                color="$MENU_RED"
                label="✕ Quit"
                desc=""
            else
                color="$MENU_GREEN"
            fi

            # Highlight if selected
            if [[ $idx -eq $selected ]]; then
                echo -e "  ${MENU_INVERSE}${MENU_BOLD}> ${label}${MENU_RESET}${MENU_BOLD}${desc:+ - $desc}${MENU_RESET}"
            else
                echo -e "  ${color}  ${label}${MENU_RESET}${desc:+ - $desc}"
            fi

            ((idx++)) || true
        done

        echo ""
        echo -e "${MENU_CYAN}════════════════════════════════════════════════════════════${MENU_RESET}"
        echo -e "${MENU_BOLD}Use ↑/↓ to navigate, Enter to select, q to quit${MENU_RESET}"
        
        needs_redraw=0
        fi  # end of needs_redraw check

        # Read key (sets MENU_KEY global variable)
        read_key

        # Handle input
        case "$MENU_KEY" in
            "")
                # Empty key (timeout) - just wait again without redrawing
                continue
                ;;
            KEY_UP)
                needs_redraw=1
                ((selected--)) || true
                if [[ $selected -lt 0 ]]; then
                    selected=$((option_count - 1))
                fi
                ;;
            KEY_DOWN)
                needs_redraw=1
                ((selected++)) || true
                if [[ $selected -ge $option_count ]]; then
                    selected=0
                fi
                ;;
            KEY_ENTER)
                MENU_RESULT="$selected"
                return 0
                ;;
            KEY_Q)
                MENU_RESULT="-1"
                return 0
                ;;
            KEY_ESC)
                # ESC behavior: return special code -1
                MENU_RESULT="-1"
                return 0
                ;;
            *)
                # Typed character - add to buffer for easter egg detection
                typed_buffer="${typed_buffer}${MENU_KEY}"

                # Keep buffer at max 10 chars
                if [[ ${#typed_buffer} -gt 10 ]]; then
                    typed_buffer="${typed_buffer: -10}"
                fi

                # Check for easter egg
                if [[ "$typed_buffer" == *"iddqd"* ]]; then
                    # shellcheck disable=SC2034
                    MENU_RESULT="IDDQD"
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

    # If not a TTY (e.g., piped input for automation), skip progress rendering
    if [[ ! -t 1 ]]; then
        return 0
    fi

    # Calculate percentage
    local percent=$(( current * 100 / total ))

    # Progress bar (20 chars wide)
    local filled=$(( percent / 5 ))
    local empty=$(( 20 - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done

    # Move cursor to top and render; clear each line to avoid text overlap
    tput cup 0 0
    tput el; echo -e "${MENU_BOLD}${MENU_CYAN}╔══════════════════════════════════════════════════════════╗${MENU_RESET}"
    tput el; echo -e "${MENU_BOLD}${MENU_CYAN}║         📝 Processing MOTDs...                           ║${MENU_RESET}"
    tput el; echo -e "${MENU_BOLD}${MENU_CYAN}╚══════════════════════════════════════════════════════════╝${MENU_RESET}"
    tput el; echo ""
    tput el; echo -e "  ${MENU_YELLOW}→${MENU_RESET} Automatic generation for all hosts"
    tput el; echo -e "${MENU_BOLD}Progress:${MENU_RESET} [${MENU_CYAN}${bar}${MENU_RESET}] ${MENU_BOLD}${percent}%${MENU_RESET} (${current}/${total} hosts)"
    tput el; echo -e "  ${MENU_YELLOW}→${MENU_RESET} No prompts per host"
    tput el; echo -e "${MENU_BOLD}Current:${MENU_RESET}  ${MENU_CYAN}${hostname}${MENU_RESET}"
    tput el; echo -e "${MENU_BOLD}Status:${MENU_RESET}   ${status}"
    tput el; echo ""
}

# Initialize progress display (clear screen, hide cursor)
init_progress() {
    # Skip when not a TTY
    if [[ ! -t 1 ]]; then
        return 0
    fi
    clear
    tput civis  # Hide cursor
}

# Finalize progress display (show cursor)
finish_progress() {
    # Skip when not a TTY
    if [[ ! -t 1 ]]; then
        return 0
    fi
    tput cnorm  # Show cursor
}

# Wrapper function for show_arrow_menu for backwards compatibility
# Usage: choose_menu "Title" "option1|description" "option2|description" ...
choose_menu() {
    local title="$1"
    shift
    show_arrow_menu "$title" "$@"
    # show_arrow_menu sets MENU_RESULT globally
}
