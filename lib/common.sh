# Strip the remote
function strip_remote {
    cat | sed -e 's/^ *.*\///'
}

# Limit remote
function limit_remote {
    grep "^ *${1}/" | strip_remote
}

# Get the current branch
function get_current_branch {
    git branch | grep "^*" | awk '{print $2}'
}

# Get all branches
function get_branches {
    remote=$1

    if [ -z "$remote" ]; then
        git branch | sed -e 's/^\*\? *//'
    else
        git branch -r | limit_remote $remote
    fi
}

# Get remote branches contained in the specified branch
# TODO: As get_descendents but with --merged

# Get remote branches containing the specified branch
function get_descendents {
    remote=$1
    branch=$2

    if [ -z "$branch" ]; then
        branch=$remote
        git branch --contains $branch | sed -e 's/^\*\? *//' | grep -v "^${branch}$"
    else
        b=$(echo $branch | strip_remote)
        git branch -r --contains $branch | limit_remote $remote | grep -v "^${b}$"
    fi
}

function confirm {
    message=$1

    read -p "$message [Y/n] " yn

    [ "$yn" == "Y" -o "$yn" == "y" -o -z "$yn" ]
}
