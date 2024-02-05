# Set Execution Policy
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force

# Define logging path in the current user's home directory
$logPath = Join-Path $HOME -ChildPath "printerInstall_log.txt"
# Start transcript to log the entire PowerShell session
Start-Transcript -Path $logPath

# Path to the Excel workbook
$workbookPath = Read-Host "Enter path to excel workbook: C:\Users\Public\Workbook.xlsx, \\server\share\workbook.xlsx" 
Write-Output "User input: $workbookpath" | Out-File -Append -FilePath $logPath

# Worksheet names in the Excel workbook
$refPoolSheet = "RefPool"
$printDriverMapSheet = "PrintDriverMap"

# Import ImportExcel module
Import-Module ImportExcel

# Read RefPool and PrintDriverMap from Excel
$refPool = Import-Excel -Path $workbookPath -WorksheetName $refPoolSheet
$printDriverMap = Import-Excel -Path $workbookPath -WorksheetName $printDriverMapSheet

# Define regular expression patterns for HTML elements (Printer Names)
$TR_TB_ELEMENT = '<tr>\s*<td>Name:<\/td>\s*<td>(.*?)<\/td>\s*<\/tr>'
$CLASS_DN_ELEMENT = '<p class="device-name" id="P1">(.*?)<\/p>'
$TITLE_ELEMENT = '<title>(.*?)<\/title>'

# Display the list of installed printers
Write-Host "Here's a list of printers that are currently installed!"
Get-Printer | Select-Object Name, PortName, DriverName | Format-Table -AutoSize

# Prompt user for IPs
$printerIPs = @(Read-Host "Enter printer IPs (separated by commas)").Split(',')
# Log user input
Write-Output "User input: $printerIPs" | Out-File -Append -FilePath $logPath

# Adds SSL/TLS cert exception
Add-Type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Process printers based on IPs
$outputArray = foreach ($ip in $printerIPs) {
    $url = "https://$ip"
    $webRequest = Invoke-WebRequest -Uri $url -ErrorAction SilentlyContinue

    # If the initial request fails, try additional paths
    if (!$webRequest) {
        # Additional paths to try
        $additionalPaths = @("/main.html", "/printer.html")

        foreach ($path in $additionalPaths) {
            $urlWithAdditionalPath = "https://$ip$path"
            $webRequest = Invoke-WebRequest -Uri $urlWithAdditionalPath -ErrorAction SilentlyContinue

            if ($webRequest) {
                break  # Break if successful
            }
        }
    }

    if (!$webRequest) {
        Write-Host "Unable to reach printer at IP $ip. Tried paths: $($additionalPaths -join ', '). Skipping."
        continue
    }

    $htmlContent = $webRequest.Content

    # Combined regular expression patterns
    $combinedPattern = "$TR_TB_ELEMENT|$CLASS_DN_ELEMENT|$TITLE_ELEMENT"

    # Search for all patterns in the HTML content
    $allMatches = $htmlContent | Select-String -Pattern $combinedPattern -AllMatches

# Iterate over all matches
foreach ($match in $allMatches.Matches) {
    $driverMapping = $printDriverMap | Where-Object { $_.ExpectedOutput -eq $match.Groups[1].Value }

    if ($driverMapping) {
        # Search for the corresponding entry in "RefPool" worksheet
        $refPoolEntry = $refPool | Where-Object { $_.PossibleIPs -eq $ip }

        if ($refPoolEntry) {
            [PSCustomObject]@{
                "IP"         = $ip
                "DriverName" = $driverMapping.DriverName
                "DriverPath" = $driverMapping.DriverPath
                "DisplayName"= $driverMapping.DisplayName
                "RoomNumber" = $refPoolEntry.RoomNumber
            }
        }
    }
}
}

# Install printers 
foreach ($printerInfo in $outputArray) {
    $driverName = $printerInfo.DriverName
    $driverPath = $printerInfo.DriverPath
    $displayName = $printerInfo.DisplayName
    $roomNumber = $printerInfo.RoomNumber

    # Combine DisplayName and RoomNumber for the new printer name
    $newPrinterName = "$displayName $roomNumber"

    pnputil /add-driver $driverPath 
    add-printerdriver -Name $driverName -infpath $driverPath -ErrorAction SilentlyContinue
    add-printerport -name $printerInfo.IP -PrinterHostAddress $printerInfo.IP -ErrorAction SilentlyContinue
    add-printer -drivername $driverName -name $newPrinterName -portname $printerInfo.IP -ErrorAction SilentlyContinue
}

# Display the updated list of installed printers
Write-Host "Here's the updated list of installed printers!"
Get-Printer | Select-Object Name, PortName, DriverName | Format-Table -AutoSize
Write-Host ""

# Prompt user for uninstallation
$uninstallChoice = Read-Host "Do you want to uninstall printers? (Y/N)"
if ($uninstallChoice -eq 'Y' -or $uninstallChoice -eq 'y') {
    # Prompt user for printer IPs to uninstall
    $printersToUninstall = @(Read-Host "Enter printer IPs to uninstall (separated by commas)").Split(',')

    foreach ($ip in $printersToUninstall) {
        # Get the current printer name and port based on the provided IP
        $printer = Get-Printer | Where-Object { $_.PortName -eq $ip }

        if ($null -ne $printer) {
            $printerName = $printer.Name
            $portName = $printer.PortName
            Start-Sleep -Seconds 8

            # PowerShell syntax for uninstallation
            Remove-Printer -Name $printerName -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 8
            Remove-PrinterPort -Name $portName -ErrorAction SilentlyContinue
            Start-sleep -Seconds 8

            Write-Host "Printer $printerName and its port $portName uninstalled."
        }
        else {
            Write-Host "No printer found for IP $ip. Skipping uninstallation."
        }
    }
}
else {
    Write-Host "Printers Installed Successfully!"
}

# Stop transcript
Stop-Transcript
