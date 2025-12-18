# File Organizer

A Python script that automatically organizes messy files in directories by their types/categories.

## Features

- **Safe Path Validation**: Ensures you don't accidentally select a root directory
- **Smart Categorization**: Organizes files into logical categories
- **Conflict Resolution**: Handles filename conflicts automatically
- **User-Friendly Interface**: Clear prompts and progress feedback
- **Comprehensive Categories**: Supports 12+ file categories including images, documents, videos, audio, archives, and more

## File Categories

The script organizes files into these categories:

| Category | File Types |
|----------|------------|
| **Images** | .jpg, .jpeg, .png, .gif, .bmp, .tiff, .svg, .webp, .ico, .raw |
| **Documents** | .pdf, .doc, .docx, .txt, .rtf, .odt, .pages, .tex |
| **Spreadsheets** | .xls, .xlsx, .csv, .ods, .numbers |
| **Presentations** | .ppt, .pptx, .odp, .key |
| **Videos** | .mp4, .avi, .mkv, .mov, .wmv, .flv, .webm, .m4v, .3gp |
| **Audio** | .mp3, .wav, .flac, .aac, .ogg, .wma, .m4a, .opus |
| **Archives** | .zip, .rar, .7z, .tar, .gz, .bz2, .xz, .iso |
| **Code** | .py, .js, .html, .css, .java, .cpp, .c, .php, .rb, .go, .rs |
| **Executables** | .exe, .msi, .deb, .rpm, .dmg, .app, .run, .sh |
| **CAD Files** | .dwg, .dxf, .step, .stp, .iges, .igs, .obj, .stl |
| **Data Files** | .json, .xml, .yaml, .yml, .sql, .db, .sqlite, .xlsx |
| **eBooks** | .epub, .mobi, .azw, .azw3, .lit, .fb2 |
| **Others** | Any file types not listed above |

## Usage

### Interactive Mode (Recommended)

1. Run the script:
   ```bash
   python file_organizer.py
   ```

2. Enter a directory path when prompted (make sure it's not a root directory)

3. Confirm the organization

4. Files will be automatically organized into category folders

### Programmatic Usage

```python
from file_organizer import FileOrganizer

# Create organizer instance
organizer = FileOrganizer()

# Get a safe path from user (interactive)
path = organizer.get_safe_path()

# Organize files and get statistics
stats = organizer.organize_files(path)

# Print results
organizer.print_summary(stats, path)

# Or run the full interactive program
organizer.run()
```

### Direct Path Organization

```python
from file_organizer import FileOrganizer

# Create organizer instance
organizer = FileOrganizer()

# Specify a directory directly
path = "/path/to/your/directory"

# Organize files
stats = organizer.organize_files(path)
organizer.print_summary(stats, path)
```

## Safety Features

- **Root Directory Protection**: Won't allow organization of root directories (C:\, /, etc.)
- **Path Validation**: Validates that paths exist and are directories
- **Conflict Handling**: Automatically handles filename conflicts by adding numbers
- **Error Handling**: Graceful handling of errors and user cancellation
- **Preview**: Shows current files before organization

## Examples

### Before Organization
```
MyDownloads/
├── vacation_photo.jpg
├── report.pdf
├── music_song.mp3
├── video_tutorial.mp4
├── archive_backup.zip
└── random_file.tmp
```

### After Organization
```
MyDownloads/
├── Images/
│   └── vacation_photo.jpg
├── Documents/
│   └── report.pdf
├── Audio/
│   └── music_song.mp3
├── Videos/
│   └── video_tutorial.mp4
├── Archives/
│   └── archive_backup.zip
└── Others/
    └── random_file.tmp
```

## Running the Demo

To see the file organizer in action:

```bash
python demo_file_organizer.py
```

This will create sample files, organize them, and show you the results.

## Requirements

- Python 3.6 or higher
- Standard library modules (no external dependencies required)

## Files

- `file_organizer.py` - Main file organizer script
- `demo_file_organizer.py` - Demonstration script
- `README.md` - This documentation

## Author

Created by Lotuschain_org Agent