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

# 07_local_protections_check.ps1
# Run this with a usb drive named <pentest> inserted or the script will save the results in the \temp folder.

$nonCompliant = 0
$log = @()

### CHECK 1: BitLocker
$bitlockerStatus = Get-BitLockerVolume -MountPoint "C:" | Select-Object -ExpandProperty ProtectionStatus
if ($bitlockerStatus -eq 1) {
    $log += "BitLocker is enabled on volume C:."
} else {
    $log += "Volume C: is NOT protected by BitLocker."
    $nonCompliant++
}

### CHECK 2: Antivirus status
$antivirus = Get-CimInstance -Namespace "root/SecurityCenter2" -ClassName "AntivirusProduct"
if ($antivirus) {
    foreach ($av in $antivirus) {
        $productState = $av.productState
        $avName = $av.displayName

        # Decode productState
        $hex = "{0:X}" -f $productState
        $statusByte = [convert]::ToInt32($hex.Substring(0,1), 16)
        $definitionByte = [convert]::ToInt32($hex.Substring(1,2), 16)
        $serviceByte = [convert]::ToInt32($hex.Substring(3,2), 16)

        # Status translation
        $status = switch ($statusByte) {
            0 { "Disabled" }
            1 { "Unknown" }
            4 { "Enabled" }
            6 { "Active" }
            default { "Unknown state ($statusByte)" }
        }
        $definitions = if ($definitionByte -ge 16) { "Up to date" } else { "Outdated" }
        $service = if ($serviceByte -eq 0) { "Running" } else { "Service not active" }

        $log += "Antivirus: $avName - Status: $status, $definitions, $service"

        if ($status -ne "Active" -or $definitions -ne "Up to date" -or $service -ne "Running") {
            $nonCompliant++
        }
    }
} else {
    $log += "No antivirus detected!"
    $nonCompliant++
}

### CHECK 3: UAC (User Account Control)
$uacValue = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA
if ($uacValue.EnableLUA -eq 1) {
    $log += "UAC is properly enabled."
} else {
    $log += "UAC is disabled!"
    $nonCompliant++
}

### Final STATUS
switch ($nonCompliant) {
    0 {
        $log += "All checks are compliant."
        $log += "STATUS: OK"
    }
    1 {
        $log += "WARNING - potential anomaly detected."
        $log += "STATUS: WARNING"
    }
    default {
        $log += "CRITICAL - two or more local protections are non-compliant."
        $log += "STATUS: CRITICAL"
    }
}

# Save result
$outputPath = if (Test-Path 'E:\pentest') { 'E:\pentest\07_local_protections_check.txt' } else { "C:\temp\07_local_protections_check.txt" }
$log | Out-File -FilePath $outputPath -Encoding UTF8

# Display output to screen (optional)
$log | ForEach-Object { Write-Output $_ }
