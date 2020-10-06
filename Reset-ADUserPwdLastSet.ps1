function Reset-ADUserPwdLastSetValue {
    <#
    .SYNOPSIS
        This is a Powershell script to reset the PasswordLastSet attribute of AD users.
     
    .DESCRIPTION
        Resets the PasswordLastSet attribute of AD users in the entire domain, or in a specified OU, to the current date and time. 
        It does this by manipulating the pwdLastSet property of the AD users. This is useful if the password expiration date of the AD user accounts needs to be extended. 
        If specifying an OU, give the Distinguished Name (DN) of the OU.  

    .EXAMPLE
        Reset-ADUserPwdLastSetValue -SearchBase "ou=StdUsers,dc=contoso,dc=cool" -LogDirectory "C:\Scripts\Logs" -AlertEmail "myEmail@domain.com"
        Resets the Password Last Set value for all users in the StdUsers OU, saving the log file in C:\Scripts\Logs and emailing myEmail@domain.com with any errors.

    .NOTES
        Author: Eric Claus, SysAdmin, North American Division of SDA, ericclaus@nadadventist.org
        Last Modified: 10/6/2020
        2020 TSC Convention, Windows Admin breakout session
     #>

    # Allows support for default parameters (such as -Verbose)
    [CmdletBinding()]

    Param(    
        # The DN of an OU
        [string]$SearchBase,
        
        # Where is the log file to be stored?
        [ValidateScript({Test-Path $_ -PathType 'container'})] 
            [string]$LogDirectory = "$PSScriptRoot",
    
        # Where to send an email if there is an error with the function
        # Uncomment the below line if you have the $ValidEmailAddress variable in RAM (e.g. defined in your profile)
        #[validatescript({$_ -match $ValidEmailAddress})]
        [string]$AlertEmail
    )

    Start-Transcript "$LogDirectory\transcript.txt"

    ########## Begin Error Handling ##########
    # If a terminating error occurs, invoke the Send-AlertEmail function and stop the script
    trap {Send-AlertEmail -FunctionName "Set-ADUserInBulk" -DestinationEmail $AlertEmail; Exit 1}
    # Treat all errors as terminating, useful for the trap statement above
    $ErrorActionPreference = "Stop"
    ########## End Error Handling ##########

    ###### Required Module ######
    Import-Module ActiveDirectory

    $property = "pwdLastSet"

    # To reset the pwdLastSet attribute to the current date and time, it has to be first set to 0 and then to -1
    $values = @("0","-1")

    # Get the AD users
    if ($SearchBase) {
        $users = Get-ADUser -SearchBase $SearchBase -Filter "*" -Properties $property
    }
    else {
        $users = Get-ADUser -Filter "*" -Properties $property
    }

    # Initialize counters to track progress
    $numUsersModified = 0
    $numUsersChanged = 0
    $numTotalUsers = ($users).count 
    # If the OU only contains 1 user, the ($users).count statement above will return empty
    if (!($numUsersModified)) {
        $numTotalUsers = 1
    }

    # Loop through each user
    foreach ($user in $users) {
        # Loop through each of the two values in the $values array 
        foreach ($value in $values) {
            $user.$property = $value

            Set-ADUser -Instance $user
        }
        
        $numUsersModified++
        echo "User: $numUsersModified / $numTotalUsers"

    }

    Stop-Transcript
}