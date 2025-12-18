#!/usr/bin/env python3
"""
Demo script to show the File Organizer in action
"""

import os
import tempfile
import shutil
from pathlib import Path
import file_organizer


def create_demo_files():
    """Create some sample messy files for demonstration."""
    # Create a temporary directory
    demo_dir = tempfile.mkdtemp(prefix="file_organizer_demo_")
    
    print(f"📁 Creating demo files in: {demo_dir}")
    
    # Sample files to create
    sample_files = [
        "vacation_photo.jpg",
        "report.pdf", 
        "presentation.pptx",
        "budget_2024.xlsx",
        "music_song.mp3",
        "video_tutorial.mp4",
        "archive_backup.zip",
        "webpage.html",
        "script.py",
        "database.db",
        "ebook.epub",
        "random_file.tmp"
    ]
    
    # Create the sample files
    for filename in sample_files:
        file_path = os.path.join(demo_dir, filename)
        with open(file_path, 'w') as f:
            f.write(f"This is a demo file: {filename}\n")
            f.write("Created for file organization demonstration.")
    
    print(f"✅ Created {len(sample_files)} demo files")
    return demo_dir


def demonstrate_organizer():
    """Demonstrate the file organizer functionality."""
    print("=" * 70)
    print("FILE ORGANIZER DEMONSTRATION")
    print("=" * 70)
    print()
    
    # Create demo files
    demo_dir = create_demo_files()
    
    try:
        # Show files before organization
        print("\n📂 FILES BEFORE ORGANIZATION:")
        print("-" * 40)
        for item in sorted(os.listdir(demo_dir)):
            print(f"   📄 {item}")
        
        # Create organizer instance
        organizer = file_organizer.FileOrganizer()
        
        # Organize the demo files (simulate automatic organization)
        print(f"\n🔄 ORGANIZING FILES...")
        print("-" * 40)
        stats = organizer.organize_files(demo_dir)
        
        # Show results
        print("\n📊 ORGANIZATION RESULTS:")
        print("-" * 40)
        
        # Show new directory structure
        for category in sorted(os.listdir(demo_dir)):
            category_path = os.path.join(demo_dir, category)
            if os.path.isdir(category_path):
                files = os.listdir(category_path)
                print(f"📁 {category}/")
                for file in files:
                    print(f"   📄 {file}")
        
        # Show statistics
        print(f"\n📈 STATISTICS:")
        print("-" * 40)
        total_files = sum(v for k, v in stats.items() if k != 'Folders')
        print(f"Total files organized: {total_files}")
        for category, count in stats.items():
            if category != 'Folders' and count > 0:
                print(f"{category}: {count} files")
        
        print("\n✨ Demo completed successfully!")
        
    finally:
        # Clean up
        print(f"\n🧹 Cleaning up demo directory...")
        shutil.rmtree(demo_dir)
        print("✅ Demo directory removed")


def show_usage_example():
    """Show how to use the file organizer programmatically."""
    print("\n" + "=" * 70)
    print("PROGRAMMATIC USAGE EXAMPLE")
    print("=" * 70)
    
    example_code = '''
# Example: How to use the FileOrganizer class in your own code

from file_organizer import FileOrganizer

# Create organizer instance
organizer = FileOrganizer()

# Get a safe path from user (interactive)
path = organizer.get_safe_path()

# Or specify a path directly
# path = "/path/to/your/directory"

# Organize files and get statistics
stats = organizer.organize_files(path)

# Print results
organizer.print_summary(stats, path)

# Run the full interactive program
organizer.run()
'''
    
    print(example_code)


def main():
    """Main demonstration function."""
    try:
        # Show the demo
        demonstrate_organizer()
        
        # Show usage examples
        show_usage_example()
        
        print("\n" + "=" * 70)
        print("TO USE THE FILE ORGANIZER:")
        print("=" * 70)
        print("1. Run: python file_organizer.py")
        print("2. Enter a directory path when prompted")
        print("3. Confirm organization")
        print("4. Files will be organized into category folders")
        print()
        print("💡 The script will create folders like:")
        print("   📁 Images/, 📁 Documents/, 📁 Videos/, 📁 Audio/, etc.")
        print("=" * 70)
        
    except Exception as e:
        print(f"❌ Demo error: {e}")


if __name__ == "__main__":
    main()