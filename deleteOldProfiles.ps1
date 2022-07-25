# Script to remove accounts that are over 30 days since last logged in.

Get-WMIObject -class Win32_UserProfile | Where {(!$_.Special) -and ($_.ConvertToDateTime($_.LastDownloadTime) -lt (Get-Date).AddDays(-30))} | Remove-WmiObject