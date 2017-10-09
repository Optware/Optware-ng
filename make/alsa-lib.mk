###########################################################
#
# alsa-lib
#
###########################################################

# You must replace "alsa-lib" and "ALSA-LIB" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ALSA-LIB_VERSION, ALSA-LIB_SITE and ALSA-LIB_SOURCE define
# the upstream location of the source code for the package.
# ALSA-LIB_DIR is the directory which is created when the source
# archive is unpacked.
# ALSA-LIB_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
ALSA-LIB_SITE=ftp://ftp.alsa-project.org/pub/lib
ALSA-LIB_VERSION=1.0.29
ALSA-LIB_SOURCE=alsa-lib-$(ALSA-LIB_VERSION).tar.bz2
ALSA-LIB_DIR=alsa-lib-$(ALSA-LIB_VERSION)
ALSA-LIB_UNZIP=bzcat
ALSA-LIB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ALSA-LIB_DESCRIPTION=ALSA sound library
ALSA-LIB_SECTION=libs
ALSA-LIB_PRIORITY=optional
ALSA-LIB_DEPENDS=
ALSA-LIB_SUGGESTS=
ALSA-LIB_CONFLICTS=


#
# ALSA-LIB_IPK_VERSION should be incremented when the ipk changes.
#
ALSA-LIB_IPK_VERSION=2

#
# ALSA-LIB_CONFFILES should be a list of user-editable files
ALSA-LIB_CONFFILES=

#
# ALSA-LIB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ALSA-LIB_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ALSA-LIB_CPPFLAGS=
ALSA-LIB_LDFLAGS=

#
# ALSA-LIB_BUILD_DIR is the directory in which the build is done.
# ALSA-LIB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ALSA-LIB_IPK_DIR is the directory in which the ipk is built.
# ALSA-LIB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ALSA-LIB_BUILD_DIR=$(BUILD_DIR)/alsa-lib
ALSA-LIB_SOURCE_DIR=$(SOURCE_DIR)/alsa-lib
ALSA-LIB_IPK_DIR=$(BUILD_DIR)/alsa-lib-$(ALSA-LIB_VERSION)-ipk
ALSA-LIB_IPK=$(BUILD_DIR)/alsa-lib_$(ALSA-LIB_VERSION)-$(ALSA-LIB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: alsa-lib-source alsa-lib-unpack alsa-lib alsa-lib-stage alsa-lib-ipk alsa-lib-clean alsa-lib-dirclean alsa-lib-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ALSA-LIB_SOURCE):
	$(WGET) -P $(DL_DIR) $(ALSA-LIB_SITE)/$(ALSA-LIB_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
alsa-lib-source: $(DL_DIR)/$(ALSA-LIB_SOURCE) $(ALSA-LIB_PATCHES)

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
$(ALSA-LIB_BUILD_DIR)/.configured: $(DL_DIR)/$(ALSA-LIB_SOURCE) $(ALSA-LIB_PATCHES) make/alsa-lib.mk
	rm -rf $(BUILD_DIR)/$(ALSA-LIB_DIR) $(ALSA-LIB_BUILD_DIR)
	$(ALSA-LIB_UNZIP) $(DL_DIR)/$(ALSA-LIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(ALSA-LIB_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(ALSA-LIB_DIR) -p1
	mv $(BUILD_DIR)/$(ALSA-LIB_DIR) $(ALSA-LIB_BUILD_DIR)
	(cd $(ALSA-LIB_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ALSA-LIB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ALSA-LIB_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--disable-python \
	)
	touch $(ALSA-LIB_BUILD_DIR)/.configured

alsa-lib-unpack: $(ALSA-LIB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ALSA-LIB_BUILD_DIR)/.built: $(ALSA-LIB_BUILD_DIR)/.configured
	rm -f $(ALSA-LIB_BUILD_DIR)/.built
	$(MAKE) -C $(ALSA-LIB_BUILD_DIR) -j 1
	touch $(ALSA-LIB_BUILD_DIR)/.built

#
# This is the build convenience target.
#
alsa-lib: $(ALSA-LIB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ALSA-LIB_BUILD_DIR)/.staged: $(ALSA-LIB_BUILD_DIR)/.built
	rm -f $(ALSA-LIB_BUILD_DIR)/.staged
	$(MAKE) -C $(ALSA-LIB_BUILD_DIR) DESTDIR=$(STAGING_DIR) install -j 1
	rm -f $(STAGING_LIB_DIR)/libasound.la $(STAGING_LIB_DIR)/alsa-lib/smixer/*.la
	touch $(ALSA-LIB_BUILD_DIR)/.staged

alsa-lib-stage: $(ALSA-LIB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/alsa-lib
#
$(ALSA-LIB_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: alsa-lib" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ALSA-LIB_PRIORITY)" >>$@
	@echo "Section: $(ALSA-LIB_SECTION)" >>$@
	@echo "Version: $(ALSA-LIB_VERSION)-$(ALSA-LIB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ALSA-LIB_MAINTAINER)" >>$@
	@echo "Source: $(ALSA-LIB_SITE)/$(ALSA-LIB_SOURCE)" >>$@
	@echo "Description: $(ALSA-LIB_DESCRIPTION)" >>$@
	@echo "Depends: $(ALSA-LIB_DEPENDS)" >>$@
	@echo "Suggests: $(ALSA-LIB_SUGGESTS)" >>$@
	@echo "Conflicts: $(ALSA-LIB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ALSA-LIB_IPK_DIR)$(TARGET_PREFIX)/sbin or $(ALSA-LIB_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ALSA-LIB_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(ALSA-LIB_IPK_DIR)$(TARGET_PREFIX)/etc/alsa-lib/...
# Documentation files should be installed in $(ALSA-LIB_IPK_DIR)$(TARGET_PREFIX)/doc/alsa-lib/...
# Daemon startup scripts should be installed in $(ALSA-LIB_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??alsa-lib
#
# You may need to patch your application to make it use these locations.
#
$(ALSA-LIB_IPK): $(ALSA-LIB_BUILD_DIR)/.built
	rm -rf $(ALSA-LIB_IPK_DIR) $(BUILD_DIR)/alsa-lib_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ALSA-LIB_BUILD_DIR) DESTDIR=$(ALSA-LIB_IPK_DIR) install-strip -j 1
	$(MAKE) $(ALSA-LIB_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 644 $(ALSA-LIB_SOURCE_DIR)/control $(ALSA-LIB_IPK_DIR)/CONTROL/control
	echo $(ALSA-LIB_CONFFILES) | sed -e 's/ /\n/g' > $(ALSA-LIB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ALSA-LIB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
alsa-lib-ipk: $(ALSA-LIB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
alsa-lib-clean:
	rm -f $(ALSA-LIB_BUILD_DIR)/.built
	-$(MAKE) -C $(ALSA-LIB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
alsa-lib-dirclean:
	rm -rf $(BUILD_DIR)/$(ALSA-LIB_DIR) $(ALSA-LIB_BUILD_DIR) $(ALSA-LIB_IPK_DIR) $(ALSA-LIB_IPK)
#
#
# Some sanity check for the package.
#
alsa-lib-check: $(ALSA-LIB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^

