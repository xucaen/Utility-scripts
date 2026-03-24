# Check if we are in a Git repository
if (!(Test-Path .git)) {
    Write-Host "Error: This is not a Git repository!" -ForegroundColor Red
    exit
}

# 1. Automatically detect the current branch name
$currentBranch = git rev-parse --abbrev-ref HEAD
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Could not determine current branch." -ForegroundColor Red
    exit $LASTEXITCODE
}

$commitMessage = $args[0]

if (-not $commitMessage) {
    $commitMessage = Read-Host "Enter your commit message"
}


if (-not $commitMessage) {
    Write-Host "Error: A commit message is required!" -ForegroundColor Red
    exit
}

Write-Host "Staging changes..." -ForegroundColor Cyan
git add .
if($LASTEXITCODE -ne 0)
{
    Write-Host "git add failed with exit code $LASTEXITCODE" -ForegroundColor Magenta -BackgroundColor Cyan
    exit $LASTEXITCODE
}

Write-Host "Committing changes..." -ForegroundColor Cyan
git commit -m "$commitMessage"
if($LASTEXITCODE -ne 0)
{
    Write-Host "git commit failed with exit code $LASTEXITCODE" -ForegroundColor Magenta -BackgroundColor Cyan
    exit $LASTEXITCODE
}

# Using the explicit remote and branch name for safety
Write-Host "Pushing to origin $currentBranch..." -ForegroundColor Cyan
git push origin $currentBranch
if($LASTEXITCODE -ne 0)
{
    Write-Host "git push failed with exit code $LASTEXITCODE" -ForegroundColor Magenta -BackgroundColor Cyan
    exit $LASTEXITCODE
}

Write-Host "Success! Your video scripts are now on GitHub branch $currentBranch." -ForegroundColor Green