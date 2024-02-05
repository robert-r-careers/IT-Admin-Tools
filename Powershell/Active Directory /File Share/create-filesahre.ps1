# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force

# Start logging
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFilePath = "C:\Path\ScriptLog_$timestamp.txt"
Start-Transcript -Path $logFilePath -Append

# Prompt admin for information
$sharedrive = Read-Host -Prompt "Enter Share Drive Folder Name (enter_for_spaces)"
$sharedriveowner = Read-Host -Prompt "Enter Owner Name"
$descriptionfornotes = Read-Host -Prompt "Enter Descriptive notes for AD Security group, description field"
$aduc_ou = "Enter AD security group OU path: OU=Groups,OU=YOUR_DOMAIN,DC=auth,DC=your_domain,DC=local"
# Prompt admin for credentials
$cred = Get-Credential -Message "Enter Credentials for AD Operations"

# Prompts for Server Name and Folder Path Prefix
$computerName = Read-Host -Prompt "Enter Share Drive Server Name for PSSession"
$folderPathPrefix = Read-Host -Prompt "Enter Folder Path Prefix if youwant to create a subfolder in \\server\apps\, you will enter:  \apps\"

# Define naming conventions and paths
$Splat = @{
    share_ro = "$sharedrive-ro"
    share_rw = "$sharedrive-rw"
}

$idescriptionname = "Owner: $sharedriveowner"

# Create AD security groups and set properties
foreach ($group in $Splat.Values) {
    $groupPath = Join-Path $aduc_ou $group
    New-ADGroup -Name $group -GroupCategory Security -Path $groupPath -GroupScope Global -Description $idescriptionname -Credential $cred
    Set-ADGroup $group -ManagedBy (Get-AdUser -Filter {Name -like $sharedriveowner}) -Replace @{info = $descriptionfornotes} -Credential $cred
}

# Create a PSSession
$s = New-PSSession -ComputerName $computerName

# Invoke command within the PSSession
Invoke-Command -Session $s -ScriptBlock {
    $folderPath = Join-Path $using:folderPathPrefix $using:sharedrive
    $acl = Get-Acl $folderPath

    # Apply read-only rule to share_ro
    $readRule = New-Object System.Security.AccessControl.FileSystemAccessRule($using:Splat['share_ro'], "Read", "Allow")
    $acl.AddAccessRule($readRule)

    # Apply read and write rule to share_rw
    $readWriteRule = New-Object System.Security.AccessControl.FileSystemAccessRule($using:Splat['share_rw'], "FullControl", "Allow")
    $acl.AddAccessRule($readWriteRule)

    Set-Acl -Path $folderPath -AclObject $acl

    Get-WinEvent -LogName $using:Splat.share_ro
    Get-WinEvent -LogName $using:Splat.share_rw

    Exit-PSSession
}

# Stop logging
Stop-Transcript
