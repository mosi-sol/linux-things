#!/usr/bin/env python3
"""
File Organizer Script
Organizes files in subdirectories by their types/categories.
"""

import os
import sys
import argparse
import shutil
import pathlib
from pathlib import Path
import mimetypes
import re
from typing import Dict, List, Tuple
import hashlib


class FileOrganizer:
    def __init__(self):
        # Mode settings
        self.quiet_mode = False
        self.auto_confirm = False
        
        # Define file categories and their extensions
        self.file_categories = {
            'Images': ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.svg', '.webp', '.ico', '.raw'],
            'Documents': ['.pdf', '.doc', '.docx', '.txt', '.rtf', '.odt', '.pages', '.tex'],
            'Spreadsheets': ['.xls', '.xlsx', '.csv', '.ods', '.numbers'],
            'Presentations': ['.ppt', '.pptx', '.odp', '.key'],
            'Videos': ['.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.3gp'],
            'Audio': ['.mp3', '.wav', '.flac', '.aac', '.ogg', '.wma', '.m4a', '.opus'],
            'Archives': ['.zip', '.rar', '.7z', '.tar', '.gz', '.bz2', '.xz', '.iso'],
            'Code': ['.py', '.js', '.html', '.css', '.java', '.cpp', '.c', '.php', '.rb', '.go', '.rs'],
            'Executables': ['.exe', '.msi', '.deb', '.rpm', '.dmg', '.app', '.run', '.sh'],
            'CAD': ['.dwg', '.dxf', '.step', '.stp', '.iges', '.igs', '.obj', '.stl'],
            'Data': ['.json', '.xml', '.yaml', '.yml', '.sql', '.db', '.sqlite', '.xlsx'],
            'ebooks': ['.epub', '.mobi', '.azw', '.azw3', '.lit', '.fb2']
        }
        
        # Create category folder mapping
        self.category_folders = {
            'Images': 'Images',
            'Documents': 'Documents',
            'Spreadsheets': 'Spreadsheets',
            'Presentations': 'Presentations',
            'Videos': 'Videos',
            'Audio': 'Audio',
            'Archives': 'Archives',
            'Code': 'Code',
            'Executables': 'Executables',
            'CAD': 'CAD_Files',
            'Data': 'Data_Files',
            'ebooks': 'eBooks'
        }

    def get_safe_path(self) -> str:
        """Ask user for a path and validate it's not a root directory."""
        print("=" * 60)
        print("FILE ORGANIZER")
        print("=" * 60)
        print()
        
        while True:
            path_input = input("Enter the directory path to organize: ").strip()
            
            if not path_input:
                print("❌ Path cannot be empty. Please try again.")
                continue
            
            # Expand user path (e.g., ~ to home directory)
            path_input = os.path.expanduser(path_input)
            
            # Convert to absolute path
            try:
                abs_path = os.path.abspath(path_input)
            except Exception as e:
                print(f"❌ Invalid path: {e}")
                continue
            
            # Check if path exists
            if not os.path.exists(abs_path):
                print(f"❌ Path does not exist: {abs_path}")
                continue
            
            # Check if it's a directory
            if not os.path.isdir(abs_path):
                print(f"❌ Path is not a directory: {abs_path}")
                continue
            
            # Check if it's a root directory
            if self.is_root_directory(abs_path):
                print("❌ This appears to be a root directory (C:\\, /, etc.)")
                print("Please choose a specific subdirectory instead.")
                print("Examples:")
                print("  Windows: C:\\Users\\YourName\\Downloads")
                print("  Mac/Linux: /Users/YourName/Downloads")
                continue
            
            # Confirm the path
            print(f"\n✓ Selected directory: {abs_path}")
            
            if self.auto_confirm:
                if not self.quiet_mode:
                    print("Auto-confirm mode: Proceeding...")
                return abs_path
            
            confirm = input("Is this correct? (y/N): ").strip().lower()
            
            if confirm in ['y', 'yes']:
                return abs_path
            else:
                print("Let's try again...\n")

    def is_root_directory(self, path: str) -> bool:
        """Check if the given path is a root directory."""
        path = os.path.normpath(path)
        
        # Windows root directories
        if os.name == 'nt':
            drive_letter = path[:3]  # e.g., 'C:\\'
            if drive_letter.endswith(':\\') and len(drive_letter) == 3:
                return True
            # Also check for just drive letters
            if len(path) == 2 and path[1] == ':':
                return True
        
        # Unix/Linux/Mac root directories
        if path == '/' or path == '\\':
            return True
        
        return False

    def get_file_category(self, file_path: str) -> str:
        """Determine the category of a file based on its extension."""
        file_ext = Path(file_path).suffix.lower()
        
        for category, extensions in self.file_categories.items():
            if file_ext in extensions:
                return category
        
        # Check by MIME type as fallback
        mime_type, _ = mimetypes.guess_type(file_path)
        if mime_type:
            if mime_type.startswith('image/'):
                return 'Images'
            elif mime_type.startswith('video/'):
                return 'Videos'
            elif mime_type.startswith('audio/'):
                return 'Audio'
            elif mime_type.startswith('text/'):
                return 'Documents'
        
        return 'Others'

    def get_safe_filename(self, original_path: str, target_dir: str) -> str:
        """Generate a safe filename, avoiding conflicts."""
        original_name = Path(original_path).name
        target_path = os.path.join(target_dir, original_name)
        
        if not os.path.exists(target_path):
            return original_name
        
        # Handle naming conflicts
        stem = Path(original_path).stem
        suffix = Path(original_path).suffix
        counter = 1
        
        while True:
            new_name = f"{stem}_{counter}{suffix}"
            new_path = os.path.join(target_dir, new_name)
            
            if not os.path.exists(new_path):
                return new_name
            counter += 1

    def organize_files(self, base_path: str) -> Dict[str, int]:
        """Organize files in the directory by their categories."""
        if not self.quiet_mode:
            print(f"\n🔍 Scanning directory: {base_path}")
            print("📊 Analyzing files...\n")
        
        stats = {category: 0 for category in self.category_folders.values()}
        stats['Others'] = 0
        stats['Folders'] = 0
        
        # Create category directories
        for category in self.category_folders.values():
            category_dir = os.path.join(base_path, category)
            if not os.path.exists(category_dir):
                os.makedirs(category_dir)
                if not self.quiet_mode:
                    print(f"📁 Created directory: {category}")
        
        # Also create "Others" folder for uncategorized files
        others_dir = os.path.join(base_path, "Others")
        if not os.path.exists(others_dir):
            os.makedirs(others_dir)
            if not self.quiet_mode:
                print(f"📁 Created directory: Others")
        
        # Process files
        for item in os.listdir(base_path):
            item_path = os.path.join(base_path, item)
            
            try:
                if os.path.isdir(item_path):
                    stats['Folders'] += 1
                    continue
                
                if os.path.isfile(item_path):
                    category = self.get_file_category(item_path)
                    
                    if category == 'Others':
                        category_folder = 'Others'
                    else:
                        category_folder = self.category_folders.get(category, 'Others')
                    
                    # Move file to appropriate category folder
                    safe_filename = self.get_safe_filename(item_path, 
                                                          os.path.join(base_path, category_folder))
                    target_path = os.path.join(base_path, category_folder, safe_filename)
                    
                    try:
                        shutil.move(item_path, target_path)
                        stats[category_folder] += 1
                        if not self.quiet_mode:
                            print(f"✅ Moved: {item} → {category_folder}/")
                    except Exception as e:
                        if not self.quiet_mode:
                            print(f"❌ Failed to move {item}: {e}")
                        
            except Exception as e:
                if not self.quiet_mode:
                    print(f"❌ Error processing {item}: {e}")
        
        return stats

    def print_summary(self, stats: Dict[str, int], base_path: str):
        """Print a summary of the organization results."""
        print("\n" + "=" * 60)
        print("📋 ORGANIZATION SUMMARY")
        print("=" * 60)
        
        total_files_moved = sum(v for k, v in stats.items() if k != 'Folders')
        
        print(f"📍 Base Directory: {base_path}")
        print(f"📊 Total files organized: {total_files_moved}")
        print(f"📁 Folders encountered: {stats['Folders']}")
        print()
        
        print("📈 Files by Category:")
        for category, count in stats.items():
            if category != 'Folders' and count > 0:
                print(f"   {category:<15}: {count:>3} files")
        
        print("\n" + "=" * 60)
        print("✨ Organization complete!")

    def run(self):
        """Main method to run the file organizer."""
        try:
            # Get safe path from user
            base_path = self.get_safe_path()
            
            # Show current directory structure
            print(f"\n📂 Current directory structure:")
            for item in sorted(os.listdir(base_path))[:10]:  # Show first 10 items
                item_path = os.path.join(base_path, item)
                if os.path.isdir(item_path):
                    print(f"   📁 {item}/")
                else:
                    print(f"   📄 {item}")
            
            if len(os.listdir(base_path)) > 10:
                print(f"   ... and {len(os.listdir(base_path)) - 10} more items")
            
            # Confirm organization
            print(f"\n⚠️  This will organize all files in this directory into category folders.")
            
            if self.auto_confirm:
                if not self.quiet_mode:
                    print("Auto-confirm mode: Proceeding with organization...")
            else:
                confirm = input("Proceed with organization? (y/N): ").strip().lower()
                
                if confirm not in ['y', 'yes']:
                    print("Organization cancelled.")
                    return
            
            # Organize files
            stats = self.organize_files(base_path)
            
            # Print summary
            self.print_summary(stats, base_path)
            
        except KeyboardInterrupt:
            print("\n\n⚠️  Operation cancelled by user.")
        except Exception as e:
            print(f"\n❌ An error occurred: {e}")
            print("Please check the directory permissions and try again.")


def setup_argument_parser():
    """Setup command line argument parser."""
    parser = argparse.ArgumentParser(
        description='Organize files in directories by type/category',
        epilog='Examples:\n'
               '  file-organizer                    # Interactive mode\n'
               '  file-organizer /path/to/dir       # Direct organization\n'
               '  file-organizer -q /path/to/dir    # Quiet mode\n'
               '  file-organizer -y /path/to/dir    # Auto-confirm',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument(
        'directory', 
        nargs='?', 
        help='Directory to organize (interactive mode if not provided)'
    )
    
    parser.add_argument(
        '-q', '--quiet',
        action='store_true',
        help='Run in quiet mode (suppress progress output)'
    )
    
    parser.add_argument(
        '-y', '--yes',
        action='store_true',
        help='Automatically answer yes to all prompts'
    )
    
    parser.add_argument(
        '-v', '--version',
        action='version',
        version='File Organizer 1.0 (Lotuschain_org Agent)',
        help='Show version information and exit'
    )
    
    return parser

def main():
    """Main entry point."""
    parser = setup_argument_parser()
    args = parser.parse_args()
    
    # Create organizer instance
    organizer = FileOrganizer()
    
    # Add quiet and auto-confirm attributes to organizer
    organizer.quiet_mode = getattr(args, 'quiet', False)
    organizer.auto_confirm = getattr(args, 'yes', False)
    
    # Handle direct directory organization
    if args.directory:
        try:
            # Validate the path
            abs_path = os.path.abspath(os.path.expanduser(args.directory))
            
            if not os.path.exists(abs_path):
                print(f"Error: Path does not exist: {abs_path}", file=sys.stderr)
                sys.exit(1)
            
            if not os.path.isdir(abs_path):
                print(f"Error: Path is not a directory: {abs_path}", file=sys.stderr)
                sys.exit(1)
            
            if organizer.is_root_directory(abs_path):
                print("Error: Cannot organize root directory", file=sys.stderr)
                sys.exit(1)
            
            # Organize the directory
            if not args.quiet:
                print(f"Organizing directory: {abs_path}")
            
            stats = organizer.organize_files(abs_path)
            
            if not args.quiet:
                organizer.print_summary(stats, abs_path)
            
            sys.exit(0)
            
        except KeyboardInterrupt:
            if not args.quiet:
                print("\nOperation cancelled by user.")
            sys.exit(130)
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
            sys.exit(1)
    
    # Interactive mode (no directory specified)
    try:
        organizer.run()
    except KeyboardInterrupt:
        print("\nOperation cancelled by user.")
        sys.exit(130)


if __name__ == "__main__":
    main()