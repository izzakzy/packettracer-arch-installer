# packettracer-arch-installer

One-command installer for **Cisco Packet Tracer** on Arch Linux. It wraps the
[`packettracer`](https://aur.archlinux.org/packages/packettracer) AUR package and
handles the parts that usually go wrong.

> Cisco Packet Tracer is proprietary and cannot be redistributed. This repo
> contains only helper scripts. You download the installer from Cisco yourself.

## Contents

| File | Purpose |
|---|---|
| `install.sh` | Validates your Cisco `.deb`, builds and installs the package, adds a launcher |
| `check-update.sh` | Compares your installed version with the AUR |
| `uninstall.sh` | Removes the package and launcher |

## 1. Download the installer from Cisco

1. Sign in (free) at <https://www.skillsforall.com>.
2. Enroll in **Getting Started with Cisco Packet Tracer** (use the **Self-Paced Online** tab).
3. Go to **Resources → Download Packet Tracer** and pick **Ubuntu 64-bit (.deb)**.

Cisco's download links expire after **30 seconds**. Click once and let the download
start immediately. Don't reuse or copy the link.

## 2. Install

```bash
git clone https://github.com/YOUR_USER/packettracer-arch-installer.git
cd packettracer-arch-installer
./install.sh                                  # uses the newest ~/Downloads/CiscoPacketTracer*.deb
./install.sh ~/path/to/CiscoPacketTracer_901_Ubuntu_64bit.deb   # or give a path
```

The script:

1. Checks the `.deb` is genuine (over 50 MB and a real Debian package).
2. Installs `base-devel`, `git` and `fuse2`.
3. Clones the AUR recipe and builds the package with `--skipchecksums`.
4. Adds a `packettracer` command in `~/.local/bin`, a menu entry, and the `pttp://` login handler.

Make sure `~/.local/bin` is on your `PATH`.

## 3. Run

```bash
packettracer
```

On first launch type `2` to accept the EULA, then sign in with your Skills for All account.
The package installs an AppImage at `/usr/lib/packettracer/packettracer.AppImage`.

## Updating

Packet Tracer does not update itself, and neither does the AUR package.

```bash
./check-update.sh
```

If a newer version exists, download the new `.deb` from Cisco and run `./install.sh` with it.
If Cisco is ahead of the AUR, edit `pkgver` and the `local://` filename in the PKGBUILD
(in `~/.cache/packettracer-install/packettracer`) or wait for the maintainer to update it.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| Script says the file is not a real `.deb` | The link expired and the browser saved a ~366 byte S3 "Request has expired" error. Download again. |
| `tar: data.tar.xz: Cannot open` | Same cause: the `.deb` is an error page. |
| `ar: file format not recognized` | Same cause. |
| Checksum `FAILED` | Cisco re-uploads under the same name. The script already uses `--skipchecksums`. |
| `command not found: packettracer` | Add `~/.local/bin` to `PATH`, or run `/usr/lib/packettracer/packettracer.AppImage` directly. |
| `/opt/pt/bin` does not exist | Expected: this package uses an AppImage, not `/opt/pt`. |
| AppImage won't start (FUSE error) | `sudo pacman -S fuse2` |
| Blank or glitchy window on Wayland | `QT_QPA_PLATFORM=xcb packettracer` |
| Tiny UI on HiDPI | `QT_SCALE_FACTOR=1.5 packettracer` |
| Login finishes in browser but app doesn't react | `xdg-mime default packettracer.desktop x-scheme-handler/pttp` |

## Uninstall

```bash
./uninstall.sh
```

## License

MIT for the scripts only. Packet Tracer is Cisco's property.