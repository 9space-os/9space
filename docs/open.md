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
  - Mesa: zink's read of deferred scissored clears (tree patch 0047:
    `zink_fb_clears_apply_region` applied them only when the read lay
    inside a scissor; main unchanged on 2026-11-19), its merge request
    text in `cache/mesa/upstream/zink-read-applies-clears.md`.
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
- Soaks, 2026-11-19: "busy while idle" for the whole 10 s window, once
  each: aux/acpi (X1, 18:44), aux/amdgpu (ThinkBook, 21:08), #l1wifi
  (ThinkBook, 21:11, the first test kernel of the reorder fix: all its CPU
  since boot in that window). Causes open; soak.rc now records the procs'
  state and kregs when it fires (tree, soak.rc).
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

- The LinuxKPI page pool (aux/i915, aux/amdgpu) gives memory back since
  tree 33d5e2fdd (i915-pool.md: (c) 231668ae3 the status line, (a)
  2aaa5c5e0 wholly free chunks, (b) 33d5e2fdd under memory pressure, with
  /dev/swap's free line). On the X1 (2026-11-20): under a hog the reserve
  chunk went back, nobody killed, the driver lived; the cost of the
  lookups' count is none measurable (vkcube within 0.1 %, drawspeed equal
  over 10 runs a side). Open: a bigger case (a client freeing hundreds of
  MB, then the hog), and "memory short" counted per episode, not per
  second.
- The LinuxKPI's `DECLARE_DELAYED_WORK` (workqueue.h) is Linux's form and
  does not compile here (`struct work_struct` has no `entry`); unused so
  far, `INIT_DELAYED_WORK` at run time instead.
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
   content flickers back while scrolling. Done as far as 9space goes:
   the 4-row band under the toolbar is servoshell's (no clear of the
   whole frame, egui's panels and the blit leave a gap; a Servo patch
   candidate, not now); heise.de's flicker while loading is the page.
   Found on the way: EGL never announced buffer age (tree d191d12f4, Mesa
   0046), zink read stale scissored clears (996f2e697, 0047); tests/gpu
   glage, wsysorder. Servo by eye again with the next root.
2. RADV finds no device on the ThinkBook's APU (1002:1681): RADV says
   only "Created an instance"; drm9's scan has DRM9DEBUG lines since tree
   0b322aebc, one run there names the cause.
3. From the X1's ui profile (60 s, 0.45 ms of ui's first proc a frame, no
   encode hotspot): Mesa was built with its asserts (debugoptimized,
   b_ndebug if-release: vk_object_base_assert_valid 2.2 %): a release
   build from now (b_ndebug=true, MESA_ASSERTS=1 the developer's), ms per
   frame on the X1 before/after; the printf a frame is gpu(4)'s text and
   the WSI's present (cheap, stays). uiprof.rc to cover all of ui's procs.
4. Tearing on the processor path: done (tree 31be0d5ed two screen
   objects, a1058f9b5 swap only when on the display; X1 and ThinkBook
   by eye clean, flips = events). amdflip.rc at the RX 7600's next binding.
5. Partial updates on the GPU path: A+B done (tree 6653c0d14: the WSI's
   regions to wsys, comp.rs composing only the damage per image; glage
   ~20000 instead of ~166000 window pixels a frame). C1 holds already
   (ui presents only on a change). C2, ui's damage: not a side channel
   beside Vulkan but VkPresentRegionsKHR chained by wgpu-hal's Vulkan
   backend, given through a small wgpu API (a crate patch in
   toolchain/rust; upstream wgpu has requests for present damage), so
   every wgpu client gains; the design decided when taken on.
6. The measurement: done for QEMU (tree ae171b460, tests/uiserver/uilat.c,
   measure.sh): first pixels ~265 ms (VESA) / ~281 ms (venus) after
   uinew; click → composed pixels 5.7 / 6.6 ms (ui's frame ~3.5-4 ms of
   it; the scanout not in it). The X1 with the user. Where the start's
   ~265 ms go (Vulkan instance, fonts, Rust std) belongs to 9. Open: a heap profile of ui's
   frame path: the X1's profile has ~25 % of ui in the pool (treesplay,
   pooldel, poolfreel, blockcheck: 9front's pool checks every block, by
   design) behind mainmem's one lock, Rust's System allocator going
   through malloc. Fewer allocations a frame first; a size-class cache
   per thread in Rust's std for plan9 (toolchain/rust) only if that
   shows nothing.
7. wsys' menus in the scale and font of the monitor they open on: done
   (tree 3924c581b); by eye on the X1 with a second monitor at another
   scale. The overlay plane with damage (bac452371): glage on the RX
   7600's plane at its next binding (QEMU has no plane).
8. term and ptyfs: SIGWINCH (to the processes that catch it only) and
   VMIN/VTIME done (tree 4ee185d0f). Open: Alt/Meta, the user's word.
   kbdfs starts a compose at Alt's press, so Alt+key never reaches term
   as a chord. Options: (1) compose only on Alt pressed and released
   alone, Alt+key a chord, which term sends as ESC+key (changes 9front's
   input for everyone: kbdfs(8), MEMORY); (2) Meta on another key
   (AltGr, right Alt); (3) Esc as the prefix only (works today).
   Recommended: (1). Also open: APE's `_getpty` starts ptyfs in the
   caller's window namespace, fixed for term only (L1372).
9. ui's start: done (tree 029c15f2e fonts late, f32415f7f pipeline cache;
   venus: first frame painted 392 → 96 ms warm, uilat 281 → 140 ms;
   UITIME=file for the phases). Small follow-ups: the Vulkan instance and
   device made while the fonts load (a thread; at most ~36 ms now); on a
   machine without a GPU, skip the Vulkan try (~30-40 ms on VESA) after a
   look at gpu(4)'s /shr/gpu*. Also: a system font index (names and faces
   to files, made at install or on a change) that ui and fontconfig (the
   Servo study scans /lib/font/ttf each start) could both use. Open from
   before: no native build with the `gpu` feature, a window node's x, y,
   role set only at creation.
10. GPU windows and draw(3) readers: documented (wsys(4) BUGS): under -g
    draw(3)'s screen image lacks the GPU windows, /dev/screen in a window
    has them. Low priority, until it shows on real hardware: the soft
    cursor (vga hwgc soft) under GPU windows, only when
    kmsout_cursor_image fails; fix: comp.rs draws the soft cursor as the
    top layer (its damage the old and new cursor rects).

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
wsys(4) BUGS: "Rust's threads take 64" of ~250 segments: check; a rio
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
- wsysorder.rc read the desktop after vktri's end as frames (X1, "back
  to 119" = #777777): counts only vktri's frames now (tree 785af7950);
  confirm on the X1, -O and plain.
- tests/ui text.rc's check after drawtest (no red left, all the text
  again; tree 3717c15d0) has not been seen failing: run it once against
  a wsys without the fix (w.drawn = None) to know it catches the kbmap
  bug.
- The VFIO guest's /tests lacks `drawcmp` and `workload`: amddraw.rc's
  drawcmp comparison and its workload part FAIL on the RX 7600
  (2026-11-19). drawcmp is built only by tests/draw/run.sh into its own
  root; vfio-test.sh copies tests/gpu's root and `amd*.rc` alone.
  Fix: build both into tests/gpu's root (build-vktest.sh), or let
  vfio-test.sh take tests/draw's root as well.
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
