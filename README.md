# Description

This is an Optware fork. It targets to be firmware-independent and currently supports hard-float ARMv7, I686 and soft-float ARMv5, ARMv7 EABI and MIPSEL targets.

# Attention!

uClibc-0.9.33.2 feeds: ARMv7 (buildroot-armeabi) and MIPSEL (buildroot-mipsel) are now DEPRECATED. These feeds will remain there on the server, but will not be developed further, since uClibc-0.9.33.2 is *very* outdated. New feeds that use uClibc-ng-1.0.6: buildroot-armeabi-ng and buildroot-mipsel-ng should be used instead. If you have previously bootstrapped one of the uClibc-0.9.33.2 feeds using `buildroot-armeabi-bootstrap.sh` or `buildroot-mipsel-bootstrap.sh` scripts, see below for migrating instructions.

# Getting started

The instructions below only download, unpack and configure the package manager `ipkg`. You must previously make sure that `/opt` is writable, by preparing USB storage or router's `jffs` partition (for routers that support them), or symlink/mount-bind `/opt` to a location on your data volume (e.g., for a NAS). If you have MIPSEL/ARM Asus router running [Asuswrt-Merlin firmware](http://asuswrt.lostrealm.ca/download), check out [How To Install New Generation Optware]( https://www.hqt.ro/how-to-install-new-generation-optware) guide by @TeHashX.

To bootstrap the feed, connect over SSH/Telnet and type:

ARMv7 EABI hardfloat:
(Use this if you have a modern ARM device with FPU, e.g., a NAS)
```
wget -O - http://optware-ng.zyxmon.org/buildroot-armeabihf/buildroot-armeabihf-bootstrap.sh | sh
```
ARMv7 EABI softfloat:
(Use this for a modern ARM device without FPU, e.g., an ARMv7 router)
```
wget -O - http://optware-ng.zyxmon.org/buildroot-armeabi-ng/buildroot-armeabi-ng-bootstrap.sh | sh
```
ARMv5 EABI:
```
wget -O - http://optware-ng.zyxmon.org/buildroot-armv5eabi-ng/buildroot-armv5eabi-ng-bootstrap.sh | sh
```
MIPSEL:
```
wget -O - http://optware-ng.zyxmon.org/buildroot-mipsel-ng/buildroot-mipsel-ng-bootstrap.sh | sh
```
I686:
```
wget -O - http://optware-ng.zyxmon.org/buildroot-i686/buildroot-i686-bootstrap.sh | sh
```
ipkg package manager will be bootstrapped and configured. See available packages:
```
export PATH=$PATH:/opt/bin:/opt/sbin
/opt/bin/ipkg update
/opt/bin/ipkg list
```
Install desired ones:
```
/opt/bin/ipkg install nano mc
```

# Available packages

* [ARMv7 EABI hardfloat](http://optware-ng.zyxmon.org/buildroot-armeabihf/Packages.html)
* [ARMv7 EABI softfloat](http://optware-ng.zyxmon.org/buildroot-armeabi-ng/Packages.html)
* [ARMv5 EABI](http://optware-ng.zyxmon.org/buildroot-armv5eabi-ng/Packages.html)
* [MIPSEL](http://optware-ng.zyxmon.org/buildroot-mipsel-ng/Packages.html)
* [I686](http://optware-ng.zyxmon.org/buildroot-i686/Packages.html)

# Migrating to uClibc-ng feeds from deprecated uClibc ones

If you're running a deprecated uClibc-0.9.33.2 (ARMv7 softfloat or MIPSEL) feed, you can either start from scratch, or use this script that should work for most of the cases (don't forget to backup `/opt` before you proceed!):

```
wget -O - http://optware-ng.zyxmon.org/scripts/move-to-uclibc-ng.sh | sh
```

# News

## 2015-10-26

New buildroot-armv5eabi-ng feed is now online. This is a softfloat ARMv5 gcc-5.2.0, uClibc-ng-1.0.6, linux-2.6.36.4 feed. It targets ARMv5 devices with EABI interface, like older ARM NASes or android devices.

## 2015-09-29

New buildroot-armeabihf feed is now online. This is a hardfloat ARMv7 gcc-5.2.0, glibc-2.21, linux-3.2.66 feed. It targets ARMv7 devices with FPUs, like most modern android devices or ARM NASes, and gives significant performance boost on such devices compared to softfloat.

## 2015-09-16

New buildroot-armeabi-ng and buildroot-mipsel-ng feeds should now be used for softfloat ARMv7 and MIPSEL devices. These are uClibc-ng-1.0.6 gcc-5.2.0 targets. Look above for instructions on migrating from now deprecated buildroot-armeabi and buildroot-mipsel feeds.

## 2015-09-05

Upgrade buildroot-armeabi, buildroot-i686 and buildroot-mipsel toolchains to gcc-5.2.0 to support all C++14 language features. libc versions and configs and kernel headers versions left the same to not brake compatibility with previously built binaries. Also use "--with-default-libstdcxx-abi=gcc4-compatible" libstdc++ configure switch for the same purpose. Buildroot-2015.08 is now used to build the toolchains.

## 2015-04-30:

New buildroot-i686 target added. This is a gcc-4.9.2, glibc-2.20, linux-3.2.66 feed. It mainly targets modern Intel headless devices, such as NASes.

## 2015-04-19:

Now buildroot-mipsel target added. It is similar to buildroot-armeabi, but targets mipsel softfloat (mips32r2) devices.

# Background

Being at some point an Optware developer, I learnt a bit about this build system and also grew to like it. At some point of my life, however, I got drown away from Optware. Right until I bought an ARM Asus router and discover that both Asus and Tomato USB Shibby mod (the firmware I use) use mbwe-bluering Optware feed. As it was me years ago who added this target, I knew well enough that it was far from being a good fit to be used with the router. Not to mention uClibc versions mismatch, it uses the old ARM application binary interface (OABI), which on systems without a floating point unit processor (and routers obviously don’t have one) is very slow. On the other hand, software floating point operations using the newer EABI interface are noted to be approximately 10x faster than OABI. Since all new ARM devices, and my router as well, have EABI kernels (though often with OABI support enabled), it makes sense to use EABI rather than OABI for better performance, especially when there is no FPU. However, current official Optware has no uClibc ARM EABI target, so the use of mbwe-bluering feed is understandable.

All this left me wishing to add Optware ARM EABI uClibc target, which would use the same toolchain that Asus (and Shibby) use, but, unfortunately, I was unable to renew my Optware developer’s certificate due to the project being basically stalled, hence I chose to fork. I called the new target “shibby-tomato-arm”, and went on to upgrade and fix packages, and while I was at it, add some more packages (like deluge) I wanted to have in the feed. After building the feed, I realized that due to missing uClibc’s libresolv in the firmware, one needs to use some sort of a hack on the target device to use packages that depend on it. This was when @ryzhovau chimed in and taught me how they made Entware firmware-independent. Thanks to his advice, I learnt how to make a uClibc feed depend only on the architecture, but not use a single firmware’s shared library. That being said, there is now no point to stick to the old buildroot-2012.02 toolchain used to build the firmware, so I chose to build my own toolchain using buildroot-2015.02. I called the feed “buildroot-armeabi”, and it has gcc-4.9.2 and can be used to build newer software (like recent mkvtoolnix or mpd) that needs at least gcc-4.6 (unlike shibby-tomato-arm’s gcc-4.5.3) to have proper C++11 standard support (features like range-based 'for', nullptr etc.)

# Building from source

For instructions on how to build packages using this build system, see:

* [Original Optware instructions](http://www.nslu2-linux.org/wiki/Optware/AddAPackageToOptware)
