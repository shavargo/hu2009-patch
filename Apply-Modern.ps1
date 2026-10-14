param(
	[Parameter(Mandatory = $true)]
	[string]$GameDir
)

$ErrorActionPreference = 'Stop'
$GameDir = (Resolve-Path -LiteralPath $GameDir).Path

function Enable-LargeAddressAware {
	param([string]$Path)
	$bytes = [System.IO.File]::ReadAllBytes($Path)
	if ($bytes.Length -lt 0x40 -or $bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
		throw "$Path is not an executable"
	}
	$pe = [BitConverter]::ToInt32($bytes, 0x3C)
	$machine = [BitConverter]::ToUInt16($bytes, $pe + 4)
	$magic = [BitConverter]::ToUInt16($bytes, $pe + 24)
	if ($machine -ne 0x14C -or $magic -ne 0x10B) {
		throw "$Path is not a 32-bit executable"
	}
	$chars = [BitConverter]::ToUInt16($bytes, $pe + 22)
	if (($chars -band 0x20) -ne 0) {
		Write-Output "already 4 GB: $Path"
		return
	}
	$chars = $chars -bor 0x20
	$bytes[$pe + 22] = [byte]($chars -band 0xFF)
	$bytes[$pe + 23] = [byte](($chars -shr 8) -band 0xFF)
	[System.IO.File]::WriteAllBytes($Path, $bytes)
	Write-Output "enabled 4 GB: $Path"
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$backup = Join-Path $GameDir 'modern-backup'
New-Item -ItemType Directory -Force -Path $backup | Out-Null
foreach ($name in @('hu2009.exe', 'prism3d.exe', 'specs.settings')) {
	$source = Join-Path $GameDir $name
	if (-not (Test-Path -LiteralPath $source)) {
		throw "Missing $source"
	}
	$saved = Join-Path $backup $name
	if (-not (Test-Path -LiteralPath $saved)) {
		Copy-Item -LiteralPath $source -Destination $saved
		Write-Output "backed up: $saved"
	}
}

Copy-Item -LiteralPath (Join-Path $here 'specs.settings') -Destination (Join-Path $GameDir 'specs.settings') -Force
Copy-Item -LiteralPath (Join-Path $here 'READ-ME-MOD.txt') -Destination (Join-Path $GameDir 'READ-ME-MOD.txt') -Force
Write-Output "installed specs.settings"

Enable-LargeAddressAware (Join-Path $GameDir 'hu2009.exe')
Enable-LargeAddressAware (Join-Path $GameDir 'prism3d.exe')

$layers = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers'
$gpu = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'
if (-not (Test-Path $layers)) { New-Item -Path $layers -Force | Out-Null }
if (-not (Test-Path $gpu)) { New-Item -Path $gpu -Force | Out-Null }
foreach ($name in @('hu2009.exe', 'prism3d.exe')) {
	$full = Join-Path $GameDir $name
	New-ItemProperty -Path $layers -Name $full -Value '~ DISABLEDXMAXIMIZEDWINDOWEDMODE' -PropertyType String -Force | Out-Null
	New-ItemProperty -Path $gpu -Name $full -Value 'GpuPreference=2;' -PropertyType String -Force | Out-Null
	Write-Output "windows settings: $full"
}

$valu = 'HKCU:\Software\ValuSoft\Hunting Unlimited 2009'
if (Test-Path $valu) {
	New-ItemProperty -Path $valu -Name 'TargetPath' -Value (Join-Path $GameDir 'hu2009.exe') -PropertyType String -Force | Out-Null
	Write-Output "TargetPath updated"
}

Write-Output "done"
