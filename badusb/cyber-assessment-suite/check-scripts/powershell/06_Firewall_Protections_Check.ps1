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

# 06_firewall_protections_check.ps1
# Run this with a usb drive named <pentest> inserted or the script will save the results in the \temp folder.

# log Init
$log = @()
$log += "Checking firewall and local protections status…"

# Checking firewall status for all profiles
$fwOK = $true
try {
    $profiles = @("Domain", "Private", "Public")
    foreach ($profile in $profiles) {
        $status = (Get-NetFirewallProfile -Profile $profile).Enabled
        if (-not $status) {
            $log += "CRITICAL - Firewall disabled for profile: $profile"
            $fwOK = $false
        }
    }
}
catch {
    $log += "Error retrieving firewall status."
    $fwOK = $false
}

# Windows Defender status check
$defenderOK = $true
try {
    $defenderStatus = Get-MpComputerStatus
    if (-not $defenderStatus.AntispywareEnabled -or -not $defenderStatus.RealTimeProtectionEnabled) {
        $log += "CRITICAL - Windows Defender not completely active."
        $defenderOK = $false
    }
}
catch {
    $log += "Error during Windows Defender check."
    $defenderOK = $false
}

# Final validation
if ($fwOK -and $defenderOK) {
    $log += "Firewall and local protections are active and working properly."
    $log += "STATUS: OK"
}
elseif (-not $fwOK -or -not $defenderOK) {
    $log += "STATUS: CRITICAL"
}
else {
    $log += "STATUS: WARNING"
}

# Output and save
$log | ForEach-Object { Write-Output $_ }

$outputPath = if (Test-Path 'E:\pentest') { 'E:\pentest\06_firewall_protections_check.txt' } else { "C:\temp\06_firewall_protections_check.txt" }
$log | Out-File -FilePath $outputPath -Encoding UTF8
