function Repair-BTWildcardRecord {
    [CmdletBinding()]
    param (
        [Parameter()]
        [array]$WildcardRecords,
        [switch]$Run = $false
    )

    if ($null -eq $WildcardRecords) {
        $WildcardRecords = Test-BTWildcardRecord
    }

    if ($Run) {
        foreach ($wildcardrecord in $WildcardRecords) {
            $type = "-$($wildcardrecord.'Correct Type')"
            if ($wildcardrecord.'Wildcard Exists?') {
                Remove-DnsServerResourceRecord -ComputerName $wildcardrecord.Domain -ZoneName $wildcardrecord.Domain -RRType $wildcardrecord.'Current Wildcard Type' -Name '*'
            }
            Add-DnsServerResourceRecord -ComputerName $wildcardrecord.Domain -ZoneName $wildcardrecord.Domain $type -Name '*' -IPv4Address '0.0.0.0'
        }
    } else {
        foreach ($wildcardrecord in $WildcardRecords) {
            $type = "-$($wildcardrecord.'Correct Type')"
            if ($wildcardrecord.'Wildcard Exists?') {
                Write-Host "Run the following code block to delete the Wildcard Record of incorrect type ($($wildcardrecord.'Current Wildcard Type')) and replace with a Wildcard Record of the correct type ($type) in the $($wildcardrecord.Domain) domain" -ForegroundColor Green
                Write-Host @"
Remove-DnsServerResourceRecord -ComputerName $($wildcardrecord.Domain) -ZoneName $($wildcardrecord.Domain) -RRType $($wildcardrecord.'Current Wildcard Type') -Name '*'
Add-DnsServerResourceRecord -ComputerName $($wildcardrecord.Domain) -ZoneName $($wildcardrecord.Domain) $type -Name '*' -IPv4Address '0.0.0.0'
              
"@
            } else {
                Write-Host "Run the following code block to create a Wildcard Record in the $($wildcardrecord.Domain) domain" -ForegroundColor Green
                Write-Host @"
Add-DnsServerResourceRecord -ZoneName $($wildcardrecord.Domain) -ComputerName $($wildcardrecord.Domain) $type -Name '*' -IPv4Address '0.0.0.0'
              
"@
            }
        }
    }
}