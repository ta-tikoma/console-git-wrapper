@echo off

if "%~1"==":cgw" goto :cgw
cmd /c "%~f0" :cgw
exit /b
:cgw

SETLOCAL ENABLEDELAYEDEXPANSION
SET LC_ALL=C.UTF-8

REM define buffer file
SET "buff=%tmp%\cgw~%RANDOM%.tmp"

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
    SET /p COMMIT=Commit text ^(e - cancel^)? 
    IF NOT "%COMMIT%" == "e" (
        ECHO ^("!COMMIT!"^)
        git commit -m "!COMMIT!"
    )
)
IF "%COMMAND%" == "p" (
    ECHO Push:
    git push origin !CURRENT_BRANCH!
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
    SET /p COMMIT=Commit text? 
    IF NOT "%COMMIT%" == "e" (
        git commit -m "!COMMIT!"
    )
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

rem -----------------------------------------------------

IF "%COMMAND%" == "m" (
    git branch --sort=-committerdate > "%buff%"
    CALL :SelectOneFromList "Select branch for merge in current"
    IF NOT [!ONEFORMLIST!] == [] (
        git merge --no-ff !ONEFORMLIST:~2!
    )
)
IF "%COMMAND%" == "m+" (
    git branch -r > "%buff%"
    CALL :SelectOneFromList "Select remote branch for merge in current"
    IF NOT [!ONEFORMLIST!] == [] (
        git merge --no-ff !ONEFORMLIST:~2!
    )
)
IF "%COMMAND%" == "b" (
    git branch --sort=-committerdate > "%buff%"
    CALL :ShowList "Branches:"
)
IF "%COMMAND%" == "cb" (
    git branch --sort=-committerdate > "%buff%"
    CALL :SelectOneFromList "Select branch for checkout"
    IF NOT [!ONEFORMLIST!] == [] (
        git checkout !ONEFORMLIST:~2!
    )
)
IF "%COMMAND%" == "cb+" (
    git branch -r > "%buff%"
    CALL :SelectOneFromList "Select remote branch for checkout"
    IF NOT [!ONEFORMLIST!] == [] (
        git checkout -t !ONEFORMLIST:~2!
    )
)
IF "%COMMAND%" == "db" (
    git branch --sort=-committerdate > "%buff%"
    CALL :SelectOneFromList "Select branch for delete"
    IF NOT [!ONEFORMLIST!] == [] (
        git branch -d !ONEFORMLIST:~2!
    )
)
IF "%COMMAND%" == "db+" (
    git branch -r > "%buff%"
    CALL :SelectOneFromList "Select remote branch for delete"
    IF NOT [!ONEFORMLIST!] == [] (
        git push origin --delete !ONEFORMLIST:~2!
    )
)
IF "%COMMAND%" == "ab" (
    ECHO Add branch from current branch:
    SET /p BRANCH=Branch name? 
    IF NOT "%BRANCH%" == "e" (
        git checkout -b !BRANCH! !CURRENT_BRANCH!
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
    SET /p TAG=Tag name? 
    IF NOT "%TAG%" == "e" (
        git tag !TAG!
        git push origin !TAG!
    )
)
IF "%COMMAND%" == "dt" (
    git tag --sort=-creatordate > "%buff%"
    CALL :SelectOneFromList "Select tag for delete"
    IF NOT [!ONEFORMLIST!] == [] (
        git tag -d !ONEFORMLIST!
        git push --delete origin !ONEFORMLIST!
    )
)

rem -----------------------------------------------------

IF "%COMMAND%" == "r" (
    ECHO Reset:
    git reset --hard HEAD
)
IF "%COMMAND%" == "cf" (
    git status -s > "%buff%"
    CALL :SelectOneFromList "Select file for checkout"
    IF NOT [!ONEFORMLIST!] == [] (
        git checkout !ONEFORMLIST:~2!
    )
)
IF "%COMMAND%" == "h" (
    ECHO Help:
    ECHO s   - show status
    ECHO c   - commit all changed files
    ECHO p   - push to current branch
    ECHO cp  - commit all changed fales and push to current branch
    ECHO pl  - pull form current branch
    ECHO f   - fetch
    ECHO ------------------------
    ECHO m   - merge in current branch
    ECHO m+  - merge remote in current branch
    ECHO b   - branch list
    ECHO cb  - change branch 
    ECHO cb+ - change on remote branch 
    ECHO db  - delete branch 
    ECHO db+ - delete remote branch 
    ECHO ab  - add branch from current branch
    ECHO ------------------------
    ECHO t   - tag list
    ECHO ftf - fetch tag force
    ECHO dt  - delete tag local and remote
    ECHO at  - add tag local and remote
    ECHO ------------------------
    ECHO cf  - checkout file
    ECHO r   - reset branch
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

CHOICE /C jke /N /M "j and k for scroll list, e - close"
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
FOR /f "%SK%delims=" %%B in (%buff%) do (
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

CHOICE /C 0123456789jke /N /M "j and k for scroll list, e - close, 0-9 for make choice"
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
rem выбор сделан находим вариант и возвращаем его
SET /A INDEX = 1
FOR /f "%SK%delims=" %%B in (%buff%) do (
    IF !INDEX! == !ERRORLEVEL! (
        SET ONEFORMLIST=%%B
    )
    rem инкрементируем нумерацию
    SET /A INDEX=INDEX+1
)

EXIT /B 0
