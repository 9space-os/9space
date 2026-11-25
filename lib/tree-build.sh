# The tree's build in parts, for dist/bin/build-toolchains and dist/bin/build-profile
# (sourced; HERE is dist/). The tree's top manifest build.$ARCH.json
# (sys/src/build/gen/genbuild.py) has these groups, in this order:
#
#   prep libc libs klibs cmds linux ape rust kernelgen kernel install
#
# tb_groups builds whole groups (build.exe's regular expression on their names);
# tb_projects builds some of a group's manifests (a manifest of its own in
# CACHE/build). Both build what is out of date only (build.exe -D).

TREE=$(cd -P "$HERE/.." && pwd -P)/$(sed -n 's/^TREE=//p' "$HERE/paths.env")
ROOT=$TREE
. "$TREE/sys/src/build/lib/paths.sh"	# GCC_DIR, RUST_DIR, GO_DIR, CACHE, CLI_DIR (paths.env)

# the build tool, with the host's go if it is not there
tb_buildexe(){
	[ -x "$TREE/sys/src/cmd/build/build.exe" ] ||
		(cd "$TREE/sys/src/cmd/build" && GO111MODULE=off go build -o build.exe .)
}

# build.exe for ARCH, in the tree. arm64: the binutils of aarch64-linux-musl-cross
# (2.44) load every plugin of /usr/lib/bfd-plugins, and LLVM's LLVMgold.so (LLVM 23)
# makes its ar, nm and ranlib hang; gcc's wrappers (gcc-ar, ...) load gcc's
# plugin only. build.exe puts TOOLPREFIX in front: aarch64-linux-musl-gcc-ar
tb_run(){
	local a=$1; shift
	local tools=()
	[ $a = arm64 ] && tools=(AR=${AR:-gcc-ar} NM=${NM:-gcc-nm} RANLIB=${RANLIB:-gcc-ranlib})
	(cd "$TREE" && env PLAN9="$TREE" CC=gcc ARCH=$a "${tools[@]}" sys/src/cmd/build/build.exe -D "$@")
}

# tb_groups ARCH GROUP...: those groups of build.ARCH.json (one it lacks is skipped:
# 386 and arm64 have no linux and ape)
tb_groups(){
	local a=$1; shift
	local IFS='|'
	tb_run $a sys/src/build/build.$a.json "^($*)\$"
}

# tb_projects ARCH NAME GROUP REGEX: the manifests of GROUP in build.ARCH.json whose
# path matches REGEX (python's re.search), as CACHE/build/NAME.ARCH.json
tb_projects(){
	local a=$1 name=$2 group=$3 re=$4 m
	m=$CACHE/build/$name.$a.json
	mkdir -p "$CACHE/build"
	python3 - "$TREE/sys/src/build/build.$a.json" "$group" "$re" "$name" > "$m.new" <<'PY' || return 1
import json, re, sys
top, group, rx, name = sys.argv[1:]
projs = [p for b in json.load(open(top)) if b['Name'] == group
	for p in b.get('Projects', []) if re.search(rx, p)]
if not projs:
	sys.exit('tree-build: no manifest of the group %s matches %s' % (group, rx))
json.dump([{'Name': name, 'Projects': projs}], sys.stdout, indent='\t')
print()
PY
	mv "$m.new" "$m"
	tb_run $a "$m"
}
