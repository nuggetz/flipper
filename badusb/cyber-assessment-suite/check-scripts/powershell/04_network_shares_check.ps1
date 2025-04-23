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

# 04_network_shares_check.ps1
# Run this with a usb drive named <pentest> inserted or the script will save the results in the \temp folder.

# log init.
$log = @()
$log += "Auditing network shares..."

# Checklist
$shares = Get-WmiObject -Class Win32_Share

# LIST OF SUSPECT SHARES (TO CUSTOMIZE)
$suspiciousShares = @()
$defaultAdminShares = "C$", "ADMIN$", "IPC$"

foreach ($share in $shares) {
    if ($defaultAdminShares -notcontains $share.Name) {
        if ($share.Type -eq 0) {  # Disk Drive
            $suspiciousShares += "$($share.Name) - $($share.Path)"
        }
    }
}

# Final output
if ($suspiciousShares.Count -eq 0) {
    $log += "No shares found."
    $log += "STATUS: OK"
} else {
    $log += "WARNING - Non-standard network shares detected:"
    $suspiciousShares | ForEach-Object { $log += " - $_" }
    $log += "STATUS: WARNING"
}

# Display
$log | ForEach-Object { Write-Output $_ }

# Save result
$outputPath = if (Test-Path 'E:\pentest') { 'E:\pentest\04_network_shares.txt' } else { "C:\temp\04_network_shares.txt" }
$log | Out-File -FilePath $outputPath -Encoding UTF8
