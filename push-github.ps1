# Upload Healthy Life iOS to GitHub
# Usage: $env:GITHUB_TOKEN = "ghp_..."; .\push-github.ps1

$ErrorActionPreference = "Stop"
$env:Path = "C:\Program Files\Git\bin;C:\Program Files\Git\cmd;" + $env:Path

$token = $env:GITHUB_TOKEN
if (-not $token) {
    Write-Host "Set token: `$env:GITHUB_TOKEN = 'ghp_...'" -ForegroundColor Red
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
Write-Host "GitHub user: $login" -ForegroundColor Green

$existing = $null
try {
    $existing = Invoke-RestMethod -Uri "https://api.github.com/repos/$login/$repoName" -Headers $headers
} catch {}

if (-not $existing) {
    Write-Host "Creating repository $repoName ..."
    $body = @{ name = $repoName; private = $false; auto_init = $false } | ConvertTo-Json
    Invoke-RestMethod -Method Post -Uri "https://api.github.com/user/repos" -Headers $headers -Body $body -ContentType "application/json" | Out-Null
} else {
    Write-Host "Repository already exists."
}

$remoteUrl = "https://$login`:$token@github.com/$login/$repoName.git"
git remote remove origin 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { $global:LASTEXITCODE = 0 }
git remote add origin $remoteUrl

Write-Host "Pushing to GitHub ..."
git push -u origin main

git remote set-url origin "https://github.com/$login/$repoName.git"

Write-Host ""
Write-Host "Done: https://github.com/$login/$repoName" -ForegroundColor Green
Write-Host "Actions: https://github.com/$login/$repoName/actions" -ForegroundColor Cyan
