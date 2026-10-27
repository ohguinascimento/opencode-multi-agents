# ============================================
# sync-skills.ps1 - Sincroniza Skills OpenCode -> Antigravity
# ============================================

$ErrorActionPreference = "Stop"

$Green  = "Green"
$Yellow = "Yellow"
$Blue   = "Blue"
$Cyan   = "Cyan"
$Red    = "Red"

function Print-Info  { param($Msg) Write-Host "[INFO] $Msg" -ForegroundColor $Blue }
Write-Host ""
Write-Host "=============================================" -ForegroundColor $Cyan
Write-Host "  Sincronizador de Skills: OpenCode -> Antigravity" -ForegroundColor $Cyan
Write-Host "=============================================" -ForegroundColor $Cyan
Write-Host ""

$sourceSkills = ".opencode\skills"
if (-not (Test-Path $sourceSkills)) {
    Write-Host "[ERRO] Diretorio $sourceSkills nao encontrado!" -ForegroundColor $Red
    exit 1
}

$userProfile = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
$globalGeminiSkills = Join-Path $userProfile ".gemini\config\skills"
$localAgentsSkills = ".agents\skills"

# 1. Sincronizar Workspace (.agents/skills)
Write-Host "[1/2] Sincronizando para Workspace (.agents\skills)..." -ForegroundColor $Cyan
if (-not (Test-Path $localAgentsSkills)) {
    New-Item -ItemType Directory -Force -Path $localAgentsSkills | Out-Null
}
Copy-Item -Path "$sourceSkills\*" -Destination $localAgentsSkills -Recurse -Force
Write-Host "  -> OK: Skills copiadas para $localAgentsSkills" -ForegroundColor $Green

# 2. Sincronizar Global Antigravity (~/.gemini/config/skills)
Write-Host "[2/2] Sincronizando para Antigravity Global ($globalGeminiSkills)..." -ForegroundColor $Cyan
if (-not (Test-Path $globalGeminiSkills)) {
    New-Item -ItemType Directory -Force -Path $globalGeminiSkills | Out-Null
}
Copy-Item -Path "$sourceSkills\*" -Destination $globalGeminiSkills -Recurse -Force
Write-Host "  -> OK: Skills copiadas para $globalGeminiSkills" -ForegroundColor $Green

Write-Host ""
Write-Host "=============================================" -ForegroundColor $Green
Write-Host "  Skills sincronizadas com sucesso!" -ForegroundColor $Green
Write-Host "  As skills especialistas ja estao ativas no Antigravity." -ForegroundColor $Green
Write-Host "=============================================" -ForegroundColor $Green
Write-Host ""
