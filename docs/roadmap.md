# 9space: the way to a distribution

The starting point was a review of the project. Unlike its recommendation
(an overlay on 9front, merging upstream as an option), 9space is a
**distribution of its own** (decided 2026-11-12): its own name, its own
replica and ISOs. 9front's `front` stays the source, brought in regularly
(`upstream.md`); single fixes still go to 9front as patches
(`sys/src/build/host/patch-upstream/` in the tree).

## State (2026-11-12)

- Parts and paths: `../paths.env`, `../manifest.json`, `../bin/status`;
  `../bin/repos` gets them from GitHub (github.com/9space-os).
- Licences: no GPL code of Linux in the tree or its git history (the
  LinuxKPI from OpenBSD/FreeBSD templates, `sys/src/build/linux/provenance.py` in
  `sys/src/build/host/tests/static`). Exceptions: Bison parsers (GPL with the Bison
  exception), dual-licensed files (a permissive choice), firmware separate
  under `/lib/firmware`; the CA roots (Mozilla's, MPL-2.0) likewise a separate file,
  from `distfiles.list` onto a CD with Rust or Go as `/sys/lib/tls/ca.pem`. It is a fixed
  state: before each release raise its entry in `distfiles.list` to curl's newest
  `cacert-DATE.pem` (https://curl.se/ca/; `bin/cacert`); installed systems get no update of it
  until there is an update path (replica/pull; there now: `pull(1)`, once
  the update server runs).
- Tests: `sys/src/build/host/tests/static`, `sys/src/build/host/tests/gpu/run.sh` (QEMU, ~140 checks), the
  RX 7600 by VFIO (`amdall.rc`); the laptop (i915) on Linux 7.3 green in its
  runs 9 and 10 (2026-11-11). What ran where: `hardware.md`.

## Progress (2026-11-14)

- Phase 0 reached: `build-toolchains` from scratch; the four profiles' CDs
  from one pinned state, each `iso` 7/7; the suites green but for two old
  gaps (386: APE shared memory cannot grow; arm64: no segment(3) in the
  kernel, since added, 2026-11-16; `tree/sys/src/build/host/MEMORY.md`). The userland builds with `-O2` (Rust thin LTO,
  Go `-s -w`). The release step (tag 0.1-preview) waits for the user.
- Phase 1: wsys is the desktop of the profiles `ui` and `full`
  (`desktop=rio` chooses rio); the hardware matrix is `hardware.md`.
  Updates over HTTP (the user's choice): `pull(1)` runs replica/pull through
  `replica/httpfs`, which serves the server's tree from a signed index
  (RSA, SHA-256 per file; webfs checks no TLS certificate, so the signature
  carries the trust); `tree/sys/src/build/host/replica/publish.py` publishes a CD's tree
  (every `mkcd`: into `cache/replica/current/NAME.ARCH`, channel `current`,
  signed with `~/.config/9space/replica.pem`), and the CD installs the client
  up to date. On gefs `pull` snapshots `main` first, the way back; on hjfs
  what it replaces is gone. `sys/src/build/host/tests/replica` covers it. The server does not
  exist yet: the CDs ask a placeholder, `https://9space-os.github.io/replica`
  (GitHub, likely). For GitHub: files over 100 MB are refused there (the
  `full` profile's rustc, rustdoc, clippy-driver are 147-161 MB stripped),
  objects would need splitting, or another host. Open as well: a file
  manager (the reference workflow is a test now: `sys/src/build/host/tests/workflow`); since
  done: `files`, 2026-11-16.

## Progress (2026-11-18)

- Desktop: a program has several windows under wsys (a window's clone
  makes a dialog or popup: parent, modal, askclose), through libdraw,
  SDL3, GLFW, winit (p9win) and Wayland (wlsys, `xdg_wm_dialog_v1`);
  ui(4) has window nodes. The same widget demo in rc, Go, Rust and C++
  (`sys/src/build/host/tests/uiserver`); the theme `9space` (acme's colours) is the default.
- Real hardware by PXE: `sys/src/build/host/hw/pxe.sh` boots a machine of the LAN
  with its root from the host (or a USB stick image), with the MCP server
  and drawterm. The ThinkPad X1 Carbon 3rd runs so: ACPI (battery, AC,
  brightness keys), `aux/pstate` (P-states), the WLAN (etheriwl: 802.11n,
  5 GHz, A-MPDU both ways, roaming by a background scan; 40-77 Mbit/s).
  The CD carries linux-firmware's WLAN and GPU firmware, each file checked.
- Graphics: Mesa 26.2.7. The i915 driver spent a CPU while drawing and
  minutes freeing buffers: the LinuxKPI's xarray and idr (OpenBSD's
  drm_linux.c) find the next entry by walking a splay tree from its start;
  splaying the tree at the index fixed it (tree 991f1c79d, amortized
  O(log n): closing a client went from minutes to about a second).
- The gcc port's checks are errors now (device registers volatile,
  sequence points, return mismatch, implicit declarations); zlib 1.4; one
  memory image per `rfork(RFMEM)` family. Fixes for 9front: `patch-upstream`
  up to 0047.
- Next: the X1 as a daily driver (criterion 1; plan in Phase 1). The user
  chose a local install on the SSD with PXE kept for test kernels, but not
  to wipe the SSD yet: until then it runs by PXE, and the steps without an
  install come first. Open decisions: the update server's place; the
  0.1-preview tag. The open tasks, all parts: `open.md`.

## Phase 0: reference build (weeks)

Goal: a reproducible build, an ISO, a green test suite.

- `bin/build-all`: toolchains (only when their commit changes) → tree
  (`build.exe -D` per arch) → ISO (`sys/src/build/host/guest/mkiso.sh` with Rust and Go).
- Done: the move to `~/Devel/9space/` (umbrella; only `paths.env` changed);
  `distfiles/` with checksums and `bin/fetch`; the toolchains from release
  archives (`fetch.sh`).
- ISO amd64 with `desktop=wsys`; VESA, virtio-gpu, amdgpu, i915.
- Result: **0.1-preview**, internal.

## Phase 1: daily driver (months)

Goal: a working day on the desktop.

- wsys as the default; term, the ui programs, wbar, a theme.
- draw(3), Wayland (foot) and Vulkan programs in daily use.
- Replica + `pull` with a way back; channel `current` (done but for the
  server's place and key, 2026-11-14).
- Reference workflow without a browser: term, an editor (acme/sam), a file
  manager, a ui client, a draw(3) program, a Wayland program, 9P over the
  network. As one test: `tree/sys/src/build/host/tests/workflow` (2026-11-16; term, sam, paint,
  uitodo, foot, the file manager `files`, 9P from the host, on a `ui`
  CD).
- The laptop as a daily driver (2026-11-18; the X1 Carbon 3rd, plan in the
  attic: `dist-docs/plans/x1-daily.md`): first the system on its SSD (or PXE
  kept; the user's call), no crash for a day (a soak test on the laptop),
  battery protection and a lid rule (no suspend yet); then TrackPoint
  scrolling, volume keys, the headphone jack, choosing a WLAN, an external
  display; later suspend/resume, the touchpad, Bluetooth.
- Result: **0.9-beta**, public, with a hardware matrix.

## Phase 2: stable

Goal: **1.0** with a frozen public API.

- ui(4), uiview, libui, uigo, p9win frozen; versions.
- A rebase cycle for Linux (DRM), Mesa, Rust, Go, gcc, wgpu/winit
  (`patches.md`).
- The security model of wsys/ui (file permissions, namespaces, buffer
  ownership).
- Signed ISOs, an SBOM (from `manifest.json` and the distfiles), channel
  `release`.

## Phase 3: platform

arm64 GPU, riscv64 (Rust target, drivers), more drivers; programs beside
it as packages (GPL allowed there, not in the tree).

## The five 1.0 criteria

1. A working day on the laptop without a crash (term, ui, draw(3),
   Wayland, Vulkan, network).
2. A reproducible build, byte-identical on two machines, with the Rust
   bootstrap.
3. `pull` updates and rolls back (or documents what is lost).
4. The public API frozen, with manual pages and examples.
5. A published hardware matrix (tested/works/untested; VESA as the
   guarantee).
