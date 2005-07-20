###########################################################
#
# qemu
#
###########################################################
#
# QEMU_VERSION, QEMU_SITE and QEMU_SOURCE define
# the upstream location of the source code for the package.
# QEMU_DIR is the directory which is created when the source
# archive is unpacked.
# QEMU_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
QEMU_SITE=http://fabrice.bellard.free.fr/qemu
QEMU_VERSION=0.7.0
QEMU_SOURCE=qemu-$(QEMU_VERSION).tar.gz
QEMU_DIR=qemu-$(QEMU_VERSION)
QEMU_UNZIP=zcat
QEMU_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
QEMU_DESCRIPTION=A portable machine emulator.
QEMU_SECTION=misc
QEMU_PRIORITY=optional
QEMU_DEPENDS=zlib
QEMU_SUGGESTS=
QEMU_CONFLICTS=

ifeq ($(UNSLUNG_TARGET),nslu2)
QEMU_CPU=armv4b
endif
ifeq ($(UNSLUNG_TARGET),wl500g)
QEMU_CPU=mips
endif

#
# QEMU_IPK_VERSION should be incremented when the ipk changes.
#
QEMU_IPK_VERSION=1

#
# QEMU_CONFFILES should be a list of user-editable files
QEMU_CONFFILES=

#
# QEMU_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
QEMU_PATCHES=$(QEMU_SOURCE_DIR)/arm-build-fixes.patch $(QEMU_SOURCE_DIR)/arm-bigendian-host.patch $(QEMU_SOURCE_DIR)/arm-timer.patch $(QEMU_SOURCE_DIR)/cross-build.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
QEMU_CPPFLAGS=-DDEBUG_MMAP
QEMU_LDFLAGS=

#
# QEMU_BUILD_DIR is the directory in which the build is done.
# QEMU_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# QEMU_IPK_DIR is the directory in which the ipk is built.
# QEMU_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
QEMU_BUILD_DIR=$(BUILD_DIR)/qemu
QEMU_SOURCE_DIR=$(SOURCE_DIR)/qemu
QEMU_IPK_DIR=$(BUILD_DIR)/qemu-$(QEMU_VERSION)-ipk
QEMU_IPK=$(BUILD_DIR)/qemu_$(QEMU_VERSION)-$(QEMU_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(QEMU_SOURCE):
	$(WGET) -P $(DL_DIR) $(QEMU_SITE)/$(QEMU_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
qemu-source: $(DL_DIR)/$(QEMU_SOURCE) $(QEMU_PATCHES)

#
# This target unpacks the source code in the build directory.
#
$(QEMU_BUILD_DIR)/.configured: $(DL_DIR)/$(QEMU_SOURCE) $(QEMU_PATCHES)
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(QEMU_DIR) $(QEMU_BUILD_DIR)
	$(QEMU_UNZIP) $(DL_DIR)/$(QEMU_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(QEMU_PATCHES) | patch -d $(BUILD_DIR)/$(QEMU_DIR) -p1
	mv $(BUILD_DIR)/$(QEMU_DIR) $(QEMU_BUILD_DIR)
	cp $(QEMU_SOURCE_DIR)/armeb.ld $(QEMU_BUILD_DIR)
	(cd $(QEMU_BUILD_DIR); \
		./configure \
		--cross-prefix=$(TARGET_CROSS) \
		--extra-cflags="$(STAGING_CPPFLAGS) $(QEMU_CPPFLAGS)" \
		--extra-ldflags="$(STAGING_LDFLAGS) $(QEMU_LDFLAGS)" \
		--cpu=$(QEMU_CPU) \
		--make="$(MAKE)" \
		--prefix=/opt \
		--disable-sdl \
	)
	touch $(QEMU_BUILD_DIR)/.configured

qemu-unpack: $(QEMU_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(QEMU_BUILD_DIR)/.built: $(QEMU_BUILD_DIR)/.configured
	rm -f $(QEMU_BUILD_DIR)/.built
	$(MAKE) -C $(QEMU_BUILD_DIR) HOST_CC=$(HOSTCC) dyngen
	$(MAKE) -C $(QEMU_BUILD_DIR) \
		CFLAGS="$(STAGING_CPPFLAGS) $(QEMU_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(QEMU_LDFLAGS)" \
		VL_LDFLAGS="$(STAGING_LDFLAGS) $(QEMU_LDFLAGS)"
	touch $(QEMU_BUILD_DIR)/.built

#
# This is the build convenience target.
#
qemu: $(QEMU_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/qemu
#
$(QEMU_IPK_DIR)/CONTROL/control:
	@install -d $(QEMU_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: qemu" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(QEMU_PRIORITY)" >>$@
	@echo "Section: $(QEMU_SECTION)" >>$@
	@echo "Version: $(QEMU_VERSION)-$(QEMU_IPK_VERSION)" >>$@
	@echo "Maintainer: $(QEMU_MAINTAINER)" >>$@
	@echo "Source: $(QEMU_SITE)/$(QEMU_SOURCE)" >>$@
	@echo "Description: $(QEMU_DESCRIPTION)" >>$@
	@echo "Depends: $(QEMU_DEPENDS)" >>$@
	@echo "Suggests: $(QEMU_SUGGESTS)" >>$@
	@echo "Conflicts: $(QEMU_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(QEMU_IPK_DIR)/opt/sbin or $(QEMU_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(QEMU_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(QEMU_IPK_DIR)/opt/etc/qemu/...
# Documentation files should be installed in $(QEMU_IPK_DIR)/opt/doc/qemu/...
# Daemon startup scripts should be installed in $(QEMU_IPK_DIR)/opt/etc/init.d/S??qemu
#
# You may need to patch your application to make it use these locations.
#
$(QEMU_IPK): $(QEMU_BUILD_DIR)/.built
	rm -rf $(QEMU_IPK_DIR) $(BUILD_DIR)/qemu_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(QEMU_BUILD_DIR) \
		prefix=$(QEMU_IPK_DIR)/opt \
		bindir=$(QEMU_IPK_DIR)/opt/bin \
		mandir=$(QEMU_IPK_DIR)/opt/share/man \
		datadir=$(QEMU_IPK_DIR)/opt/share/qemu \
		docdir=$(QEMU_IPK_DIR)/opt/share/doc/qemu \
		install
	$(STRIP_COMMAND) $(QEMU_IPK_DIR)/opt/bin/*
	$(MAKE) $(QEMU_IPK_DIR)/CONTROL/control
	#echo $(QEMU_CONFFILES) | sed -e 's/ /\n/g' > $(QEMU_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(QEMU_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
qemu-ipk: $(QEMU_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
qemu-clean:
	-$(MAKE) -C $(QEMU_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
qemu-dirclean:
	rm -rf $(BUILD_DIR)/$(QEMU_DIR) $(QEMU_BUILD_DIR) $(QEMU_IPK_DIR) $(QEMU_IPK)
