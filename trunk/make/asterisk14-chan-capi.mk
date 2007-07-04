###########################################################
#
# asterisk14-chan-capi
#
###########################################################

# You must replace "asterisk14-chan-capi" and "ASTERISK14-CHAN-CAPI" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ASTERISK14-CHAN-CAPI_VERSION, ASTERISK14-CHAN-CAPI_SITE and ASTERISK14-CHAN-CAPI_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK14-CHAN-CAPI_DIR is the directory which is created when the source
# archive is unpacked.
# ASTERISK14-CHAN-CAPI_UNZIP is the command used to unzip the source.
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
ASTERISK14-CHAN-CAPI_SITE=ftp://ftp.melware.net/chan-capi
ASTERISK14-CHAN-CAPI_VERSION=1.0.1
ASTERISK14-CHAN-CAPI_SOURCE=chan_capi-$(ASTERISK14-CHAN-CAPI_VERSION).tar.gz
ASTERISK14-CHAN-CAPI_DIR=chan_capi-$(ASTERISK14-CHAN-CAPI_VERSION)
ASTERISK14-CHAN-CAPI_UNZIP=zcat
ASTERISK14-CHAN-CAPI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ASTERISK14-CHAN-CAPI_DESCRIPTION=capi module for asterisk
ASTERISK14-CHAN-CAPI_SECTION=util
ASTERISK14-CHAN-CAPI_PRIORITY=optional
ASTERISK14-CHAN-CAPI_DEPENDS=asterisk14, libcapi20
ASTERISK14-CHAN-CAPI_SUGGESTS=
ASTERISK14-CHAN-CAPI_CONFLICTS=

#
# ASTERISK14-CHAN-CAPI_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK14-CHAN-CAPI_IPK_VERSION=1

#
# ASTERISK14-CHAN-CAPI_CONFFILES should be a list of user-editable files
ASTERISK14-CHAN-CAPI_CONFFILES=

#
# ASTERISK14-CHAN-CAPI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ASTERISK14-CHAN-CAPI_PATCHES=$(ASTERISK14-CHAN-CAPI_SOURCE_DIR)/HEAD-r456.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASTERISK14-CHAN-CAPI_CPPFLAGS="-D_GNU_SOURCE"
ASTERISK14-CHAN-CAPI_LDFLAGS=

#
# ASTERISK14-CHAN-CAPI_BUILD_DIR is the directory in which the build is done.
# ASTERISK14-CHAN-CAPI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASTERISK14-CHAN-CAPI_IPK_DIR is the directory in which the ipk is built.
# ASTERISK14-CHAN-CAPI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK14-CHAN-CAPI_BUILD_DIR=$(BUILD_DIR)/asterisk14-chan-capi
ASTERISK14-CHAN-CAPI_SOURCE_DIR=$(SOURCE_DIR)/asterisk14-chan-capi
ASTERISK14-CHAN-CAPI_IPK_DIR=$(BUILD_DIR)/asterisk14-chan-capi-$(ASTERISK14-CHAN-CAPI_VERSION)-ipk
ASTERISK14-CHAN-CAPI_IPK=$(BUILD_DIR)/asterisk14-chan-capi_$(ASTERISK14-CHAN-CAPI_VERSION)-$(ASTERISK14-CHAN-CAPI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: asterisk14-chan-capi-source asterisk14-chan-capi-unpack asterisk14-chan-capi asterisk14-chan-capi-stage asterisk14-chan-capi-ipk asterisk14-chan-capi-clean asterisk14-chan-capi-dirclean asterisk14-chan-capi-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASTERISK14-CHAN-CAPI_SOURCE):
	$(WGET) -P $(DL_DIR) $(ASTERISK14-CHAN-CAPI_SITE)/$(ASTERISK14-CHAN-CAPI_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
asterisk14-chan-capi-source: $(DL_DIR)/$(ASTERISK14-CHAN-CAPI_SOURCE) $(ASTERISK14-CHAN-CAPI_PATCHES)

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
$(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK14-CHAN-CAPI_SOURCE) $(ASTERISK14-CHAN-CAPI_PATCHES) make/asterisk14-chan-capi.mk
	$(MAKE) asterisk14-stage libcapi20-stage
	rm -rf $(BUILD_DIR)/$(ASTERISK14-CHAN-CAPI_DIR) $(ASTERISK14-CHAN-CAPI_BUILD_DIR)
	$(ASTERISK14-CHAN-CAPI_UNZIP) $(DL_DIR)/$(ASTERISK14-CHAN-CAPI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASTERISK14-CHAN-CAPI_PATCHES)" ; \
		then cat $(ASTERISK14-CHAN-CAPI_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ASTERISK14-CHAN-CAPI_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK14-CHAN-CAPI_DIR)" != "$(ASTERISK14-CHAN-CAPI_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK14-CHAN-CAPI_DIR) $(ASTERISK14-CHAN-CAPI_BUILD_DIR) ; \
	fi
	(cd $(ASTERISK14-CHAN-CAPI_BUILD_DIR); \
		./create_config.sh $(STAGING_INCLUDE_DIR) \
	)
#	$(PATCH_LIBTOOL) $(ASTERISK14-CHAN-CAPI_BUILD_DIR)/libtool
	touch $(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.configured

asterisk14-chan-capi-unpack: $(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.built: $(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.configured
	rm -f $(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.built
	$(MAKE) -C $(ASTERISK14-CHAN-CAPI_BUILD_DIR) \
		ASTERISK_HEADER_DIR=$(STAGING_INCLUDE_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK14-CHAN-CAPI_CPPFLAGS) -I$(STAGING_INCLUDE_DIR)" \
		LIBLINUX="$(STAGING_LDFLAGS) $(ASTERISK14-CHAN-CAPI_LDFLAGS)"
	touch $(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.built

#
# This is the build convenience target.
#
asterisk14-chan-capi: $(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.staged: $(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.built
	rm -f $(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.staged
	$(MAKE) -C $(ASTERISK14-CHAN-CAPI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.staged

asterisk14-chan-capi-stage: $(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk14-chan-capi
#
$(ASTERISK14-CHAN-CAPI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: asterisk14-chan-capi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASTERISK14-CHAN-CAPI_PRIORITY)" >>$@
	@echo "Section: $(ASTERISK14-CHAN-CAPI_SECTION)" >>$@
	@echo "Version: $(ASTERISK14-CHAN-CAPI_VERSION)-$(ASTERISK14-CHAN-CAPI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASTERISK14-CHAN-CAPI_MAINTAINER)" >>$@
	@echo "Source: $(ASTERISK14-CHAN-CAPI_SITE)/$(ASTERISK14-CHAN-CAPI_SOURCE)" >>$@
	@echo "Description: $(ASTERISK14-CHAN-CAPI_DESCRIPTION)" >>$@
	@echo "Depends: $(ASTERISK14-CHAN-CAPI_DEPENDS)" >>$@
	@echo "Suggests: $(ASTERISK14-CHAN-CAPI_SUGGESTS)" >>$@
	@echo "Conflicts: $(ASTERISK14-CHAN-CAPI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK14-CHAN-CAPI_IPK_DIR)/opt/sbin or $(ASTERISK14-CHAN-CAPI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK14-CHAN-CAPI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ASTERISK14-CHAN-CAPI_IPK_DIR)/opt/etc/asterisk14-chan-capi/...
# Documentation files should be installed in $(ASTERISK14-CHAN-CAPI_IPK_DIR)/opt/doc/asterisk14-chan-capi/...
# Daemon startup scripts should be installed in $(ASTERISK14-CHAN-CAPI_IPK_DIR)/opt/etc/init.d/S??asterisk14-chan-capi
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK14-CHAN-CAPI_IPK): $(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.built
	rm -rf $(ASTERISK14-CHAN-CAPI_IPK_DIR) $(BUILD_DIR)/asterisk14-chan-capi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ASTERISK14-CHAN-CAPI_BUILD_DIR) install \
		MODULES_DIR=$(ASTERISK14-CHAN-CAPI_IPK_DIR)/opt/lib/asterisk/modules \
		ASTERISK_HEADER_DIR=$(STAGING_INCLUDE_DIR) \
		;
	$(STRIP_COMMAND) $(ASTERISK14-CHAN-CAPI_IPK_DIR)/opt/lib/asterisk/modules/*.so
	install -d $(ASTERISK14-CHAN-CAPI_IPK_DIR)/opt/etc/asterisk/sample/
	install -m 644 $(ASTERISK14-CHAN-CAPI_BUILD_DIR)/capi.conf $(ASTERISK14-CHAN-CAPI_IPK_DIR)/opt/etc/asterisk/sample/capi.conf
	$(MAKE) $(ASTERISK14-CHAN-CAPI_IPK_DIR)/CONTROL/control
#	install -m 755 $(ASTERISK14-CHAN-CAPI_SOURCE_DIR)/postinst $(ASTERISK14-CHAN-CAPI_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ASTERISK14-CHAN-CAPI_SOURCE_DIR)/prerm $(ASTERISK14-CHAN-CAPI_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(ASTERISK14-CHAN-CAPI_CONFFILES) | sed -e 's/ /\n/g' > $(ASTERISK14-CHAN-CAPI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK14-CHAN-CAPI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk14-chan-capi-ipk: $(ASTERISK14-CHAN-CAPI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk14-chan-capi-clean:
	rm -f $(ASTERISK14-CHAN-CAPI_BUILD_DIR)/.built
	-$(MAKE) -C $(ASTERISK14-CHAN-CAPI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk14-chan-capi-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK14-CHAN-CAPI_DIR) $(ASTERISK14-CHAN-CAPI_BUILD_DIR) $(ASTERISK14-CHAN-CAPI_IPK_DIR) $(ASTERISK14-CHAN-CAPI_IPK)
#
#
# Some sanity check for the package.
#
asterisk14-chan-capi-check: $(ASTERISK14-CHAN-CAPI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ASTERISK14-CHAN-CAPI_IPK)
