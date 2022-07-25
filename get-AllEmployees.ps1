#Exports all users with a mailbox from designated dynamic distribution group.

$Credential = Get-Credential
Connect-ExchangeOnline -Credential $Credential

Get-DynamicDistributionGroupMember "<GROUP NAME>" | Select Displayname,PrimarySmtpAddress | Export-Csv "C:\temp\Users.csv" -NoTypeInformation

Disconnect-ExchangeOnline -Confirm:$false
