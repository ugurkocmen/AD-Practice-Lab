# Set Primary DNS to point to DC01
$NetAdapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
Set-DnsClientServerAddress -InterfaceIndex $NetAdapter.InterfaceIndex -ServerAddresses "192.168.56.10"

Write-Output "[*] Joining DC02 to mekke.local domain..."
$Password = ConvertTo-SecureString "KankaSifre123!" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential("MEKKE\Administrator", $Password)
Add-Computer -DomainName "mekke.local" -Credential $Credential -Restart -Force

# POST-REBOOT SECURITY HARDENING (AV & FIREWALL BYPASS CHALLENGE)
# 1. Enable Windows Defender Real-Time Protection & AMSI
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableBlockAtFirstSight $false

# 2. Tighten Windows Firewall
New-NetFirewallRule -DisplayName "Block_Kali_Scanning" -Direction Inbound -RemoteAddress 192.168.56.20 -Action Block -Severity Critical
New-NetFirewallRule -DisplayName "Allow_ADCS_Web" -Direction Inbound -RemoteAddress 192.168.56.20 -LocalPort 80,443,88,389 -Protocol TCP -Action Allow

# 3. Internal Exposure Leaks
$TargetDir = "C:\Users\Public\Documents\Shares"
New-Item -ItemType Directory -Force -Path $TargetDir
$ConfigContent = @"
<configuration>
   <appSettings>
      <add key="db_connection" value="Server=192.168.56.11;Database=CustomerData;Uid=MEKKE\ahmet.sizma;Pwd=ZorluSifre123!;" />
   </appSettings>
</configuration>
"@
Out-File -FilePath "$TargetDir\web.config" -InputObject $ConfigContent -Encoding UTF8

# 4. Inject Initial Access Flag
Out-File -FilePath "C:\Users\Public\Documents\Shares\flag_2.txt" -InputObject "FLAG{gp0_l1nk_0v3rwr1t3_f0und}" -Encoding UTF8