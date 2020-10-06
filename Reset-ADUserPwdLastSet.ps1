function Reset-ADUserPwdLastSet {
    <#
    .SYNOPSIS
        Reset the Password Last Set attribute of AD users. 

    .EXAMPLE
        Reset-ADUserPwdLastSet -SearchBase "ou=myOU,dc=contoso,dc=cool" -LogDirectory "C:\Scripts\Logs" -AlertEmail "myEmail@domain.com"

    .NOTES
        Author: Eric Claus, TSC 2020
        Last Modified: 10/6/2020    
    #>

    [CmdletBinding()]

    Param(
        # DN of target OU
        [string]$SearchBase,

        [string]$LogDirectory = "$PSScriptRoot",

        [string]$AlertEmail
    )

    Start-Transcript "$LogDirectory\transcript.txt"

    trap {Send-AlertEmail -FunctionName "Reset-ADUserPwdLastSet" -DestinationEmail $AlertEmail}
    $ErrorActionPreference = "Stop"

    Import-Module ActiveDirectory

    $property = "pwdLastSet"

    $values = @("0","-1")

    if ($SearchBase) {
        $users = Get-ADUser -Filter "*" -SearchBase $SearchBase
    }
    else {
        $users = Get-ADUser -Filter "*"
    }

    $numberOfUsersModified = 0
    $numberOfTotalUsers = ($users).count

    foreach ($user in $users) {
        foreach ($value in $values) {
            $user.$property = $value
            Set-ADUser -Instance $user
        }

        $numberOfUsersModified++
        Write-Host "User: $numberOfUsersModified / $numberOfTotalUsers"

    }


    Stop-Transcript
}