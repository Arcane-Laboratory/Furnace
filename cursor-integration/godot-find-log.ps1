# PowerShell script to find Godot log file (Windows)
# Extracts project name from project.godot and searches common log locations

$ErrorActionPreference = "Stop"

# Get script directory and search for project.godot
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CurrentDir = Get-Location

$ProjectFile = $null

# Search for project.godot
$SearchPaths = @(
    Join-Path $ScriptDir "project.godot"
    Join-Path $CurrentDir "project.godot"
    Join-Path $CurrentDir "godot\project.godot"
    Join-Path (Split-Path $ScriptDir) "project.godot"
    Join-Path (Split-Path $ScriptDir) "godot\project.godot"
)

foreach ($path in $SearchPaths) {
    if (Test-Path $path) {
        $ProjectFile = $path
        break
    }
}

# Search up directory tree
if (-not $ProjectFile) {
    $searchDir = $CurrentDir
    while ($searchDir -ne (Split-Path $searchDir)) {
        $testPath = Join-Path $searchDir "project.godot"
        if (Test-Path $testPath) {
            $ProjectFile = $testPath
            break
        }
        $testPath = Join-Path $searchDir "godot\project.godot"
        if (Test-Path $testPath) {
            $ProjectFile = $testPath
            break
        }
        $searchDir = Split-Path $searchDir
    }
}

if (-not $ProjectFile -or -not (Test-Path $ProjectFile)) {
    Write-Host "Error: project.godot not found" -ForegroundColor Red
    exit 1
}

# Extract project name
$projectName = $null
$content = Get-Content $ProjectFile
foreach ($line in $content) {
    if ($line -match '^config/name="([^"]+)"') {
        $projectName = $matches[1]
        break
    }
}

if (-not $projectName) {
    Write-Host "Error: Could not extract project name from project.godot" -ForegroundColor Red
    exit 1
}

# Windows log locations
$logLocations = @(
    "$env:APPDATA\Godot\app_userdata\$projectName\logs"
    "$env:LOCALAPPDATA\Godot\app_userdata\$projectName\logs"
    "$env:USERPROFILE\AppData\Roaming\Godot\app_userdata\$projectName\logs"
    "$env:USERPROFILE\AppData\Local\Godot\app_userdata\$projectName\logs"
)

# Find most recent log file
$mostRecentLog = $null
$mostRecentTime = [DateTime]::MinValue

foreach ($location in $logLocations) {
    if (Test-Path $location) {
        $logFiles = Get-ChildItem -Path $location -Recurse -File -Filter "*.log" -ErrorAction SilentlyContinue
        foreach ($file in $logFiles) {
            if ($file.LastWriteTime -gt $mostRecentTime) {
                $mostRecentTime = $file.LastWriteTime
                $mostRecentLog = $file.FullName
            }
        }
    }
}

# Also check for any files matching project name
foreach ($location in $logLocations) {
    if (Test-Path $location) {
        $logFiles = Get-ChildItem -Path $location -Recurse -File -Filter "*$projectName*" -ErrorAction SilentlyContinue
        foreach ($file in $logFiles) {
            if ($file.LastWriteTime -gt $mostRecentTime) {
                $mostRecentTime = $file.LastWriteTime
                $mostRecentLog = $file.FullName
            }
        }
    }
}

if ($mostRecentLog -and (Test-Path $mostRecentLog)) {
    Write-Output $mostRecentLog
    exit 0
} else {
    Write-Host "Error: No log file found for project '$projectName'" -ForegroundColor Red
    Write-Host "Searched locations:" -ForegroundColor Yellow
    foreach ($location in $logLocations) {
        Write-Host "  - $location" -ForegroundColor Yellow
    }
    exit 1
}
