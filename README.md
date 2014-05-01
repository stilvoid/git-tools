# Git tools

A collection of git commands to provide some common, useful functionality when managing sizeable projects.

## TODO

* Support a branch glob for all commands.

## Commands

* `git branch-graph <remote>`

    Draws a graph of the relationships between branches on the specified remote.

* `git branch-cleanup [-l] [-f] <remote>`

    `branch-cleanup` helps identify branches that are no longer in use and then deletes them for you, confirming each one first (unless you specify the `-f` option).

    The following branches are considered for deletion:

    * Local branches that are no longer on the specified remote

    * Local branches that are fully merged into other remote branches

    * Remote branches that are fully merged into other remote branches

    * Local and remote branches that haven't had a commit for 3 months

    If the `-l` option is specified, only local branches are checked.
