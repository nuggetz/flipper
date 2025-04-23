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

# 09_Remote_Services_Check.ps1
# Run this with a usb drive named <pentest> inserted or the script will save the results in the \temp folder.

$log = @()
$nonCompliant = 0

# Remote services to check
$remoteServices = @(
    @{ Name = "RDP";        Port = 3389;  Service = "TermService" },
    @{ Name = "SSH";        Port = 22;    Service = "sshd" },
    @{ Name = "Telnet";     Port = 23;    Service = "TlntSvr" },
    @{ Name = "WinRM";      Port = 5985;  Service = "WinRM" },
    @{ Name = "VNC";        Port = 5900;  Service = "uvnc_service" },
    @{ Name = "TeamViewer"; Port = $null; Service = "TeamViewer" }
)

foreach ($entry in $remoteServices) {
    $service = Get-Service -Name $entry.Service -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq 'Running') {
        $log += "Active service detected: $($entry.Name) - Windows Service: $($entry.Service)"
        $nonCompliant++
    }
    elseif ($entry.Port) {
        $netstat = netstat -ano | Select-String ":$($entry.Port)\s+.*LISTENING"
        if ($netstat) {
            $log += "Open and listening port found for $($entry.Name): TCP $($entry.Port)"
            $nonCompliant++
        }
    }
}

if ($nonCompliant -eq 0) {
    $log += "No potentially dangerous remote services detected."
    $log += "STATUS: OK"
} elseif ($nonCompliant -eq 1) {
    $log += "STATUS: WARNING - Possible anomaly"
} else {
    $log += "STATUS: CRITICAL - Multiple remote services active"
}

# Save results
$outputPath = if (Test-Path 'E:\pentest') { 'E:\pentest\09_Remote_Services_Check.txt' } else { "C:\temp\09_Remote_Services_Check.txt" }
$log | Out-File -FilePath $outputPath -Encoding UTF8

# Display output
$log | ForEach-Object { Write-Output $_ }
