# Making a release

A release of 9space is one pinned state of all its parts (`manifest.json` in
the `dist` repository), the install CDs made from it, and the tree those CDs
publish for `pull(1)`. This page goes from a working checkout to that state;
[[Building]] has the steps it builds on (toolchains, tree, CDs), and the
roadmap (`docs/roadmap.md`) the releases planned (0.1-preview, 0.9-beta, 1.0).

All commands run in `~/Devel/9space`. Builds and guests one at a time: two
builds never in one tree, and no other load while a suite boots guests.

## 1. 9front's newest

Bring in 9front's `front` and merge it through the tree's branches, as
`docs/upstream.md` describes (`front` → `gcc` → `main`, `nix`, `riscv`;
`upstream` rebased, `patch-upstream/` exported again). Each branch is built
and tested before the next merge.

## 2. The other parts up to date

```sh
dist/bin/repos           # fast-forwards every part that is clean and on its branch
dist/bin/status          # each part against manifest.json
```

Then rebuild what changed (the table in [[Building]], "Later: updating"), or
everything from scratch with `dist/bin/build-toolchains`.

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
bash tests/static/run.sh
bash tests/run.sh                      # every category, amd64
objtype=386 bash tests/run.sh          # and the other architectures
objtype=arm64 bash tests/run.sh
bash tests/gpu/run.sh                  # ~1 h, needs a host GPU
cd ..
```

The branches `nix` and `riscv` are built and tested in their worktrees
(`dist/bin/repos --worktrees=nix,riscv tree`; riscv64:
[[Building]], "Not in build-toolchains"). A test that fails once and passes
again is not done: its cause goes into `tree/MEMORY.md` (`scripts/guest/boot-cli.sh`
keeps a boot that never reached its prompt in `cache/cli/noprompt.TIME`).

Real hardware: run the CD (or `tree/tests/hw`'s stick) on each machine of
`docs/hardware.md` and bring its rows up to date (level, date, what ran).

## 5. Pin and push

```sh
dist/bin/pin             # manifest.json from the parts' heads
dist/bin/push -n         # what would go to GitHub
dist/bin/push            # the parts; then commit manifest.json and push dist
git -C dist commit -m 'pin: ...' manifest.json && dist/bin/push dist
```

`pin` refuses while a part has uncommitted changes; changes a build makes
by itself (plan9port's install paths, cargo's `Cargo.lock`) are listed in
`dist/expected-changes` and do not count. `push` sends only fast-forwards,
and `upstream` with `--force-with-lease`.

## 6. The CDs

One CD per profile, from the build of `main` (profiles: [[Building]]):

```sh
for p in minimal gpu ui full; do dist/bin/mkcd $p; done
dist/bin/mkcd full 386                 # 386: the same profiles, without the GPU stack
```

The CDs land in `cache/cli/9space-PROFILE.ARCH.iso`. Test each one:

```sh
cd tree
for p in minimal gpu ui full; do ISO=../cache/cli/9space-$p.amd64.iso bash tests/run.sh iso; done
```

## 7. The replica

Each `mkcd` also publishes its CD's tree for `pull(1)` into
`cache/replica/current/NAME.ARCH` (channel `current`), signed with the key
`~/.config/9space/replica.pem` (made on the first run; keep it, and keep it
out of 9space). The CD's client asks `REPLICA_BASE/current/NAME.ARCH`; its
default is a placeholder, `https://9space-os.github.io/replica`.

To release, `cache/replica` goes to the web server at `REPLICA_BASE` as it is
(any static HTTP server; the index is signed, the server needs no TLS of its
own for the trust).

## Open

These are not decided yet; until they are, a release stops after step 6:

- **The server for the replica.** GitHub Pages refuses files over 100 MB
  (the `full` profile's rustc and rustdoc are larger): split objects, release
  assets, or another host.
- **The release's name.** Where the tag goes (the `dist` commit whose
  `manifest.json` names every part, or each repository too) and what it is
  called (`0.1-preview`, ...).
- **Signed ISOs and an SBOM** (from `manifest.json` and `distfiles.list`), the
  channel `release`: phase 2 of the roadmap.
