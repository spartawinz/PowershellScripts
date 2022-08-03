#REQUIRES -modules ActiveDirectory
#The "encryption" used in this program is just to obscure the preferences since it holds dc and domain information and should not be trusted as secure
#default save directory
$PreferenceDirectory = $env:AppData + "\DU\Settings.pref"
#generates empty hash table
$Preferences = @{}
#Powershell pulls data from settings and updates them
Function DisableUser{
    [CmdletBinding()]
    param(
        $Sel
    )
    
    foreach ($group in $Sel.MemberOf){
        Remove-ADGroupMember -Identity $group -Members $Sel -Confirm:$false
    }
    
    Set-ADUser -Identity $Sel -Clear Company -Credential $cred
    Disable-ADAccount -Identity $Sel -Credential $cred
    Move-ADObject -Identity $Sel -Server $Server -Credential $cred -TargetPath $DisabledDirectory
}

Function Encrypt{
    param(
        [string]$str
    )
    $output = ConvertTo-SecureString -String $str -AsPlainText -Force | ConvertFrom-SecureString
    
    return $output
}

Function Decrypt{
    [CmdletBinding()]
    param(
        [string]$encrypted
    )
    $staged = ConvertTo-SecureString -String $encrypted
    $decrypted = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((($staged))))
    $output = convertStringToHash -str $decrypted
    return $output
}

Function convertStringToHash{
    [CmdletBinding()]
    param(
        [string]$str
    )
    $newHash = ConvertFrom-StringData -StringData $str
    return $newHash
}

Function convertHashToString{
    [CmdletBinding()]
    param(
        [HashTable[]]$hash
    )
    $newstr = ""
    foreach($item in $hash){
        foreach($entry in $item.getEnumerator()){
            if($entry.Value -contains "="){
                $splitValue = $entry.Value -split "="
                for($i = 0;$i -lt $splitValue.count;$i++){
                    if($i -eq ($splitValue.count-1)){
                        $newValue += $splitValue[$i]
                    }
                    else{
                        $newValue += $splitValue[$i] + "`="
                    }
                }
                $newstr = += $entry.Key + $newValue + "`n"
            }
            else{
                $newstr += $entry.Key + "=" + $entry.Value + "`n"
            }
            
        }
    }
    return $newstr
}

Function updatePreferences{
    [CmdletBinding()]
    param(
        $Path
    )
    if(!([string]::IsNullOrWhiteSpace($(Get-Content -Path $Path)))){
        $Pref = Decrypt -encrypted $(Get-Content -Path $Path)
        return $Pref
    }
    else{
        Write-Output "Preferences is blank."
    }
    
}

Function SaveFile{
    [CmdletBinding()]
    param(
        $File,
        $Path
    )
    $data = convertHashToString -hash $File
    Out-File -FilePath $PreferenceDirectory -InputObject $(Encrypt -str $data)
}



#generates blank preference list if it doesn't exist
if (-Not(Test-Path -Path $PreferenceDirectory)){
        New-Item -ItemType File -Path $PreferenceDirectory -UseTransaction:$false 
}

$Preferences = updatePreferences -Path $PreferenceDirectory

Write-Host "This program will connect to your AD forest and do the following: `nDisable the user.`nStrip group access.`nRemove Company attribute."

$Search = Read-Host "Please enter the persons name to search for"
#converts Search criteria into fuzzy search
$SearchWild = "*"+$Search+"*"

#Start Search Base Logic
#If File exists and preference exists
if((Test-Path -Path $PreferenceDirectory) -and !([string]::IsNullOrEmpty($Preferences.Item('SearchBase')))){ 
    $Selection = Read-Host "Would you like to use your saved Search Base selection?(Y/N)"
    if(( $Selection -notlike "y" ) -and ($Selection -ne ""))
    {
        $SearchBase = Read-Host "Please enter your SearchBase"
        $SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
    }
    else
    {
        $SearchBase = $Preferences.Item('SearchBase')
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
    $SaveFlag = "n"
    if(Test-Path -Path $PreferenceDirectory)
    {
        $Preferences.Item('SearchBase') = $SearchBase
        SaveFile -Path $PreferenceDirectory -File $Preferences
    }
    
}
#Start DC Server Logic
#$Server = Read-Host "Please enter your DC Hostname"

if((Test-Path -Path $PreferenceDirectory) -and !([string]::IsNullOrEmpty($Preferences.Item('Server')))){ 
    $Selection = Read-Host "Would you like to use your saved DC selection?(Y/N)"
    if(( $Selection -notlike "y" ) -and ($Selection -ne ""))
    {
        $Server = Read-Host "Please enter your DC Hostname" 
        $SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
    }
    else{
        $Server = $Preferences.Item('Server')
    }
    
}
else
{
    $Server = Read-Host "Please enter your DC Hostname" 
    $SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
}
if($SaveFlag -like "y")
{
    $SaveFlag = "n"
    if(Test-Path -Path $PreferenceDirectory)
    {
        
        $Preferences.Item('Server') = $Server
        SaveFile -Path $PreferenceDirectory -File $Preferences
    }
}
#Start Disabled Directory Logic
#$DisabledDirectory = Read-Host "Please enter your disabled Distinguished Name"

if((Test-Path -Path $PreferenceDirectory) -and !([string]::IsNullOrEmpty($Preferences.Item('DisabledDirectory')))){ 
    $Selection = Read-Host "Would you like to use your saved disabled directory selection?(Y/N)"
    if(( $Selection -notlike "y" ) -and ($Selection -ne ""))
    {
        $DisabledDirectory = Read-Host "Please enter your disabled Distinguished Name" 
        $SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
    }
    else{
        $DisabledDirectory = $Preferences.Item('DisabledDirectory')
    }

}
else
{
    $DisabledDirectory = Read-Host "Please enter your disabled user OU Distinguished Name" 
    $SaveFlag = Read-Host "Would you like to save this selection?(Y/N)"
}
if($SaveFlag -like "y")
{
    $SaveFlag = "n"
    if(Test-Path -Path $PreferenceDirectory)
    {
        
        $Preferences.Item('DisabledDirectory') = $DisabledDirectory
        SaveFile -Path $PreferenceDirectory -File $Preferences
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
    if(([int]$Selection -ge ($User.Count)) -or ([int]$Selection -lt 0)){
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

