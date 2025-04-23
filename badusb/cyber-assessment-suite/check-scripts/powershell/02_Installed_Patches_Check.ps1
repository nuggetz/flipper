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

# 02_Installed_Patches_Check.ps1
# Run this with a usb drive named <pentest> inserted or the script will save the results in the \temp folder.

# Retrive installed patch info from WMI
$updates = Get-HotFix | Where-Object { $_.Description -like "*Security*" }

# Output buffer
$results = @()

if ($updates.Count -eq 0) {
    $results += "No security patch installed found. System potentially vulnerable."
    $results += "STATUS: CRITICAL"
} else {
    $results += "Found patches: $($updates.Count)"
    $updates | ForEach-Object {
        $results += " - $($_.HotFixID) installation date: $($_.InstalledOn)"
    }

    # Check for recent updates (last 30 days)
    $recentThreshold = (Get-Date).AddDays(-30)
    $recentUpdates = $updates | Where-Object { $_.InstalledOn -gt $recentThreshold }

    if ($recentUpdates.Count -eq 0) {
        $results += "NOTICE: No recent security patch (last 30 days)."
        $results += "STATUS: WARNING"
    } else {
        $results += "STATUS: OK"
    }
}

# Save results
$outputPath = if (Test-Path 'E:\pentest') { 'E:\pentest\02_Installed_Patches_Check.txt' } else { "C:\temp\02_Installed_Patches_Check.txt" }
$results | Out-File -FilePath $outputPath -Encoding UTF8

# Display Outputs
$results | ForEach-Object { Write-Output $_ }
