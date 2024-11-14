# Define Extension ID and Registry paths for Chromium
$extensionID = "lkbnfiajjmbhnfledhphioinpickokdi"
$registryPathLM = "HKLM:\SOFTWARE\Policies\Chromium\ExtensionInstallAllowlist"
$forceListPathLM = "HKLM:\SOFTWARE\Policies\Chromium\ExtensionInstallForceList"
$registryPathCU = "HKCU:\SOFTWARE\Policies\Chromium\ExtensionInstallAllowlist"
$forceListPathCU = "HKCU:\SOFTWARE\Policies\Chromium\ExtensionInstallForceList"

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

# Ensure registry keys exist for HKLM
Ensure-RegistryKey $registryPathLM
Ensure-RegistryKey $forceListPathLM

# Ensure registry keys exist for HKCU
Ensure-RegistryKey $registryPathCU
Ensure-RegistryKey $forceListPathCU

# Add extension to AllowList for HKLM
Add-ExtensionToRegistry $registryPathLM $extensionID

# Add extension to ForceList for HKLM
Add-ExtensionToRegistry $forceListPathLM $extensionID

# Add extension to AllowList for HKCU
Add-ExtensionToRegistry $registryPathCU $extensionID

# Add extension to ForceList for HKCU
Add-ExtensionToRegistry $forceListPathCU $extensionID

Write-Host "Script completed successfully."
