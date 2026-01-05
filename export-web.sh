#!/bin/bash

# Godot Web Export Script for itch.io
# Exports the Godot game for HTML5 deployment

set -e  # Exit on error

# Configuration
EXPORT_PRESET_NAME="blast-deck-web-1.0"
EXPORT_PATH="web/public/game/index.html"
PROJECT_PATH="godot/project.godot"
EXPORT_DIR="web/public/game"
EXPORT_PRESETS_FILE="godot/export_presets.cfg"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions for colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Find Godot executable
find_godot() {
    local godot_path=""
    
    # Check GODOT_PATH environment variable first
    if [ -n "$GODOT_PATH" ]; then
        if [ -f "$GODOT_PATH" ] && [ -x "$GODOT_PATH" ]; then
            godot_path="$GODOT_PATH"
            print_info "Found Godot at GODOT_PATH: $godot_path" >&2
        else
            print_warn "GODOT_PATH is set but file is not executable: $GODOT_PATH" >&2
        fi
    fi
    
    # Check common installation paths
    if [ -z "$godot_path" ]; then
        local common_paths=(
            "/usr/bin/godot"
            "/usr/local/bin/godot"
            "/opt/godot/godot"
            "$HOME/.local/bin/godot"
            "$HOME/Applications/Godot.app/Contents/MacOS/Godot"  # macOS
            "/Applications/Godot.app/Contents/MacOS/Godot"  # macOS system
        )
        
        for path in "${common_paths[@]}"; do
            if [ -f "$path" ] && [ -x "$path" ]; then
                godot_path="$path"
                print_info "Found Godot at: $godot_path" >&2
                break
            fi
        done
    fi
    
    # Try to find godot in PATH
    if [ -z "$godot_path" ]; then
        if command -v godot &> /dev/null; then
            godot_path="godot"
            print_info "Found Godot in PATH: $godot_path" >&2
        fi
    fi
    
    if [ -z "$godot_path" ]; then
        print_error "Could not find Godot executable." >&2
        print_error "Please install Godot or set GODOT_PATH environment variable." >&2
        print_error "Example: export GODOT_PATH=/path/to/godot" >&2
        exit 1
    fi
    
    echo "$godot_path"
}

# Validate export preset exists
validate_preset() {
    print_info "Validating export preset: $EXPORT_PRESET_NAME"
    
    if [ ! -f "$EXPORT_PRESETS_FILE" ]; then
        print_error "Export presets file not found: $EXPORT_PRESETS_FILE"
        exit 1
    fi
    
    if ! grep -q "name=\"$EXPORT_PRESET_NAME\"" "$EXPORT_PRESETS_FILE"; then
        print_error "Export preset '$EXPORT_PRESET_NAME' not found in $EXPORT_PRESETS_FILE"
        exit 1
    fi
    
    print_success "Export preset validated"
}

# Clean and create export directory
clean_export_dir() {
    print_info "Preparing export directory: $EXPORT_DIR"
    
    if [ -d "$EXPORT_DIR" ]; then
        print_info "Cleaning existing export directory..."
        rm -rf "$EXPORT_DIR"/*
    else
        print_info "Creating export directory..."
        mkdir -p "$EXPORT_DIR"
    fi
    
    print_success "Export directory ready"
}

# Export the game
export_game() {
    local godot_executable="$1"
    
    print_info "Starting Godot export..."
    print_info "Preset: $EXPORT_PRESET_NAME"
    print_info "Output: $EXPORT_PATH"
    print_info "Project: $PROJECT_PATH"
    
    # Change to godot directory for relative path resolution
    cd godot
    
    # Run Godot export command
    if "$godot_executable" --headless --export-release "$EXPORT_PRESET_NAME" "../$EXPORT_PATH"; then
        print_success "Export completed successfully"
    else
        print_error "Export failed"
        cd ..
        exit 1
    fi
    
    cd ..
}

# Validate export files
validate_export() {
    print_info "Validating exported files..."
    
    local required_files=("index.html")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$EXPORT_DIR/$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        print_error "Missing required files: ${missing_files[*]}"
        exit 1
    fi
    
    print_success "All required files present"
    
    # List exported files
    print_info "Exported files:"
    ls -lh "$EXPORT_DIR" | tail -n +2 | awk '{print "  " $9 " (" $5 ")"}'
    
    # Count files
    local file_count=$(find "$EXPORT_DIR" -type f | wc -l)
    print_info "Total files exported: $file_count"
}

# Create zip file for itch.io upload
create_itch_zip() {
    print_info "Creating zip file for itch.io upload..."
    
    local zip_name="furnace-web-export.zip"
    local zip_path="$zip_name"
    
    # Remove existing zip if it exists
    if [ -f "$zip_path" ]; then
        rm "$zip_path"
    fi
    
    # Create zip from export directory contents
    # Use absolute path to ensure zip is created in project root
    local current_dir=$(pwd)
    cd "$EXPORT_DIR"
    if zip -r "$current_dir/$zip_path" . > /dev/null 2>&1; then
        cd "$current_dir"
        if [ -f "$zip_path" ]; then
            local zip_size=$(du -h "$zip_path" | cut -f1)
            print_success "Zip file created: $zip_path ($zip_size)"
            print_info "You can upload this zip file directly to itch.io"
        else
            cd "$current_dir"
            print_error "Failed to create zip file"
            exit 1
        fi
    else
        cd "$current_dir"
        print_error "Failed to create zip file (zip command failed)"
        exit 1
    fi
}

# Check debug mode is disabled
check_debug_mode() {
    print_info "Checking debug mode status..."
    
    local config_file="godot/scripts/autoload/game_config.gd"
    
    if [ ! -f "$config_file" ]; then
        print_error "Game config file not found: $config_file"
        exit 1
    fi
    
    # Check if debug_mode is set to true
    if grep -q "var debug_mode: bool = true" "$config_file"; then
        print_error "Debug mode is enabled in $config_file"
        print_error "Cannot export with debug_mode = true"
        print_error "Please set debug_mode = false before exporting"
        exit 1
    fi
    
    print_success "Debug mode is disabled"
}

# Main execution
main() {
    print_info "=== Godot Web Export Script ==="
    print_info "Exporting for itch.io HTML5 deployment"
    echo ""
    
    # Check debug mode is disabled
    check_debug_mode
    echo ""
    
    # Find Godot executable
    GODOT_EXECUTABLE=$(find_godot)
    print_success "Using Godot: $GODOT_EXECUTABLE"
    echo ""
    
    # Validate preset
    validate_preset
    echo ""
    
    # Clean export directory
    clean_export_dir
    echo ""
    
    # Export game
    export_game "$GODOT_EXECUTABLE"
    echo ""
    
    # Validate export
    validate_export
    echo ""
    
    # Create zip file automatically
    create_itch_zip
    echo ""
    
    # Final instructions
    print_success "=== Export Complete ==="
    print_info "Export location: $EXPORT_DIR"
    print_info "Zip file: furnace-web-export.zip"
    print_info ""
    print_info "To upload to itch.io:"
    print_info "  1. Go to your itch.io project page"
    print_info "  2. Navigate to 'Edit project' > 'Uploads'"
    print_info "  3. Upload 'furnace-web-export.zip' or the directory '$EXPORT_DIR'"
    print_info "  4. Set the main file to 'index.html'"
    print_info "  5. Save and publish"
}

# Run main function
main
