#REQUIRES -modules ActiveDirectory

$PreferenceDirectory = "C:\Users\AppData\Local\DU\Settings.pref"

Write-Host "This program will connect to your AD forest and do the following: `nDisable the user.`nStrip group access.`nRemove Company attribute."

$Search = Read-Host "Please enter the persons name to search for"

$SearchWild = "*"+$Search+"*"

$SearchBase = Read-Host "Please enter your SearchBase"
$SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
if($SaveFlag -like "y")
{
    
}

$Server = Read-Host "Please enter your DC Hostname"

$cred = Get-Credential

$User = Get-ADUser -Server $Server -Credential $cred -SearchBase $SearchBase -Filter {DisplayName -like $SearchWild}

Write-Host $User