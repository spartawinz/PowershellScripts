#REQUIRES -modules ActiveDirectory
#default save directory
$PreferenceDirectory = $env:AppData + "\DU\Settings.pref"
#generates blank preference list if it doesn't exist
if (-Not(Test-Path -Path $PreferenceDirectory)){
    $emptyList = @([string]"",[string]"",[string]"")
    New-Item -ItemType File -Path $PreferenceDirectory -UseTransaction:$false 
    Out-File -FilePath $PreferenceDirectory -InputObject $emptyList
}
$Preferences = (Get-Content -Path $PreferenceDirectory)



Function DisableUser{
    [CmdletBinding()]
    param(
        $Sel
    )
    
    foreach ($group in $Sel.MemberOf){
        Remove-ADGroupMember -Identity $group -Members $Sel -Confirm:$false
    }
    
    Set-ADUser -Identity $Sel -Clear Company -Credential $cred
    Disable-ADAccount -Identity $Sel
    Move-ADObject -Identity $Sel -Server $Server -Credential $cred -TargetPath $DisabledDirectory
}

Write-Host "This program will connect to your AD forest and do the following: `nDisable the user.`nStrip group access.`nRemove Company attribute."

$Search = Read-Host "Please enter the persons name to search for"
#converts Search criteria into fuzzy search
$SearchWild = "*"+$Search+"*"
#If File exists and preference exists
if((Test-Path -Path $PreferenceDirectory) -and !([string]::IsNullOrEmpty($Preferences[0])))
{ 
    $Selection = Read-Host "Would you like to use your saved Search Base selection?(Y/N)"
    if(( $Selection -notlike "y" ) -and ($Selection -ne ""))
    {
        $SearchBase = [string](Read-Host "Please enter your SearchBase")
        $SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
    }
    else
    {
        $SearchBase = $Preferences[0]
    }
    
}
else
{
    $SearchBase = [string](Read-Host "Please enter your SearchBase")
    $SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
}
#saves to file in preference directory
if($SaveFlag -like "y")
{
    $SaveFlag = $false
    if(Test-Path -Path $PreferenceDirectory)
    {
        $Preferences[0]=$SearchBase
        Out-File -FilePath $PreferenceDirectory -InputObject $Preferences
    }
    
}

#$Server = Read-Host "Please enter your DC Hostname"

if((Test-Path -Path $PreferenceDirectory) -and !([string]::IsNullOrEmpty($Preferences[1])))
{ 
    $Selection = Read-Host "Would you like to use your saved DC selection?(Y/N)"
    if(( $Selection -notlike "y" ) -and ($Selection -ne ""))
    {
        $Server = Read-Host "Please enter your DC Hostname"
        $SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
    }
    else{
        $Server = $Preferences[1]
    }
    
}
else
{
    $Server = Read-Host "Please enter your DC Hostname"
    $SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
}
if($SaveFlag -like "y")
{
    $SaveFlag = $false
    if(Test-Path -Path $PreferenceDirectory)
    {
        $Preferences[1] = $Server
        Out-File -FilePath $PreferenceDirectory -InputObject $Preferences
    }
}

#$DisabledDirectory = Read-Host "Please enter your disabled Distinguished Name"

if((Test-Path -Path $PreferenceDirectory) -and !([string]::IsNullOrEmpty($Preferences[2]))){ 
    $Selection = Read-Host "Would you like to use your saved disabled directory selection?(Y/N)"
    if(( $Selection -notlike "y" ) -and ($Selection -ne ""))
    {
        $DisabledDirectory = Read-Host "Please enter your disabled Distinguished Name"
        $SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
    }

}
else
{
    $DisabledDirectory = Read-Host "Please enter your disabled user OU Distinguished Name"
    $SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
}
if($SaveFlag -like "y")
{
    $SaveFlag = $false
    if(Test-Path -Path $PreferenceDirectory)
    {
        $Preferences[2] = $DisabledDirectory
        Out-File -FilePath $PreferenceDirectory -InputObject $Preferences
    }
}

if($Cred -eq $null){
    $cred = Get-Credential
}

$User = Get-ADUser -Server $Server -Credential $cred -SearchBase $SearchBase -Properties DisplayName,DistinguishedName,MemberOf,Company -Filter {DisplayName -like $SearchWild}
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

