. include\show-list.ps1
. include\select-from-list.ps1

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
    Write-Host "Branch: '$currentBranch' Path: '$path'"
    $command = Read-Host -Prompt 'What you want'
    Switch ($command) {
        's' {
            $status = git status -s
            Show-List "GIT STATUS" $status.Split([Environment]::NewLine)        
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
            $branches = git branch
            Show-List "BRANCHES" $branches.Split([Environment]::NewLine)
        }
        'cb' {
            $branches = git branch
            Select-From-List "SELECT BRANCH" $branches.Split([Environment]::NewLine)
        }
        'rb' {
        }
        'nb' {
            Write-Host "NEW BRANCH" -ForegroundColor Green
            $branch = Read-Host -Prompt 'Branch name'
            git checkout -b $branch 2>&1 | %{ "$_" }
        }
        't' {
            $tags = git tag --sort=-creatordate
            Show-List "TAGS" $tags.Split([Environment]::NewLine)
        }
        'ft' {
            Write-Host "FETCH TAGS" -ForegroundColor Green
            git fetch --tags --force
        }
        'dt' {
        }
        'at' {
            Write-Host "ADD TAG" -ForegroundColor Green
            $tag = Read-Host -Prompt 'Tag name'
            git tag $tag
            git push origin $tag
        }
        'cf' {
        }
        'r' {
            Write-Host "RESET" -ForegroundColor Green
            git reset --hard HEAD
        }
        'h' {
            Write-Host "HELP" -ForegroundColor Green
            Write-Host “s   - show status
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
q   - quit“

        }
        'q' {
            $continue = $false
        }
    }
} while ($continue)
