# Stages a Teamruns-style install folder (same layout as the official release zip) for the Jak 2 co-op build.
#   D:\REA\jak2mp\install        <- point the Teamruns client's game folder here
#   D:\REA\jak2mp\jak2-coop.zip  <- same thing without game files, to copy to the second PC
$ErrorActionPreference = 'Stop'
$repo    = 'D:\REA\jak2mp\jak-project'
$bin     = "$repo\out\build\Release\bin"
$install = 'D:\REA\jak2mp\install'

New-Item -ItemType Directory -Force "$install\data" | Out-Null
foreach ($exe in 'gk.exe', 'goalc.exe', 'extractor.exe') { Copy-Item "$bin\$exe" $install -Force }

# Everything the extractor/compiler needs from the source tree (mirrors the release zip's data folder)
foreach ($dir in 'decompiler\config', 'game\assets', 'game\graphics\opengl_renderer\shaders', 'goal_src', 'custom_assets') {
  robocopy "$repo\$dir" "$install\data\$dir" /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
}
New-Item -ItemType Directory -Force "$install\data\launcher", "$install\data\log", "$install\data\iso_data\jak2" | Out-Null
if (Test-Path "$repo\.github\scripts\releases\error-code-metadata.json") {
  Copy-Item "$repo\.github\scripts\releases\error-code-metadata.json" "$install\data\launcher\" -Force
}

# Distributable zip (no ISO data, no compiled output)
$zip = 'D:\REA\jak2mp\jak2-coop.zip'
if (Test-Path $zip) { Remove-Item $zip }
$tmp = Join-Path $env:TEMP 'jak2-coop-stage'
if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
robocopy $install $tmp /MIR /XD "$install\data\iso_data" "$install\data\out" "$install\data\decompiler_out" "$install\data\log" /NFL /NDL /NJH /NJS /NP | Out-Null
New-Item -ItemType Directory -Force "$tmp\data\iso_data\jak2" | Out-Null
Copy-Item D:\REA\jak2mp\package\* $tmp -Force
# host tools (anyone can host): relay + ws module, generic players.txt
robocopy D:\REA\jak2mp\host "$tmp\host" /E /XF players.txt relay.log /NFL /NDL /NJH /NJS /NP | Out-Null
Copy-Item D:\REA\jak2mp\package-host\players.txt "$tmp\host\players-ejemplo.txt" -Force
Compress-Archive -Path "$tmp\*" -DestinationPath $zip
Remove-Item -Recurse -Force $tmp
"staged: $install"
"zip:    $zip ({0:N0} MB)" -f ((Get-Item $zip).Length / 1MB)

# publish to the read-only network share (\<this PC>\Jak2-Coop) so other players can grab it
if (Test-Path 'D:\Jak2-Coop-Share') {
  Copy-Item $zip, 'D:\REA\jak2mp\package\LEEME.txt' 'D:\Jak2-Coop-Share' -Force
  Copy-Item 'D:\REA\jak2mp\site\index.html' 'D:\Jak2-Coop-Share\GUIA.html' -Force
  "shared: \\$env:COMPUTERNAME\Jak2-Coop"
}
