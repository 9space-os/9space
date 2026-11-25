# dist/lib/tree.sh: where dist/bin's scripts find the tree's own scripts, the one
# place that names them (a move of the tree's scripts changes only this file).
# Sourced after HERE (dist/) is set; sets TREE (paths.env's TREE, absolute) and
# TREE_SCRIPTS, and sources the tree's scripts/lib/paths.sh (all of paths.env and
# local.env exported).
TREE=$(cd -P "$HERE/.." && pwd -P)/$(sed -n 's/^TREE=//p' "$HERE/paths.env")
TREE_SCRIPTS=$TREE/scripts
ROOT=$TREE
. "$TREE_SCRIPTS/lib/paths.sh"
