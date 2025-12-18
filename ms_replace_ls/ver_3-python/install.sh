#!/bin/bash
#
# ms - Modern ls command replacement
# Installation script
#
# This script installs the ms command and sets up the man page
#

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MS_SCRIPT="$SCRIPT_DIR/ms.py"
MS_MAN_PAGE="$SCRIPT_DIR/ms.1"
MS_BINARY="/usr/local/bin/ms"
MS_MAN_PAGE_DIR="/usr/local/share/man/man1"

# Check if running as root for system-wide installation
if [ "$1" = "--system" ] || [ "$1" = "-s" ]; then
    SYSTEM_INSTALL=true
    echo -e "${BLUE}Installing ms system-wide (requires root privileges)${NC}"
else
    SYSTEM_INSTALL=false
    echo -e "${BLUE}Installing ms locally to user's bin directory${NC}"
fi

# Function to check for existing ms installations
check_existing_installations() {
    echo -e "${YELLOW}Checking for existing ms installations...${NC}"
    
    local found_existing=false
    
    # Check for existing ms command
    if command -v ms &> /dev/null; then
        local existing_ms_path=$(which ms)
        echo -e "${YELLOW}Found existing ms command: $existing_ms_path${NC}"
        found_existing=true
    fi
    
    # Check for existing ms man page
    if [ "$SYSTEM_INSTALL" = true ]; then
        if [ -f "$MS_MAN_PAGE_DIR/ms.1" ]; then
            echo -e "${YELLOW}Found existing ms man page: $MS_MAN_PAGE_DIR/ms.1${NC}"
            found_existing=true
        fi
    else
        local user_man_dir="$HOME/.local/share/man/man1"
        if [ -f "$user_man_dir/ms.1" ]; then
            echo -e "${YELLOW}Found existing ms man page: $user_man_dir/ms.1${NC}"
            found_existing=true
        fi
    fi
    
    if [ "$found_existing" = true ]; then
        echo -e "${BLUE}Existing ms installation detected.${NC}"
        echo -e "${YELLOW}Do you want to replace the existing ms installation? (y/N)${NC}"
        read -r replace_response
        if [[ ! "$replace_response" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Installation cancelled by user${NC}"
            exit 0
        fi
    fi
}

# Function to check dependencies
check_dependencies() {
    echo -e "${YELLOW}Checking dependencies...${NC}"
    
    # Check if Python 3 is available
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}Error: Python 3 is required but not installed${NC}"
        exit 1
    fi
    
    # Check Python version
    python_version=$(python3 --version | cut -d' ' -f2)
    echo -e "${GREEN}Found Python $python_version${NC}"
    
    # Check if humanize package is available, install if not
    if ! python3 -c "import humanize" &> /dev/null; then
        echo -e "${YELLOW}Installing required Python package: humanize${NC}"
        
        # Try different installation methods in order
        local install_success=false
        
        # Method 1: Try --user installation
        if command -v pip3 &> /dev/null; then
            echo -e "${BLUE}Attempting user-local installation...${NC}"
            if pip3 install --user humanize &> /tmp/pip_install.log; then
                install_success=true
                echo -e "${GREEN}Successfully installed humanize using pip3 --user${NC}"
            else
                echo -e "${YELLOW}User installation failed. Trying system installation...${NC}"
                # Check if it's an externally-managed-environment error
                if grep -q "externally-managed-environment" /tmp/pip_install.log; then
                    echo -e "${YELLOW}Detected externally-managed-environment error.${NC}"
                    
                    # Method 2: Try --break-system-packages
                    echo -e "${BLUE}Attempting system installation with --break-system-packages...${NC}"
                    if pip3 install --break-system-packages humanize &> /tmp/pip_install2.log; then
                        install_success=true
                        echo -e "${GREEN}Successfully installed humanize using --break-system-packages${NC}"
                        echo -e "${YELLOW}Warning: This may affect system Python packages${NC}"
                    else
                        echo -e "${RED}System installation failed.${NC}"
                        
                        # Method 3: Try apt installation
                        echo -e "${BLUE}Attempting apt installation...${NC}"
                        if apt list --installed 2>/dev/null | grep -q "^python3-humanize"; then
                            echo -e "${GREEN}python3-humanize is already installed via apt${NC}"
                            install_success=true
                        elif sudo apt update && sudo apt install -y python3-humanize; then
                            install_success=true
                            echo -e "${GREEN}Successfully installed python3-humanize via apt${NC}"
                        else
                            # Method 4: Suggest manual installation
                            echo -e "${RED}Automatic installation failed.${NC}"
                            echo -e "${YELLOW}Please install the humanize package manually:${NC}"
                            echo -e "${BLUE}  Option 1: sudo apt install python3-humanize${NC}"
                            echo -e "${BLUE}  Option 2: pip3 install --break-system-packages humanize${NC}"
                            echo -e "${BLUE}  Option 3: python3 -m venv ms_env && source ms_env/bin/activate && pip install humanize${NC}"
                            echo -e "${YELLOW}Or run the installer with: sudo ./install.sh --system${NC}"
                            exit 1
                        fi
                    fi
                else
                    echo -e "${RED}Unknown installation error:${NC}"
                    cat /tmp/pip_install.log
                    exit 1
                fi
            fi
        elif command -v pip &> /dev/null; then
            echo -e "${BLUE}Attempting installation with pip...${NC}"
            if pip install --user humanize; then
                install_success=true
                echo -e "${GREEN}Successfully installed humanize using pip --user${NC}"
            else
                echo -e "${RED}pip installation failed${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Error: pip is not available to install humanize package${NC}"
            exit 1
        fi
        
        # Verify installation worked
        if [ "$install_success" = true ] && ! python3 -c "import humanize" &> /dev/null; then
            echo -e "${RED}Installation appeared successful but humanize is still not available${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}humanize package is available${NC}"
    fi
}

# Function to install ms command
install_ms_command() {
    if [ "$SYSTEM_INSTALL" = true ]; then
        # System-wide installation
        if [ ! -w "/usr/local/bin" ]; then
            echo -e "${RED}Error: Writing to /usr/local/bin requires root privileges${NC}"
            echo "Please run with sudo or use --system flag with appropriate permissions"
            exit 1
        fi
        
        # Backup existing ms command if it exists
        if [ -f "$MS_BINARY" ]; then
            local backup_path="${MS_BINARY}.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$MS_BINARY" "$backup_path"
            echo -e "${YELLOW}Backed up existing ms command to: $backup_path${NC}"
        fi
        
        # Copy the script to /usr/local/bin
        cp "$MS_SCRIPT" "$MS_BINARY"
        chmod +x "$MS_BINARY"
        echo -e "${GREEN}ms command installed to $MS_BINARY${NC}"
    else
        # User-local installation
        local user_bin_dir="$HOME/.local/bin"
        local user_binary="$user_bin_dir/ms"
        
        # Create bin directory if it doesn't exist
        if [ ! -d "$user_bin_dir" ]; then
            mkdir -p "$user_bin_dir"
            echo -e "${GREEN}Created $user_bin_dir${NC}"
            
            # Add to PATH if not already there
            if [[ ":$PATH:" != *":$user_bin_dir:"* ]]; then
                echo -e "${YELLOW}Adding $user_bin_dir to PATH in ~/.bashrc${NC}"
                echo "" >> ~/.bashrc
                echo "# Added by ms installation" >> ~/.bashrc
                echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc
                echo -e "${YELLOW}Please run 'source ~/.bashrc' or restart your terminal${NC}"
            fi
        fi
        
        # Backup existing ms command if it exists
        if [ -f "$user_binary" ]; then
            local backup_path="${user_binary}.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$user_binary" "$backup_path"
            echo -e "${YELLOW}Backed up existing ms command to: $backup_path${NC}"
        fi
        
        # Copy the script
        cp "$MS_SCRIPT" "$user_binary"
        chmod +x "$user_binary"
        echo -e "${GREEN}ms command installed to $user_binary${NC}"
        MS_BINARY="$user_binary"
    fi
}

# Function to install man page
install_man_page() {
    if [ "$SYSTEM_INSTALL" = true ]; then
        # System-wide man page installation
        if [ ! -w "/usr/local/share/man" ]; then
            echo -e "${YELLOW}Warning: Cannot install man page to system location${NC}"
            echo "You can still use ms, but man page won't be available"
            return
        fi
        
        # Backup existing man page if it exists
        if [ -f "$MS_MAN_PAGE_DIR/ms.1" ]; then
            local man_backup="${MS_MAN_PAGE_DIR}/ms.1.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$MS_MAN_PAGE_DIR/ms.1" "$man_backup"
            echo -e "${YELLOW}Backed up existing ms man page to: $man_backup${NC}"
        fi
        
        # Install man page
        mkdir -p "$MS_MAN_PAGE_DIR"
        cp "$MS_MAN_PAGE" "$MS_MAN_PAGE_DIR/ms.1"
        echo -e "${GREEN}Man page installed to $MS_MAN_PAGE_DIR/ms.1${NC}"
        
        # Update man database if available
        if command -v mandb &> /dev/null; then
            mandb -q 2>/dev/null || echo -e "${YELLOW}Warning: Could not update man database${NC}"
        fi
    else
        # User-local man page installation
        local user_man_dir="$HOME/.local/share/man/man1"
        
        if [ ! -d "$user_man_dir" ]; then
            mkdir -p "$user_man_dir"
        fi
        
        # Backup existing man page if it exists
        if [ -f "$user_man_dir/ms.1" ]; then
            local man_backup="${user_man_dir}/ms.1.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$user_man_dir/ms.1" "$man_backup"
            echo -e "${YELLOW}Backed up existing ms man page to: $man_backup${NC}"
        fi
        
        cp "$MS_MAN_PAGE" "$user_man_dir/ms.1"
        echo -e "${GREEN}Man page installed to $user_man_dir/ms.1${NC}"
        
        # Add to MANPATH if not already there
        if [[ ":$MANPATH:" != *":$HOME/.local/share/man:"* ]]; then
            echo -e "${YELLOW}Adding man path to environment${NC}"
            echo "" >> ~/.bashrc
            echo "# Added by ms installation" >> ~/.bashrc
            echo "export MANPATH=\"\$HOME/.local/share/man:\$MANPATH\"" >> ~/.bashrc
        fi
    fi
}

# Function to create desktop shortcut (Linux)
create_desktop_shortcut() {
    if [ "$DESKTOP_SESSION" ] || [ "$XDG_CURRENT_DESKTOP" ]; then
        local desktop_file="$HOME/Desktop/ms.desktop"
        cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=MS Command
Comment=Modern ls command replacement
Exec=$MS_BINARY
Icon=utilities-terminal
Terminal=true
Categories=System;TerminalEmulator;
EOF
        chmod +x "$desktop_file"
        echo -e "${GREEN}Desktop shortcut created at $desktop_file${NC}"
    fi
}

# Function to verify installation
verify_installation() {
    echo -e "${YELLOW}Verifying installation...${NC}"
    
    if command -v ms &> /dev/null; then
        echo -e "${GREEN}ms command is available${NC}"
        ms --version 2>/dev/null || echo -e "${YELLOW}ms command found but --version failed${NC}"
    else
        echo -e "${RED}ms command not found in PATH${NC}"
        return 1
    fi
    
    # Test the command
    if ms /tmp &> /dev/null; then
        echo -e "${GREEN}ms command works correctly${NC}"
    else
        echo -e "${RED}ms command test failed${NC}"
        return 1
    fi
    
    return 0
}

# Function to show usage information
show_usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo ""
    echo "Options:"
    echo "  --system, -s    Install system-wide (requires root)"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "Without options, installs to user's local directory (~/.local/bin)"
}

# Main installation process
main() {
    echo -e "${BLUE}MS Command Installation Script${NC}"
    echo "================================"
    
    # Handle command line arguments
    case "$1" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --system|-s)
            shift
            ;;
    esac
    
    # Check if ms.py exists
    if [ ! -f "$MS_SCRIPT" ]; then
        echo -e "${RED}Error: ms.py not found in $SCRIPT_DIR${NC}"
        echo "Please run this script from the ms installation directory"
        exit 1
    fi
    
    # Check for existing installations
    check_existing_installations
    
    # Check dependencies
    check_dependencies
    
    # Install ms command
    install_ms_command
    
    # Install man page
    install_man_page
    
    # Create desktop shortcut (optional)
    echo -e "${YELLOW}Would you like to create a desktop shortcut? (y/N)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        create_desktop_shortcut
    fi
    
    # Verify installation
    if verify_installation; then
        echo -e "${GREEN}Installation completed successfully!${NC}"
        echo ""
        echo -e "${BLUE}Usage examples:${NC}"
        echo "  ms                    # List current directory"
        echo "  ms -la /etc          # List /etc with all details"
        echo "  ms --pattern=\"*.py\"   # Show Python files only"
        echo "  man ms               # View the manual page"
        echo ""
        if [ "$SYSTEM_INSTALL" = false ]; then
            echo -e "${YELLOW}Note: If ms command is not found, run:${NC}"
            echo "  source ~/.bashrc"
        fi
    else
        echo -e "${RED}Installation verification failed${NC}"
        exit 1
    fi
}

# Run main function
main "$@"