# Repositories

Layout of `~/Devel/9space` (each entry below is a git repository). `tree` has
`main` checked out; its other branches (`gcc`, `nix`, `riscv`, `upstream`) are
refs in the same repository, with a worktree beside it only when one works on
them (see [[Branches]]):

```
9space/
├── CLAUDE.md          symbolic link to dist/CLAUDE.9space.md (the agents' guide)
├── dist/              the distribution: paths, manifest, tools, docs
├── tree/              9space's tree (9front's)
├── toolchain/
│   ├── gcc/           gcc and binutils for 9space
│   ├── rust/          Rust for 9space (+ rust/, libc/)
│   └── go/            Go for 9space (+ go/)
├── tools/mcp/         MCP server for 9space
├── browser/           Servo for 9space (+ servo/, mozjs/)
├── tools/plan9port/   Plan 9 from User Space (9fans', unchanged)
├── distfiles/         release archives (not git)
└── cache/             what the build and the guests keep (not git): cli/ (CLI_DIR:
                       guest images, CDs), the ports' work dirs, the provenance cache
```

| Repository | Holds | Upstream it builds on |
|---|---|---|
| `dist` | `paths.env` (all paths), `manifest.json` (commits that belong together), `bin/` (`repos`, `status`, `pin`, `fetch`, `build-toolchains`, `build-profile`, `build-all`, `clean-build`, `mkcd`, `wiki`, `pxe`; `lib/tree-build.sh`), `docs/` (roadmap, upstream, patches), this wiki | — |
| `tree` | 9front with the gcc port, the GPU stack, wsys, ui, tests, build tool (`sys/src/cmd/build`) | github.com/9front/9front |
| `toolchain/gcc` | `build.sh`, `fetch.sh`, `patches/` (gcc.patch, binutils.patch), `plan9/` (gccmk) | gcc 16.2.0, binutils 2.47 |
| `toolchain/rust` | `patches/` (rust, cargo, backtrace, llvm-project, libc, crates), `crates/`, `scripts/`, `tests/` | rust-lang/rust, rust-lang/libc |
| `toolchain/rust/rust`, `libc` | the release archives (`fetch.sh`: nightly source, libc's crate) as repositories of their own (Rust's git data in `rust.git` beside `rust/`: Rust's bootstrap treats `rust/` as a source archive only without `.git`); the port on branch `plan9` (from `patches/`) | rust-lang/rust, rust-lang/libc |
| `toolchain/go` | `patches/go`, `scripts/build.sh`, `install.sh`, tests | go1.27.3 |
| `toolchain/go/go` | Go's release archive (`fetch.sh`) as a repository; the port on branch `plan9` | go1.27.3 |
| `tools/plan9port` | rc, yacc and the generators of the host build (`PLAN9PORT`); 9fans' repository, unchanged: its `INSTALL` writes the install path into ~75 files, `bin/repos` knows that | github.com/9fans/plan9port |
| `tools/mcp` | `9front-mcp`: lets an agent on Linux work on a 9space system (read, write, edit, glob, grep, rc); on the CD with `dist/bin/mkcd -mcp` | — |
| `browser` | `fetch.sh`, `prepare.sh`, `build.sh`, `patches/` (servo, mozjs, crates: stylo's, a git source Servo brings), `webfs-rs/`, `tests/`; the crates.io crates it changes are `toolchain/rust`'s (`patches/crates`, `cargo-plan9.toml`); MPL-2.0 for Servo's and mozjs' parts (`LICENSES.md`) | servo/servo (a nightly's commit), servo/mozjs, servo/stylo |
| `browser/servo`, `mozjs` | the archives of those commits (`fetch.sh`) as repositories of their own, tag `pristine`; the port on branch `plan9` (from `patches/`) | servo/servo, servo/mozjs |

Outside 9space, referenced by `dist/paths.env`:

| Name | Path | Needed for |
|---|---|---|
| `LINUX`, `LINUX_OLD` | `../linux-7.3.1`, `../linux-6.6` | the LinuxKPI's tools and its GPL check |
| `OPENBSD_SRC`, `FREEBSD_SRC`, `DRMKMOD_SRC` | `../openbsd`, `../freebsd-src`, `../drm-kmod` | importing the LinuxKPI's BSD templates |
| `NETBSD_SRC` | `../netbsd` | NetBSD's tree: its ATF and `tests/`, the model of a later test framework (`docs/open.md`) |

Show every part against the manifest:

```sh
$ dist/bin/status
tree               main       a96ee0111e   =
tree-gcc           gcc        7e31bbb806   = (no worktree: the branch in tree)
tree-nix           nix        ef4f803bb3   = (no worktree: the branch in tree)
tree-riscv         riscv      9cd17408dc   = (no worktree: the branch in tree)
tree-upstream      upstream   7e9a98017f   = (no worktree: the branch in tree)
gcc                main       ae85fdbbe5   =
rust               main       69dd67cea6   =
rust/rust          plan9      1c3e87b4da   = 1 changed
...
```

`=`: at the pinned commit; `+N`: N commits after it; `N changed`: tracked files
changed (for `rust/rust` cargo's `Cargo.lock`, which the build rewrites; for
`plan9port` the paths its `INSTALL` writes). `dist/bin/pin` pins the current
heads; a part that is not there keeps its pin.

Paths: never written into scripts. The tree reads them with
`scripts/lib/paths.sh` / `paths.py`, each toolchain with
`scripts/9space-paths.sh`. Moving a part means editing `dist/paths.env`:

```sh
GCC_DIR=toolchain/gcc
DISTFILES=distfiles
LINUX=../linux-7.3.1
```
