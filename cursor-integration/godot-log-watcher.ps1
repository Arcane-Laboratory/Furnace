# PowerShell script for Windows - Watch Godot log file for errors
# Requires PowerShell 5.1+ or PowerShell Core

param(
    [string]$LogFile = ""
)

$ErrorActionPreference = "Stop"

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$FindLogScript = Join-Path $ScriptDir "godot-find-log.ps1"
$ErrorParser = Join-Path $ScriptDir "godot-error-parser.ps1"
$CursorSender = Join-Path $ScriptDir "send-error-to-cursor.ps1"

# Find log file if not provided
if ([string]::IsNullOrEmpty($LogFile)) {
    if (Test-Path $FindLogScript) {
        $LogFile = & $FindLogScript
    } else {
        Write-Host "Error: Log file not specified and find-log script not found" -ForegroundColor Red
        exit 1
    }
}

if (-not (Test-Path $LogFile)) {
    Write-Host "Log file not found: $LogFile" -ForegroundColor Yellow
    Write-Host "Waiting for Godot to create it..." -ForegroundColor Yellow
    Write-Host "Start Godot to create the log file, or specify a log file path." -ForegroundColor Yellow
    
    # Wait for log file to be created
    while (-not (Test-Path $LogFile)) {
        Start-Sleep -Seconds 2
        if (Test-Path $FindLogScript) {
            $LogFile = & $FindLogScript
        }
    }
    Write-Host "Found log file: $LogFile" -ForegroundColor Green
}

Write-Host "Watching log file: $LogFile" -ForegroundColor Cyan

# Track last position
$LastPos = 0
if (Test-Path $LogFile) {
    $LastPos = (Get-Item $LogFile).Length
}

# Function to process new lines
function Process-NewLines {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        return
    }
    
    $currentSize = (Get-Item $FilePath).Length
    
    if ($currentSize -lt $LastPos) {
        # File was rotated or truncated
        $script:LastPos = 0
    }
    
    if ($currentSize -gt $script:LastPos) {
        # Read new content
        $stream = [System.IO.File]::OpenRead($FilePath)
        $stream.Position = $script:LastPos
        $reader = New-Object System.IO.StreamReader($stream)
        $newContent = $reader.ReadToEnd()
        $reader.Close()
        $stream.Close()
        
        if ($newContent) {
            # Parse errors from new content
            $errors = $newContent | & $ErrorParser
            foreach ($error in $errors) {
                if ($error) {
                    $error | & $CursorSender
                }
            }
        }
        
        $script:LastPos = $currentSize
    }
}

# Create FileSystemWatcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = Split-Path -Parent $LogFile
$watcher.Filter = Split-Path -Leaf $LogFile
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::Size
$watcher.EnableRaisingEvents = $true

# Register event handler
$action = {
    $filePath = $Event.SourceEventArgs.FullPath
    Process-NewLines -FilePath $filePath
}

Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action $action | Out-Null

Write-Host "Watcher started. Press Ctrl+C to stop." -ForegroundColor Green

# Process initial content
Process-NewLines -FilePath $LogFile

# Keep script running
try {
    while ($true) {
        Start-Sleep -Seconds 1
        # Also check periodically in case events are missed
        Process-NewLines -FilePath $LogFile
    }
} finally {
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Write-Host "Watcher stopped." -ForegroundColor Yellow
}
