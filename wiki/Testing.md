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
dist/bin/check -instance instance   # the installed system on your instance (below), brought up to date first
dist/bin/check -n -native         # prints the stages only
dist/bin/check kencc              # one stage by name
```

At the end there is one line per stage, `ok` or `FAIL` with its minutes,
and the exit status is 1 when one failed. The output of each stage is in
`dist/logs/check-STAGE.log`; a failed stage's last lines are shown as well.

## The stages

| Stage | What | Command (in `tree/`) |
|---|---|---|
| `static` | source checks: manifests, licences, layouts (seconds) | `bash sys/src/build/host/tests/static/run.sh` |
| `build` | what the build tool made: libraries, programs, kernel | `bash sys/src/build/host/tests/run.sh build` |
| `guest` | the unit tests in a 9front guest | `bash sys/src/build/host/tests/run.sh guest` |
| `boot` | the built kernel boots to rc | `bash sys/src/build/host/tests/run.sh boot` |
| `kencc` (`-native`) | 9front's own compilers (6c, 6a, 6l, mk) build the tree, kernel included | `bash sys/src/build/host/guest/build-kencc.sh` |
| `gccmk` (`-native`) | 9front's mkfiles with `gccmk`, the native gcc (userland) | `bash sys/src/build/host/guest/build-kencc.sh gcc` |
| `gpu` (`-gpu`) | the GPU stack on virtio-gpu (~1 h, needs a host GPU) | `bash sys/src/build/host/tests/gpu/run.sh` |
| `iso` (`-iso ISO`) | the CD as CD and as disk, BIOS and UEFI, up to its desktop; mouse and keyboard, USB, and the gcc, Go, Rust and MCP server it has (each skipped when the CD lacks it) | `ISO=... bash sys/src/build/host/tests/run.sh iso rio usb gcc go rust mcp` |
| `instance` (`-instance`) | the same tests of the installed system on your instance: gcc, Go, Rust, the MCP server, the desktop's mouse and keys, the reference workflow; and the tests that bring their own desktop (draw, SDL, GLFW, winit, ui, Wayland) | `INSTANCE=1 bash sys/src/build/host/tests/run.sh gcc go rust mcp rio workflow draw glfw winit uiserver sdl wayland` |

`check` needs the tree's build first (`build-all`, `build-profile`). The
`gccmk` stage also needs the native gcc's `plan9` step
(`toolchain/gcc/out/amd64`, made by `build-toolchains`).

## Your own instance

An instance is a 9space system installed on a disk image that QEMU boots,
the way a user's machine has it, instead of a CD booted afresh for each
test. Where it is is each checkout's own: `dist/local.env` (not in git;
the format of `dist/paths.env`, whose paths it may set otherwise too)
names it, the environment's `INSTANCE_DIR` wins over it:

```sh
cd ~/Devel/9space
echo 'INSTANCE_DIR=~/9space' >> dist/local.env
dist/bin/mkcd -mcp full                  # a CD with the MCP server, if there is none
dist/bin/instance install                # a 20 GB disk from it: the installer, in a window
cp --sparse=always ~/9space/9space.raw ~/9space/9space.golden.raw   # the backup
dist/bin/instance status
```

After the installation the system needs the instance's token as
`$home/lib/mcptoken` (`dist/bin/instance install` makes `mcptoken` in the
instance's directory); the profile starts the MCP server with it. The
directory holds only data: the disk, its backup, `mcptoken`, and
`instance.env` with its settings (`PROFILE`, `MKUPDATE`: the profile and
`mkupdate`'s options of its CD, default `full` and `-mcp`; `SMP`, `MEM`,
the ports; `dist/bin/instance`'s header lists them).

`dist/bin/instance up` (what the tests call) boots it if it does not run
and checks that it has this checkout's build: the system's
`/sys/lib/dist/update` names the fingerprint of the update archive it was
last given, `dist/bin/mkupdate` computes the build's. When they differ, it
puts the backup back over the disk (a fresh system, without the traces of
earlier tests; `FRESH=0`: onto the disk as it is, where the update removes
only what the last update put on and this one has not), puts the build on with an update archive and reboots. The archive is
kept (`cache/cli/instance.amd64.tgz`); the build is staged again (minutes)
only when a part of it is newer. `instance stop`, `reset` (the backup back),
`start` and `check` do one step each.

Work on the instance that must stay (a setup for a test of one's own)
needs a `hold` file in its directory: its first line says who holds it and
what for (`echo 'me: self-build test' > ~/9space/hold`). While it is there,
`update` and `reset` do not put the backup back (`FRESH=0 dist/bin/instance
up` puts a new build onto the disk as it is), and `status` names the
holder. Remove it when done.

The tests of the installed system (`gcc`, `go`, `rust`, `mcp`, `rio`,
`workflow`) run on it with `INSTANCE=1`, and so do the tests that bring a
desktop of their own (`draw`, `sdl`, `glfw`, `winit`, `uiserver`,
`wayland`: their wsys on the screen, keys through QMP), on a throwaway boot
of it (`dist/bin/instance fresh`, below): `dist/bin/instance put` puts their
programs on as `/tests`, the system's desktop ends (`deskoff.rc`) and an MCP
server of the test's starts in its place (`sys/src/build/host/tests/lib.sh`
`deskguest`); `instance stop` at the end throws it all away, so the next
test boots the instance as it was. Their parts with a GPU of the host's
(venus) still boot a guest of their own, after the instance stopped; the
other categories boot guests of their own as before (their devices and
kernels are the test's). The instance is
booted only when it does not run and rebooted only for a new build; it
keeps running after the tests. So that the tests can be run again and
again on a system that stays, each one tidies up its own traces: it works
in a directory of its own (`/tmp/test.NAME`, the workflow's `/tmp/wf`),
emptied before it starts, removed afterwards when every check passed
(kept to look at when one failed); a serial rc of its own in a note group
of its own, which the next test stops with whatever it left running; the
workflow deletes the windows it made. `dist/bin/instance fresh` boots a
throwaway copy instead (QEMU's `-snapshot`: nothing stays; `QEMU_EXTRA`
adds devices to it, e.g. sdl's sound card), for trying something by hand
and for the desktop tests; `dist/bin/instance put [-m] DIR [TO]` puts a
directory of the host's into the running system (`-m`: merged into what is
there). The instance is a guest too: one at a time.

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
