$ErrorActionPreference = 'Stop';

if ([Version] (Get-CimInstance Win32_OperatingSystem).Version -lt [version] "10.0.17763") {
    Write-Error "SQL Server 2025 requires a minimum of Windows 10 or Windows Server 2019"
}

$packageName= $env:ChocolateyPackageName
$url64      = 'https://download.microsoft.com/download/dea8c210-c44a-4a9d-9d80-0c81578860c5/ENU/SQLEXPR_x64_ENU.exe'
$checksum   = '74AA90C11202A5524E769B9BC22531BAEF22D91E9B2D2E8C3CB99E89A65C5297'
$silentArgs = "/IACCEPTSQLSERVERLICENSETERMS /Q /ACTION=install /INSTANCEID=SQLEXPRESS /INSTANCENAME=SQLEXPRESS /UPDATEENABLED=FALSE"

$tempDir = Join-Path (Get-Item $env:TEMP).FullName "$packageName"
if ($null -ne $env:packageVersion) {$tempDir = Join-Path $tempDir "$env:packageVersion"; }

if (![System.IO.Directory]::Exists($tempDir)) { [System.IO.Directory]::CreateDirectory($tempDir) | Out-Null }
$fileFullPath = "$tempDir\SQLEXPR.exe"

Get-ChocolateyWebFile -PackageName $packageName -FileFullPath $fileFullPath -Url64bit $url64 -Checksum $checksum -ChecksumType 'sha256'

Write-Host "Extracting..."
$extractPath = "$tempDir\SQLEXPR"
Start-Process "$fileFullPath" "/Q /x:`"$extractPath`"" -Wait

Write-Host "Installing..."
$setupPath = "$extractPath\setup.exe"
Install-ChocolateyInstallPackage "$packageName" "EXE" "$silentArgs" "$setupPath" -validExitCodes @(0, 3010, 1116)

Write-Host "Removing extracted files..."
Remove-Item -Recurse "$extractPath"
