![License](https://img.shields.io/github/license/nuggetz/flipper)
![Last Commit](https://img.shields.io/github/last-commit/nuggetz/flipper)
![Platform](https://img.shields.io/badge/platform-PowerShell-blue?style=flat-square)
# Cybersecurity Assessment Suite (CAS) for Flipper Zero

## 📌 Overview

The **Cybersecurity Assessment Suite (CAS)** is a collection of **BadUSB scripts** designed to be deployed via **Flipper Zero** on Windows systems, providing a fast and automated **security configuration assessment**.

The project was developed with research and auditing purposes in mind and helps identify misconfigurations, unauthorized software, and deviations from best security practices based on widely recognized guidelines such as:

- ✅ CIS Benchmarks  
- ✅ Microsoft Security Baselines  
- ✅ NSA / DISA STIG  
- ✅ NIST SP 800-53  
- ✅ ISO/IEC 27001  
- ✅ ANSSI recommendations  
- ✅ OWASP Secure Configuration

> ⚠️ The suite performs **read-only checks** and does **not apply any changes** to the target system.

## 🔧 Features

- Designed for **Windows 10 and 11** environments.
- Modular script structure, each script checks a specific area.
- Read-only data collection with clear status and local logging.

## ⚠️ Keyboard Layout Notice
The BadUSB scripts are written for the **US keyboard layout**. 

If you're using a different layout (e.g., IT, DE, FR), please:

- Adjust the `ALT` key sequence used to confirm UAC prompts.
- For example: `ALT+Y` on US may be `ALT+S` on Italian.

I **strongly recommend** users familiar with scripting to adapt the layout section themselves.
Each DuckyScript includes a reminder comment.

## 🧪 Included Assessment Checks

| ID  | Script Name                      | Description |
|-----|----------------------------------|-------------|
| 01  | Unauthorized Software Check      | Verifies installed programs against a trusted allowlist |
| 02  | Legacy Services Status           | Detects presence and status of legacy or insecure services like Telnet, SMBv1, RDP |
| 03  | Network Shares Status            | Lists active network shares and checks for potentially insecure configurations |
| 04  | Policy Auditing & Logging        | Audit policy, security log size, event forwarding |
| 05  | Account & Privilege Check        | Evaluates user accounts, admin groups, and built-ins |
| 06  | Firewall & Defender Status       | Active firewall profiles, Defender protections |
| 07  | Local Protection Controls        | BitLocker, UAC, Windows Defender AV status |
| 08  | Policy Auditing & Logging        | Audit policy, security log size, event forwarding (must be executed manually) |
| 09  | Remote Services Exposure         | Detects active services like RDP, SSH, VNC, WinRM |
| 10  | Persistence Mechanisms           | Run keys, startup folders, scheduled tasks |

## 📚 Security Standards Reference

The design of each check script follows industry-standard security hardening guidelines, including:

- **[CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)**  
- **[Microsoft Security Baselines](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-security-baselines)**  
- **[DISA STIG](https://public.cyber.mil/stigs/)** and **NSA Guidelines**  
- **[NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)**  
- **[ISO/IEC 27001:2022](https://www.iso.org/isoiec-27001-information-security.html)**  
- **[OWASP Secure Configuration](https://owasp.org/www-project-top-ten/)**  
- **[ANSSI Configuration Guides](https://www.ssi.gouv.fr/)**

Each check attempts to strike a balance between strict security compliance and operational realism for corporate endpoints.

## ⚠️ Legal Disclaimer

> **This project is intended for educational, research, and authorized auditing purposes only.**
>
> The author **disclaims any liability** for misuse, damages, or illegal actions carried out using this code.
>
> Running these scripts on systems **you do not own or manage without explicit permission** may be a **violation of local or international laws**.  
>
> Use this suite only in controlled environments (lab, red teaming, pentests, internal audits) and always with **prior written authorization**.

## 🧠 Technical Notes

- PowerShell scripts are designed to be **non-invasive**, fast, and compatible with typical enterprise configurations.
- BadUSB scripts simulate keystrokes to launch the corresponding PowerShell scripts from a local USB drive.
- Output logs are saved in `E:\pentest\` if available, or fallback to `C:\temp\`.
