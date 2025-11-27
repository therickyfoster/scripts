# Define the parent directory containing your folders
$parentDir = "C:\path\to\your\folders"  # Change this to your folders' directory path

# Loop through each folder in the parent directory
foreach ($folder in Get-ChildItem -Path $parentDir -Directory) {
    $repoName = $folder.Name
    $indexPath = Join-Path $folder.FullName "index.html"

    # Ensure the index.html exists in the folder
    if (Test-Path $indexPath) {
        Write-Host "Processing folder: $repoName" -ForegroundColor Cyan
        
        # 1. Create the GitHub repository
        $repoCreated = $false
        $retryCount = 0
        while (-not $repoCreated -and $retryCount -lt 3) {
            try {
                Write-Host "Creating repository: $repoName..." -ForegroundColor Cyan
                gh repo create $repoName --public --confirm
                $repoCreated = $true
                Write-Host "Repository $repoName created successfully!" -ForegroundColor Green
            } catch {
                $retryCount++
                Write-Host "Failed to create repository $repoName. Retrying... ($retryCount/3)" -ForegroundColor Yellow
                Start-Sleep -Seconds 3
            }
        }

        # Skip to the next folder if repository creation failed after 3 attempts
        if (-not $repoCreated) {
            Write-Host "Failed to create repository $repoName after multiple attempts. Skipping..." -ForegroundColor Red
            continue
        }

        # 2. Initialize git in the folder and push the index.html file
        try {
            Write-Host "Uploading index.html to repository $repoName..." -ForegroundColor Cyan
            
            # Initialize git repo and push index.html
            Set-Location -Path $folder.FullName
            git init
            git add index.html
            git commit -m "Initial commit with index.html"
            git remote add origin "https://github.com/your-username/$repoName.git"  # Replace with your GitHub username
            git push -u origin master

            Write-Host "index.html uploaded successfully to $repoName!" -ForegroundColor Green
        } catch {
            Write-Host "Error uploading index.html to $repoName." -ForegroundColor Red
            continue
        }

        # 3. Enable GitHub Pages for the repository
        $pagesEnabled = $false
        $retryCount = 0
        while (-not $pagesEnabled -and $retryCount -lt 3) {
            try {
                Write-Host "Enabling GitHub Pages for $repoName..." -ForegroundColor Cyan
                gh repo edit $repoName --enable-pages --source main
                $pagesEnabled = $true
                Write-Host "GitHub Pages enabled for $repoName!" -ForegroundColor Green
            } catch {
                $retryCount++
                Write-Host "Failed to enable GitHub Pages for $repoName. Retrying... ($retryCount/3)" -ForegroundColor Yellow
                Start-Sleep -Seconds 3
            }
        }

        # If enabling Pages failed after 3 attempts, skip this repository
        if (-not $pagesEnabled) {
            Write-Host "Failed to enable GitHub Pages for $repoName after multiple attempts. Skipping..." -ForegroundColor Red
        }
    } else {
        Write-Host "No index.html found in folder $repoName. Skipping..." -ForegroundColor Yellow
    }
}

Write-Host "Process complete!" -ForegroundColor Green
