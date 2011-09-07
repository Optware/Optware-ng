###########################################################
#
# xvid
#
###########################################################

#
# XVID_VERSION, XVID_REPOSITORY and XVID_SOURCE define
# the upstream location of the source code for the package.
# XVID_DIR is the directory which is created when the source
# archive is unpacked.
# XVID_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
XVID_SITE=http://downloads.xvid.org/downloads
XVID_VERSION=1.3.2
XVID_LIB_VER=4.3
XVID_SOURCE=xvidcore-$(XVID_VERSION).tar.bz2
#XVID_REPOSITORY=:pserver:anonymous@cvs.xvid.org:/xvid
#XVID_TAG=-D 2006-12-26
XVID_MODULE=xvidcore
XVID_DIR=xvidcore
XVID_UNZIP=bzcat
XVID_MAINTAINER=Keith Garry Boyce <nslu2-linux@yahoogroups.com>
XVID_DESCRIPTION=Xvid is MPEG4 codec
XVID_SECTION=tool
XVID_PRIORITY=optional
XVID_DEPENDS=
XVID_CONFLICTS=

#
# XVID_IPK_VERSION should be incremented when the ipk changes.
#
XVID_IPK_VERSION=1

#
# XVID_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XVID_PATCHES=$(XVID_SOURCE_DIR)/configure.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XVID_CPPFLAGS=
XVID_LDFLAGS=

#
# XVID_BUILD_DIR is the directory in which the build is done.
# XVID_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XVID_IPK_DIR is the directory in which the ipk is built.
# XVID_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XVID_BUILD_DIR=$(BUILD_DIR)/xvid
XVID_SOURCE_DIR=$(SOURCE_DIR)/xvid
XVID_IPK_DIR=$(BUILD_DIR)/xvid-$(XVID_VERSION)-ipk
XVID_IPK=$(BUILD_DIR)/xvid_$(XVID_VERSION)-$(XVID_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from cvs.
#
$(DL_DIR)/$(XVID_SOURCE):
ifdef XVID_REPOSITORY
	cd $(DL_DIR) ; $(CVS) -z3 -d $(XVID_REPOSITORY) co $(XVID_TAG) $(XVID_MODULE)
	mv $(DL_DIR)/$(XVID_MODULE) $(DL_DIR)/$(XVID_DIR)
	cd $(DL_DIR) ; tar zcvf $(XVID_SOURCE) $(XVID_DIR)
	rm -rf $(DL_DIR)/$(XVID_DIR)
else
	$(WGET) -P $(@D) $(XVID_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

.PHONY: xvid-source xvid-unpack xvid xvid-stage xvid-ipk xvid-clean xvid-dirclean xvid-check


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xvid-source: $(DL_DIR)/$(XVID_SOURCE) $(XVID_PATCHES)

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
$(XVID_BUILD_DIR)/.configured: $(DL_DIR)/$(XVID_SOURCE) $(XVID_PATCHES) make/xvid.mk
	rm -rf $(BUILD_DIR)/$(XVID_DIR) $(@D)
	$(XVID_UNZIP) $(DL_DIR)/$(XVID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(XVID_PATCHES)"; then \
	    cat $(XVID_PATCHES) | patch -d $(BUILD_DIR)/$(XVID_DIR) -p1; \
	fi
	if test "$(BUILD_DIR)/$(XVID_DIR)" != "$(@D)" ; then \
	    mv $(BUILD_DIR)/$(XVID_DIR) $(@D); \
	fi
	(cd $(@D)/build/generic; \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./bootstrap.sh; \
	)
	sed -i \
	    -e 's:`./gcc-ver M`:'"`$(TARGET_CC) -dumpversion | cut -d. -f1`:" \
	    -e 's:`./gcc-ver m`:'"`$(TARGET_CC) -dumpversion | cut -d. -f2`:" \
	    $(@D)/build/generic/configure
	(cd $(@D)/build/generic; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XVID_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XVID_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
		--enable-shared \
	)
	touch $@

xvid-unpack: $(XVID_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(XVID_BUILD_DIR)/.built: $(XVID_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/build/generic
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
xvid: $(XVID_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XVID_BUILD_DIR)/.staged: $(XVID_BUILD_DIR)/.built
	rm -f $@
	rm -f $(STAGING_LIB_DIR)/libxvid*
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(@D)/build/generic install
	rm -f $(STAGING_LIB_DIR)/libxvidcore.a
	cd $(STAGING_LIB_DIR) && ln -fs libxvidcore.so.$(XVID_LIB_VER) libxvidcore.so
	touch $@

xvid-stage: $(XVID_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/xvid
# 
$(XVID_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: xvid" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XVID_PRIORITY)" >>$@
	@echo "Section: $(XVID_SECTION)" >>$@
	@echo "Version: $(XVID_VERSION)-$(XVID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XVID_MAINTAINER)" >>$@
ifdef XVID_REPOSITORY
	@echo "Source: $(XVID_REPOSITORY)" >>$@
else
	@echo "Source: $(XVID_SOURCE)" >>$@
endif
	@echo "Description: $(XVID_DESCRIPTION)" >>$@
	@echo "Depends: $(XVID_DEPENDS)" >>$@
	@echo "Conflicts: $(XVID_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(XVID_IPK_DIR)/opt/sbin or $(XVID_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XVID_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XVID_IPK_DIR)/opt/etc/xvid/...
# Documentation files should be installed in $(XVID_IPK_DIR)/opt/doc/xvid/...
# Daemon startup scripts should be installed in $(XVID_IPK_DIR)/opt/etc/init.d/S??xvid
#
# You may need to patch your application to make it use these locations.
#
$(XVID_IPK): $(XVID_BUILD_DIR)/.built
	rm -rf $(XVID_IPK_DIR) $(BUILD_DIR)/xvid_*_$(TARGET_ARCH).ipk
	$(MAKE) DESTDIR=$(XVID_IPK_DIR) -C $(XVID_BUILD_DIR)/build/generic install
	rm -f $(XVID_IPK_DIR)/opt/lib/libxvidcore.a
	$(STRIP_COMMAND) $(XVID_IPK_DIR)/opt/lib/libxvidcore.so.$(XVID_LIB_VER)
	ln -s $(XVID_IPK_DIR)/opt/lib/libxvidcore.so.$(XVID_LIB_VER) $(XVID_IPK_DIR)/opt/lib/libxvidcore.so
	$(MAKE) $(XVID_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XVID_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xvid-ipk: $(XVID_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xvid-clean:
	-$(MAKE) -C $(XVID_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xvid-dirclean:
	rm -rf $(BUILD_DIR)/$(XVID_DIR) $(XVID_BUILD_DIR) $(XVID_IPK_DIR) $(XVID_IPK)
#
#
# Some sanity check for the package.
#
xvid-check: $(XVID_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
