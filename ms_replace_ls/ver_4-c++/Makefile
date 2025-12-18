# Makefile for ms command
# Provides convenient compilation and installation targets

CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2
TARGET = ms
SOURCE = ms.cpp
MAN_PAGE = ms.1

# Installation paths
INSTALL_PREFIX = /usr/local
BIN_DIR = $(INSTALL_PREFIX)/bin
MAN_DIR = $(INSTALL_PREFIX)/share/man/man1

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m

.PHONY: all clean install uninstall test help

# Default target
all: $(TARGET)

# Compile the ms command
$(TARGET): $(SOURCE)
	@echo "$(GREEN)Compiling ms command...$(NC)"
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SOURCE)
	@echo "$(GREEN)Compilation successful!$(NC)"

# Clean build artifacts
clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	rm -f $(TARGET)
	rm -rf build/
	@echo "$(GREEN)Clean complete!$(NC)"

# Install system-wide (requires root)
install: $(TARGET)
	@echo "$(GREEN)Installing ms command...$(NC)"
	@if [ "$$(id -u)" != "0" ]; then \
		echo "$(RED)Warning: Installing system-wide requires root privileges$(NC)"; \
		echo "$(YELLOW)Use 'sudo make install' or run as root$(NC)"; \
		exit 1; \
	fi
	install -d $(BIN_DIR) $(MAN_DIR)
	install -m 755 $(TARGET) $(BIN_DIR)/$(TARGET)
	install -m 644 $(MAN_PAGE) $(MAN_DIR)/$(MAN_PAGE)
	mandb -q 2>/dev/null || true
	@echo "$(GREEN)Installation complete!$(NC)"
	@echo "$(GREEN)You can now use: ms --help$(NC)"

# Install user-local (no root required)
install-user: $(TARGET)
	@echo "$(GREEN)Installing ms command locally...$(NC)"
	mkdir -p ~/.local/bin ~/.local/share/man/man1
	install -m 755 $(TARGET) ~/.local/bin/$(TARGET)
	install -m 644 $(MAN_PAGE) ~/.local/share/man/man1/$(MAN_PAGE)
	@echo "$(GREEN)Installation complete!$(NC)"
	@echo "$(YELLOW)Don't forget to add ~/.local/bin to your PATH$(NC)"
	@echo "$(YELLOW)Add this line to your ~/.bashrc or ~/.zshrc:$(NC)"
	@echo "$(YELLOW)export PATH=\"$$HOME/.local/bin:$$PATH\"$(NC)"

# Uninstall system-wide
uninstall:
	@echo "$(GREEN)Uninstalling ms command...$(NC)"
	@if [ "$$(id -u)" != "0" ]; then \
		echo "$(RED)Warning: Uninstalling system-wide requires root privileges$(NC)"; \
		echo "$(YELLOW)Use 'sudo make uninstall' or run as root$(NC)"; \
		exit 1; \
	fi
	rm -f $(BIN_DIR)/$(TARGET)
	rm -f $(MAN_DIR)/$(MAN_PAGE)
	mandb -q 2>/dev/null || true
	@echo "$(GREEN)Uninstall complete!$(NC)"

# Test the compiled binary
test: $(TARGET)
	@echo "$(GREEN)Running tests...$(NC)"
	@echo "Test 1: Help message"
	./$(TARGET) --help > /dev/null && echo "$(GREEN)✓ Help test passed$(NC)" || echo "$(RED)✗ Help test failed$(NC)"
	@echo "Test 2: Basic listing"
	./$(TARGET) . > /dev/null && echo "$(GREEN)✓ Basic listing test passed$(NC)" || echo "$(RED)✗ Basic listing test failed$(NC)"
	@echo "Test 3: Long format"
	./$(TARGET) -l . > /dev/null && echo "$(GREEN)✓ Long format test passed$(NC)" || echo "$(RED)✗ Long format test failed$(NC)"
	@echo "Test 4: Tree view"
	./$(TARGET) -k . > /dev/null && echo "$(GREEN)✓ Tree view test passed$(NC)" || echo "$(RED)✗ Tree view test failed$(NC)"
	@echo "Test 5: Table mode"
	./$(TARGET) -n . > /dev/null && echo "$(GREEN)✓ Table mode test passed$(NC)" || echo "$(RED)✗ Table mode test failed$(NC)"
	@echo "Test 6: Zebra view"
	./$(TARGET) -z . > /dev/null && echo "$(GREEN)✓ Zebra view test passed$(NC)" || echo "$(RED)✗ Zebra view test failed$(NC)"
	@echo "Test 7: Sorting"
	./$(TARGET) --sort=size . > /dev/null && echo "$(GREEN)✓ Sorting test passed$(NC)" || echo "$(RED)✗ Sorting test failed$(NC)"
	@echo "Test 8: Human readable"
	./$(TARGET) -H . > /dev/null && echo "$(GREEN)✓ Human readable test passed$(NC)" || echo "$(RED)✗ Human readable test failed$(NC)"
	@echo "$(GREEN)All tests completed!$(NC)"

# Debug build
debug:
	@echo "$(GREEN)Building debug version...$(NC)"
	$(CXX) -std=c++17 -g -Wall -Wextra -O0 -o $(TARGET) $(SOURCE)
	@echo "$(GREEN)Debug build complete!$(NC)"

# Release build with optimizations
release:
	@echo "$(GREEN)Building release version...$(NC)"
	$(CXX) -std=c++17 -O3 -Wall -Wextra -flto -o $(TARGET) $(SOURCE)
	@echo "$(GREEN)Release build complete!$(NC)"

# Show help
help:
	@echo "$(YELLOW)Available targets:$(NC)"
	@echo "  all          - Build the ms command (default)"
	@echo "  clean        - Remove build artifacts"
	@echo "  install      - Install system-wide (requires root)"
	@echo "  install-user - Install user-local (no root required)"
	@echo "  uninstall    - Remove system-wide installation"
	@echo "  test         - Run basic functionality tests"
	@echo "  debug        - Build with debug symbols"
	@echo "  release      - Build optimized release version"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make              # Build ms"
	@echo "  make test         # Run tests"
	@echo "  make install-user # Install to ~/.local/bin"
	@echo "  make clean        # Clean build files"