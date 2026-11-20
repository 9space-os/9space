# CLAUDE.md — 9space

9space (working name) is a distribution built on 9front: the 9front tree
built with gcc, the GPU stack (gpu(4), the LinuxKPI with Linux's DRM
drivers, Mesa), the window system wsys and the ui framework, and the
toolchains gcc, Rust and Go for it. This directory holds all of its parts;
it is not a git repository itself, each part is one.

## Layout

| Path | What | Git |
|---|---|---|
| `tree/` | the 9front tree, branch `main` (was `ui`); see `tree/CLAUDE.md` | yes; worktrees below |
| `tree-gcc/`, `tree-nix/`, `tree-riscv/`, `tree-upstream/` | worktrees of `tree`, only when needed (`dist/bin/repos --worktrees=...`): branches `gcc` (the gcc port), `nix`, `riscv`, `upstream` (fixes for 9front itself); without one the branch is a ref in `tree` (`bin/status` says so) | worktrees, optional |
| `toolchain/gcc/` | gcc 16 and binutils for 9front, cross and native (branch `main`) | yes |
| `toolchain/rust/` | Rust for 9front; `rust/`, `libc/`, `llvm-project/` are repositories of their own | yes |
| `toolchain/go/` | Go for 9front; `go/` is a repository of its own | yes |
| `tools/mcp/` | MCP server: an agent on Linux works on a 9front guest | yes |
| `browser/` | Servo for 9space (servoshell, servoshot, webfs-rs); `servo/`, `mozjs/` are repositories of their own (from archives, the port on branch `plan9`); MPL-2.0, see Rules | yes |
| `tools/plan9port/` | Plan 9 from User Space (`PLAN9PORT`: rc, yacc, the host build's generators); 9fans' repository, unchanged, built by its `./INSTALL` | yes (9fans') |
| `distfiles/` | the releases' archives other projects' sources come from | no (data) |
| `dist/` | the distribution: `paths.env`, `manifest.json`, `bin/`, `docs/` | yes |

Outside, on purpose: `~/Devel/9space-attic` (the plans and chats, downloads
with GPL sources, a bundle of the old git history with GPL code). Never move them into 9space, never put
the attic into git: a copy of 9space must carry no GPL material.

## Paths

- `dist/paths.env` is the only place with paths (relative to this
  directory; things outside it as `../linux-7.3.1`, ...).
  After moving anything, change only this file.
- Scripts read it: in the tree `scripts/lib/paths.sh` (after `ROOT=`) and
  `scripts/lib/paths.py` (`paths.get('GCC_DIR')`, `paths.archive()` for
  `$DISTFILES/x`); in each toolchain `scripts/9space-paths.sh` (after
  `TOP=`). Never write a sibling path (`../9front-gcc`, `~/Devel/...`) into a
  script.
- `~/Devel/9front*` are symlinks of the old layout, kept until the
  toolchains are rebuilt from here; then they go.

## Tools (dist/bin)

- `status`: each part (branch, commit) against `manifest.json`, changed files.
- `pin [-f]`: `manifest.json` from the parts' heads, after commits. Changes a
  build makes (plan9port's `./INSTALL` paths, cargo's `Cargo.lock`) are listed in
  `expected-changes` and do not count; `-f` only for real uncommitted work.
- `push [-n] [PART...]`: what the parts have and GitHub (9space-os) has not:
  the tree's branches (`upstream` with `--force-with-lease`), each toolchain's,
  mcp's and dist's branch, fast-forward only; `-n` says what it would push.
- `fetch [-n]`: the archives of `distfiles.list` into `distfiles/`, checked by sha256.
- `cacert [-n]`: the CA roots to curl's newest `cacert-DATE.pem` (DISTFILES and
  `distfiles.list`), before each release.
- `build-toolchains [-n] [-from STEP] [ARCH...]`: the whole chain from scratch
  (tree, gcc, Rust, Go, tree again), one log per step in `dist/logs/`; the
  build the wiki's Building page describes. Keep the two in step.
- `build-all [-iso] [ARCH...]`: checks the toolchains, builds the tree
  (`build.exe -D` per arch), optionally the amd64 CD with Rust and Go.

Docs: `dist/docs/roadmap.md` (phases, 1.0 criteria), `upstream.md` (bringing
in 9front: front → gcc → main), `patches.md`; the plans (German) are kept
outside git in `~/Devel/9space-attic/dist-docs`.
Logs of the work: `tree/MEMORY.md` (German, stays so: every branch edits it, a translation would conflict in each merge), `toolchain/*/NOTES.md` (English).

## Rules

- Licences: in the tree only permissive code (MIT, BSD, ISC, zlib, public
  domain); firmware as separate files. The LinuxKPI holds no GPL text of
  Linux: `tree/scripts/linux/provenance.py --check` (in `tests/static`;
  needs `LINUX`, `LINUX_OLD` of paths.env). Own versions of GPL files are
  written by hand from usage, never generated from the original; copied code
  keeps its notices. Exceptions the user accepted: Bison-generated parsers,
  dual-licensed files (a permissive choice), FreeBSD's BSD-4-Clause
  (vge's register layout in `sys/src/9/pc/ethervgbe.c`, notice kept), and
  MPL-2.0 for the browser only: Servo and SpiderMonkey (mozjs) and the
  patches to them in `browser/` (`browser/LICENSES.md`), and the patches of
  the browser's MPL crates.io crates in `toolchain/rust/patches/crates`
  (webdriver, wr_glyph_rasterizer: all crates.io crates live there); our own
  files are MIT, and no MPL code goes into the tree.
- Git: commit only your own files (`git add <files>`, not `-A` in a tree with
  build output); never commit build files (`.o`, `.d`, logs). Other agents
  may have uncommitted work in a part (`toolchain/rust`: crate patches):
  leave it alone. No backup branches in the repositories: a `git bundle`
  outside 9space instead. History rewrites only with the user's word and
  `filter-repo --refs` limited to the range concerned.
- Builds: never two builds in one tree at once (`build-all` locks). After
  changes: `tree/tests/static/run.sh`, the build, and for the GPU stack
  `tree/tests/gpu/run.sh` (QEMU, ~140 checks).
- Guests: one at a time (they share `cache/cli`, `CLI_DIR`); no side load
  while a test suite boots guests. The RX 7600 by VFIO only when the user has
  bound it (`sudo tree/scripts/guest/vfio-gpu.sh bind <pid of the long-lived
  parent>`); no guest while binding or releasing.
- Documentation only in English: `dist/docs`, the wiki, READMEs, NOTES.md, comments. Exception: the tree's `MEMORY.md` stays German.
- The wiki (`dist/wiki`) is the way in for people who want to work with 9space
  and must always be current: a change to anything a wiki page describes
  (a command, a path, a build step, a device file, a default) updates that
  page in the same slot, tried by following it; no pin with a page known to be
  stale.
- Fix causes, not symptoms; close open ends (hangs, unrun tests) before new work.
- Clean solutions over workarounds, even when they change compatibility
  with 9front (an interface, a type, a syscall's arguments): change every
  part that depends on it (the tree, the toolchains' libc crate and std,
  Go's syscalls, the man pages) instead of routing around the defect, and
  note the difference to 9front in the man page and `tree/MEMORY.md`.
- Develop modularly where possible and fitting: code used in more than one
  place lives once, as a library or crate of its own with a clear interface
  (e.g. the 9P code in `sys/src/rust/plan9/ninep`, not a copy per program);
  a program is built from such parts instead of growing one large file. No
  copies of code between programs or parts; a fix then lands in one place.
