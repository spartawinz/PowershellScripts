#This Script will pull all installed software that has a uninstall script from the registry and lists them and filters out dell and microsoft installations.

﻿Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object {$_.Publisher -notlike "*Microsoft*"} |
    Where-Object {$_.Publisher -notlike "*Dell*" } |
    Format-Table –AutoSize

Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object {$_.Publisher -notlike "*Microsoft*"} |
    Where-Object {$_.Publisher -notlike "*Dell*"} |
    Format-Table –AutoSize
