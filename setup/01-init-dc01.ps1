Write-Output "[*] Installing AD-DS Role and Management Tools..."
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Write-Output "[*] Creating 'mekke.local' Active Directory Forest..."
$Password = ConvertTo-SecureString "KankaSifre123!" -AsPlainText -Force
Install-ADDSForest -DomainName "mekke.local" `
                   -SafeModeAdministratorPassword $Password `
                   -InstallDns:$true `
                   -Force:$true

# POST-REBOOT AD CONFIGURATION & VULNERABILITY INJECTION
Import-Module ActiveDirectory

# 1. Create Domain Users
$UserPass = ConvertTo-SecureString "ZorluSifre123!" -AsPlainText -Force
New-ADUser -Name "Ahmet Sizma" -SamAccountName "ahmet.sizma" -UserPrincipalName "ahmet.sizma@mekke.local" -AccountPassword $UserPass -Enabled $true
New-ADUser -Name "Mehmet Servis" -SamAccountName "mehmet.servis" -UserPrincipalName "mehmet.servis@mekke.local" -AccountPassword $UserPass -Enabled $true

# 2. Create Target OU and inject Cross-Domain GPO Link Misconfiguration
New-ADOrganizationalUnit -Name "KritikSunucular" -Path "DC=mekke,DC=local"
$OU = [ADSI]"LDAP://OU=KritikSunucular,DC=mekke,DC=local"
$Identity = New-Object System.Security.Principal.NTAccount("MEKKE\ahmet.sizma")
$ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($Identity, "WriteProperty", "Allow", [Guid]"f30e3bc1-4c0e-11d1-b244-0000f875973d")
$OU.ObjectSecurity.AddAccessRule($ACE)
$OU.CommitChanges()

# 3. Honeytoken / Deception LSASS Dump Trap
New-Item -ItemType Directory -Force -Path "C:\Backup"
Out-File -FilePath "C:\Backup\lsass.dmp" -InputObject "DECEPTION_DATA: FAKE_DOM_ADMIN_HASH_HERE (Honeytoken)" -Encoding UTF8

# 4. Inject Final Domain Admin Flag
Out-File -FilePath "C:\Users\Administrator\Desktop\FINAL_FLAG.txt" -InputObject "FLAG{c3rt1py_3sc13_d0m41n_pwn3d}" -Encoding UTF8
