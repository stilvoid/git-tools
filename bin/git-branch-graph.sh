#!/bin/bash

source $(dirname $0)/lib/common.sh

remote=${1:-origin}

function branch_graph {
    for branch in $(get_branches $remote); do
        author=$(git log -n 1 $remote/$branch | grep "Author:" | sed -e 's/Author: //' | sed -e 's/ <.*>//')

        echo "\"$branch\" [label=\"$branch|$author\"];"

        for descendent in $(get_descendents $remote $remote/$branch); do
            echo -n "    "
            echo "\"$branch\" -> \"$descendent\";"
        done

        for merged in $(get_merged $remote $remote/$branch); do
            echo -n "    "
            echo "\"$merged\" -> \"$branch\";"
        done
    done
}

echo "digraph {"
echo "    rankdir=LR;"
echo "    node [shape=record];"
    branch_graph | sort -u # De-dupe
echo "}"
