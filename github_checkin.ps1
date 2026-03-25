param(
    
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
    Write-Host "No changes detected. Everything is up to date!" -ForegroundColor Green
    exit 0
}

# 1. Automatically detect the current branch name
$currentBranch = git rev-parse --abbrev-ref HEAD
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Could not determine current branch." -ForegroundColor Red
    exit $LASTEXITCODE
}


# 3. Handle Commit Message
if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
    $CommitMessage = Read-Host "Changes detected! Enter a commit message"
    if ([string]::IsNullOrWhiteSpace($CommitMessage)) { 
        Write-Host "Commit cancelled. Message cannot be empty." -ForegroundColor Red
        exit 1 
    }
}

Write-Host "--- Starting Auto-Checkin for [$currentBranch] ---" -ForegroundColor Cyan


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
git push origin $currentBranch --rebase
if($LASTEXITCODE -ne 0)
{
    Write-Host "Sync conflict! You might have edited the same line of code on two PCs." -ForegroundColor Red
    Write-Host "Resolve the conflict and run the script again."
    exit $LASTEXITCODE
}

# 6. Push
Write-Host "Pushing to GitHub..." -ForegroundColor Gray
git push origin $currentBranch

if ($LASTEXITCODE -ne 0) {
    Write-Host "Push failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Success! Your code is live on GitHub." -ForegroundColor Green