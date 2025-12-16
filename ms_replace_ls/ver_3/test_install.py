#!/usr/bin/env python3
"""
Test script to simulate the installer's dependency checking
"""

import subprocess
import sys

def test_humanize_import():
    """Test if humanize is available"""
    try:
        import humanize
        print("✅ humanize is available")
        return True
    except ImportError:
        print("❌ humanize is not available")
        return False

def simulate_pip_error():
    """Simulate the externally-managed-environment error"""
    print("🔍 Simulating pip installation with externally-managed-environment error...")
    
    try:
        result = subprocess.run([
            sys.executable, "-m", "pip", "install", "--user", "nonexistent_package_test"
        ], capture_output=True, text=True, timeout=10)
        
        if "externally-managed-environment" in result.stderr:
            print("✅ Detected externally-managed-environment error")
            return True
        else:
            print("ℹ️  No externally-managed-environment error detected")
            return False
    except Exception as e:
        print(f"⚠️  Error during simulation: {e}")
        return False

def main():
    print("🧪 Testing installer dependency handling")
    print("=" * 50)
    
    # Test if humanize is available
    if test_humanize_import():
        print("📦 humanize package is already installed")
        return
    
    # Simulate the pip error scenario
    simulate_pip_error()
    
    print("\n💡 Installation guidance:")
    print("If you encounter 'externally-managed-environment' error:")
    print("1. Try: pip3 install --break-system-packages humanize")
    print("2. Or: sudo apt install python3-humanize")
    print("3. Or create virtual environment and install there")
    print("4. Or run installer with --system flag")

if __name__ == "__main__":
    main()