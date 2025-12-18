#!/bin/bash

# ms command demonstration script
# Shows various features and modes of the ms command

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if ms command exists
check_ms_command() {
    if command -v ms >/dev/null 2>&1; then
        MS_CMD="ms"
        echo -e "${GREEN}Found ms command: $(which ms)${NC}"
    elif [ -f "./ms" ]; then
        MS_CMD="./ms"
        echo -e "${GREEN}Found local ms binary${NC}"
    else
        echo -e "${RED}Error: ms command not found${NC}"
        echo "Please compile the ms command first:"
        echo "  g++ -std=c++17 -O2 -Wall -Wextra -o ms ms.cpp"
        exit 1
    fi
    echo
}

# Create demo directory structure
create_demo_structure() {
    echo -e "${YELLOW}Creating demo directory structure...${NC}"
    
    # Create directory structure
    mkdir -p demo/{docs,src,images,data}/{sub1,sub2}
    
    # Create various files
    echo "This is a README file" > demo/README.md
    echo "Small text file" > demo/small.txt
    echo "Medium sized file with some content here" > demo/medium.txt
    echo "Large file with lots of content to demonstrate size formatting in human readable mode" > demo/large.txt
    echo "Configuration file content" > demo/config.json
    echo "Script content" > demo/script.sh
    echo "Data file content" > demo/data.csv
    echo "Log entry" > demo/app.log
    echo "Hidden config" > demo/.hidden_config
    echo "Another hidden" > demo/.secret
    
    # Create files in subdirectories
    echo "Source file" > demo/src/main.cpp
    echo "Header file" > demo/src/header.h
    echo "Documentation" > demo/docs/guide.pdf
    echo "Image file content" > demo/images/photo.jpg
    echo "Dataset" > demo/data/dataset.csv
    echo "Deep file" > demo/docs/sub1/deep.txt
    echo "Deeper file" > demo/src/sub2/deeper.cpp
    
    # Create symlink
    ln -s README.md demo/link_to_readme
    
    echo -e "${GREEN}Demo structure created${NC}"
    echo
}

# Cleanup demo structure
cleanup_demo() {
    echo -e "${YELLOW}Cleaning up demo structure...${NC}"
    rm -rf demo
    echo -e "${GREEN}Cleanup complete${NC}"
    echo
}

# Print section header
print_section() {
    local title="$1"
    echo
    echo -e "${PURPLE}═══════════════════════════════════════${NC}"
    echo -e "${PURPLE}  $title${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════${NC}"
    echo
}

# Print subsection
print_subsection() {
    local title="$1"
    echo -e "${CYAN}▶ $title${NC}"
    echo "Command: $2"
    echo "----------------------------------------"
}

# Demo basic listing
demo_basic_listing() {
    print_section "BASIC LISTING MODES"
    
    print_subsection "Default listing" "$MS_CMD demo"
    $MS_CMD demo
    echo
    
    print_subsection "Long format listing" "$MS_CMD -l demo"
    $MS_CMD -l demo
    echo
    
    print_subsection "Include hidden files" "$MS_CMD -a demo"
    $MS_CMD -a demo
    echo
    
    print_subsection "All files with details" "$MS_CMD -la demo"
    $MS_CMD -la demo
    echo
}

# Demo tree view
demo_tree_view() {
    print_section "TREE VIEW MODES"
    
    print_subsection "Simple tree view" "$MS_CMD -k demo"
    $MS_CMD -k demo
    echo
    
    print_subsection "Tree with metadata" "$MS_CMD -K demo"
    $MS_CMD -K demo
    echo
}

# Demo table modes
demo_table_modes() {
    print_section "TABLE DISPLAY MODES"
    
    print_subsection "Table with name and size" "$MS_CMD -n demo"
    $MS_CMD -n demo
    echo
    
    print_subsection "Table with human readable sizes" "$MS_CMD -nH demo"
    $MS_CMD -nH demo
    echo
    
    print_subsection "Two column layout" "$MS_CMD -N demo"
    $MS_CMD -N demo
    echo
    
    print_subsection "Horizontal table" "$MS_CMD -t demo"
    $MS_CMD -t demo
    echo
    
    print_subsection "Horizontal table with metadata" "$MS_CMD -TH demo"
    $MS_CMD -TH demo
    echo
}

# Demo zebra list
demo_zebra_list() {
    print_section "ZEBRA LIST MODES"
    
    print_subsection "Zebra striped list" "$MS_CMD -z demo"
    $MS_CMD -z demo
    echo
    
    print_subsection "Zebra with metadata" "$MS_CMD -Z demo"
    $MS_CMD -Z demo
    echo
    
    print_subsection "Zebra with all files" "$MS_CMD -za demo"
    $MS_CMD -za demo
    echo
}

# Demo sorting options
demo_sorting() {
    print_section "SORTING OPTIONS"
    
    print_subsection "Sort by name (default)" "$MS_CMD --sort=name demo"
    $MS_CMD --sort=name demo
    echo
    
    print_subsection "Sort by size" "$MS_CMD --sort=size demo"
    $MS_CMD --sort=size demo
    echo
    
    print_subsection "Sort by size (human readable)" "$MS_CMD -H --sort=size demo"
    $MS_CMD -H --sort=size demo
    echo
    
    print_subsection "Sort by time" "$MS_CMD --sort=time demo"
    $MS_CMD --sort=time demo
    echo
    
    print_subsection "Sort by type" "$MS_CMD --sort=type demo"
    $MS_CMD --sort=type demo
    echo
    
    print_subsection "Reverse sort" "$MS_CMD --sort=name --reverse demo"
    $MS_CMD --sort=name --reverse demo
    echo
}

# Demo combined options
demo_combined_options() {
    print_section "COMBINED OPTIONS"
    
    print_subsection "Long format with human readable" "$MS_CMD -lH demo"
    $MS_CMD -lH demo
    echo
    
    print_subsection "Recursive listing" "$MS_CMD -R demo"
    $MS_CMD -R demo
    echo
    
    print_subsection "Recursive tree view" "$MS_CMD -kR demo"
    $MS_CMD -kR demo | head -20  # Limit output for demo
    echo "... (output truncated)"
    echo
    
    print_subsection "All options combined" "$MS_CMD -laHR --sort=size demo"
    $MS_CMD -laHR --sort=size demo
    echo
}

# Demo practical examples
demo_practical_examples() {
    print_section "PRACTICAL EXAMPLES"
    
    print_subsection "Project overview" "$MS_CMD -nH ."
    $MS_CMD -nH . | head -10
    echo "... (output truncated)"
    echo
    
    print_subsection "Recent files" "$MS_CMD -l --sort=time ."
    $MS_CMD -l --sort=time . | head -10
    echo "... (output truncated)"
    echo
    
    print_subsection "Large files first" "$MS_CMD -lH --sort=size --reverse ."
    $MS_CMD -lH --sort=size --reverse . | head -10
    echo "... (output truncated)"
    echo
    
    print_subsection "Code files analysis" "$MS_CMD -n --sort=type demo/src"
    $MS_CMD -n --sort=type demo/src
    echo
}

# Show help and comparison
show_help_comparison() {
    print_section "HELP AND COMPARISON"
    
    print_subsection "Show help" "$MS_CMD --help"
    $MS_CMD --help | head -20
    echo "... (help truncated)"
    echo
    
    print_subsection "Compare with standard ls" "ls -la | head -5"
    echo -e "${YELLOW}Standard ls output:${NC}"
    ls -la . | head -5
    echo
    
    print_subsection "Compare with ms" "$MS_CMD -la | head -5"
    echo -e "${YELLOW}MS command output:${NC}"
    $MS_CMD -la . | head -5
    echo
}

# Main demo function
main() {
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    MS COMMAND DEMONSTRATION                   ║${NC}"
    echo -e "${GREEN}║                Modern ls Replacement Features                 ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    check_ms_command
    create_demo_structure
    
    # Run demonstrations
    demo_basic_listing
    demo_tree_view
    demo_table_modes
    demo_zebra_list
    demo_sorting
    demo_combined_options
    demo_practical_examples
    show_help_comparison
    
    # Cleanup
    cleanup_demo
    
    # Final summary
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                     DEMONSTRATION COMPLETE                    ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}Key Features Demonstrated:${NC}"
    echo "  ✓ Multiple display modes (tree, table, zebra)"
    echo "  ✓ Human readable file sizes"
    echo "  ✓ Advanced sorting options"
    echo "  ✓ Metadata display"
    echo "  ✓ Recursive listing"
    echo "  ✓ Hidden file support"
    echo "  ✓ Combined options"
    echo
    echo -e "${BLUE}Try these commands:${NC}"
    echo "  ms --help              # Show all options"
    echo "  ms -k /usr/bin         # Tree view of system binaries"
    echo "  ms -nH ~               # Table view of home directory"
    echo "  ms -zR .               # Zebra view recursively"
    echo "  man ms                 # Read the manual page"
    echo
}

# Run main function
main "$@"