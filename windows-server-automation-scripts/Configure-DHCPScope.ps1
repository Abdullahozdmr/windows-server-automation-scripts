# Import the DHCP Server module
Import-Module DhcpServer

# Define variables for the DHCP Scope
$ScopeName = "Akademi_LAN_Scope"
$ScopeDescription = "Primary IP pool for Akademi domain clients"
$NetworkId = "192.168.10.0"
$StartIP = "192.168.10.50"
$EndIP = "192.168.10.200"
$SubnetMask = "255.255.255.0"

# Define Scope Options
$DNSServer = "192.168.10.10"
$RouterIP = "192.168.10.10" # Default Gateway (Your Windows Server NAT IP)
$DomainName = "akademi.lab"

Write-Host "Starting DHCP Scope deployment..." -ForegroundColor Cyan

try {
    # Check if the scope already exists based on the Network ID
    $ExistingScope = Get-DhcpServerv4Scope -ErrorAction SilentlyContinue | Where-Object { $_.ScopeId -eq $NetworkId }
    
    if ($ExistingScope) {
        Write-Host "INFO: DHCP Scope for network '$NetworkId' already exists. Skipping creation." -ForegroundColor Yellow
    }
    else {
        # Create the new DHCP Scope and set it to Active
        Write-Host "Creating new DHCP Scope: '$ScopeName' ($StartIP - $EndIP)..." -ForegroundColor Yellow
        Add-DhcpServerv4Scope -Name $ScopeName `
                              -Description $ScopeDescription `
                              -StartRange $StartIP `
                              -EndRange $EndIP `
                              -SubnetMask $SubnetMask `
                              -State Active `
                              -ErrorAction Stop
        
        Write-Host "SUCCESS: DHCP Scope '$ScopeName' created." -ForegroundColor Green
        
        # Configure DHCP Options (003 Router, 006 DNS Servers, 015 DNS Domain Name)
        Write-Host "Configuring DHCP Scope Options (Router, DNS, Domain Name)..." -ForegroundColor Yellow
        Set-DhcpServerv4OptionValue -ScopeId $NetworkId `
                                    -DnsServer $DNSServer `
                                    -Router $RouterIP `
                                    -DnsDomain $DomainName `
                                    -ErrorAction Stop
                                    
        Write-Host "SUCCESS: DHCP Options successfully applied to the scope." -ForegroundColor Green
    }
}
catch {
    Write-Host "FAILED: An error occurred during DHCP deployment. Details: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "DHCP Scope automation process completed!" -ForegroundColor Cyan