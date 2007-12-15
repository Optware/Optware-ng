###########################################################
#
# syx
#
###########################################################
#
# SYX_VERSION, SYX_SITE and SYX_SOURCE define
# the upstream location of the source code for the package.
# SYX_DIR is the directory which is created when the source
# archive is unpacked.
# SYX_UNZIP is the command used to unzip the source.
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
SYX_SITE=http://syx.googlecode.com/files
SYX_VERSION=0.1.5
SYX_SOURCE=syx-$(SYX_VERSION).tar.gz
SYX_DIR=syx-$(SYX_VERSION)
SYX_UNZIP=zcat
SYX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SYX_DESCRIPTION=Smalltalk YX is an open source Smalltalk-80 implementation.
SYX_SECTION=lang
SYX_PRIORITY=optional
SYX_DEPENDS=libgmp
SYX_SUGGESTS=
SYX_CONFLICTS=

#
# SYX_IPK_VERSION should be incremented when the ipk changes.
#
SYX_IPK_VERSION=1

#
# SYX_CONFFILES should be a list of user-editable files
#SYX_CONFFILES=/opt/etc/syx.conf /opt/etc/init.d/SXXsyx

#
# SYX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SYX_PATCHES=$(SYX_SOURCE_DIR)/SConstruct-cross.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SYX_CPPFLAGS=
SYX_LDFLAGS=

#
# SYX_BUILD_DIR is the directory in which the build is done.
# SYX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SYX_IPK_DIR is the directory in which the ipk is built.
# SYX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SYX_SOURCE_DIR=$(SOURCE_DIR)/syx

SYX_BUILD_DIR=$(BUILD_DIR)/syx
SYX_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/syx

SYX_IPK_DIR=$(BUILD_DIR)/syx-$(SYX_VERSION)-ipk
SYX_IPK=$(BUILD_DIR)/syx_$(SYX_VERSION)-$(SYX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: syx-source syx-unpack syx syx-stage syx-ipk syx-clean syx-dirclean syx-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SYX_SOURCE):
	$(WGET) -P $(DL_DIR) $(SYX_SITE)/$(SYX_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SYX_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
syx-source: $(DL_DIR)/$(SYX_SOURCE) $(SYX_PATCHES)

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
$(SYX_BUILD_DIR)/.configured: $(DL_DIR)/$(SYX_SOURCE) $(SYX_PATCHES) make/syx.mk
	$(MAKE) scons-host-stage
	$(MAKE) libgmp-stage
	rm -rf $(BUILD_DIR)/$(SYX_DIR) $(SYX_BUILD_DIR)
	$(SYX_UNZIP) $(DL_DIR)/$(SYX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SYX_PATCHES)" ; \
		then cat $(SYX_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(SYX_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SYX_DIR)" != "$(SYX_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SYX_DIR) $(SYX_BUILD_DIR) ; \
	fi
	sed -i.orig \
	    -e '/bimage *=/{s|$$SOURCE |LD_LIBRARY_PATH=$(SYX_HOST_BUILD_DIR)/build/lib $$SOURCE |; s| prog,| "$(SYX_HOST_BUILD_DIR)/build/bin/syx",|}' \
		$(SYX_BUILD_DIR)/src/SConscript
ifeq (mss, $(OPTWARE_TARGET))
	sed -i.orig -e 's|-Wno-strict-aliasing ||' $(SYX_BUILD_DIR)/SConstruct
endif
#	(cd $(SYX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SYX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SYX_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

syx-unpack: $(SYX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SYX_BUILD_DIR)/.built: $(SYX_BUILD_DIR)/.configured
	rm -f $@
	if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/endianness.c | grep -q puts.*BIG_ENDIAN; \
	then ENDIANNESS=big; \
	else ENDIANNESS=little; fi; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SYX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SYX_LDFLAGS)" \
	$(HOST_STAGING_PREFIX)/bin/scons \
		-C $(SYX_BUILD_DIR) \
		prefix=/opt \
		GTK=false \
		host=`echo $(TARGET_CROSS) | sed 's/-$$//'` \
		endianness=$$ENDIANNESS \
		;
	touch $@

#
# This is the build convenience target.
#
syx: $(SYX_BUILD_DIR)/.built

$(SYX_HOST_BUILD_DIR)/.built: host/.configured make/syx.mk
	$(MAKE) scons-host-stage
	rm -f $@
	rm -rf $(HOST_BUILD_DIR)/$(SYX_DIR) $(SYX_HOST_BUILD_DIR)
	$(SYX_UNZIP) $(DL_DIR)/$(SYX_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(SYX_DIR)" != "$(SYX_HOST_BUILD_DIR)" ; \
		then mv $(HOST_BUILD_DIR)/$(SYX_DIR) $(SYX_HOST_BUILD_DIR) ; \
	fi
	$(HOST_STAGING_PREFIX)/bin/scons \
		-C $(SYX_HOST_BUILD_DIR) \
		prefix=/opt \
		GTK=false \
		;
	touch $@

syx-host: $(SYX_HOST_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SYX_BUILD_DIR)/.staged: $(SYX_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(SYX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

syx-stage: $(SYX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/syx
#
$(SYX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: syx" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SYX_PRIORITY)" >>$@
	@echo "Section: $(SYX_SECTION)" >>$@
	@echo "Version: $(SYX_VERSION)-$(SYX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SYX_MAINTAINER)" >>$@
	@echo "Source: $(SYX_SITE)/$(SYX_SOURCE)" >>$@
	@echo "Description: $(SYX_DESCRIPTION)" >>$@
	@echo "Depends: $(SYX_DEPENDS)" >>$@
	@echo "Suggests: $(SYX_SUGGESTS)" >>$@
	@echo "Conflicts: $(SYX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SYX_IPK_DIR)/opt/sbin or $(SYX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SYX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SYX_IPK_DIR)/opt/etc/syx/...
# Documentation files should be installed in $(SYX_IPK_DIR)/opt/doc/syx/...
# Daemon startup scripts should be installed in $(SYX_IPK_DIR)/opt/etc/init.d/S??syx
#
# You may need to patch your application to make it use these locations.
#
$(SYX_IPK): $(SYX_BUILD_DIR)/.built
	$(MAKE) syx-host
	rm -rf $(SYX_IPK_DIR) $(BUILD_DIR)/syx_*_$(TARGET_ARCH).ipk
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SYX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SYX_LDFLAGS)" \
	$(HOST_STAGING_PREFIX)/bin/scons \
		-C $(SYX_BUILD_DIR) \
		prefix=/opt \
		GTK=false \
		bdist
	install -d $(SYX_IPK_DIR)
	cp -rp $(SYX_BUILD_DIR)/syx-$(SYX_VERSION)/opt $(SYX_IPK_DIR)/
	rm -f $(SYX_IPK_DIR)/opt/lib/libsyx.a
	$(STRIP_COMMAND) $(SYX_IPK_DIR)/opt/lib/libsyx.so $(SYX_IPK_DIR)/opt/bin/syx
	$(MAKE) $(SYX_IPK_DIR)/CONTROL/control
	echo $(SYX_CONFFILES) | sed -e 's/ /\n/g' > $(SYX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SYX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
syx-ipk: $(SYX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
syx-clean:
	rm -f $(SYX_BUILD_DIR)/.built
	-$(MAKE) -C $(SYX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
syx-dirclean:
	rm -rf $(BUILD_DIR)/$(SYX_DIR) $(SYX_BUILD_DIR) $(SYX_IPK_DIR) $(SYX_IPK)
#
#
# Some sanity check for the package.
#
syx-check: $(SYX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SYX_IPK)
