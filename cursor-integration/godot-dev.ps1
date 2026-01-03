# PowerShell wrapper script for Godot development with Cursor integration (Windows)
# Watches Godot log files and sends errors to Cursor

param(
    [Parameter(Position=0)]
    [string]$Command = "start"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$FindLogScript = Join-Path $ScriptDir "godot-find-log.ps1"
$WatcherScript = Join-Path $ScriptDir "godot-log-watcher.ps1"
$PidFile = Join-Path $ScriptDir ".godot-watcher.pid"

function Start-Watcher {
    if (Test-Path $PidFile) {
        $oldPid = Get-Content $PidFile
        $process = Get-Process -Id $oldPid -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "Watcher already running (PID: $oldPid)" -ForegroundColor Yellow
            return $false
        } else {
            Remove-Item $PidFile -Force
        }
    }
    
    Write-Host "Starting Godot log watcher..." -ForegroundColor Cyan
    
    # Start watcher in background
    $logFile = Join-Path $ScriptDir ".godot-watcher.log"
    $job = Start-Job -ScriptBlock {
        param($watcherScript, $logFile)
        & $watcherScript *> $logFile
    } -ArgumentList $WatcherScript, $logFile
    
    $job.Id | Out-File -FilePath $PidFile
    
    Start-Sleep -Seconds 1
    
    $job = Get-Job -Id (Get-Content $PidFile) -ErrorAction SilentlyContinue
    if ($job -and $job.State -eq "Running") {
        Write-Host "Watcher started (Job ID: $($job.Id))" -ForegroundColor Green
        try {
            $logPath = & $FindLogScript 2>$null
            Write-Host "Log file: $logPath" -ForegroundColor Cyan
        } catch {
            Write-Host "Log file: Not found" -ForegroundColor Yellow
        }
        return $true
    } else {
        Write-Host "Failed to start watcher" -ForegroundColor Red
        if (Test-Path $logFile) {
            Write-Host "Error details:" -ForegroundColor Red
            Get-Content $logFile | Write-Host
        }
        Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
        return $false
    }
}

function Stop-Watcher {
    if (-not (Test-Path $PidFile)) {
        Write-Host "Watcher not running" -ForegroundColor Yellow
        return $false
    }
    
    $jobId = Get-Content $PidFile
    $job = Get-Job -Id $jobId -ErrorAction SilentlyContinue
    
    if ($job) {
        Stop-Job -Id $jobId -ErrorAction SilentlyContinue
        Remove-Job -Id $jobId -Force -ErrorAction SilentlyContinue
        Write-Host "Watcher stopped" -ForegroundColor Green
    } else {
        Write-Host "Watcher was not running" -ForegroundColor Yellow
    }
    
    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
    return $true
}

function Show-Status {
    if (-not (Test-Path $PidFile)) {
        Write-Host "Watcher not running" -ForegroundColor Yellow
        return $false
    }
    
    $jobId = Get-Content $PidFile
    $job = Get-Job -Id $jobId -ErrorAction SilentlyContinue
    
    if ($job -and $job.State -eq "Running") {
        Write-Host "Watcher is running (Job ID: $jobId)" -ForegroundColor Green
        try {
            $logPath = & $FindLogScript 2>$null
            Write-Host "Log file: $logPath" -ForegroundColor Cyan
        } catch {
            Write-Host "Log file: Not found" -ForegroundColor Yellow
        }
        return $true
    } else {
        Write-Host "Watcher PID file exists but job is not running" -ForegroundColor Red
        Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
        return $false
    }
}

function Show-Log {
    $logFile = Join-Path $ScriptDir ".godot-watcher.log"
    if (Test-Path $logFile) {
        Get-Content $logFile -Tail 50
    } else {
        Write-Host "No watcher log file found" -ForegroundColor Yellow
    }
}

# Main command handling
switch ($Command.ToLower()) {
    "start" {
        if (Start-Watcher) {
            exit 0
        } else {
            exit 1
        }
    }
    "stop" {
        Stop-Watcher
    }
    "restart" {
        Stop-Watcher
        Start-Sleep -Seconds 1
        Start-Watcher
    }
    "status" {
        Show-Status
    }
    "log" {
        Show-Log
    }
    "find-log" {
        & $FindLogScript
    }
    default {
        Write-Host "Usage: .\godot-dev.ps1 {start|stop|restart|status|log|find-log}" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  start     - Start the log watcher (default)"
        Write-Host "  stop      - Stop the log watcher"
        Write-Host "  restart   - Restart the log watcher"
        Write-Host "  status    - Check watcher status"
        Write-Host "  log       - Show watcher log"
        Write-Host "  find-log  - Find and display log file path"
        exit 1
    }
}
