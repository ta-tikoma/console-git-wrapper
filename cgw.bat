@echo off

if "%~1"==":cgw" goto :cgw
cmd /c "%~f0" :cgw
exit /b
:cgw

SETLOCAL ENABLEDELAYEDEXPANSION
SET LC_ALL=C.UTF-8
CHCP 65001

REM define buffer file
SET "buff=%tmp%\cgw~%RANDOM%.tmp"

CLS

:loop
FOR /f "delims=" %%I in ('git rev-parse --abbrev-ref HEAD') do SET CURRENT_BRANCH=%%I
ECHO _______________________________________________________________
ECHO Branch: !CURRENT_BRANCH! Path: %cd%
SET /p COMMAND=What you want? 
CLS

rem -----------------------------------------------------

IF "%COMMAND%" == "s" (
    git status -s > "%buff%"
    CALL :ShowList "Status:"
)
IF "%COMMAND%" == "a" (
    ECHO Files add:
    FOR /f "delims=" %%L in ('git status -s') do (
        SET TYPE=%%L
        SET GITCOMMAND=add
        IF "!TYPE:~0,2!" == " D" (
            SET GITCOMMAND="rm"
            rem ECHO rm:  !TYPE!
        ) ELSE (
            ECHO add '!TYPE:~3!'
        )
        git !GITCOMMAND! !TYPE:~3!
    )
)
IF "%COMMAND%" == "c" (
    ECHO Files add to commit:
    FOR /f "delims=" %%L in ('git status -s') do (
        SET TYPE=%%L
        SET GITCOMMAND=add
        IF "!TYPE:~0,2!" == " D" (
            SET GITCOMMAND="rm"
            rem ECHO rm:  !TYPE!
        ) ELSE (
            ECHO add '!TYPE:~3!'
        )
        git !GITCOMMAND! !TYPE:~3!
    )
    SET /p COMMIT=Commit text ^(e - cancel^): 
    IF NOT "!COMMIT!" == "e" (
        git commit -m "!COMMIT!"
    )
)
IF "%COMMAND%" == "p" (
    ECHO Push:
    git push origin !CURRENT_BRANCH!
)
IF "%COMMAND%" == "pf" (
    ECHO Push force:
    git push -f origin !CURRENT_BRANCH!
)
IF "%COMMAND%" == "cp" (
    ECHO Files add to commit:
    FOR /f "delims=" %%L in ('git status -s') do (
        SET TYPE=%%L
        SET GITCOMMAND=add
        IF "!TYPE:~0,2!" == " D" (
            SET GITCOMMAND="rm"
            rem ECHO rm:  !TYPE!
        ) ELSE (
            ECHO add '!TYPE:~3!'
        )
        git !GITCOMMAND! !TYPE:~3!
    )
    SET /p COMMIT=Commit text ^(e - cancel^): 
    IF NOT "!COMMIT!" == "e" (
        git commit -m "!COMMIT!"
        ECHO Push:
        git push origin !CURRENT_BRANCH!
    )
)
IF "%COMMAND%" == "pl" (
    ECHO Pull:
    git pull origin !CURRENT_BRANCH!
)
IF "%COMMAND%" == "f" (
    ECHO Fetch:
    git fetch
)
IF "%COMMAND%" == "f" (
    ECHO Fetch force:
    git fetch --force
)

rem -----------------------------------------------------

IF "%COMMAND%" == "m" (
    git branch --sort=-committerdate > "%buff%"
    CALL :SelectOneFromList "Select branch for merge in current: "
    IF NOT [!ONEFORMLIST!] == [] (
        git merge --no-ff !ONEFORMLIST:~2!
    )
)
IF "%COMMAND%" == "m+" (
    git branch -r > "%buff%"
    CALL :SelectOneFromList "Select remote branch for merge in current: "
    IF NOT [!ONEFORMLIST!] == [] (
        git merge --no-ff !ONEFORMLIST:~2!
    )
)
IF "%COMMAND%" == "r" (
    git branch --sort=-committerdate > "%buff%"
    CALL :SelectOneFromList "Select branch for rebase in current: "
    IF NOT [!ONEFORMLIST!] == [] (
        git pull --rebase origin !ONEFORMLIST:~2!
    )
)
IF "%COMMAND%" == "rc" (
    git rebase --continue
)
IF "%COMMAND%" == "rs" (
    git rebase --skip
)
IF "%COMMAND%" == "ra" (
    git rebase --abort
)

rem -----------------------------------------------------

IF "%COMMAND%" == "b" (
    git branch --sort=-committerdate > "%buff%"
    CALL :ShowList "Branches:"
)
IF "%COMMAND%" == "b+" (
    git branch -r > "%buff%"
    CALL :ShowList "Remote branches:"
)
IF "%COMMAND%" == "rnb" (
    ECHO Rename current branch:
    SET /p BRANCH=New name to current branch ^(e - cancel^):  
    IF NOT "!BRANCH!" == "e" (
        rem Создаем новую ветку из текущей с новым именем
        git checkout -b !BRANCH! !CURRENT_BRANCH!
        rem Удаляем локально
        git branch -d !CURRENT_BRANCH!
        rem Удаляем и в репоизитории
        git push origin --delete !CURRENT_BRANCH!
    )
)
IF "%COMMAND%" == "cb" (
    git branch --sort=-committerdate > "%buff%"
    CALL :SelectOneFromList "Select branch for checkout: "
    IF NOT [!ONEFORMLIST!] == [] (
        git checkout !ONEFORMLIST:~2!
    )
)
IF "%COMMAND%" == "cb+" (
    git branch -r > "%buff%"
    CALL :SelectOneFromList "Select remote branch for checkout: "
    IF NOT [!ONEFORMLIST!] == [] (
        git checkout -t !ONEFORMLIST:~2!
    )
)
IF "%COMMAND%" == "db" (
    git branch --sort=-committerdate > "%buff%"
    CALL :SelectOneFromList "Select branch for delete: "
    IF NOT [!ONEFORMLIST!] == [] (
        git branch -D !ONEFORMLIST:~2!
    )
)
IF "%COMMAND%" == "db+" (
    git branch -r > "%buff%"
    CALL :SelectOneFromList "Select remote branch for delete: "
    IF NOT [!ONEFORMLIST!] == [] (
        rem удаляем origin/
        git push origin --delete !ONEFORMLIST:~9!
    )
)
IF "%COMMAND%" == "ab" (
    ECHO Add branch from current branch:
    SET /p BRANCH=Branch name ^(e - cancel^):  
    IF NOT "!BRANCH!" == "e" (
        git checkout -b !BRANCH! !CURRENT_BRANCH!
    )
)
IF "%COMMAND%" == "bfc" (
    git log --pretty=format:"%%h | %%<(30)%%an | %%<(30)%%ar | %%s" > "%buff%"
    CALL :SelectOneFromList "Select commit for new branch: "
    IF NOT [!ONEFORMLIST!] == [] (
        ECHO Add branch from commit '!ONEFORMLIST:~0,8!'
        SET /p BRANCH=Branch name ^(e - cancel^):  
        IF NOT "!BRANCH!" == "e" (
            git checkout -b !BRANCH! !ONEFORMLIST:~0,8!
        )
    )
)
IF "%COMMAND%" == "bh" (
    git log --pretty=format:"%%h | %%<(30)%%an | %%<(30)%%ar | %%s" > "%buff%"
    CALL :ShowList "Branch history:"
)
IF "%COMMAND%" == "bp" (
    ECHO Remote prune origin:
    git remote prune origin
)

rem -----------------------------------------------------

IF "%COMMAND%" == "rc" (
    git log --pretty=format:"%%h | %%<(30)%%an | %%<(30)%%ar | %%s" > "%buff%"
    CALL :SelectOneFromList "Select commit for revert: "
    IF NOT [!ONEFORMLIST!] == [] (
        git revert !ONEFORMLIST:~0,8! --no-edit
    )
)

IF "%COMMAND%" == "chc" (
    git branch --sort=-committerdate > "%buff%"
    CALL :SelectOneFromList "Select branch for search commit to cherry-pick: "
    IF NOT [!ONEFORMLIST!] == [] (
        git log !ONEFORMLIST:~2! --pretty=format:"%%h | %%<(30)%%an | %%<(30)%%ar | %%s" > "%buff%"
        CALL :SelectOneFromList "Select commit for cherry-pick: "
        IF NOT [!ONEFORMLIST!] == [] (
            git cherry-pick !ONEFORMLIST:~0,8!
        )
    )
)

rem -----------------------------------------------------

IF "%COMMAND%" == "t" (
    git tag --sort=-creatordate > "%buff%"
    CALL :ShowList "Tags:"
)
IF "%COMMAND%" == "ftf" (
    ECHO Fetch tag force:
    git fetch --tags --force
)
IF "%COMMAND%" == "at" (
    ECHO Add tag on last commit:
    SET /p TAG=Tag name ^(e - cancel^):  
    IF NOT "!TAG!" == "e" (
        git tag !TAG!
        git push origin !TAG!
    )
)
IF "%COMMAND%" == "dt" (
    git tag --sort=-creatordate > "%buff%"
    CALL :SelectOneFromList "Select tag for delete: "
    IF NOT [!ONEFORMLIST!] == [] (
        git tag -d !ONEFORMLIST!
        git push --delete origin !ONEFORMLIST!
    )
)
IF "%COMMAND%" == "mt" (
    git tag --sort=-creatordate > "%buff%"
    CALL :SelectOneFromList "Select tag for move: "
    IF NOT [!ONEFORMLIST!] == [] (
        git tag -d !ONEFORMLIST!
        git push --delete origin !ONEFORMLIST!
        git tag !ONEFORMLIST!
        git push origin !ONEFORMLIST!
    )
)

rem -----------------------------------------------------

IF "%COMMAND%" == "hr" (
    ECHO Reset:
    git reset --hard HEAD
)
IF "%COMMAND%" == "cf" (
    git status -s > "%buff%"
    CALL :SelectOneFromList "Select file for checkout: "
    IF NOT [!ONEFORMLIST!] == [] (
        git checkout !ONEFORMLIST:~2!
    )
)

rem -----------------------------------------------------

IF "%COMMAND%" == "h" (
    ECHO Help:
    ECHO s   - show status
    ECHO a   - add unstorage files
    ECHO c   - commit all changed files
    ECHO p   - push to current branch
    ECHO pf  - push force to current branch
    ECHO cp  - commit all changed fales and push to current branch
    ECHO pl  - pull form current branch
    ECHO f   - fetch
    ECHO ff  - fetch force
    ECHO ------------------------
    ECHO m   - merge in current branch
    ECHO m+  - merge remote in current branch
    ECHO r   - rebase in current branch
    ECHO rc  - rebase continue
    ECHO rs  - rebase skip
    ECHO ra  - rebase abort
    ECHO ------------------------
    ECHO b   - branch list
    ECHO b+  - remote branch list
    ECHO rnb - rename current branch
    ECHO cb  - change branch 
    ECHO cb+ - change on remote branch 
    ECHO db  - delete branch 
    ECHO db+ - delete remote branch 
    ECHO ab  - add branch from current branch
    ECHO bfc - branch from commit
    ECHO bh  - current branch history
    ECHO bp  - remote branch prune
    ECHO ------------------------
    ECHO rc  - revert commit
    ECHO chc - cherry-pick commit
    ECHO ------------------------
    ECHO t   - tag list
    ECHO ftf - fetch tag force
    ECHO dt  - delete tag local and remote
    ECHO at  - add tag local and remote
    ECHO mt  - remove tag from old commit and add to current
    ECHO ------------------------
    ECHO cf  - checkout file
    ECHO hr  - hard reset branch
    ECHO ------------------------
    ECHO h   - help
    ECHO e   - exit
)

IF NOT "%COMMAND%" == "e" GOTO loop
rem EXIT /B %ERRORLEVEL%
EXIT /B 0


rem функция для вывода списка
:ShowList
SET /A OFFSET=0

:showListBegin
CLS
ECHO %~1
SET /A INDEX=0
rem данные читаем из временного файла
IF !OFFSET! LEQ 0 (
    SET SK=
    SET /A OFFSET=0
) ELSE (
    SET SK=skip=%OFFSET%
)
FOR /f "%SK%delims=" %%B in (%buff%) do (
    ECHO %%B
    rem инкрементируем нумерацию
    SET /A INDEX=INDEX+1
    rem ограничиваем вывод десятью строками
    IF !INDEX! == 10 (
        GOTO :showListEnd
    )
)
:showListEnd

CHOICE /C jke /N /M "j and k for scroll list, e - close: "
IF %ERRORLEVEL% EQU 1 (
    SET /A OFFSET=OFFSET+1
    GOTO :showListBegin
)
IF %ERRORLEVEL% EQU 2 (
    SET /A OFFSET=OFFSET-1
    GOTO :showListBegin
)
IF %ERRORLEVEL% EQU 3 (
    CLS
    EXIT /B 0
)

EXIT /B 0


rem функция для вывода списка
:SelectOneFromList
SET /A OFFSET=0
SET ONEFORMLIST=
SET SUBSTRING=

:selectOneFromListBegin
CLS
ECHO %~1
SET /A INDEX=0
rem данные читаем из временного файла
IF !OFFSET! LEQ 0 (
    SET SK=
    SET /A OFFSET=0
) ELSE (
    SET SK=skip=%OFFSET%
)

rem если указана подстрока то фильтруем по ней
IF NOT [!SUBSTRING!] == [] (
    ECHO Filter by "!SUBSTRING!"
    SET SOURCE='FINDSTR /Li /c:"%SUBSTRING%" %buff%'
) ELSE (
    SET SOURCE=%buff%
)

rem цикл прохождения по строкам
FOR /f "%SK%delims=" %%B in (%SOURCE%) do (
    rem выводим строки с нумераций
    ECHO %%B ^(!INDEX!^)
    rem инкрементируем нумерацию
    SET /A INDEX=INDEX+1
    rem ограничиваем вывод десятью строками
    IF !INDEX! == 10 (
        GOTO :selectOneFromListEnd
    )
)
:selectOneFromListEnd

CHOICE /C 0123456789jkefd /N /M "j and k for scroll list, e - close, f - filter, d - disable filter, 0-9 for make choice: "
rem список вниз
IF %ERRORLEVEL% EQU 11 (
    SET /A OFFSET=OFFSET+1
    GOTO :selectOneFromListBegin
)
rem список вверх
IF %ERRORLEVEL% EQU 12 (
    SET /A OFFSET=OFFSET-1
    GOTO :selectOneFromListBegin
)
rem выйти из выбора
IF %ERRORLEVEL% EQU 13 (
    CLS
    EXIT /B 0
)
rem поиск по подстроке
IF %ERRORLEVEL% EQU 14 (
    SET /p SUBSTRING=Substring to search ^(e - cancel^): 
    IF "!SUBSTRING!" == "e" (
        SET SUBSTRING=
    )
    GOTO :selectOneFromListBegin
)
rem сбрасываем поиск
IF %ERRORLEVEL% EQU 15 (
    SET SUBSTRING=
    GOTO :selectOneFromListBegin
)
rem выбор сделан находим вариант и возвращаем его
SET /A INDEX = 1
FOR /f "%SK%delims=" %%B in (%SOURCE%) do (
    IF !INDEX! == !ERRORLEVEL! (
        SET ONEFORMLIST=%%B
    )
    rem инкрементируем нумерацию
    SET /A INDEX=INDEX+1
)

EXIT /B 0
