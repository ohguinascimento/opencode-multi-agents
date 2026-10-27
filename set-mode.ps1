# ============================================
# opencode-multi-agents - Permission Mode Switcher (Windows)
# ============================================

param(
    [ValidateSet("auto", "ask", "status", "help")]
    [string]$Mode = "status"
)

$ConfigFile = "opencode.json"

if (-not (Test-Path $ConfigFile)) {
    Write-Host "[ERRO] Arquivo opencode.json nao encontrado!" -ForegroundColor Red
    exit 1
}

$Green  = "Green"
$Yellow = "Yellow"
$Cyan   = "Cyan"
$Blue   = "Blue"

function Show-Status {
    $content = Get-Content $ConfigFile -Raw | ConvertFrom-Json
    $edit = $content.permission.edit
    $bash = $content.permission.bash
    $task = $content.permission.task.'*'

    Write-Host ""
    Write-Host "=============================================" -ForegroundColor $Cyan
    Write-Host "  Status do Modo de Permissoes (OpenCode)" -ForegroundColor $Cyan
    Write-Host "=============================================" -ForegroundColor $Cyan
    Write-Host ""

    if ($edit -eq "allow" -and $bash -eq "allow") {
        Write-Host "Modo Atual: " -NoNewline
        Write-Host "AUTONOMO (Sem pedir permissao)" -ForegroundColor $Green
        Write-Host "Modificacoes de arquivo: " -NoNewline
        Write-Host "AUTOMATICAS (allow)" -ForegroundColor $Green
        Write-Host "Comandos bash/terminal: " -NoNewline
        Write-Host "AUTOMATICOS (allow)" -ForegroundColor $Green
        Write-Host "Delegacao de tarefas: " -NoNewline
        Write-Host "AUTOMATICAS (allow)" -ForegroundColor $Green
    } else {
        Write-Host "Modo Atual: " -NoNewline
        Write-Host "SEGURO / INTERATIVO (Pede permissao)" -ForegroundColor $Yellow
        Write-Host "Modificacoes de arquivo: " -NoNewline
        Write-Host "INTERATIVO ($edit)" -ForegroundColor $Yellow
        Write-Host "Comandos bash/terminal: " -NoNewline
        Write-Host "INTERATIVO ($bash)" -ForegroundColor $Yellow
        Write-Host "Delegacao de tarefas: " -NoNewline
        Write-Host "INTERATIVO ($task)" -ForegroundColor $Yellow
    }

    Write-Host ""
    Write-Host "Comandos para alternar:" -ForegroundColor $Blue
    Write-Host "  .\set-mode.ps1 auto   - Nao pede permissao para modificacoes (Modo Rapido)"
    Write-Host "  .\set-mode.ps1 ask    - Pede permissao a cada modificacao (Modo Seguro)"
    Write-Host "  .\set-mode.ps1 status - Exibe este status"
    Write-Host ""
}

function Set-PermissionMode([string]$target) {
    $jsonText = Get-Content $ConfigFile -Raw
    $data = $jsonText | ConvertFrom-Json

    if ($target -eq "auto") {
        $data.permission.edit = "allow"
        $data.permission.bash = "allow"
        $data.permission.task.'*' = "allow"
        $msg = "Modo AUTONOMO ativado: o OpenCode executara modificacoes e comandos sem pedir permissao."
        $color = $Green
    } else {
        $data.permission.edit = "ask"
        $data.permission.bash = "ask"
        $data.permission.task.'*' = "ask"
        $msg = "Modo SEGURO ativado: o OpenCode solicitara confirmacao para cada modificacao."
        $color = $Yellow
    }

    $updatedJson = $data | ConvertTo-Json -Depth 20
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Resolve-Path $ConfigFile), $updatedJson, $utf8NoBom)

    Write-Host ""
    Write-Host "[OK] $msg" -ForegroundColor $color
    Write-Host "[INFO] Se o OpenCode estiver aberto, reinicie-o para aplicar a mudanca." -ForegroundColor $Cyan
    Write-Host ""
}

switch ($Mode) {
    "auto"   { Set-PermissionMode "auto" }
    "ask"    { Set-PermissionMode "ask" }
    "status" { Show-Status }
    "help"   { Show-Status }
}
