# Quick Start Guide - Godot Error Watcher

## Quick Commands

### Linux/macOS (Bash)

```bash
# Start the watcher (runs in background)
./godot-dev.sh start

# Check if watcher is running
./godot-dev.sh status

# Stop the watcher
./godot-dev.sh stop

# View watcher output
./godot-dev.sh log

# Find the current log file
./godot-dev.sh find-log
```

### Windows (PowerShell)

```powershell
# Start the watcher (runs in background)
.\godot-dev.ps1 start

# Check if watcher is running
.\godot-dev.ps1 status

# Stop the watcher
.\godot-dev.ps1 stop

# View watcher output
.\godot-dev.ps1 log

# Find the current log file
.\godot-dev.ps1 find-log
```

**Note:** On Windows, you can also use Git Bash to run the `.sh` scripts.

## Using with Cursor/VS Code

### Via Tasks (Recommended)

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type "Tasks: Run Task"
3. Select one of the Godot watcher tasks:
   - **Godot: Start Error Watcher** - Start monitoring
   - **Godot: Stop Error Watcher** - Stop monitoring
   - **Godot: Restart Error Watcher** - Restart the watcher
   - **Godot: Check Watcher Status** - See if it's running
   - **Godot: View Watcher Log** - View watcher output
   - **Godot: Find Log File** - Locate the log file

### Via Terminal

**Linux/macOS:**
```bash
cd cursor-integration
./godot-dev.sh start
```

**Windows (PowerShell):**
```powershell
cd cursor-integration
.\godot-dev.ps1 start
```

**Windows (Git Bash):**
```bash
cd cursor-integration
./godot-dev.sh start
```

## Workflow

1. **Start the watcher** before running Godot
2. **Run your Godot project** normally
3. **Errors will automatically appear** in Cursor via temporary files or clipboard
4. **Stop the watcher** when done (or it will auto-stop on git commit)

## Auto-Stop on Commit

The watcher automatically stops when you commit changes (via git pre-commit hook).

## Troubleshooting

- **Watcher won't start**: Check if `inotify-tools` is installed (`sudo pacman -S inotify-tools`)
- **No errors appearing**: Make sure Godot has been run at least once to create log files
- **Log file not found**: Run `./godot-dev.sh find-log` to locate it manually

For more details, see `README-GODOT-CURSOR.md`.
