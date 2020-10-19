#!/bin/bash

buff=$(mktemp /tmp/cgw-$RANDOM.XXXXXX)

# функции
ShowList()
{
    valid=true
    while [ valid ]
    do
        clear

        echo $@
        IFS=$'\n' read -d '' -r -a LINES < "$buff"
        OFFSER=0

        for (( INDEX=0; INDEX<10; INDEX++ ))
        do
            CURENT_INDEX=$(($OFFSET + $INDEX))
            echo "${LINES[CURENT_INDEX]}"
        done

        read -n1 -p "j and k for scroll list, e - close: " LEVEL
        if [ "$LEVEL" = "e" ];
        then
            clear
            break;
        elif [ "$LEVEL" = "j" ];
        then
            OFFSET=$(($OFFSET + 1))
        elif [ "$LEVEL" = "k" ];
        then
            OFFSET=$(($OFFSET - 1))
        fi
    done
}

# основной цикл
valid=true
while [ valid ]
do
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    CURRENT_PATH=$(pwd)

    echo "______________________________________________________________"
    echo "Branch $CURRENT_BRANCH Path: $CURRENT_PATH"
    read -p "What you want? " COMMAND
    clear

    if [ "$COMMAND" = "s" ];
    then
        git status -s > "$buff"
        ShowList "Status:"
    elif [ "$COMMAND" = "c" ];
    then
        echo "Files add to commit:"

        git status -s |
        while read -r LINE
        do
            if [ "${LINE:0:2}" = " D" ];
            then
                GITCOMMAND="rm"
            else
                GITCOMMAND="add"
                echo "add ${LINE:3}"
            fi
            git $GITCOMMAND "${LINE:3}"
        done

        read -p "Commit test (e -cancel): " COMMIT
        if [ "$COMMIT" != "e" ];
        then
            git commit -m $COMMIT
        fi
    elif [ "$COMMAND" = "p" ];
    then
        echo "Push:"
        git push origin $CURRENT_BRANCH
    elif [ "$COMMAND" = "cp" ];
    then
        echo "Files add to commit:"

        git status -s |
        while read -r LINE
        do
            if [ "${LINE:0:2}" = " D" ];
            then
                GITCOMMAND="rm"
            else
                GITCOMMAND="add"
                echo "add ${LINE:3}"
            fi
            git $GITCOMMAND "${LINE:3}"
        done

        read -p "Commit test (e -cancel): " COMMIT
        if [ "$COMMIT" != "e" ];
        then
            git commit -m "$COMMIT"
            git push origin $CURRENT_BRANCH
        fi
    elif [ "$COMMAND" = "pl" ];
    then
        echo "Pull:"
        git pull origin $CURRENT_BRANCH
    elif [ "$COMMAND" = "h" ];
    then
        echo "Help:"
        echo "s   - show status"
        echo "c   - commit all changed files"
        echo "p   - push to current branch"
        echo "cp  - commit all changed fales and push to current branch"
        echo "pl  - pull form current branch"
        echo "f   - fetch"
        echo "------------------------"
        echo "m   - merge in current branch"
        echo "m+  - merge remote in current branch"
        echo "b   - branch list"
        echo "b+  - remote branch list"
        echo "rnb - rename current branch"
        echo "cb  - change branch "
        echo "cb+ - change on remote branch "
        echo "db  - delete branch "
        echo "db+ - delete remote branch "
        echo "ab  - add branch from current branch"
        echo "bh  - current branch history"
        echo "------------------------"
        echo "rc  - revert commit"
        echo "------------------------"
        echo "t   - tag list"
        echo "ftf - fetch tag force"
        echo "dt  - delete tag local and remote"
        echo "at  - add tag local and remote"
        echo "mt  - remove tag from old commit and add to current"
        echo "------------------------"
        echo "cf  - checkout file"
        echo "r   - reset branch"
        echo "------------------------"
        echo "h   - help"
        echo "e   - exit"
    elif [ "$COMMAND" = "e" ];
    then
        break
    fi
done
