$continue = $true;
do {
    $branch = git rev-parse --abbrev-ref HEAD
    $path = Get-Location
    Write-Host "Branch: '$branch' Path: '$path'"
    $command = Read-Host -Prompt 'What you want'
    Switch ($command) {
        's' {
            git status -s
        }
        'c' {
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
        'p' {
            git push origin $branch
        }
        'cp' {
        }
        'pl' {
        }
        'f' {
        }
        'm' {
        }
        'b' {
        }
        'cb' {
        }
        'rb' {
        }
        'nb' {
        }
        't' {
        }
        'ft' {
        }
        'dt' {
        }
        'at' {
        }
        'cf' {
        }
        'r' {
        }
        'h' {
            Write-Host “Help:
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