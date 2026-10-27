# ============================================
# opencode-multi-agents - Install Script (Windows)
# ============================================

param(
    [string]$TargetDir = "."
)

$Green  = "Green"
$Yellow = "Yellow"
$Blue   = "Blue"
$Red    = "Red"
$Cyan   = "Cyan"

function Print-Info   { param($Msg) Write-Host "[INFO] $Msg" -ForegroundColor $Blue }
function Print-OK     { param($Msg) Write-Host "[OK] $Msg" -ForegroundColor $Green }
function Print-Warn   { param($Msg) Write-Host "[AVISO] $Msg" -ForegroundColor $Yellow }
function Print-Error  { param($Msg) Write-Host "[ERRO] $Msg" -ForegroundColor $Red }

Write-Host ""
Write-Host "=============================================" -ForegroundColor $Cyan
Write-Host "  opencode-multi-agents Installer (Windows)" -ForegroundColor $Cyan
Write-Host "=============================================" -ForegroundColor $Cyan
Write-Host ""

# Verificar se esta no diretorio correto
if (-not (Test-Path ".opencode")) {
    Print-Error "Diretorio .opencode nao encontrado!"
    Print-Info "Execute este script na raiz do repositorio opencode-multi-agents"
    exit 1
}

Print-OK "Estrutura do projeto encontrada"
Write-Host ""

# Perguntar diretorio de destino
Write-Host "Diretorio de instalacao: $TargetDir" -ForegroundColor $Blue
$confirm = Read-Host "Confirmar instalacao? (S/n)"
if ($confirm -eq "n" -or $confirm -eq "N") {
    Print-Info "Instalacao cancelada"
    exit 0
}

# Criar diretorio se nao existir
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

Print-Info "Instalando arquivos em: $TargetDir"

# Copiar agentes
Print-Info "Copiando agentes..."
Copy-Item -Recurse -Force ".opencode\agents" "$TargetDir\.opencode\"

# Copiar comandos
Print-Info "Copiando comandos..."
Copy-Item -Recurse -Force ".opencode\command" "$TargetDir\.opencode\"

# Copiar skills
Print-Info "Copiando skills..."
Copy-Item -Recurse -Force ".opencode\skills" "$TargetDir\.opencode\"

# Configurar skills para Antigravity (.agents\skills)
Print-Info "Configurando skills para Antigravity (.agents\skills)..."
if (-not (Test-Path "$TargetDir\.agents\skills")) {
    New-Item -ItemType Directory -Force -Path "$TargetDir\.agents\skills" | Out-Null
}
Copy-Item -Recurse -Force ".opencode\skills\*" "$TargetDir\.agents\skills\"

# Copiar configuracao
Print-Info "Copiando configuracao..."
Copy-Item -Force "opencode.json" "$TargetDir\"

# Copiar scripts
Print-Info "Copiando scripts..."
if (Test-Path "start.ps1")    { Copy-Item -Force "start.ps1" "$TargetDir\" }
if (Test-Path "start.sh")     { Copy-Item -Force "start.sh" "$TargetDir\" }
if (Test-Path "set-mode.ps1") { Copy-Item -Force "set-mode.ps1" "$TargetDir\" }
if (Test-Path "set-mode.sh")  { Copy-Item -Force "set-mode.sh" "$TargetDir\" }

# Copiar .gitignore (adicionar entradas se ja existir)
if (Test-Path "$TargetDir\.gitignore") {
    $gi = Get-Content "$TargetDir\.gitignore" -Raw
    if ($gi -notmatch "\.env") {
        Add-Content -Path "$TargetDir\.gitignore" -Value "`n# Configuracoes sensiveis`n.env`n.env.local`n.env.*.local`n.env.backup*"
    }
} else {
    if (Test-Path ".gitignore") { Copy-Item -Force ".gitignore" "$TargetDir\" }
}

# Copiar .env.example
Copy-Item -Force ".env.example" "$TargetDir\"

# Criar .env se nao existir
if (-not (Test-Path "$TargetDir\.env")) {
    Copy-Item -Force ".env.example" "$TargetDir\.env"
    Print-Warn "Arquivo .env criado. Configure com /setup dentro do opencode!"
}

Print-OK "Arquivos instalados com sucesso!"
Write-Host ""

# Instrucoes
Write-Host "=============================================" -ForegroundColor $Green
Write-Host "  Instalacao Concluida!" -ForegroundColor $Green
Write-Host "=============================================" -ForegroundColor $Green
Write-Host ""
Write-Host "  Proximos passos:" -ForegroundColor $Yellow
Write-Host ""
Write-Host "  1. Navegue ate o diretorio do projeto:"
Write-Host "     cd $TargetDir" -ForegroundColor $Blue
Write-Host ""
Write-Host "  2. Execute o start script:"
Write-Host "     .\start.ps1" -ForegroundColor $Blue
Write-Host ""
Write-Host "  3. DENTRO do opencode, digite:"
Write-Host "     /setup" -ForegroundColor $Green
Write-Host ""
Write-Host "  4. Inicie seu projeto:"
Write-Host '     /start-project "descricao do projeto"' -ForegroundColor $Green
Write-Host ""
