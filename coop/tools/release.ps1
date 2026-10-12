# Public release zip: same as stage.ps1's package, but with the generic (no personal names) guides.
param([string]$version = "v0.1")
$ErrorActionPreference = 'Stop'
$install = 'D:\REA\jak2mp\install'
$zip = "D:\REA\jak2mp\jak2-coop-$version.zip"
if (Test-Path $zip) { Remove-Item $zip }
$tmp = Join-Path $env:TEMP 'jak2-coop-release'
if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
robocopy $install $tmp /MIR /XD "$install\data\iso_data" "$install\data\out" "$install\data\decompiler_out" "$install\data\log" /XF imgui.ini /NFL /NDL /NJH /NJS /NP | Out-Null
New-Item -ItemType Directory -Force "$tmp\data\iso_data\jak2" | Out-Null
Copy-Item D:\REA\jak2mp\package\* $tmp -Force
Copy-Item D:\REA\jak2mp\package-public\* $tmp -Force   # generic LEEME/README override the personal ones
robocopy D:\REA\jak2mp\host "$tmp\host" /E /XF players.txt relay.log /NFL /NDL /NJH /NJS /NP | Out-Null
Copy-Item D:\REA\jak2mp\package-host\players.txt "$tmp\host\players-ejemplo.txt" -Force
Compress-Archive -Path "$tmp\*" -DestinationPath $zip
Remove-Item -Recurse -Force $tmp
"release zip: $zip ({0:N0} MB)" -f ((Get-Item $zip).Length / 1MB)
