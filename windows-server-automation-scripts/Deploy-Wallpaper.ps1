# Import the Group Policy module
Import-Module GroupPolicy

# Define variables for the GPO
$GpoName = "Corporate_Wallpaper_Policy"
$TargetOUPath = "OU=Employees,DC=akademi,DC=lab"

# Using the existing dedicated network share path
$WallpaperNetworkPath = "\\192.168.10.10\Common\logo.jpg"

Write-Host "Starting Corporate Wallpaper GPO deployment using existing share..." -ForegroundColor Cyan

try {
    # Check if the GPO already exists, create if it doesn't
    $existingGPO = Get-GPO -Name $GpoName -ErrorAction SilentlyContinue
    if (!$existingGPO) {
        Write-Host "Creating new GPO: '$GpoName'..." -ForegroundColor Yellow
        New-GPO -Name $GpoName | Out-Null
    }
    else {
        Write-Host "GPO '$GpoName' already exists. Updating settings..." -ForegroundColor Yellow
    }

    # Set the Wallpaper path via Registry Key (Administrative Templates)
    # HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System -> Wallpaper
    Set-GPRegistryValue -Name $GpoName `
                        -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
                        -ValueName "Wallpaper" `
                        -Type String `
                        -Value $WallpaperNetworkPath | Out-Null

    # Set the Wallpaper Style (2 = Stretch, 10 = Fill, 0 = Center, 4 = Fit)
    Set-GPRegistryValue -Name $GpoName `
                        -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
                        -ValueName "WallpaperStyle" `
                        -Type String `
                        -Value "2" | Out-Null

    Write-Host "Wallpaper settings successfully written to the GPO pointing to the Common share." -ForegroundColor Green

    # Link the GPO to the target OU
    $GPInheritance = Get-GPInheritance -Target $TargetOUPath -ErrorAction Stop
    $ExistingLinks = $GPInheritance.GpoLinks | Where-Object { $_.DisplayName -eq $GpoName }

    if ($ExistingLinks) {
        Write-Host "INFO: GPO '$GpoName' is already linked to '$TargetOUPath'." -ForegroundColor Yellow
    }
    else {
        New-GPLink -Name $GpoName -Target $TargetOUPath -LinkEnabled Yes -ErrorAction Stop | Out-Null
        Write-Host "SUCCESS: GPO linked to '$TargetOUPath'." -ForegroundColor Green
    }
}
catch {
    Write-Host "FAILED: An error occurred. Details: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Wallpaper deployment process completed!" -ForegroundColor Cyan