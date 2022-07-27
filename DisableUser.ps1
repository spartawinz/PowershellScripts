#REQUIRES -modules ActiveDirectory
#default save directory
$PreferenceDirectory = $env:AppData + "\DU\Settings.pref"

Function DisableUser{
    [CmdletBinding()]
    param(
        $Sel
    )
    
    foreach ($group in $Sel.MemberOf){
        Remove-ADGroupMember -Identity $group -Members $Sel 
    }
    Disable-ADAccount -Identity $Sel 
}

Write-Host "This program will connect to your AD forest and do the following: `nDisable the user.`nStrip group access.`nRemove Company attribute."

$Search = Read-Host "Please enter the persons name to search for"
#converts Search criteria into fuzzy search
$SearchWild = "*"+$Search+"*"
#If File exists
if(Test-Path -Path $PreferenceDirectory)
{ 
    $Selection = Read-Host "Would you like to use your saved selection?(Y/N)"
    if(( $Selection -notlike "y" ) -and ($Selection -ne ""))
    {
        $SearchBase = Read-Host "Please enter your SearchBase"
        $SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
    }
    else
    {
        $SearchBase = Get-Content -Path $PreferenceDirectory
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

$User = Get-ADUser -Server $Server -Credential $cred -SearchBase $SearchBase -Properties DisplayName,DistinguishedName,MemberOf -Filter {DisplayName -like $SearchWild}
#Logic for User count based on search critera and user picks which one.
if($User.Count -gt 1) {
    $i = 0
    Write-Host "Please select a user from the list below."
    foreach ($u in $User){
        $str = "[" + [string]($i++) + "]" + [string]$u.DisplayName
        Write-Host $str
    }    
    $Selection = Read-Host "Selection"
    if(($Selection -ge ($User.Count)) -or ([int]$Selection -lt 0)){
        Write-Host "Invalid Selection."
        return
    }
    else{
        DisableUser -Sel $User.Get($Selection)
    }
}
elseif($User.Count -eq 0)
{
    Write-Host "NO USER FOUND..."
}
else{
    DisableUser -Sel $User

}

