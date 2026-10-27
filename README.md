# Windows Server Automation Scripts

This repository contains a collection of PowerShell scripts developed during my System, Network, and Cloud technologies internship. These automation scripts are designed to streamline core infrastructure tasks on Windows Server environments, including Active Directory bulk user provisioning, DHCP scope configuration, and Group Policy Object (GPO) deployment.

## 📂 Repository Structure

* **`Configure-DHCPScope.ps1`**: Automates the creation of a new DHCP scope and configures essential options such as Default Gateway, DNS Servers, and Domain Name.
* **`Create-ADUsers.ps1`**: Bulk provisions Active Directory users by reading data from a CSV file. It automatically handles OU (Organizational Unit) creation based on departments and assigns secure passwords.
* **`Deploy-Wallpaper.ps1`**: Creates and links a Group Policy Object (GPO) to deploy a standard corporate wallpaper to domain computers via a network share.
* **`Link-ADGPO.ps1`**: Links an existing Group Policy Object to a specific Organizational Unit to enforce policies on targeted users or computers.
* **`employees.csv`**: Sample data file containing user attributes (FirstName, LastName, Username, Department, JobTitle, Password) used by the AD provisioning script.
* **`employees.csv.xlsx`**: The original Excel workbook version of the employee data.

## 🚀 Usage

1. Clone the repository to your Windows Server environment:
   ```bash
   git clone [https://github.com/yourusername/windows-server-automation-scripts.git](https://github.com/yourusername/windows-server-automation-scripts.git)
