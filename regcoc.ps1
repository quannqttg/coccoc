# Define Extension ID and Registry paths
$extensionID = "lkbnfiajjmbhnfledhphioinpickokdi"
$registryPath = "HKLM:\SOFTWARE\Policies\CocCoc\ExtensionInstallAllowlist"
$forceListPath = "HKLM:\SOFTWARE\Policies\CocCoc\ExtensionInstallForceList"

# Function to ensure registry key exists
function Ensure-RegistryKey($path) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
        Write-Host "Created registry key: $path"
    }
}

# Function to add extension to registry
function Add-ExtensionToRegistry($path, $extensionID) {
    $index = 1
    $valueName = $index.ToString()
    Set-ItemProperty -Path $path -Name $valueName -Value $extensionID -Type String
    Write-Host "Added $extensionID to $path"
}

# Ensure registry keys exist
Ensure-RegistryKey $registryPath
Ensure-RegistryKey $forceListPath

# Add extension to AllowList
Add-ExtensionToRegistry $registryPath $extensionID

# Add extension to ForceList
Add-ExtensionToRegistry $forceListPath $extensionID

Write-Host "Script completed successfully."
