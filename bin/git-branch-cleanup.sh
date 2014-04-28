#!/bin/bash

source $(dirname $0)/lib/common.sh

function only_local_branches {
    local_branches="$(get_branches)"
    remote_branches="$(get_branches origin)"

    for branch in $local_branches; do
        echo $remote_branches | grep -v -q "$branch" && echo "$branch"
    done
}

# Kill remote branches that have been merged
echo "MERGED REMOTE BRANCHES"
for branch in $(get_branches origin); do
    descendents=( $(get_descendents origin origin/$branch) )

    if [ ${#descendents[@]} -gt 0 ]; then
        if [ ${#descendents[@]} -eq 1 ]; then
            message="Contained in $descendents"
        else
            message="Contained in ${#descendents[@]} other branches"
        fi

        confirm "Delete origin/${branch}? ($message)" && echo KILLED || echo SAVED
        echo
    fi
done

# Kill local branches that have been merged
echo "MERGED LOCAL BRANCHES"
for branch in $(get_branches); do
    descendents=( $(get_descendents origin $branch) )

    if [ ${#descendents[@]} -gt 0 ]; then
        if [ ${#descendents[@]} -eq 1 ]; then
            message="Contained in $descendents"
        else
            message="Contained in ${#descendents[@]} other branches"
        fi

        confirm "Delete ${branch}? ($message)" && git branch -D $branch
        echo
    fi
done

# Kill branches that are only local and have not been pushed
echo "UNPUSHED BRANCHES"
for branch in $(only_local_branches); do
    descendents=( $(get_descendents $branch) )

    if [ ${#descendents[@]} -eq 0 ]; then
        message="Not available elsewhere"
    elif [ ${#descendents[@]} -eq 1 ]; then
        message="Contained in $descendents"
    else
        message="Contained in ${#descendents[@]} other branches"
    fi

    confirm "Delete ${branch}? ($message)" && git branch -D $branch
    echo
done
