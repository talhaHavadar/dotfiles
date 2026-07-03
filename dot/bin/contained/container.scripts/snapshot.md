# snapshot

Build Debian `*.orig` tarball(s) for packages whose upstream lives in a
subdirectory (or several) of an upstream **git monorepo**, with `gbp` +
`pristine-tar`. Handles **multiple gbp components** and **`Files-Excluded`
repacking**, and adds a reviewer-side **regenerate / verify** flow.

The mechanism is upstream-agnostic; ROCm/rocm-systems is just the example below.

## Why a script (and not just `d/watch` / `uscan`)

`uscan` _can_ follow a git ref and synthesise a snapshot version — e.g.

```
version=4
opts="mode=git, pgpmode=none, gitmode=shallow, pretty=0~git%cd.%h" \
  https://github.com/ROCm/rocm-systems.git HEAD
```

produces `0~git20260624.fbc96946`. **But** for a monorepo it can't do the job: it
tars the _entire_ repo at that ref — there is no way to extract just
`projects/clr` to the tarball root, and no way to emit sibling
`orig-<component>` tarballs from `projects/hip`. `Files-Excluded` only _removes_
files; it can't re-root `projects/clr/...` to the source root. So snapshot orig
creation needs a helper. `d/watch` stays useful for **released** versions (it
downloads the per-release `clr.tar.gz` / `hip.tar.gz` assets); this tool is for
**snapshots** (and for reproducing/verifying them).

## Placement

The tool lives in `~/sandbox/` next to the packaging clones. `contained`
bind-mounts the _parent_ of your cwd, so from inside a packaging repo the tool is
visible as `/work/snapshot` and `../*.orig.tar.*` persists to the host.

```
contained -i -- bash          # drop into the Debian-tools container
cd /work/rocm-hipamd
/work/snapshot <subcommand> ...
```

## Config

Default `debian/snapshot.conf` (auto-discovered), or pass any path with `-c` so
you don't have to commit it:

```
/work/snapshot -c ~/configs/rocm-hipamd.conf create -u 7.3.0
```

```sh
# debian/snapshot.conf
UPSTREAM_URL="https://github.com/ROCm/rocm-systems.git"   # required
UPSTREAM_REF="develop"
MAIN_SUBDIR="projects/clr"          # -> main *.orig.tar.* (root: hipamd/ rocclr/ opencl/ ...)
COMPONENTS="hip:projects/hip"       # <component-name>:<monorepo-subdir>, space/newline separated
COMPRESSION="xz"
SEP="~"                             # 7.3.0~git... sorts BEFORE 7.3.0
# DEBIAN_BRANCH="debian/experimental"   # else taken from debian/gbp.conf
```

Any of these may also come from the environment. If `UPSTREAM_URL` is set by
neither the config nor the environment, it falls back to the `Repository:` field
of `debian/upstream/metadata` (DEP-12), so packages that already declare their
upstream there don't need to repeat it. **Component name ≠ subdir name:**
the _name_ (left of `:`) drives the tarball name (`orig-<name>`) and the on-disk
dir (`<name>/`); the _subdir_ (right of `:`) is only where content is read from.

### Monorepo auto-detect

For known upstream monorepos, `MAIN_SUBDIR` is filled in automatically from a
small built-in map keyed by the upstream URL's `owner/repo` (case-insensitive,
`.git` and SSH/HTTPS variants all normalize to the same key):

| Upstream                           | Default `MAIN_SUBDIR` |
| ---------------------------------- | --------------------- |
| `github.com/ROCm/rocm-libraries`   | `projects/<pkg>`      |
| `github.com/ROCm/rocm-systems`     | `projects/<pkg>`      |

`<pkg>` is the source package name from `debian/changelog`. So a package whose
only upstream pointer is the `Repository:` field of `debian/upstream/metadata`
needs no `debian/snapshot.conf` at all — e.g. for `hipblas-common` pointing at
`ROCm/rocm-libraries`, `MAIN_SUBDIR` resolves to `projects/hipblas-common`
automatically and `snapshot orig` packs just that subtree.

Precedence is **config file > env > per-package pin > monorepo map > whole
upstream repo**, so anything you set explicitly still wins. Register a new
monorepo by adding a line to the `UPSTREAM_MONOREPOS` array near the top of
`snapshot.sh`; the value is a `printf` template where `%s` is substituted with
the package name (use e.g. `"components/lib%s"` if the upstream lays things
out differently).

### Per-package layout overrides

Some monorepo packages don't fit the `projects/<pkg>` template — either the
upstream subdir name differs from the source package name, or the package
pulls a sibling subdir in as a gbp component. For example, `rocm-hipamd`
lives under `ROCm/rocm-systems` but its main tarball comes from
`projects/clr` (not `projects/rocm-hipamd`, which doesn't exist), plus a
`hip` component from `projects/hip`.

Pin the layout in-script via the `UPSTREAM_PACKAGE_MAIN` and
`UPSTREAM_PACKAGE_COMPONENTS` maps in `snapshot.sh`, keyed by source
package name:

```sh
declare -A UPSTREAM_PACKAGE_MAIN=(
    [rocm-hipamd]="projects/clr"
)
declare -A UPSTREAM_PACKAGE_COMPONENTS=(
    [rocm-hipamd]="hip:projects/hip"
)
```

These fire only when `MAIN_SUBDIR` / `COMPONENTS` are still empty after
config+env — explicit settings still win. Unlisted packages fall through
to the monorepo template (or, for non-monorepo upstreams like
`ROCm/rocm-cmake`, to whole-repo mode) exactly as before.

## Subcommands

`snapshot [-c CONFIG] <create|orig|verify> [options]`

### `create` — package the latest upstream (maintainer)

```
/work/snapshot create -u 7.3.0            # 7.3.0 = the marketing/base version
/work/snapshot create -u 7.3.0 -r develop # explicit ref (tag/branch/commit)
/work/snapshot create -u 7.3.0 --no-import # only write ../*.orig*, skip gbp
```

Shallow-fetches the ref, derives `<base>~git<UTCdate>.<sha10>[+ds]` from the
_commit_ (reproducible — same commit ⇒ same version), builds the main +
component tarballs (`git archive` → `mk-origtargz`, applying
`Files-Excluded` / `Files-Excluded-<component>`), then
`gbp import-orig --pristine-tar --merge-mode=replace` and a `dch` entry. `+ds` is
decided **once** from `debian/copyright` and applied to _all_ tarballs so their
upstream version always matches.

> The marketing/base version (`7.3.0`) is not derivable from the monorepo — pass
> it with `-u` (or set `UPSTREAM_VERSION` in the config).

### `orig` — regenerate orig(s) for the top changelog entry (reviewer / build)

```
/work/snapshot orig
```

Regenerates `../<pkg>_<ver>.orig*.tar.*` for the **topmost changelog version**.
Prefers committed `pristine-tar` (exact, offline, via `gbp export-orig`); if
absent, re-derives from upstream using the date+sha encoded in the version. Then
`dpkg-buildpackage` / `gbp buildpackage` to check it builds.

### `verify` — was the orig created honestly? (tech-lead check)

```
/work/snapshot verify
```

Independently re-derives the orig(s) from upstream at the commit encoded in the
top changelog version and compares their **content** (per-file sha256, top-dir
agnostic) against what the repo would build from `pristine-tar`/upstream. Prints
`PASS`/`FAIL` per tarball; exit `0` = all match, `1` = mismatch.

## Reproducibility note

The snapshot version embeds a **10-char** short sha. GitHub's git server fetches
a _full_ 40-char commit but **refuses an abbreviated** one, so `verify`/`orig`
recover the commit by fetching the branch and deepening until the short sha
resolves — and the committed `pristine-tar` branch is the exact, offline source
of truth for a build. For network-independent re-derivation with zero
pristine-tar dependence, set `SHA_ABBREV=40` in the config to embed the full sha.
