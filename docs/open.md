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
- The X1 with the user there: aux/i915 killed while vkcube draws (tree
  fb4a91e54: gpu(3) onexit's GEN6_GDRST, ORCLOSE segments), as tests/gpu's
  killdrv.rc does on virtio: no "engine did not stop", no i915./kpi.
  segments left in #g, /dev/swap back down, aux/i915 restarts. A failed
  reset turns the display off until reboot. The same visit, under wsys -g:
  wsys falls back to the processor and composes on the GPU again once
  aux/i915 is back (tree cf74a918b; the drivers in shr(3) since 0b322aebc; tested in QEMU
  with venus, tests/gpu wsysback.rc).
- The X1's SSD: the install is decided, wiping the SSD is not. Suspend and
  `pull` on real hardware follow it.
- Sending fixes upstream:
  - 9front: the 59 patches in tree `patch-upstream/` (base `cb9e5e7e9`),
    none sent yet. Not made into a patch: APE's dup/`F_DUPFD` taking the
    number from `_fdinfo` (L1272): it goes wrong only in a program that
    mixes native descriptors with APE's (Rust's std with Mesa), which
    9front has none of.
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

- The 8-hour soak run (`tests/hw/soak.rc`, 1.0 criterion 1), first run
  2026-11-19 with the final kernel: stopped after ~5 rounds when memory ran
  out (logs: `cache/cli/pxe/soak-2026-11-19/`). Two leaks: the `ui -s`
  servers of killed ui clients stay (ui session: `ui -c` ends with its
  client); the sticky `#g` segments (`i915.<pid>.*`, `kpi.<pid>.*`) of an
  aux/i915 the pager killed stay until reboot (fix: segment(3) create
  honours ORCLOSE, after the main build). Then: the pager's choice of
  aux/i915 as victim (FreeBSD's protect(1)) and the i915 page pool never
  giving chunks back. soak.rc to FAIL on growth of procs and pages from
  round to round. Rerun after the fixes.
- `wlan auto` from termrc does not associate at boot (2026-11-19; by hand
  it does). Cause open; read-only while a soak runs.
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
- Small: sysname is the IPv6 link-local address; etheriwl's loud
  "file does not exist" at the first attach (L1726). Bluetooth (8087:0a2a).

## Graphics

- aux/i915's page pool never returns chunks (high-water ~1.2-1.6 GB; not
  a leak, L1781, L1786).
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

## Desktop: wsys, ui, Wayland

"The ui first, perfect" (the user, 2026-11-19), in this order:

1. servoshell on the X1 (Zink/kopper, wsys -g on i915): old screen
   content flickers back while scrolling: the present/compose order
   (a frame shown before its rendering fence, or an image given back to
   the app while wsys still reads it).
2. RADV finds no device on the ThinkBook's APU (1002:1681): RADV says
   only "Created an instance"; drm9's scan has DRM9DEBUG lines since tree
   0b322aebc, one run there names the cause.
3. From the X1's ui profile (60 s, 0.45 ms of ui's first proc a frame, no
   encode hotspot): Mesa was built with its asserts (debugoptimized,
   b_ndebug if-release: vk_object_base_assert_valid 2.2 %): a release
   build from now (b_ndebug=true, MESA_ASSERTS=1 the developer's), ms per
   frame on the X1 before/after; the printf a frame is gpu(4)'s text and
   the WSI's present (cheap, stays). uiprof.rc to cover all of ui's procs.
4. Tearing on the processor path (aux/i915, aux/amdgpu: devdraw's screen
   copied into the one scanned-out object): two screen objects, flips
   at the vblank (kmsscreen.c/kmsout.c, with the X1 session); a test that
   counts copies into the scanned-out one; the X1 by eye.
5. Partial updates on the GPU path: VK_KHR_incremental_present in Mesa's
   plan9 WSI, the regions to wsys, comp.rs composing the damage only
   (buffer age), ui's damage as present regions.
6. A measurement as a script: ui's start time to its first frame and the
   input-to-pixel latency, QEMU and the X1; and a heap profile of ui's
   frame path: the X1's profile has ~25 % of ui in the pool (treesplay,
   pooldel, poolfreel, blockcheck: 9front's pool checks every block, by
   design) behind mainmem's one lock, Rust's System allocator going
   through malloc. Fewer allocations a frame first; a size-class cache
   per thread in Rust's std for plan9 (toolchain/rust) only if that
   shows nothing.
7. wsys' menus (button 3, the window menu) in the scale and font of the
   monitor they open on (`drawmenu`: `self.sz`, `self.font`; L1794).
8. term: no Alt/Meta key; ptyfs: no SIGWINCH on a resize, VTIME/VMIN
   ignored (L1357); APE's `_getpty` starts ptyfs in the caller's window
   namespace, fixed for term only (L1372).
9. ui: a slow first frame (shader compilation, no pipeline cache across
   starts; L1274), no native build with the `gpu` feature, a window
   node's x, y, role set only at creation.
10. GPU windows not seen by draw(3) readers and the software cursor
    (L1359).

Later, by the user's choice: Wayland (no linux-dmabuf v4, no
linux-drm-syncobj, L1363; clients beyond weston and foot not ported,
L1293; subsurfaces clipped at the root, L1346; wlsys(4) BUGS: one output,
32 buffers, clipboard text only, no client scaling) and a draw(3)-ops back
end for ui under drawterm/rcpu (ui on the GPU sends 4.8 MB in 20 s at
33 ms RTT, ui -p 280 KB; wsys' text windows are done). For one visit at
the X1 with the user: the HiDPI cursor on a real monitor (L1392), the
tearing check, the GPU return under wsys -g (above).

Smaller: ui's scene not clipped to the damage before vello encodes it
(measured: no encode hotspot in QEMU or on the X1, no block for it);
wsys(4) BUGS "clients cannot announce theirs again yet" is stale for
p9win's windows and Mesa's WSI (say which still cannot: draw(3)
programs?), "Rust's threads take 64" of ~250 segments: check; a rio
inside a window goes Broken when the window closes (real rio too, an
upstream candidate, L1175); AltGr in the Windows drawterm fork (L1575).

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

- Sporadic, cause not found: tests/boot with an empty console (L1583;
  boot-cli now keeps `$CLI_DIR/serial.log`, written by QEMU, to tell a
  silent guest from a lost pty), wayland "wlvk subsurface" (L1623), wlan
  "5 GHz preferred" (L1588; 0 of 10 on 2026-11-19),
  gldesk and vktri hangs on venus (L1195, L1211, L1362).
- tests/gpu still has a fixed `sleep 8` (vkdraw; L1668).
- Never run: `scripts/build/rc/ape.rc` (no self-build), eframetest on
  venus (L1266, L1354); firmware loaded from the CD (only its staging
  checked; L1762).
- `build.exe -D` rebuilds musl's 12 `x86_64/*.s` each time (L1411); a full
  gs rebuild under `-D`, seen twice, unexplained (L879).
- A `-D` run right after a clean build (tree 66e79df91, 2026-11-19)
  recompiled 145 files: the pc64 kernel's sources, libsec's generated
  `secp*.c`/`jacobian.c`, `gram.c`; the kernel came out the same
  (md5 8547d171…). A no-op should compile nothing; cause open.
- The QEMU egl-headless SIGKILL workaround goes once the host's QEMU has
  baca2517 (L1416).

## The roadmap's later phases

- 1.0 criterion 2, a byte-identical build on two machines with the Rust
  bootstrap: never tried.
- Phase 2: the public API frozen with versions (ui(4), uiview, libui,
  uigo, p9win), a rebase cycle per part, the security model of wsys/ui,
  signed ISOs, an SBOM, channel `release`.
- Phase 3: the GPU on arm64, riscv64 drivers, packages.

## Hardware: gaps across the machines

The inventory of 2026-11-19 (`hardware.md`: the X1, the ThinkBook, the
build host); what is missing on more than one machine or blocks one:

- The ThinkBook's APU: RADV finds no Vulkan device (`vkEnumeratePhysicalDevices`
  zero, no drm9 line with `DRM9DEBUG=3`; the loader or ICD stage first);
  its rtw89 stalls after two load rounds while associated (an A/B against
  the kernel before tree be974532b, counters for the block-ack window's
  old frames, then a window reset as net80211's reorder does); `wlan auto`
  at boot does not associate on the X1 and the ThinkBook.
- Bluetooth on all three (X1 8087:0a2a, ThinkBook, host 2357:0604 RTL8761B):
  9front has none. A project of its own: HCI over USB as an nusb driver
  with the firmware load, L2CAP/SDP, then HID, then audio; permissive
  templates only (FreeBSD's netgraph Bluetooth, NetBSD's stack; BlueZ is
  GPL).
- HDMI/DP audio: the X1 ("no audio codecs found") and the host's RX 7600
  (1002:ab30 unknown to `audiohda`; amdgpu's display audio not done).
- Internal disks: NVMe and AHCI never read or written on real hardware
  (all machines' disks are off limits by the user's rule); a QEMU NVMe
  test first (detect, partition, gefs and hjfs, load, the CD's install
  onto NVMe) before an install on any machine.
- The build host as a target (plan: attic `dist-docs/plans/host-b550.md`):
  its devices by VFIO in a guest first (HDA ALC897, the Matisse xHCI with
  the PCM2902 USB audio, the RX 7600 with its HDMI audio), a native boot
  from a stick with `*nonvme=1 *noahci=1` only with the user's word (it is
  the PXE server and the agents' machine).

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
