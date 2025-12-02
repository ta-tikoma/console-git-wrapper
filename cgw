#!/bin/bash

buff=$(mktemp /tmp/cgw-$RANDOM.XXXXXX)
buff2=$(mktemp /tmp/cgw2-$RANDOM.XXXXXX)

# функции
ShowList()
{
    OFFSET=0
    valid=true

    while [ valid ]
    do
        clear

        echo $@
        IFS=$'\n' read -d '' -r -a LINES < "$buff"

        for (( INDEX=0; INDEX<10; INDEX++ ))
        do
            local CURENT_INDEX=$(($OFFSET + $INDEX))
            echo "${LINES[CURENT_INDEX]}"
        done

        read -n1 -p "j and k for scroll list, e - close: " LEVEL
        if [ "$LEVEL" = "e" ]; then
            clear
            break;
        elif [ "$LEVEL" = "j" ]; then
            if [ $(($OFFSET + 10 + 1)) -le ${#LINES[@]} ]; then
                OFFSET=$(($OFFSET + 1))
            fi
        elif [ "$LEVEL" = "k" ]; then
            if [ $(($OFFSET - 1)) -ge 0 ]; then
                OFFSET=$(($OFFSET - 1))
            fi
        fi
    done
}

SelectOneFromList()
{
    ONEFORMLIST=""
    FILTER=""
    OFFSET=0
    valid=true

    while [ valid ]
    do
        clear

        echo $@

        if [ "$FILTER" != "" ];
        then
            cat "$buff" | grep "$FILTER" > "$buff2"
            IFS=$'\n' read -d '' -r -a LINES < "$buff2"
        else
            IFS=$'\n' read -d '' -r -a LINES < "$buff"
        fi

        for (( INDEX=0; INDEX<10; INDEX++ ))
        do
            CURENT_INDEX=$(($OFFSET + $INDEX))
            if [ "$CURENT_INDEX" = "${#LINES[@]}" ]
            then
                break
            fi
            echo "$INDEX ${LINES[CURENT_INDEX]}"
        done

        read -n1 -p "j and k for scroll list, e - close, f - filter, d - disable filter, 0-9 for make choice: " LEVEL
        if [ "$LEVEL" = "e" ]; then
            clear
            break
        elif [ "$LEVEL" = "j" ]; then
            if [ $(($OFFSET + 11)) -le ${#LINES[@]} ]; then
                OFFSET=$(($OFFSET + 1))
            fi
        elif [ "$LEVEL" = "k" ]; then
            if [ $(($OFFSET - 1)) -ge 0 ]; then
                OFFSET=$(($OFFSET - 1))
            fi
        elif [ "$LEVEL" = "d" ]; then
            FILTER=""
        elif [ "$LEVEL" = "f" ]; then
            echo ""
            read -e -p "Substring to search (e - cansel): " FILTER
            if [ "$FILTER" = "e" ]; then
                FILTER=""
            fi
        else
            CURENT_INDEX=$(($OFFSET + $LEVEL))
            ONEFORMLIST="${LINES[CURENT_INDEX]}"
            clear
            break
        fi
    done
}

# история файла
if [ ! -z "$1" ]; then
    while true
    do
        git log --pretty=format:"%h | %<(30)%an | %<(30)%ar | %s" "$1" > "$buff"
        SelectOneFromList "File history:"
        if [ "$ONEFORMLIST" != "" ]; then
            git show --output="$buff" "${ONEFORMLIST:0:8}" -- "$1"
            # read -p "Press any key to continue... " -n1 -s
            # git show "${ONEFORMLIST:0:8}" -- "$1" > "$buff"
            ShowList "Commit ${ONEFORMLIST:0:8}:"
        else
            exit 0
        fi
    done
fi

# основной цикл
valid=true
while [ valid ]
do
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    CURRENT_PATH=$(pwd)

    echo "______________________________________________________________"
    echo "Branch $CURRENT_BRANCH Path: $CURRENT_PATH"
    read -e -p "What you want? " COMMAND
    clear

    if [ "$COMMAND" = "s" ];
    then
        git status -s > "$buff"
        ShowList "Status:"
    elif [ "$COMMAND" = "a" ];
    then
        echo "Add files:"
        git status -s
        git add .
    elif [ "$COMMAND" = "c" ];
    then
        echo "Files add to commit:"

        git status -s
        git add .
        # git status -s |
        # while read -r LINE
        # do
        #     if [ "${LINE:0:2}" = " D" ];
        #     then
        #         GITCOMMAND="rm"
        #     else
        #         GITCOMMAND="add"
        #         echo "add ${LINE:2}"
        #     fi
        #     git $GITCOMMAND "${LINE:2}"
        # done

        read -e -p "Commit test (e -cancel): " COMMIT
        if [ "$COMMIT" != "e" ];
        then
            git commit -m $COMMIT
        fi
    elif [ "$COMMAND" = "p" ];
    then
        echo "Push:"
        git push origin $CURRENT_BRANCH
    elif [ "$COMMAND" = "pf" ];
    then
        echo "Push force:"
        git push -f origin $CURRENT_BRANCH
    elif [ "$COMMAND" = "cp" ];
    then
        echo "Files add to commit:"

        git status -s
        git add .
        # git status -s |
        # while read -r LINE
        # do
        #     if [ "${LINE:0:2}" = " D" ];
        #     then
        #         GITCOMMAND="rm"
        #     else
        #         GITCOMMAND="add"
        #         echo "add ${LINE:2}"
        #     fi
        #     git $GITCOMMAND "${LINE:2}"
        # done

        read -e -p "Commit test (e - cancel): " COMMIT
        if [ "$COMMIT" != "e" ];
        then
            git commit -m "$COMMIT"
            git push origin $CURRENT_BRANCH
        fi
    elif [ "$COMMAND" = "pl" ];
    then
        echo "Pull:"
        git pull origin $CURRENT_BRANCH
    elif [ "$COMMAND" = "ff" ];
    then
        echo "Fetch force:"
        git fetch --force
    # --------------------------------------------
    elif [ "$COMMAND" = "m" ];
    then
        git branch --sort=-committerdate > "$buff"
        SelectOneFromList "Select branch for merge in current: "
        if [ "$ONEFORMLIST" != "" ];
        then
             git merge --no-ff --no-edit "${ONEFORMLIST:2}"
        fi
    elif [ "$COMMAND" = "m+" ];
    then
        git branch -r > "$buff"
        SelectOneFromList "Select remote branch for merge in current: "
        if [ "$ONEFORMLIST" != "" ];
        then
             git merge --no-ff --no-edit "${ONEFORMLIST:2}"
        fi
    elif [ "$COMMAND" = "r" ];
    then
        git branch --sort=-committerdate > "$buff"
        SelectOneFromList "Select branch for rebase in current: "
        if [ "$ONEFORMLIST" != "" ];
        then
             git pull --rebase origin "${ONEFORMLIST:2}"
        fi
    elif [ "$COMMAND" = "rc" ];
    then
        git rebase --continue
    elif [ "$COMMAND" = "rs" ];
    then
        git rebase --skip
    elif [ "$COMMAND" = "ra" ];
    then
        git rebase --abort
    # --------------------------------------------
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
        read -e -p "New name to current branch (e - cancel): " BRANCH
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
    elif [ "$COMMAND" = "db" ];
    then
        git branch --sort=-committerdate > "$buff"
        SelectOneFromList "Select branch for delete: "
        if [ "$ONEFORMLIST" != "" ];
        then
            git branch -D "${ONEFORMLIST:2}"
        fi
    elif [ "$COMMAND" = "db+" ];
    then
        git branch -r > "$buff"
        SelectOneFromList "Select remote branch for delete: "
        if [ "$ONEFORMLIST" != "" ];
        then
            git push origin --delete  "${ONEFORMLIST:9}"
        fi
    elif [ "$COMMAND" = "ab" ];
    then
        echo "Add branch from current branch"
        read -e -p "Branch name (e - cancel): " BRANCH
        if [ "$BRANCH" != "e" ];
        then
            git checkout -b  "$BRANCH" "$CURRENT_BRANCH"
        fi
    elif [ "$COMMAND" = "bfc" ];
    then
        git log --pretty=format:"%h | %<(30)%an | %<(30)%ar | %s" > "$buff"
        SelectOneFromList "Select commit for new branch: "
        if [ "$ONEFORMLIST" != "" ];
        then
            echo "Add branch from commit ${ONEFORMLIST:0:7}"
            read -e -p "Branch name (e - cancel): " BRANCH
            if [ "$BRANCH" != "e" ];
            then
                git checkout -b  "$BRANCH" "${ONEFORMLIST:0:7}"
            fi
        fi
    elif [ "$COMMAND" = "bh" ];
    then
        git log --pretty=format:"%h | %<(30)%an | %<(30)%ar | %s" > "$buff"
        ShowList "Branch history:"
    elif [ "$COMMAND" = "bp" ];
    then
        echo "Remote prune origin:"
        git remote prune origin
    # --------------------------------------------
    elif [ "$COMMAND" = "rc" ];
    then
        git log --pretty=format:"%h | %<(30)%an | %<(30)%ar | %s" > "$buff"
        SelectOneFromList "Select commit for revert: "
        if [ "$ONEFORMLIST" != "" ];
        then
            git revert "${ONEFORMLIST:0:7}" --no-edit
            echo
        fi
    elif [ "$COMMAND" = "chc" ];
    then
        git branch --sort=-committerdate > "$buff"
        SelectOneFromList "Select branch for search commit to cherry-pick: "
        if [ "$ONEFORMLIST" != "" ];
        then
            git log "${ONEFORMLIST:2}" --pretty=format:"%h | %<(30)%an | %<(30)%ar | %s" > "$buff"
            SelectOneFromList "Select commit for cherry-pick: "
            if [ "$ONEFORMLIST" != "" ];
            then
                git cherry-pick "${ONEFORMLIST:0:7}" --no-edit
                echo
            fi
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
        read -e -p "Tag name (e - cancel): " TAG
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
    elif [ "$COMMAND" = "hr" ];
    then
        echo "Reset:"
        git reset --hard HEAD
    elif [ "$COMMAND" = "cf" ]; then
        git status -s > "$buff"
        SelectOneFromList "Select file for checkout: "
        if [ "$ONEFORMLIST" != "" ];
        then
            git checkout "${ONEFORMLIST:3}"
        fi
    elif [ "$COMMAND" = "h" ]; then
        echo "Help:"
        echo "s   - show status"
        echo "a   - add unstorage files"
        echo "c   - commit all changed files"
        echo "p   - push to current branch"
        echo "pf  - push force to current branch"
        echo "cp  - commit all changed fales and push to current branch"
        echo "pl  - pull form current branch"
        echo "f   - fetch"
        echo "ff  - fetch force"
        echo "------------------------"
        echo "m   - merge in current branch"
        echo "m+  - merge remote in current branch"
        echo "r   - rebase in current branch"
        echo "rc  - rebase continue"
        echo "rs  - rebase skip"
        echo "ra  - rebase abort"
        echo "------------------------"
        echo "b   - branch list"
        echo "b+  - remote branch list"
        echo "rnb - rename current branch"
        echo "cb  - change branch "
        echo "cb+ - change on remote branch "
        echo "db  - delete branch "
        echo "db+ - delete remote branch "
        echo "ab  - add branch from current branch"
        echo "bfc - branch from commit"
        echo "bh  - current branch history"
        echo "bp  - remote branch prune"
        echo "------------------------"
        echo "rc  - revert commit"
        echo "chc - cherry-pick commit"
        echo "------------------------"
        echo "t   - tag list"
        echo "ftf - fetch tag force"
        echo "dt  - delete tag local and remote"
        echo "at  - add tag local and remote"
        echo "mt  - remove tag from old commit and add to current"
        echo "------------------------"
        echo "cf  - checkout file"
        # echo "fh  - file history"
        echo "hr  - hard reset branch"
        echo "------------------------"
        echo "h   - help"
        echo "e   - exit"
    elif [ "$COMMAND" = "e" ];
    then
        break
    fi
done
