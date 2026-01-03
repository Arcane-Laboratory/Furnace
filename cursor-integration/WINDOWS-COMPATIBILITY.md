# Windows Compatibility & Cursor CLI Integration

## Overview

The Godot error watcher system is now fully cross-platform compatible, supporting:
- **Linux** (bash scripts with `inotify-tools`)
- **macOS** (bash scripts with `fswatch` or `inotify-tools` via Homebrew)
- **Windows** (PowerShell scripts or Git Bash)

## Cursor CLI Integration

### Automatic Detection

The system automatically detects and uses Cursor CLI on all platforms:

**Detection Order:**
1. `cursor` command (Linux/macOS)
2. `cursor.exe` (Windows)
3. `cursor.cmd` (Windows)
4. Common installation paths:
   - `%LOCALAPPDATA%\Programs\cursor\cursor.exe`
   - `C:\Program Files\Cursor\cursor.exe`
   - `C:\Program Files (x86)\Cursor\cursor.exe`

### How It Works

When an error is detected:
1. **Primary**: Attempts to open error file directly in Cursor using CLI
   ```bash
   cursor /tmp/godot-error-1234567890.txt
   ```
2. **Fallback**: Creates temporary file and provides instructions
3. **Last Resort**: Copies error to clipboard

## Windows Usage

### Option 1: PowerShell (Recommended)

```powershell
# Start watcher
.\godot-dev.ps1 start

# Check status
.\godot-dev.ps1 status

# Stop watcher
.\godot-dev.ps1 stop
```

### Option 2: Git Bash

If you prefer bash scripts on Windows:

```bash
# Start watcher
./godot-dev.sh start

# Check status
./godot-dev.sh status

# Stop watcher
./godot-dev.sh stop
```

**Note:** Git Bash scripts require WSL or a Linux-like environment for `inotifywait`.

## File Locations

### Windows Log Paths

Godot logs are searched in these locations on Windows:
- `%APPDATA%\Godot\app_userdata\Furnace\logs\`
- `%LOCALAPPDATA%\Godot\app_userdata\Furnace\logs\`
- `%USERPROFILE%\AppData\Roaming\Godot\app_userdata\Furnace\logs\`
- `%USERPROFILE%\AppData\Local\Godot\app_userdata\Furnace\logs\`

### Temporary Error Files

Error files are created in:
- Windows: `%TEMP%\godot-error-*.txt`
- Linux: `/tmp/godot-error-*.txt` or `$XDG_RUNTIME_DIR/godot-error-*.txt`
- macOS: `/tmp/godot-error-*.txt` or `$TMPDIR/godot-error-*.txt`

## VS Code/Cursor Tasks

Tasks are configured to work cross-platform:
- **Windows**: Uses PowerShell automatically
- **Linux/macOS**: Uses bash scripts

Access via: `Ctrl+Shift+P` → "Tasks: Run Task" → Select Godot task

## Troubleshooting

### Cursor CLI Not Found

If Cursor CLI is not detected:
1. Ensure Cursor is installed
2. Add Cursor to your PATH:
   - Windows: Add `C:\Users\<YourUser>\AppData\Local\Programs\cursor` to PATH
   - Linux/macOS: Usually auto-installed, check with `which cursor`

### PowerShell Scripts Not Running

If PowerShell scripts are blocked:
```powershell
# Allow script execution (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### File Watcher Not Working on Windows

**PowerShell version** (recommended):
- Uses native `FileSystemWatcher`
- No additional dependencies required
- Works on PowerShell 5.1+

**Git Bash version**:
- Requires WSL or Linux-like environment
- Needs `inotify-tools` installed

## Script Files

### Bash Scripts (Linux/macOS/Windows Git Bash)
- `godot-dev.sh` - Main wrapper
- `godot-log-watcher.sh` - File watcher
- `godot-find-log.sh` - Log file locator
- `godot-error-parser.sh` - Error parser
- `send-error-to-cursor.sh` - Cursor integration

### PowerShell Scripts (Windows)
- `godot-dev.ps1` - Main wrapper
- `godot-log-watcher.ps1` - File watcher
- `godot-find-log.ps1` - Log file locator
- `godot-error-parser.ps1` - Error parser
- `send-error-to-cursor.ps1` - Cursor integration

Both sets of scripts provide identical functionality, just using platform-appropriate tools.
