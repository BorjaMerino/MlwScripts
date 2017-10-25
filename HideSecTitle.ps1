Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class Win32 {
  [DllImport("User32.dll", EntryPoint="SetWindowText")]
  public static extern int SetWindowText(IntPtr hWnd, string strTitle);
}
"@

$callback = {
    $secproc=  "tcpview.exe","procexp.exe","procexp64.exe", "wireshark.exe","Fiddler.exe","regmon.exe","procmon.exe",
               "apimonitor.exe","immunitydebugger.exe","idag64.exe","ollydbg.exe","windbg.exe","idaq.exe","idaq64.exe",
               "x32dbg.exe","x64dbg.exe","ProcessHacker.exe","ResourceHacker.exe","depends.exe","pestudio.exe","PE-bear.exe",
	           "pexplorer.exe","CFF Explorer.exe","PEview.exe","VirtualBox.exe","vmmap.exe","HxD.exe"
       
    $process = $Event.SourceEventArgs.NewEvent            
    $info = 'New Process! Name="{0}", PID ={1}, PPID={2}, Time={3}'            
    $output = $info -f $process.ProcessName, $process.ProcessId, $process.ParentProcessId, $event.TimeGenerated 
  
    if ($secproc -contains $process.ProcessName) {
        # Generate random string 
        $Chars = [Char[]]"1234567890qazxswedcvfrtgbnhyujmkiolpQAZXSWEDCVFRTGBNHYUJMKIOLP"
        $prefix = ($Chars | Get-Random -Count 10) -join ""
    	Start-Sleep -s 1
	    # Useful code: https://hinchley.net/articles/changing-window-titles-using-powershell/
	    Get-Process -id $process.ProcessId | ? {$_.mainWindowTitle -and $_.mainWindowTitle -notlike "$($prefix)*"} | %{
        [Win32]::SetWindowText($_.mainWindowHandle, "$prefix")
  		}
        Write-host -ForegroundColor Green "[+]" $output  "New windows Title=$prefix"
   	}
    else {
        Write-host -ForegroundColor Red $output
    }
}            
Register-WmiEvent -Query "SELECT * FROM Win32_ProcessStartTrace" -SourceIdentifier ProcessStart -Action $callback  | out-null

