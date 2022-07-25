#Writes attributes and can be modified to add others or multiple.

Import-Module ActiveDirectory
# Foreach $aduser in (get all the AD user)
foreach($aduser in (Get-ADUser -Filter * -SearchBase '<SEARCH BASE>')){
  Set-ADUser -identity $aduser.samaccountname -Replace @{Company='<INSERT COMPANY NAME'} -Verbose
}
