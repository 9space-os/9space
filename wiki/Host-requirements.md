# Host requirements

9space is built on a Linux host (x86-64). Tested on Arch Linux with the
versions below; other distributions work with their equivalents. All Python
scripts use the standard library only.

## Always

| Tool | For | Tested |
|---|---|---|
| gcc, g++ (with 32-bit multilib) | the tree (`ARCH=386` uses `gcc -m32`), the toolchains | gcc 16.2 |
| binutils (`objcopy`, `nm`, `readelf`, `ar`) | linking, the a.out conversion | 2.47 |
| make, bash, coreutils, sed, awk, tar, xz | build steps | |
| python3 | generators, build steps, tests | 3.14 |
| go | the build tool (`sys/src/cmd/build`) | go1.27 |
| git | the repositories, the source archives made repositories | |
| flock (util-linux) | one `build-all`/`build-toolchains` at a time | |
| curl, gpg, gpgv, sha256sum | `fetch.sh` of each toolchain, `dist/bin/fetch` | |
| [plan9port](https://github.com/9fans/plan9port) | rc, yacc and generators of the host build (`PLAN9PORT`, `tools/plan9port`) | |

Arch Linux:

```sh
pacman -S --needed base-devel lib32-glibc lib32-gcc-libs go python git curl gnupg xz util-linux   # lib32-*: the multilib repository
```

plan9port itself comes with the sources (`dist/bin/repos`, [[Building]] step 2):
`cd tools/plan9port && ./INSTALL` builds it; its `./INSTALL` needs only the
compiler and, for its graphical programs, the X11 headers (`libx11 libxt libxext
fontconfig freetype2` on Arch); the build of 9space uses none of those.

## Per architecture

| Tool | For |
|---|---|
| `riscv64-linux-gnu-gcc` (on `PATH`) | `ARCH=riscv64` (branch `riscv` only): the kernel's initcode and reboot code. Arch: `riscv64-linux-gnu-gcc` |
| `aarch64-linux-musl-gcc` (on `PATH`) | `ARCH=arm64`: the kernel's initcode and reboot code. Arch: AUR `aarch64-linux-musl-cross-bin`; elsewhere musl.cc's `aarch64-linux-musl-cross` |

## Toolchains

| Tool | For | Tested |
|---|---|---|
| (as "Always") | gcc and binutils for 9space (`toolchain/gcc`); GMP, MPFR, MPC come with `fetch.sh` | |
| cargo (rustup or the distribution's) | the tree's Rust programs with the stage-1 rustc (`scripts/build/cargo.sh`), cargo for 9space | 1.99 |
| cmake, ninja | LLVM for 9space (`toolchain/rust/scripts/build-llvm.sh`) | |
| network | Rust's bootstrap downloads its stage-0 compiler and LLVM; cargo the crates | |
| a Go ≥ 1.24.6 | bootstrapping Go for 9space (`GOROOT_BOOTSTRAP` or `go` on `PATH`) | go1.27 |

Arch Linux:

```sh
pacman -S --needed rustup cmake ninja && rustup default stable
```

## Guests: boot loaders, CD, tests

| Tool | For | Tested |
|---|---|---|
| qemu-system-x86_64, -i386, -aarch64, qemu-img; KVM | `scripts/guest/*` (boot loaders, CD), all guest tests | QEMU 11.1 |
| `ufs`: the tree's (`scripts/hw/ufs`, Harvey's ufs without TCP keepalive, its ninep vendored), built with the host's go into `$CLI_DIR/ufs` by `scripts/hw/ufs/build.sh` when missing or older than its sources: nothing to install | serves the guest's root from the host (`boot-cli.sh`, `pxe.sh`, `dist/bin/pxe`) | |
| grub (`grub-mkrescue`) | the guest's multiboot ISO (`boot-cli.sh`, amd64 and 386) | |
| rsync | the guest's root, kept between boots: only what differs is written (`gen-ufs-root.sh`) | |
| edk2 OVMF (where `OVMF_CODE` and `OVMF_VARS` of `dist/paths.env` say: `/usr/share/edk2/x64/OVMF_{CODE,VARS}.4m.fd` on Arch; another distribution changes them there) | UEFI boots (`UEFI=1`, `tests/iso`, `pxe.sh QEMU=1`) | |
| mtools (`mcopy`, `mformat`) | FAT images for guests | |
| e2fsprogs (`mkfs.ext4`, `debugfs`) | self-hosting build, toolchain tests in the guest | |
| ImageMagick (`convert`) | disk images (`mkdisk.sh`) | |
| xorriso | checking the CD (`check-install.py`) | |

Arch Linux:

```sh
pacman -S --needed qemu-full edk2-ovmf mtools e2fsprogs imagemagick libisoburn grub rsync
```

## Real machines by PXE

A test machine whose disks stay untouched boots from the host
(`tree/tests/hw/README.md`, "A machine booted by PXE"):
`tree/scripts/hw/pxe.sh mac [machine]` makes the root, the TFTP directory and
dnsmasq's conf once (and after each refresh of the root); after that, and
after every reboot of the host, `dist/bin/pxe` starts the services in the
background: `dist/bin/pxe` (start: dnsmasq by sudo, then ufs serving
`$CLI_DIR/pxe/ufsroot` on port 5650), `dist/bin/pxe status`,
`dist/bin/pxe stop`. Logs in `$CLI_DIR/pxe` (`dnsmasq.log`, `ufs.log`).

| Tool | For | Tested |
|---|---|---|
| dnsmasq newer than 2.93 (2.93 sends a stale TFTP block to 9bootpxe, a BIOS machine's loader: "bad magic"; fixed upstream in `cdbfb97`), e.g. built from its git in `$CACHE/dnsmasq` (`make`; `dist/bin/pxe` takes `$CACHE/dnsmasq/src/dnsmasq` first, `DNSMASQ=` another) | proxy DHCP and TFTP for the machine | 2.93-44 |
| sudo | dnsmasq's ports 67, 69, 4011 | |

## Checks (`tests/static`)

| Requirement | For |
|---|---|
| Linux 7.3.1 and 6.6 sources from kernel.org, unpacked as `../linux-7.3.1` and `../linux-6.6` beside `~/Devel/9space` (`LINUX`, `LINUX_OLD` in `dist/paths.env`) | the LinuxKPI's GPL check and its manifests (they fail without them and say what is missing) |

## GPU tests (`tests/gpu`)

| Requirement | For |
|---|---|
| a host GPU with Vulkan and `/dev/dri/renderD128`; QEMU with virglrenderer (venus) | virtio-gpu-gl: Vulkan, GL, wsys on the GPU |
| optional: IOMMU, a second GPU or single-GPU VFIO, `sudo` | real-hardware tests with the card in the guest (`scripts/guest/vfio-gpu.sh`) |

## Only for re-vendoring other projects' sources

Not needed to build; only to bring a new release of Mesa, Wayland, fontconfig
and the like into the tree:

| Tool | For |
|---|---|
| meson, ninja, pkg-config | Mesa (`scripts/mesa/build.sh`) |
| wayland-scanner | protocol code (wayland, weston, foot) |
| gperf | fontconfig's generated headers |
| glslc, spirv-val | wsys' shaders (`.spv` files are checked in) |
| rsync | `scripts/rust/crates.sh` (the tree's copy of the patched crates) |
