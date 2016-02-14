# Description

This is an Optware fork. It targets to be firmware-independent and currently supports hard-float ARMv7, I686, PowerPC 603e and soft-float ARMv5, ARMv7 EABI and MIPSEL targets.

# Attention!

buildroot-mipsel-ng feed is now rebuilt with 2.6.22.19 kernel headers. Please reinstall all currently installed packages if you're running this feed:

```
ipkg update
ipkg -force-reinstall install `ipkg list_installed|cut -d ' ' -f1`
```

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
PowerPC 603e:
```
wget -O - http://optware-ng.zyxmon.org/buildroot-ppc-603e/buildroot-ppc-603e-bootstrap.sh | sh
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
* [PowerPC 603e](http://optware-ng.zyxmon.org/buildroot-ppc-603e/Packages.html)
* [I686](http://optware-ng.zyxmon.org/buildroot-i686/Packages.html)

# Migrating to uClibc-ng feeds from deprecated uClibc ones

If you're running a deprecated uClibc-0.9.33.2 (ARMv7 softfloat or MIPSEL) feed, you can either start from scratch, or use this script that should work for most of the cases (don't forget to backup `/opt` before you proceed!):

```
wget -O - http://optware-ng.zyxmon.org/scripts/move-to-uclibc-ng.sh | sh
```

# News

## 2016-02-14

buildroot-mipsel-ng feed, rebuilt with 2.6.22.19 kernel headers using kernel from the [wl500g](https://github.com/wl500g/wl500g) project, is now online.

## 2015-11-30

New buildroot-ppc-603e is now online. This is a hardfloat PowerPC 603e gcc-5.2.0, glibc-2.21, linux-3.2.66 feed.

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

# Building from source

For instructions on how to build packages using this build system, see:

* [Original Optware instructions](http://www.nslu2-linux.org/wiki/Optware/AddAPackageToOptware)
