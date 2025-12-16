#!/bin/bash

# Install ms command
echo "Installing 'ms' command..."
sudo cp ms /usr/local/bin/ms
sudo chmod +x /usr/local/bin/ms

# Install man page
echo "Installing man page for 'ms'..."
sudo mkdir -p /usr/local/man/man1
sudo cp ms.1 /usr/local/man/man1/ms.1
sudo mandb

echo "Installation complete. You can now use 'ms' and 'man ms'."
