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

# 03_legacy_services_check.ps1
# Run this with a usb drive named <pentest> inserted or the script will save the results in the \temp folder.

# Log init.
$log = @()

# Checklist
$legacyServices = @(
    "Telnet",
    "SNMP",
    "RemoteRegistry",
    "Fax",
    "XblGameSave",
    "WMPNetworkSvc",
    "TermService",       # RDP
    "IKEEXT",            # IPsec (potentially legacy in some cases)
    "SharedAccess",      # ICS
    "WinHttpAutoProxySvc"
)

$log += "Checking for legacy or obsolete services..."
$found = @()

foreach ($service in $legacyServices) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') {
        $found += "$($svc.Name) - Status: $($svc.Status)"
    }
}

# Final output
if ($found.Count -eq 0) {
    $log += "All legacy services are disabled or not active."
    $log += "STATUS: OK"
} else {
    $log += "CRITICAL - Legacy services detected:"
    $found | ForEach-Object { $log += " - $_" }
    $log += "STATUS: CRITICAL"
}

# Display
$log | ForEach-Object { Write-Output $_ }

# Save Result
$outputPath = if (Test-Path 'E:\pentest') { 'E:\pentest\03_legacy_services.txt' } else { "C:\temp\03_legacy_services.txt" }
$log | Out-File -FilePath $outputPath -Encoding UTF8
