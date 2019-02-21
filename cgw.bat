@echo off

if "%~1"==":cgw" goto :cgw
cmd /c "%~f0" :cgw
exit /b
:cgw

SETLOCAL ENABLEDELAYEDEXPANSION
set LC_ALL=C.UTF-8
SET SCRIPT_PATH=%~dp0
SET "PROJECTS_PATH=%SCRIPT_PATH%projects.txt"

:help
FOR /f "delims=" %%I in ('git rev-parse --abbrev-ref HEAD') do SET CURRENT_BRANCH=%%I
ECHO Branch: !CURRENT_BRANCH! Path: %cd%
ECHO Help:
ECHO s   - show status
ECHO c   - commit all changed files
ECHO p   - push to current branch
ECHO cp  - commit all changed fales and push to current branch
ECHO pl  - pull form current branch
ECHO f   - fetch
ECHO b   - branch list (and update current branch)
ECHO cb  - change branch 
ECHO rb  - remove branch 
ECHO nbm - new branch from master
ECHO nbd - new branch from develop
ECHO mtm - merge current branch to master
ECHO cf  - checkout file
ECHO r   - reset branch
ECHO ------------------------
ECHO sp  - select project
ECHO ap  - add project
ECHO ------------------------
ECHO h   - help
ECHO e   - exit


:loop
SET /p COMMAND=What you want? 
CLS
FOR /f "delims=" %%I in ('git rev-parse --abbrev-ref HEAD') do SET CURRENT_BRANCH=%%I
ECHO Branch: !CURRENT_BRANCH! Path: %cd%
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
IF "%COMMAND%" == "cp" (
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
    ECHO Push:
    git push origin !CURRENT_BRANCH!
)
IF "%COMMAND%" == "p" (
    ECHO Push:
    git push origin !CURRENT_BRANCH!
)
IF "%COMMAND%" == "pl" (
    ECHO Pull:
    git pull origin !CURRENT_BRANCH!
)
IF "%COMMAND%" == "f" (
    ECHO Fetch:
    git fetch
)
IF "%COMMAND%" == "b" (
    ECHO Branch list:
    git branch
)
IF "%COMMAND%" == "r" (
    ECHO Reset:
    git reset --hard HEAD
)
IF "%COMMAND%" == "nbm" (
    ECHO New branch from master:
    SET /p BRANCH=Branch name? 
    git checkout -b !BRANCH! master
)
IF "%COMMAND%" == "nbd" (
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
IF "%COMMAND%" == "mtm" (
    git checkout master
    git pull origin master
    git merge --no-ff !CURRENT_BRANCH!
    git push origin master
    ECHO merged!
    GOTO loop
)
IF "%COMMAND%" == "cb" (
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
IF "%COMMAND%" == "rb" (
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
            git branch -d !BRANCH:~2!
            GOTO loop
        )
        SET /A INDEX=INDEX+1
    )
)
IF "%COMMAND%" == "sp" (
    SET /A INDEX=1
    FOR /f "delims=" %%B in ('type "!PROJECTS_PATH!"') do (
        ECHO !INDEX! %%B
        SET /A INDEX=INDEX+1
    )
    SET /p PROJECTNUMBER=Project number? 
    SET /A INDEX=1
    FOR /f "delims=" %%B in ('type "!PROJECTS_PATH!"') do (
        IF !INDEX! == !PROJECTNUMBER! (
            SET PROJECT=%%B
            CD !PROJECT!
            ECHO Change to: !PROJECT!
            GOTO loop
        )
        SET /A INDEX=INDEX+1
    )
    GOTO loop
)
IF "%COMMAND%" == "ap" (
    ECHO %cd% >> !PROJECTS_PATH!
    ECHO Project '%cd%' add.
    GOTO loop
)
IF "%COMMAND%" == "h" (
    GOTO help
)
IF NOT "%COMMAND%" == "e" GOTO loop