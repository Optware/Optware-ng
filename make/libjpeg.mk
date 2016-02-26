###########################################################
#
# libjpeg
#
###########################################################

# You must replace "libjpeg" and "LIBJPEG" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBJPEG_VERSION, LIBJPEG_SITE and LIBJPEG_SOURCE define
# the upstream location of the source code for the package.
# LIBJPEG_DIR is the directory which is created when the source
# archive is unpacked.
# LIBJPEG_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBJPEG_SITE=http://www.ijg.org/files
LIBJPEG_VERSION=8d
LIBJPEG_SOURCE=jpegsrc.v$(LIBJPEG_VERSION).tar.gz
LIBJPEG_DIR=jpeg-$(LIBJPEG_VERSION)
LIBJPEG_UNZIP=zcat
LIBJPEG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBJPEG_DESCRIPTION=collection of jpeg tools
LIBJPEG_SECTION=net
LIBJPEG_PRIORITY=optional
LIBJPEG_DEPENDS=
LIBJPEG_CONFLICTS=

#
# LIBJPEG_IPK_VERSION should be incremented when the ipk changes.
#
LIBJPEG_IPK_VERSION=2

#
# LIBJPEG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBJPEG_PATCHES=$(LIBJPEG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBJPEG_CPPFLAGS=
LIBJPEG_LDFLAGS=

#
# LIBJPEG_BUILD_DIR is the directory in which the build is done.
# LIBJPEG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBJPEG_IPK_DIR is the directory in which the ipk is built.
# LIBJPEG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBJPEG_BUILD_DIR=$(BUILD_DIR)/libjpeg
LIBJPEG_SOURCE_DIR=$(SOURCE_DIR)/libjpeg
LIBJPEG_IPK_DIR=$(BUILD_DIR)/libjpeg-$(LIBJPEG_VERSION)-ipk
LIBJPEG_IPK=$(BUILD_DIR)/libjpeg_$(LIBJPEG_VERSION)-$(LIBJPEG_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBJPEG_SOURCE):
	$(WGET) -P $(@D) $(LIBJPEG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libjpeg-source: $(DL_DIR)/$(LIBJPEG_SOURCE) $(LIBJPEG_PATCHES)

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
$(LIBJPEG_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBJPEG_SOURCE) $(LIBJPEG_PATCHES) make/libjpeg.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -f	$(STAGING_INCLUDE_DIR)/jconfig.h \
		$(STAGING_INCLUDE_DIR)/jerror.h \
		$(STAGING_INCLUDE_DIR)/jpeglib.h \
		$(STAGING_INCLUDE_DIR)/jmorecfg.h \
		$(STAGING_LIB_DIR)/libjpeg*so*
	rm -rf $(BUILD_DIR)/$(LIBJPEG_DIR) $(@D)
	$(LIBJPEG_UNZIP) $(DL_DIR)/$(LIBJPEG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBJPEG_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(LIBJPEG_DIR) -p1
	mv $(BUILD_DIR)/$(LIBJPEG_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBJPEG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBJPEG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--enable-shared \
		--disable-static \
		--prefix=$(TARGET_PREFIX) \
		--program-transform-name='s/^//' \
	)
	touch $@

libjpeg-unpack: $(LIBJPEG_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBJPEG_BUILD_DIR)/.built: $(LIBJPEG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libjpeg: $(LIBJPEG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBJPEG_BUILD_DIR)/.staged: $(LIBJPEG_BUILD_DIR)/.built
	rm -f $@
	$(INSTALL) -d $(STAGING_INCLUDE_DIR)
	$(INSTALL) -d $(STAGING_LIB_DIR)
	$(INSTALL) -d $(STAGING_PREFIX)/bin
	$(INSTALL) -d $(STAGING_PREFIX)/man/man1
	$(MAKE) -C $(@D) prefix=$(STAGING_PREFIX) install
	rm -f $(STAGING_LIB_DIR)/libjpeg.la
	touch $@

libjpeg-stage: $(LIBJPEG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libjpeg
#
$(LIBJPEG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libjpeg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBJPEG_PRIORITY)" >>$@
	@echo "Section: $(LIBJPEG_SECTION)" >>$@
	@echo "Version: $(LIBJPEG_VERSION)-$(LIBJPEG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBJPEG_MAINTAINER)" >>$@
	@echo "Source: $(LIBJPEG_SITE)/$(LIBJPEG_SOURCE)" >>$@
	@echo "Description: $(LIBJPEG_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBJPEG_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBJPEG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBJPEG_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBJPEG_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBJPEG_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBJPEG_IPK_DIR)$(TARGET_PREFIX)/etc/libjpeg/...
# Documentation files should be installed in $(LIBJPEG_IPK_DIR)$(TARGET_PREFIX)/doc/libjpeg/...
# Daemon startup scripts should be installed in $(LIBJPEG_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libjpeg
#
# You may need to patch your application to make it use these locations.
#
$(LIBJPEG_IPK): $(LIBJPEG_BUILD_DIR)/.built
	rm -rf $(LIBJPEG_IPK_DIR) $(BUILD_DIR)/libjpeg_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBJPEG_BUILD_DIR) prefix=$(LIBJPEG_IPK_DIR)$(TARGET_PREFIX) install
	rm -f $(LIBJPEG_IPK_DIR)$(TARGET_PREFIX)/lib/libjpeg.la
	$(STRIP_COMMAND) 	$(LIBJPEG_IPK_DIR)$(TARGET_PREFIX)/bin/* \
				$(LIBJPEG_IPK_DIR)$(TARGET_PREFIX)/lib/*.so
#	$(INSTALL) -d $(LIBJPEG_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBJPEG_SOURCE_DIR)/rc.libjpeg $(LIBJPEG_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibjpeg
	$(MAKE) $(LIBJPEG_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 644 $(LIBJPEG_SOURCE_DIR)/postinst $(LIBJPEG_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 644 $(LIBJPEG_SOURCE_DIR)/prerm $(LIBJPEG_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBJPEG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libjpeg-ipk: $(LIBJPEG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libjpeg-clean:
	-$(MAKE) -C $(LIBJPEG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libjpeg-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBJPEG_DIR) $(LIBJPEG_BUILD_DIR) $(LIBJPEG_IPK_DIR) $(LIBJPEG_IPK)

#
# Some sanity check for the package.
#
libjpeg-check: $(LIBJPEG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
