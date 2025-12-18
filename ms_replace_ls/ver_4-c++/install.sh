#!/bin/bash

# ms installer script
# This script installs the ms command and its man page

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

# Check if running as root for system-wide installation
check_permissions() {
    if [[ $EUID -eq 0 ]]; then
        INSTALL_PREFIX="/usr/local"
        MAN_PREFIX="/usr/local/share/man"
    else
        INSTALL_PREFIX="$HOME/.local"
        MAN_PREFIX="$HOME/.local/share/man"
    fi
}

# Check if ms command already exists
check_existing_ms() {
    if command -v ms >/dev/null 2>&1; then
        EXISTING_MS_PATH=$(which ms)
        print_warning "Existing ms command found at: $EXISTING_MS_PATH"
        echo -n "Do you want to replace it? (y/N): "
        read -r REPLACE_MS
        if [[ $REPLACE_MS =~ ^[Yy]$ ]]; then
            print_info "Removing existing ms command..."
            sudo rm -f "$EXISTING_MS_PATH" 2>/dev/null || rm -f "$EXISTING_MS_PATH"
            print_success "Existing ms command removed"
        else
            print_info "Installation cancelled - existing ms command preserved"
            exit 0
        fi
    fi
}

# Check if ms man page already exists
check_existing_man() {
    if man -w ms >/dev/null 2>&1; then
        EXISTING_MAN_PATH=$(man -w ms)
        print_warning "Existing ms man page found at: $EXISTING_MAN_PATH"
        echo -n "Do you want to replace it? (y/N): "
        read -r REPLACE_MAN
        if [[ $REPLACE_MAN =~ ^[Yy]$ ]]; then
            print_info "Removing existing ms man page..."
            sudo rm -f "$EXISTING_MAN_PATH" 2>/dev/null || rm -f "$EXISTING_MAN_PATH"
            print_success "Existing ms man page removed"
        else
            print_info "Installation cancelled - existing ms man page preserved"
            exit 0
        fi
    fi
}

# Check for required dependencies
check_dependencies() {
    print_info "Checking dependencies..."
    
    if ! command -v g++ >/dev/null 2>&1; then
        print_error "g++ compiler not found. Please install g++ to compile ms"
        exit 1
    fi
    
    if ! command -v man >/dev/null 2>&1; then
        print_warning "man command not found. Man page installation will be skipped"
        SKIP_MAN=true
    else
        SKIP_MAN=false
    fi
    
    print_success "Dependencies check completed"
}

# Compile the ms command
compile_ms() {
    print_info "Compiling ms command..."
    
    # Create build directory
    mkdir -p build
    
    # Compile with optimization and C++17 support
    g++ -std=c++17 -O2 -Wall -Wextra -o build/ms ms.cpp
    
    if [[ $? -eq 0 ]]; then
        print_success "ms command compiled successfully"
    else
        print_error "Compilation failed"
        exit 1
    fi
}

# Install the ms command
install_ms() {
    print_info "Installing ms command..."
    
    # Create directories if they don't exist
    mkdir -p "$INSTALL_PREFIX/bin"
    mkdir -p "$INSTALL_PREFIX/share/man/man1"
    
    # Copy the compiled binary
    if [[ $EUID -eq 0 ]]; then
        cp build/ms "$INSTALL_PREFIX/bin/"
        chmod 755 "$INSTALL_PREFIX/bin/ms"
    else
        mkdir -p "$HOME/.local/bin"
        cp build/ms "$HOME/.local/bin/ms"
        chmod 755 "$HOME/.local/bin/ms"
    fi
    
    print_success "ms command installed successfully"
}

# Install the man page
install_man() {
    if [[ "$SKIP_MAN" == "true" ]]; then
        print_warning "Skipping man page installation (man command not found)"
        return
    fi
    
    print_info "Installing ms man page..."
    
    # Copy man page
    cp ms.1 "$MAN_PREFIX/man1/ms.1"
    
    # Update man database
    if command -v mandb >/dev/null 2>&1; then
        mandb -q 2>/dev/null || true
    fi
    
    print_success "ms man page installed successfully"
}

# Update PATH if needed
update_path() {
    if [[ $EUID -ne 0 ]]; then
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            print_warning "You may need to add $HOME/.local/bin to your PATH"
            print_info "Add the following line to your ~/.bashrc or ~/.zshrc:"
            print_info 'export PATH="$HOME/.local/bin:$PATH"'
        fi
    fi
}

# Test installation
test_installation() {
    print_info "Testing installation..."
    
    if command -v ms >/dev/null 2>&1; then
        print_success "ms command is available"
        print_info "Running ms --help to verify functionality..."
        ms --help >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            print_success "ms command works correctly"
        else
            print_warning "ms command may have issues"
        fi
    else
        print_error "ms command not found in PATH"
        return 1
    fi
}

# Cleanup
cleanup() {
    print_info "Cleaning up build files..."
    rm -rf build
    print_success "Cleanup completed"
}

# Main installation function
main() {
    echo "========================================"
    echo "           MS INSTALLER"
    echo "========================================"
    echo
    
    check_permissions
    check_existing_ms
    check_existing_man
    check_dependencies
    compile_ms
    install_ms
    install_man
    update_path
    test_installation
    cleanup
    
    echo
    print_success "Installation completed successfully!"
    echo
    print_info "Usage examples:"
    echo "  ms                    # List current directory"
    echo "  ms -l /home          # Long format listing"
    echo "  ms -k /usr/bin       # Tree view"
    echo "  ms -n -H .           # Table with human readable sizes"
    echo "  ms -z -R             # Zebra view recursively"
    echo "  ms --help            # Show help"
    echo
    if [[ "$SKIP_MAN" != "true" ]]; then
        print_info "Man page available via: man ms"
    fi
}

# Run main function
main "$@"