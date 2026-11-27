# Features

State of `main`, November 2026. "QEMU" means tested in `sys/src/build/host/tests/` under QEMU,
"hardware" on a real machine.

## System

| Feature | Status |
|---|---|
| 9front built with gcc: amd64, 386, arm64 | QEMU, hardware (amd64) |
| riscv64 (branch `riscv`) | QEMU |
| NIX application cores (branch `nix`) | QEMU |
| Self-hosting: the tree builds itself on 9space with the native gcc or clang | QEMU (`sys/src/build/host/guest/build-self.sh`) |
| APE with C99/C11, POSIX.1-2008, pthreads, ptys, eventfd, memfd | QEMU |
| Install/live CD, hybrid BIOS/UEFI/USB | QEMU, hardware |
| Installation profiles: `minimal`, `gpu`, `ui`, `full`, gcc/Rust/Go and the MCP server as options of each (`dist/bin/mkcd`) | QEMU: all four boot; `full` CD and USB, BIOS and UEFI, rio, USB, gcc, Go, Rust tests |
| Updates over HTTP: `pull(1)` (replica/pull through `replica/httpfs`: a signed index, each file checked by SHA-256; a gefs snapshot first, the way back), published by every `mkcd` | QEMU (`sys/src/build/host/tests/replica`); no server yet, the CDs ask a placeholder URL (GitHub) |
| gefs, the installer's default file system, built with gcc | QEMU (`sys/src/build/host/tests/replica`: ream, snapshots) |

## Toolchains on 9space

| Toolchain | Targets | Notes |
|---|---|---|
| gcc 16.2, binutils 2.47 | amd64, 386, arm64, riscv64 | C, C++ (libstdc++); `gccmk` runs Plan 9 mkfiles with gcc |
| Rust | x86_64, i686, aarch64 (`*-unknown-plan9`); riscv64 cross only | std, cargo, rustdoc, rustfmt, clippy; cargo fetches from crates.io (the CD's CA roots) |
| Go 1.27.3 | plan9/amd64, 386, arm64 (arm64 new) | cgo with the native gcc; modules from the proxy over https |

## Graphics

| Feature | Status |
|---|---|
| gpu(4): drivers as user-space file servers (`/shr/gpu/N`) | QEMU, hardware |
| virtio-gpu with venus (Vulkan of the host) | QEMU |
| AMD amdgpu (Linux 7.3 DRM on the LinuxKPI), Mesa RADV | hardware: RX 7600 (VFIO) |
| Intel i915 (Linux 7.3 DRM on the LinuxKPI), Mesa hasvk | hardware: HD 5500 (X1 Carbon 3rd, the desktop on the GPU) |
| Vulkan 1.4 (`VK_PLAN9_surface`), OpenGL 4.6 / GLES 3.2 via zink, EGL | QEMU, hardware |
| Direct scanout, overlay planes | QEMU, hardware |

## Desktop

| Feature | Status |
|---|---|
| **wsys**: window system in Rust; composes on the GPU (or the processor); the desktop of the profiles `ui` and `full` (`desktop=rio` chooses rio) | QEMU, hardware |
| draw(3) programs and rio in wsys (rio(4) files) | QEMU |
| HiDPI (scale from `/dev/dpi`), themes (9space's, light and dark: [[Desktop]]), `wbar` | QEMU |
| **ui**: widgets described through files (`ui(4)`), drawn by vello on wgpu or vello_cpu | QEMU |
| Wayland clients via `wlsys` (foot terminal, weston examples) | QEMU |
| SDL3, GLFW, winit, egui/eframe, iced | QEMU |
| **Browser**: Servo (nightly 2026-11-19) with SpiderMonkey's JIT, WebRender on zink; `webfs-rs` for its requests; `browser [url]` (browser(1)); on the CD with `dist/bin/mkcd -browser` (ui, full) | QEMU: six real sites (Wikipedia, tagesschau, heise, GitHub, MDN) load, input; hardware: X1 (an earlier build) |

## Tools

| Feature | Example |
|---|---|
| MCP server: an agent on Linux works on 9space | on the CD: `dist/bin/mkcd -mcp PROFILE`; by hand: `GOOS=plan9 GOARCH=amd64 go build -o 9front-mcp .` in `tools/mcp` |
| Guest control for debugging | `sys/src/build/host/debug/qemu-ctl.py DIR shot` |
| Test suites | `sys/src/build/host/tests/static`, `sys/src/build/host/tests/gpu`, `sys/src/build/host/tests/guest`, … (`sys/src/build/host/tests/README.md`) |
