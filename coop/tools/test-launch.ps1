# Dev test: two Jak 2 windows (host 8111 left, guest 8112 right) for the local co-op test.
Get-Process gk -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 1
Set-Location D:\REA\jak2mp\install
foreach ($p in 8111, 8112) {
  Start-Process -FilePath .\gk.exe -ArgumentList "--socketport", $p, "--game", "jak2", "--", "-boot", "-fakeiso" -RedirectStandardOutput "D:\REA\jak2mp\gk-$p.log"
}
Start-Sleep 6
Add-Type @"
using System; using System.Runtime.InteropServices;
public class W2 { [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h,int x,int y,int w,int hh,bool r); }
"@
Add-Type -AssemblyName System.Windows.Forms
$scr = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$half = [int]($scr.Width / 2); $hgt = [int]($half * 9 / 16) + 40
foreach ($c in Get-NetTCPConnection -LocalPort 8111, 8112 -State Listen -ErrorAction SilentlyContinue) {
  $proc = Get-Process -Id $c.OwningProcess
  $x = $scr.Left + ([int]$c.LocalPort - 8111) * $half
  [W2]::MoveWindow($proc.MainWindowHandle, $x, $scr.Top, $half, $hgt, $true) | Out-Null
}
"launched side by side"
