@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
set LC_ALL=C.UTF-8

:help
FOR /f "delims=" %%I in ('git rev-parse --abbrev-ref HEAD') do SET BRANCH=%%I
ECHO Branch: !BRANCH! Path: %cd%
ECHO Help:
ECHO s   - show status
ECHO c   - commit all chaned files
ECHO p   - push to current branch
ECHO pl  - pull form current branch
ECHO f   - fetch
ECHO b   - branch list (and update current branch)
ECHO bc  - change branch 
ECHO bnm - new branch from master
ECHO bnd - new branch from develop
ECHO l   - history of commits
ECHO cf  - checkout file
ECHO r   - reset branch
ECHO h   - help
ECHO e   - exit


:loop
SET /p COMMAND=What you want? 
CLS
FOR /f "delims=" %%I in ('git rev-parse --abbrev-ref HEAD') do SET BRANCH=%%I
ECHO Branch: !BRANCH! Path: %cd%
IF "%COMMAND%" == "s" (
    ECHO Status:
    git status -s
)
IF "%COMMAND%" == "c" (
    ECHO Files add to commit:
    FOR /f "delims=" %%L in ('git status -s') do (
        SET TYPE=%%L
        SET GITCOMMAND=add
        IF "!TYPE:~0,2!" == " D" (
            SET GITCOMMAND="rm"
            ECHO RM:  !TYPE!
        ) ELSE (
            ECHO ADD: !TYPE!
        )
        git !GITCOMMAND! !TYPE:~3!
    )
    SET /p COMMIT=Commit text? 
    git commit -m "!COMMIT!"
)
IF "%COMMAND%" == "p" (
    ECHO Push:
    git push origin !BRANCH!
)
IF "%COMMAND%" == "pl" (
    ECHO Pull:
    git pull origin !BRANCH!
)
IF "%COMMAND%" == "f" (
    ECHO Fetch:
    git fetch
)
IF "%COMMAND%" == "l" (
    ECHO History commits:
    git log --stat -2
)
IF "%COMMAND%" == "b" (
    ECHO Branch list:
    git branch
)
IF "%COMMAND%" == "r" (
    ECHO Reset:
    git reset --hard HEAD
)
IF "%COMMAND%" == "bnm" (
    ECHO New branch from master:
    SET /p BRANCH=Branch name? 
    git checkout -b !BRANCH! master
)
IF "%COMMAND%" == "bnd" (
    ECHO New branch from develop:
    SET /p BRANCH=Branch name? 
    git checkout -b !BRANCH! develop
)
IF "%COMMAND%" == "cf" (
    ECHO Select file:
    SET /A INDEX=1
    FOR /f "delims=" %%B in ('git status -s') do (
        ECHO !INDEX! %%B
        SET /A INDEX=INDEX+1
    )
    SET /p FILENUMBER=Checkout file number? 
    SET /A INDEX=1
    FOR /f "delims=" %%B in ('git status -s') do (
        IF !INDEX! == !FILENUMBER! (
            SET FILE=%%B
            git checkout !FILE:~3!
            GOTO loop
        )
        SET /A INDEX=INDEX+1
    )
)
IF "%COMMAND%" == "bc" (
    ECHO Select branch:
    SET /A INDEX=1
    FOR /f "delims=" %%B in ('git branch') do (
        ECHO !INDEX! %%B
        SET /A INDEX=INDEX+1
    )
    SET /p BRANCHNUMBER=Branch number? 
    SET /A INDEX=1
    FOR /f "delims=" %%B in ('git branch') do (
        IF !INDEX! == !BRANCHNUMBER! (
            SET BRANCH=%%B
            git checkout !BRANCH:~2!
            GOTO loop
        )
        SET /A INDEX=INDEX+1
    )

)
IF "%COMMAND%" == "h" (
    GOTO help
)
IF NOT "%COMMAND%" == "e" GOTO loop