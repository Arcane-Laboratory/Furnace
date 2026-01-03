# PowerShell script to send formatted error to Cursor (Windows)
# Cross-platform compatible with send-error-to-cursor.sh

param(
    [string]$ErrorText = ""
)

$ErrorActionPreference = "Continue"

# Read from stdin if no argument provided
if ([string]::IsNullOrEmpty($ErrorText)) {
    $ErrorText = $input | Out-String
}

if ([string]::IsNullOrEmpty($ErrorText)) {
    Write-Host "Error: No error text provided" -ForegroundColor Red
    exit 1
}

# Find Cursor CLI
$cursorCmd = $null
$cursorPaths = @(
    "cursor"
    "cursor.cmd"
    "cursor.exe"
    "$env:LOCALAPPDATA\Programs\cursor\cursor.exe"
    "$env:ProgramFiles\Cursor\cursor.exe"
    "${env:ProgramFiles(x86)}\Cursor\cursor.exe"
)

foreach ($path in $cursorPaths) {
    if (Get-Command $path -ErrorAction SilentlyContinue) {
        $cursorCmd = $path
        break
    }
    if (Test-Path $path) {
        $cursorCmd = $path
        break
    }
}

# Create temp file
$tempDir = $env:TEMP
if (-not $tempDir) {
    $tempDir = $env:TMP
}
if (-not $tempDir) {
    $tempDir = "C:\Temp"
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    }
}

$tempFile = Join-Path $tempDir "godot-error-$(Get-Date -Format 'yyyyMMddHHmmss').txt"

try {
    $ErrorText | Out-File -FilePath $tempFile -Encoding UTF8
    Write-Host "✓ Godot error written to: $tempFile" -ForegroundColor Green
    
    # Try to open in Cursor
    if ($cursorCmd) {
        try {
            & $cursorCmd $tempFile 2>$null
            Write-Host "✓ File opened in Cursor via CLI" -ForegroundColor Green
            exit 0
        } catch {
            Write-Host "  (Cursor CLI available but file open failed)" -ForegroundColor Yellow
        }
    }
    
    # Fallback instructions
    Write-Host "  To view error:" -ForegroundColor Yellow
    Write-Host "    1. Open Cursor" -ForegroundColor Yellow
    Write-Host "    2. File -> Open -> $tempFile" -ForegroundColor Yellow
    if ($cursorCmd) {
        Write-Host "  Or run: $cursorCmd `"$tempFile`"" -ForegroundColor Yellow
    }
    
    # Try clipboard as fallback
    try {
        $ErrorText | Set-Clipboard
        Write-Host "✓ Error also copied to clipboard" -ForegroundColor Green
        Write-Host "  Paste in Cursor to view" -ForegroundColor Yellow
    } catch {
        # Clipboard failed, but we already wrote to file
    }
    
    exit 0
} catch {
    Write-Host "Warning: Could not send error to Cursor. Error text:" -ForegroundColor Red
    Write-Host $ErrorText -ForegroundColor Red
    exit 1
}
