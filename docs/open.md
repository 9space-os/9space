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
  - 9front: the 65 patches in tree `patch-upstream/` (base `cb9e5e7e9`;
    0064/0065 of 2026-11-21: shr(3)'s walk and chan.c's createdir held a
    lock across a remote walk, the killdrv deadlock), none sent yet. Not made into a patch: APE's dup/`F_DUPFD` taking the
    number from `_fdinfo` (L1272): it goes wrong only in a program that
    mixes native descriptors with APE's (Rust's std with Mesa), which
    9front has none of.
  - OpenBSD: the drm_linux.c idr/xarray fix (`patches.md`) and older
    findings (fence-wait overflow, `min_array`, `dma_fence_chain_walk`;
    L1107, L1124).
  - Mesa: the zink vertex-buffer fix, its merge request text written
    (`cache/mesa/upstream`, L1688).
  - wgpu: wgpu-core's Surface::present/discard return on an invalid
    (lost) device before they take the acquired texture, so the
    swapchain can never be destroyed (a panic in wgpu-hal); trunk has
    the same order (2026-11-20). toolchain/rust ad26ee2's patch.
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
  state and kregs when it fires (tree, soak.rc). aux/acpi's (2026-11-21, the
  X1: ~3% of a processor at idle, all system time): ec.c's ecwait polls
  with delay(1), 1 ms of busy waiting per poll, ~25-45 ms per _Q/_BST;
  the fix after OpenBSD's acpiec_wait (300 polls of microdelay(1) first)
  is in the stability session's clone (branch ecwait), its X1 test (acpi's
  system time per 10 s, before 300-370 ms; battery, brightness, lid) with
  the user, then patch-upstream 0066. Separate: ec.c holds the spinlock
  ec.Lock across waits of up to 1 s.
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
  over 10 runs a side). "memory short" counts episodes and seconds since
  cd5115f52. The GPU drivers are noswap since c0a610b20 (gpu(4)): on the
  X1's hog soak (2026-11-20, attic hw/x1-hogsoak-20261120) aux/i915 lived
  and the pool gave 8 chunks back, but the pager killed wsys, vkcube and
  wbar first (each bigger than a hog child): wsys to be noswap too
  (wsys(4), FreeBSD's protect(1); patch ready, the ui session's area).
  Open: the soak again with it and a slower hog (the pool giving back
  over seconds), and a client freeing hundreds of MB. An option for the
  user, not planned: a kill priority per process (Linux's oom_score_adj:
  clients before the compositor) instead of the on/off of noswap.
- The LinuxKPI's `DECLARE_DELAYED_WORK` (workqueue.h) is Linux's form and
  does not compile here (`struct work_struct` has no `entry`); unused so
  far, `INIT_DELAYED_WORK` at run time instead.
- The GPU restart path under host I/O load (tests/gpu wsysback, QEMU with
  venus, 2026-11-20): reproduced with an artificial load on the host's disk
  (attic hw/wsysback-20261120/iorepro: a 4 GB-file writer with fsync and a
  small-file storm): 2 FAIL and 1 hang in 16 runs, against 0 in 24 without
  load. (1) A vktri started fresh after the driver's restart gets
  VK_ERROR_DEVICE_LOST on its first submit: venus says "the renderer is
  lost (ring fatal error on submit)" (MESA_LOG_LEVEL=debug): its new ring
  already carries VK_RING_STATUS_FATAL_BIT_MESA, which only the host's
  renderer (virglrenderer) sets; its context never submitted ("fence 0/0"),
  the new driver fine, kmesg clean. The host's journal (not
  VIRGL_LOG_FILE) says why, 15 times on 2026-11-20: `vkr_ring_thread:
  cmd_size(N) > ring->buffer.size(131072)`, N 1.5 to 4.2 M: the new ring's
  control memory holds an old ring's tail counter, memory aliased between
  an old and a new ring across the driver's restart: the guest's shmem
  cache, or QEMU's deferred blob unmap at a hostmem offset the new driver
  hands out again. Cause found (code, 2026-11-20): venus's shmem, the
  ring's control memory too, is a host blob, and vn_renderer_plan9 maps
  it by attaching the kernel physseg of the whole hostmem BAR
  (gpu0bar4[cw], devgpu.c) for the process's life; no #g segment, so
  nothing revokes it when the driver dies: the across vktri writes its
  old ring's tail at the offset the new driver gives a new ring. The same
  is an isolation gap without any restart: every venus client sees every
  other client's host blobs, and its own freed ones. Fix (ui session):
  per mapped host blob a #g alias segment of the BAR in virtiogpu
  (ORCLOSE, lost), attached per bo; unmap removes it. Not the context ids
  (destroyold, reverted), not "owner going" (0c6a48036) nor segment.c's
  idle image order (attic hw/wsysback-20261120/destroyold/,
  journal-ringfatal.txt). Fixed (tree 9883f4414, 2026-11-21): each mapped
  blob in a #g segment of its own (`map r seg va size info`; Mesa's venus
  renderer, wsys' import and gpuctxtest with the faults past the blob and
  after unmap); iorepro 16 under the host load: all ok, 0 `cmd_size` lines
  (15 before). (2) A hang of 300 s:
  the killed virtiogpu in "Queueing", the new one in "Stat", vktri in
  "Open", the closeprocs in "Queueing"; its kernel stacks are not read yet
  (rc's dd cannot seek to a kernel address; acid -k, else a pread helper).
  Maybe killdrv's devshr deadlock (fixed 2026-11-21, patch-upstream 0064):
  read its stacks if it comes again.
- aux/amdgpu killed on the ThinkBook (amdlost, 2026-11-20, attic
  hw/thinkbook-amdlost-20261120): (A) fixed (tree 969846bfc, 2026-11-20):
  the LinuxKPI made its views ORCLOSE only after p9_onexit, which aux/amdgpu
  never calls, and a dead pager queue revoked nothing; now the views are
  always ORCLOSE (aux/gpu/gpuseg.c, the one place for the drivers' #g
  segments) and a dead queue revokes its pager segments. tests/gpu
  segrevoke "pager dead" failed before (the client killed at an unmapped
  page, its write in the bar), passes after; on AMD hardware still to be
  run (the RX 7600 by VFIO). (B) the restarted driver
  fails its probe: "psp reg (0x16080) wait timed out ... PSP create ring
  failed ... hw_init of IP block <psp> failed -22", then a MODE2 reset: the
  killed driver leaves the PSP where no firmware loads; Linux resets the
  ASIC before probing one already initialised (to look at in OpenBSD's
  amdgpu first). Testable only on the RX 7600 by VFIO now (the ThinkBook
  is no longer a test machine, 2026-11-20). B is also why aux/amdgpu arms
  no reset at exit (no p9_onexit): it needs an onexit sequence, so that its
  page-owning segments go with it too.
  On the RX 7600 by VFIO (2026-11-20, attic hw/rx7600-vfio-20261120):
  A holds (Broken 0, wsys back on the GPU), B does not occur on Navi33 (the
  re-probe goes through), amdgpu9's lost handling works (RADV "context is
  lost", vktri a new device). ui's panic at its GPU retry was wgpu-core's
  (toolchain/rust 774f997, tree fdcebe36c). Open: (C) a new driver's views
  get the old one's addresses (p9dev.c's segnext from the same base), a
  client still holding the old lost views fails segattach ("segments
  overlap") and RADV then faults on a shader whose upload failed (the X1
  session's fix is designed: a view's va 0 through devsegment's range
  allocator, segnext gone; RADV's missing check is the ui session's Mesa
  patch). (D) the
  new aux/amdgpu's probe takes 23 s after a restart, and wsys' backoff
  (2+4+8+16 s) adds about 10 s before it composes on the GPU again.
  On hold (the user, 2026-11-21): the RX 7600 is released from VFIO and
  stays the host's (venus); A on AMD, B, C, D and the RADV check wait for
  an AMD machine.
- A known limit (2026-11-20): the LinuxKPI drivers (i915; amdgpu once
  its views are always ORCLOSE, defect A's fix) hold one open ORCLOSE file
  per client view, so all clients together have at most MAXNFD (5000,
  portdat.h) views of one driver, its own fds included. To measure in a
  guest (venus): how many buffer objects ui (vello) and servoshell hold. Later,
  a design without a file per view (the kernel removing a dead driver's
  views by their maker).
- The #g segment handling of the drivers is there twice: virtiogpu.c and
  the LinuxKPI's p9dev.c each have segcreate, rmseg and the ORCLOSE
  table, and both need the same rule (views ORCLOSE always, page-owning
  segments after the reset at exit). One library for the drivers'
  segments (modularity rule).
- Isolation between clients of one driver: the per-object views give "a
  client maps only its own objects, views end at unmap and at the
  driver's death", not isolation between users' processes, which reach
  each other anyway as one user (#g by name, /proc/N/mem). Drivers per
  user (or views per user) are a design question.
- venus: a lost ring notify (Mesa 0038), cause unknown; it logs and fails
  the tests now (L1302, L1699).
- RX 7600 by VFIO (on hold, see above): the IH ring re-arm and "IH ring overflow" (L1086, L1701),
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
After a GPU driver's loss: venus done (Mesa 0048, tree e94dbb71d). hasvk on
    the X1: new objects after the loss have no map and hasvk writes through
    it (ui's crash); drm9 then gives local memory for them (written, the X1
    tests it). Next: the same in amdgpu9.c for RADV (libdrm_amdgpu's BO
    allocation and map after the loss).
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
a rio
inside a window goes Broken when the window closes (real rio too, an
upstream candidate, L1175); AltGr in the Windows drawterm fork (L1575).

## Kernel, APE, the gcc port

- Out of memory with only the host owner's noswap processes left, the
  machine stays stuck (a noswap server holds the pages; the process
  killbig killed waits in a mount flush to it): no longer a spinning
  pager (tree c452a27cf), but nothing frees it either. A way out (kill a
  noswap process after all? fail the flush?) is open.
- Checked for the gcc port (2026-11-20, by tool; the scripts in the attic,
  `dist-docs/plans/padcheck/`): a struct's layout as 6c/8c give it
  (padded to 8/4 at the end, struct members aligned to 8/4) against gcc's
  DWARF for every object: 1469 structs differ, 13 of them in raw I/O by
  sizeof, none wrong with gcc (scat's records are 8c's sizes; Udphdr is
  52 as udp(3) wants, 6c's 56 is a 9front bug in tftpfs and socksd);
  `ulong - ulong` into a 64-bit `long` (clang-query, 108 places): real in
  pc/i8253.c `i8253timerset` and port/segment.c's idle image order;
  pointers to (u)vlong on 386, sign-extended by gcc: dtracy's arguments.
  Fixes made (gcc a1778c553, 75dcc306c, d806af79b; main ceba80e85;
  upstream 0061/0062). The clang checks again over a copy where every
  embedded member is `union { Lock; Lock Lock; }` (both access paths, the
  same layout), the kernel's register globals (`m`, `up`) plain externs
  and `-ferror-limit=0` (clang had stopped after 20 errors a file):
  errors 8065 in 1761 files before, 6152 in 1554 after (the rest old
  K&R files and local headers), and the same 105 and 58 places as without
  it: nothing missed (`padcheck/transform.py`). Open: 386 and arm64
  objects only where a directory's last build was theirs; sudoku's save
  files (12 bytes a cell against 6c's 16). Known and left: eqn `yylval=(int)s` (a pointer in an
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

- Rust: the std tests never ran on arm64 (one processor in the guest; nor
  tests/exitrace, the 2026-11-21 fix of a program's end killing too few
  procs: toolchain/rust b92d626, amd64 and 386 ok), the
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
- rust-analyzer (the user, 2026-11-20; shelved 2026-11-21: the current tasks
  first): (1) on the Linux host, a
  `rust-analyzer.toml` per workspace (the tree's, toolchain/rust's, browser's)
  so that it analyses for `x86_64-unknown-plan9` with the stage-1 rustc's
  sysroot and the right cargo config (paths from paths.env), so that
  plan9-only code is not shown inactive; (2) ported to 9space: built by
  toolchain/rust for plan9 next to rustc, clippy and rustfmt (stage2 tools),
  run on 9space as an LSP server for editors there; needs the plan9 std's
  process, pipe and file-watching parts it uses (polling, since there is no
  inotify); (3) later both cargo and rust-analyzer for the host from
  toolchain/rust too, so the builds need no rustup.
- The script review's findings (2026-11-20), the toolchains' part
  ((a) and (b) fixed): (c) x86_64-unknown-linux-gnu hard-coded as rust's build host
  (install.sh, tests/rustc.sh, cargo-build.sh). (d) gcc's build.sh usage
  stops before BUILD, OUTDIR, PLAN9; gcc tests/mk.sh ignores BUILD;
  gcc fetch.sh's key branch has no keys/ (dead), autoconf 2.69 listed
  but built by nobody; rust's async.sh and std-runner.sh let PLAN9_RISCV override PLAN9; rust
  guest.sh's arm64 SMP=1 (the wfe hang is fixed; check *ncpu first);
  rust-patches.sh's `ids "$d"` argument unused; crates-patch.sh's
  libp9.a check silent without the amd64 tree; the installed READMEs say
  "9front-rust", "9front-gcc", "9front-go" and go's "no cgo" (wrong);
  go build.sh keeps build/gocache after a make.bash; go tests/guest.sh's
  cp fallback lacks rust's rm -rf; rust tools/csstress.rc has no header.

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

- The instance (2026-11-25, `dist/bin/instance`, `check -instance`, wiki
  Testing): gcc, go, rust, rio pass on it, again and again on the running
  system; open: **workflow's foot** (its window under wlsys stays black, no
  prompt, a line typed in writes nothing: 35/36; not known whether the CD has
  it too, `check -iso` does not run workflow); **mcp** fails there as on the
  CD (3/5: initialize, tools/call, deny; suspected its long JSON lines on the
  serial line); the tests with a wsys of their own on the bare console (draw,
  sdl, glfw, winit, uiserver, wayland) do not run on the instance yet (its
  desktop holds the screen).
- The X1, updated on 2026-11-24 with an update archive whose apply.rc copied
  over `/amd64/rust`: two `libstd-*.rmeta` side by side would make rustc
  refuse ("multiple candidates"), as on the instance. Not looked at yet (the
  X1 did not answer); the next update replaces the toolchains' trees whole.
- Later (the user's plan, 2026-11-25): a test framework after NetBSD's ATF
  (atf(7); `NETBSD_SRC`: `external/bsd/atf`, its test cases in `tests/`), in
  Plan 9's manner rather than a port of ATF and Kyua (C++, Lua, SQLite):
  test programs and rc scripts beside what they test, each listing its cases
  and printing one `ok|fail|skip name` line per case (the form tests/run.sh
  and tests/vm.py use now), a runner in rc that runs them on the system
  itself (an installed machine, the instance, the X1) without the host;
  NetBSD's cases (libc, the kernel's interfaces, the programs; BSD licence)
  as the source of what to test, rewritten for Plan 9 where its interfaces
  differ. To be planned; nothing started.
- The kencc and gccmk builds (2026-11-22/23, `tree/scripts/guest/build-kencc.sh`,
  `dist/bin/check -native`): kencc builds the whole tree again (run 7: 681
  programs, the kernel pc64; pstate.c fixed after it, compiled with 6c alone).
  gccmk: run 1 (4 CPUs) ran out of its 3 h at cmd's last programs; `pcc -TVwc`
  (ape/lib/auth) fixed in gccmk's pcc; libc/9syscall's generated `.s` stubs
  have no GAS port (`gcc-as` fails there; the build's own stubs are used).
  **Open:** run 2 with `SMP=8 MEM=4096` lost the guest's TCP connection to
  the root's ufs (guestfwd 10.0.2.100:564) after ~25 min: the whole guest
  stopped, no echo on the console, no ^T^T; host side no connection on 5640,
  no ufs or QEMU log. Not seen with 4 CPUs. To find: the guest's TCP
  (retransmits, a reset) under 8 CPUs, or slirp's guestfwd. Run 3 (4 CPUs)
  stopped on the user's word (2026-11-23): gccmk and the lost connection are
  to be tested on hardware later.
- **Kernel heap exhausted** (2026-11-23, installed 9space in `~/9space`, KVM,
  4 CPUs, 4 GB): during the 4th gccmk run over all of `/sys/src` in one boot
  (runs 3 and 4 piped `gcc -E` of every file through grep, megabytes each)
  the screen filled with "no memory for allocb" and "no memory for smalloc";
  no process could be started ("kernel allocate failed"), MCP stopped
  answering. **Found and fixed (tree ef7c1756c):** devmnt.c's mntwalk lost
  its clone chan on every failed walk (a local set after waserror, read in
  its handler, not volatile: gcc's register copy after the longjmp). The
  candidates of `tree/scripts/check/find-clobbered.py` reviewed: six more
  made volatile (patch-upstream 0066); open: devvmx eventparse frees `q`
  after `q++` (a bug of its own, kencc too). gccmk again
  on the test host with the fix: all of 9front's mkfiles build (mp3enc
  fixed after it), the kernel heap 5.7 -> 7.1 MB through the run.
- Sporadic, cause not found: tests/boot with an empty console (L1583;
  boot-cli now keeps `$CLI_DIR/serial.log`, written by QEMU, to tell a
  silent guest from a lost pty), wayland "wlvk subsurface" (L1623), wlan
  "5 GHz preferred" (L1588; 0 of 10 on 2026-11-19),
  gldesk and vktri hangs on venus (L1195, L1211, L1362).
- tests/gpu still has a fixed `sleep 8` (vkdraw; L1668).
- tests/static's rc syntax check covers only some test directories:
  tests/uiserver and others are not parsed, and quote and redirection
  mistakes (an apostrophe in an echo, `window ... 'cmd >file'`, whose
  redirection window(1) takes as its own) reached guests twice
  (2026-11-21); a shared helper for a window running a command with
  redirections is planned (ui session).
- wsys writes a diagnostic line in several writes (Rust's unbuffered
  stderr, format pieces), so a test's echo can land inside it: tests/gpu's
  `^back: the GPU composes again` missed once (2026-11-21). One write per
  line in wsys, and greps that need no line start (ui session).
- scripts/mesa/patches.sh rewrites sys/src/mesa/patches from scratch (rm,
  then format-patch overlay..HEAD); the series has gaps (0017, 0040), so a
  rerun renumbers ~30 patches. Renumber once on purpose, or add only new
  commits (and -N as rust-patches.sh does since toolchain/rust 7693b8b).
  scripts/mesa/vendor.py takes any intended change outside the arch dir
  for a conflict; VENDOR_FRESH=1 then overwrites every conflict unseen:
  accept changes from commits after the last vendoring, or list them.
- Sporadic, 2026-11-21: a whole guest froze once during browser realweb
  (run 73 of 90, tree be821f7e1: the console and rc's watchdog silent for
  79 min); 1 in 163 runs, not caught. Ready for the next one: browser
  tests/guest.sh QEMU_DEBUG (qmp and serial), the kernel kept in
  cache/browser/runs/freeze/; take `info registers -a` 2-3 times, `info
  cpus`, gdb's bt per vCPU before killing it.
- Sporadic, 2026-11-20: tests/guest's apegnutest once failed its pty part
  (tree 969846bfc's run): "^C: interrupt to the note group" first, then
  the VMIN 3 and VMIN 0/VTIME 3 checks behind it (they read what was
  left); the next run was green, 331 of 331. ptyfs' VMIN/VTIME are new
  (4ee185d0f). Log: cache/stability/logs/guest-defecta-fail1-console.log.
- Sporadic, 2026-11-20 (maybe the devshr deadlock, fixed 2026-11-21):
  tests/gpu's wsysback hung for 300 s (tree
  e94dbb71d's run, again in 627ade406+'s joint run without host load):
  the killed aux/virtiogpu in Queueing, the new one in Stat, vktri in
  Open, closeprocs in Queueing, wsys in Semacquire. Its kernel stacks are
  read by itself next time (tree ac44f4f5b: tests/gpu/kstacks.rc, acid -k,
  resolved by scripts/debug/kstack.py).
- Sporadic, 2026-11-20: tests/uiserver's uilost boot once printed no
  lines (the venus guest up, the MCP call in run.sh came back empty);
  the debug run and the next full run were green.
- wsysorder.rc read the desktop after vktri's end as frames (X1, "back
  to 119" = #777777): counts only vktri's frames now (tree 785af7950);
  confirm on the X1, -O and plain.
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
- The script review's code findings (2026-11-20; the whole list: attic
  dist-docs/plans/scriptreview/FINDINGS.md; (a) and (b) fixed), the
  tree's part: (c) hardcodings:
  tests/gcc/gcc.py's `'16.2'`; scripts/linux/kbuild.py guesses Linux (6,6)
  without VERSION; census.py, undef.py and gencmds.py match gcc's
  messages in German and English (LC_ALL=C instead); sdl3/vendor.py's
  version numbers not from VERSION, mesa/vendor.py's KeyError for arm64,
  wayland/build.sh's ARCH=amd64; hw/soak.py's -w/-H defaults are this
  LAN's addresses (from the machine files instead); hw/pxe.sh's OVMF
  paths (paths.env as boot-cli.sh) and its QMP helper taking an event for
  the reply. (d) small: rc scripts behind their .sh (gen-9syscall,
  gen-initcode-i, gen-bootfs, gen-rebootcode-i: no arm64; rc/ape.rc's
  lists by hand, no cxxwidgets; rc/check-install.rc ignores -r), paths.sh
  sourced twice (gen-bootfs.sh, gen-sd53c8xx-i.sh), dead code
  (find-added-casts.py), gencmds' warning names `6.` for every objtype,
  mkinstall.py's P9P twice, check-install.py's options by hand,
  find-clobbered/find-narrow-mmio check only a manifest's first
  configuration, stage-dist.sh's `gccproto` holds every extra proto,
  build-kencc.sh passes -smp twice, mcp-guest/vfio-test/pxe ignore
  PLAN9 for ROOT, boot-cli.sh builds ufs for disk and CD boots too,
  vfio-test.sh drops the arguments after `$1` without MCP, tests/wayland
  sources common.sh twice, tests/boot's ncpu in both branches,
  tests/static's numbering (va_arg under 5.), wlan/run.sh's misplaced
  WPA2 comment, tests/run.sh's default list without sdl, glfw, winit,
  uiserver, wayland (by name only, said so).

## Documentation

- The user, 2026-11-20: "9space muss so dokumentiert werden, dass
  Interessierte damit arbeiten können": as important as the next technical
  feature. Today the material is scattered (man pages ui(4), uiview, uigo,
  uitodo; the wiki's Building/Toolchains/Desktop; the tests' READMEs) and
  there is no entry point. The wiki becomes the reader's way in (dist/docs
  stays the internal planning; the man pages stay the reference):
  - Getting started: what 9space is; try it (the CD in QEMU, on hardware:
    the machines of hardware.md), first steps on the desktop. (X1 session)
  - Using: the desktop (wsys, windows, the bar, keys, theme, monitors), the
    network and WLAN, the GPU, files and the usual programs. (ui session for
    the desktop, X1 session for network/hardware)
  - Developing: a ui application from nothing to a test in a guest, with a
    worked example; how it talks to the system (files and 9P, /mnt/wsys,
    /dev/theme, the plumber, webfs); testing (tests/ui, uiserver, QEMU,
    tools/mcp); gcc, Rust and Go programs. (ui session; toolchains: X1)
  - Contributing: the parts and repositories, branches, which tests per
    area, the licence rules, how a change gets in. (X1 session)
  Written between the technical slots, without a guest; each page tried
  out by following it on a clean state. Source: attic dist-docs/documentation.md.

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

- claude9 (2026-11-21): talking to Claude, or a local LLM by llama.cpp's
  OpenAI-style server, from 9space, working through 9front-mcp; the plan in
  the attic (dist-docs/plans/claude9.md), not to be built until the user
  takes it up again.

- Suspend/resume: shelved again (user, 2026-11-20): stages B-D (the
  drivers around the sleep, the lid). Done before: the PXE root survives
  a long sleep (ufs without TCP keepalive, tree f90b2651b, not yet the
  laptops' running ufs: with the user); aux/power right (2328f9717).
- Power management in operation: `aux/pstate` on by default on both
  laptops (`pstate=auto` in their machine files, tree 9794dc663; X1
  intel-eist, ThinkBook amd-cppc). Waiting for the user at the machine:
  the C-states' load test (`*cstates=`) and which device keeps the
  package out of pc3 and deeper. HWP untested.
- nix on the X1 (the touchpad dead under nix, its UEFI "no boot devices";
  L1728).
- ThinkBook: the power button (GPIO, no event), fingerprint, internal mic,
  Bluetooth, the IR camera's emitter, tap-and-drag and horizontal
  scrolling.
