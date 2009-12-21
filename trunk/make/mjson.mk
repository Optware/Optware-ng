###########################################################
#
# mjson
#
###########################################################

MJSON_SITE=http://palm.cdnetworks.net/opensource/1.3.1/mjson-1.0.tgz
MJSON_VERSION=1.0
MJSON_SOURCE=mjson-$(MJSON_VERSION).tgz
MJSON_DIR=mjson-$(MJSON_VERSION)
MJSON_UNZIP=zcat
MJSON_MAINTAINER=WebOS Internals <support@webos-internals.org>
MJSON_DESCRIPTION=M\'s JSON parser is a small library completely written in plain ISO C which handles documents described by the JavaScript Object Notation (JSON) data interchange format.  This package is a patched version of mjson used by Palm in webOS.
MJSON_SECTION=lib
MJSON_PRIORITY=optional
MJSON_DEPENDS=
MJSON_SUGGESTS=
MJSON_CONFLICTS=

#
# MJSON_IPK_VERSION should be incremented when the ipk changes.
#
MJSON_IPK_VERSION=1

#
# MJSON_CONFFILES should be a list of user-editable files
#MJSON_CONFFILES=/opt/etc/mjson.conf /opt/etc/init.d/SXXmjson

#
# MJSON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MJSON_PATCHES=$(MJSON_SOURCE_DIR)/mjson-1.0-patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MJSON_CPPFLAGS=
MJSON_LDFLAGS=

#
# MJSON_BUILD_DIR is the directory in which the build is done.
# MJSON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MJSON_IPK_DIR is the directory in which the ipk is built.
# MJSON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MJSON_BUILD_DIR=$(BUILD_DIR)/mjson
MJSON_SOURCE_DIR=$(SOURCE_DIR)/mjson
MJSON_IPK_DIR=$(BUILD_DIR)/mjson-$(MJSON_VERSION)-ipk
MJSON_IPK=$(BUILD_DIR)/mjson_$(MJSON_VERSION)-$(MJSON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mjson-source mjson-unpack mjson mjson-stage mjson-ipk mjson-clean mjson-dirclean mjson-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MJSON_SOURCE):
	$(WGET) -P $(@D) $(MJSON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mjson-source: $(DL_DIR)/$(MJSON_SOURCE) $(MJSON_PATCHES)

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
$(MJSON_BUILD_DIR)/.configured: $(DL_DIR)/$(MJSON_SOURCE) $(MJSON_PATCHES) make/mjson.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MJSON_DIR) $(@D)
	$(MJSON_UNZIP) $(DL_DIR)/$(MJSON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MJSON_PATCHES)" ; \
		then cat $(MJSON_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MJSON_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MJSON_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MJSON_DIR) $(@D) ; \
	fi
	touch $@

mjson-unpack: $(MJSON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MJSON_BUILD_DIR)/.built: $(MJSON_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	CPPFLAGS="$(STAGING_CPPFLAGS) $(MJSON_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(MJSON_LDFLAGS)" \
	CUSTOM_BUILD_TYPE=release CUSTOM_PLATFORM=arm \
	$(MAKE) -C $(@D) -f Makefile.inc all
	touch $@

#
# This is the build convenience target.
#
mjson: $(MJSON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MJSON_BUILD_DIR)/.staged: $(MJSON_BUILD_DIR)/.built
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	CPPFLAGS="$(STAGING_CPPFLAGS) $(MJSON_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(MJSON_LDFLAGS)" \
	CUSTOM_BUILD_TYPE=release CUSTOM_PLATFORM=arm \
	$(MAKE) -C $(@D) -f Makefile.inc LUNA_STAGING=$(STAGING_DIR)/opt install
	touch $@

mjson-stage: $(MJSON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mjson
#
$(MJSON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mjson" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MJSON_PRIORITY)" >>$@
	@echo "Section: $(MJSON_SECTION)" >>$@
	@echo "Version: $(MJSON_VERSION)-$(MJSON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MJSON_MAINTAINER)" >>$@
	@echo "Source: $(MJSON_SITE)/$(MJSON_SOURCE)" >>$@
	@echo "Description: $(MJSON_DESCRIPTION)" >>$@
	@echo "Depends: $(MJSON_DEPENDS)" >>$@
	@echo "Suggests: $(MJSON_SUGGESTS)" >>$@
	@echo "Conflicts: $(MJSON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MJSON_IPK_DIR)/opt/sbin or $(MJSON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MJSON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MJSON_IPK_DIR)/opt/etc/mjson/...
# Documentation files should be installed in $(MJSON_IPK_DIR)/opt/doc/mjson/...
# Daemon startup scripts should be installed in $(MJSON_IPK_DIR)/opt/etc/init.d/S??mjson
#
# You may need to patch your application to make it use these locations.
#
$(MJSON_IPK): $(MJSON_BUILD_DIR)/.built
	rm -rf $(MJSON_IPK_DIR) $(BUILD_DIR)/mjson_*_$(TARGET_ARCH).ipk
	$(TARGET_CONFIGURE_OPTS) \
	CPPFLAGS="$(STAGING_CPPFLAGS) $(MJSON_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(MJSON_LDFLAGS)" \
	CUSTOM_BUILD_TYPE=release CUSTOM_PLATFORM=arm \
	$(MAKE) -C $(MJSON_BUILD_DIR) -f Makefile.inc LUNA_STAGING=$(MJSON_IPK_DIR)/opt install
	$(MAKE) $(MJSON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MJSON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mjson-ipk: $(MJSON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mjson-clean:
	rm -f $(MJSON_BUILD_DIR)/.built
	-$(MAKE) -C $(MJSON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mjson-dirclean:
	rm -rf $(BUILD_DIR)/$(MJSON_DIR) $(MJSON_BUILD_DIR) $(MJSON_IPK_DIR) $(MJSON_IPK)
#
#
# Some sanity check for the package.
#
mjson-check: $(MJSON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
