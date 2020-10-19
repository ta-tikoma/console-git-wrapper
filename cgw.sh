#!/bin/bash

buff=$(mktemp /tmp/cgw-$RANDOM.XXXXXX)

# функции
ShowList()
{
    OFFSER=0
    valid=true

    while [ valid ]
    do
        clear

        echo $@
        IFS=$'\n' read -d '' -r -a LINES < "$buff"

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

SelectOneFromList()
{
    ONEFORMLIST=""
    OFFSER=0
    valid=true

    while [ valid ]
    do
        clear

        echo $@
        IFS=$'\n' read -d '' -r -a LINES < "$buff"

        for (( INDEX=0; INDEX<10; INDEX++ ))
        do
            CURENT_INDEX=$(($OFFSET + $INDEX))
            echo "$INDEX ${LINES[CURENT_INDEX]}"
        done

        read -n1 -p "j and k for scroll list, e - close: " LEVEL
        if [ "$LEVEL" = "e" ];
        then
            clear
            break
        elif [ "$LEVEL" = "j" ];
        then
            OFFSET=$(($OFFSET + 1))
        elif [ "$LEVEL" = "k" ];
        then
            OFFSET=$(($OFFSET - 1))
        else
            CURENT_INDEX=$(($OFFSET + $LEVEL))
            ONEFORMLIST="${LINES[CURENT_INDEX]}"
            clear
            break
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
                echo "add ${LINE:2}"
            fi
            git $GITCOMMAND "${LINE:2}"
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
                echo "add ${LINE:2}"
            fi
            git $GITCOMMAND "${LINE:2}"
        done

        read -p "Commit test (e - cancel): " COMMIT
        if [ "$COMMIT" != "e" ];
        then
            git commit -m "$COMMIT"
            git push origin $CURRENT_BRANCH
        fi
    elif [ "$COMMAND" = "pl" ];
    then
        echo "Pull:"
        git pull origin $CURRENT_BRANCH
    # --------------------------------------------
    elif [ "$COMMAND" = "m" ];
    then
        git branch --sort=-committerdate > "$buff"
        SelectOneFromList "Select branch for merge in current: "
        if [ "$ONEFORMLIST" != "" ];
        then
             git merge --no-ff "${ONEFORMLIST:2}"
        fi
    elif [ "$COMMAND" = "m+" ];
    then
        git branch -r > "$buff"
        SelectOneFromList "Select remote branch for merge in current: "
        if [ "$ONEFORMLIST" != "" ];
        then
             git merge --no-ff "${ONEFORMLIST:2}"
        fi
    elif [ "$COMMAND" = "b" ];
    then
        git branch --sort=-committerdate > "$buff"
        ShowList "Branches:"
    elif [ "$COMMAND" = "b+" ];
    then
        git branch -r > "$buff"
        ShowList "Remote branches:"
    elif [ "$COMMAND" = "rnb" ];
    then
        echo "Rename current branch:"
        read -p "New name to current branch (e - cancel): " BRANCH
        if [ "$BRANCH" != "e" ];
        then
            git checkout -b "$BRANCH" "$CURRENT_BRANCH"
            git branch -d "$CURRENT_BRANCH"
            git push origin --delete "$CURRENT_BRANCH"
        fi
    elif [ "$COMMAND" = "cb" ];
    then
        git branch --sort=-committerdate > "$buff"
        SelectOneFromList "Select branch for checkout: "
        if [ "$ONEFORMLIST" != "" ];
        then
            git checkout "${ONEFORMLIST:2}"
        fi
    elif [ "$COMMAND" = "cb+" ];
    then
        git branch -r > "$buff"
        SelectOneFromList "Select remote branch for checkout: "
        if [ "$ONEFORMLIST" != "" ];
        then
            git checkout -t "${ONEFORMLIST:2}"
        fi
    elif [ "$COMMAND" = "ab" ];
    then
        echo "Add branch from current branch"
        read -p "Branch name (e - cancel): " BRANCH
        if [ "$BRANCH" != "e" ];
        then
            git checkout -b  "$BRANCH" "$CURRENT_BRANCH"
        fi
    elif [ "$COMMAND" = "bh" ];
    then
        git log --pretty=format:"%%h | %%<(30)%%an | %%<(30)%%ar | %%s" > "$buff"
        ShowList "Branch history:"
    # --------------------------------------------
    elif [ "$COMMAND" = "rc" ];
    then
        git log --pretty=format:"%%h | %%<(30)%%an | %%<(30)%%ar | %%s" > "$buff"
        SelectOneFromList "Select commit for revert: "
        if [ "$ONEFORMLIST" != "" ];
        then
            # git revert !ONEFORMLIST:~0,8! --no-edit
            echo "${ONEFORMLIST:8}"
        fi
    # --------------------------------------------
    elif [ "$COMMAND" = "t" ];
    then
        git tag --sort=-creatordate > "$buff"
        ShowList "Tags:"
    elif [ "$COMMAND" = "ftf" ];
    then
        echo "Fetch tag force:"
        git fetch --tags --force
    elif [ "$COMMAND" = "at" ];
    then
        echo "Add tag on last commit:"
        read -p "Tag name (e - cancel): " TAG
        if [ "$TAG" != "e" ];
        then
            git tag "$TAG"
            git push origin "$TAG"
        fi
    elif [ "$COMMAND" = "dt" ];
    then
        git tag --sort=-creatordate > "$buff"
        SelectOneFromList "Select tag for delete: "
        if [ "$ONEFORMLIST" != "" ];
        then
            git tag -d "$ONEFORMLIST"
            git push --delete origin "$ONEFORMLIST"
        fi
    elif [ "$COMMAND" = "mt" ];
    then
        git tag --sort=-creatordate > "$buff"
        SelectOneFromList "Select tag for move: "
        if [ "$ONEFORMLIST" != "" ];
        then
            git tag -d "$ONEFORMLIST"
            git push --delete origin "$ONEFORMLIST"
            git tag "$ONEFORMLIST"
            git push origin "$ONEFORMLIST"
        fi
    # --------------------------------------------
    elif [ "$COMMAND" = "r" ];
    then
        echo "Reset:"
        git reset --hard HEAD
    elif [ "$COMMAND" = "cf" ];
    then
        git status -s > "$buff"
        SelectOneFromList "Select file for checkout: "
        if [ "$ONEFORMLIST" != "" ];
        then
            git checkout "${ONEFORMLIST:2}"
        fi
    # --------------------------------------------
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
