# Publishing the Sakoon Repository

This folder is ready to become the public `arkenapps/Sakoon` repository without
publishing the private Go source.

---

## Updating an already-published repository (v2.0.0)

If `arkenapps/Sakoon` already exists on GitHub, **do not use `publish.bat`** —
that is the first-time publisher. Use `PUBLISH-V2-UPDATE.bat` instead. It pushes
the updated documentation and cuts the `v2.0.0` release in one run.

### Before you run it

1. Build the app: `cd Sakoon` then `build.bat`.
2. Copy the freshly built `Sakoon.exe` into `release-assets\`.
3. Make sure `git` and `gh` are installed and `gh auth login` has been done.

### Running it

```bat
PUBLISH-V2-UPDATE.bat --dry-run     rehearse; changes nothing
PUBLISH-V2-UPDATE.bat               push docs + create the v2.0.0 release
PUBLISH-V2-UPDATE.bat --docs-only   push docs only, skip the release
PUBLISH-V2-UPDATE.bat --force-push  this folder overwrites origin/main
```

### What it does, in order

1. Refuses to continue if any private Go source or secret-like file is present.
2. Checks that `git` and `gh` exist and that `gh` is signed in.
3. **Reads the version resource inside `release-assets\Sakoon.exe` and stops if
   it is not `2.0.0`** — this is the guard against shipping the old binary.
4. Regenerates `release-assets/SHA256SUMS.txt`.
5. Commits everything in this folder, then re-parents it on top of the
   already-published history so the push is a normal fast-forward.
6. Pushes to `main`.
7. Creates the `v2.0.0` release with the exe, the sample table, and the
   checksums attached, using `releases/v2.0.0.md` as the notes, and marks it
   as latest. If `v2.0.0` already exists it asks before replacing it.
8. Updates the repository description and homepage.

### How it handles the already-published v1 history

This folder is normally a fresh `git init`, so its history has nothing in
common with the `main` branch already on GitHub, and a plain `git push` can
only be rejected as non-fast-forward. The script handles that for you: it
fetches `origin/main` and uses `git reset --soft` to re-parent this exact
folder on top of the published commit. The staged tree - this folder - is
untouched; it simply gets a real parent instead of floating free.

The result is one honest commit on top of the v1.0.0 history, an ordinary
fast-forward push, and repository contents identical to this folder. Files
that existed only on GitHub are recorded as deletions, and nothing is
discarded from the history.

`--force-push` still exists as a last resort, but you should not need it. It
throws away the published commit history (releases, issues, and stars are not
affected).

### After it finishes

GitHub Pages rebuilds within a couple of minutes at
`https://arkenapps.github.io/Sakoon/`. If Pages is not enabled yet, run
`ENABLE-SAKOON-GITHUB-PAGES.bat` once.

---

## First-time publishing (kept for reference)

## 1. Install prerequisites

Install:

- Git for Windows
- GitHub CLI (`gh`)

Confirm:

```bat
git --version
gh --version
gh auth status
```

The authenticated GitHub account must have permission to create repositories
under `arkenapps`.

## 2. Review public content

Before publishing:

1. Replace screenshot placeholders in `assets/screenshots/`.
2. Review `LICENSE.txt`.
3. Review the v1.0.0 notes in `releases/v1.0.0.md`.
4. Confirm that no Go source, credentials, certificates, official private
   tables, local databases, logs, or build paths are present.
5. Place the final executable here:

```text
release-assets\Sakoon.exe
```

The script will generate:

```text
release-assets\SHA256SUMS.txt
```

The executable and generated checksum file are release assets and are not
committed to the repository.

## 3. Test without changing GitHub

From the repository root:

```bat
publish.bat --dry-run
```

Dry-run mode prints the important commands and validates the intended paths
without creating a repository, pushing commits, or publishing a release.

## 4. Publish

Run:

```bat
publish.bat
```

The script:

1. checks Git and GitHub CLI;
2. confirms GitHub authentication;
3. prevents accidental publication of common private-source folders;
4. verifies that `release-assets\Sakoon.exe` exists;
5. generates SHA-256 hashes;
6. initialises Git with branch `main`;
7. commits the public repository files;
8. creates `arkenapps/Sakoon` as a public repository if it does not exist;
9. pushes `main`;
10. creates the `v1.0.0` GitHub Release;
11. uploads the executable, format example, and checksum file.

## 5. Exact core GitHub CLI commands

For a new repository, the core creation command is:

```bat
gh repo create arkenapps/Sakoon --public --source=. --remote=origin --description "A local-first Windows desktop app that mutes PC audio around official azaan times." --homepage "https://arkenapps.com/" --push
```

The release command is:

```bat
gh release create v1.0.0 ^
  "release-assets\Sakoon.exe#Sakoon for Windows" ^
  "release-assets\Sakoon-Table-Format-Example-NOT-OFFICIAL.csv#Timing-table format example — not official" ^
  "release-assets\SHA256SUMS.txt#SHA-256 checksums" ^
  --repo arkenapps/Sakoon ^
  --title "Sakoon v1.0.0" ^
  --notes-file "releases\v1.0.0.md" ^
  --latest
```

## 6. After publication

Open:

```text
https://github.com/arkenapps/Sakoon
https://github.com/arkenapps/Sakoon/releases/latest
```

Then:

- add repository topics such as `windows`, `system-tray`, `local-first`,
  `privacy`, `prayer-times`, `azaan`, and `offline`;
- enable private vulnerability reporting in repository security settings if
  available;
- confirm the `Sakoon.exe` direct-download link works;
- download the release assets and recheck the published SHA-256 hash;
- replace any remaining screenshot placeholders;
- pin the repository on the ArkenApps GitHub profile.

## Important

Do not use `--add-readme` or a GitHub licence template when creating the
repository. This scaffold already contains the intended README and custom
personal-use licence.
