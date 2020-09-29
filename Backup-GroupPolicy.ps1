function Backup-GroupPolicy{
    <#
    .SYNOPSIS
        This is a Powershell script to automatically backup all GPOs.

    .DESCRIPTION
        This script can be used to automate the backup of all group policy objects.
        It performs an incremental backup and only backs up GPOs that have been
        modified since their last backup. 
        
        The Group Policy Management feature (or Remote Server Administration Tools, 
        RSAT, if on Windows 10 and not Server 2016) needs to be installed in order
        for the grouppolicy module, needed by this script, to import.
        
        Thanks to Matt Browne, MattB101, for his script named GPO_Backup.ps1. 
        The incremental backup part of this script is based upon his script.
        The link to his script is in the LINK section.

    .NOTES
        Author: Eric Claus, SysAdmin, North American Division of SDA, ericclaus@nadadventist.org
        Last Modified: 9/23/20

    .LINK
        https://gallery.technet.microsoft.com/scriptcenter/Incremental-GPO-Backup-ccc0856f

    .COMPONENT
        RSAT, PS module grouppolicy
    #>

    [CmdletBinding()]

    Param(
        # Where to store the backups
        [Parameter(Mandatory=$true)]
            [string]$BackupDirectory,
    
        # Where is the log file to be stored?
        [string]$LogDirectory = "$BackupDirectory\Logs",
    
        [validatescript({$_ -match $ValidEmailAddress})]
            [string]$AlertEmail
    )

    ########## Begin Error Handling ##########
    # If a terminating error occurs, invoke the Send-AlertEmail function and stop the script
    trap {Send-AlertEmail -FunctionName "Invoke-WindowsUpdateByOU" -DestinationEmail $AlertEmail; Exit 1}
    # Treat all errors as terminating, useful for the trap statement above
    $ErrorActionPreference = "Stop"
    ########## End Error Handling ##########

    Write-Output "Beginning Group Policy backup..."

    if (!(Test-Path $backupDirectory)) {mkdir $backupDirectory}
    if (!(Test-Path $LogDirectory)) {mkdir $LogDirectory}

    $date = Get-Date -Format MM-dd-yyyy-HHmm

    $log = "$LogDirectory\GPO-BackupLog-$date.log"
    
    Write-Output $date | Out-File $log
      
    Write-Verbose "Importing grouppolicy module."
    # Import required module
    Import-Module grouppolicy

    # Get all GPOs and loop through them
    Foreach ($GPO in $(Get-GPO -All)) {
        $name = $GPO.DisplayName
        $lastModified = $GPO.ModificationTime
    
        # Set the path to the backup directory, named for the GPO and it's modification date
        $path = "$BackupDirectory\Backups\$name\$lastModified"
        
        # GPO name and last modified date might include chatacters not legal in a file path
        $path = $path -replace ':','-'
        $path = $path -replace 'C-','C:'
        $path = $path -replace '/','-'
        $path = $path -replace ' ','_'
    
        Write-Verbose "GPO name=$name; Last modified=$lastModified; Backup path=$path."

        # Check if the GPO has been modified since it was last backed up by
        # checking to see if there is already a backup folder by the same name.
        If (!(Test-Path $path)) {
            mkdir $path
            Backup-GPO -Name $name -Path $path
            Write-Output ("GPO {0} has been backed up." -f $name.PadRight(40,"-")) | Tee-Object -FilePath $log -Append
        }
        Else {Write-Output ("GPO {0} not backed up." -f $name.PadRight(40,"-")) | Tee-Object -FilePath $log -Append}
    }
}