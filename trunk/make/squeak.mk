###########################################################
#
# squeak
#
###########################################################

#
# SQUEAK_VERSION, SQUEAK_SITE and SQUEAK_VM_SRC define
# the upstream location of the source code for the package.
# SQUEAK_DIR is the directory which is created when the source
# archive is unpacked.
# SQUEAK_UNZIP is the command used to unzip the source.
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
SQUEAK_SITE=http://www.squeakvm.org/unix/release/
SQUEAK_VERSION_MAJOR_MINOR=3.9
SQUEAK_VERSION=3.9.9
SQUEAK_VM_VERSION=$(SQUEAK_VERSION_MAJOR_MINOR)-9
SQUEAK_VM_SRC=Squeak-$(SQUEAK_VM_VERSION).src.tar.gz
SQUEAK_DIR=Squeak-$(SQUEAK_VM_VERSION)
SQUEAK_UNZIP=zcat
SQUEAK_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
SQUEAK_DESCRIPTION=Squeak is a full-featured implementation of the Smalltalk programming language and environment.
SQUEAK_SECTION=lang
SQUEAK_PRIORITY=optional
SQUEAK_DEPENDS=
SQUEAK_SUGGESTS=
SQUEAK_CONFLICTS=

#
# SQUEAK_IPK_VERSION should be incremented when the ipk changes.
#
SQUEAK_IPK_VERSION=2

#
# SQUEAK_CONFFILES should be a list of user-editable files
#SQUEAK_CONFFILES=/opt/etc/squeak.conf /opt/etc/init.d/SXXsqueak

#
# SQUEAK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(HOSTCC), $(TARGET_CC))
ifeq ($(OPTWARE_TARGET),nslu2)
SQUEAK_PATCHES=$(SQUEAK_SOURCE_DIR)/configure.ac-$(OPTWARE_TARGET).patch \
	$(SQUEAK_SOURCE_DIR)/Makefile.in-cross.patch
else
SQUEAK_PATCHES=$(SQUEAK_SOURCE_DIR)/configure.ac-cross.patch \
	$(SQUEAK_SOURCE_DIR)/Makefile.in-cross.patch \
	$(SQUEAK_SOURCE_DIR)/sqUnixMain.c.patch
endif
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SQUEAK_CPPFLAGS=-O3
ifeq ($(NO_BUILTIN_MATH), true)
SQUEAK_CPPFLAGS+= -fno-builtin-cos -fno-builtin-exp -fno-builtin-sin
endif
SQUEAK_LDFLAGS=

#
# SQUEAK_BUILD_DIR is the directory in which the build is done.
# SQUEAK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SQUEAK_IPK_DIR is the directory in which the ipk is built.
# SQUEAK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SQUEAK_BUILD_DIR=$(BUILD_DIR)/squeak
SQUEAK_SOURCE_DIR=$(SOURCE_DIR)/squeak
SQUEAK_IPK_DIR=$(BUILD_DIR)/squeak-$(SQUEAK_VERSION)-ipk
SQUEAK_IPK=$(BUILD_DIR)/squeak_$(SQUEAK_VERSION)-$(SQUEAK_IPK_VERSION)_$(TARGET_ARCH).ipk

SQUEAK_IMG_SRC_SITE=http://ftp.squeak.org/sources_files
SQUEAK_IMG_SRC=SqueakV3.sources

.PHONY: squeak-source squeak-unpack squeak squeak-stage squeak-ipk squeak-clean squeak-dirclean squeak-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SQUEAK_VM_SRC):
	$(WGET) -P $(DL_DIR) $(SQUEAK_SITE)/$(SQUEAK_VM_SRC)

$(DL_DIR)/$(SQUEAK_IMG_SRC).gz:
	$(WGET) -P $(DL_DIR) $(SQUEAK_IMG_SRC_SITE)/$(SQUEAK_IMG_SRC).gz

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
squeak-source: $(SQUEAK_PATCHES) $(DL_DIR)/$(SQUEAK_VM_SRC) $(DL_DIR)/$(SQUEAK_IMG_SRC).gz

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(SQUEAK_BUILD_DIR)/.configured: $(DL_DIR)/$(SQUEAK_VM_SRC) $(DL_DIR)/$(SQUEAK_IMG_SRC).gz make/squeak.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SQUEAK_DIR) $(SQUEAK_BUILD_DIR)
	$(SQUEAK_UNZIP) $(DL_DIR)/$(SQUEAK_VM_SRC) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SQUEAK_PATCHES)" ; then \
		cat $(SQUEAK_PATCHES) | patch -bd $(BUILD_DIR)/$(SQUEAK_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(SQUEAK_DIR)" != "$(SQUEAK_BUILD_DIR)" ; then \
		mv $(BUILD_DIR)/$(SQUEAK_DIR) $(SQUEAK_BUILD_DIR) ; \
	fi
	(cd $(SQUEAK_BUILD_DIR)/platforms/unix/config/; \
		./mkacinc > acplugins.m4; \
		aclocal; \
		autoconf; \
		rm acplugins.m4; \
	)
	mkdir -p $(SQUEAK_BUILD_DIR)/bld
	(cd $(SQUEAK_BUILD_DIR)/bld; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SQUEAK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SQUEAK_LDFLAGS)" \
		../platforms/unix/config/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-rfb \
		--without-x \
		--without-ffi \
		--without-npsqueak \
	)
	$(PATCH_LIBTOOL) $(SQUEAK_BUILD_DIR)/bld/libtool
	sed -i -e 's/clone/_clone_/g' \
		$(SQUEAK_BUILD_DIR)/platforms/unix/src/vm/interp.c \
		$(SQUEAK_BUILD_DIR)/platforms/Cross/vm/sqVirtualMachine.* \
		$(SQUEAK_BUILD_DIR)/platforms/unix/src/vm/intplugins/CroquetPlugin/CroquetPlugin.c \
		$(SQUEAK_BUILD_DIR)/platforms/unix/src/plugins/Squeak3D/Squeak3D.c
	touch $(SQUEAK_BUILD_DIR)/.configured

squeak-unpack: $(SQUEAK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SQUEAK_BUILD_DIR)/.built: $(SQUEAK_BUILD_DIR)/.configured
	rm -f $(SQUEAK_BUILD_DIR)/.built
	$(MAKE) -C $(SQUEAK_BUILD_DIR)/bld
	touch $(SQUEAK_BUILD_DIR)/.built

#
# This is the build convenience target.
#
squeak: $(SQUEAK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SQUEAK_BUILD_DIR)/.staged: $(SQUEAK_BUILD_DIR)/.built
	rm -f $(SQUEAK_BUILD_DIR)/.staged
	$(MAKE) -C $(SQUEAK_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SQUEAK_BUILD_DIR)/.staged

squeak-stage: $(SQUEAK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/squeak
#
$(SQUEAK_IPK_DIR)/CONTROL/control:
	@install -d $(SQUEAK_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: squeak" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SQUEAK_PRIORITY)" >>$@
	@echo "Section: $(SQUEAK_SECTION)" >>$@
	@echo "Version: $(SQUEAK_VERSION)-$(SQUEAK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SQUEAK_MAINTAINER)" >>$@
	@echo "Source: $(SQUEAK_SITE)/$(SQUEAK_VM_SRC)" >>$@
	@echo "Description: $(SQUEAK_DESCRIPTION)" >>$@
	@echo "Depends: $(SQUEAK_DEPENDS)" >>$@
	@echo "Suggests: $(SQUEAK_SUGGESTS)" >>$@
	@echo "Conflicts: $(SQUEAK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SQUEAK_IPK_DIR)/opt/sbin or $(SQUEAK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SQUEAK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SQUEAK_IPK_DIR)/opt/etc/squeak/...
# Documentation files should be installed in $(SQUEAK_IPK_DIR)/opt/doc/squeak/...
# Daemon startup scripts should be installed in $(SQUEAK_IPK_DIR)/opt/etc/init.d/S??squeak
#
# You may need to patch your application to make it use these locations.
#
$(SQUEAK_IPK): $(SQUEAK_BUILD_DIR)/.built
	rm -rf $(SQUEAK_IPK_DIR) $(BUILD_DIR)/squeak_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SQUEAK_BUILD_DIR)/bld ROOT=$(SQUEAK_IPK_DIR) install
	$(STRIP_COMMAND) $(SQUEAK_IPK_DIR)/opt/lib/squeak/$(SQUEAK_VM_VERSION)/*
	install -m 755 $(SQUEAK_BUILD_DIR)/bld/inisqueak  $(SQUEAK_IPK_DIR)/opt/bin/
	$(SQUEAK_UNZIP) $(DL_DIR)/$(SQUEAK_IMG_SRC).gz > $(SQUEAK_IPK_DIR)/opt/lib/squeak/$(SQUEAK_IMG_SRC)
#	install -d $(SQUEAK_IPK_DIR)/opt/etc/
#	install -m 644 $(SQUEAK_SOURCE_DIR)/squeak.conf $(SQUEAK_IPK_DIR)/opt/etc/squeak.conf
#	install -d $(SQUEAK_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SQUEAK_SOURCE_DIR)/rc.squeak $(SQUEAK_IPK_DIR)/opt/etc/init.d/SXXsqueak
	$(MAKE) $(SQUEAK_IPK_DIR)/CONTROL/control
	install -m 755 $(SQUEAK_SOURCE_DIR)/postinst $(SQUEAK_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SQUEAK_SOURCE_DIR)/prerm $(SQUEAK_IPK_DIR)/CONTROL/prerm
	echo $(SQUEAK_CONFFILES) | sed -e 's/ /\n/g' > $(SQUEAK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SQUEAK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
squeak-ipk: $(SQUEAK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
squeak-clean:
	rm -f $(SQUEAK_BUILD_DIR)/.built
	-$(MAKE) -C $(SQUEAK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
squeak-dirclean:
	rm -rf $(BUILD_DIR)/$(SQUEAK_DIR) $(SQUEAK_BUILD_DIR) $(SQUEAK_IPK_DIR) $(SQUEAK_IPK)

#
# Some sanity check for the package.
#
squeak-check: $(SQUEAK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SQUEAK_IPK)
