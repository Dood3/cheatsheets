__Windows Server 2022__

```
Get-NetIPAddress

New-NetIPAddress -InterfaceIndex 4 -IPAddress 192.168.10.21 -PrefixLength 24 -DefaultGateway 192.168.10.10
Set-DnsClientServerAddress -InterfaceIndex 4 -ServerAddresses ("127.0.0.1")
Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools

Install-ADDSForest -DomainName "dom.com" -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "7" -DomainNetbiosName "DOMCOM" -ForestMode "7" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$True -SysvolPath "C:\Windows\SYSVOL" -Force:$true

Install-ADDSForest -DomainName "bad.com" -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainNetbiosName "BADCOM" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$True -SysvolPath "C:\Windows\SYSVOL" -Force:$true

Add-Computer -DomainName "bad.com" -restart

Get-Service adws,kdc,netlogon,dns
Get-ADDomainController
Get-ADForest bad.com
Get-smbshare SYSVOL
```

__Generate AD-Users__
```
-> Copy the folder onto installed AD machine
-> Edit the `ad_config.json` file and set the parameters
-> Run make_schema.ps1 to generate your AD schema
./make_schema.ps1
-> Run gen_vulnAD.ps1 to create the AD
./gen_vulnAD.ps1 out.json
```
__Install Sub-Domain__
```
Import-Module DNSServer

# Define the subdomain and IP address
$subdomain = "lin.dom.com"
$ipAddress = "192.168.10.20"

# Create a new primary zone for the subdomain
Add-DnsServerPrimaryZone -Name $subdomain -ZoneFile "$subdomain.dns"

# Add an A record to the subdomain zone
Add-DnsServerResourceRecord -ZoneName $subdomain -A -Name "@" -IPv4Address $ipAddress

# Add a TXT record to the subdomain zone
Add-DnsServerResourceRecord -ZoneName $subdomain -TXT -Name "@" -DescriptiveText "txt_entry_for_win"

# Verify the configuration
Get-DnsServerResourceRecord -ZoneName $subdomain -RRType A
Get-DnsServerResourceRecord -ZoneName $subdomain -RRType TXT
```

__Install OpenSSH via PowerShell (Windows 10/11)__
```
# Install OpenSSH 
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*' 
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 

# Start SSH service 
Start-Service sshd Set-Service -Name sshd -StartupType Automatic

# Allow SSH through Firewall 
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

------------------------------------------------------------------------------

OR (if Powershell fails):
dism /online /Add-Capability /CapabilityName:OpenSSH.Server~~~~0.0.1.0
Start-Service sshd 
Set-Service -Name sshd -StartupType Automatic
```
