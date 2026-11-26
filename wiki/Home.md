# 9space

9space (working name) is a distribution built on [9front](https://9front.org):

- 9front built with **gcc** on Linux (amd64, 386, arm64; riscv64 as a port)
- a **GPU stack**: gpu(4), Linux's DRM drivers on a LinuxKPI, Mesa (Vulkan, OpenGL)
- **wsys**, a GPU-composing window system, and **ui**, a declarative UI framework served as files
- toolchains for 9space: **gcc**, **Rust**, **Go**

All of it lives in one directory, `~/Devel/9space`; each part is a git repository.

| Page | What |
|---|---|
| [[Repositories]] | the git repositories and what each holds |
| [[Branches]] | branches and how they stack |
| [[Host-requirements]] | what the Linux host needs |
| [[Building]] | from a Linux host to an install CD, step by step; the installation profiles |
| [[Building by hand\|Building-by-hand]] | for experts: the single steps of the build scripts, as commands to type |
| [[Testing]] | `dist/bin/check`: the built system and its CD tested, with gcc, kencc and gccmk |
| [[Releasing]] | from a working checkout to a release: 9front's newest, the CA roots, tests, pin, CDs, the replica |
| [Using gcc, Rust, Go and clang](Toolchains) | the toolchains on 9space and from Linux; rebuilding the system with gcc |
| [[Features]] | what works today, and where |

Licences: 9space's tree holds only permissive code (MIT, BSD, ISC, zlib,
public domain); firmware is kept as separate files. A check
(`sys/src/build/linux/provenance.py`, part of `sys/src/build/host/tests/static`) keeps GPL text of
Linux out of the LinuxKPI.
