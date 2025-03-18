$jsonData = Get-Content .\ad_config.json | ConvertFrom-JSON
$Global:Domain = $jsonData.domain
$numGroups = $jsonData.numGroups
$MaxUserGroups = $jsonData.MaxUserGroups
$numUsers = $jsonData.numUsers
$OutputJsonFile = $jsonData.outputJsonFile

$groupNames = (Get-Content "data/groups.txt")
$firstNames = (Get-Content "data/firstNames.txt")
$lastNames = (Get-Content "data/lastNames.txt")
$passwords = (Get-Content "data/passwords.txt")
$groups = @(Get-Random -InputObject $groupNames -Count $numGroups)
$users = @()

# Create the domain users with necessary information
for ($i = 0; $i -lt $numUsers; $i++) {
    $firstName = (Get-Random -InputObject $firstNames)
    $lastName = (Get-Random -InputObject $lastNames)
    $password = (Get-Random -InputObject $passwords)
    $newUser = @{
        "name"="$firstName $lastName"
        "password"="$password"
        "groups"=@((Get-Random -InputObject $groups -Count (Get-Random -Minimum 1 -Maximum $MaxUserGroups)))
    }
    $users += $newUser
}

# Create our domain information into an output Json file
ConvertTo-Json -InputObject @{
    "domain"=$Domain
    "groups"=([string]$groups)
    "users"=$users
} | Out-File $OutputJsonFile

