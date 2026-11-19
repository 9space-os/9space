# Open tasks

All parts' open tasks in one list, collected on 2026-11-19 from
`tree/MEMORY.md`, the toolchains' `NOTES.md`, these docs, the plans in the
attic and the BUGS sections of 9space's own man pages, each checked against
git history. "Maybe done" marks an item a later commit may have closed.
Update this list when an item is closed or found; the sources keep the
details (`MEMORY.md` line numbers as of this date, "L").

## Waiting for the user

- The 0.1-preview tag: whether, where, its name (`roadmap.md`, wiki Releasing).
- The update server: its place and key; where files over 100 MB go (the
  `full` profile's rustc, rustdoc, clippy-driver are 147-161 MB; GitHub
  refuses them).
- The X1's SSD: the install is decided, wiping the SSD is not. Suspend and
  `pull` on real hardware follow it.
- Sending fixes upstream:
  - 9front: the 47 patches in tree `patch-upstream/`, none sent yet. Not
    yet made into patches: `pcibusno` (bus 0 for root bridges without
    `_BBN`/`_ADR`), APE's sigaddset/sigprocmask, `INTn_MIN` in `#if`,
    setvbuf `malloc(0)`, libdraw freeing getenv's string, SIGSEGV for
    traps, fcntl `EINVAL`, dup/`F_DUPFD` (L409, L1083, L1117, L1272,
    L1357, L1374).
  - OpenBSD: the drm_linux.c idr/xarray fix (`patches.md`) and older
    findings (fence-wait overflow, `min_array`, `dma_fence_chain_walk`;
    L1107, L1124).
  - Mesa: the zink vertex-buffer fix, its merge request text written
    (`cache/mesa/upstream`, L1688).
  - Linux: amdgpu does not bound the firmware's `number_of_points` (L1453).
- rtw89 in the install profiles, or on every CD as now (L1531).
- draw(3) on the GPU (glyphs and fills), deferred (L1369).
- The tree's tag `gcc-before-rebase-2026-10-31` looks like a backup ref,
  which the rules forbid: delete it only with the user's word.
- Later, by the user's choice: FreeType on upstream's Plan 9 build (L1712).

## The X1 as a daily driver

Plan: attic `dist-docs/plans/x1-daily.md`.

- The 8-hour soak run (`tests/hw/soak.rc`, 1.0 criterion 1): the i915 spin
  it waited for is fixed (tree 991f1c79d); it needs the final kernel on the
  X1 and so the user at the machine.
- Volume and mute keys: wsys has kbdtap and riostart starts
  reform/shortcuts under it (tree e2f6a78ef, tests/ui); untested on the X1's
  HDA keys.
- HDMI/DP audio: "no audio codecs found" (the i915 audio power domain);
  the cause of HDA's `waitup timeout` is open (L1756).
- UEFI: `bootx64.efi` resets the X1 at once; the test with 9front's own
  (`stick-9front-efi.img`) is pending (L1726).
- The second monitor black (pointer visible) after a replug or a login,
  seen once by the user, not reproduced; needs the user with the monitor.
  The same visit: tree 3f185ebb6 (windows moving to the remaining monitor
  and back, maximize and full screen per monitor, the scale per monitor,
  framebuffers that grow) is untested on the X1 with the current wsys.
- wsys' menus (button 3, the window menu) take the theme's one scale and
  font (`drawmenu`: `self.sz`, `self.font`), not the monitor's they open
  on (L1794).
- Small: sysname is the IPv6 link-local address; etheriwl's loud
  "file does not exist" at the first attach (L1726). Bluetooth (8087:0a2a).

## Graphics

- aux/i915's page pool never returns chunks (high-water ~1.2-1.6 GB; not
  a leak, L1781, L1786).
- The screen through aux/i915 and aux/amdgpu can tear: no double buffer
  with flips (L1128).
- venus: a lost ring notify (Mesa 0038), cause unknown; it logs and fails
  the tests now (L1302, L1699).
- RX 7600 by VFIO: the IH ring re-arm and "IH ring overflow" (L1086, L1701),
  buddy blocks left after a failed init (L1074), overlay planes and a
  second monitor never looked at (L1113, L1213).
- i915 on the X1: syncobjs only within a process (L1312), `live_rps_power`
  fails (L1139), a confirming run of the drmirqw fix (L1140), a driver
  restart untested (L1116).
- No GPU limits per user (VRAM, contexts; L1115); no shared venus
  semaphores (L1201); "MESA-LOADER: failed to retrieve device information"
  with `DRIVER_OVERRIDE` (L1117); no ROM BAR in `#G` (L1073).
- gpu(4) and gpu(3) BUGS: no MSI, 1 MB command buffers, the host-visible
  BAR uncached, each frame copied twice, a dma-buf token for one other
  process. Some entries look stale (amdgpu "no display", "no hotplug";
  the framebuffer never freed): check them.
- Mesa 26.3 as a step of its own (L1692).
- A fence wait with a time limit is several calls: gpu(4)'s fence file
  waits without one, so Mesa's plan9 drm (`drm9.c` `gemwait`, `syncwait`)
  polls with usleep(200-500) for a limited wait; a `wait k timeout` in
  gpufs.c and the drivers' `fencewait` (i915, amdgpu, virtio) would make it
  one blocking read.
- Mesa's plan9 WSI has no VK_KHR_incremental_present: on the GPU path wsys
  composes a client's whole window each frame even when ui drew only a
  small part of it.

## Desktop: wsys, ui, Wayland

- Wayland: no linux-dmabuf v4, no linux-drm-syncobj (L1363); clients
  beyond weston and foot (GTK) not ported (L1293); subsurfaces clipped at
  the root (L1346). wlsys(4) BUGS: one output, 32 buffers, clipboard text
  only, no client scaling.
- Under drawterm/rcpu (33 ms RTT): wsys' own text windows under -k upload
  pixels for every line, 113 s and 22.5 MB for 3000 lines of output (term:
  about 1 s). ui on the GPU sends 4.8 MB in 20 s against ui -p's 280 KB (its
  round trips per frame not yet traced); the rio reference run is still to
  do (tree MEMORY.md, 2026-11-19 drawterm). A draw(3)-ops back end for ui,
  as rio's clients send drawing commands rather than pixels, is the larger
  step after these.
- GPU windows are not seen by draw(3) readers and the software cursor
  (L1359).
- ptyfs: no SIGWINCH on a resize, VTIME/VMIN ignored (L1357); term has no
  Alt/Meta key; APE's `_getpty` starts ptyfs in the caller's window
  namespace, fixed for term only (L1372).
- ui: the scene not clipped to the damage before vello encodes it: a
  frame of a small change costs ui's process as much as a whole one
  (Masonry's passes, vello's encoding; the region saves only GPU work;
  L1813); no native build with the `gpu` feature, a slow first frame
  (shader compilation; L1274); a window node's x, y, role set only at
  creation (its width and height follow since tree fe201a126).
- wsys(4) BUGS: "clients cannot announce theirs again yet" is stale for
  p9win's windows (winit, ui, term) and Mesa's WSI, which move to the next
  wsys (tests/gpu "wsys gone"); say which clients still cannot (draw(3)
  programs?). "Rust's threads take 64" of ~250 segments: check.
- A rio inside a window goes Broken when the window closes; real rio does
  too, an upstream candidate (L1175).
- The HiDPI cursor never seen on a real monitor (L1392); AltGr in the
  Windows drawterm fork (L1575).

## Kernel, APE, the gcc port

- Out of memory with only the host owner's noswap processes left, the
  machine stays stuck (a noswap server holds the pages; the process
  killbig killed waits in a mount flush to it): no longer a spinning
  pager (tree c452a27cf), but nothing frees it either. A way out (kill a
  noswap process after all? fail the flush?) is open.
- Not yet checked for the gcc port: a struct's tail padding (kencc rounds,
  gcc does not) in raw I/O by sizeof (L770); 32-bit `long` wraparound in
  `long d = a - b` without a cast (L605); dtracy casting pointers to 64-bit
  integers, sign-extended by gcc on 386 (L725; its uchar/ushort shifts are
  done, c95092a33). Known and left: eqn `yylval=(int)s` (a pointer in an
  int, also in 9front amd64), scat `heavens()` (a projection over the
  wrong struct), gs' `sfnts_reader_rlong` (four calls in one expression,
  a gs bug; L1628, L1629, L1646).
- APE: stdio without locks (`fopen` no longer gives two threads one FILE,
  tree aacb318f6; a shared FILE is unguarded); `_exit`/abort end the
  whole program only in native programs with Rust's std (`__plan9_exit`,
  tree 11a5cf69e), a C program's other pthreads go on; no locale but "C"
  (gcc `NOTES.md`, whose "`<uchar.h>` is missing" is stale: tree
  5265aca8a).
- acid cannot read the gcc port's ELF symbols (L938, L1574).
- 386: APE shared memory cannot grow (L1427); 386 and arm64 come later by
  the user's choice (L1382).

## Toolchains

- Rust: the std tests never ran on arm64 (one processor in the guest), the
  doc tests never; rustdoc and clippy-driver each carry the whole compiler
  (~490 MB together); no TCP keepalive; a caught note interrupts blocked
  calls in all procs; APE's copy procs leak their buffer after a close
  during a read. Two "open" entries in Rust's `NOTES.md` are done (TCP half
  close: tree 7e5a710d1; loopback connect under load: patch-upstream 0025):
  update them once the file's uncommitted work is in.
- Go: after `syscall.Exec` the other procs go on and hold the inherited
  fds (a parent never sees EOF); the exit-message patch to carry to each
  release, the vendored `x/sys/plan9` still old.
- riscv64: no ISO, the tree never built itself there, musl without real
  quad `expl`/`logl`/`log1pl`.
- Building `build.exe` with Go on 9front untested (wiki Toolchains).

## Network

- rtw89: MSI, VHT/HE, 6 GHz, the DMA mask above 64 GB; the "SER cannot
  recognize error" message at each start (harmless; L1531, L1543, L1568).
- etheriwl: 40/80 MHz and VHT; an aggregation queue of 64 (`Aggqmax` 16
  by default, ctl `aggq`) hung the 7265D before the tx-status fix
  (tree b9a54d270) and was not rechecked after it; the 9000 family's path
  untested, no card (L1763, L1765).
- Replica: the signed index has no expiry; no way back on hjfs (L1444).
- factotum's wpapsk `calcptk` orders the two nonces by their first 6
  bytes (`memcmp(..., Eaddrlen)`), not all 32: a wrong PTK only when those
  6 bytes are equal; 9front's code, an upstream candidate (L1517).

## Tests and the build

- Sporadic, cause not found: tests/boot with an empty console (L1583),
  wayland "wlvk subsurface" (L1623), wlan "5 GHz preferred" (L1588),
  gldesk and vktri hangs on venus (L1195, L1211, L1362).
- tests/gpu still has a fixed `sleep 8` (vkdraw; L1668).
- Never run: `scripts/build/rc/ape.rc` (no self-build), eframetest on
  venus (L1266, L1354); firmware loaded from the CD (only its staging
  checked; L1762).
- `build.exe -D` rebuilds musl's 12 `x86_64/*.s` each time (L1411); a full
  gs rebuild under `-D`, seen twice, unexplained (L879).
- The QEMU egl-headless SIGKILL workaround goes once the host's QEMU has
  baca2517 (L1416).

## The roadmap's later phases

- 1.0 criterion 2, a byte-identical build on two machines with the Rust
  bootstrap: never tried.
- Phase 2: the public API frozen with versions (ui(4), uiview, libui,
  uigo, p9win), a rebase cycle per part, the security model of wsys/ui,
  signed ISOs, an SBOM, channel `release`.
- Phase 3: the GPU on arm64, riscv64 drivers, packages.

## Shelved by the user

- Power management (2026-11-19): suspend stages B-D, the PXE root lost
  after more than 150 s asleep (ufs keepalive), the device that keeps the
  package out of pc3 and deeper, a load test of the C-states (behind
  `*cstates=`), `aux/pstate` only with `pstate=`; HWP, CPPC and AMD
  P-states untested.
- aux/power reads a processor's MSRs on the wrong one on an idle
  machine (its `sleep(0)` after `wired n` yields only when another process
  is ready) and does not clamp a residency to 100%: one absurd cc7 on the
  X1. The fix (sleep(1), a reading kept per processor, clamped) is in the
  attic, `dist-docs/plans/aux-power-wired.patch`, not applied.
- nix on the X1 (the touchpad dead under nix, its UEFI "no boot devices";
  L1728).
- ThinkBook: the power button (GPIO, no event), fingerprint, internal mic,
  Bluetooth, the IR camera's emitter, tap-and-drag and horizontal
  scrolling.
