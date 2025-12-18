# File Organizer Installation Guide

This guide explains how to install the File Organizer as a system command with man pages.

## Quick Installation

### Option 1: User Installation (Recommended)

```bash
# Make installer executable and run
chmod +x install.sh
./install.sh
```

### Option 2: System-Wide Installation

```bash
# Requires root/sudo privileges
chmod +x install.sh
sudo ./install.sh
```

## What the Installer Does

The installer automatically:

1. **Detects Installation Paths**
   - User: `~/.local/bin/` or `~/bin/`
   - System: `/usr/local/bin/` or `/usr/bin/`

2. **Installs Components**
   - Main script: `file-organizer` command
   - Man page: Available via `man file-organizer`
   - Creates necessary directories

3. **Configures Environment**
   - Adds alias to `~/.bashrc` or `~/.zshrc`
   - Updates PATH if needed
   - Updates man database

4. **Safety Features**
   - Backs up existing installations
   - Validates permissions
   - Provides detailed feedback

## Installation Options

```bash
# Show help
./install.sh --help

# Force user installation
./install.sh --user

# Force system installation (requires root)
./install.sh --system
```

## Post-Installation

After installation, you can use the file organizer in several ways:

### Interactive Mode
```bash
file-organizer
```

### Direct Organization
```bash
file-organizer /path/to/directory
```

### Quiet Mode
```bash
file-organizer -q /path/to/directory
```

### Auto-Confirm Mode
```bash
file-organizer -y /path/to/directory
```

### View Manual
```bash
man file-organizer
```

## Command-Line Options

The installed `file-organizer` command supports:

- `file-organizer` - Interactive mode (asks for directory)
- `file-organizer /path` - Direct organization
- `-q, --quiet` - Quiet mode (suppress output)
- `-y, --yes` - Auto-confirm all prompts
- `-v, --version` - Show version
- `-h, --help` - Show help

## Usage Examples

### Basic Usage
```bash
# Start interactive mode
file-organizer

# The tool will ask for a directory path
# Enter something like: /home/user/Downloads
```

### Scripted Usage
```bash
# Organize downloads quietly
file-organizer -q ~/Downloads

# Organize with auto-confirmation
file-organizer -y ~/Documents
```

### View Documentation
```bash
# Read the manual
man file-organizer

# Or get quick help
file-organizer --help
```

## Troubleshooting

### Command Not Found
If `file-organizer` command is not found after installation:

```bash
# Reload your shell configuration
source ~/.bashrc

# Or restart your terminal

# Check if it's in PATH
echo $PATH

# Run directly if needed
python3 ~/.local/bin/file-organizer
```

### Permission Issues
For system installation, ensure you have sudo privileges:

```bash
sudo ./install.sh
```

For user installation, the installer should work without special permissions.

### Man Page Not Found
If `man file-organizer` doesn't work:

```bash
# Update man database
sudo mandb  # For system installation
mandb ~/.local/share/man  # For user installation
```

## Uninstallation

To remove the file organizer:

```bash
# Remove the command
rm ~/.local/bin/file-organizer  # User installation
sudo rm /usr/local/bin/file-organizer  # System installation

# Remove man page
rm ~/.local/share/man/man1/file-organizer.1  # User
sudo rm /usr/share/man/man1/file-organizer.1  # System

# Remove alias from shell config
# Edit ~/.bashrc or ~/.zshrc and remove the alias line
```

## File Structure After Installation

### User Installation
```
~/.local/bin/file-organizer          # Main command
~/.local/share/man/man1/file-organizer.1  # Man page
~/.bashrc or ~/.zshrc               # Contains alias
```

### System Installation
```
/usr/local/bin/file-organizer       # Main command
/usr/share/man/man1/file-organizer.1 # Man page
/etc/bash.bashrc or /etc/zsh/zshrc   # System-wide aliases
```

## Requirements

- Python 3.6 or higher
- Standard Unix utilities (mkdir, cp, mv, etc.)
- For system installation: sudo/root privileges

## Compatibility

- ✅ Linux (all distributions)
- ✅ macOS
- ✅ Windows (with WSL/Git Bash)
- ✅ BSD variants

## Support

For issues or questions:
1. Check the manual: `man file-organizer`
2. Run with help: `file-organizer --help`
3. Check installation: `./install.sh --help`

## Security Notes

- The installer only installs to standard system directories
- No external network connections are made
- All file operations are local
- Existing files are backed up before replacement
- No privileged operations without explicit sudo