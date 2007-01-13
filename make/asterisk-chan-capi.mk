###########################################################
#
# asterisk-chan-capi
#
###########################################################

# You must replace "asterisk-chan-capi" and "ASTERISK-CHAN-CAPI" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ASTERISK-CHAN-CAPI_VERSION, ASTERISK-CHAN-CAPI_SITE and ASTERISK-CHAN-CAPI_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK-CHAN-CAPI_DIR is the directory which is created when the source
# archive is unpacked.
# ASTERISK-CHAN-CAPI_UNZIP is the command used to unzip the source.
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
ASTERISK-CHAN-CAPI_SITE=ftp://ftp.melware.net/chan-capi
ASTERISK-CHAN-CAPI_VERSION=0.7.1
ASTERISK-CHAN-CAPI_SOURCE=chan_capi-$(ASTERISK-CHAN-CAPI_VERSION).tar.gz
ASTERISK-CHAN-CAPI_DIR=chan_capi-$(ASTERISK-CHAN-CAPI_VERSION)
ASTERISK-CHAN-CAPI_UNZIP=zcat
ASTERISK-CHAN-CAPI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ASTERISK-CHAN-CAPI_DESCRIPTION=capi module for asterisk
ASTERISK-CHAN-CAPI_SECTION=util
ASTERISK-CHAN-CAPI_PRIORITY=optional
ASTERISK-CHAN-CAPI_DEPENDS=asterisk, libcapi20
ASTERISK-CHAN-CAPI_SUGGESTS=
ASTERISK-CHAN-CAPI_CONFLICTS=

#
# ASTERISK-CHAN-CAPI_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK-CHAN-CAPI_IPK_VERSION=1

#
# ASTERISK-CHAN-CAPI_CONFFILES should be a list of user-editable files
ASTERISK-CHAN-CAPI_CONFFILES=

#
# ASTERISK-CHAN-CAPI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ASTERISK-CHAN-CAPI_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASTERISK-CHAN-CAPI_CPPFLAGS="-D_GNU_SOURCE"
ASTERISK-CHAN-CAPI_LDFLAGS=

#
# ASTERISK-CHAN-CAPI_BUILD_DIR is the directory in which the build is done.
# ASTERISK-CHAN-CAPI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASTERISK-CHAN-CAPI_IPK_DIR is the directory in which the ipk is built.
# ASTERISK-CHAN-CAPI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK-CHAN-CAPI_BUILD_DIR=$(BUILD_DIR)/asterisk-chan-capi
ASTERISK-CHAN-CAPI_SOURCE_DIR=$(SOURCE_DIR)/asterisk-chan-capi
ASTERISK-CHAN-CAPI_IPK_DIR=$(BUILD_DIR)/asterisk-chan-capi-$(ASTERISK-CHAN-CAPI_VERSION)-ipk
ASTERISK-CHAN-CAPI_IPK=$(BUILD_DIR)/asterisk-chan-capi_$(ASTERISK-CHAN-CAPI_VERSION)-$(ASTERISK-CHAN-CAPI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: asterisk-chan-capi-source asterisk-chan-capi-unpack asterisk-chan-capi asterisk-chan-capi-stage asterisk-chan-capi-ipk asterisk-chan-capi-clean asterisk-chan-capi-dirclean asterisk-chan-capi-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASTERISK-CHAN-CAPI_SOURCE):
	$(WGET) -P $(DL_DIR) $(ASTERISK-CHAN-CAPI_SITE)/$(ASTERISK-CHAN-CAPI_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
asterisk-chan-capi-source: $(DL_DIR)/$(ASTERISK-CHAN-CAPI_SOURCE) $(ASTERISK-CHAN-CAPI_PATCHES)

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
$(ASTERISK-CHAN-CAPI_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK-CHAN-CAPI_SOURCE) $(ASTERISK-CHAN-CAPI_PATCHES) make/asterisk-chan-capi.mk
	$(MAKE) asterisk-stage libcapi20-stage
	rm -rf $(BUILD_DIR)/$(ASTERISK-CHAN-CAPI_DIR) $(ASTERISK-CHAN-CAPI_BUILD_DIR)
	$(ASTERISK-CHAN-CAPI_UNZIP) $(DL_DIR)/$(ASTERISK-CHAN-CAPI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASTERISK-CHAN-CAPI_PATCHES)" ; \
		then cat $(ASTERISK-CHAN-CAPI_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ASTERISK-CHAN-CAPI_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK-CHAN-CAPI_DIR)" != "$(ASTERISK-CHAN-CAPI_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK-CHAN-CAPI_DIR) $(ASTERISK-CHAN-CAPI_BUILD_DIR) ; \
	fi
	(cd $(ASTERISK-CHAN-CAPI_BUILD_DIR); \
		./create_config.sh $(STAGING_DIR)/opt/usr/include \
	)
#	$(PATCH_LIBTOOL) $(ASTERISK-CHAN-CAPI_BUILD_DIR)/libtool
	touch $(ASTERISK-CHAN-CAPI_BUILD_DIR)/.configured

asterisk-chan-capi-unpack: $(ASTERISK-CHAN-CAPI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK-CHAN-CAPI_BUILD_DIR)/.built: $(ASTERISK-CHAN-CAPI_BUILD_DIR)/.configured
	rm -f $(ASTERISK-CHAN-CAPI_BUILD_DIR)/.built
	$(MAKE) -C $(ASTERISK-CHAN-CAPI_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK-CHAN-CAPI_CPPFLAGS) -I$(STAGING_DIR)/opt/usr/include" \
		LIBLINUX="$(STAGING_LDFLAGS) $(ASTERISK-CHAN-CAPI_LDFLAGS)"
	touch $(ASTERISK-CHAN-CAPI_BUILD_DIR)/.built

#
# This is the build convenience target.
#
asterisk-chan-capi: $(ASTERISK-CHAN-CAPI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK-CHAN-CAPI_BUILD_DIR)/.staged: $(ASTERISK-CHAN-CAPI_BUILD_DIR)/.built
	rm -f $(ASTERISK-CHAN-CAPI_BUILD_DIR)/.staged
	$(MAKE) -C $(ASTERISK-CHAN-CAPI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ASTERISK-CHAN-CAPI_BUILD_DIR)/.staged

asterisk-chan-capi-stage: $(ASTERISK-CHAN-CAPI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk-chan-capi
#
$(ASTERISK-CHAN-CAPI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: asterisk-chan-capi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASTERISK-CHAN-CAPI_PRIORITY)" >>$@
	@echo "Section: $(ASTERISK-CHAN-CAPI_SECTION)" >>$@
	@echo "Version: $(ASTERISK-CHAN-CAPI_VERSION)-$(ASTERISK-CHAN-CAPI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASTERISK-CHAN-CAPI_MAINTAINER)" >>$@
	@echo "Source: $(ASTERISK-CHAN-CAPI_SITE)/$(ASTERISK-CHAN-CAPI_SOURCE)" >>$@
	@echo "Description: $(ASTERISK-CHAN-CAPI_DESCRIPTION)" >>$@
	@echo "Depends: $(ASTERISK-CHAN-CAPI_DEPENDS)" >>$@
	@echo "Suggests: $(ASTERISK-CHAN-CAPI_SUGGESTS)" >>$@
	@echo "Conflicts: $(ASTERISK-CHAN-CAPI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK-CHAN-CAPI_IPK_DIR)/opt/sbin or $(ASTERISK-CHAN-CAPI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK-CHAN-CAPI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ASTERISK-CHAN-CAPI_IPK_DIR)/opt/etc/asterisk-chan-capi/...
# Documentation files should be installed in $(ASTERISK-CHAN-CAPI_IPK_DIR)/opt/doc/asterisk-chan-capi/...
# Daemon startup scripts should be installed in $(ASTERISK-CHAN-CAPI_IPK_DIR)/opt/etc/init.d/S??asterisk-chan-capi
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK-CHAN-CAPI_IPK): $(ASTERISK-CHAN-CAPI_BUILD_DIR)/.built
	rm -rf $(ASTERISK-CHAN-CAPI_IPK_DIR) $(BUILD_DIR)/asterisk-chan-capi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ASTERISK-CHAN-CAPI_BUILD_DIR) MODULES_DIR=$(ASTERISK-CHAN-CAPI_IPK_DIR)/opt/lib/asterisk/modules install
	$(STRIP_COMMAND) $(ASTERISK-CHAN-CAPI_IPK_DIR)/opt/lib/asterisk/modules/*.so
	install -d $(ASTERISK-CHAN-CAPI_IPK_DIR)/opt/etc/asterisk/sample/
	install -m 644 $(ASTERISK-CHAN-CAPI_BUILD_DIR)/capi.conf $(ASTERISK-CHAN-CAPI_IPK_DIR)/opt/etc/asterisk/sample/capi.conf
	$(MAKE) $(ASTERISK-CHAN-CAPI_IPK_DIR)/CONTROL/control
#	install -m 755 $(ASTERISK-CHAN-CAPI_SOURCE_DIR)/postinst $(ASTERISK-CHAN-CAPI_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ASTERISK-CHAN-CAPI_SOURCE_DIR)/prerm $(ASTERISK-CHAN-CAPI_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(ASTERISK-CHAN-CAPI_CONFFILES) | sed -e 's/ /\n/g' > $(ASTERISK-CHAN-CAPI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK-CHAN-CAPI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk-chan-capi-ipk: $(ASTERISK-CHAN-CAPI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk-chan-capi-clean:
	rm -f $(ASTERISK-CHAN-CAPI_BUILD_DIR)/.built
	-$(MAKE) -C $(ASTERISK-CHAN-CAPI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk-chan-capi-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK-CHAN-CAPI_DIR) $(ASTERISK-CHAN-CAPI_BUILD_DIR) $(ASTERISK-CHAN-CAPI_IPK_DIR) $(ASTERISK-CHAN-CAPI_IPK)
#
#
# Some sanity check for the package.
#
asterisk-chan-capi-check: $(ASTERISK-CHAN-CAPI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ASTERISK-CHAN-CAPI_IPK)
