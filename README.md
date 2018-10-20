# Description

This is an Optware fork. It targets to be firmware-independent and currently supports hard-float ARMv7, I686, x86_64, PowerPC 603e and soft-float ARMv5, ARMv7 EABI, MIPSEL and PowerPC e500v2 targets. Feeds building and hosting resources are kindly provided by [Nas-Admin.org project](http://www.nas-admin.org).

# Help wanted

Now that Optware-ng is official, we're looking for developers and wiki writers. If you're willing to give it a go, please see '**Contributing to project and building from source**' and '**Writing Optware-ng end-user instructions**' sections below.

# Attention!

If you are having issues with installing packages, similar to [#106](https://github.com/Optware/Optware-ng/issues/106), you need to upgrade your `ipkg` package manager.

Some changes have been recently made to the packaging system:
* sha256 checksum added
* Installed-Size field added to the ipk files and to the index
* opkg is now used as the package manager. To provide backward compatibility, it's patched to use ipkg pathes

To upgrade the packager, simply run the bootstrap script proper for your target (see the '**Getting started**' section) -- this will not affect your installed packages. After that, just use `ipkg` (or `ipkg-static`) command as you used it before the upgrade.

# Attention!

Optware-ng feeds have moved to [http://ipkg.nslu2-linux.org/optware-ng](http://ipkg.nslu2-linux.org/optware-ng). Please run this command to update ipkg configuration if you installed Optware-ng prior to this announcement:

```
sed -i -e 's|optware-ng\.zyxmon\.org/|ipkg.nslu2-linux.org/optware-ng/|' /opt/etc/ipkg.conf
ipkg update
```

```
ipkg update
ipkg -force-reinstall install `ipkg list_installed|cut -d ' ' -f1`
```

# Getting started

The instructions below only download, unpack and configure the package manager `ipkg`. You must previously make sure that `/opt` is writable, by preparing USB storage or router's `jffs` partition (for routers that support them), or symlink/mount-bind `/opt` to a location on your data volume (e.g., for a NAS). If you have MIPSEL/ARM Asus router running [Asuswrt-Merlin firmware](http://asuswrt.lostrealm.ca/download), check out [How To Install New Generation Optware](https://www.hqt.ro/how-to-install-new-generation-optware) guide by @TeHashX. If you owe a QNAP box, check out [Qnap Optware-NG](https://forum.qnap.com/viewtopic.php?f=124&t=137710) by @satfreak.

To bootstrap the feed, connect over SSH/Telnet and type:

ARMv7 EABI hardfloat:
(Use this if you have a modern ARM device with FPU, e.g., a NAS)
```
wget -O - http://ipkg.nslu2-linux.org/optware-ng/bootstrap/buildroot-armeabihf-bootstrap.sh | sh
```
ARMv7 EABI softfloat:
(Use this for a modern ARM device without FPU, e.g., an ARMv7 router)
```
wget -O - http://ipkg.nslu2-linux.org/optware-ng/bootstrap/buildroot-armeabi-ng-bootstrap.sh | sh
```
ARMv5 EABI (use this if running a more recent linux, 2.6.36.4 or newer):
```
wget -O - http://ipkg.nslu2-linux.org/optware-ng/bootstrap/buildroot-armv5eabi-ng-bootstrap.sh | sh
```
ARMv5 EABI legacy (built with 2.6.22 kernel headers, use for devices that run old kernels):
```
wget -O - http://ipkg.nslu2-linux.org/optware-ng/bootstrap/buildroot-armv5eabi-ng-legacy-bootstrap.sh | sh
```
MIPSEL:
```
wget -O - http://ipkg.nslu2-linux.org/optware-ng/bootstrap/buildroot-mipsel-ng-bootstrap.sh | sh
```
PowerPC 603e:
```
wget -O - http://ipkg.nslu2-linux.org/optware-ng/bootstrap/buildroot-ppc-603e-bootstrap.sh | sh
```
PowerPC e500v2:
```
wget -O - http://ipkg.nslu2-linux.org/optware-ng/bootstrap/ct-ng-ppc-e500v2-bootstrap.sh | sh
```
I686:
```
wget -O - http://ipkg.nslu2-linux.org/optware-ng/bootstrap/buildroot-i686-bootstrap.sh | sh
```
x86_64:
```
wget -O - http://ipkg.nslu2-linux.org/optware-ng/bootstrap/buildroot-x86_64-bootstrap.sh | sh
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

* [ARMv7 EABI hardfloat](http://ipkg.nslu2-linux.org/optware-ng/buildroot-armeabihf/Packages.html)
* [ARMv7 EABI softfloat](http://ipkg.nslu2-linux.org/optware-ng/buildroot-armeabi-ng/Packages.html)
* [ARMv5 EABI](http://ipkg.nslu2-linux.org/optware-ng/buildroot-armv5eabi-ng/Packages.html)
* [ARMv5 EABI legacy](http://ipkg.nslu2-linux.org/optware-ng/buildroot-armv5eabi-ng-legacy/Packages.html)
* [MIPSEL](http://ipkg.nslu2-linux.org/optware-ng/buildroot-mipsel-ng/Packages.html)
* [PowerPC 603e](http://ipkg.nslu2-linux.org/optware-ng/buildroot-ppc-603e/Packages.html)
* [PowerPC e500v2](http://ipkg.nslu2-linux.org/optware-ng/ct-ng-ppc-e500v2/Packages.html)
* [I686](http://ipkg.nslu2-linux.org/optware-ng/buildroot-i686/Packages.html)
* [x86_64](http://ipkg.nslu2-linux.org/optware-ng/buildroot-x86_64/Packages.html)

# Contributing to project and building from source

Contribution is always welcomed. These wiki pages contain useful info to get you started:

* [Contributing to Optware-ng](https://github.com/Optware/Optware-ng/wiki/Contributing-to-Optware-ng)
* [Adding a package to Optware-ng](https://github.com/Optware/Optware-ng/wiki/Adding-a-package-to-Optware-ng)

# Writing Optware-ng end-user instructions

Currently, the project is missing writers who would contribute by creating how-to's for end-users. We can setup a mediawiki with the help of nas-admin.org guys, but we need people to fill it. In case you are willing to contribute by writing how-to's, please contact me on #**optware** IRC channel on irc.freenode.net, nickname **alllexx**. If I'm away, you can PM me, and I'll reach you later.

# News

## 2018-10-07

buildroot-x86_64 feed added

## 2017-12-11

buildroot-ppc-603e feed rebuilt with 2.6.32 kernel headers to support WD My Book Live NASes

## 2016-04-25

ct-ng-ppc-e500v2 feed rebuilt with 2.6.32 kernel headers to support Synology PowerPC e500v2 NASes

## 2016-04-14

New ct-ng-ppc-e500v2 feed is now online. This is a softfloat PowerPC e500v2 gcc-5.3.0, glibc-2.23, linux-3.2.66 feed.

## 2016-04-07

buildroot-armve5eabi-ng-legacy feed is now ARMv5 gcc-5.3.0, uClibc-ng-1.0.13, linux-2.6.22. Proper QNAP TS-109Pro support is not feasible until the custom 2.6.12 kernel source used there are made available.

## 2016-03-17

buildroot-armve5eabi-ng-legacy feed added. This is ARMv5 gcc-5.3.0, uClibc-ng-1.0.12, linux-2.6.12 feed. It targets older ARMv5 devices, like QNAP TS-109Pro.

## 2016-02-23

Optware-ng is now official. Feeds are built and hosted by [Nas-Admin.org project](http://www.nas-admin.org). See http://jenkins.nas-admin.org/view/Optware

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
