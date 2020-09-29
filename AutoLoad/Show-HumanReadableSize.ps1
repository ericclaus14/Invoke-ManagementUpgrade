function Show-HumanReadableSize {
    <#
    .SYNOPSIS
        Converts a file's size, specified in bytes as an int, to a human readable form.  

    .INPUTS
    [Int64]

    .OUTPUTS
    [String]

    .NOTES
        Author: Eric Claus, Sys Admin, North American Division of the Seventh-day Adventist church, ericclaus@nadadventist.org
        Last modified: 2/11/2020
    #>

    param(
        [Parameter(Mandatory=$True)][long]$SizeInBytes
    )

    if ($SizeInBytes -ge 1TB) {
        $humanReadableSize = "$([math]::Round($SizeInBytes / 1TB,2)) TB"
    }
    if ($SizeInBytes -ge 1GB) {
        $humanReadableSize = "$([math]::Round($SizeInBytes / 1GB,2)) GB"
    }
    elseif ($SizeInBytes -ge 1MB) {
        $humanReadableSize = "$([math]::Round($SizeInBytes / 1MB,2)) MB"
    }
    elseif ($SizeInBytes -ge 1KB) {
        $humanReadableSize = "$([math]::Round($SizeInBytes / 1KB,2)) KB"
    }

    return $humanReadableSize
}