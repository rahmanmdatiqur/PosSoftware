function Get-PosHash {
    param([string]$password)
    $saltBytes = New-Object byte[] 16
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($saltBytes)
    $salt = [Convert]::ToBase64String($saltBytes)
    $combined = [System.Text.Encoding]::UTF8.GetBytes($password + $salt + "PosSecSaltKey2026")
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $hashBytes = $sha.ComputeHash($combined)
    $hash = [Convert]::ToBase64String($hashBytes)
    return @{ Hash = $hash; Salt = $salt }
}

$admin   = Get-PosHash "Admin@123"
$cashier = Get-PosHash "Cashier@123"
$manager = Get-PosHash "Manager@123"

Write-Host "ADMIN_HASH=$($admin.Hash)"
Write-Host "ADMIN_SALT=$($admin.Salt)"
Write-Host "CASHIER_HASH=$($cashier.Hash)"
Write-Host "CASHIER_SALT=$($cashier.Salt)"
Write-Host "MANAGER_HASH=$($manager.Hash)"
Write-Host "MANAGER_SALT=$($manager.Salt)"
