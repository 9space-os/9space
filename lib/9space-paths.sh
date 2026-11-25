# dist/lib/9space-paths.sh: where 9space's parts are, the one reader of
# paths.env for every part's shell scripts (the tree's sys/src/build/lib/paths.sh,
# the toolchains' and tools' scripts/9space-paths.sh source it).
# Exports each variable of paths.env that the environment does not set
# already, as an absolute path.  paths.env: $NINESPACE_PATHS, else the one
# beside this file (dist/paths.env).  paths.env is the only place with
# paths (dist/CLAUDE.9space.md): without it an error, no fallbacks.
# local.env beside it (not in git) holds one checkout's own settings
# (INSTANCE_DIR, or a path of paths.env set otherwise): it wins over
# paths.env, the environment over both.  A value: absolute, ~/... (the
# home directory) or relative to the umbrella.
__9space_paths(){
	local f top line k v
	f=${NINESPACE_PATHS:-$(dirname "${BASH_SOURCE[0]}")/../paths.env}
	if [ ! -f "$f" ]; then
		echo "9space-paths: no paths.env ($f; NINESPACE_PATHS)" >&2
		return 1
	fi
	top=$(cd -P "$(dirname "$f")/.." && pwd -P)	# the umbrella (~/Devel/9space), physical
	# local.env first: a variable is set by the first that has it
	for f in "$(dirname "$f")/local.env" "$f"; do
		[ -f "$f" ] || continue
		while IFS= read -r line; do
			case "$line" in ''|'#'*) continue;; esac
			k=${line%%=*}
			v=${line#*=}
			case "$v" in /*) ;; '~/'*) v=$HOME/${v#'~/'};; *) v=$top/$v;; esac
			v=$(realpath -m "$v")
			[ -z "${!k}" ] && export "$k=$v"
		done < "$f"
	done
	return 0
}
__9space_paths
