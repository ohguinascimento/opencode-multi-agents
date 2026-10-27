# ============================================
# opencode-multi-agents - Start Script (Windows)
# ============================================

param(
    [switch]$Auto,
    [switch]$Ask
)

$ErrorActionPreference = "Stop"

# Cores (apenas cores basicas do PowerShell)
$Cyan   = "Cyan"
$Green  = "Green"
$Yellow = "Yellow"
$Blue   = "Blue"
$Red    = "Red"

function Print-Info  { param($Msg) Write-Host "[INFO] $Msg" -ForegroundColor $Blue }
function Print-OK    { param($Msg) Write-Host "[OK] $Msg" -ForegroundColor $Green }
function Print-Warn  { param($Msg) Write-Host "[AVISO] $Msg" -ForegroundColor $Yellow }
function Print-Error { param($Msg) Write-Host "[ERRO] $Msg" -ForegroundColor $Red }

# ============================================
#  BANNER
# ============================================
function Show-Banner {
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor $Cyan
    Write-Host "  opencode-multi-agents v0.1.0" -ForegroundColor $Cyan
    Write-Host "  Windows PowerShell" -ForegroundColor $Cyan
    Write-Host "=============================================" -ForegroundColor $Cyan
    Write-Host ""
}

# ============================================
#  INSTALAR OPENCODE
# ============================================
function Install-OpenCode {
    Print-Info "Instalando opencode (pode levar alguns segundos)..."
    Write-Host ""

    # Tenta via npm primeiro
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Print-Info "Usando npm para instalar..."
        & npm install -g opencode-ai 2>$null
        if ($LASTEXITCODE -eq 0) {
            Print-OK "opencode instalado via npm"
            return
        }
    }

    # Metodo alternativo: baixar binario do GitHub
    Print-Info "Baixando binario diretamente..."
    $arch = if ([Environment]::Is64BitOperatingSystem) { "x86_64" } else { "x86" }
    $url = "https://github.com/anomalyco/opencode/releases/latest/download/opencode-windows-$arch.exe"
    $installDir = "$env:USERPROFILE\.opencode\bin"
    $destFile = "$installDir\opencode.exe"

    try {
        New-Item -ItemType Directory -Force -Path $installDir | Out-Null
        Invoke-WebRequest -Uri $url -OutFile $destFile -UseBasicParsing

        # Adicionar ao PATH atual
        $env:PATH = "$installDir;$env:PATH"

        # Adicionar ao PATH permanentemente (usuario)
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($currentPath -notlike "*$installDir*") {
            [Environment]::SetEnvironmentVariable("Path", "$installDir;$currentPath", "User")
        }

        Print-OK "opencode instalado em $installDir"
    }
    catch {
        Print-Error "Falha na instalacao automatica."
        Write-Host ""
        Print-Info "Instale manualmente:"
        Write-Host "  npm install -g opencode-ai" -ForegroundColor $Yellow
        Write-Host "  ou baixe de: https://opencode.ai" -ForegroundColor $Yellow
        exit 1
    }
}

# ============================================
#  VERIFICAR OPENCODE
# ============================================
function Check-OpenCode {
    # Verifica no PATH
    if (Get-Command opencode -ErrorAction SilentlyContinue) {
        Print-OK "opencode encontrado"
        return
    }

    # Verifica diretorios comuns no Windows
    $paths = @(
        "$env:USERPROFILE\.opencode\bin\opencode.exe",
        "$env:LOCALAPPDATA\opencode\bin\opencode.exe",
        "$env:PROGRAMFILES\opencode\bin\opencode.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $dir = Split-Path $p
            $env:PATH = "$dir;$env:PATH"
            Print-OK "opencode encontrado em $dir"
            return
        }
    }

    # Nao encontrou, instalar
    Install-OpenCode

    if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
        Print-Error "Nao foi possivel iniciar o opencode."
        exit 1
    }
    Print-OK "opencode instalado com sucesso"
}

# ============================================
#  VERIFICAR OPencode.json
# ============================================
function Check-Config {
    if (-not (Test-Path "opencode.json")) {
        Print-Error "opencode.json nao encontrado!"
        Print-Info "Execute .\install.ps1 primeiro para instalar os agentes."
        exit 1
    }
    Print-OK "configuracao encontrada"
}

# ============================================
#  VERIFICAR .env (opcional com modelo gratuito)
# ============================================
function Check-Env {
    if (-not (Test-Path ".env")) {
        Print-Info "Arquivo .env nao encontrado (ok se usar modelo gratuito)"
        return $false
    }

    $envContent = Get-Content .env -Raw -ErrorAction SilentlyContinue
    if ($envContent -match "OPENCODE_API_KEY=(.+)" -and $Matches[1].Length -ge 20 -and $Matches[1] -ne "sua-chave-aqui") {
        Print-OK "API key configurada"
        return $true
    }

    Print-Info "Usando modelo gratuito (nenhuma API key necessaria)"
    return $false
}

# ============================================
#  VERIFICAR NODE.JS
# ============================================
function Check-Node {
    $hasNode = Get-Command node -ErrorAction SilentlyContinue
    $hasNpx  = Get-Command npx -ErrorAction SilentlyContinue
    if (-not $hasNode -and -not $hasNpx) {
        Print-Warn "Node.js nao encontrado. opencode pode precisar dele."
        Write-Host "  Instale Node.js: https://nodejs.org" -ForegroundColor $Yellow
    }
}

# ============================================
#  MOSTRAR INSTRUCOES
# ============================================
function Show-Help {
    param($Mode = "ready")

    Write-Host ""
    Write-Host "=============================================" -ForegroundColor $Blue
    Write-Host "  COMO USAR O OPENCODE-MULTI-AGENTS" -ForegroundColor $Blue
    Write-Host "=============================================" -ForegroundColor $Blue
    Write-Host ""
    Write-Host "A partir daqui, voce entrara na interface do opencode."
    Write-Host "Dentro dela, digite os comandos abaixo."
    Write-Host ""
    Write-Host "NUNCA digite /comandos no terminal!" -ForegroundColor $Yellow
    Write-Host "Os /comandos sao digitados DENTRO da interface do opencode."
    Write-Host ""
    Write-Host "Primeira vez:" -ForegroundColor $Cyan
    Write-Host "  1. Digite:  " -NoNewline
    Write-Host "/setup" -ForegroundColor $Green
    Write-Host "     > Configure seu modelo (gratuito ou pago)"
    Write-Host "  2. Digite:  " -NoNewline
    Write-Host '/start-project "descricao do projeto"' -ForegroundColor $Green
    Write-Host "     > O time de agentes trabalha para voce"
    Write-Host ""
    Write-Host "Comandos disponiveis:" -ForegroundColor $Cyan
    Write-Host "  /setup           - Configurar ambiente (gratuito ou pago)"
    Write-Host "  /setup-status    - Ver configuracao atual"
    Write-Host "  /start-project   - Iniciar novo projeto"
    Write-Host "  /full-cycle      - Ciclo completo automatizado"
    Write-Host "  /review-code     - Revisar codigo"
    Write-Host "  /security-audit  - Auditoria de seguranca"
    Write-Host "  /deploy          - Configurar deploy"
    Write-Host "  /status          - Ver progresso"
    Write-Host "  /mode            - Ver/configurar modo de permissoes"
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor $Blue
    Write-Host "  MANTER ATUALIZADO" -ForegroundColor $Blue
    Write-Host "=============================================" -ForegroundColor $Blue
    Write-Host ""
    Write-Host "Se voce fez FORK deste repositorio:" -ForegroundColor $Cyan
    Write-Host '  > No GitHub: clique em "Sync fork" para atualizar'
    Write-Host "  > No terminal:"
    Write-Host "      git fetch upstream && git merge upstream/main" -ForegroundColor $Green
    Write-Host ""
    Write-Host 'Se usou "Use this template":' -ForegroundColor $Cyan
    Write-Host "  > Nao recebe atualizacoes automaticas"
    Write-Host "  > Para copiar uma versao nova, rode: " -NoNewline
    Write-Host ".\install.ps1" -ForegroundColor $Green
    Write-Host ""
    Write-Host "(No Linux/Mac, use ./start.sh e ./install.sh)" -ForegroundColor $Blue

    if ($Mode -eq "first") {
        Write-Host ""
        Write-Host "Execute " -NoNewline
        Write-Host "/setup" -ForegroundColor $Green -NoNewline
        Write-Host " ao entrar para escolher seu modelo." -ForegroundColor $Yellow
        Write-Host "  Padrao: modelo gratuito (sem API key). Opcoes pagas disponiveis."
        Write-Host ""
    }
}

# ============================================
#  MAIN
# ============================================
Show-Banner

Print-Info "Verificando ambiente..."
Write-Host ""

Check-OpenCode
Check-Config
Check-Node

Write-Host ""
$hasKey = Check-Env
if ($hasKey) {
    Print-OK "API key configurada"
    Write-Host ""
    Show-Help "ready"
} else {
    Print-Warn "Configuracao inicial necessaria"
    Write-Host ""
    Show-Help "first"
}

# Detectar modo de permissoes (Auto vs Ask)
$isAuto = $false
if ($Auto) {
    $isAuto = $true
} elseif ($Ask) {
    $isAuto = $false
} else {
    try {
        $cfg = Get-Content "opencode.json" -Raw | ConvertFrom-Json
        if ($cfg.permission.edit -eq "allow" -and $cfg.permission.bash -eq "allow") {
            $isAuto = $true
        }
    } catch {}
}

if ($isAuto) {
    Print-OK "Modo de Permissoes: AUTONOMO (Sem pedir permissao para modificacoes/comandos)"
    Print-Info "Iniciando opencode com --auto..."
    Write-Host ""
    & opencode --auto
} else {
    Print-Warn "Modo de Permissoes: SEGURO / INTERATIVO (Pedira confirmacao a cada alteracao)"
    Print-Info "Dica: Para executar sem confirmacao, use .\start.ps1 -Auto ou rode .\set-mode.ps1 auto"
    Write-Host ""
    Print-Info "Iniciando opencode..."
    Write-Host ""
    & opencode
}
