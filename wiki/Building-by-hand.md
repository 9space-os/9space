# Building by hand

[[Building]] runs the build with three scripts: `build-toolchains`, `build-profile`,
`mkcd`. This page shows the single steps those scripts run, as commands to type
yourself: for a step that failed, for part of the system, or to see what happens.
Each script prints its own steps: `dist/bin/build-toolchains -n`,
`dist/bin/build-profile -n PROFILE`.

Every command starts in `~/Devel/9space` unless it says otherwise. A is the
architecture (`amd64`, `386`, `arm64`); the commands use amd64. The sources and
plan9port come first ([[Building]], section 2).

## The build tool

The tree is built by `build.exe`, built with the host's Go:

```sh
(cd tree/sys/src/cmd/build && GO111MODULE=off go build -o build.exe .)
```

`build.exe` reads JSON manifests. The tree's top manifest `sys/src/build/build.$ARCH.json`
(written by `sys/src/build/gen/genbuild.py`) has these groups, in this order:

| Group | What it builds | Needs |
|---|---|---|
| `prep` | the install directories, gcc's runtime library `libgcc.a` | |
| `libc` | `/A/lib.gcc/libc.a` | |
| `libs` | the libraries of `sys/src/lib*` | |
| `klibs` | the kernel's `klib*.a` | |
| `cmds` | the programs of `sys/src/cmd` and APE (`sys/src/ape`, with its libraries `sys/src/ape/lib/*`) | |
| `linux` (amd64) | the LinuxKPI (`sys/src/linux`), `aux/i915`, `aux/amdgpu`, `aux/rtw89` | |
| `ape` (amd64) | `sys/src/build/step/ape.sh`: Mesa, libwayland, SDL3, GLFW, foot, …; wlsys, foot, cxxwidgets | gcc's cross compiler |
| `rust` | `sys/src/build/step/cargo.sh`: files, term, ui, the ui demos, wbar, wdock, wsys | Rust's stage-1 rustc, the cross gcc |
| `kernelgen` | what the kernel embeds (rebootcode, initcode, the boot file system) | |
| `kernel` | the kernel (`/amd64/bin/9pc64`, `/386/bin/9pc`, `/arm64/bin/9qemu`) | |
| `install` | the kernel's a.out (`elf2aout.py`), `check-install.py -r` | |

`-D` builds only what is out of date. With no arguments `build.exe` builds all of
`build.json` (all groups). A manifest as its first argument, followed by regular
expressions, builds only the groups whose names match:

```sh
cd tree
CC=gcc ARCH=amd64 sys/src/cmd/build/build.exe -D                              # everything
CC=gcc ARCH=amd64 sys/src/cmd/build/build.exe -D sys/src/build/build.amd64.json '^(prep|libc|libs)$'
CC=gcc ARCH=amd64 sys/src/cmd/build/build.exe -D sys/src/cmd/rc/cmds.json      # one manifest
```

A manifest of its own (a group from part of another's) works the same way, from
any directory, with `PLAN9=` set to the tree. That is how `dist/lib/tree-build.sh`
builds part of a group (in `cache/build/`).

**arm64**: since binutils 2.44, the tools of `aarch64-linux-musl-cross` load every
plugin of `/usr/lib/bfd-plugins`, and LLVM's `LLVMgold.so` makes their `ar`, `nm`
and `ranlib` hang (100 % CPU, no output, for good). gcc's wrappers load only gcc's
plugin. `build.exe` puts TOOLPREFIX in front of `AR`, `NM` and `RANLIB`, so this
gives `aarch64-linux-musl-gcc-ar` etc.:

```sh
CC=gcc ARCH=arm64 AR=gcc-ar NM=gcc-nm RANLIB=gcc-ranlib sys/src/cmd/build/build.exe -D …
```

The scripts (`build-toolchains`, `build-profile`, `build-all`) set them themselves.

## 1. What the toolchains need from the tree

gcc's cross compiler is built against a sysroot made of the tree
(`toolchain/gcc/sysroot.sh`: `/A/include`, `/sys/include`, `/A/lib.gcc` with
`libc.a` and `ape/libap.a`, `/A/plan9.ld`). LLVM, rustc and cargo for 9space link
against APE. That is the step `tree-base`, for each architecture:

```sh
cd tree
CC=gcc ARCH=amd64 sys/src/cmd/build/build.exe -D sys/src/build/build.amd64.json '^(prep|libc|libs)$'
# APE's libraries, the manifests of the group cmds under sys/src/ape/lib, in order
for m in $(python3 -c "import json
print(' '.join(p for b in json.load(open('sys/src/build/build.amd64.json')) if b['Name'] == 'cmds'
	for p in b['Projects'] if p.startswith('/sys/src/ape/lib/')))"); do
	CC=gcc ARCH=amd64 sys/src/cmd/build/build.exe -D .$m || break
done
cd ..
```

On 386 `prep` takes the host's `libgcc.a` (`gcc -m32`) until gcc for 386 exists,
with a warning. The tree of the profile builds `prep` again later, with gcc's.

## 2. gcc

`toolchain/gcc/build.sh` runs in stages; each can be run on its own:

```sh
cd toolchain/gcc
objtype=amd64 ./build.sh cross       # binutils, gcc (C, C++) on Linux for 9space, libgcc, libstdc++ -> build/amd64/cross
objtype=amd64 ./build.sh hostlibs    # gmp, mpfr, mpc for 9space                                   -> build/amd64/hostlibs
objtype=amd64 ./build.sh native      # binutils and gcc that run on 9space                         -> out/amd64
objtype=amd64 ./build.sh plan9       # gccmk: mk with gcc on 9space                                -> out/amd64
cd ../..
```

`cross` needs section 1's sysroot. The stages' logs are `toolchain/gcc/*.log`. A
stage whose arguments have not changed since the last run is not configured again.

## 3. Rust

```sh
cd toolchain/rust/rust
./x build --stage 1 library --target x86_64-unknown-linux-gnu,x86_64-unknown-plan9,i686-unknown-plan9,aarch64-unknown-plan9
cd ..
objtype=amd64 scripts/build-llvm.sh                     # LLVM for 9space (rustc links it)
(cd rust && ./x build --stage 2 --host x86_64-unknown-plan9 --target x86_64-unknown-plan9 \
	compiler/rustc src/tools/rustdoc src/tools/rustfmt src/tools/clippy)
(cd rust && ./x build --stage 1 library --target x86_64-unknown-linux-gnu,x86_64-unknown-plan9,i686-unknown-plan9,aarch64-unknown-plan9)
objtype=amd64 scripts/build-cargo.sh                    # cargo for 9space
objtype=amd64 scripts/install.sh                        # out/amd64: /amd64/rust on 9space
cd ../..
```

The stage-1 library comes first: the downloaded stage-0 compiler builds std for
Linux and the Plan 9 targets (`*-unknown-plan9`). Stage 2 (rustc for 9space) removes the other
targets' std, so the stage-1 library is built again after it. For each further
architecture, repeat from `build-llvm.sh` with its `objtype` and target
(`i686-unknown-plan9`, `aarch64-unknown-plan9`). The tree's Rust programs need only
the stage-1 rustc (`rust/build/host/stage1/bin/rustc`) with the cross gcc, not
`out/A`, which is for 9space.

## 4. Go

```sh
cd toolchain/go
objtype=amd64 HOST=1 bash -c 'sys/src/build/step.sh && scripts/install.sh'   # HOST=1: also the host's Go, once
objtype=386 HOST=0 bash -c 'sys/src/build/step.sh && scripts/install.sh'
cd ../..
```

## 5. The tree of a profile

`dist/bin/build-profile PROFILE` is these steps. Every profile:

```sh
cd tree
CC=gcc ARCH=amd64 sys/src/cmd/build/build.exe -D sys/src/build/build.amd64.json '^(prep|libc|libs|klibs|cmds)$'
# amd64, without the GPU stack: the LinuxKPI and aux/rtw89 (WLAN), not the DRM drivers
CC=gcc ARCH=amd64 sys/src/cmd/build/build.exe -D sys/src/linux/build.json
CC=gcc ARCH=amd64 sys/src/cmd/build/build.exe -D sys/src/cmd/aux/rtw89/build.json
```

Then, by profile:

```sh
CC=gcc ARCH=amd64 sys/src/cmd/build/build.exe -D sys/src/build/build.amd64.json '^linux$'   # gpu, full: + i915, amdgpu
CC=gcc ARCH=amd64 sys/src/cmd/build/build.exe -D sys/src/build/build.amd64.json '^ape$'     # gpu, ui, full
CC=gcc ARCH=amd64 sys/src/cmd/build/build.exe -D sys/src/build/build.amd64.json '^rust$'    # ui, full
```

A single Rust crate: `objtype=amd64 bash sys/src/build/step/cargo.sh sys/src/cmd/wsys wsys`
(the lines of the group `rust` in `sys/src/build/build.amd64.json`; 386 and arm64 with `-n`, no GPU
features). APE's parts alone: `objtype=amd64 bash sys/src/build/step/ape.sh`; its log is
`cache/mesa/build-amd64/ape.log`.

Last, the kernel, its a.out and the check:

```sh
CC=gcc ARCH=amd64 sys/src/cmd/build/build.exe -D sys/src/build/build.amd64.json '^(kernelgen|kernel)$'
python3 sys/src/build/step/elf2aout.py amd64/bin/9pc64 amd64/9pc64     # 386: 386/bin/9pc 386/9pc; arm64: arm64/bin/9qemu arm64/9qemu
# what the profile leaves out (sys/src/build/host/guest/profiles), as stage-dist.sh writes it
P=minimal; keep=$(awk -v p=$P '$1 == "profile" && $2 == p { for(i = 3; i <= NF; i++) printf " %s", $i }' sys/src/build/host/guest/profiles)
awk -v keep=" $keep " '/^[a-z]/ && $1 != "profile" && index(keep, " " $1 " ") == 0 { print "/" $2 }' sys/src/build/host/guest/profiles |
	sed 's/\$objtype/amd64/' > /tmp/omitted
objtype=amd64 python3 sys/src/build/step/check-install.py -r -x /tmp/omitted | grep -v '^broken'
cd ..
```

`check-install.py` without `-x` checks the whole tree (`full`); `-l` lists what it
expects. `missing` is an error. `norust`/`nocross` mean the toolchain is not
there. `hostlib` means 386's `libgcc.a` is the host's. `-r` removes `stale` files,
which no rule installs any more.

## 6. Boot loaders and the CD

The boot loaders are built in a QEMU guest running the system just built (it needs
the base system: section 5's first and last steps):

```sh
cd tree && sys/src/build/host/guest/build-boot.sh && cd ..
```

`dist/bin/mkcd PROFILE` checks its options and then runs `tree/sys/src/build/host/guest/mkiso.sh`
with the profile in the environment. Without publishing for `pull(1)`
(`mkcd -noreplica`) that is:

```sh
cd tree
PROFILE=minimal DEV= MCP= BROWSER= PLAN9INI= objtype=amd64 sys/src/build/host/guest/mkiso.sh ../cache/cli/9space-minimal.amd64.iso
cd ..
```

`DEV` takes the languages (`gcc,rust,go`); `MCP=1`; `BROWSER=1` (profile `full`,
amd64); `PLAN9INI` lines `name=value`. `mkiso.sh` runs `sys/src/build/host/guest/stage-dist.sh`
(the distribution's tree for the profile, checked with `check-install.py -d -x`)
and makes the ISO in a guest. With pull(1), `mkcd` also sets `REPLICA_KEY`,
`REPLICA_DIR` and `REPLICA_URL` (see the comment at the top of `dist/bin/mkcd`).

## When something hangs or fails

- A step that writes no log for minutes: `ps -eo pid,etime,pcpu,args --sort=start_time | tail`
  shows what runs. A tool at 100 % CPU whose output stays empty is hung (arm64's
  `ar`: see "The build tool").
- The scripts' logs: `dist/logs/<step>.log`. gcc's stages: `toolchain/gcc/*.log`.
  Rust: `toolchain/rust/logs/` (made by the first step that writes one). APE:
  `cache/mesa/build-A/ape.log`.
- From scratch: `dist/bin/clean-build -n` shows what the build made, without `-n` it
  removes it ([[Building]], "From scratch again").
- Two builds must never share the tree. The scripts take `dist/.build-all.lock`;
  by hand, check first that none of them is running.
