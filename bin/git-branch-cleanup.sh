#!/bin/bash

source $(dirname $0)/lib/common.sh

function only_local_branches {
    local_branches="$(get_branches)"
    remote_branches="$(get_branches origin)"

    for branch in $local_branches; do
        echo $remote_branches | grep -v -q "$branch" && echo "$branch"
    done
}

# Kill branches that are only local and aren't on the remote
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

        confirm "Delete origin/${branch}? ($message)" && git push origin :$branch
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

# Find old branches
echo "OLD BRANCHES"
now=$(date +%s)
limit=$((90 * 24 * 60 * 60))

for branch in $(get_branches origin); do
    timestamp=$(get_branch_timestamp origin/$branch)

    if [ $((now - timestamp)) -gt $limit ]; then
        confirm "Delete ${branch}? (No commits for $(((now - timestamp) / (24 * 60 * 60))) days)" && git push origin :$branch
    fi
done
