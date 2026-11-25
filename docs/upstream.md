# Bringing in 9front (merges)

The tree's branches (one git repository; only `main` is checked out, in `tree`.
A worktree for another branch, `tree-gcc` etc. where `paths.env` puts it, only to
work on several branches at once: `dist/bin/repos --worktrees=gcc,...`):

| Branch | Worktree, if any | What |
|---|---|---|
| `front` | (none) | mirror of github.com/9front/9front, branch `front`; fast-forward only |
| `gcc` | `tree-gcc` | 9front built with gcc; minimal changes against `front` |
| `main` | `tree` | 9space: gcc + the GPU stack + wsys/ui (`ui` until 2026-11-12) |
| `nix`, `riscv` | `tree-nix`, `tree-riscv` | ports on `gcc` |
| `upstream` | `tree-upstream` | fixes for 9front itself, one commit each on `origin/front` (`sys/src/build/host/patch-upstream/`) |

Since 2026-11-13 9front comes in by **merge**, not rebase: `gcc`, `main`, `nix`
and `riscv` are public and cloned (`dist/bin/repos` only fast-forwards), so their
history is never rewritten and never force-pushed. The port's changes stay
reviewable as `git diff front gcc` (the rule "minimal changes against `front`").
Only `upstream` is rebased: its commits go to 9front as patches.

Steps:

1. Fast-forward `front` to 9front's: `git -C tree fetch origin front:front`.
2. Merge `front` into `gcc` (`git merge front`); `sys/src/build/host/tests/static` (it fails if a
   manifest differs from its generator in `sys/src/build/gen`: regenerate it), build
   amd64, 386, arm64, `sys/src/build/host/tests/run.sh boot`.
3. Merge `gcc` into `main`, `nix`, `riscv`; build and test each (`sys/src/build/host/tests/static`,
   `sys/src/build/host/tests/gpu/run.sh` for `main`). A change both sides made (paths, scripts) is
   resolved for the branch's own version.
4. `upstream`: rebased onto the new `front` (all its commits must apply; one
   9front has taken drops out); it alone is force-pushed. `sys/src/build/host/patch-upstream/` is
   not exported again: the files keep their numbers, a taken one moves to
   `sys/src/build/host/patch-upstream/archive/` (its README: "Archive"), a new one gets the next
   free number.
5. Push `front`, `gcc`, `main`, `nix`, `riscv`, `upstream` (`bin/push tree`:
   `upstream` with `--force-with-lease`); `bin/pin` in the distribution's
   repository, then `bin/push dist`.

`main` is merged in `tree` itself. A branch without a worktree is merged in one
made for the while, never by switching `tree` (its working tree holds `main`'s build):

```sh
git -C tree worktree add ../tree-gcc gcc
(cd tree-gcc && git merge front)
git -C tree worktree remove ../tree-gcc      # once built, tested and pushed
```

A change for every branch (paths, a fix of the port) goes on `gcc` and comes to
the others by the next merge; to keep that merge clean, write the lines as the
other branches already have them.

Leave no backup branches in the repository (they once carried old history
with GPL code): before larger work at most a `git bundle` outside the
repositories (`~/Devel/9space-attic/bundles`).
