# Gauntlet releases

Build artifacts and the signed update manifest for Gauntlet.

There is no source here. This repository exists because an application that
updates itself has to fetch its manifest without credentials, and that means
the artifacts have to be public even while the source is not.

## Install

macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/rathojohn/gauntlet-releases/main/install.sh | sh
```

The script is worth reading before you pipe it anywhere. It downloads the
latest release, verifies it, and copies it to `/Applications`.

It installs with `curl` rather than a browser on purpose. macOS quarantine is
applied by the downloading application, not by the system, and command line
tools do not set it. A browser download of the same file would be blocked by
Gatekeeper until you cleared it by hand in System Settings.

## Updates

The app checks this repository on launch and can install a new version itself.
Updates are signed; the app carries only the public key and refuses anything it
cannot verify, so a public repository means these artifacts are readable, not
writable.
