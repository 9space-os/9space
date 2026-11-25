# Hardware matrix

What 9space has run on, and how far. The roadmap's 1.0 asks for this table
published, with VESA as the guarantee: the aim is that every machine with
a VESA BIOS or UEFI GOP gets rio and the desktop (wsys composing on the
processor), with or without a GPU driver; the rows below say where that
was seen.

Levels:

- **tested**: a test suite ran on it and passed (named in the row).
- **works**: used by hand and seen working; no suite, or only part of one.
- **fails**: tried, does not work (what fails is said).
- **untested**: expected to work (a driver is there), never run.
- **missing**: no driver.

Runs on real hardware dated before 2026-11-13 predate the userland's
switch to `-O2`; QEMU's rows are from the suites after it, where not said
otherwise.

## Machines

| Machine | Part | Level | Last run | Notes |
|---|---|---|---|---|
| Lenovo ThinkPad X1 Carbon 3rd (20BT, 2015: i7-5600U Broadwell, 8 GB) | boot, amd64 CD | tested | 2026-11-11 | CD and USB stick up to rio; `sys/src/build/host/tests/hw` stick runs (disk read-only, usb, net listing, clock); **no longer a test machine since 2026-11-20** (the user: installed from the CD 9space-full-mcp.amd64.iso, tree ac44f4f5b); its rows are its last state (last runs 2026-11-20) |
| | boot by PXE (`sys/src/build/host/hw/pxe.sh mac x1carbon2015`), root from the host | works | 2026-11-18 | `*noahci=1 *nonvme=1`: the internal SSD is never touched; 4 processors, `cputemp`, ACPI (`aux/acpi`: battery, AC, backlight), the MCP server reached over the network |
| | GPU: Intel HD 5500 (i915) | tested | 2026-11-11 | `aux/i915`, eDP 1920×1080, Vulkan through hasvk (vulkaninfo, vktri, vkcube ~71 fps); laptop runs 9 and 10 of the desktop green (`deskrun`, `comprun`, `wlrun`, overlay plane); RC6 and RPS (300–950 MHz); the screen in two objects ("screen 1920x1080 double", tree 31be0d5ed; 2026-11-19); the GPU path (wsys -g) clean: a stripe paced to the display (4 px a frame) "passes cleanly" (the user's eye), a flip a vblank (60/s); the processor path (devdraw's screen without wsys) tore until tree a1058f9b5 (it swapped without a flip); since then tearing fixed on both paths: the paced stripe "passes cleanly" on devdraw's screen too (the user's eye; slight judder from the test's 16 ms against the 16.7 ms vblank), flips and commits rise together, "not on the display after 0"; the frames' order (sys/src/build/host/tests/gpu's wsysorder.rc as the top-level wsys, tree 785af7950, 2026-11-20): never an older frame, -O and plain, 3 runs each without WSYSDEBUG (an earlier "back to 119" was the test's: it read the desktop's #777777 after vktri's window had closed), glage's buffer age right; aux/i915 restarted under wsys -g (overlay plane in use, vktri, uiwidgets, a text window): wsys goes on, "the GPU composes no longer", then "composes again", the windows kept; a Vulkan client gets VK_ERROR_DEVICE_LOST (the driver's segments "lost", segment(3), tree 3dd6bba4a; 2026-11-20) |
| | desktop (`desktop=wsys`) | tested | 2026-11-11 | wsys on i915, wbar, title bars, Mod4+Tab, Wayland (foot) |
| | backlight | tested | 2026-11-04 | `gpuoutputs` (eDP-1 to 30 % and back); `/dev/backlight` by `aux/acpi` as well |
| | Ethernet: I218-LM (through Lenovo's adapter) | works | 2026-11-18 | 1000 Mbps; PXE and the 9P root |
| | WLAN: Intel Wireless 7265D (`etheriwl`) | works | 2026-11-18 | WPA2 (CCMP) with WMM; 802.11n: HT MCS 15 with two streams (AMRR), aggregates both ways (A-MPDU, block ack); 2.4 and 5 GHz (DFS channels by listening); the strongest node of a mesh by signal, roaming below -75 dBm by a background scan of the firmware (the link stays, a node 8 dB stronger is joined); ~65-77 Mbit/s sent, ~40-45 received, ping ~2 ms; firmware `iwm-7265D-29` (the machine file's `firmware` lines); `wlan` lists and joins networks, `wlan auto` at boot (2026-11-18; since 2026-11-19 it does not associate at boot, by hand it does); the soak's 50 MB transfers hold (9 of 9 rounds, 2026-11-19, after the block-ack reorder moved out of the interrupt, tree be974532b) |
| | xHCI | works | 2026-11-18 | USB 2 root hub (11 ports), USB 3 root hub (4 ports); the test stick boots and is read from it (2026-11-01) |
| | camera: Integrated Camera 04ca:7049 (UVC, `nusb/cam`) | works | 2026-11-18 | frames at 640×480 and 1280×720 (YUY2); `ctl` settings take effect (brightness, gamma); `format WxHxBPP-FOURCC` failed before `patch-upstream` 0046 |
| | audio: HDA, Realtek ALC292 | works | 2026-11-18 | speaker (pin 20) and headphones (pin 21): the output follows the jack (`jack auto`), heard by the user in both; internal mic; `waitup timeout` messages at the controller's reset |
| | audio over HDMI/DP (Broadwell HDA, `#A1`) | fails | 2026-11-18 | "no audio codecs found" |
| | keyboard, touchpad, TrackPoint (PS/2) | works | 2026-11-18 | `mouseport=synaptic` (9space's driver: Synaptics clickpad, firmware 8.1): one finger moves, two scroll, clicks and taps with one, two, three fingers are buttons 1, 3, 2, menus dragged; the TrackPoint and its three buttons through the pad, middle-button scrolling (`midscroll=on`); all checked by the user. Volume keys: not handled yet (wsys has no kbdtap) |
| | lid, battery | works | 2026-11-18 | lid closed: panel dark, clock `low`; open: both back (`aux/acpikeys`, the events fed by hand); `batteryguard`: a window and `fshalt` at 5 % without AC (the window seen, the halt only on the host); wbar `bat N%+`/`low`; charge limits 60/80 kept by the EC (`/dev/battery`) |
| | external monitor (HDMI, 1080p) | works | 2026-11-19 | plugged in and out under wsys on the GPU: the layout changes (kmsout takes the client's image off the display, the framebuffer grows with it), windows move to the remaining monitor, a scale per monitor from its EDID (X1 1.5, a 27" monitor 1.0); once seen by the user: the second monitor black (pointer visible) after a replug or a login, not reproduced; `sys/src/build/host/tests/hw/cat/extmon.rc` for the round |
| | processor clock: `aux/pstate`, `intel-eist` | works | 2026-11-20 | idle at the lowest ratio (~750 MHz; package 2.28 W instead of 2.81 W), busy at turbo (3.09 GHz); policies auto, high, low; started only when plan9.ini sets `pstate=`, the deeper idle states only with `*cstates=`; `aux/power` (RAPL, residencies) reads each processor on that processor (tree 2328f9717): idle pkg 2.55 W (without `pstate=`), cores 0.2 W, dram 0.8 W, no package C-state without `*cstates=` (2026-11-20); on by default since 2026-11-20: `pstate=auto` in its machine file (`sys/src/build/host/tests/hw/machines/x1carbon2015`): idle ~680 MHz, package 2.28 W instead of 2.55 W; `*cstates=` still off |
| | Bluetooth (Intel 8087:0a2a), suspend | missing | | Bluetooth listed on USB, no driver; fingerprint reader not on the bus |
| Lenovo ThinkBook 16 G7 ARP (Ryzen 7 7735HS, 32 GB) | boot by PXE (`sys/src/build/host/hw/pxe.sh`), root from the host | tested | 2026-11-14 | `*nonvme=1`: the internal NVMe (another system) is never touched; Secure Boot off in the firmware's setup (9boot's `bootx64.efi` is not signed: with it on, neither PXE nor the stick boots; 2026-11-19); beside the X1 with a root of its own (`PXE_DIR=$CLI_DIR/pxe-thinkbook UFS_PORT=5651`); 16 processors, ACPI (battery), RTL8168 Ethernet, xHCI (USB devices listed), i8042 keyboard, HDA; **no longer a test machine since 2026-11-20** (the user); its rows are its last state (last runs 2026-11-20); amdgpu on a re-probe (the PSP) is tested on the RX 7600 by VFIO from now on |
| | GPU: Radeon 680M (Rembrandt, YELLOW_CARP) | tested | 2026-11-14 | `aux/amdgpu` as the screen, eDP 1920×1200, the display's cursor; the APU's 4 GB of video memory through `gpu(3)`'s `vram`; taking over from VESA with the desktop running; RADV finds the APU (RADV REMBRANDT) with the drm9 of 2520c6386 (vkcube in 20 soak rounds, 2026-11-19); the screen in two objects ("screen 1920x1200 double"); the GPU path (wsys -g) clean: the paced stripe "passes cleanly" (the user's eye), a flip a vblank (60/s); the processor path swapped without a flip (63996 flips against 6046 commits) until tree a1058f9b5; since then tearing fixed on both paths: the paced stripe on devdraw's screen "passes cleanly", flips +163 and commits +163 in 10 s, "not on the display after 0" |
| | Vulkan (RADV) on the APU | tested | 2026-11-20 | RADV finds the APU (RADV REMBRANDT) through `/shr/gpu/0` since the drm9 of 2520c6386: vkcube in 20 soak rounds (2026-11-19), vktri and ui in windows of wsys -g; aux/amdgpu killed (amdlost, 2026-11-20): the clients get VK_ERROR_DEVICE_LOST and go on, but the restarted driver fails its probe (the PSP: "psp reg (0x16080) wait timed out"), so no way back to the GPU without a reboot yet (open.md) |
| | desktop (`desktop=wsys`) | tested | 2026-11-14 | wsys on amdgpu, wbar |
| | touchpad (ELAN 04f3:327e, I2C-HID, PTP) | works | 2026-11-15 | `aux/i2chid` over 9space's GPIO and I2C drivers; still open: tap-and-drag, horizontal scrolling |
| | WLAN: Realtek RTL8852CE (`aux/rtw89`) | works | 2026-11-15 | FreeBSD's rtw89 on the LinuxKPI; WPA2, WMM, HT 20/40 MHz, A-MPDU: ~47-57 Mbit/s sent, ~40 received on 5 GHz; 2026-11-19: 167-221 Mbit/s in the soak's transfers, then no data after two rounds while still associated (a stall, under investigation); `wlan auto` at boot does not associate; open: VHT/HE, 6 GHz, MSI |
| | card reader (Realtek RTS522A, `rtsx`), camera (30c9:00c2), sound (ALC257) | works | 2026-11-15 | an SD card with its partitions (`#S/sdM0`); the camera's RGB function through `nusb/cam` (the infrared one stays black: its emitter needs a vendor extension unit); a tone from the speakers |
| | fingerprint (Goodix 27c6), internal mic (ACP), Bluetooth, power button | missing | | no driver; the power button comes over the AMD GPIO controller and gave no event |
| | processor clock: `aux/pstate` (CPPC or AMD P-states) | works | 2026-11-20 | method amd-cppc (the firmware turns CPPC on); policy auto: idle ~1.7 GHz, pkg 3.05 W (without `pstate=` 3.2 W), busy 4.2 GHz; high: idle 3.1 GHz, 4.4 W; low: 398 MHz, idle 3.6 W, busy 5.6 W; low idles above auto without `*cstates=`; under load the package falls from ~59 to ~53 W within 10 s, the firmware's power limit; on by default since 2026-11-20: `pstate=auto` in its machine file (`sys/src/build/host/tests/hw/machines/thinkbook16g7`), idle package 2.97 W instead of 3.05 W, `*cstates=` still off; `aux/power` read-only: idle pkg 3.2 W, cores 0.7 W (tree 2328f9717; was "cores 52366 W" before the fix) |
| HP Mini 2140 (Atom N270, 945GSE, UHCI+EHCI) | boot, 386 CD | fails | 2026-10-14 | the boot stops (not looked at since; 386 comes later) |
| Desktop: ASUS PRIME B550-PLUS, Ryzen 5 5600XT (Zen 3), 32 GB, UEFI (the build host) | boot, native | untested | | inventory 2026-11-19 (plan: attic `dist-docs/plans/host-b550.md`); its NVMe (Crucial P310) and SATA disk (Samsung 870 QVO) hold the host's Linux: a native boot only with `*nonvme=1 *noahci=1`; the devices are tried by VFIO in a guest first, the host keeps running; `cputemp` knows family 0x19 |
| | GPU: Radeon RX 7600 XT (Navi 33, 1002:7480), by VFIO in a QEMU guest | tested | 2026-11-12 | `amdall.rc`: `aux/amdgpu`, RADV (Vulkan), wsys composing on the GPU, overlay plane, eframe/egui on wgpu, SDL3 on Vulkan, ui on vello/wgpu; as the host's own screen (native) never |
| | second monitor | untested | | |
| | HDMI/DP audio (1002:ab30) | missing | | `audiohda` does not know the function; amdgpu's display audio is not done |
| | HDA (1022:1487), codec Realtek ALC897 | untested | | `audiohda` knows the controller |
| | USB audio: TI PCM2902 (08bb:2902, UAC1) | untested | | `nusb/audio` |
| | Ethernet: RTL8168H (10ec:8168 rev 15) | untested | | `ether8169` knows the MAC version (Macv45) |
| | xHCI (1022:43ee, 1022:149c), USB keyboard and mouse | untested | | `usbxhci`, `nusb/kb` |
| | Bluetooth: TP-Link USB adapter (2357:0604, RTL8761B) | missing | | 9front has no Bluetooth |

## QEMU (the test suites)

| Device | Level | Suite |
|---|---|---|
| amd64, 386, arm64 (virt, GICv3) guests | tested | `sys/src/build/host/tests/run.sh boot guest` (amd64 all green; 386: APE shared memory cannot grow, arm64: no segment(3), see `tree/sys/src/build/host/MEMORY.md`) |
| VESA (`aux/realemu`) | tested | amd64: `gui`, `ui`, `draw`, `sdl`, `glfw`, `winit`, `uiserver`, `wayland`; 386: `ui` (2026-11-11, before `-O2`) |
| virtio-gpu 2D (`aux/virtiogpu`) | tested | `gpu` (mode switch, drawing, interrupts) |
| virtio-gpu-gl with virgl and venus (Vulkan, GL by zink) | tested | `gpu` (139 checks), `wayland` |
| install CD: BIOS and UEFI, as CD and as USB stick | tested | `iso` (all four profiles) |
| USB: xHCI, EHCI, UHCI (a stick) | tested | `usb` |
| USB: OHCI | fails | `usb` with `USB_CTLRS=ohci`; fails with 9front's own release too |
| e1000, virtio-net | tested | every guest boot (9P root over the network) |
| IDE disk (QEMU's default) | tested | `iso` (booted as a disk); `disk` (the hjfs install image) last before `-O2` |

## How to add a row

Run the CD (or `sys/src/build/host/tests/hw`'s stick) on the machine, then put the machine,
the part, the level, the date and what ran into the table; a failure
gets what failed. The suites' names are in `tree/sys/src/build/host/tests/README.md`.
