# PowerShell script to parse Godot error formats from log files
# Extracts: file path, line number, error message, error type

param(
    [string]$InputFile = ""
)

$ErrorActionPreference = "Continue"

# Read from stdin if no file provided
$inputSource = if ([string]::IsNullOrEmpty($InputFile)) {
    [Console]::In
} else {
    if (-not (Test-Path $InputFile)) {
        Write-Host "Error: Input file not found: $InputFile" -ForegroundColor Red
        exit 1
    }
    Get-Content $InputFile
}

function Output-Error {
    param(
        [string]$ErrorType,
        [string]$FilePath,
        [string]$LineNum,
        [string]$Message
    )
    
    if ([string]::IsNullOrEmpty($ErrorType)) {
        return
    }
    
    Write-Output "=== Godot $ErrorType ==="
    if (-not [string]::IsNullOrEmpty($FilePath)) {
        Write-Output "File: $FilePath"
    }
    if (-not [string]::IsNullOrEmpty($LineNum)) {
        Write-Output "Line: $LineNum"
    }
    if (-not [string]::IsNullOrEmpty($Message)) {
        Write-Output "Message: $Message"
    }
    Write-Output ""
}

$inStackTrace = $false
$errorType = ""
$filePath = ""
$lineNum = ""
$message = ""

foreach ($line in $inputSource) {
    if ([string]::IsNullOrWhiteSpace($line)) {
        continue
    }
    
    # Detect stack traces
    if ($line -match '^\s*at\s+') {
        $inStackTrace = $true
        # Extract file and line from stack trace
        if ($line -match '\(([^:]+):([0-9]+)\)') {
            $filePath = $matches[1]
            $lineNum = $matches[2]
            # Clean up file path (remove res:// prefix if present)
            $filePath = $filePath -replace '^res://', ''
            $filePath = $filePath -replace '^/', ''
        }
        continue
    }
    
    # Reset stack trace flag on non-stack-trace lines
    if ($line -notmatch '^\s*at\s+') {
        $inStackTrace = $false
    }
    
    # Format 1 & 2: ERROR/WARNING: [message] at [file]:[line]
    if ($line -match '^(ERROR|WARNING):\s+(.+)\s+at\s+([^:]+):([0-9]+)') {
        $errorType = $matches[1]
        $message = $matches[2]
        $filePath = $matches[3]
        $lineNum = $matches[4]
        
        # Clean up file path
        $filePath = $filePath -replace '^res://', ''
        $filePath = $filePath -replace '^/', ''
        
        Output-Error -ErrorType $errorType -FilePath $filePath -LineNum $lineNum -Message $message
        continue
    }
    
    # Format 3: [file]:[line] - ERROR/WARNING: [message]
    if ($line -match '^([^:]+):([0-9]+)\s*-\s*(ERROR|WARNING):\s+(.+)') {
        $filePath = $matches[1]
        $lineNum = $matches[2]
        $errorType = $matches[3]
        $message = $matches[4]
        
        # Clean up file path
        $filePath = $filePath -replace '^res://', ''
        $filePath = $filePath -replace '^/', ''
        
        Output-Error -ErrorType $errorType -FilePath $filePath -LineNum $lineNum -Message $message
        continue
    }
    
    # Format 4: Simple ERROR/WARNING: [message] (may be followed by file:line on next line)
    if ($line -match '^(ERROR|WARNING):\s+(.+)') {
        $errorType = $matches[1]
        $message = $matches[2]
        $filePath = ""
        $lineNum = ""
        
        # Try to read next line for file:line (not implemented in PowerShell streaming, skip for now)
        Output-Error -ErrorType $errorType -FilePath $filePath -LineNum $lineNum -Message $message
        continue
    }
    
    # Format 5: Compilation errors - [file]:[line] - [message]
    if ($line -match '^([^:]+):([0-9]+)\s*-\s*(.+)') {
        $filePath = $matches[1]
        $lineNum = $matches[2]
        $message = $matches[3]
        
        # Only treat as error if it looks like a compilation error
        if ($message -match '(error|Error|ERROR|failed|Failed|FAILED)') {
            $errorType = "ERROR"
            $filePath = $filePath -replace '^res://', ''
            $filePath = $filePath -replace '^/', ''
            Output-Error -ErrorType $errorType -FilePath $filePath -LineNum $lineNum -Message $message
        }
        continue
    }
}
