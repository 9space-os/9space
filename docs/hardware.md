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
| Lenovo ThinkPad X1 Carbon 3rd (20BT, 2015: i7-5600U Broadwell, 8 GB) | boot, amd64 CD | tested | 2026-11-11 | CD and USB stick up to rio; `tests/hw` stick runs (disk read-only, usb, net listing, clock) |
| | boot by PXE (`scripts/hw/pxe.sh mac x1carbon2015`), root from the host | works | 2026-11-18 | `*noahci=1 *nonvme=1`: the internal SSD is never touched; 4 processors, `cputemp`, ACPI (`aux/acpi`: battery, AC, backlight), the MCP server reached over the network |
| | GPU: Intel HD 5500 (i915) | tested | 2026-11-11 | `aux/i915`, eDP 1920×1080, Vulkan through hasvk (vulkaninfo, vktri, vkcube ~71 fps); laptop runs 9 and 10 of the desktop green (`deskrun`, `comprun`, `wlrun`, overlay plane); RC6 and RPS (300–950 MHz) |
| | desktop (`desktop=wsys`) | tested | 2026-11-11 | wsys on i915, wbar, title bars, Mod4+Tab, Wayland (foot) |
| | backlight | tested | 2026-11-04 | `gpuoutputs` (eDP-1 to 30 % and back); `/dev/backlight` by `aux/acpi` as well |
| | Ethernet: I218-LM (through Lenovo's adapter) | works | 2026-11-18 | 1000 Mbps; PXE and the 9P root |
| | WLAN: Intel Wireless 7265 (`etheriwl`) | works | 2026-11-18 | WPA2 (CCMP) associated; legacy rates only (54 Mbps), no HT/VHT although the access point offers them; firmware `iwm-7265-17` (the machine file's `firmware` line) |
| | xHCI | works | 2026-11-18 | USB 2 root hub (11 ports), USB 3 root hub (4 ports); the test stick boots and is read from it (2026-11-01) |
| | camera: Integrated Camera 04ca:7049 (UVC, `nusb/cam`) | works | 2026-11-18 | frames at 640×480 and 1280×720 (YUY2); `ctl` settings take effect (brightness, gamma); `format WxHxBPP-FOURCC` failed before `patch-upstream` 0046 |
| | audio: HDA, Realtek ALC292 | untested | | codec found: speaker, headphone jack, internal mic; nothing played yet; `waitup timeout` messages at the controller's reset |
| | audio over HDMI/DP (Broadwell HDA, `#A1`) | fails | 2026-11-18 | "no audio codecs found" |
| | keyboard, TrackPoint (PS/2) | works | 2026-11-11 | the desktop runs; the touchpad (PS/2, no gestures) not checked |
| | external monitor | untested | | DP-1/2 and HDMI-A-1/2 are listed (disconnected) |
| | Bluetooth (Intel 8087:0a2a), processor clock (P-states, turbo), suspend | missing | | Bluetooth listed on USB, no driver; the clock stays at 2594 MHz; fingerprint reader not on the bus |
| Lenovo ThinkBook 16 G7 ARP (Ryzen 7 7735HS, 32 GB) | boot by PXE (`scripts/hw/pxe.sh`), root from the host | tested | 2026-11-14 | `*nonvme=1`: the internal NVMe (another system) is never touched; 16 processors, ACPI (battery), RTL8168 Ethernet, xHCI (USB devices listed), i8042 keyboard, HDA |
| | GPU: Radeon 680M (Rembrandt, YELLOW_CARP) | tested | 2026-11-14 | `aux/amdgpu` as the screen, eDP 1920×1200, the display's cursor; the APU's 4 GB of video memory through `gpu(3)`'s `vram`; taking over from VESA with the desktop running |
| | desktop (`desktop=wsys`) | tested | 2026-11-14 | wsys on amdgpu, wbar |
| | touchpad (I2C-HID), WLAN (RTL8852CE), card reader, camera, fingerprint, internal mic | missing | | no driver; PS/2 aux disabled by the firmware |
| HP Mini 2140 (Atom N270, 945GSE, UHCI+EHCI) | boot, 386 CD | fails | 2026-10-14 | the boot stops (not looked at since; 386 comes later) |
| AMD Radeon RX 7600 XT (Navi 33) | GPU, by VFIO in a QEMU guest | tested | 2026-11-12 | `amdall.rc`: `aux/amdgpu`, RADV (Vulkan), wsys composing on the GPU, overlay plane, eframe/egui on wgpu, SDL3 on Vulkan, ui on vello/wgpu |
| | second monitor | untested | | |

## QEMU (the test suites)

| Device | Level | Suite |
|---|---|---|
| amd64, 386, arm64 (virt, GICv3) guests | tested | `tests/run.sh boot guest` (amd64 all green; 386: APE shared memory cannot grow, arm64: no segment(3), see `tree/MEMORY.md`) |
| VESA (`aux/realemu`) | tested | amd64: `gui`, `ui`, `draw`, `sdl`, `glfw`, `winit`, `uiserver`, `wayland`; 386: `ui` (2026-11-11, before `-O2`) |
| virtio-gpu 2D (`aux/virtiogpu`) | tested | `gpu` (mode switch, drawing, interrupts) |
| virtio-gpu-gl with virgl and venus (Vulkan, GL by zink) | tested | `gpu` (139 checks), `wayland` |
| install CD: BIOS and UEFI, as CD and as USB stick | tested | `iso` (all four profiles) |
| USB: xHCI, EHCI, UHCI (a stick) | tested | `usb` |
| USB: OHCI | fails | `usb` with `USB_CTLRS=ohci`; fails with 9front's own release too |
| e1000, virtio-net | tested | every guest boot (9P root over the network) |
| IDE disk (QEMU's default) | tested | `iso` (booted as a disk); `disk` (the hjfs install image) last before `-O2` |

## How to add a row

Run the CD (or `tests/hw`'s stick) on the machine, then put the machine,
the part, the level, the date and what ran into the table; a failure
gets what failed. The suites' names are in `tree/tests/README.md`.
