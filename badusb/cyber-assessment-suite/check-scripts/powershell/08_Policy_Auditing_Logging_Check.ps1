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

  WARNING
  This script is designed to be run locally only.
  Please ensure it is placed in either 'E:\pentest' or 'C:\temp' before executing.
  It will NOT be automatically downloaded by the BadUSB script for security reasons.
#>

# Script: 08_Policy_Auditing_Logging_Check.ps1

# Check Policy, Auditing and Logging Configuration
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

# CHECK 3: Event Forwarding (WECUTIL fallback)
try {
    $wec = wecutil es 2>&1
    if ($wec -match "Subscription") {
        $log += "Event Forwarding: at least one subscription found."
    } else {
        $log += "Event Forwarding: no active subscriptions."
    }
} catch {
    $log += "Event Forwarding check failed or service not available."
}

# Final assessment
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

# Save result
$outputPath = "C:\temp\08_Policy_Auditing_Logging_Check.txt"
$log | Out-File -FilePath $outputPath -Encoding UTF8 -Force

# Console output for debugging
$log | ForEach-Object { Write-Output $_ }
