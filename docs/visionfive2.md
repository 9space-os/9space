# VisionFive 2: the full port

Goal: 9space on the StarFive VisionFive 2 (v1.3b, JH7110, 8 GB) as a complete
system — booted from its SD card, root on the card or over the network, the
desktop (wsys, ui) on HDMI with a USB keyboard and mouse. Kernel `9vf`,
branch `riscv`, worktree `tree-riscv` (debug kernels in `tree-vf`).

Rules for the board: the SD card is ours to write (U-Boot `fatwrite mmc 1:3`,
or on the host); the NVMe SSD (a Debian) is off limits — no writes, no tests on
it. Sources for drivers: the BSDs first (NetBSD `sys/arch/riscv/starfive`,
OpenBSD `sys/arch/riscv64/dev/stf*`, FreeBSD `sys/riscv/starfive`); Linux and
U-Boot are GPL and only read for facts (register meanings), never copied.

## How a kernel is tested

`sys/src/build/host/hw/vf2load.py` (branch `riscv`) stops U-Boot at its countdown over the serial line
(CH340 on the B550 host, `/dev/serial/by-id/usb-1a86_USB2.0-Ser_-if00-port0`),
fetches the kernel by TFTP from the host (dnsmasq, root `cache/hw/tftp`), arms
the JH7110 watchdog (`WDT=seconds`: the board resets itself, so no power
cycle is needed), boots it and logs to `cache/hw/vf2.log`.

## State (2026-11-28)

| Part | State |
|---|---|
| boot (SBI, Sv39, 4 harts; the S7 left out), 8 GB (`fdt memory` in boot2) | works |
| uart0 console, in and out (DesignWare busy detect; U-Boot's Linux `bootargs` cleared) | works |
| PLIC, timer | works |
| reboot, reset after a panic (the JH7110 watchdog: OpenSBI's reset does nothing) | works |
| Ethernet ×2 (`etherdwmac.c`, YT8531): clocks and resets on, MACs from the device tree | works: ETH1 1000 Mbps, DHCP |
| root over the network (host: `gen-ufs-root.sh` for riscv64 and ufs; `vf2load.py INI=`) | works: init, termrc, rc |
| SD card, eMMC (`sddwmmc.c`) | written, untested |
| no RTC: timesync wants `/dev/rtc`; no `#i`, `#m` (display) | open |

## Order

Each step ends with a test on the board and a commit on `riscv`.

1. **Network** (done 2026-11-28). MAC addresses from the device tree (`local-mac-address`, which
   U-Boot fills from its `ethaddr`/`eth1addr` at `bootm`); packets in and out;
   DHCP (ip/ipconfig); root over the network from the host (ufs/9P, as
   `dist/bin/pxe` serves the PCs). Gives a full 9space userland on the board
   early, before any local disk.
2. **Reset** (done 2026-11-28). `reboot` and a panic reset the board: SBI's system reset if it
   works, else the JH7110 watchdog (NetBSD `jh7110_wdt.c`).
3. **SD card.** `sddwmmc.c` on the card (read, write on partition 4 only),
   then a 9front file system there (gefs or hjfs) as the local root; the
   card's layout made by `mksd-vf.sh` (p1/p2 StarFive's, p3 FAT boot, p4 the
   root).
4. **Clocks, resets, pins** (syscrg, aoncrg, stgcrg; sys/aon iomux): a small
   driver for what the next steps need, instead of relying on U-Boot's state
   (NetBSD `jh7110_clkc.c`, `jh7110_pinctrl.c`).
5. **PCIe** (PLDA XpressRICH, two ports; NetBSD `jh7110_pcie.c`,
   `jh7110_pciephy.c`, OpenBSD `stfpcie.c`): port 0 carries the VL805 USB 3
   controller, port 1 the M.2 slot (the SSD: only enumerated, never written).
6. **USB.** xHCI on the VL805 (9front's `usbxhci`) for keyboard, mouse,
   sticks; then the SoC's own USB 2.0 (Cadence, NetBSD `jh71x0_usb.c`).
7. **Display.** HDMI: the DC8200 display controller and the Innosilicon HDMI
   transmitter, a frame buffer for devdraw (software rendering; the IMG BXE
   GPU is out of reach). Then wsys and ui as on the other machines.
8. **The rest.** I2C and the AXP15060 PMIC (power off, CPU voltage), GPIO,
   temperature sensor (`jh71x0_temp.c`), random number generator
   (`jh7110_trng.c`) for /dev/random, CPU frequency. No RTC on the board: time
   from the network (timesync).
9. **Distribution.** A riscv64 9space image for the card (`mksd-vf.sh` makes
   the whole card), the wiki page for the board, `check` stages for it.
