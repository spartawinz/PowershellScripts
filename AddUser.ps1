#WORK IN PROGRESS, allows for creation of user via powershell and the exchange snapin.

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$Credential = Get-Credential
Connect-ExchangeOnline -Credential $Credential

$Alias = Read-Host "User Alias"
$UPN = $Alias + "@Company.com"
$FirstName = Read-Host "First Name"

$InitialFlag = Read-Host "Intials input?(Y/N)"
if(($InitialFlag -eq "Y") -or ($InitialFlag -eq "y")){
    $Initial = Read-Host "Initial"
}
else{
    $Initial = $null
}

$LastName = Read-Host "Last Name"

if($Initial -ne $null){
    $DisplayName = $FirstName + " " + $Initial + ". " + $LastName
}
else{
    $DisplayName = $FirstName + " " + $LastName
}

Write-Host "Please pick an OU.`n"
Write-Host "[0]Place0`n[1]Place1`n[2]Place2`n[3]Place3`n[4]Place4`n[5]Place5`n[6]Place6`n[7]Place7`n"
$OUChoice = Read-Host "Please Pick a selection"

Switch ($OUChoice){
    0 {
    #Place0
        Write-Host "Please Pick a Department."
        Write-Host "[0]Parts`n[1]Sales`n[2]Service Advisors`n[3]Service Techs`n[4]Reception`n[5]Cashier`n[6]Finance`n[7]Sales Manager`n[8]Car Wash`n"
        $DeptChoice = Read-Host "Department Choice"
        Switch ($DeptChoice){
            0{
                $OU = "<Location>"
                break
            }
            1{
                $OU = "<Location>"
                break
            }
            2{
                $OU = "<Location>"
                break
            }
            3{
                $OU = "<Location>"
                break
            }
            4{
                $OU = "<Location>"
                break
            }
            5{
                $OU = "<Location>"
                break
            }
            6{
                $OU = "<Location>"
                break
            }
            7{
                $OU = "<Location>"
                break
            }
            8{
                $OU = "<Location>"
                break
            }
            Default{
                Write-Host "Invalid Entry."
                return
            }
        }
        break
    }
    1 {
    #Place1
        Write-Host "Please Pick a Department."
        Write-Host "[0]Finance`n[1]Parts Counter Person`n[2]Parts Manager`n[3]Sales`n[4]Sales Manager`n[5]Reception`n[6]Service Advisor`n[7]Service Tech`n[8]Service Manager`n"
        $DeptChoice = Read-Host "Department Choice"
        Switch ($DeptChoice){
            0{
                $OU = "<Location>"
                break
            }
            1{
                $OU = "<Location>"
                break
            }
            2{
                $OU = "<Location>"
                break
            }
            3{
                $OU = "<Location>"
                break
            }
            4{
                $OU = "<Location>"
                break
            }
            5{
                $OU = "<Location>"
                break
            }
            6{
                $OU = "<Location>"
                break
            }
            7{
                $OU = "<Location>"
                break
            }
            8{
                $OU = "<Location>"
                break
            }
            Default{
                Write-Host "Invalid Entry."
                return
            }
        }
        break
    }
    2 {
    #Place2
        Write-Host "Please Pick a Department."
        Write-Host "[0]Accounting`n[1]BDC`n[2]Executive`n[3]Finance`n[4]Parts`n[5]Sales`n[6]Sales Manager`n[7]Service Tech`n[8]Service Advisor`n[9]Cashier`n"
        $DeptChoice = Read-Host "Department Choice"
        Switch ($DeptChoice){
            0{
                $OU = "<Location>"
                break
            }
            1{
                $OU = "<Location>"
                break
            }
            2{
                $OU = "<Location>"
                break
            }
            3{
                $OU = "<Location>"
                break
            }
            4{
                $OU = "<Location>"
                break
            }
            5{
                $OU = "<Location>"
                break
            }
            6{
                $OU = "<Location>"
                break
            }
            7{
                $OU = "<Location>"
                break
            }
            8{
                $OU = "<Location>"
                break
            }
            9{
                $OU = "<Location>"
                break
            }
            Default{
                Write-Host "Invalid Entry."
                return
            }
        }
        break
    }
    3 {
        #Place3
        Write-Host "Please Pick a Department."
        Write-Host "[0]BDC Sales`n[1]BDC Service`n[2]Connect`n[3]Executive`n[4]HR`n[5]Marketing`n[6]Support Staff`n[7]Body Shop`n"
        $DeptChoice = Read-Host "Department Choice"
        Switch ($DeptChoice){
            0{
                $OU = "<Location>"
                break
            }
            1{
                $OU = "<Location>"
                break
            }
            2{
                $OU = "<Location>"
                break
            }
            3{
                $OU = "<Location>"
                break
            }
            4{
                $OU = "<Location>"
                break
            }
            5{
                $OU = "<Location>"
                break
            }
            6{
                $OU = "<Location>"
                break
            }
            7{
                $OU = "<Location>"
                break
            }
            Default{
                Write-Host "Invalid Entry."
                return
            }
        }
        break
    }
    4 {
        break
    }
    5 {
        break
    }
    6 {
        break
    }
    7 {
        break
    }
    Default {
        break
    }
}

if($OU -eq $null)
{
    Write-Host "OU is Empty."
    return
}
else{
    New-RemoteMailbox -Name $Name -UserPrincipalName $UPN -Password (ConvertTo-SecureString -String $Employee.Password -AsPlainText -Force) -Alias $Employee.Alias -FirstName $Employee.FirstName -LastName $Employee.LastName -DisplayName $DisplayName -OnPremisesOrganizationalUnit $Employee.OU -ResetPasswordOnNextLogon:$false
}

Disconnect-ExchangeOnline -Confirm:$false
