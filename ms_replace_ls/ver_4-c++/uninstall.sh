#!/bin/bash

# ms uninstaller script
# Removes the ms command and its man page

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if ms command exists
check_ms_exists() {
    if command -v ms >/dev/null 2>&1; then
        MS_PATH=$(which ms)
        return 0
    elif [ -f "./ms" ]; then
        MS_PATH="./ms"
        return 0
    else
        return 1
    fi
}

# Check if man page exists
check_man_exists() {
    if man -w ms >/dev/null 2>&1; then
        MAN_PATH=$(man -w ms)
        return 0
    else
        return 1
    fi
}

# Find ms installation paths
find_ms_paths() {
    if command -v ms >/dev/null 2>&1; then
        MS_PATH=$(which ms)
        
        # Determine installation type
        if [[ "$MS_PATH" == "/usr/local/bin/ms" ]] || [[ "$MS_PATH" == "/usr/bin/ms" ]]; then
            INSTALL_TYPE="system"
            BIN_PATH="$MS_PATH"
        elif [[ "$MS_PATH" == *"/.local/bin/ms"* ]]; then
            INSTALL_TYPE="user"
            BIN_PATH="$MS_PATH"
        else
            INSTALL_TYPE="unknown"
            BIN_PATH="$MS_PATH"
        fi
    else
        INSTALL_TYPE="unknown"
        BIN_PATH=""
    fi
    
    # Find man page path
    if man -w ms >/dev/null 2>&1; then
        MAN_PATH=$(man -w ms)
    else
        MAN_PATH=""
    fi
}

# Uninstall system-wide
uninstall_system() {
    print_info "Uninstalling system-wide ms command..."
    
    # Remove binary
    if [ -f "/usr/local/bin/ms" ]; then
        sudo rm -f /usr/local/bin/ms
        print_success "Removed /usr/local/bin/ms"
    elif [ -f "/usr/bin/ms" ]; then
        sudo rm -f /usr/bin/ms
        print_success "Removed /usr/bin/ms"
    else
        print_warning "System-wide binary not found"
    fi
    
    # Remove man page
    if [ -f "/usr/local/share/man/man1/ms.1" ]; then
        sudo rm -f /usr/local/share/man/man1/ms.1
        print_success "Removed /usr/local/share/man/man1/ms.1"
    elif [ -f "/usr/share/man/man1/ms.1" ]; then
        sudo rm -f /usr/share/man/man1/ms.1
        print_success "Removed /usr/share/man/man1/ms.1"
    else
        print_warning "System-wide man page not found"
    fi
    
    # Update man database
    if command -v mandb >/dev/null 2>&1; then
        sudo mandb -q 2>/dev/null || true
        print_success "Updated man database"
    fi
}

# Uninstall user-local
uninstall_user() {
    print_info "Uninstalling user-local ms command..."
    
    # Remove binary
    if [ -f "$HOME/.local/bin/ms" ]; then
        rm -f "$HOME/.local/bin/ms"
        print_success "Removed $HOME/.local/bin/ms"
        
        # Remove bin directory if empty
        if [ -d "$HOME/.local/bin" ] && [ -z "$(ls -A $HOME/.local/bin)" ]; then
            rmdir "$HOME/.local/bin" 2>/dev/null || true
            print_info "Removed empty ~/.local/bin directory"
        fi
    else
        print_warning "User binary not found"
    fi
    
    # Remove man page
    if [ -f "$HOME/.local/share/man/man1/ms.1" ]; then
        rm -f "$HOME/.local/share/man/man1/ms.1"
        print_success "Removed $HOME/.local/share/man/man1/ms.1"
        
        # Remove man directories if empty
        if [ -d "$HOME/.local/share/man/man1" ] && [ -z "$(ls -A $HOME/.local/share/man/man1)" ]; then
            rmdir "$HOME/.local/share/man/man1" 2>/dev/null || true
        fi
        if [ -d "$HOME/.local/share/man" ] && [ -z "$(ls -A $HOME/.local/share/man)" ]; then
            rmdir "$HOME/.local/share/man" 2>/dev/null || true
        fi
    else
        print_warning "User man page not found"
    fi
    
    # Update man database
    if command -v mandb >/dev/null 2>&1; then
        mandb -q 2>/dev/null || true
        print_success "Updated man database"
    fi
}

# Remove local build
uninstall_local() {
    print_info "Removing local ms binary..."
    
    if [ -f "./ms" ]; then
        rm -f ./ms
        print_success "Removed local ./ms binary"
    else
        print_warning "Local binary not found"
    fi
}

# Show installation info
show_installation_info() {
    print_info "Current ms installation information:"
    echo "  Installation type: $INSTALL_TYPE"
    if [ -n "$BIN_PATH" ]; then
        echo "  Binary location: $BIN_PATH"
    fi
    if [ -n "$MAN_PATH" ]; then
        echo "  Man page location: $MAN_PATH"
    fi
    echo
}

# Confirm uninstallation
confirm_uninstall() {
    echo -n "Are you sure you want to uninstall ms? (y/N): "
    read -r CONFIRM
    
    if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
        print_info "Uninstallation cancelled"
        exit 0
    fi
}

# Test removal
test_removal() {
    print_info "Testing removal..."
    
    if command -v ms >/dev/null 2>&1; then
        print_error "ms command still found in PATH"
        return 1
    else
        print_success "ms command successfully removed from PATH"
        return 0
    fi
}

# Main uninstall function
main() {
    echo "========================================"
    echo "        MS UNINSTALLER"
    echo "========================================"
    echo
    
    # Check if ms exists
    if ! check_ms_exists; then
        print_warning "ms command not found"
        print_info "Nothing to uninstall"
        exit 0
    fi
    
    # Find installation paths
    find_ms_paths
    
    # Show current installation info
    show_installation_info
    
    # Confirm uninstallation
    confirm_uninstall
    
    # Perform uninstallation based on installation type
    case $INSTALL_TYPE in
        "system")
            if [[ $EUID -eq 0 ]]; then
                uninstall_system
            else
                print_error "System-wide installation detected but not running as root"
                print_info "Please run with sudo or as root:"
                print_info "  sudo $0"
                exit 1
            fi
            ;;
        "user")
            uninstall_user
            ;;
        "unknown")
            print_warning "Unknown installation type"
            print_info "Attempting to remove from common locations..."
            uninstall_system
            uninstall_user
            uninstall_local
            ;;
    esac
    
    # Test removal
    test_removal
    
    # Cleanup any remaining files
    print_info "Cleaning up any remaining files..."
    find /usr/local /usr /home -name "ms" -type f 2>/dev/null | while read -r file; do
        echo -n "Found remaining file: $file. Remove it? (y/N): "
        read -r REMOVE_FILE
        if [[ $REMOVE_FILE =~ ^[Yy]$ ]]; then
            sudo rm -f "$file" 2>/dev/null || rm -f "$file"
            print_success "Removed $file"
        fi
    done
    
    echo
    print_success "Uninstallation completed successfully!"
    echo
    print_info "ms command has been removed from your system"
    
    if [ "$INSTALL_TYPE" = "user" ]; then
        print_info "If you added ~/.local/bin to your PATH, you may want to remove that line"
        print_info "from your ~/.bashrc or ~/.zshrc file"
    fi
}

# Run main function
main "$@"