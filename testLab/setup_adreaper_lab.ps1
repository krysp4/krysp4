Import-Module ActiveDirectory

$domainInfo = Get-ADDomain
$domainDN = $domainInfo.DistinguishedName
$domainFQDN = $domainInfo.DNSRoot
$domainName = $domainInfo.Name

Write-Host "[*] Starting ADReaper Lab Deployment in $($domainFQDN)..." -ForegroundColor Cyan

# ────────────────────────────────────────────────────────────────────────
# Phase 0: Teardown
# ────────────────────────────────────────────────────────────────────────
Write-Host "`n[*] Phase 0: Cleaning up previous objects..." -ForegroundColor Yellow

$groupsToClean = @("Banca_Comercial", "Inversiones_Corporate", "Riesgos_y_Compliance", "IT_Sistemas_Core", "SWIFT_Operators")
foreach ($g in $groupsToClean) {
    if (Get-ADGroup -Filter "Name -eq '$g'") {
        Remove-ADGroup -Identity $g -Confirm:$false
        Write-Host "  [-] Group removed: $g" -ForegroundColor DarkGray
    }
}

$specialUsers = @("svc_corebanking", "svc_swift_backup", "srv_app_riesgos", "auditor_externo", "admin_pruebas")
foreach ($u in $specialUsers) {
    if (Get-ADUser -Filter "SamAccountName -eq '$u'") {
        Remove-ADUser -Identity $u -Confirm:$false
        Write-Host "  [-] Special user removed: $u" -ForegroundColor DarkGray
    }
}

$generatedUsers = Get-ADUser -Filter "Description -like '*Automatically generated user*'"
if ($generatedUsers) {
    $count = 0
    foreach ($gu in $generatedUsers) {
        Remove-ADUser -Identity $gu.SamAccountName -Confirm:$false
        $count++
    }
    Write-Host "  [-] Removed $count previously generated base users." -ForegroundColor DarkGray
}

# ────────────────────────────────────────────────────────────────────────
# Phase 1: Banking Groups
# ────────────────────────────────────────────────────────────────────────
Write-Host "`n[*] Phase 1: Creating Banking Security Groups..." -ForegroundColor Yellow

$groups = @(
    @{Name="Banca_Comercial"; Desc="Branch agents and commercial managers."},
    @{Name="Inversiones_Corporate"; Desc="Investment banking and corporate accounts."},
    @{Name="Riesgos_y_Compliance"; Desc="Risk auditors and compliance officers."},
    @{Name="IT_Sistemas_Core"; Desc="Core banking platform administrators."},
    @{Name="SWIFT_Operators"; Desc="Authorized SWIFT international transfer operators."}
)

foreach ($g in $groups) {
    try {
        New-ADGroup -Name $g.Name -GroupCategory Security -GroupScope Global -Description $g.Desc -Path $domainDN -ErrorAction Stop
        Write-Host "  [+] Banking group created: $($g.Name)" -ForegroundColor Green
    } catch {
        Write-Host "  [x] Error creating group $($g.Name): $_" -ForegroundColor Red
    }
}

# ────────────────────────────────────────────────────────────────────────
# Phase 2: 120 Bank Employees
# ────────────────────────────────────────────────────────────────────────
Write-Host "`n[*] Phase 2: Creating 120 Bank Employees (Name + 2 Surnames)..." -ForegroundColor Yellow

$generatedCredentials = @()
$nombres = @("Carlos","Maria","Juan","Ana","Luis","Laura","Pedro","Sofia","Jorge","Marta","David","Elena","Miguel","Lucia","Raul")
$apellidos = @("Garcia","Martinez","Lopez","Sanchez","Perez","Gomez","Martin","Ruiz","Hernandez","Diaz","Moreno","Munoz")
$bankWords = @("Finance","Capital","Reserve","Credit","Active","Value")
$specialChars = @("!","@","#")
$weakPasswordsList = @("Bank2024!","Password123!","Welcome2024@","Admin12345#","Qwerty99!")

function Get-StrongPassword {
    $word = Get-Random -InputObject $bankWords
    $num = Get-Random -Minimum 10 -Maximum 99
    $char = Get-Random -InputObject $specialChars
    return "$word$num$char"
}

$weakPasswordCount = 0
for ($i = 1; $i -le 120; $i++) {
    $rName = Get-Random -InputObject $nombres
    $rS1 = Get-Random -InputObject $apellidos
    $rS2 = Get-Random -InputObject $apellidos
    $displayName = "$rName $rS1 $rS2"
    $samAccount = "{0}{1}{2}{3:D3}" -f $rName.Substring(0,1).ToLower(), $rS1.ToLower(), $rS2.Substring(0,1).ToLower(), $i
    $dept = (Get-Random -InputObject $groups).Name
    
    if ($weakPasswordCount -lt 15) {
        $plainPass = Get-Random -InputObject $weakPasswordsList
        $weakPasswordCount++
        $isWeak = $true
    } else {
        $plainPass = Get-StrongPassword
        $isWeak = $false
    }
    
    $SecurePassword = ConvertTo-SecureString $plainPass -AsPlainText -Force
    try {
        New-ADUser -SamAccountName $samAccount -Name $displayName -AccountPassword $SecurePassword -Department $dept -Description "Automatically generated user." -Enabled $true -Path $domainDN -ErrorAction Stop
        Add-ADGroupMember -Identity $dept -Members $samAccount -ErrorAction Stop
        $generatedCredentials += [PSCustomObject]@{Username=$samAccount; Password=$plainPass; Department=$dept; Weak=$isWeak}
    } catch {}
}
Write-Host "  [+] 120 employees created (15 with weak passwords)." -ForegroundColor Green

# ────────────────────────────────────────────────────────────────────────
# Phase 3: Attack Vectors
# ────────────────────────────────────────────────────────────────────────
Write-Host "`n[*] Phase 3: Injecting 5 Critical Attack Vectors..." -ForegroundColor Yellow

$SecureBasePlain = "P@sswordBancaria123!"
$SecureBase = ConvertTo-SecureString $SecureBasePlain -AsPlainText -Force
$vulnerableTargets = @()

try {
    # 1. Kerberoast
    $target1 = "svc_corebanking"
    New-ADUser -SamAccountName $target1 -Name $target1 -AccountPassword $SecureBase -Enabled $true -ErrorAction Stop
    Set-ADUser -Identity $target1 -ServicePrincipalNames @{Add="COREBANKSvc/mainframe.$($domainFQDN):8080"} -Description "Core Banking Service Account (Legacy)" -ErrorAction Stop
    $vulnerableTargets += [PSCustomObject]@{Username=$target1; Password=$SecureBasePlain; Vulnerability="Kerberoast (SPN)"}
    Write-Host "  [+] Vector 1: Kerberoasting ($target1)." -ForegroundColor Red

    # 2. AS-REP Roast
    $target2 = "svc_swift_backup"
    New-ADUser -SamAccountName $target2 -Name $target2 -AccountPassword $SecureBase -Enabled $true -ErrorAction Stop
    Set-ADAccountControl -Identity $target2 -DoesNotRequirePreAuth $true -ErrorAction Stop
    $vulnerableTargets += [PSCustomObject]@{Username=$target2; Password=$SecureBasePlain; Vulnerability="AS-REP Roasting (No PreAuth)"}
    Write-Host "  [+] Vector 2: AS-REP Roasting ($target2)." -ForegroundColor Red

    # 3. Unconstrained Delegation
    $target3 = "srv_app_riesgos"
    New-ADUser -SamAccountName $target3 -Name $target3 -AccountPassword $SecureBase -Enabled $true -ErrorAction Stop
    Set-ADUser -Identity $target3 -TrustedForDelegation $true -ErrorAction Stop
    $vulnerableTargets += [PSCustomObject]@{Username=$target3; Password=$SecureBasePlain; Vulnerability="Unconstrained Delegation"}
    Write-Host "  [+] Vector 3: Unconstrained Delegation ($target3)." -ForegroundColor Red

    # 4. DCSync / ACL Abuse
    $target4 = "auditor_externo"
    New-ADUser -SamAccountName $target4 -Name "Auditor KPMG" -AccountPassword $SecureBase -Enabled $true -ErrorAction Stop
    
    # Direct ACE Grant for DCSync (DS-Replication-Get-Changes and Changes-All)
    $rootACL = Get-Acl "AD:\$domainDN"
    $sid = (Get-ADUser $target4).SID
    $guid1 = "1131f6ad-9c07-11d1-f79f-00c04fc2dcd2" # Get Changes
    $guid2 = "1131f6aa-9c07-11d1-f79f-00c04fc2dcd2" # Get Changes All
    $ace1 = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($sid, "ExtendedRight", "Allow", [guid]$guid1)
    $ace2 = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($sid, "ExtendedRight", "Allow", [guid]$guid2)
    $rootACL.AddAccessRule($ace1)
    $rootACL.AddAccessRule($ace2)
    Set-Acl "AD:\$domainDN" -AclObject $rootACL
    
    $vulnerableTargets += [PSCustomObject]@{Username=$target4; Password=$SecureBasePlain; Vulnerability="DCSync Rights (Direct ACL)"}
    Write-Host "  [+] Vector 4: DCSync Privileges ($target4)." -ForegroundColor Red

    # 5. GPP Password
    $sysvolBase = "C:\Windows\SYSVOL\sysvol"
    $targetFolder = Get-ChildItem -Path $sysvolBase -Directory | Where-Object { Test-Path (Join-Path $_.FullName "Policies") } | Select-Object -First 1
    if (-not $targetFolder) {
        Write-Host "  [x] Error: Could not find Policies folder in $sysvolBase" -ForegroundColor Red
        throw "Policies folder not found"
    }

    $sysvolPath = Join-Path $targetFolder.FullName "Policies"
    $gpoPath = "$sysvolPath\{31B2F340-016D-11D2-945F-00C04FB984F9}_BANCARIO\Machine\Preferences\Groups"
    if (-not (Test-Path $gpoPath)) { New-Item -ItemType Directory -Force -Path $gpoPath | Out-Null }
    
    # We add a null terminator to the password string (\0) before encryption
    # Base64 string below decodes to "Bancaria123!\0" using MS14-025 key
    $verifiedGPP = "J4KVFL8Y9OdrxX2YSUeGkbM+mPOf9fD/oK2A8H9vGgw=" 
    $groupsXmlContent = @"
<?xml version="1.0" encoding="utf-8"?>
<Groups clsid="{3125E937-EB16-4b4c-9934-544FC6D24D26}">
    <Group clsid="{6D4A79E4-529C-4481-ABD0-F5CD7EA8A1F8}" name="Administradores" image="2" changed="2023-01-01 00:00:00" uid="{1A2B3C4D-5E6F-7A8B-9C0D-1E2F3A4B5C6D}">
        <Properties action="U" newName="" description="Local Admin Pass" cpassword="$verifiedGPP" cpassword2="" />
    </Group>
</Groups>
"@
    Set-Content -Path "$gpoPath\Groups.xml" -Value $groupsXmlContent -Encoding UTF8
    Write-Host "  [+] Vector 5: GPP Password injected in $domainFQDN." -ForegroundColor Red
    $vulnerableTargets += [PSCustomObject]@{Username="admin_pruebas"; Password=$SecureBasePlain; Vulnerability="GPP Credential"}

} catch {
    Write-Host "  [x] Error injecting vectors: $_" -ForegroundColor Red
}

Write-Host "`n[====== GENERATED USER & CREDENTIAL REPORT ======]`n" -ForegroundColor Cyan
$vulnerableTargets | Format-Table -AutoSize

Write-Host "`n[====== BANKING LAB READY ======]" -ForegroundColor Cyan
Write-Host "Run these commands in ADReaper to audit the environment:"
Write-Host "1. enum acls            # Detect Vector 4 (DCSync)"
Write-Host "2. attack gpp           # Detect Vector 5 (GPP)"
