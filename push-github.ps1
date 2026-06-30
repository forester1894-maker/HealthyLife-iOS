# Upload Healthy Life iOS to GitHub
# GitHub НЕ принимает пароль для git push — нужен Personal Access Token (PAT).
#
# Как получить PAT (1 раз, ~2 мин):
# 1. https://github.com/settings/tokens
# 2. Generate new token (classic) → scope: repo
# 3. Скопируйте токен
#
# Запуск в PowerShell:
#   $env:GITHUB_TOKEN = "ghp_ВАШ_ТОКЕН"
#   .\push-github.ps1

$ErrorActionPreference = "Stop"
$env:Path = "C:\Program Files\Git\bin;C:\Program Files\Git\cmd;" + $env:Path

$token = $env:GITHUB_TOKEN
if (-not $token) {
    Write-Host "Задайте токен: `$env:GITHUB_TOKEN = 'ghp_...'" -ForegroundColor Red
    exit 1
}

$repoName = "HealthyLife-iOS"
$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectDir

$headers = @{
    Authorization = "Bearer $token"
    "User-Agent"  = "HealthyLife-Setup"
    Accept        = "application/vnd.github+json"
}

$user = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers
$login = $user.login
Write-Host "GitHub: $login" -ForegroundColor Green

$existing = $null
try {
    $existing = Invoke-RestMethod -Uri "https://api.github.com/repos/$login/$repoName" -Headers $headers
} catch {}

if (-not $existing) {
    Write-Host "Создаю репозиторий $repoName ..."
    $body = @{ name = $repoName; private = $false; auto_init = $false } | ConvertTo-Json
    Invoke-RestMethod -Method Post -Uri "https://api.github.com/user/repos" -Headers $headers -Body $body -ContentType "application/json" | Out-Null
} else {
    Write-Host "Репозиторий уже существует."
}

$remoteUrl = "https://$login`:$token@github.com/$login/$repoName.git"
git remote remove origin 2>$null
git remote add origin $remoteUrl

Write-Host "Отправляю код на GitHub ..."
git push -u origin main

# Убираем токен из remote URL
git remote set-url origin "https://github.com/$login/$repoName.git"

Write-Host ""
Write-Host "Готово: https://github.com/$login/$repoName" -ForegroundColor Green
Write-Host "Сборка: https://github.com/$login/$repoName/actions" -ForegroundColor Cyan
