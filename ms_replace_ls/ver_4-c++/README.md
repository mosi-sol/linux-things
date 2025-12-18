# MS - Modern ls Command Replacement

**ms** is a powerful, modern replacement for the traditional `ls` command with enhanced formatting options and display modes. It provides a rich set of features for listing directory contents with beautiful, organized output.

## Features

### Display Modes
- **Tree View** (`-k`, `-K`): Hierarchical directory structure display
- **Table Modes** (`-n`, `-t`, `-T`): Organized column layouts
- **Zebra List** (`-z`, `-Z`): Alternating row colors for better readability
- **Two Column** (`-N`): Compact two-column layout
- **Long Format** (`-l`): Detailed file information

### Advanced Features
- **Human Readable Sizes** (`-H`): Automatic size formatting (K, M, G, T)
- **Recursive Listing** (`-R`): Display subdirectories
- **Sorting Options** (`--sort`): By name, size, time, or type
- **Reverse Sort** (`--reverse`): Change sort order
- **Metadata Display**: Permissions, owner, group, modification time
- **Hidden Files** (`-a`): Show dotfiles

### Visual Enhancements
- ANSI color support for zebra striping
- Multiple view modes for different use cases
- Professional formatting with proper alignment
- Cross-platform compatibility

## Installation

### Quick Installation

1. **Clone or download the files**:
   ```bash
   # If you have the source files
   wget https://example.com/ms.tar.gz
   tar -xzf ms.tar.gz
   cd ms
   ```

2. **Run the installer**:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

The installer will:
- Check for existing `ms` command and man page
- Compile the C++ source code
- Install the binary to `/usr/local/bin/` (or `~/.local/bin/` for user installation)
- Install the man page to `/usr/local/share/man/` (or `~/.local/share/man/` for user installation)
- Update the man database
- Test the installation

### Manual Installation

If you prefer manual installation:

1. **Compile the program**:
   ```bash
   g++ -std=c++17 -O2 -Wall -Wextra -o ms ms.cpp
   ```

2. **Install the binary**:
   ```bash
   # System-wide installation (requires root)
   sudo cp ms /usr/local/bin/
   sudo chmod 755 /usr/local/bin/ms
   
   # User installation
   mkdir -p ~/.local/bin
   cp ms ~/.local/bin/
   chmod 755 ~/.local/bin/ms
   ```

3. **Install the man page**:
   ```bash
   # System-wide installation
   sudo cp ms.1 /usr/local/share/man/man1/
   sudo mandb -q
   
   # User installation
   mkdir -p ~/.local/share/man/man1
   cp ms.1 ~/.local/share/man/man1/
   mandb -q 2>/dev/null || true
   ```

4. **Update PATH** (if using user installation):
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

## Usage

### Basic Usage

```bash
ms                          # List current directory
ms /path/to/directory       # List specific directory
ms -a                       # Include hidden files
ms -l                       # Long format listing
ms -R                       # Recursive listing
```

### Display Modes

#### Tree View
```bash
ms -k /usr/bin             # Simple tree structure
ms -K /home/user           # Tree with metadata
```

#### Table Modes
```bash
ms -n .                    # Table with name and size
ms -t /var/log             # Horizontal table layout
ms -T -H /usr/lib          # Table with metadata and human-readable sizes
```

#### Zebra List
```bash
ms -z .                    # Zebra striped list
ms -Z -l /home/user        # Zebra list with metadata
```

#### Two Column
```bash
ms -N /usr/share           # Compact two-column layout
```

### Advanced Usage

#### Sorting
```bash
ms --sort=size             # Sort by file size
ms --sort=time             # Sort by modification time
ms --sort=type             # Sort by file type
ms --sort=name --reverse   # Sort by name, reverse order
```

#### Combining Options
```bash
ms -la -H                  # Long format, all files, human-readable sizes
ms -Rz -K                  # Recursive zebra tree with metadata
ms -tH --sort=size         # Horizontal table, human-readable, sorted by size
```

### Practical Examples

#### Development
```bash
ms -n -H src/              # Quick file size overview in project
ms -l --sort=time          # Recently modified files first
ms -R -z                   # Project overview with zebra striping
```

#### System Administration
```bash
ms -K /etc                 # System config directory tree
ms -T -H /var/log          # Log files with sizes
ms -l --sort=size /usr/bin # Large binaries sorted by size
```

#### General Use
```bash
ms -n ~                    # Home directory table view
ms -t /tmp                 # Temp files in compact format
ms -z -a /home/user        # All files with zebra striping
```

## Command Reference

### Options Summary

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help information |
| `-l` | Long format listing |
| `-a, --all` | Show hidden files |
| `-R, --recursive` | Recursively list directories |
| `-k` | Tree view |
| `-K` | Tree view with metadata |
| `-n` | Table with name and size |
| `-N` | Two column row mode |
| `-z` | Zebra list view |
| `-Z` | Zebra list with metadata |
| `-H, --human-readable` | Human readable sizes |
| `-t` | Table 2xN horizontal mode |
| `-T` | Table 2xN with metadata |
| `-d` | Show details |
| `--sort=SORT_BY` | Sort by (name, size, time, type) |
| `--reverse` | Reverse sort order |

### Sort Options

- `name`: Sort alphabetically by filename (default)
- `size`: Sort by file size
- `time`: Sort by modification time
- `type`: Sort by file type

### Human Readable Sizes

When using `-H`, file sizes are automatically formatted:
- `< 1 KB`: Displayed in bytes
- `1 KB - 1 MB`: Displayed with K suffix
- `1 MB - 1 GB`: Displayed with M suffix
- `1 GB - 1 TB`: Displayed with G suffix
- `> 1 TB`: Displayed with T suffix

## Comparison with ls

| Feature | ls | ms |
|---------|----|----|
| Basic listing | ✓ | ✓ |
| Long format | ✓ | ✓ |
| Hidden files | ✓ | ✓ |
| Recursive | ✓ | ✓ |
| Tree view | ✗ | ✓ |
| Table modes | ✗ | ✓ |
| Zebra striping | ✗ | ✓ |
| Human readable | ✓ | ✓ |
| Sorting options | ✓ | ✓ |
| Color support | ✓ | ✓ (enhanced) |

## Platform Compatibility

- **Linux**: Fully supported
- **macOS**: Fully supported  
- **BSD**: Supported (with minor differences)
- **Windows**: Requires WSL or similar environment

## Dependencies

- **C++17** compatible compiler (g++ or clang++)
- Standard C++ library
- POSIX system calls (for file operations)

## Troubleshooting

### Common Issues

**Q: Command not found after installation**
```bash
# Check if ~/.local/bin is in PATH
echo $PATH | grep -q "$HOME/.local/bin" && echo "PATH OK" || echo "PATH missing"
# Add to PATH if missing
export PATH="$HOME/.local/bin:$PATH"
```

**Q: Man page not accessible**
```bash
# Update man database
mandb -q
# Check man page path
man -w ms
```

**Q: Compilation errors**
```bash
# Check C++ compiler version
g++ --version
# Ensure C++17 support
g++ -std=c++17 -E -x c++ - < /dev/null > /dev/null && echo "C++17 OK" || echo "C++17 not supported"
```

**Q: Zebra colors not working**
- Some terminal emulators may not support ANSI colors
- Try a different terminal or disable color schemes
- Colors work best on dark backgrounds

### Performance Notes

- Large directories may take longer to process
- Tree view on deep directory structures can be slow
- Use `-d` flag for faster listings basic
- Consider using `--sort=name` for large directories

## Development

### Building from Source

```bash
# Compile with debugging symbols
g++ -std=c++17 -g -Wall -Wextra -o ms-debug ms.cpp

# Compile with maximum optimization
g++ -std=c++17 -O3 -Wall -Wextra -o ms ms.cpp
```

### Code Structure

The source code is organized into:
- **Main function**: Command-line argument parsing
- **MSCommand class**: Core functionality
- **File operations**: Directory reading and file metadata
- **Display functions**: Various output formatting methods
- **Utility functions**: Size formatting, time formatting, etc.

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This software is provided as-is for educational and practical use. Feel free to modify and distribute according to your needs.

## Support

For issues, questions, or suggestions:
- Check the man page: `man ms`
- Run `ms --help` for quick reference
- Review this documentation

## Version History

### Version 1.0 (Current)
- Initial release
- All core features implemented
- Tree, table, and zebra display modes
- Comprehensive sorting and filtering options
- Man page and installation script

---

**Author**: Lotuschain_org Agent  
**Last Updated**: December 2025