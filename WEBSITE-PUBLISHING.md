# Sakoon website publishing

## ArkenApps website

Upload the following from `Sakoon_Website_Package.zip` to the public root of
the ArkenApps hosting account:

```text
azaan-audio-guard.html
sakoon-assets/
```

Expected address:

```text
https://arkenapps.com/azaan-audio-guard.html
```

## GitHub Pages

The GitHub Pages edition is already stored in:

```text
docs/index.html
docs/sakoon-assets/
```

From the local repository folder, double-click:

```text
PUBLISH-WEBSITE-UPDATE.bat
```

Type `UPDATE`.

The script commits the website and real screenshots, pushes `main`, and
configures GitHub Pages to publish from:

```text
Branch: main
Folder: /docs
```

Expected Pages address:

```text
https://arkenapps.github.io/Sakoon/
```

If API-based activation is not allowed, configure it manually in:

```text
Repository Settings > Pages
Source: Deploy from a branch
Branch: main
Folder: /docs
```
