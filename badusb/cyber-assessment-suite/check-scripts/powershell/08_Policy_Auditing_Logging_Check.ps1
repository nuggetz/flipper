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

# 08_Policy_Auditing_Logging_Check.ps1
# Run this with a usb drive named <pentest> inserted or the script will save the results in the \temp folder.

$log = @()
$nonCompliant = 0

# CHECK 1: Audit Policy
$auditPolicy = auditpol /get /category:* | Out-String
$categoriesToCheck = @(
    "Logon/Logoff",
    "Account Logon",
    "Privilege Use",
    "System",
    "Policy Change"
)

foreach ($category in $categoriesToCheck) {
    if ($auditPolicy -match "$category\s+No Auditing") {
        $log += "Category '$category': auditing NOT configured!"
        $nonCompliant++
    } else {
        $log += "Category '$category': auditing is properly configured."
    }
}

# CHECK 2: Security log configuration
$logConfig = wevtutil gl Security
$logSizeLine = ($logConfig | Select-String "maxSize").ToString()
$logRetentionLine = ($logConfig | Select-String "retention").ToString()

$logSizeMB = [int]($logSizeLine -replace "[^\d]", "") / 1024 / 1024
$retention = if ($logRetentionLine -match "true") { "Enabled" } else { "Disabled" }

if ($logSizeMB -lt 20) {
    $log += "Security log configured with insufficient size: ${logSizeMB}MB."
    $nonCompliant++
} else {
    $log += "Security log size is adequate: ${logSizeMB}MB."
}

if ($retention -eq "Disabled") {
    $log += "Log retention is disabled – risk of overwriting!"
    $nonCompliant++
} else {
    $log += "Log retention is enabled."
}

# CHECK 3: Event Forwarding
$subs = Get-WinEvent -ListSubscriptions -ErrorAction SilentlyContinue
if ($subs.Count -gt 0) {
    $log += "Event forwarding is properly configured."
} else {
    $log += "No event forwarding configured (Event Forwarding is not active)."
}

# Final Status
switch ($nonCompliant) {
    0 {
        $log += "All checks are compliant."
        $log += "STATUS: OK"
    }
    1 {
        $log += "WARNING - potential anomaly detected in auditing policy."
        $log += "STATUS: WARNING"
    }
    default {
        $log += "CRITICAL - auditing or log settings are misconfigured."
        $log += "STATUS: CRITICAL"
    }
}

# Ensure output directory exists
if (-not (Test-Path "C:\temp")) {
    New-Item -Path "C:\temp" -ItemType Directory | Out-Null
}

# Output path logic
$outputPath = "C:\temp\08_Policy_Auditing_Logging_Check.txt"
$log | Out-File -FilePath $outputPath -Encoding UTF8

# Optional: output preview
$log | ForEach-Object { Write-Output $_ }
