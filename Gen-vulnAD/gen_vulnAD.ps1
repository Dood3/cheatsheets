param(
    [Parameter(Mandatory=$true)] $Jsonfile,
    [switch]$Revert
    )


function CreateADGroup() {
    param([Parameter(Mandatory=$true)] $groupObject)

    $groups = $groupObject.split(" ")
    foreach ($group in $groups) {
        New-ADGroup -name $group -GroupScope Global
    }
}

function RemoveADGroup(){
    param([Parameter(Mandatory=$true)] $groupObject)

    $groups = $groupObject.split(" ")
    foreach ($group in $groups) {
        Remove-ADGroup -Identity $group -Confirm:$false
    }
}
function CreateADUser(){
    param([Parameter(Mandatory=$true)] $userObject)

    # Pull required info from config file
    $name = $userObject.name
    $password = $userObject.password

    # Carve out a first initial, last name structure for username
    $firstname, $lastname = $name.Split(" ")
    $username = ($firstname[0] + $lastname).ToLower()
    $samAccountName = $username
    $principalname = $username

    # Create the AD user
    Write-Host "Creating $username User..."
    New-ADUser -Name "$name" -GivenName $firstname -Surname $lastname -SamAccountName $SamAccountName -UserPrincipalName $principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount

    # Add the user to an appropriate group
    foreach ($group_name in $userObject.groups) {
        try {
            Get-ADGroup -Identity "$group_name"
            Add-ADGroupMember -Identity $group_name -Members $username
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            Write-Warning “WARNING! AD Group $group_name not found while creating user $name”
        }
    }
    
}

function RemoveADUser(){
    param([Parameter(Mandatory=$true)] $userObject)

    $name = $userObject.name
    $firstname, $lastname = $name.Split(" ")
    $username = ($firstname[0] + $lastname).ToLower()
    $samAccountName = $username

    Remove-ADUser -Identity $samAccountName -Confirm:$false
}

function NerfPasswordPolicy(){
    secedit /export /cfg c:\secpol.cfg
    (Get-Content C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0").replace("MinimumPasswordLength = 7", "MinimumPasswordLength = 1") | Out-File C:\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
    Remove-Item -force c:\secpol.cfg -confirm:$false
}

function BuffPasswordPolicy(){
    secedit /export /cfg c:\secpol.cfg
    (Get-Content C:\secpol.cfg).replace("PasswordComplexity = 0", "PasswordComplexity = 1").replace("MinimumPasswordLength = 1", "MinimumPasswordLength = 7") | Out-File C:\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
    Remove-Item -force c:\secpol.cfg -confirm:$false
}

$jsonData = (Get-Content $Jsonfile | ConvertFrom-JSON)
$Global:Domain = $jsonData.domain

if ( -not $Revert) {
    NerfPasswordPolicy

    # Create the groups for the domain
    CreateADGroup $jsonData.groups

    # Create the users for the domain
    foreach ( $user in $jsonData.users){
        CreateADUser $user
    }

} else {
    # Revert given -> roll back
    BuffPasswordPolicy
    foreach ( $user in $jsonData.users){
        RemoveADUser $user
    }
    
    RemoveADGroup $jsonData.groups
}