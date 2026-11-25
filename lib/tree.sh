# dist/lib/tree.sh: where dist/bin's scripts find the tree's own scripts, the one
# place that names them (a move of the tree's scripts changes only this file).
# Sourced after HERE (dist/) is set; sets TREE (paths.env's TREE, absolute),
# TREE_BUILD (the tree's sys/src/build: manifests, steps, generators, lib) and
# TREE_SCRIPTS (its host/: the Linux host's guest, hw, debug, tests, ...), and
# sources the tree's sys/src/build/lib/paths.sh (all of paths.env and local.env
# exported).
TREE=$(cd -P "$HERE/.." && pwd -P)/$(sed -n 's/^TREE=//p' "$HERE/paths.env")
TREE_BUILD=$TREE/sys/src/build
TREE_SCRIPTS=$TREE_BUILD/host
ROOT=$TREE
. "$TREE_BUILD/lib/paths.sh"
