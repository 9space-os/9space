# Open tasks

All parts' open tasks in one list, collected on 2026-11-19 from
`tree/sys/src/build/host/MEMORY.md`, the toolchains' `NOTES.md`, these docs, the plans in the
attic and the BUGS sections of 9space's own man pages, each checked against
git history. "Maybe done" marks an item a later commit may have closed.
Update this list when an item is closed or found; the sources keep the
details (`MEMORY.md` line numbers as of this date, "L").

## Waiting for the user

- The stage 1 review fixes on real hardware (tree main 71c938b23 and the
  waserror fixes, gcc d9f1d850f/4c47fd8c9): green in QEMU (gpu 204/204
  with gcc and clang), but i915 and amdgpu run there only on virtio. The
  X1 (i915: context reuse, cancel_work_sync, hrtimer_cancel, late
  wakeups) after an update; the RX 7600 by VFIO (amdgpu: the growing
  request pool, sudo vfio-gpu.sh bind by the user; the host loses its
  screen meanwhile). Postponed by the user on 2026-11-27 ("geht heute
  nicht"); pushed since (GitHub main 0e470dffe has them). The X1 part done 2026-11-27 evening
  (main 8b2c2b55e, after two reboots): 300 i915 contexts opened and
  closed in a row (none failed, numbers stay at the first free one,
  the count as before), vkcube under wsys 5+10 times started, drawing,
  killed (no hang, none left, no i915 error state, aux/i915 +800 KB per
  10 runs, not growing). killdrv done too, the user there: aux/i915
  killed while vkcube drew under wsys and two walkers were in its tree:
  no proc of it left, its 78 #g segments gone, the memory back, no
  "did not stop"/fault/panic in kmesg; restarted (gpustart i915): the
  device served, vkcube drew again, no error state; the desktop there,
  mouse and keyboard working. Found on the way: the killed vkcube hung
  in its atexit functions (APE ran them for a kill note, Mesa's waited
  for the dead driver): fixed (gcc 51491d2a9, signal.c: none for
  SIGKILL's notes); to upstream, not yet in patch-upstream. Left: the RX
  7600 by VFIO (the request pool); natively the RX 7600 ran 71c938b23 on
  the B550 (CD of main 8b2c2b55e, 2026-11-27: wsys -g and vkcube,
  hardware.md). The stage 1 medium fixes (tree 932289ae7, 49e4edbc2: the
  concurrent ctxfree) are tested only on virtio: the X1 ran 8b2c2b55e,
  before them (L2077).
- The 0.1-preview tag: whether, where, its name (`roadmap.md`, wiki Releasing).
- The update server: its place and key; where files over 100 MB go (the
  `full` profile's rustc, rustdoc, clippy-driver are 147-161 MB; GitHub
  refuses them).
- The X1 under wsys -g with the user there: wsys falls back to the
  processor while aux/i915 is gone and composes on the GPU again once it
  is back (tree cf74a918b; the drivers in shr(3) since 0b322aebc; tested
  in QEMU with venus, tests/gpu wsysback.rc). The kill itself (killdrv,
  fb4a91e54) passed on the X1 on 2026-11-27 (above).
- The X1's install: done by the user on a second SSD (2026-11-27); its
  first SSD stays untouched. Now open on it: `pull` on real hardware (once
  the update server exists) and the soak run on the installed system;
  suspend stays shelved.
- Sending fixes upstream:
  - 9front: the patches in tree `patch-upstream/` (base `cb9e5e7e9`, up
    to 0075) are published (the user, 2026-11-27); left: what 9front
    takes, into `archive/`. Not made into a patch: APE's dup/`F_DUPFD` taking the
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
  out (logs: `cache/cli/pxe/soak-2026-11-19/`). Its causes are fixed: the
  `ui -s` servers of killed clients (`ui -c`, tree 72de338ff), the sticky
  `#g` segments of a killed aux/i915 (ORCLOSE and gpu(3) onexit,
  fb4a91e54), the pager's choice of the driver (proc(3) nokill,
  8de91a2c3), the page pool giving chunks back (33d5e2fdd); soak.rc fails
  when procs, pages or the driver's files grow after round 2. Left: the
  rerun.
- Soaks, 2026-11-19: "busy while idle" for the whole 10 s window, once
  each: aux/acpi (X1, 18:44), aux/amdgpu (ThinkBook, 21:08), #l1wifi
  (ThinkBook, 21:11, the first test kernel of the reorder fix: all its CPU
  since boot in that window). Causes open; soak.rc now records the procs'
  state and kregs when it fires (tree, soak.rc). aux/acpi's (2026-11-21, the
  X1: ~3% of a processor at idle, all system time): ec.c's ecwait polled
  with delay(1); fixed in tree 9299f3880 (300 polls of microdelay(1) first,
  as OpenBSD's acpiec_wait): on the X1 its system time per 10 s 280-360 →
  0 ms, a battery read 60 → <10 ms, brightness and lid fine (L1968). Left:
  its export to patch-upstream (0066 is now another patch), with
  sdiahci's class-code match (656607f9b, L1971). Separate: ec.c holds the
  spinlock ec.Lock across waits of up to 1 s.
- Volume and mute keys: wsys has kbdtap and riostart starts
  reform/shortcuts under it (tree e2f6a78ef, tests/ui); untested on the X1's
  HDA keys.
- HDMI/DP audio: "no audio codecs found" (the i915 audio power domain);
  the cause of HDA's `waitup timeout` is open (L1756).
- UEFI: `bootx64.efi` resets the X1 at once; the test with 9front's own
  (`stick-9front-efi.img`) is pending (L1726). The B550 boots 9space's
  from a stick (2026-11-27, hardware.md).
- The second monitor black (pointer visible) after a replug or a login,
  seen once by the user, not reproduced; needs the user with the monitor.
  The same visit: tree 3f185ebb6 (windows moving to the remaining monitor
  and back, maximize and full screen per monitor, the scale per monitor,
  framebuffers that grow) is untested on the X1 with the current wsys.
- Small: sysname is the IPv6 link-local address; etheriwl's loud
  "file does not exist" at the first attach (L1726). Bluetooth (8087:0a2a).

## Graphics

- RX 7600 (B550, native, 2026-11-27): after `gpustart amdgpu` and before the first
  client the status says load 96-100 %, gfx up to 2944 MHz, hotspot 46 → 76 °C in
  3 min (the fan ran up audibly, then down); with wsys -g: 6 %, 902 MHz, 54 °C. Power
  management starts only with the first client; until fixed, do not leave the card
  alone with no client (hardware.md).
- RX 7600 on the B550 natively (2026-11-27, hardware.md): the warnings "Failed to
  setup vendor infoframe ... -22" and an optc32_disable_crtc REG_WAIT timeout; the
  screen is black for a moment at the takeover. Not looked at.

- Write-combining for system RAM pages (2026-11-26, the user: later, on the
  list). There is WC on BARs (PAT entry 7, PTEWC, SG_WC; devgpu's gpuNbarMw,
  the KPI's ioremap_wc/io_mapping_wc/vmap_pfn), but not on the KPI's own page
  pool: set_pages_wc only sets PG_PMAP_WC, which nothing reads, set_memory_wc
  is a no-op, vmap maps cached. Needed only for amdgpu's USWC (a performance
  gain; without CONFIG_X86_PAT amdgpu leaves it off and snoops, correctly; the
  #warning at amdgpu_object.c:600 is accurate) and for Intel GPUs without LLC
  (the X1's Broadwell has LLC). A page must not be mapped cached and WC at
  once on x86, so it takes per-page memory types in a segment in the kernel
  (with a TLB shootdown), an interface in devgpu, then the KPI (set_pages_wc,
  vmap), and only then CONFIG_X86_PAT. Setting CONFIG_X86_PAT alone would be
  incoherent.
- The LinuxKPI page pool (aux/i915, aux/amdgpu) gives memory back since
  tree 33d5e2fdd (i915-pool.md: (c) 231668ae3 the status line, (a)
  2aaa5c5e0 wholly free chunks, (b) 33d5e2fdd under memory pressure, with
  /dev/swap's free line). On the X1 (2026-11-20): under a hog the reserve
  chunk went back, nobody killed, the driver lived; the cost of the
  lookups' count is none measurable (vkcube within 0.1 %, drawspeed equal
  over 10 runs a side). "memory short" counts episodes and seconds since
  cd5115f52. The GPU drivers are noswap since c0a610b20 (gpu(4)), nokill
  since 8de91a2c3 (proc(3) nokill, FreeBSD's protect(1); aux/nokill.c): on
  the X1's hog soak (2026-11-20, attic hw/x1-hogsoak-20261120) aux/i915
  lived and the pool gave 8 chunks back, but the pager killed wsys, vkcube
  and wbar first (each bigger than a hog child): wsys protected since tree
  220dda698 (noswap, tests/gpu wsysnoswap), nokill since 518c3fa67.
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
  an AMD machine. The B550 runs the RX 7600 natively since 2026-11-27
  (hardware.md): none of them tried there yet. C still open (p9dev.c's
  segnext as before).
- A known limit (2026-11-20): the LinuxKPI drivers (i915; amdgpu since
  its views are always ORCLOSE, tree 969846bfc) hold one open ORCLOSE file
  per client view, so all clients together have at most MAXNFD (5000,
  portdat.h) views of one driver, its own fds included. To measure in a
  guest (venus): how many buffer objects ui (vello) and servoshell hold. Later,
  a design without a file per view (the kernel removing a dead driver's
  views by their maker).
- The drivers' #g segments: one place since tree 969846bfc
  (aux/gpu/gpuseg.c, included by virtiogpu.c and the LinuxKPI's p9dev.c).
  Left: aux/intelgpu (aux/gpu/intel/plan9/sys.c) still has its own
  stickyseg and rmseg, without ORCLOSE.
- Isolation between clients of one driver: the per-object views give "a
  client maps only its own objects, views end at unmap and at the
  driver's death", not isolation between users' processes, which reach
  each other anyway as one user (#g by name, /proc/N/mem). Drivers per
  user (or views per user) are a design question.
- venus: a lost ring notify (Mesa 0038), cause unknown; it logs and fails
  the tests now (L1302, L1699).
- RX 7600 by VFIO (on hold, see above) or on the B550 natively (since 2026-11-27): the IH ring re-arm and "IH ring overflow" (L1086, L1701),
  buddy blocks left after a failed init (L1074), overlay planes and a
  second monitor never looked at (L1113, L1213).
- i915 on the X1: syncobjs only within a process (L1312), `live_rps_power`
  fails (L1139), a confirming run of the drmirqw fix (L1140). A driver
  restart passed on 2026-11-27 (killdrv: aux/i915 killed under vkcube,
  restarted by gpustart i915, vkcube drew again).
- No GPU limits per user (VRAM, contexts; L1115); no shared venus
  semaphores (L1201); "MESA-LOADER: failed to retrieve device information"
  with `DRIVER_OVERRIDE` (L1117); no ROM BAR in `#G` (L1073).
- gpu(4) and gpu(3) BUGS: 1 MB command buffers, the host-visible BAR
  uncached, each frame copied twice, a dma-buf token for one other
  process. Stale entries to remove: gpu(3) "no MSI" (devgpu has MSI since
  tree 52785b234) and "the framebuffer is never freed" (fbreap,
  3f185ebb6); gpu(4) "one output, one framebuffer; no cursor plane, no
  hotplug" (kmsscreen.c: outputs, cursor planes, hotplugproc; 3f185ebb6)
  and amdgpu "no display yet" (scanout since 2026-11-02, L1086; HDMI on
  the B550 natively 2026-11-27).
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
2. RADV on the ThinkBook's APU (1002:1681): done; with the drivers in
   shr(3) (tree 0b322aebc) RADV finds /shr/gpu/0 (RADV REMBRANDT, attic
   hw/thinkbook-radv-20261119, run 2), and ran there for amdgpu9's
   lost-driver test (tree d24ae5c73).
3. From the X1's ui profile (60 s, 0.45 ms of ui's first proc a frame, no
   encode hotspot): Mesa was built with its asserts; a release build since
   tree 2520c6386 (b_ndebug=true, MESA_ASSERTS=1 the developer's). Open: ms
   per frame on the X1 before/after; uiprof.rc to cover all of ui's procs.
   The printf a frame is gpu(4)'s text and the WSI's present (cheap, stays).
4. Tearing on the processor path: done (tree 31be0d5ed two screen
   objects, a1058f9b5 swap only when on the display; X1 and ThinkBook
   by eye clean, flips = events; amdflip.rc on the RX 7600 by VFIO
   2026-11-20 all ok, attic hw/rx7600-vfio-20261120).
5. Partial updates on the GPU path: done. A+B tree 6653c0d14 (the WSI's
   regions to wsys, comp.rs composing only the damage per image; glage
   ~20000 instead of ~166000 window pixels a frame); C1 holds (ui presents
   only on a change); C2 toolchain/rust c3cbf3b (wgpu 28's
   present_with_damage, upstream gfx-rs/wgpu PR #10152 backported:
   VkPresentRegionsKHR, EGL swap with damage) and tree d9949adf5 (ui
   presents what it drew: 10516 instead of 192864 pixels a frame for a
   progress bar).
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
   7600's plane done (2026-11-20: 600 overlay commits, 0 frames wrong,
   attic hw/rx7600-vfio-20261120).
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
the X1 with the user: the HiDPI cursor on a real monitor (L1392) (the
tearing check and wsys -g's return to the GPU are done: item 4; X1
drvswap 2026-11-20, attic hw/x1-wsys-drvswap-20261120).

Smaller: ui's scene not clipped to the damage before vello encodes it
(measured: no encode hotspot in QEMU or on the X1, no block for it);
a rio
inside a window goes Broken when the window closes (real rio too, an
upstream candidate, L1175); AltGr in the Windows drawterm fork (L1575);
wsys' build is not reproducible (one source built three times, three
md5s: only LLVM's inlining in Wsys::answer differs, thin LTO; MEMORY
2026-11-20 "cargostd auch für den Host-Teil", cause not yet looked for).

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
- APE: stdio locks each FILE once a second thread runs, `_exit`/abort end
  the other threads in every program (tree 32bab4bc8, 2026-11-19); no
  locale but "C" (gcc `NOTES.md`); FD_SETSIZE is still 96 while OPEN_MAX
  is 5000 (select ignores higher fds, FD_SET writes past the fd_set; the
  change is an ABI one down to the libc crate; MEMORY 2026-11-27, review
  stage 2).
- acid cannot read the gcc port's ELF symbols (L938, L1574).
- waserror locals (2026-11-27): the kernel's set after waserror and read in
  its handler made volatile (tree 59e317819, aaf01b020, 4c47fd8c9; upstream
  0069-0074); left: drawmesg's fmt/a (only the diagnostic output; MEMORY
  2026-11-27 "waserror-Muster").
- 386: APE shared memory cannot grow (L1427); the 386 guest's notify
  frame alignment check fails, with gcc and clang alike (toolchain/clang
  NOTES part 7); 386 and arm64 come later by the user's choice (L1382).

## Toolchains

- Rust: the std tests never ran on arm64 (one processor in the guest; nor
  tests/exitrace, the 2026-11-21 fix of a program's end killing too few
  procs: toolchain/rust b92d626, amd64 and 386 ok), the
  doc tests never; rustdoc and clippy-driver each carry the whole compiler
  (~490 MB together); no TCP keepalive; a caught note interrupts blocked
  calls in all procs; APE's copy procs leak their buffer after a close
  during a read. Two "open" entries in Rust's `NOTES.md` are done (TCP half
  close: tree 7e5a710d1; loopback connect under load: patch-upstream 0025):
  to be updated there (the file has no uncommitted work now, 2026-11-27).
- Go: after `syscall.Exec` the other procs go on and hold the inherited
  fds (a parent never sees EOF); the exit-message patch to carry to each
  release, the vendored `x/sys/plan9` still old.
- riscv64: no ISO, the tree never built itself there, musl without real
  quad `expl`/`logl`/`log1pl`.
- `build.exe` built with Go on 9space: done on the X1 (build-tool.rc,
  2026-11-25, MEMORY "build installiert"); its md5 differs from the Linux
  build (Go version and buildid still to compare; wiki Toolchains says so).
- clang (toolchain/clang; NOTES.md parts 1-8): cross and native on amd64,
  386, arm64 and riscv64, the whole tree built with `CC=clang` on each, every
  machine boots, and the system builds itself with clang (2026-11-27).
  `#pragma varargck` checks formats as kencc does (llvm-project 0013,
  2026-11-28; NOTES part 9). The amd64 sweep of gcc's and clang's warnings
  (2026-11-28, cache/clang/analysis) is worked through: the fixes are on
  `gcc` and `upstream` (patch-upstream 0076-0114; 0081 withdrawn), and three
  checks now catch the same mistakes (tests/static ulongmax and ulongshift,
  tests/build find-common-mismatch.py). Not merged, not pushed. The full
  gcc build with `check` (build, guest, boot) on them is running. Open:
  - the varargck places of the gcc-only kind (`%d` for a 64-bit sizeof,
    ptrdiff_t or ulong), on `gcc`, and `-Wno-plan9-format` for APE's
    libbio and libsec, which are built without kencc's `-F`;
  - a waserror check with control flow (a clang AST/CFG pass): a local
    changed inside a waserror()...poperror() scope, an error() after the
    change, and a read after the jump. A text scan has too many false
    alarms to be a gate (draft in cache/clang/waserror). 9space-3e read the
    36 likeliest of gcc's 269 -Wclobbered: none is live. devdraw's
    drawmesg `a`/`fmt` (three copies) hold by the rule but only feed a
    debug print that is off;
  - 386, arm64 and riscv64 are not swept yet. Rust's LLVM and the native rustc from the
  series with `Triple::Plan9`: rebuilt and confirmed without effect
  (2026-11-27; tests/run.sh 15/15, rustc.sh 3/3 on amd64, 386, arm64:
  toolchain/rust NOTES.md, "clang's patches in the llvm-project series").
- APE's own `sin`/`cos` (double) are inaccurate: `cos(M_PI)` is 2 ulp off,
  `sin(M_PI)` is -0 (found by clang's tests, 2026-11-25; gcc programs alike,
  hidden at -O2 by constant folding). Candidate: musl's, as for float and
  long double (tree MEMORY.md).
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
- The script review's findings (2026-11-20), the toolchains' part ((a),
  (b), (c) and most of (d) fixed: toolchain/rust 3fd03be, 163a9da;
  toolchain/go 372106c; gcc build.sh's usage, fabf42e). Left of (d): gcc
  tests/mk.sh ignores BUILD (writes $TOP/build); gcc fetch.sh's key branch
  has no keys/ (dead), autoconf 2.69 listed in sources.txt but built by
  nobody; rust guest.sh's arm64 SMP=1 (the wfe hang is fixed; check *ncpu
  first).

## Network

- rtw89: MSI, VHT/HE, 6 GHz, the DMA mask above 64 GB; the "SER cannot
  recognize error" message at each start (harmless; L1531, L1543, L1568).
- etheriwl: 40/80 MHz and VHT; an aggregation queue of 64 (`Aggqmax` 16
  by default, ctl `aggq`) hung the 7265D before the tx-status fix
  (tree b9a54d270) and was not rechecked after it; the 9000 family's path
  untested, no card (L1763, L1765).
- Replica: the signed index has no expiry; no way back on hjfs (L1444).

## Tests and the build

- The CD's /lib/firmware was empty (no proto named its files): fixed in tree
  0e470dffe (boot/firmwareproto; tests/iso checks the CD against firmware.list);
  the B550 CD of 22:35 (mkcd -dev gcc,rust,go -mcp) holds all 674 files, check -iso ok;
  still to try on the B550: gpustart amdgpu straight from that CD.
- MCP: `aux/pstate` started inside an rc call keeps the call open until its timeout
  (the server waits on the call's stdout, which the background proc holds).

- Mesa's work directory is one per machine, not per tree (2026-11-27):
  `cache/mesa/build-$objtype` holds gcc's sysroot view (a view of the tree
  that last sourced `sys/src/build/mesa/common.sh`), its cross wrappers and
  the meson build. Two builds of different trees at once (tree, tree-gcc,
  tree-clang) change it under each other: a clang build re-pointed it to
  tree-clang and gcc's wsys link on main took the clang `libvulkan.a`
  (tree 5c86a48d1: the view only for TOOLSET=gcc now). A directory per tree is
  out: the disk has no room for it (the user, 2026-11-27; amd64's alone
  is 22 GB, 11 of them cargo's). So the rule: no two Mesa or cargo builds
  of different trees at once.
- Updates (dist acbf579): apply.rc removes what the last update put on and
  the new one lacks (`/sys/lib/dist/update.files`). The X1 got its first list
  by hand (2026-11-25): 180 leftovers of the layout of 2026-11-24 removed.
  Instance and CD-installed machines get theirs with their next update.
- The instance (2026-11-25, `dist/bin/instance`, `check -instance`, wiki
  Testing): **done**. gcc, go, rust, mcp, rio, workflow pass on it, again and
  again on the running system (workflow since APE's timerfd honours
  TFD_NONBLOCK; mcp since its deny check no longer sends fshalt, which
  deny.example allows: tree b5de45cf5). The desktop categories (draw, sdl,
  glfw, winit, uiserver, wayland) pass on a throwaway boot of it (tree
  49c62065f, dist b4ef6e1: lib.sh deskguest, deskoff.rc, instance put,
  fresh's QEMU_EXTRA); winit's iced typing check had failed since tree
  fe201a126 (2026-11-19: a program sizes its first window, iced's 1024x768
  filled the screen), fixed in icedtest (toolchain/rust b868393). Fewer
  boots since tree 03b10e30c (draw's boot taken over by glfw, winit, uiserver;
  the archive staged once per run). 2026-11-26 with APE's wide ino_t/dev_t:
  12/12 (44 min), after toolchain/gcc's native binutils/gcc were rebuilt (the
  ld of 07:11 had bfd compiled with the old struct stat, linked with the wide
  libap: it crashed overwriting an existing output, so cgo and workflow failed).
- The X1: updated 2026-11-25 with the new apply.rc (toolchains replaced
  whole, one libstd), rebooted, Rust runs; `/tmp/up` removed,
  `/tmp/up.20261125` (3.2 GB) still there (the user's word).
- clang in the distribution (2026-11-26, tree aca5e6358): `-dev clang`, in
  `all` and so in `full`; `/$objtype/clang`, and for `objtype=386|arm64` the
  other machines' runtimes, `lib.gcc` (without the gpu group's) and `plan9.ld`;
  `build-toolchains` builds it (clang-host, clang-A); `tests/clang` 11/11 on the
  instance (again 11/11 after the relink against the `_dirfstat` fix, tree
  a7ebaf367: `apefresh -a`); wiki Toolchains, Building. `toolchain/clang` on
  GitHub (9space-os/clang), in `push` and `repos`. Pushed and pinned (dist
  3045b7c). Open: the branch nix's stage-dist without clang (`mkcd nix` leaves
  it out).
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
- The kencc and gccmk builds (2026-11-22/23, `tree/sys/src/build/host/guest/build-kencc.sh`,
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
  stopped on the user's word (2026-11-23). gccmk on hardware: done on the
  installed X1 (2026-11-25: all of /sys/src without a failing directory,
  `gccmk 9pc64` boots to the desktop; toolchain/gcc 6be417f). Still open:
  the lost connection under 8 CPUs.
- **Kernel heap exhausted** (2026-11-23, installed 9space in `~/9space`, KVM,
  4 CPUs, 4 GB): during the 4th gccmk run over all of `/sys/src` in one boot
  (runs 3 and 4 piped `gcc -E` of every file through grep, megabytes each)
  the screen filled with "no memory for allocb" and "no memory for smalloc";
  no process could be started ("kernel allocate failed"), MCP stopped
  answering. **Found and fixed (tree ef7c1756c):** devmnt.c's mntwalk lost
  its clone chan on every failed walk (a local set after waserror, read in
  its handler, not volatile: gcc's register copy after the longjmp). The
  candidates of `tree/sys/src/build/host/check/find-clobbered.py` reviewed: six more
  made volatile (patch-upstream 0066); devvmx eventparse freed `q` after
  `q++` (a bug of its own, kencc too): fixed in tree 0b21990fc
  (patch-upstream 0068, 2026-11-27). gccmk again
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
- sys/src/build/mesa/patches.sh rewrites sys/src/mesa/patches from scratch (rm,
  then format-patch overlay..HEAD); the series has gaps (0017, 0040), so a
  rerun renumbers ~30 patches. Renumber once on purpose, or add only new
  commits (and -N as rust-patches.sh does since toolchain/rust 7693b8b).
  sys/src/build/mesa/vendor.py takes any intended change outside the arch dir
  for a conflict; VENDOR_FRESH=1 then overwrites every conflict unseen:
  accept changes from commits after the last vendoring, or list them.
- Sporadic, 2026-11-21: a whole guest froze once during browser realweb
  (run 73 of 90, tree be821f7e1: the console and rc's watchdog silent for
  79 min); 1 in 163 runs, not caught. Ready for the next one: browser
  tests/guest.sh QEMU_DEBUG (qmp and serial), the kernel kept in
  cache/browser/runs/freeze/; take `info registers -a` 2-3 times, `info
  cpus`, gdb's bt per vCPU before killing it.
- Sporadic, 2026-11-20 (maybe the devshr deadlock, fixed 2026-11-21):
  tests/gpu's wsysback hung for 300 s (tree
  e94dbb71d's run, again in 627ade406+'s joint run without host load):
  the killed aux/virtiogpu in Queueing, the new one in Stat, vktri in
  Open, closeprocs in Queueing, wsys in Semacquire. Its kernel stacks are
  read by itself next time (tree ac44f4f5b: tests/gpu/kstacks.rc, acid -k,
  resolved by sys/src/build/host/debug/kstack.py).
- Sporadic, 2026-11-20: tests/uiserver's uilost boot once printed no
  lines (the venus guest up, the MCP call in run.sh came back empty);
  the debug run and the next full run were green.
- Sporadic, 2026-11-27: tests/gpu 198/201 on tree 49e4edbc2 (the review's
  stage 1 medium fixes): i915's mock selftests (aux/i915 -M: sw_fence
  "Timeout fence unsignaled", -22), 3d (a run of 1 frame in 3.1 s, no
  triangle at 640,333), vktri; the repeat on the same build 204/204.
  Suspects: the concurrent ctxfree (Gpudrv.bg), flush_delayed_work's
  change, the irq ack. Logs: cache/stability/review/m8-gpu.log, m10-gpu.log.
- The VFIO guest's /tests lacks `drawcmp` and `workload`: amddraw.rc's
  drawcmp comparison and its workload part FAIL on the RX 7600
  (2026-11-19). drawcmp is built only by tests/draw/run.sh into its own
  root; vfio-test.sh copies tests/gpu's root and `amd*.rc` alone.
  Fix: build both into tests/gpu's root (build-vktest.sh), or let
  vfio-test.sh take tests/draw's root as well.
- Never run: eframetest on venus (L1266, L1354); firmware loaded from the
  CD (only its staging checked; L1762).
- A full gs rebuild under `build.exe -D`, seen twice, unexplained (L879).
- A `-D` run right after a clean build (tree 66e79df91, 2026-11-19)
  recompiled 145 files: the pc64 kernel's sources, libsec's generated
  `secp*.c`/`jacobian.c`, `gram.c`. The kernel's part fixed in tree
  c37206777 (kernelgen's Clean list was relative to the root, the tool
  reads it relative to the manifest; "a second -D now compiles nothing");
  libsec's and `gram.c` not named there: confirm with a clean build and two
  `-D` runs.
- The QEMU egl-headless SIGKILL workaround goes once the host's QEMU has
  baca2517 (L1416); the host still has 11.1.3 (2026-11-27).
- The script review's code findings (2026-11-20; the whole list: attic
  dist-docs/plans/scriptreview/FINDINGS.md; (a) and (b) fixed), the
  tree's part: (c) hardcodings: fixed in tree 030737e52 (2026-11-20) but
  for hw/pxe.sh's QMP helper taking an event for the reply.
  (d) small: rc scripts behind their .sh (gen-9syscall,
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

- VisionFive 2 (riscv64 `9vf`, riscv 3f1678b2e, hardware.md): boots with its root
  over the network. Next by `docs/visionfive2.md`: the SD card (sddwmmc) as root,
  clocks/resets/pins as a driver, PCIe, USB, HDMI. Test kernels:
  `sys/src/build/host/hw/vf2load.py` (TFTP, watchdog, one log `cache/hw/vf2.log`).
The inventory of 2026-11-19 (`hardware.md`: the X1, the ThinkBook, the
build host); what is missing on more than one machine or blocks one:

- The ThinkBook's APU: RADV finds no Vulkan device (`vkEnumeratePhysicalDevices`
  zero, no drm9 line with `DRM9DEBUG=3`; the loader or ICD stage first);
  its rtw89 stalls after two load rounds while associated (an A/B against
  the kernel before tree be974532b, counters for the block-ack window's
  old frames, then a window reset as net80211's reorder does); `wlan auto`
  at boot did not associate on the X1 (fixed: tree f97615f46, it waits
  up to $wlanwait for a known network; joined 21 s after start) and the
  ThinkBook (not retried).
- Bluetooth on all three (X1 8087:0a2a, ThinkBook, host 2357:0604 RTL8761B):
  9front has none. A project of its own: HCI over USB as an nusb driver
  with the firmware load, L2CAP/SDP, then HID, then audio; permissive
  templates only (FreeBSD's netgraph Bluetooth, NetBSD's stack; BlueZ is
  GPL).
- HDMI/DP audio: the X1 ("no audio codecs found") and the host's RX 7600
  (natively, 2026-11-27: its codec 1002:aa01 found on `#A1`, outpath pin
  11 "nothing", not tried; amdgpu's display audio not done).
- Internal disks: NVMe never read or written on real hardware (the
  machines' disks off limits by the user's rule); AHCI on the X1:
  sdiahci finds its Samsung PCIe AHCI SSD since tree 656607f9b (any
  vendor by class code), and the user installed 9space on its second SSD
  (2026-11-27). A QEMU NVMe test first (detect, partition, gefs and hjfs,
  load, the CD's install onto NVMe) before an install on an NVMe disk.
- The build host as a target (plan: attic `dist-docs/plans/host-b550.md`):
  booted natively from a stick with `*nonvme=1 *noahci=1` on 2026-11-27
  (the CD of main 8b2c2b55e, hardware.md): USB, Ethernet, pstate, the RX
  7600 (wsys -g, vkcube), the ALC897's rear out and the PCM2902 play. Left:
  the front headphone, the RX 7600's HDMI audio, Bluetooth (no driver).

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
- Mesa's shader cache (tree 785c8a0a1, 2026-11-27): its database in
  `$home/lib/mesa` is locked with flock, which is a stub twice (APE's
  `ap/gnu/flock.c` grants every lock, Mesa's `plan9compat.c` does nothing):
  ui programs starting at once (the desktop's) may write it together.
  Clean: a real flock in APE (an exclusive-use lock file, DMEXCL, per
  locked file), Mesa's stub gone. Measured on the X1 (2026-11-27, update
  0dbd9bc, hasvk on Broadwell): Mesa's cache stays empty (its database
  parts 2 KB, no shader written), cxxwidgets takes 16 s the first time and
  10.5 s after; ui alone (UITIME) ~3.9 s, of which the first frame 2.9-3.2 s
  each start (vello's pipelines), with ui's own wgpu pipeline cache read
  ($home/lib/ui/cache, 918 KB of 2026-11-23, accepted by the driver: not
  written again). Open: why hasvk compiles anyway (pipeline cache data not
  used for vello's compute pipelines? Mesa's disk cache not reached by
  hasvk?), and where cxxwidgets' other ~6.5 s go. The ui work is paused
  (the user, 2026-11-27).
