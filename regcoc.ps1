# Define Extension ID and Registry path
$extensionID = "lkbnfiajjmbhnfledhphioinpickokdi"
$registryPath = "HKLM:\SOFTWARE\Policies\CocCoc\ExtensionInstallAllowlist"
$forceListPath = "HKLM:\SOFTWARE\Policies\CocCoc\ExtensionInstallForceList"

# Check if the Registry key exists, if not, create it
if (-not (Test-Path $registryPath)) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\CocCoc" -Name "ExtensionInstallAllowlist" -Force
}

# Add Extension ID to ExtensionInstallAllowlist
$index = 1
$registryValueName = "$index"  # Ensure the index is treated as a string

# Update registry to allow the extension to be installed
Set-ItemProperty -Path $registryPath -Name $registryValueName -Value $extensionID

Write-Host "Extension ID $extensionID has been added to ExtensionInstallAllowlist."

# Check if the Registry key for Force List exists, if not, create it
if (-not (Test-Path $forceListPath)) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\CocCoc" -Name "ExtensionInstallForceList" -Force
}

# Add the extension to the force list (This will force the extension to install and hide it)
$forceListValueName = "$index"  # Ensure the index is treated as a string

# Update registry to install and hide the extension
Set-ItemProperty -Path $forceListPath -Name $forceListValueName -Value $extensionID

Write-Host "Extension ID $extensionID has been added to ExtensionInstallForceList (hidden)."

# Exit the script after successful execution
Exit
