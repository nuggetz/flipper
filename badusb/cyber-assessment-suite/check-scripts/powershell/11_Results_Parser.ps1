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

# 11_Results_Parser.ps1
# Run this with a usb drive named <pentest> inserted or the script will save the results in the \temp folder

$resultsFolder = if (Test-Path "E:\pentest") { "E:\pentest" } else { "C:\temp" }
$checkFiles = Get-ChildItem -Path $resultsFolder -Filter "*.txt" | Sort-Object Name

$statusSummary = @()
$report = @()

foreach ($file in $checkFiles) {
    $content = Get-Content $file.FullName
    $status = "UNKNOWN"
    foreach ($line in $content) {
        if ($line -match "STATUS: OK") {
            $status = "OK"
            break
        } elseif ($line -match "STATUS: WARNING") {
            $status = "WARNING"
            break
        } elseif ($line -match "STATUS: CRITICAL") {
            $status = "CRITICAL"
            break
        }
    }
    $statusSummary += [PSCustomObject]@{
        FileName = $file.Name
        Status   = $status
    }

    $report += "=== {0} ===" -f $file.Name
    $report += $content
    $report += ""
}

# Output sommario
$summaryPath = if (Test-Path 'E:\pentest') { 'E:\pentest\_SUMMARY.txt' } else { 'C:\temp\_SUMMARY.txt' }
$statusSummary | Format-Table -AutoSize | Out-File -FilePath $summaryPath -Encoding UTF8

# Output report completo
$fullReportPath = if (Test-Path 'E:\pentest') { 'E:\pentest\_FULL_REPORT.txt' } else { 'C:\temp\_FULL_REPORT.txt' }
$report | Out-File -FilePath $fullReportPath -Encoding UTF8

Write-Output "Parsing completed. Risults saved in _SUMMARY.txt and _FULL_REPORT.txt."
