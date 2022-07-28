#This list will turn on system restore protection on the machine. This does require Administrator priveledges and a txt file with a list of computers separated by new lines.
#You can modify the drives by adding the drive letter separated by a ,.
function enableRestore{
    [CmdletBinding()]
    param ()
    
    Enable-ComputerRestore -drive "C:"
    vssadmin resize shadowstorage /on=c: /for=c: /maxsize=10%
}
$List = Get-Content -Path C:\temp\computers.txt
$cred = Get-Credential

foreach($item in $list){
    Invoke-Command -ComputerName $item -Credential $cred -ScriptBlock ${function:enableRestore}
}

