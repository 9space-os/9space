# Building

Everything is built on a Linux host (x86-64) from the repositories of
[9space-os](https://github.com/9space-os) and the release archives they name.
The result is 9space for amd64, 386 and arm64 (the 9front tree built with gcc),
with gcc, Rust and Go for 9space, and an install CD.

From scratch it is a handful of commands (sections 2–5) and about three hours,
mostly gcc and Rust. Later builds are incremental and take minutes.

| Part | Where | What it is |
|---|---|---|
| plan9port | `tools/plan9port` | rc, yacc and the generators the tree's build runs on Linux |
| tree | `tree` | 9space's tree (9front's, with the GPU stack and the desktop); `sys/src/cmd/build` (build.exe) builds it |
| gcc | `toolchain/gcc` | gcc 16 and binutils for 9space: the cross compiler (Linux → 9space) and gcc on 9space |
| Rust | `toolchain/rust` | rustc, cargo and std for 9space (from Rust's nightly source archive) |
| Go | `toolchain/go` | Go for 9space (from Go's release archive) |

All paths come from `dist/paths.env`. Every command below starts in
`~/Devel/9space` unless it says otherwise.

## 1. Host

Install what [[Host-requirements]] lists under "Always", "Per architecture"
and "Toolchains"; for the CD and the tests also "Guests". Disk: about
170 GB (gcc 70, Rust 50, tree 20, Go 6, guest images 20).

## 2. The sources

```sh
mkdir -p ~/Devel/9space && cd ~/Devel/9space
git clone https://github.com/9space-os/9space dist
ln -s dist/CLAUDE.9space.md CLAUDE.md
dist/bin/repos --sources
(cd tools/plan9port && ./INSTALL)
```

`CLAUDE.md` in `~/Devel/9space` is a symbolic link to `dist/CLAUDE.9space.md`,
the guide for agents (Claude Code) working in the whole directory. It is not a copy:
the directory is not a repository, so the guide lives in `dist` and is changed
there only.

`dist/bin/repos` clones every part where `paths.env` puts it: the tree with its
branches (`main` checked out; `gcc`, `nix`, `riscv`, `upstream` as refs: a worktree
for one of them only with `--worktrees=riscv` etc.), gcc, Rust,
Go, mcp and plan9port, by HTTPS (no key needed). How you push is up to you; to push
by SSH, `NINESPACE_PUSH=git@github.com:9space-os dist/bin/repos` gives the remotes
of 9space-os (`dist`'s too) that push URL and leaves fetching as it is (a push URL
already set stays). `--sources` then runs each toolchain's `./fetch.sh`
and `dist/bin/fetch`:

- `toolchain/gcc/fetch.sh`: gcc, binutils, gmp, mpfr, mpc (GNU's signatures,
  `sha256.txt`) into `src/`, our patches applied.
- `toolchain/rust/fetch.sh`: Rust's nightly source archive and libc's crate
  (signatures, `sha256.txt`) as the repositories `rust/` (its git data in
  `rust.git`) and `libc/`, our patches on their branch `plan9`; then
  `rust/bootstrap.toml`, `crates/` (the crates.io crates we change, the
  browser's too, fetched and checked against crates.io's index) and
  `cargo-plan9.toml`.
- `toolchain/go/fetch.sh`: Go's release archive as `go/`, our patches on its
  branch `plan9`.
- `dist/bin/fetch`: the archives of `distfiles.list` (Mesa, Wayland, SDL3, …)
  into `distfiles/`, checked by sha256.

plan9port's `./INSTALL` builds it in place (a few minutes). It writes its own
directory into about 75 of its files; that is expected, and `dist/bin/repos`
knows it.

## 3. Toolchains

```sh
dist/bin/build-toolchains            # amd64 386 arm64; or name the architectures
```

It builds gcc, Rust and Go for 9space, and of the tree only what they are built
against. The tree of an installation profile comes after it (section 4). It runs
these steps in order, each one's output in `dist/logs/<step>.log`, and stops at
the first failure, showing the end of its log:

| Step | Runs | Time here |
|---|---|---|
| `tree-base` | of the tree, for each arch: `prep`, `libc`, `libs` and APE's libraries (`sys/src/ape/lib/*`): gcc's sysroot, what the toolchains link against | a few min |
| `gcc-A` | `toolchain/gcc`: `objtype=A ./build.sh cross hostlibs native plan9` | 10 min per arch |
| `rust-stage1` | `toolchain/rust/rust`: `./x build --stage 1 library --target <Linux and the arches>` (downloads Rust's stage-0 compiler and its LLVM) | 10 min |
| `llvm-A` | `objtype=A scripts/build-llvm.sh`: LLVM for 9space | 15 min per arch |
| `rustc-A` | `./x build --stage 2 --host T --target T compiler/rustc src/tools/rustdoc src/tools/rustfmt src/tools/clippy` | 10–25 min per arch |
| `stage1-again-A` | `./x build --stage 1 library …` (stage 2 removed the other targets' std) | 1 min |
| `cargo-A` | `objtype=A scripts/build-cargo.sh`: cargo for 9space | 5 min |
| `install-A` | `objtype=A scripts/install.sh`: `out/A`, which is `/A/rust` on 9space | 1 min |
| `go-A` | `toolchain/go`: `objtype=A scripts/build.sh && scripts/install.sh` (the host Go only for the first arch) | 1–3 min |

The times are those of the development machine; a smaller one (a laptop) takes
several times as long. A is amd64, 386, arm64; T is the Rust target (`x86_64-unknown-plan9`,
`i686-unknown-plan9`, `aarch64-unknown-plan9`). `dist/bin/build-toolchains -n`
prints the steps with their full commands. The steps one by one, by hand:
[[Building by hand|Building-by-hand]].

When a step fails, read its log and fix the cause. Then continue from that
step; the steps before it are done:

```sh
dist/bin/build-toolchains -from rustc-386
```

(`-from tree-first`, the step's old name, still works: it means `tree-base`.)

## 4. The tree of a profile

```sh
dist/bin/build-profile full                   # amd64; or: build-profile ui amd64 386
```

`build-profile PROFILE [ARCH...]` builds of the tree only what the profile's CD
has (the profiles: section 5, "Installation profiles"), with what
`build-toolchains` made. These are the groups of the tree's top manifest
`build.$ARCH.json` it builds:

| Profile | Groups | Needs |
|---|---|---|
| every one | `prep libc libs klibs cmds kernelgen kernel`, the kernel's a.out; amd64: of `linux` the LinuxKPI and `aux/rtw89` (WLAN, on every CD) | the host's gcc |
| `gpu` | + `linux` (aux/i915, aux/amdgpu), `ape` (Mesa) | gcc's cross compiler |
| `ui` | + `ape` (Wayland, foot, the fonts' libraries, Mesa for wsys), `rust` (wsys, ui, term, …) | gcc's cross compiler, Rust |
| `full` | all of them: the whole tree | both |

It ends with `scripts/build/check-install.py -x`: everything the profile has is
there, and what it leaves out is not missing (`NNN files expected, ok`). What a
profile leaves out is listed in `cache/build/PROFILE.ARCH.omitted`. `-n` prints
the steps only. `-cd` makes the CD right after (amd64, 386); `mkcd`'s options
go before the profile:

```sh
dist/bin/build-profile -cd minimal            # then dist/bin/mkcd minimal
dist/bin/build-profile -cd -dev rust -mcp ui  # mkcd -dev rust -mcp ui
```

The builds are incremental (`build.exe -D`): a later `build-profile full` after
`build-profile minimal` builds only the missing groups. `dist/bin/build-all
[ARCH...]` builds the whole tree, as `build-profile full` does, without the check
against a profile.

## 5. Boot loaders and the CD

The boot loaders are built with the Plan 9 C compilers (from 9front) inside the
built system, in a QEMU guest (needs "Guests" of [[Host-requirements]]):

```sh
cd tree && scripts/guest/build-boot.sh && cd ..
dist/bin/mkcd full                    # ~/Devel/9space/cache/cli/9space-full.amd64.iso

The CD of a profile needs the tree built for it (section 4): `mkcd minimal`
after `build-profile minimal`, `mkcd full` after `build-profile full`. A CD of a
profile the build does not cover stops at stage-dist's check
("distribution incomplete").
```

### Installation profiles

`dist/bin/mkcd PROFILE` makes the CD of one profile. Every profile comes from
the same build of the branch `main`; a profile only decides which files go on
the CD, and so onto the system installed from it.

| Profile | On the CD | Size (amd64) |
|---|---|---|
| `minimal` | the base system: rio, VESA | 330 MB |
| `gpu` | + the GPU stack: gpu(4)'s drivers (i915, amdgpu, virtiogpu), Mesa's Vulkan, the Vulkan programs | 1.3 GB |
| `ui` | + the desktop: wsys, the ui framework, term, foot, Wayland, the TrueType fonts and themes; wsys composes on the processor and is the desktop (`desktop=rio` in plan9.ini: rio) | 670 MB |
| `full` | `gpu` and `ui`, with gcc, Rust and Go | past 2 GB |
| `nix` | the branch `nix`: the base system with NIX's kernel; no GPU stack, no desktop | 340 MB |

`nix` is the one profile not made from `main`: its CD comes from the tree's
branch `nix` (the base system with NIX's kernel, its application and
kernel cores: `*nixac`, `*nixkc` in plan9.ini(8)), without the GPU stack, the
desktop and `pull(1)`, for amd64 only. It needs that branch's build in its
worktree first:

```sh
dist/bin/repos --worktrees=nix tree
cd tree-nix
(cd sys/src/cmd/build && GO111MODULE=off go build -o build.exe .)
CC=gcc ARCH=amd64 sys/src/cmd/build/build.exe
scripts/guest/build-boot.sh
cd ..
dist/bin/mkcd nix                             # 9space-nix.amd64.iso
dist/bin/mkcd -dev all nix                    # with gcc, Rust and Go (1.5 GB)
```

The languages are an option of every profile: `-dev` takes `gcc`, `rust`,
`go` (comma-separated), `all` or `none`. The default is `all` for `full` and
`none` for the others. Rust links with gcc, so `rust` brings gcc along. With Rust
or Go the CD also gets the CA roots (`/sys/lib/tls/ca.pem`), so cargo and go
can fetch crates and modules over https.

`-mcp` puts the MCP server on the CD, with any profile of `main`: `/$objtype/bin/9front-mcp`
(built with 9space's Go from `tools/mcp`) and its example deny list as
`/sys/lib/mcp/deny`. It lets an agent on another machine work on the installed
system; how to start it and what guards it: `tools/mcp/README.md`.

`-browser` puts the browser on the CD, with `full` (it runs in wsys, with the desktop's
fonts, and draws on a GPU driver of the `gpu` group), amd64 only: Servo for 9space's `servoshell` and `webfs-rs` in
`/$objtype/bin`, the script `browser` (`browser [url]`, browser(1)) in `/rc/bin`, the
CA roots, and in `/sys/lib/browser` its licences (Servo and SpiderMonkey are
MPL-2.0: `browser/LICENSES.md`) with the MPL's source offer (`SOURCES`: the archives
and the commits of the patch series the programs are built from). It takes the
programs as `browser/build.sh` left them in `browser/out/amd64`: build the browser
first (after `build-toolchains`, on the tree's build):

```sh
browser/fetch.sh && browser/build.sh          # once fetched; ~50 min from scratch
dist/bin/mkcd -browser full                   # 9space-full-browser.amd64.iso
```

Before handing such a CD to others, the commits `SOURCES` names (the browser's and
the Rust toolchain's) must be public: the MPL's source offer points at them.

```sh
dist/bin/mkcd minimal                         # 9space-minimal.amd64.iso
dist/bin/mkcd -dev all minimal                # minimal with gcc, Rust and Go
dist/bin/mkcd -dev rust gpu                   # 9space-gpu-dev-rust.amd64.iso
dist/bin/mkcd -ini 'desktop=rio' ui           # rio instead of wsys, the ui CD's default
dist/bin/mkcd -mcp minimal                    # with the MCP server: 9space-minimal-mcp.amd64.iso
dist/bin/mkcd -mcp -browser full              # 9space-full-mcp-browser.amd64.iso
dist/bin/mkcd -o /tmp/x.iso full 386          # 386 (no GPU stack there)
```

The CDs go to `~/Devel/9space/cache/cli` (`-o` for another place). `-ini` takes
lines `name=value` for the CD's `plan9.ini`. The groups and their files are
listed in `tree/scripts/guest/profiles`. `mkcd` needs the tree's build for the
profile (`dist/bin/build-profile PROFILE`) and takes a QEMU guest (one at a time); it does not start while `build-all` or
`build-profile` runs.

The ISO is hybrid (BIOS, UEFI, CD or USB stick). At boot it asks for the
screen (`monitor`, default `vesa`):

| Answer | Screen |
|---|---|
| `vesa` | the firmware's VESA modes; works on every PC, no acceleration |
| `i915` | Intel graphics through the GPU stack (`aux/i915`, gpu(4)) |
| `amdgpu` | AMD graphics through the GPU stack (`aux/amdgpu`, gpu(4)) |
| `virtiogpu` | QEMU's virtio-gpu (`aux/virtiogpu`, gpu(4)) |

With `i915`, `amdgpu` or `virtiogpu` the driver sets up the screen itself; if
it has no picture after 60 seconds, the screen falls back to VESA. Its log
goes to the boot stick's ESP as `i915boot.log`, `amdgpuboot.log` or
`virtiogpuboot.log`. Details: gpu(4).

### In QEMU

| QEMU display | Answer |
|---|---|
| `-vga std` (QEMU's default) | `vesa` |
| `-vga none -device virtio-vga` | `virtiogpu` |
| `-vga none -device virtio-gpu-gl-pci,…` | `virtiogpu`: 3D, Vulkan (venus) and GL (virgl) on the host's GPU |

For 2D use `virtio-vga`, not `virtio-gpu-pci`: it also has a VGA screen, so the
boot loader and the boot questions are visible. `aux/virtiogpu` drives both.

For example, the CD with virtio-gpu:

```sh
qemu-system-x86_64 -enable-kvm -m 4096 -cdrom ~/Devel/9space/cache/cli/9space-full.amd64.iso \
	-vga none -device virtio-vga
```

3D needs a GPU on the host with Vulkan, KVM, and QEMU with virglrenderer.
These are the options `tree/tests/gpu/run.sh` boots with:

```sh
-enable-kvm -cpu host -m 1024 -vga none \
-device virtio-gpu-gl-pci,blob=true,venus=true,hostmem=256M \
-object memory-backend-memfd,id=mem1,size=1024M,share=on -machine memory-backend=mem1 \
-display egl-headless
```

`-m` must be the memory backend's size. For a window instead of
`egl-headless`, QEMU's `-display gtk,gl=on` should work, but the tests don't use it.

To skip the question, make a CD with the answer in its `plan9.ini`:

```sh
dist/bin/mkcd -ini 'monitor=virtiogpu' full    # or vesa, i915, amdgpu
```

A CD without the GPU stack (`minimal`, `ui`) asks only for VESA's kinds of
screen. If `monitor` names a GPU driver anyway, it says so and takes VESA.

The guest that makes the CD holds the whole image in memory: it gets 6 GB
(`MEM=` to change; `mkcd` runs `tree/scripts/guest/mkiso.sh`).

## 6. Tests

```sh
cd tree
bash tests/static/run.sh       # seconds: manifests, licences, layouts (needs the Linux sources, see Host-requirements)
bash tests/run.sh guest boot   # the system boots and works in QEMU
bash tests/gpu/run.sh          # ~1 h: LinuxKPI selftests, virtio-gpu, Vulkan, GL, wsys (needs a host GPU)
```

The CD tests (`bash tests/run.sh iso`) make a CD of their own; to test a
profile's CD instead: `ISO=~/Devel/9space/cache/cli/9space-ui.amd64.iso bash tests/run.sh iso`.

Only one guest at a time: they share `~/Devel/9space/cache/cli` (`CLI_DIR`).

All of it in one go, and the build with 9front's own compilers (kencc, gccmk) too: `dist/bin/check`, see [[Testing]].

## Later: updating

```sh
dist/bin/repos           # fast-forwards every part that is clean and on its branch
dist/bin/status          # each part against manifest.json
```

Then rebuild what changed:

| What changed | Then |
|---|---|
| only the tree | `dist/bin/build-profile PROFILE [ARCH...]`, or everything: `dist/bin/build-all amd64 386 arm64` (`build.exe -D`: only what is out of date; seconds when nothing is) |
| gcc's patches or `sources.txt` | `cd toolchain/gcc && rm -rf src && ./fetch.sh && cd ../..`, then `dist/bin/build-toolchains -from gcc-amd64` (Rust and the tree depend on gcc), then `dist/bin/build-profile PROFILE` |
| Rust's patches (`toolchain/rust/patches/*`, not `crates`) | `cd toolchain/rust && scripts/rust-patches.sh apply && cd ../..`, then `dist/bin/build-toolchains -from rust-stage1` |
| a crate patch (`toolchain/rust/patches/crates`) | `cd toolchain/rust && scripts/crates-patch.sh apply && scripts/cargo-config.sh && cd ../..`, then `dist/bin/build-toolchains -from cargo-amd64`; for a crate of the browser (dlib, imsz, inventory, ipc-channel, libsqlite3-sys 0.36.0, mozangle, rustls-platform-verifier 0.7.1, surfman, webdriver, wr_glyph_rasterizer) `browser/build.sh` instead |
| Rust's `sources.txt` (a new nightly) | `cd toolchain/rust && rm -rf rust rust.git libc && ./fetch.sh && cd ../..`, then `-from rust-stage1` |
| Go's patches or `sources.txt` | `cd toolchain/go && rm -rf go && ./fetch.sh && cd ../..`, then `-from go-amd64` |
| `distfiles.list` | `dist/bin/fetch`, then `dist/bin/build-profile PROFILE` (or `build-all amd64 386 arm64`) |
| plan9port | `cd tools/plan9port && git checkout . && git pull && ./INSTALL` (`dist/bin/repos` says so too) |

`rm -rf src`, `go` or `rust` throws away work in those directories; the
patches are the record (each toolchain's README says how to write them back).
`rust-patches.sh apply` stops by itself if `plan9` has commits of its own
that the patches lack.

## From scratch again

```sh
dist/bin/clean-build -n          # what would go
dist/bin/clean-build             # asks, then removes it
dist/bin/build-toolchains && dist/bin/build-profile full
```

`clean-build` removes everything the build made: in the tree every file git
does not track (`git clean -fdx`, but `tests/hw/results/`), the toolchains'
`build/` and `out/` directories, Go's `go/bin` and `go/pkg`, `cache/build`,
`cache/mesa` and `dist/logs`. `build.exe -clean` is not enough for that: it knows
only the manifests' objects, not what their steps and the installs make. The
sources and the downloaded archives stay. So does Rust's download cache
(`rust/build/cache`), unless `-downloads`. The guests' images and CDs
(`cache/cli`) go only with `-cli`. Single parts: `clean-build rust go`. Before it
asks, it lists the tree's untracked files that look like sources, since a new
file not yet in git would be lost too. It does not start while a build runs.

## Not in `build-toolchains`

- **riscv64** (the tree's branch `riscv` in the worktree `tree-riscv`: first
  `dist/bin/repos --worktrees=riscv tree`; needs
  `riscv64-linux-gnu-gcc`, see [[Host-requirements]]):

  ```sh
  (cd tree-riscv/sys/src/cmd/build && GO111MODULE=off go build -o build.exe .)
  (cd tree-riscv && CC=gcc ARCH=riscv64 sys/src/cmd/build/build.exe)
  (cd toolchain/gcc && objtype=riscv64 ./build.sh cross hostlibs native plan9)   # ~30 min
  ```
- **Self-hosting**: the tree built inside 9space with the native gcc,
  `tree/scripts/guest/build-self.sh`.
- **Real hardware** (VFIO GPU tests): `tree/tests/README.md`.
