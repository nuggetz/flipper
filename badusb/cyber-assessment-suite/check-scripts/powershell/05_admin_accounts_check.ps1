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

# 05_admin_accounts_check.ps1
# Run this with a usb drive named <pentest> inserted or the script will save the results in the \temp folder.

# log init.
$log = @()
$log += "Checking accounts with administrative privileges..."

# Obtain local Admin members
try {
    $adminGroup = [ADSI]"WinNT://./Administrators,group"
    $members = @()
    $adminGroup.Members() | ForEach-Object {
        $members += $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
    }
}
catch {
    $log += "Error retrieving members of the Administrators group."
    $log += "STATUS: ERROR"
    $outputPath = if (Test-Path 'E:\pentest') { 'E:\pentest\5_admin_accounts.txt' } else { "C:\temp\05_Admin_Accounts_Check.txt" }
    $log | Out-File -FilePath $outputPath -Encoding UTF8
    exit
}

# List of expected users (editable)
$expectedAdmins = @("Administrator", "Admin", "adminuser")

# Analysis
$unexpectedAdmins = @()
foreach ($user in $members) {
    if ($expectedAdmins -notcontains $user) {
        $unexpectedAdmins += $user
    }
}

# Final output
if ($unexpectedAdmins.Count -eq 0) {
    $log += "All Admin accounts are expected."
    $log += "STATUS: OK"
} else {
    $log += "CRITICAL - Unexpected administrative accounts found:"
    $unexpectedAdmins | ForEach-Object { $log += " - $_" }
    $log += "STATUS: CRITICAL"
}

# Stampa log su schermo
$log | ForEach-Object { Write-Output $_ }

# Salvataggio risultato
$outputPath = if (Test-Path 'E:\pentest') { 'E:\pentest\05_admin_accounts_check.txt' } else { "C:\temp\05_admin_accounts_check.txt" }
$log | Out-File -FilePath $outputPath -Encoding UTF8
