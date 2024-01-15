# Set Execution Policy
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force

# Path to the Excel workbook
$workbookPath = "$env:USERPROFILE\Desktop\install-printers\Workbook.xlsx"

# Worksheet names in the Excel workbook
$referencePoolSheet = "ReferencePool"
$printerDriverMappingsSheet = "PrinterDriverMappings"

# Import ImportExcel module
Import-Module ImportExcel

# Read ReferencePool and PrinterDriverMappings from Excel
$referencePool = Import-Excel -Path $workbookPath -WorksheetName $referencePoolSheet
$printerDriverMappings = Import-Excel -Path $workbookPath -WorksheetName $printerDriverMappingsSheet

# Define regular expression patterns for HTML elements (Printer Names)
$TR_TB_ELEMENT = '<tr>\s*<td>Name:<\/td>\s*<td>(.*?)<\/td>\s*<\/tr>'
$CLASS_DN_ELEMENT = '<p class="device-name" id="P1">(.*?)<\/p>'
$TITLE_ELEMENT = '<title>(.*?)<\/title>'
# $NEW_REGEX_NAME = 

# Define logging path in the current user's home directory
$logPath = Join-Path $HOME -ChildPath "printerInstall_log.txt"
# Start transcript to log the entire PowerShell session
Start-Transcript -Path $logPath

# Display the list of installed printers
Write-Host "Here's a list of printers that are currently installed!"
Get-Printer | Select-Object Name, PortName, DriverName | Format-Table -AutoSize

# Prompts user for IPs
$printerIP = @(Read-Host "Enter printer IPs (separated by commas)").Split(',')

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
$outputArray = foreach ($ip in $printerIP) {
    $url = "https://$ip"
    $webRequest = Invoke-WebRequest -Uri $url -ErrorAction SilentlyContinue
    if (!$webRequest) {
        continue 
    }

    $htmlContent = $webRequest.Content

    $foundValues = foreach ($match in  ($htmlContent | Select-String -Pattern $TR_TB_ELEMENT -AllMatches).Matches +
                                   ($htmlContent | Select-String -Pattern $CLASS_DN_ELEMENT -AllMatches).Matches +
                                   ($htmlContent | Select-String -Pattern $TITLE_ELEMENT -AllMatches).Matches)#+
    {                             #($htmlContent | Select-String -Pattern $NEW_REGEX_NAME -AllMatches).Matches) 
        $driverMapping = $printerDriverMappings | Where-Object { $match.Groups[1].Value -contains $_.ExpectedOutput }

        if ($driverMapping) {
            [PSCustomObject]@{
                "IP"         = $ip
                "DriverName" = $driverMapping.DriverName
                "DriverPath" = $driverMapping.DriverPath
            }
        }
    }


    $foundValues | Where-Object { $_.DriverName }
}

# Install printers 
foreach ($printerInfo in $outputArray) {
    $driverName = $printerInfo.DriverName
    $driverPath = $printerInfo.DriverPath

    pnputil /add-driver $driverPath 
    add-printerdriver -Name $driverName -infpath $driverPath -ErrorAction SilentlyContinue
    add-printerport -name $printerInfo.IP -PrinterHostAddress $printerInfo.IP -ErrorAction SilentlyContinue
    add-printer -drivername $driverName -name $driverName -portname $printerInfo.IP -ErrorAction SilentlyContinue
}

foreach ($printerInfo in $outputArray) {
    $printerName = $printerInfo.DriverName

    $referenceMatch = $referencePool | Where-Object { $_.IP -eq $printerInfo.IP }

    if ($referenceMatch) {
        $customContent = $referenceMatch.RoomNumber
        $newPrinterName = "$printerName $customContent"

        Rename-Printer -Name $printerName -NewName $newPrinterName -ErrorAction SilentlyContinue
        $printerInfo.DriverName = $newPrinterName
    }
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

        if ($printer -ne $null) {
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
