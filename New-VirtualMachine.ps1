function New-VirtualMachine {
    <#
    .SYNOPSIS
        Creates a new virtual machine in the specified cluster

    .EXAMPLE
        New-VirtualMachine -Name TestVM2 -ProcessorCount 2 -MemoryStartup 1024MB -MemoryMaximum 2048MB -DiskSize 30GB -VlanID 1001 -OperatingSystem 'Server 2019' -Path "\\fs1\Perf1\Testing"
        Creates a new VM named "TestVM2" in the FC1 cluster on hypervisor FC11 with the specified specs. It also uses the default memory minimum value of 512MB, the default generation value of 2, and the default switch name "SETswitch1". Prompts for credentials.

    .EXAMPLE
        New-VirtualMachine -Name TestVM3 -ProcessorCount 2 -MemoryStartup 2048MB -MemoryMinimum 1024MB -MemoryMaximum 4096MB -DiskSize 30GB -VlanID 1001 -OperatingSystem 'Server 2019' -Credentials $creds
        Creates a new VM named "TestVM3" in the FC2 cluster on FC23. Uses the credentials stored in $creds (this must be a PSCredntial object).

    .NOTES
        Authors: Richard Stephenson, Eric Claus
        Last Modified: 2/11/2020
    #>

    [CmdletBinding(DefaultParameterSetName="None")]

    Param(
        [Parameter(Mandatory=$true)]
            [string]$Name,

        [int]$ProcessorCount = 2,

        [Parameter(Mandatory=$true)]
            [Int64]$MemoryStartup,

        [Int64]$MemoryMinimum = 512MB,

        [Int64]$MemoryMaximum = 8192MB,

        [Int64]$DiskSize = 40GB,

        [string]$VMPath = "C:\Hyper-V",

        [string]$SwitchName = "ExternalSwitch",

        [Parameter(Mandatory=$true)]
            [int]$VlanID,

        [int]$Generation = 2,

        [switch]$FixedMemory,

        [Parameter(Mandatory=$true)]
            [ValidateSet('Server 2019', 'CentOS 7', 'CentOS 8')]
            [string]$OperatingSystem,

        [pscredential]$Credentials = (Get-Credential),

        [Parameter(ParameterSetName="Disks",Mandatory=$false)]
            [switch]$AddExtraDisks,


        [Parameter(ParameterSetName="Disks",Mandatory=$true)]
            [Int64[]]$ExtraDiskSIzes
    )

    #Create the New VM. Change variables such as VM Name, Path, VHD Path, disk size, etc. By default the disk will be dynamic.

    New-VM -Name $Name -Path "$Path\" -NewVHDPath "$Path\$Name\Disk1.vhdx" -NewVHDSizeBytes $DiskSize -Generation $Generation -MemoryStartupBytes $MemoryStartup -SwitchName $SwitchName

    #To set the VLAN ID of the virtual switch that was just created...

    Set-VMNetworkAdapterVlan -VMName $Name -Access -VlanId $VlanID

    #With the VM created, we now need to configure CPU, memory, etc.

    Set-VM -Name $Name -ProcessorCount $ProcessorCount -DynamicMemory -MemoryMinimumBytes $MemoryMinimum -MemoryMaximumBytes $MemoryMaximum

    #If you want to create a second (or third, etc.) hard drive. If you want a Fixed disk, then change -dynamic to -fixed

    if ($AddExtraDisks) {
        $DiskCount = 1

        foreach ($DiskSize in $ExtraDiskSIzes) {
            $DiskCount ++

            $DiskPath = "$Path\$Name\Disk$DiskCount.vhdx"

            New-VHD -Path $DiskPath -SizeBytes $Disksize -Dynamic

            #IF you need to add a second disk...

            Add-VMHardDiskDrive -VMName $Name -Path $DiskPath
        }
    }
    
    $IsoRootDir = "C:\ISOs"

    Switch ($OperatingSystem)
    {
        "Server 2019" {$ISO = "$IsoRootDir\SW_DVD9_Win_Server_STD_CORE_2019_64Bit_English_DC_STD_MLF_X21-96581.iso"}
        "CentOS 7" {$ISO = "$IsoRootDir\CentOS-7-x86_64-DVD-1810.iso"; Set-VMFirmware -VMName $Name -EnableSecureBoot Off}
        "CentOS 8" {$ISO = "$IsoRootDir\CentOS-8-x86_64-1905-dvd1.iso"; Set-VMFirmware -VMName $Name -EnableSecureBoot Off}
    }
    
    #Add a DVD drive and map the ISO to drive

    Add-VMDvdDrive -VMName $Name -Path $ISO

    #Now we need to set the DVD drive as the primary boot device.

    Set-VMFirmware -VMName $Name -FirstBootDevice $(Get-VMDvdDrive -VMName $Name)

    #to start the VM...

    Start-VM -Name $Name

    # Send email as a reminder for post-VM creation tasks

    $MemoryStartupHuman = Show-HumanReadableSize $MemoryStartup
    $DiskSizeHuman = Show-HumanReadableSize $DiskSize
    if ($AddExtraDisks) {
        $ExtraDiskSIzesHuman = @()
        foreach ($size in $ExtraDiskSIzes) {
            $ExtraDiskSIzesHuman += Show-HumanReadableSize $size
        }
    }
    
    $From = "New-VirtualMachine1@nadadventist.org"
    $To = @("ericclaus@nadadventist.org","miltonsand@nadadventist.org","richardstephenson@nadadventist.org")
    $Subject = "Auto Reminder for $Name VM Post-Creation Tasks"
    $SMTPServer = "10.4.11.25"
    $SMTPPort = "25"
    $Body = "A new VM, $Name, has been created. This is an automatically generated reminder to perform the following tasks as applicable: `n `n-Add the VM to Veeam B&R, `n-Add the VM to monitoring (Nagios/Pingdom), `n-Add the VM to the inventory, `n-Add the VM's IP address to the network documentation on the Wiki, `n-Add the VM's local admin credentials to the credentials documentation on the Wiki. `n `nThe VM's specs are: `n-vCPUs=$ProcessorCount, `n-Startup memory=$MemoryStartupHuman, `n-Disk size=$DiskSizeHuman (if additional disks are present, their sizes=$ExtraDiskSIzesHuman), `n-OS=$OperatingSystem, `n-VLAN=$VlanID."
    Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort

    #Notes: As a best practice, once Windows or Linux is installed, remove the ISO from the DVD drive. 
}