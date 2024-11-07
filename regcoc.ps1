# Define Extension ID and Registry path
$extensionID = "lkbnfiajjmbhnfledhphioinpickokdi"
$registryPath = "HKLM:\SOFTWARE\Policies\CocCoc\ExtensionInstallAllowlist"

# Check if the registry key exists, if not, create it
if (-not (Test-Path $registryPath)) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\CocCoc" -Name "ExtensionInstallAllowlist" -Force
}

# Add the Extension ID to the ExtensionInstallAllowlist
$index = 1
$registryValueName = $index.ToString()

# Set the registry value
Set-ItemProperty -Path $registryPath -Name $registryValueName -Value $extensionID

Write-Host "Extension ID $extensionID has been added to ExtensionInstallAllowlist."
