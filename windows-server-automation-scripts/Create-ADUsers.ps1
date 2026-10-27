# Import the Active Directory module required for AD cmdlets
Import-Module ActiveDirectory

# Define the path to the CSV file (Assumes it is located in the current directory)
$csvPath = ".\employees.csv"

# Define the domain and the base Organizational Unit (OU)
$domainPath = "DC=akademi,DC=lab"
$baseOUName = "Employees"
$baseOUPath = "OU=$baseOUName,$domainPath"

Write-Host "Starting the bulk user import process..." -ForegroundColor Cyan

# NEW STAGE: Check and Create the Base 'Employees' OU if it doesn't exist
if (!(Get-ADOrganizationalUnit -Filter "Name -eq '$baseOUName'" -SearchBase $domainPath -ErrorAction SilentlyContinue)) {
    Write-Host "Base OU Not Found: Creating the '$baseOUName' root organizational unit..." -ForegroundColor Yellow
    New-ADOrganizationalUnit -Name $baseOUName -Path $domainPath
}

# Read the data from the CSV file
$users = Import-Csv -Path $csvPath -Delimiter ","

foreach ($user in $users) {
    # Map variables directly from the CSV column headers
    $FirstName = $user.FirstName
    $LastName = $user.LastName
    $Username = $user.Username
    $Department = $user.Department
    $JobTitle = $user.JobTitle
    $Password = $user.Password
    
    # Generate the full Display Name
    $FullName = "$FirstName $LastName"
    
    # Define the target Organizational Unit (OU) path for the specific department
    $targetOU = "OU=$Department,$baseOUPath"

    # Stage 1: Create the Department OU if it does not already exist
    if (!(Get-ADOrganizationalUnit -Filter "Name -eq '$Department'" -SearchBase $baseOUPath -ErrorAction SilentlyContinue)) {
        Write-Host "Department OU Not Found: Creating the '$Department' organizational unit..." -ForegroundColor Yellow
        New-ADOrganizationalUnit -Name $Department -Path $baseOUPath
    }

    # Stage 2: Check if the user already exists in the Active Directory environment
    if (Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue) {
        Write-Host "ERROR: User '$Username' already exists in the domain! Skipping." -ForegroundColor Red
    }
    else {
        # Convert the plaintext password from the CSV into a SecureString format
        $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
        
        # Stage 3: Create the new Active Directory user
        try {
            New-ADUser -SamAccountName $Username `
                       -UserPrincipalName "$Username@akademi.lab" `
                       -Name $FullName `
                       -GivenName $FirstName `
                       -Surname $LastName `
                       -Enabled $true `
                       -DisplayName $FullName `
                       -Path $targetOU `
                       -Title $JobTitle `
                       -Department $Department `
                       -AccountPassword $SecurePassword `
                       -ErrorAction Stop
                       
            Write-Host "SUCCESS: Account for '$FullName' has been provisioned in the $Department department." -ForegroundColor Green
        }
        catch {
            Write-Host "FAILED: Could not create user '$FullName'. Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "User provisioning process completed!" -ForegroundColor Cyan