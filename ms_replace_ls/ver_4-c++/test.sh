#!/bin/bash

# ms command test script
# Tests various features and modes of the ms command

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test results
print_test_result() {
    local test_name="$1"
    local result="$2"
    
    ((TESTS_RUN++))
    
    if [ "$result" -eq 0 ]; then
        echo -e "${GREEN}[PASS]${NC} $test_name"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}[FAIL]${NC} $test_name"
        ((TESTS_FAILED++))
    fi
}

# Function to run a test
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_exit_code="${3:-0}"
    
    echo -e "${BLUE}Running: $test_name${NC}"
    echo "Command: $command"
    
    eval "$command" > /dev/null 2>&1
    local exit_code=$?
    
    if [ $exit_code -eq $expected_exit_code ]; then
        print_test_result "$test_name" 0
    else
        print_test_result "$test_name" 1
        echo "Expected exit code: $expected_exit_code, got: $exit_code"
    fi
    echo
}

# Create test directory structure
setup_test_environment() {
    echo -e "${YELLOW}Setting up test environment...${NC}"
    
    # Create test directory
    mkdir -p test_dir/subdir1/subdir2
    mkdir -p test_dir/subdir1/another_subdir
    
    # Create test files
    echo "Test file 1" > test_dir/file1.txt
    echo "Test file 2 with more content" > test_dir/file2.txt
    echo "Small file" > test_dir/small.txt
    echo "Large file content that should be bigger than small file" > test_dir/large.txt
    echo "Hidden file" > test_dir/.hidden_file
    echo "Another hidden" > test_dir/.another_hidden
    
    # Create symlink
    ln -s file1.txt test_dir/link_to_file1
    
    # Create files in subdirectories
    echo "Sub file" > test_dir/subdir1/sub_file.txt
    echo "Deep file" > test_dir/subdir1/subdir2/deep_file.txt
    
    echo -e "${GREEN}Test environment created${NC}"
    echo
}

# Cleanup test environment
cleanup_test_environment() {
    echo -e "${YELLOW}Cleaning up test environment...${NC}"
    rm -rf test_dir
    echo -e "${GREEN}Cleanup complete${NC}"
    echo
}

# Check if ms command exists
check_ms_command() {
    echo -e "${BLUE}Checking if ms command exists...${NC}"
    
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

# Test basic functionality
test_basic_functionality() {
    echo -e "${YELLOW}=== BASIC FUNCTIONALITY TESTS ===${NC}"
    
    # Help command
    run_test "Help command" "$MS_CMD --help" 0
    
    # Basic listing
    run_test "Basic listing" "$MS_CMD test_dir" 0
    
    # Long format
    run_test "Long format" "$MS_CMD -l test_dir" 0
    
    # Hidden files
    run_test "Show hidden files" "$MS_CMD -a test_dir" 0
    
    # Non-existent directory (should fail)
    run_test "Non-existent directory" "$MS_CMD /nonexistent" 1
}

# Test display modes
test_display_modes() {
    echo -e "${YELLOW}=== DISPLAY MODE TESTS ===${NC}"
    
    # Tree view
    run_test "Tree view" "$MS_CMD -k test_dir" 0
    
    # Tree with metadata
    run_test "Tree with metadata" "$MS_CMD -K test_dir" 0
    
    # Table mode
    run_test "Table mode" "$MS_CMD -n test_dir" 0
    
    # Two column
    run_test "Two column mode" "$MS_CMD -N test_dir" 0
    
    # Zebra list
    run_test "Zebra list" "$MS_CMD -z test_dir" 0
    
    # Zebra with metadata
    run_test "Zebra with metadata" "$MS_CMD -Z test_dir" 0
    
    # Horizontal table
    run_test "Horizontal table" "$MS_CMD -t test_dir" 0
    
    # Horizontal table with metadata
    run_test "Horizontal table with metadata" "$MS_CMD -T test_dir" 0
}

# Test sorting options
test_sorting() {
    echo -e "${YELLOW}=== SORTING TESTS ===${NC}"
    
    # Sort by name
    run_test "Sort by name" "$MS_CMD --sort=name test_dir" 0
    
    # Sort by size
    run_test "Sort by size" "$MS_CMD --sort=size test_dir" 0
    
    # Sort by time
    run_test "Sort by time" "$MS_CMD --sort=time test_dir" 0
    
    # Sort by type
    run_test "Sort by type" "$MS_CMD --sort=type test_dir" 0
    
    # Reverse sort
    run_test "Reverse sort" "$MS_CMD --reverse --sort=name test_dir" 0
}

# Test combined options
test_combined_options() {
    echo -e "${YELLOW}=== COMBINED OPTIONS TESTS ===${NC}"
    
    # Long format with human readable
    run_test "Long format with human readable" "$MS_CMD -lH test_dir" 0
    
    # Table with human readable
    run_test "Table with human readable" "$MS_CMD -nH test_dir" 0
    
    # Zebra with hidden files
    run_test "Zebra with hidden files" "$MS_CMD -za test_dir" 0
    
    # Recursive tree
    run_test "Recursive tree" "$MS_CMD -kR test_dir" 0
    
    # All options combined
    run_test "All options combined" "$MS_CMD -laHR --sort=size test_dir" 0
}

# Test edge cases
test_edge_cases() {
    echo -e "${YELLOW}=== EDGE CASE TESTS ===${NC}"
    
    # Empty directory
    mkdir -p empty_dir
    run_test "Empty directory" "$MS_CMD empty_dir" 0
    rmdir empty_dir
    
    # Single file
    echo "single file" > single_file
    run_test "Single file" "$MS_CMD single_file" 0
    rm single_file
    
    # Multiple paths
    run_test "Multiple paths" "$MS_CMD test_dir . ms.cpp" 0
    
    # Current directory
    run_test "Current directory" "$MS_CMD ." 0
}

# Test error handling
test_error_handling() {
    echo -e "${YELLOW}=== ERROR HANDLING TESTS ===${NC}"
    
    # Invalid option
    run_test "Invalid option" "$MS_CMD -x" 1
    
    # Invalid sort option
    run_test "Invalid sort option" "$MS_CMD --sort=invalid test_dir" 1
}

# Performance test
test_performance() {
    echo -e "${YELLOW}=== PERFORMANCE TESTS ===${NC}"
    
    # Create many files for performance testing
    mkdir -p perf_test
    for i in {1..100}; do
        echo "file $i" > "perf_test/file$i.txt"
    done
    
    echo -e "${BLUE}Running performance test (100 files)...${NC}"
    time_output=$( { time $MS_CMD perf_test > /dev/null; } 2>&1 )
    
    # Extract real time from time output
    real_time=$(echo "$time_output" | grep real | awk '{print $2}')
    echo "Performance test completed in: $real_time"
    
    # Clean up
    rm -rf perf_test
    
    # We don't fail the test based on performance, just report it
    print_test_result "Performance test (100 files)" 0
}

# Main test function
main() {
    echo "=========================================="
    echo "        MS COMMAND TEST SUITE"
    echo "=========================================="
    echo
    
    check_ms_command
    setup_test_environment
    
    # Run all test suites
    test_basic_functionality
    test_display_modes
    test_sorting
    test_combined_options
    test_edge_cases
    test_error_handling
    test_performance
    
    # Cleanup
    cleanup_test_environment
    
    # Print summary
    echo "=========================================="
    echo "            TEST SUMMARY"
    echo "=========================================="
    echo "Total tests run: $TESTS_RUN"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
}

# Run main function
main "$@"