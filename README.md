# Description

This is an Optware fork. It targets to be firmware-independent and currently supports I686 and soft-float ARM EABI and MIPSEL targets.

# Getting started

Prepare USB drive, or other storage, as `/opt`, and type:

ARM EABI:
```
wget -O - http://optware-ng.zyxmon.org/buildroot-i686/buildroot-armeabi-bootstrap.sh | sh
```
MIPSEL:
```
wget -O - wget -O - http://optware-ng.zyxmon.org/buildroot-mipsel/buildroot-mipsel-bootstrap.sh | sh
```
I686:
```
wget -O - wget -O - http://optware-ng.zyxmon.org/buildroot-i686/buildroot-i686-bootstrap.sh | sh
```
ipkg package manager will be bootstrapped and configured. See available packages:
```
/opt/bin/ipkg update
/opt/bin/ipkg list
```
Install desired ones:
```
/opt/bin/ipkg install nano mc
```

# Available packages

* [ARM EABI](http://optware-ng.zyxmon.org/buildroot-armeabi/Packages.html)
* [MIPSEL](http://optware-ng.zyxmon.org/buildroot-mipsel/Packages.html)
* [I686](http://optware-ng.zyxmon.org/buildroot-i686/Packages.html)

# Some background

2015-03-07:
Being at some point an Optware developer, I learnt a bit about this build system and also grew to like it. At some point of my life, however, I got drown away from Optware. Right until I bought an ARM Asus router and discover that both Asus and Tomato USB Shibby mod (the firmware I use) use mbwe-bluering Optware feed. As it was me years ago who added this target, I knew well enough that it was far from being a good fit to be used with the router. Not to mention uClibc versions mismatch, it uses the old ARM application binary interface (OABI), which on systems without a floating point unit processor (and routers obviously don’t have one) is very slow. On the other hand, software floating point operations using the newer EABI interface are noted to be approximately 10x faster than OABI. Since all new ARM devices, and my router as well, have EABI kernels (though often with OABI support enabled), it makes sense to use EABI rather than OABI for better performance, especially when there is no FPU. However, current official Optware has no uClibc ARM EABI target, so the use of mbwe-bluering feed is understandable.

All this left me wishing to add Optware ARM EABI uClibc target, which would use the same toolchain that Asus (and Shibby) use, but, unfortunately, I was unable to renew my Optware developer’s certificate due to the project being basically stalled, hence I chose to fork. I called the new target “shibby-tomato-arm”, and went on to upgrade and fix packages, and while I was at it, add some more packages (like deluge) I wanted to have in the feed. After building the feed, I realized that due to missing uClibc’s libresolv in the firmware, one needs to use some sort of a hack on the target device to use packages that depend on it. This was when @ryzhovau chimed in and taught me how they made Entware firmware-independent. Thanks to his advice, I learnt how to make a uClibc feed depend only on the architecture, but not use a single firmware’s shared library. That being said, there is now no point to stick to the old buildroot-2012.02 toolchain used to build the firmware, so I chose to build my own toolchain using buildroot-2015.02. I called the feed “buildroot-armeabi”, and it has gcc-4.9.2 and can be used to build newer software (like recent mkvtoolnix or mpd) that needs at least gcc-4.6 (unlike shibby-tomato-arm’s gcc-4.5.3) to have proper C++11 standard support (features like range-based 'for', nullptr etc.)

2015-04-19:
Now buildroot-mipsel target added. It is similar to buildroot-armeabi, but targets mipsel softfloat (mips32r2) devices.

2015-04-30:
New buildroot-i686 target added. This is a gcc-4.9.2, glibc-2.20, linux-3.2.66 feed. It mainly targets modern Intel headless devices, such as NASes.

# Building from source

For instructions on how to build packages using this build system, see:

* [Original Optware instructions](http://www.nslu2-linux.org/wiki/Optware/AddAPackageToOptware)

If you want to build packages using this build system, apart from usual Optware dependencies, also make sure that you have an older automake (like 1.10) as unsuffixed automake and also have a newer automake installed (e.g., 1.14). Optware will search for the newest automake/aclocal in the same location where unsuffixed one is installed. Alternatively, you can run make with ACLOCAL_NEW= and AUTOMAKE_NEW= variables set:
```
make <package> ACLOCAL_NEW=aclocal-1.14  AUTOMAKE_NEW=automake-1.14
```
