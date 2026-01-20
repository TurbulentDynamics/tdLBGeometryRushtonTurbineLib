# Makefile for tdLBGeometryRushtonTurbineLib
# Rushton Turbine Geometry Generator for Lattice Boltzmann Simulations

.PHONY: all build release debug test clean run help format lint

# Default target
all: build

# Build targets
build:
	swift build

debug:
	swift build -c debug

release:
	swift build -c release

# Run the CLI tool
run: build
	swift run rt

run-release: release
	swift run -c release rt

# Test targets
test:
	swift test

test-verbose:
	swift test --verbose

# Clean targets
clean:
	swift package clean

clean-all:
	rm -rf .build
	rm -rf .swiftpm

# Package management
resolve:
	swift package resolve

update:
	swift package update

# Show package info
show-deps:
	swift package show-dependencies

describe:
	swift package describe

# Generate Xcode project (for debugging in Xcode)
xcode:
	swift package generate-xcodeproj

# Help
help:
	@echo "tdLBGeometryRushtonTurbineLib Makefile"
	@echo ""
	@echo "Build targets:"
	@echo "  make build       - Build debug configuration (default)"
	@echo "  make debug       - Build debug configuration"
	@echo "  make release     - Build release configuration"
	@echo ""
	@echo "Run targets:"
	@echo "  make run         - Build and run the CLI tool (debug)"
	@echo "  make run-release - Build and run the CLI tool (release)"
	@echo ""
	@echo "Test targets:"
	@echo "  make test        - Run all tests"
	@echo "  make test-verbose - Run tests with verbose output"
	@echo ""
	@echo "Clean targets:"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make clean-all   - Remove all build and cache directories"
	@echo ""
	@echo "Package management:"
	@echo "  make resolve     - Resolve package dependencies"
	@echo "  make update      - Update package dependencies"
	@echo "  make show-deps   - Show dependency tree"
	@echo "  make describe    - Describe package structure"
	@echo ""
	@echo "IDE:"
	@echo "  make xcode       - Generate Xcode project"
