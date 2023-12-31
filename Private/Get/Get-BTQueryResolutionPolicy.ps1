function Get-BTQueryResolutionPolicy {
    [CmdletBinding()]
    param (
        [Parameter()]
        [array]$Domains
    )

    if ($null -eq $Domains) {
        $Domains = Get-BTTarget
    }

    $QueryResolutionPolicyList = @()
    foreach ($domain in $Domains) {
        $DNSServers = Resolve-DnsName -Type NS -Name $domain | Where-Object QueryType -eq 'A'
        foreach ($dnsServer in $DNSServers) {
            $QueryResolutionPolicies = (Get-DnsServer -ComputerName $dnsServer.IP4Address -ErrorAction Ignore -WarningAction Ignore).ServerPolicies
            if ($QueryResolutionPolicyList.'Server IP' -notcontains $dnsServer.IP4Address) {
                    foreach ($policy in $QueryResolutionPolicies) {
                        $AddToList = [PSCustomObject]@{
                        'Server Name'          = $dnsServer.Name
                        'Server IP'            = $dnsServer.IP4Address
                        'QRP Name'             = $policy.Name
                        'QRP Level'            = $policy.Level
                        'QRP Processing Order' = $policy.ProcessingOrder
                        'QRP Enabled?'         = $policy.IsEnabled
                        'QRP Action'           = $policy.Action
                    }

                    $QueryResolutionPolicyList += $AddToList
                }
            }

        }
    }

    $QueryResolutionPolicyList
}