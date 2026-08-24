# Starts rh-backend (Spring Boot, :8080) and rh-frontend (Vite, :5173) each in their own window.
$root = $PSScriptRoot

# node/vite invoked directly (not via npm/vite .cmd shims): the OneDrive path
# contains "&", which breaks cmd.exe's argument parsing inside those shims.
Start-Process powershell -ArgumentList '-NoExit', '-Command', "cd '$root\rh-backend'; .\mvnw.cmd spring-boot:run"
Start-Process powershell -ArgumentList '-NoExit', '-Command', "cd '$root\rh-frontend'; node node_modules/vite/bin/vite.js"

Write-Host "Waiting for backend (http://localhost:8080) and frontend (http://localhost:5173) to come up..."

function Wait-Port($url, $name, $timeoutSec = 90) {
    $deadline = (Get-Date).AddSeconds($timeoutSec)
    while ((Get-Date) -lt $deadline) {
        try {
            $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3
            if ($r.StatusCode -lt 500) { Write-Host "$name is up ($url)"; return $true }
        } catch {}
        Start-Sleep -Seconds 2
    }
    Write-Host "$name did NOT come up within $timeoutSec s ($url)"
    return $false
}

$backendOk = Wait-Port 'http://localhost:8080/api/funcionarios' 'Backend'
$frontendOk = Wait-Port 'http://localhost:5173' 'Frontend'

if ($backendOk -and $frontendOk) {
    Write-Host "Both services are running."
} else {
    Write-Host "Check the opened windows for errors."
}
