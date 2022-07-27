#REQUIRES -modules ActiveDirectory
#default save directory
$PreferenceDirectory = $env:AppData + "\DU\Settings.pref"

Write-Host "This program will connect to your AD forest and do the following: `nDisable the user.`nStrip group access.`nRemove Company attribute."

$Search = Read-Host "Please enter the persons name to search for"
#converts Search criteria into fuzzy search
$SearchWild = "*"+$Search+"*"
#If File exists
if(Test-Path -Path $PreferenceDirectory)
{ 
    if(((Read-Host "Would you like to use your saved selection?(Y/N)") -notlike "y"))
    {
        $SearchBase = Read-Host "Please enter your SearchBase"
        $SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
    }
    else
    {
        $SearchBase = Get-Content -Path $PreferenceDirectory
        Write-Host $SearchBase
    }
}
else
{
    $SearchBase = Read-Host "Please enter your SearchBase"
    $SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
}
#saves to file in preference directory
if($SaveFlag -like "y")
{
    if(Test-Path -Path $PreferenceDirectory)
    {
        Out-File -FilePath $PreferenceDirectory -InputObject $SearchBase
    }
    else
    {
        New-Item -Path $PreferenceDirectory -Force -Value $SearchBase
    }
}

$Server = Read-Host "Please enter your DC Hostname"

$cred = Get-Credential

$User = Get-ADUser -Server $Server -Credential $cred -SearchBase $SearchBase -Filter {DisplayName -like $SearchWild}

Write-Host $User