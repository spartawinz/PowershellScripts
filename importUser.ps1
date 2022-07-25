#Imports users from a csv file through the online exchange snapin in powershell. This is designed to work in a hybrid environment.

﻿Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$Credential = Get-Credential
Connect-ExchangeOnline -Credential $Credential

#input file
$infile = Import-Csv "C:\temp\ADUserTemplate.csv" -delimiter ","

foreach($Employee in $infile) {

    $UPN = $Employee.Alias + "@Company.com"
    if ($Employee.Initials -eq "") {
        $DisplayName = $Employee.FirstName + " " + $Employee.LastName
    }
    else {
        $DisplayName = $Employee.FirstName + " " + $Employee.Initials + ". " + $Employee.LastName
    }
    $Name = $DisplayName

    New-RemoteMailbox -Name $Name -UserPrincipalName $UPN -Password (ConvertTo-SecureString -String $Employee.Password -AsPlainText -Force) -Alias $Employee.Alias -FirstName $Employee.FirstName -LastName $Employee.LastName -DisplayName $DisplayName -OnPremisesOrganizationalUnit $Employee.OU -ResetPasswordOnNextLogon:$false
}

Disconnect-ExchangeOnline -Confirm:$false
