# Making a release

A release of 9space is one pinned state of all its parts (`manifest.json` in
the `dist` repository) that builds and passes its tests. **No CDs are published
for now**: whoever wants 9space checks out the release and makes the CD of the
profile they want with `dist/bin/mkcd` ([[Building]]). This page goes from a
working checkout to that state; [[Building]] has the steps it builds on
(toolchains, tree, CDs), and the roadmap (`docs/roadmap.md`) the releases
planned (0.1-preview, 0.9-beta, 1.0).

All commands run in `~/Devel/9space`. Builds and guests one at a time: two
builds never in one tree, and no other load while a suite boots guests.

## 1. 9front's newest

Bring in 9front's `front` and merge it through the tree's branches, as
`docs/upstream.md` describes (`front` → `gcc` → `main`, `nix`, `riscv`;
`upstream` rebased; patches 9front has taken to `sys/src/build/host/patch-upstream/archive/`). Each branch is built
and tested before the next merge.

## 2. The other parts up to date

```sh
dist/bin/repos           # fast-forwards every part that is clean and on its branch
dist/bin/status          # each part against manifest.json
```

Then rebuild what changed (the table in [[Building]], "Later: updating"), or
everything from scratch with `dist/bin/build-toolchains`, then the tree with
`dist/bin/build-profile full amd64 386 arm64`.

## 3. The CA roots

The CDs with Rust or Go carry Mozilla's CA roots as `/sys/lib/tls/ca.pem`, a
fixed file: installed systems get no other until they pull a newer one. Before
each release, raise it to curl's newest:

```sh
dist/bin/cacert -n       # is there a newer cacert-DATE.pem?
dist/bin/cacert          # fetch it (checked by its sha256), into distfiles/ and distfiles.list
git -C dist commit -m 'distfiles: cacert-DATE.pem' distfiles.list
```

## 4. Build and test

```sh
dist/bin/build-all amd64 386 arm64
cd tree
bash sys/src/build/host/tests/static/run.sh
bash sys/src/build/host/tests/run.sh                      # every category, amd64
objtype=386 bash sys/src/build/host/tests/run.sh          # and the other architectures
objtype=arm64 bash sys/src/build/host/tests/run.sh
bash sys/src/build/host/tests/gpu/run.sh                  # ~1 h, needs a host GPU
cd ..
```

The branches `nix` and `riscv` are built and tested in their worktrees
(`dist/bin/repos --worktrees=nix,riscv tree`; riscv64:
[[Building]], "Not in build-toolchains"). A test that fails once and passes
again is not done: its cause goes into `tree/sys/src/build/host/MEMORY.md` (`sys/src/build/host/guest/boot-cli.sh`
keeps a boot that never reached its prompt in `cache/cli/noprompt.TIME`).

Real hardware: run the CD (or `tree/sys/src/build/host/tests/hw`'s stick) on each machine of
`docs/hardware.md` and bring its rows up to date (level, date, what ran).

## 5. Pin and push

```sh
dist/bin/pin             # manifest.json from the parts' heads
dist/bin/push -n         # what would go to GitHub
dist/bin/push            # the parts; then commit manifest.json and push dist
git -C dist commit -m 'pin: ...' manifest.json && dist/bin/push dist
```

The wiki is published apart from that: `dist/bin/wiki` copies the pages dist
has committed (`HEAD:wiki`) into its clone in `cache/wiki`, commits them
there as "Sync with dist/wiki (commit)" and pushes them to GitHub's wiki;
`dist/bin/wiki -n` only shows what would change. Pages with uncommitted
changes are named and go out as committed. Run it after each push of dist
that changes a page.

`pin` refuses while a part has uncommitted changes; changes a build makes
by itself (plan9port's install paths, cargo's `Cargo.lock`) are listed in
`dist/expected-changes` and do not count. `push` sends only fast-forwards,
and `upstream` with `--force-with-lease`.

## 6. The CDs

Every profile must make a CD that installs and boots: the CDs are not
published, but each one a user makes from the release has to work. The
profiles of `main`, and `nix` from its branch (its build first: [[Building]]):

```sh
for p in minimal gpu ui full; do dist/bin/mkcd $p; done
dist/bin/mkcd full 386                 # 386: the same profiles, without the GPU stack
dist/bin/mkcd nix
```

The CDs land in `cache/cli/9space-PROFILE.ARCH.iso`. Test each one with the
CD tests of the tree it came from:

```sh
cd tree
for p in minimal gpu ui full; do ISO=../cache/cli/9space-$p.amd64.iso bash sys/src/build/host/tests/run.sh iso; done
cd ../tree-nix && ISO=../cache/cli/9space-nix.amd64.iso bash sys/src/build/host/tests/run.sh iso
```

## 7. The replica

Each `mkcd` of `main`'s profiles also publishes its CD's tree for `pull(1)`
into `cache/replica/current/NAME.ARCH` (channel `current`), signed with the key
`~/.config/9space/replica.pem` (made on the first run; keep it, and keep it out
of 9space). The CD's client asks `REPLICA_BASE/current/NAME.ARCH`; its default
is a placeholder, `https://9space-os.github.io/replica`. Nothing serves it yet,
so `pull` on a CD fails to reach it: a system is brought up to date by making a
new CD from a newer release (or `-noreplica`, a CD without the client). Once
there is a server, `cache/replica` goes there as it is (any static HTTP server;
the index is signed, the server needs no TLS of its own for the trust).

## Open

Not decided yet:

- **Published CDs and the replica's server** (later; for now everyone makes
  their own CD). GitHub Pages refuses files over 100 MB (the `full` profile's
  rustc and rustdoc are larger): split objects, release assets, or another host.
- **The release's name.** Where the tag goes (the `dist` commit whose
  `manifest.json` names every part, or each repository too) and what it is
  called (`0.1-preview`, ...).
- **Signed ISOs and an SBOM** (from `manifest.json` and `distfiles.list`), the
  channel `release`: phase 2 of the roadmap.
