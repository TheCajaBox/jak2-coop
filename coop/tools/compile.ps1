# Re-sync GOAL sources into the install folder and recompile Jak 2 (no decompile).
robocopy D:\REA\jak2mp\jak-project\goal_src D:\REA\jak2mp\install\data\goal_src /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
Set-Location D:\REA\jak2mp\install
& .\extractor.exe -g jak2 -c -f "D:\REA\jak2mp\install\data\iso_data\jak2" *> D:\REA\jak2mp\compile.log
"exit=$LASTEXITCODE"
$log = (Get-Content D:\REA\jak2mp\compile.log) -replace "\x1b\[[0-9;]*m", ""
$i = ($log | Select-String -Pattern "Compilation Error" | Select-Object -First 1).LineNumber
if ($i) { $log[($i-1)..($i+30)] } else { $log | Select-Object -Last 5 }
