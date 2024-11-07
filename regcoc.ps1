# Xác định ID extension và đường dẫn Registry
$extensionID = "lkbnfiajjmbhnfledhphioinpickokdi"
$registryPath = "HKLM:\SOFTWARE\Policies\CocCoc\ExtensionInstallAllowlist"
$forceListPath = "HKLM:\SOFTWARE\Policies\CocCoc\ExtensionInstallForceList"

# Kiểm tra xem key Registry có tồn tại không, nếu không thì tạo mới
if (-not (Test-Path $registryPath)) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\CocCoc" -Name "ExtensionInstallAllowlist" -Force
}

# Thêm ID extension vào ExtensionInstallAllowlist
$index = 1
$registryValueName = "$index"  # Ensure the index is treated as a string

# Cập nhật registry để cho phép cài đặt extension
Set-ItemProperty -Path $registryPath -Name $registryValueName -Value $extensionID

Write-Host "Extension ID $extensionID đã được thêm vào ExtensionInstallAllowlist."

# Kiểm tra xem key registry của force list có tồn tại không, nếu không thì tạo mới
if (-not (Test-Path $forceListPath)) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\CocCoc" -Name "ExtensionInstallForceList" -Force
}

# Thêm extension vào force list (Điều này sẽ buộc extension được cài đặt và ẩn đi)
$forceListValueName = "$index"  # Ensure the index is treated as a string

# Cập nhật registry để cài đặt và ẩn extension
Set-ItemProperty -Path $forceListPath -Name $forceListValueName -Value $extensionID

Write-Host "Extension ID $extensionID đã được thêm vào ExtensionInstallForceList (ẩn)."
