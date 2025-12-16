# ms - Modern ls Command Replacement

**ms** is a feature-rich replacement for the traditional `ls` command, providing enhanced formatting, better color coding, categorization of files, and additional filtering options.

![ms Command Demo](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)
![Python](https://img.shields.io/badge/Python-3.6%2B-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

## Features

### 🎨 Enhanced Visual Output
- **Color-coded file identification
- **Smart size types** for easy-based coloring** (red for large files, yellow for medium)
- **Categorized display** (directories, files, links, special files)

### 📊 Advanced Features
- **Human-readable sizes** (1K, 2M, 3G format)
- **Pattern filtering** with wildcard support
- **Custom time formatting**
- **Summary statistics** showing file counts
- **Multiple sorting options**

### 🔧 Enhanced Compatibility
- Drop-in replacement for `ls`
- Compatible with existing scripts
- Extended functionality without breaking changes

## Installation

### Quick Install

1. **Download the files:**
   ```bash
   wget https://github.com/your-repo/ms/releases/latest/download/ms.tar.gz
   tar -xzf ms.tar.gz
   cd ms
   ```

2. **Run the installer:**
   ```bash
   # For user-local installation (recommended)
   ./install.sh
   
   # For system-wide installation (requires root)
   sudo ./install.sh --system
   ```

### Installation Features
- **Automatic backup**: The installer automatically backs up any existing `ms` command or man page before replacing them
- **Existing installation detection**: The installer checks for existing installations and asks for confirmation before replacing
- **Dependency management**: Automatically installs required Python packages
- **PATH configuration**: Adds installation directory to PATH if needed

### Manual Installation

1. **Copy the script:**
   ```bash
   cp ms.py /usr/local/bin/ms
   chmod +x /usr/local/bin/ms
   ```

2. **Install man page:**
   ```bash
   sudo cp ms.1 /usr/local/share/man/man1/
   sudo mandb -q  # Update man database
   ```

3. **Install dependencies:**
   ```bash
   # Standard installation
   pip3 install humanize
   
   # If you get "externally-managed-environment" error, try:
   pip3 install --break-system-packages humanize
   
   # Or install via apt (if available):
   sudo apt install python3-humanize
   
   # Or use a virtual environment:
   python3 -m venv ms_env
   source ms_env/bin/activate
   pip install humanize
   ```

## Usage

### Basic Examples

```bash
# List current directory (simple replacement for ls)
ms

# List with all details (replacement for ls -la)
ms -l

# Show all files including hidden (replacement for ls -a)
ms -a

# Long format with human-readable sizes
ms -lH

# Show summary statistics
ms -s
```

### Advanced Examples

```bash
# Sort by size, reverse order
ms -Sr

# Filter Python files with summary
ms --pattern="*.py" -s

# Custom time format
ms -l --time-format="%Y-%m-%d %H:%M"

# List specific directories
ms /etc /var/log

# Combined options
ms -laSr --pattern="*.conf" --summary
```

### Pattern Filtering

```bash
# Show all Python files
ms --pattern="*.py"

# Show files starting with "test"
ms --pattern="test_*"

# Show all config files
ms --pattern="*.conf"

# Show files with numbers
ms --pattern="*[0-9]*"
```

## Command Line Options

| Option | Description | Example |
|--------|-------------|---------|
| `-l, --long` | Long format with details | `ms -l` |
| `-a, --all` | Show hidden files | `ms -a` |
| `-r, --reverse` | Reverse sort order | `ms -r` |
| `-t, --sort` | Sort by name/size/time/type | `ms -t size` |
| `-s, --summary` | Show summary statistics | `ms -s` |
| `-H, --human` | Human readable sizes | `ms -H` |
| `-h, --help` | Show help message | `ms -h` or `ms --help` |
| `-k, --tree` | Tree view listing | `ms -k` |
| `-K, --tree-metadata` | Tree view with metadata | `ms -K` |
| `-n, --table` | Table view with name and size | `ms -n` |
| `-N, --two-column` | Two column view | `ms -N` |
| `-z, --zebra` | Zebra striping list view | `ms -z` |
| `-Z, --zebra-metadata` | Zebra striping with metadata | `ms -Z` |
| `--pattern` | Filter by pattern | `ms --pattern="*.py"` |
| `--time-format` | Custom time format | `ms --time-format="%Y-%m-%d"` |
| `--version` | Show version | `ms --version` |

### Sort Options
- `name`: Sort alphabetically (default)
- `size`: Sort by file size
- `time`: Sort by modification time
- `type`: Sort by file type

### Output Modes

The `ms` command provides multiple output formats to suit different needs:

#### Tree View (`-k`, `-K`)
Hierarchical tree-style display of directory contents.
- `-k`: Basic tree view
- `-K`: Tree view with metadata (size and modification time)

```
ms -k
├── Documents/
├── photos/
├── report.pdf
└── script.py
```

#### Table View (`-n`)
Tabular format showing filename and size columns for easy comparison.

```
ms -n
Name                 Size
-------------------------
Documents/    4.0 kB
photos/       2.1 MB
report.pdf    145 kB
script.py     2.3 kB
```

#### Two-Column View (`-N`)
Efficient space utilization by displaying items in two columns.

```
ms -N
Documents/                       photos/
report.pdf                       script.py
```

#### Zebra View (`-z`, `-Z`)
Alternating row colors for improved readability.
- `-z`: Basic zebra striping
- `-Z`: Zebra striping with metadata

```
ms -z
📁 Documents/
📄 report.pdf
📁 photos/
📄 script.py
```

## Output Guide

### Color Coding

| Color | File Type | Example |
|-------|-----------|---------|
| **Blue** | Directories | `📁 folder/` |
| **Cyan** | Symbolic links | `🔗 link -> target` |
| **Magenta** | Special files | `⚙️ device, pipe, socket` |
| **Red** | Large files (>1MB) | `📄 largefile.txt` |
| **Yellow** | Medium files (1KB-1MB) | `📄 mediumfile.txt` |
| **Default** | Small files | `📄 smallfile.txt` |

### Long Format Output

```
drwxr-xr-x  2 user   group     4.0K  Dec 17 10:30  📁 Documents/
-rw-r--r--  1 user   group     1.2M  Dec 17 09:15  📄 large_video.mp4
-rw-r--r--  1 user   group    45.6K  Dec 17 08:45  📄 photo.jpg
lrwxrwxrwx   1 user   group        12 Dec 17 11:00  🔗 link -> /path/to/file
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `COLORS` | Enable/disable color output | Auto-detect terminal |

## Configuration

### Custom Time Formats

Use standard Python strftime format codes:

```bash
# ISO format
ms -l --time-format="%Y-%m-%d %H:%M:%S"

# Month name, day, year, 24-hour time
ms -l --time-format="%b %d, %Y %H:%M"

# Relative time (if supported)
ms -l --time-format="%Y-%m-%d %H:%M"
```

### Common strftime Codes

| Code | Description | Example |
|------|-------------|---------|
| `%Y` | Year | `2025` |
| `%m` | Month (01-12) | `12` |
| `%d` | Day (01-31) | `17` |
| `%H` | Hour (00-23) | `10` |
| `%M` | Minute (00-59) | `30` |
| `%b` | Month abbreviation | `Dec` |
| `%B` | Full month name | `December` |

## Comparison with ls

| Feature | `ls` | `ms` |
|---------|------|-----|
| Basic listing | ✅ | ✅ |
| Long format | ✅ | ✅ |
| Color coding | ✅ | ✅ |
| Hidden files | ✅ | ✅ |
| File type categorization | ❌ | ✅ |
| Human readable sizes | ⚠️ | ✅ |
| Pattern filtering | ❌ | ✅ |
| Summary statistics | ❌ | ✅ |
| Size-based coloring | ❌ | ✅ |
| Custom time formats | ❌ | ✅ |

## Dependencies

- **Python 3.6+**: Core runtime
- **humanize**: Human-readable size formatting (install with `pip install humanize`)

## Troubleshooting

### Command not found
```bash
# Check if ms is in PATH
which ms

# If installed locally, ensure ~/.local/bin is in PATH
echo $PATH | grep -q "$HOME/.local/bin" && echo "In PATH" || echo "Not in PATH"

# Add to PATH if needed
export PATH="$HOME/.local/bin:$PATH"
```

### Permission denied
```bash
# Make executable
chmod +x /usr/local/bin/ms
# or
chmod +x ~/.local/bin/ms
```

### Missing dependencies
```bash
# Install humanize package
pip3 install humanize
# or
pip install humanize --user
```

### Man page not found
```bash
# Update man database
sudo mandb -q

# Check man path
manpath

# Set custom MANPATH if needed
export MANPATH="$HOME/.local/share/man:$MANPATH"
```

## Contributing

Contributions are welcome! Please feel free to submit issues and enhancement requests.

### Development Setup

1. Clone the repository
2. Make changes to `ms.py`
3. Test your changes
4. Update documentation if needed
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created by **MiniMax Agent** - An AI assistant specialized in development tasks.

## Changelog

### Version 1.1.1 (December 2025)
- Added -h as --help alternative (removed --help-short)
- Added support for doors (D) file type for Solaris compatibility
- Enhanced file type detection and categorization
- Improved help system with standard -h option

### Version 1.1.0 (December 2025)
- Added new output modes: tree view (-k, -K), table view (-n), two-column view (-N)
- Added zebra striping views (-z, -Z) for improved readability
- Enhanced installer with existing installation detection and replacement handling
- Automatic backup of existing ms commands and man pages
- Improved documentation and examples

### Version 1.0.0 (December 2025)
- Initial release
- Full ls replacement functionality
- Enhanced color coding and formatting
- Pattern filtering and sorting options
- Summary statistics
- Comprehensive man page and documentation

## Support

For issues, questions, or suggestions:

1. Check the [troubleshooting section](#troubleshooting)
2. Review the man page: `man ms`
3. Use `--help` for quick reference: `ms --help`
4. Open an issue on the project repository

---

**Happy file listing with ms! 🎉**