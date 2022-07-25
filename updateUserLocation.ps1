Import-Module CredentialManager
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$cred = Get-StoredCredential -target "<SERVER>"

Connect-ExchangeOnline -Credential $cred

#sets up custom attributes for users to match on dynamic distro group each OU needs to have the DN of the OU you want to apply to all users within.
get-remotemailbox -OnPremisesOrganizationalUnit "<OU PATH>" | set-remotemailbox -customattribute1 "<LOCATION ATTRIBUTE>"


Disconnect-ExchangeOnline -Confirm:$false
