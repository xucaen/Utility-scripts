param(
    [Parameter(Mandatory=$true, HelpMessage="Please enter a commit message.")]
    [string]$CommitMessage
)

# Check if we are in a Git repository
if (!(Test-Path .git)) {
    Write-Host "Error: This is not a Git repository!" -ForegroundColor Red
    exit 99
}

# Check if there are any changes (staged or unstaged)
$status = git status --porcelain

if (-not $status) {
    Write-Host "Hey, there are no code changes found."
    exit 0
}

# 1. Automatically detect the current branch name
$currentBranch = git rev-parse --abbrev-ref HEAD
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Could not determine current branch." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Staging changes..." -ForegroundColor Cyan
git add .
if($LASTEXITCODE -ne 0)
{
    Write-Host "git add failed with exit code $LASTEXITCODE" -ForegroundColor Magenta -BackgroundColor Cyan
    exit $LASTEXITCODE
}

Write-Host "Committing changes..." -ForegroundColor Cyan
git commit -m "$CommitMessage"
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