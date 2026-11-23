# Testing

Before a CD is made or handed on, `dist/bin/check` tests the built system:
that it builds with 9front's own compilers too, not only with gcc, that it
boots and its tests pass, and that the CD boots to its desktop. The stages
run one after another in QEMU guests, each with a log of its own.

```sh
cd ~/Devel/9space
dist/bin/check                    # static build guest boot
dist/bin/check -native            # and kencc gccmk: 9front's mkfiles with kencc and with gccmk
dist/bin/check -iso cache/cli/9space-ui.amd64.iso iso   # a CD: boots, desktop, USB, its toolchains
dist/bin/check -n -native         # prints the stages only
dist/bin/check kencc              # one stage by name
```

At the end there is one line per stage, `ok` or `FAIL` with its minutes,
and the exit status is 1 when one failed. The output of each stage is in
`dist/logs/check-STAGE.log`; a failed stage's last lines are shown as well.

## The stages

| Stage | What | Command (in `tree/`) |
|---|---|---|
| `static` | source checks: manifests, licences, layouts (seconds) | `bash tests/static/run.sh` |
| `build` | what the build tool made: libraries, programs, kernel | `bash tests/run.sh build` |
| `guest` | the unit tests in a 9front guest | `bash tests/run.sh guest` |
| `boot` | the built kernel boots to rc | `bash tests/run.sh boot` |
| `kencc` (`-native`) | 9front's own compilers (6c, 6a, 6l, mk) build the tree, kernel included | `bash scripts/guest/build-kencc.sh` |
| `gccmk` (`-native`) | 9front's mkfiles with `gccmk`, the native gcc (userland) | `bash scripts/guest/build-kencc.sh gcc` |
| `gpu` (`-gpu`) | the GPU stack on virtio-gpu (~1 h, needs a host GPU) | `bash tests/gpu/run.sh` |
| `iso` (`-iso ISO`) | the CD as CD and as disk, BIOS and UEFI, up to its desktop; mouse and keyboard, USB, and the gcc, Go, Rust and MCP server it has (each skipped when the CD lacks it) | `ISO=... bash tests/run.sh iso rio usb gcc go rust mcp` |

`check` needs the tree's build first (`build-all`, `build-profile`). The
`gccmk` stage also needs the native gcc's `plan9` step
(`toolchain/gcc/out/amd64`, made by `build-toolchains`).

## Why kencc and gccmk

9space builds with gcc on Linux (`build.exe`), but the tree stays
buildable on 9front itself: with 9front's own compilers (`mk`, `6c`) and
with `gccmk`, which runs the same mkfiles with the native gcc. gcc-only
code (`__atomic_*` builtins, `__attribute__((weak))`, gcc's predefined
types) needs a branch for kencc beside it, and the gcc build cannot see
when one is missing. The `kencc` and `gccmk` stages build all of
`/sys/src` in a guest as 9front does (`mk install` in each directory) and
count every failed mk target. Run them after changes to libc, APE or the
kernel, and before a release.

## With the build: `-check`

The build scripts run `check` when asked, before they make a CD, and stop
when it fails:

```sh
dist/bin/build-all -check -iso          # the whole tree; check -native; the amd64 CD; check -iso on it
dist/bin/build-profile -check -cd ui    # one profile; check without its stage build; mkcd; check -iso on the CD
```

`build-profile -check` leaves out the stage `build`: a profile builds only
its groups, and `check-install.py -x` (which `build-profile` runs) checks
those. Without `-check` both build as before.

## Rules

- One guest at a time: the guests share `cache/cli` (`CLI_DIR`). `check`
  refuses to start while a guest of it runs, and takes the build lock
  (`build-all`'s), so that no build changes the tree under the tests.
- `kencc` and `gccmk` build a copy of the tree's files as git knows them
  (`git ls-files`): a new source file has to be added (`git add`) first,
  else the guest's mk finds no recipe for it.
- The stages take long: `kencc` about 45 minutes, `gccmk` some hours
  (gcc in the guest is much slower than 6c; `SMP=8 MEM=4096` gives the
  guest more CPUs), the CD tests about an hour; the quick ones (`static`,
  `build`) take minutes.

See also: [[Building]] (section 6, "Tests"), [[Releasing]].
