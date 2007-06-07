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
QEMU_VERSION=0.8.0
QEMU_SOURCE=qemu-$(QEMU_VERSION).tar.gz
QEMU_DIR=qemu-$(QEMU_VERSION)
QEMU_UNZIP=zcat
QEMU_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
QEMU_DESCRIPTION=A portable machine emulator.
QEMU_SECTION=misc
QEMU_PRIORITY=optional
QEMU_DEPENDS=zlib
QEMU_SUGGESTS=kernel-module-binfmt-misc
QEMU_CONFLICTS=

QEMU_CPU=$(strip \
	$(if $(filter armeb, $(TARGET_ARCH)), armv4b, \
	$(if $(filter arm, $(TARGET_ARCH)), armv4l, \
	$(if $(filter mips mipsel, $(TARGET_ARCH)), mips, \
	$(TARGET_ARCH)))))

QEMU_TARGET_LIST=i386-user i386-softmmu

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
QEMU_PATCHES=$(QEMU_SOURCE_DIR)/arm-build-fixes.patch $(QEMU_SOURCE_DIR)/arm-bigendian-host.patch $(QEMU_SOURCE_DIR)/dyngen.patch $(QEMU_SOURCE_DIR)/makefile.patch $(QEMU_SOURCE_DIR)/no-schedule.patch $(QEMU_SOURCE_DIR)/op-gen-label.patch $(QEMU_SOURCE_DIR)/arm-timer.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
QEMU_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/SDL #-g -DDEBUG_EXEC -DDEBUG_MMAP
QEMU_LDFLAGS=#-g

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
QEMU_USER_IPK_DIR=$(BUILD_DIR)/qemu-user-$(QEMU_VERSION)-ipk
QEMU_USER_IPK=$(BUILD_DIR)/qemu-user_$(QEMU_VERSION)-$(QEMU_IPK_VERSION)_$(TARGET_ARCH).ipk

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
	$(MAKE) sdl-stage
	rm -rf $(BUILD_DIR)/$(QEMU_DIR) $(QEMU_BUILD_DIR)
	$(QEMU_UNZIP) $(DL_DIR)/$(QEMU_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(QEMU_PATCHES) | patch -d $(BUILD_DIR)/$(QEMU_DIR) -p1
	mv $(BUILD_DIR)/$(QEMU_DIR) $(QEMU_BUILD_DIR)
	(cd $(QEMU_BUILD_DIR); \
		./configure \
		--cross-prefix=$(TARGET_CROSS) \
		--extra-cflags="$(STAGING_CPPFLAGS) $(QEMU_CPPFLAGS)" \
		--extra-ldflags="$(STAGING_LDFLAGS) $(QEMU_LDFLAGS)" \
		--cpu=$(QEMU_CPU) \
		--make="$(MAKE)" \
		--prefix=/opt \
		--interp-prefix=/opt/lib/gnemul/qemu-%M \
		--target-list="$(QEMU_TARGET_LIST)" \
		--disable-gfx-check \
	)
	sed -i -e 's%/tmp/qemu.log%/opt/tmp/qemu.log%' $(QEMU_BUILD_DIR)/vl.c $(QEMU_BUILD_DIR)/exec.c $(QEMU_BUILD_DIR)/linux-user/main.c
	echo "CONFIG_SDL=yes" >>$(QEMU_BUILD_DIR)/config-host.mak
	echo "#define CONFIG_SDL 1" >>$(QEMU_BUILD_DIR)/config-host.h
	touch $(QEMU_BUILD_DIR)/.configured

qemu-unpack: $(QEMU_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(QEMU_BUILD_DIR)/.built: $(QEMU_BUILD_DIR)/.configured
	rm -f $(QEMU_BUILD_DIR)/.built
	$(MAKE) -C $(QEMU_BUILD_DIR) HOST_CC=$(HOSTCC) SDL_LIBS=-lSDL
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
	@echo "Depends: $(QEMU_DEPENDS), sdl" >>$@
	@echo "Suggests: $(QEMU_SUGGESTS)" >>$@
	@echo "Conflicts: $(QEMU_CONFLICTS)" >>$@

$(QEMU_USER_IPK_DIR)/CONTROL/control:
	@install -d $(QEMU_USER_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: qemu-user" >>$@
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
$(QEMU_IPK) $(QEMU_USER_IPK): $(QEMU_BUILD_DIR)/.built
	rm -rf $(QEMU_IPK_DIR) $(BUILD_DIR)/qemu_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(QEMU_BUILD_DIR) \
		prefix=$(QEMU_IPK_DIR)/opt \
		bindir=$(QEMU_IPK_DIR)/opt/bin \
		mandir=$(QEMU_IPK_DIR)/opt/share/man \
		datadir=$(QEMU_IPK_DIR)/opt/share/qemu \
		docdir=$(QEMU_IPK_DIR)/opt/share/doc/qemu \
		install
	$(STRIP_COMMAND) $(QEMU_IPK_DIR)/opt/bin/*
	mkdir $(QEMU_IPK_DIR)/opt/tmp
	chmod a+rwxt $(QEMU_IPK_DIR)/opt/tmp
	$(MAKE) $(QEMU_IPK_DIR)/CONTROL/control
	mkdir -p $(QEMU_USER_IPK_DIR)/opt/bin
	mkdir -p $(QEMU_USER_IPK_DIR)/opt/etc/init.d
	for F in $(QEMU_TARGET_LIST) ; \
		do if test -r  $(QEMU_IPK_DIR)/opt/bin/qemu-$${F%-user} ; \
		then mv $(QEMU_IPK_DIR)/opt/bin/qemu-$${F%-user} \
			$(QEMU_USER_IPK_DIR)/opt/bin ; \
		fi ; done
	$(MAKE) $(QEMU_USER_IPK_DIR)/CONTROL/control
	install -m 755 $(QEMU_SOURCE_DIR)/rc.qemu-user \
		$(QEMU_USER_IPK_DIR)/CONTROL/postinst
	install -m 755 $(QEMU_SOURCE_DIR)/rc.qemu-user \
		$(QEMU_USER_IPK_DIR)/opt/etc/init.d/S10qemu-user
	cd $(BUILD_DIR); $(IPKG_BUILD) $(QEMU_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(QEMU_USER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
qemu-ipk: $(QEMU_IPK) $(QEMU_USER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
qemu-clean:
	rm $(QEMU_BUILD_DIR)/.built
	-$(MAKE) -C $(QEMU_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
qemu-dirclean:
	rm -rf $(BUILD_DIR)/$(QEMU_DIR) $(QEMU_BUILD_DIR)
	rm -rf $(QEMU_IPK_DIR) $(QEMU_IPK)
	rm -rf $(QEMU_USER_IPK_DIR) $(QEMU_USER_IPK)

#
# Some sanity check for the package.
#
qemu-check: $(QEMU_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(QEMU_IPK) $(QEMU_USER_IPK)
