function Reset-ADUserPwdLastSet {
    <#
        .SYNOPSIS
            Resets the Password Last Set attribute of AD users.

        .DESCRIPTION

        .EXAMPLE
            Reset-ADUserPwdLastSet -SearchBase "ou=StandardUsers,dc=domain,dc=com" -LogDirectory "C:\Script\Logs" -AlertEmail "myEmail@domain.com"

        .NOTES
            Author: Eric Claus, TSC Convention 2020
            Last Modified: 10/5/2020
    #>

    [CmdletBinding()]

    Param(
        # Targeted OU's DN
        [string]$SearchBase,

        [string]$LogDirectory = "$PSScriptRoot",

        [string]$AlertEmail
    )

    trap {Send-AlertEmail -FunctionName "Reset-ADUserPwdLastSet" -DestinationEmail $AlertEmail; Exit 1}
    $ErrorActionPreference = "Stop"


    Import-Module ActiveDirectory

    Start-Transcript "$LogDirectory\transcript.txt"

    $values = @("0","-1")

    $property = "pwdLastSet"
    
    if ($SearchBase) {
        $users = Get-ADUser -Filter "*" -SearchBase $SearchBase -Properties $property
    }
    else {
        $users = Get-ADUser -Filter "*" -Properties $property
    }
    
    $numUserModified = 0
    $numUsersTotal = ($users).count 
    
    foreach ($user in $users) {
        foreach ($value in $values) {
            $user.$property = $value
            Set-ADUser -Instance $user
        }
        
         
        $numUserModified++
        Write-Output "User: $numUserModified / $numUsersTotal"
        
    }

    Stop-Transcript
}