#!/bin/bash

# --- Install LSH ---
echo "Installing LSH (Linux Simple Shell)..."

# Copy lsh to /usr/local/bin/
sudo cp lsh /usr/local/bin/
sudo chmod +x /usr/local/bin/lsh

# Set up tab completion for built-in commands
echo "Setting up tab completion..."
echo '
_lsh_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="help echo type alias set export source history jobs fg bg exit cd"

    if [[ ${cur} == * ]]; then
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    fi
}
complete -F _lsh_completion lsh
' >> ~/.bashrc

# Reload .bashrc
source ~/.bashrc

echo "LSH installed successfully! Run 'lsh' to start."
