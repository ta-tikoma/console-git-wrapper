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

IF "%COMMAND%" == "s" (
    ECHO Status:
    git status -s > "%buff%"
    CALL :ShowList
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
IF "%COMMAND%" == "t" (
    ECHO Tag list:
    git tag --sort=-creatordate
)
IF "%COMMAND%" == "ft" (
    ECHO Fetch tag:
    git fetch --tags --force
)
IF "%COMMAND%" == "nb" (
    ECHO New branch from current branch:
    SET /p BRANCH=Branch name? 
    git checkout -b !BRANCH! !CURRENT_BRANCH!
)
IF "%COMMAND%" == "at" (
    ECHO Add tag on last commit:
    SET /p TAG=Tag name? 
    git tag !TAG!
    git push origin !TAG!
)
IF "%COMMAND%" == "cf" (
    git status -s > "%buff%"
    CALL :SelectOneFromList "Select file for checkout"
    IF NOT [!ONEFORMLIST!] == [] (
        git checkout !ONEFORMLIST:~2!
    )
)
IF "%COMMAND%" == "m" (
    ECHO Select branch for merge in current:
    SET /A INDEX=1
    FOR /f "delims=" %%B in ('git branch') do (
        ECHO %%B -[!INDEX!]
        SET /A INDEX=INDEX+1
    )
    SET /p BRANCHNUMBER=Branch number? 
    SET /A INDEX=1
    FOR /f "delims=" %%B in ('git branch') do (
        IF !INDEX! == !BRANCHNUMBER! (
            SET BRANCH=%%B
            git merge --no-ff !BRANCH:~2!
            GOTO loop
        )
        SET /A INDEX=INDEX+1
    )
)
IF "%COMMAND%" == "cb" (
    ECHO Select branch for checkout:
    SET /A INDEX=1
    FOR /f "delims=" %%B in ('git branch') do (
        ECHO %%B -[!INDEX!]
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
    ECHO Select branch for remove:
    SET /A INDEX=1
    FOR /f "delims=" %%B in ('git branch') do (
        ECHO %%B -[!INDEX!]
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
IF "%COMMAND%" == "dt" (
    ECHO Select tag for delete:
    SET /A INDEX=1
    FOR /f "delims=" %%B in ('git tag --sort=-creatordate') do (
        ECHO %%B -[!INDEX!]
        SET /A INDEX=INDEX+1
    )
    SET /p TAGNUMBER=Tag number? 
    SET /A INDEX=1
    FOR /f "delims=" %%B in ('git tag --sort=-creatordate') do (
        IF !INDEX! == !TAGNUMBER! (
            SET TAG=%%B
            git tag -d !TAG!
            git push --delete origin !TAG!
            GOTO loop
        )
        SET /A INDEX=INDEX+1
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
    ECHO b   - branch list
    ECHO cb  - change branch 
    ECHO rb  - remove branch 
    ECHO nb  - new branch from current branch
    ECHO ------------------------
    ECHO t   - tag list
    ECHO ft  - fetch tag
    ECHO dt  - delete tag
    ECHO at  - add tag
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
    ECHO !INDEX! %%B
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
