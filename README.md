# EasyBox904xdsl specific feed

## Description

This is the easybox904xdsl-feed containing community-maintained build scripts, needed for the easybox904 xdsl device.

Installation of pre-built packages is handled directly by the **opkg** utility within your running OpenWrt system or by using the [OpenWrt SDK](http://wiki.openwrt.org/doc/howto/obtain.firmware.sdk) on a build system.

## Usage

This repository is intended to be layered on-top of an OpenWrt buildroot. If you do not have an OpenWrt buildroot installed, see the documentation at: [OpenWrt Buildroot – Installation](http://wiki.openwrt.org/doc/howto/buildroot.exigence) on the OpenWrt support site.

This feed is enabled by default. To install all its package definitions, run:
```
./scripts/feeds update easybox904xdsl
./scripts/feeds install -a -p easybox904xdsl
```

## License

See [LICENSE](LICENSE) file.
 
## Package Guidelines

See [CONTRIBUTING.md](CONTRIBUTING.md) file.

