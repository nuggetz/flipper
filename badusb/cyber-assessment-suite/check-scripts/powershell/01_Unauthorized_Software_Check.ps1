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

# 01_Unauthorized_Software_Check.ps1
# Run this with a usb drive named <pentest> inserted or the script will save the results in the \temp folder.

# Path to blocklist
$blocklistPath = "$PSScriptRoot\blocklist.txt"

# Log buffer init.
$log = @()

if (Test-Path $blocklistPath) {
    $blocklist = Get-Content $blocklistPath | Where-Object { $_ -ne "" }
} else {
    $log += "WARNING: blocklist.txt could not be found."
    $log += "STATUS: WARNING - No check performed for unauthorized software."
    
    # Display output
    $log | ForEach-Object { Write-Output $_ }

    # Write partial log
    $outputPath = if (Test-Path 'E:\pentest') { 'E:\pentest\01_Unauthorized_Software_Check.txt' } else { "C:\temp\01_Unauthorized_Software_Check.txt" }
    $log | Out-File -FilePath $outputPath -Encoding UTF8
    exit
}

# Retrive installed software (32 e 64 bit)
$installedSoftware = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName |
    Where-Object { $_.DisplayName -ne $null }

$installedSoftware += Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName |
    Where-Object { $_.DisplayName -ne $null }

# Analysis
$found = @()
foreach ($entry in $blocklist) {
    $match = $installedSoftware | Where-Object { $_.DisplayName -like "*$entry*" }
    if ($match) {
        foreach ($m in $match) {
            $found += $m.DisplayName
        }
    }
}

# Final output
if ($found.Count -eq 0) {
    $log += "No unauthorized software detected. No issues found."
    $log += "STATUS: OK"
} else {
    $log += "CRITICAL - Unauthorized software detected:"
    $found | ForEach-Object { $log += " - $_" }
    $log += "STATUS: CRITICAL"
}

# Display output
$log | ForEach-Object { Write-Output $_ }

# Save results
$outputPath = if (Test-Path 'E:\pentest') { 'E:\pentest\01_Unauthorized_Software_Check.txt' } else { "C:\temp\01_Unauthorized_Software_Check.txt" }
$log | Out-File -FilePath $outputPath -Encoding UTF8
