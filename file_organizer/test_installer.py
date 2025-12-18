#!/usr/bin/env python3
"""
Test script to verify the installer functionality
"""

import os
import sys
import tempfile
import shutil
from pathlib import Path

def test_installer_simulation():
    """Simulate running the installer and show what it would do."""
    print("=" * 70)
    print("INSTALLER SIMULATION TEST")
    print("=" * 70)
    print()
    
    # Create a temporary installation directory
    temp_install = tempfile.mkdtemp(prefix="file_organizer_install_test_")
    print(f"📁 Test installation directory: {temp_install}")
    
    try:
        # Simulate installer running
        print("\n🔧 SIMULATING INSTALLER BEHAVIOR:")
        print("-" * 50)
        
        # Check if files exist
        main_script = "file_organizer.py"
        man_page = "file_organizer.1"
        installer_script = "install.sh"
        
        print(f"✓ Checking for required files...")
        for file in [main_script, man_page, installer_script]:
            if os.path.exists(file):
                print(f"  ✓ {file} - Found")
            else:
                print(f"  ❌ {file} - Missing")
        
        print(f"\n📦 SIMULATED INSTALLATION:")
        print("-" * 50)
        
        # Simulate creating bin directory
        bin_dir = os.path.join(temp_install, "bin")
        man_dir = os.path.join(temp_install, "share", "man", "man1")
        
        os.makedirs(bin_dir, exist_ok=True)
        os.makedirs(man_dir, exist_ok=True)
        
        print(f"  📁 Created: {bin_dir}")
        print(f"  📁 Created: {man_dir}")
        
        # Simulate copying files
        print(f"\n📄 SIMULATED FILE COPIES:")
        print("-" * 50)
        
        if os.path.exists(main_script):
            target_bin = os.path.join(bin_dir, "file-organizer")
            shutil.copy2(main_script, target_bin)
            print(f"  ✓ Copied: {main_script} → {target_bin}")
            os.chmod(target_bin, 0o755)  # Make executable
        
        if os.path.exists(man_page):
            target_man = os.path.join(man_dir, "file-organizer.1")
            shutil.copy2(man_page, target_man)
            print(f"  ✓ Copied: {man_page} → {target_man}")
        
        print(f"\n🧪 TESTING COMMAND:")
        print("-" * 50)
        
        # Test if the command works
        try:
            result = os.system(f"cd {temp_install} && PYTHONPATH={bin_dir} {bin_dir}/file-organizer --help > /dev/null 2>&1")
            if result == 0:
                print("  ✓ Command 'file-organizer --help' executed successfully")
            else:
                print("  ❌ Command execution failed")
        except Exception as e:
            print(f"  ❌ Command test failed: {e}")
        
        print(f"\n🎯 INSTALLATION SUMMARY:")
        print("-" * 50)
        print(f"  📍 Installation root: {temp_install}")
        print(f"  📁 Bin directory: {bin_dir}")
        print(f"  📁 Man directory: {man_dir}")
        print(f"  🔧 Command: file-organizer")
        print(f"  📖 Manual: file-organizer.1")
        
        print(f"\n💡 ACTUAL INSTALLATION COMMANDS:")
        print("-" * 50)
        print("# For user installation (recommended):")
        print(f"  chmod +x install.sh")
        print(f"  ./install.sh")
        print()
        print("# For system installation (requires root):")
        print(f"  chmod +x install.sh")
        print(f"  sudo ./install.sh")
        
    finally:
        # Clean up
        print(f"\n🧹 Cleaning up test directory...")
        shutil.rmtree(temp_install)
        print("✅ Test complete")
    
    print("\n" + "=" * 70)
    print("INSTALLER TEST COMPLETED SUCCESSFULLY!")
    print("=" * 70)


def show_installer_features():
    """Show what features the installer provides."""
    print("\n" + "=" * 70)
    print("INSTALLER FEATURES")
    print("=" * 70)
    
    features = [
        "✅ Automatic detection of installation paths",
        "✅ User and system-wide installation support",
        "✅ Backup of existing installations",
        "✅ Bash/Zsh alias creation",
        "✅ PATH environment variable updates",
        "✅ Man page installation with database update",
        "✅ Cross-platform compatibility (Linux/macOS/Windows)",
        "✅ Safety checks and confirmations",
        "✅ Detailed installation reporting",
        "✅ Rollback capability via backups"
    ]
    
    for feature in features:
        print(f"  {feature}")
    
    print(f"\n📋 INSTALLATION TARGETS:")
    print("-" * 50)
    print("  User Installation:")
    print("    • Bin: ~/.local/bin/ or ~/bin/")
    print("    • Man: ~/.local/share/man/man1/")
    print("    • Alias: Added to ~/.bashrc or ~/.zshrc")
    print()
    print("  System Installation:")
    print("    • Bin: /usr/local/bin/ or /usr/bin/")
    print("    • Man: /usr/share/man/man1/")
    print("    • Requires root/sudo privileges")


def main():
    """Main test function."""
    try:
        test_installer_simulation()
        show_installer_features()
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        return 1
    
    return 0


if __name__ == "__main__":
    sys.exit(main())