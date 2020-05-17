Function Git-Commit {
    Write-Host "GIT COMMIT ALL FILES" -ForegroundColor Green
    $status = git status -s
    $status.Split([Environment]::NewLine) | ForEach-Object -Process {
        $gitAction = 'add'
        $file = $_.Substring(3)
        if ($_.Substring(0, 2) -eq ' D') {
            Write-Host "RM  $file"
            $gitAction = 'rm'
        } else {
            Write-Host "ADD $file"
        }
        git $gitAction $_.Substring(3)
    }
    $commit = Read-Host -Prompt 'Commit text'
    git commit -m $commit
}

Function Git-Push {
    Write-Host "GIT PUSH" -ForegroundColor Green
    git push origin $currentBranch 2>&1 | %{ "$_" } 
}

$continue = $true;
do {
    $currentBranch = git rev-parse --abbrev-ref HEAD
    $path = Get-Location
    Write-Host "Branch: '$branch' Path: '$path'"
    $command = Read-Host -Prompt 'What you want'
    Switch ($command) {
        's' {
            Write-Host "GIT STATUS" -ForegroundColor Green
            git status -s
        }
        'c' {
            Git-Commit
        }
        'p' {
            Git-Push
        }
        'cp' {
            Git-Commit
            Git-Push
        }
        'pl' {
            Write-Host "GIT PULL" -ForegroundColor Green
            git pull origin $currentBranch 2>&1 | %{ "$_" }
        }
        'f' {
            Write-Host "GIT FETCH" -ForegroundColor Green
            git fetch
        }
        'm' {
        }
        'b' {
            Write-Host "BRANCHES" -ForegroundColor Green
            git branch
        }
        'cb' {
        }
        'rb' {
        }
        'nb' {
            Write-Host "CHANGE BRANCH" -ForegroundColor Green
            $branch = Read-Host -Prompt 'Branch name'
            git checkout -b $branch $currentBranch
        }
        't' {
            Write-Host "TAGS" -ForegroundColor Green
            git tag --sort=-creatordate
        }
        'ft' {
            git fetch --tags --force
        }
        'dt' {
        }
        'at' {
        }
        'cf' {
        }
        'r' {
            Write-Host "RESET" -ForegroundColor Green
            git reset --hard HEAD
        }
        'h' {
            Write-Host "HELP" -ForegroundColor Green
            Write-Host “
    s   - show status
    c   - commit all changed files
    p   - push to current branch
    cp  - commit all changed fales and push to current branch
    pl  - pull form current branch
    f   - fetch
    ------------------------
    m   - merge in current branch
    b   - branch list (and update current branch)
    cb  - change branch
    rb  - remove branch
    nb  - new branch from current branch
    ------------------------
    t   - tag list
    ft  - fetch tag
    dt  - delete tag
    at  - add tag
    ------------------------
    cf  - checkout file
    r   - reset branch
    ------------------------
    h   - help
    e   - exit“

        }
        'e' {
            $continue = $false
        }
    }
} while ($continue)