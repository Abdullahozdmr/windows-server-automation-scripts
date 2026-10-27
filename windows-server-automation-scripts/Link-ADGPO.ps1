# Import the Group Policy module required for GPO cmdlets
Import-Module GroupPolicy

# Define the GPO name and the target Organizational Unit (OU) path
$GpoName = "Personel_Limittations"
$TargetOUPath = "OU=Employees,DC=akademi,DC=lab"

Write-Host "Starting the GPO linking process..." -ForegroundColor Cyan

try {
    # Retrieve existing GPO links on the target OU to prevent duplicates
    $GPInheritance = Get-GPInheritance -Target $TargetOUPath -ErrorAction Stop
    $ExistingLinks = $GPInheritance.GpoLinks | Where-Object { $_.DisplayName -eq $GpoName }

    if ($ExistingLinks) {
        Write-Host "INFO: GPO '$GpoName' is already linked to the target OU. Skipping operation." -ForegroundColor Yellow
    }
    else {
        # Link the GPO to the target Organizational Unit
        New-GPLink -Name $GpoName -Target $TargetOUPath -LinkEnabled Yes -ErrorAction Stop
        Write-Host "SUCCESS: GPO '$GpoName' has been successfully linked to '$TargetOUPath'." -ForegroundColor Green
    }
}
catch {
    Write-Host "FAILED: An error occurred while linking the GPO. Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "GPO deployment process completed!" -ForegroundColor Cyan