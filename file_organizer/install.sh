#!/bin/bash
# File Organizer Installer
# Installs file_organizer as a system command with man pages

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="file_organizer.py"
MAN_PAGE="file_organizer.1"
INSTALL_NAME="file-organizer"

print_header() {
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}   FILE ORGANIZER INSTALLER${NC}"
    echo -e "${BLUE}===============================================${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_warning "Running as root. This will install system-wide."
        print_warning "For user installation, run without sudo."
        echo
        read -p "Continue with system installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 1
        fi
        SYSTEM_INSTALL=true
    else
        SYSTEM_INSTALL=false
    fi
}

find_installation_path() {
    if [[ "$SYSTEM_INSTALL" == true ]]; then
        # System-wide installation
        BIN_PATHS=("/usr/local/bin" "/usr/bin")
        MAN_PATHS=("/usr/share/man/man1" "/usr/local/share/man/man1")
        
        # Find writable paths
        for path in "${BIN_PATHS[@]}"; do
            if [[ -w "$path" ]]; then
                INSTALL_BIN="$path"
                break
            fi
        done
        
        for path in "${MAN_PATHS[@]}"; do
            if [[ -w "$path" ]]; then
                INSTALL_MAN="$path"
                break
            fi
        done
    else
        # User installation
        if [[ -d "$HOME/.local/bin" ]]; then
            INSTALL_BIN="$HOME/.local/bin"
        else
            INSTALL_BIN="$HOME/bin"
        fi
        
        if [[ -d "$HOME/.local/share/man/man1" ]]; then
            INSTALL_MAN="$HOME/.local/share/man/man1"
        else
            INSTALL_MAN="$HOME/share/man/man1"
        fi
    fi
    
    # Fallback to current directory if no standard paths found
    if [[ -z "$INSTALL_BIN" ]]; then
        INSTALL_BIN="$(pwd)"
        print_warning "Could not find standard bin directory. Installing to: $INSTALL_BIN"
    fi
    
    if [[ -z "$INSTALL_MAN" ]]; then
        INSTALL_MAN="$(pwd)"
        print_warning "Could not find standard man directory. Installing to: $INSTALL_MAN"
    fi
}

check_files() {
    if [[ ! -f "$SCRIPT_DIR/$MAIN_SCRIPT" ]]; then
        print_error "Main script '$MAIN_SCRIPT' not found in $SCRIPT_DIR"
        exit 1
    fi
    
    if [[ ! -f "$SCRIPT_DIR/$MAN_PAGE" ]]; then
        print_error "Man page '$MAN_PAGE' not found in $SCRIPT_DIR"
        exit 1
    fi
}

create_directories() {
    if [[ ! -d "$INSTALL_BIN" ]]; then
        mkdir -p "$INSTALL_BIN"
        print_success "Created directory: $INSTALL_BIN"
    fi
    
    if [[ ! -d "$INSTALL_MAN" ]]; then
        mkdir -p "$INSTALL_MAN"
        print_success "Created directory: $INSTALL_MAN"
    fi
}

backup_existing() {
    local target="$1"
    if [[ -f "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$target" "$backup"
        print_success "Backed up existing file to: $backup"
    fi
}

install_main_script() {
    local target="$INSTALL_BIN/$INSTALL_NAME"
    
    # Backup existing installation
    backup_existing "$target"
    
    # Copy and make executable
    cp "$SCRIPT_DIR/$MAIN_SCRIPT" "$target"
    chmod +x "$target"
    
    print_success "Installed: $target"
}

install_man_page() {
    local target="$INSTALL_MAN/$INSTALL_NAME.1"
    
    # Backup existing man page
    backup_existing "$target"
    
    # Copy man page
    cp "$SCRIPT_DIR/$MAN_PAGE" "$target"
    
    print_success "Installed man page: $target"
    
    # Update man database if applicable
    if command -v mandb >/dev/null 2>&1; then
        mandb -q "$INSTALL_MAN" 2>/dev/null || true
        print_success "Updated man database"
    fi
}

add_to_bashrc() {
    local bashrc="$HOME/.bashrc"
    local alias_line="alias file-organizer='python3 $INSTALL_BIN/$INSTALL_NAME'"
    
    # Check if alias already exists
    if grep -q "alias file-organizer" "$bashrc" 2>/dev/null; then
        print_warning "Alias 'file-organizer' already exists in $bashrc"
        return
    fi
    
    # Add alias to bashrc
    echo "" >> "$bashrc"
    echo "# File Organizer alias (added by installer)" >> "$bashrc"
    echo "$alias_line" >> "$bashrc"
    
    print_success "Added alias to $bashrc"
    print_warning "Please run 'source ~/.bashrc' or restart your terminal"
}

add_to_path() {
    if [[ "$INSTALL_BIN" == "$HOME/.local/bin" ]] || [[ "$INSTALL_BIN" == "$HOME/bin" ]]; then
        local profile_file=""
        
        # Detect shell and choose appropriate profile file
        if [[ -n "$BASH_VERSION" ]]; then
            profile_file="$HOME/.bashrc"
        elif [[ -n "$ZSH_VERSION" ]]; then
            profile_file="$HOME/.zshrc"
        else
            profile_file="$HOME/.profile"
        fi
        
        local path_line="export PATH=\"$INSTALL_BIN:\$PATH\""
        
        # Check if path already exists
        if ! grep -q "$INSTALL_BIN" "$profile_file" 2>/dev/null; then
            echo "" >> "$profile_file"
            echo "# File Organizer path (added by installer)" >> "$profile_file"
            echo "$path_line" >> "$profile_file"
            
            print_success "Added $INSTALL_BIN to PATH in $profile_file"
            print_warning "Please run 'source $profile_file' or restart your terminal"
        else
            print_warning "$INSTALL_BIN already in PATH"
        fi
    fi
}

verify_installation() {
    echo
    echo -e "${BLUE}🔍 VERIFYING INSTALLATION${NC}"
    echo "----------------------------------------"
    
    # Check if command is accessible
    if command -v "$INSTALL_NAME" >/dev/null 2>&1; then
        print_success "Command '$INSTALL_NAME' is available"
    else
        print_warning "Command '$INSTALL_NAME' may not be in PATH yet"
    fi
    
    # Check if man page is accessible
    if man -w "$INSTALL_NAME" >/dev/null 2>&1; then
        print_success "Man page is accessible"
        print_info "View with: man $INSTALL_NAME"
    else
        print_warning "Man page may not be accessible yet"
    fi
    
    # Show installation details
    echo
    echo "Installation Details:"
    echo "  Command: $INSTALL_NAME"
    echo "  Location: $INSTALL_BIN/$INSTALL_NAME"
    echo "  Man page: $INSTALL_MAN/$INSTALL_NAME.1"
}

print_usage_instructions() {
    echo
    echo -e "${BLUE}📖 USAGE INSTRUCTIONS${NC}"
    echo "----------------------------------------"
    echo "Run the file organizer:"
    echo "  $INSTALL_NAME"
    echo
    echo "View the manual:"
    echo "  man $INSTALL_NAME"
    echo
    echo "If command is not found, try:"
    echo "  source ~/.bashrc"
    echo "  echo \$PATH"
    echo
    echo "Or run directly:"
    echo "  python3 $INSTALL_BIN/$INSTALL_NAME"
}

main() {
    print_header
    
    check_root
    find_installation_path
    check_files
    create_directories
    
    echo -e "${BLUE}📦 INSTALLING FILES${NC}"
    echo "----------------------------------------"
    
    install_main_script
    install_man_page
    add_to_bashrc
    add_to_path
    
    verify_installation
    print_usage_instructions
    
    echo
    echo -e "${GREEN}🎉 INSTALLATION COMPLETE!${NC}"
    echo "==============================================="
}

# Help message
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    echo "File Organizer Installer"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --system       Force system-wide installation (requires root)"
    echo "  --user         Force user installation"
    echo
    echo "This installer will:"
    echo "  • Install file-organizer command to $INSTALL_BIN"
    echo "  • Install man page to $INSTALL_MAN"
    echo "  • Add alias to your shell configuration"
    echo "  • Add installation directory to PATH if needed"
    exit 0
fi

# Handle user/system installation preference
if [[ "$1" == "--system" ]]; then
    SYSTEM_INSTALL=true
elif [[ "$1" == "--user" ]]; then
    SYSTEM_INSTALL=false
fi

main "$@"