#!/usr/bin/env bash
# Installation script for tt (timetracker) shell completions
# Supports both Fish and Bash shells

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Installation mode
INSTALL_FISH=0
INSTALL_BASH=0
UNINSTALL=0
AUTO_DETECT=1

# Parse command line arguments
parse_args() {
    for arg in "$@"; do
        case "$arg" in
            --fish)
                INSTALL_FISH=1
                AUTO_DETECT=0
                ;;
            --bash)
                INSTALL_BASH=1
                AUTO_DETECT=0
                ;;
            --uninstall)
                UNINSTALL=1
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}Error: Unknown option '$arg'${NC}"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    cat << EOF
tt completion installer

Usage: $0 [OPTIONS]

OPTIONS:
    --fish          Install Fish completion only
    --bash          Install Bash completion only
    --uninstall     Remove installed completions
    --help, -h      Show this help message

If no options are specified, the script will auto-detect your shell(s)
and install completions for all detected shells.

Examples:
    $0              # Auto-detect and install for all shells
    $0 --fish       # Install Fish completion only
    $0 --bash       # Install Bash completion only
    $0 --uninstall  # Remove all installed completions

Installation paths:
    Fish: ~/.config/fish/completions/tt.fish
    Bash: ~/.local/share/bash-completion/completions/tt
EOF
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect which shells are available
detect_shells() {
    if [[ $AUTO_DETECT -eq 1 ]]; then
        if command_exists fish; then
            INSTALL_FISH=1
        fi
        
        if command_exists bash; then
            INSTALL_BASH=1
        fi
        
        if [[ $INSTALL_FISH -eq 0 ]] && [[ $INSTALL_BASH -eq 0 ]]; then
            echo -e "${YELLOW}Warning: No supported shells detected (Fish or Bash)${NC}"
            exit 1
        fi
    fi
}

# Install Fish completion
install_fish() {
    local source_file="$SCRIPT_DIR/tt.fish"
    local dest_dir="$HOME/.config/fish/completions"
    local dest_file="$dest_dir/tt.fish"
    
    if [[ ! -f "$source_file" ]]; then
        echo -e "${RED}Error: Fish completion file not found: $source_file${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Installing Fish completion...${NC}"
    
    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"
    
    # Copy completion file
    cp "$source_file" "$dest_file"
    
    echo -e "${GREEN}✓ Fish completion installed to: $dest_file${NC}"
    echo -e "${YELLOW}  Note: Restart Fish or run 'source $dest_file' to activate${NC}"
    
    return 0
}

# Install Bash completion
install_bash() {
    local source_file="$SCRIPT_DIR/tt.bash"
    local dest_dir="$HOME/.local/share/bash-completion/completions"
    local dest_file="$dest_dir/tt"
    
    if [[ ! -f "$source_file" ]]; then
        echo -e "${RED}Error: Bash completion file not found: $source_file${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Installing Bash completion...${NC}"
    
    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"
    
    # Copy completion file (note: destination is named 'tt' without .bash extension)
    cp "$source_file" "$dest_file"
    
    echo -e "${GREEN}✓ Bash completion installed to: $dest_file${NC}"
    echo -e "${YELLOW}  Note: Restart Bash or run 'source $dest_file' to activate${NC}"
    
    # Check if bash-completion is available
    if ! command_exists bash && [[ -f /usr/share/bash-completion/bash_completion ]]; then
        echo -e "${YELLOW}  Tip: bash-completion package detected${NC}"
    fi
    
    return 0
}

# Uninstall Fish completion
uninstall_fish() {
    local dest_file="$HOME/.config/fish/completions/tt.fish"
    
    if [[ -f "$dest_file" ]]; then
        echo -e "${BLUE}Removing Fish completion...${NC}"
        rm "$dest_file"
        echo -e "${GREEN}✓ Fish completion removed${NC}"
    else
        echo -e "${YELLOW}Fish completion not found (already removed?)${NC}"
    fi
}

# Uninstall Bash completion
uninstall_bash() {
    local dest_file="$HOME/.local/share/bash-completion/completions/tt"
    
    if [[ -f "$dest_file" ]]; then
        echo -e "${BLUE}Removing Bash completion...${NC}"
        rm "$dest_file"
        echo -e "${GREEN}✓ Bash completion removed${NC}"
    else
        echo -e "${YELLOW}Bash completion not found (already removed?)${NC}"
    fi
}

# Check prerequisites
check_prerequisites() {
    if ! command_exists sqlite3; then
        echo -e "${YELLOW}Warning: sqlite3 command not found${NC}"
        echo -e "${YELLOW}  Completions require sqlite3 to query the task database${NC}"
        echo -e "${YELLOW}  Install it with: sudo apt install sqlite3 (Debian/Ubuntu)${NC}"
        echo -e "${YELLOW}                   sudo yum install sqlite (RHEL/CentOS)${NC}"
        echo -e "${YELLOW}                   brew install sqlite3 (macOS)${NC}"
        echo ""
    fi
}

# Main installation process
main() {
    parse_args "$@"
    
    echo -e "${BLUE}tt completion installer${NC}"
    echo ""
    
    if [[ $UNINSTALL -eq 1 ]]; then
        # Uninstall mode
        echo "Uninstalling completions..."
        echo ""
        
        uninstall_fish
        uninstall_bash
        
        echo ""
        echo -e "${GREEN}Uninstallation complete!${NC}"
    else
        # Install mode
        detect_shells
        check_prerequisites
        
        local success=0
        local failed=0
        
        if [[ $INSTALL_FISH -eq 1 ]]; then
            if install_fish; then
                ((success++))
            else
                ((failed++))
            fi
            echo ""
        fi
        
        if [[ $INSTALL_BASH -eq 1 ]]; then
            if install_bash; then
                ((success++))
            else
                ((failed++))
            fi
            echo ""
        fi
        
        # Summary
        if [[ $success -gt 0 ]]; then
            echo -e "${GREEN}Installation complete!${NC}"
            echo ""
            echo "Installed completions for:"
            [[ $INSTALL_FISH -eq 1 ]] && echo "  • Fish shell"
            [[ $INSTALL_BASH -eq 1 ]] && echo "  • Bash shell"
            echo ""
            echo "To activate completions:"
            echo "  • Restart your shell, or"
            echo "  • Source the completion file manually"
            echo ""
            echo "Test it out:"
            echo "  tt <TAB>          # Complete command names"
            echo "  tt start ENG-<TAB>  # Complete task names"
        fi
        
        if [[ $failed -gt 0 ]]; then
            echo -e "${RED}Some installations failed. See errors above.${NC}"
            exit 1
        fi
    fi
}

# Run main function
main "$@"
