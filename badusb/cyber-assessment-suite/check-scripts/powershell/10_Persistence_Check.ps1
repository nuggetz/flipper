<#
  Cyber Assessment Suite - PowerShell Scripts
  Version: 1.0
  Author: nuggetz (github.com/nuggetz)
  Year: 2025

  Description:
  PowerShell scripts for automated security auditing of Windows 10/11 systems.
  Developed to be used with Flipper Zero BadUSB payloads.

  Frameworks and Guidelines:
  CIS Benchmarks, Microsoft Security Baselines, NSA STIG, NIST 800-53, ISO 27001, OWASP, ANSSI.

  License:
  For educational and ethical testing use only. Any misuse is the sole responsibility of the user.

  Project Repository and guides:
  https://github.com/nuggetz/flipper
#>

# 10_Persistence_Check.ps1
# Run this with a usb drive named <pentest> inserted or the script will save the results in the \temp folder.

# Paths for trusted list
$trustedListPath = "$PSScriptRoot\trustedlist.txt"

# Load trusted list
$trustedList = @()
if (Test-Path $trustedListPath) {
    $trustedList = Get-Content $trustedListPath | Where-Object { $_.Trim() -ne "" }
} else {
    Write-Output "WARNING: trustedlist.txt not found. No filtering will be applied."
}

# Function to determine if an entry is trusted
function Is-Trusted {
    param ($value)
    foreach ($entry in $trustedList) {
        if ($value -like "*$entry*") {
            return $true
        }
    }
    return $false
}

$log = @()
$nonCompliant = 0

$log += "=== Registry: Run / RunOnce ==="
$runKeys = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($key in $runKeys) {
    try {
        $entries = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
        if ($entries) {
            $log += "Key contents: $key"
            foreach ($prop in $entries.PSObject.Properties) {
                if ($prop.Name -notlike "PS*" -and $prop.Value) {
                    if (-not (Is-Trusted $prop.Value)) {
                        $log += " - $($prop.Name): $($prop.Value)"
                        $nonCompliant++
                    }
                }
            }
        }
    } catch {}
}

$log += "`n=== Startup Folders ==="
$startupPaths = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
)

foreach ($path in $startupPaths) {
    if (Test-Path $path) {
        $files = Get-ChildItem -Path $path -Filter *.lnk -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            if (-not (Is-Trusted $file.Name)) {
                $log += " - $($file.Name)"
                $nonCompliant++
            }
        }
    }
}

$log += "`n=== Scheduled Tasks ==="
$tasks = schtasks /query /fo LIST /v 2>$null
$currentTask = ""
$inUntrusted = $false

foreach ($line in $tasks) {
    if ($line -like "TaskName:*") {
        $currentTask = $line
        $inUntrusted = $true
    }
    if ($line -like "Task To Run:*") {
        $value = $line.Split(":")[1].Trim()
        if (Is-Trusted $value) {
            $inUntrusted = $false
        }
    }
    if ($line -eq "") {
        if ($inUntrusted) {
            $log += $currentTask
            $nonCompliant++
        }
        $currentTask = ""
        $inUntrusted = $false
    }
}

# Final status
$log += "`n"
if ($nonCompliant -eq 0) {
    $log += "STATUS: OK - No anomalous persistence mechanisms detected."
} elseif ($nonCompliant -lt 3) {
    $log += "STATUS: WARNING - Possible anomaly in persistence mechanisms ($nonCompliant detected)."
} else {
    $log += "STATUS: CRITICAL - Multiple persistence mechanisms detected ($nonCompliant found)."
}

# Output file
$outputPath = if (Test-Path 'E:\pentest') { 'E:\pentest\10_persistence_check.txt' } else { "C:\temp\10_persistence_check.txt" }
$log | Out-File -FilePath $outputPath -Encoding UTF8
