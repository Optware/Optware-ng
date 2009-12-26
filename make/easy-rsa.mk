###########################################################
#
# easy-rsa
#
###########################################################

EASY-RSA_SITE=http://www.bisente.com/programas/easy-rsa-SAN
EASY-RSA_VERSION=2.0rc1SAN
EASY-RSA_SOURCE=easy-rsa-$(EASY-RSA_VERSION).tar.bz2
EASY-RSA_DIR=easy-rsa-$(EASY-RSA_VERSION)
EASY-RSA_UNZIP=bzcat
EASY-RSA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
EASY-RSA_DESCRIPTION=Describe easy-rsa here.
EASY-RSA_SECTION=admin
EASY-RSA_PRIORITY=optional
EASY-RSA_DEPENDS=openssl
EASY-RSA_SUGGESTS=
EASY-RSA_CONFLICTS=

#
# EASY-RSA_IPK_VERSION should be incremented when the ipk changes.
#
EASY-RSA_IPK_VERSION=3

#
# EASY-RSA_CONFFILES should be a list of user-editable files
#EASY-RSA_CONFFILES=/opt/etc/easy-rsa.conf /opt/etc/init.d/SXXeasy-rsa

#
# EASY-RSA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#EASY-RSA_PATCHES=$(EASY-RSA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
EASY-RSA_CPPFLAGS=
EASY-RSA_LDFLAGS=

#
# EASY-RSA_BUILD_DIR is the directory in which the build is done.
# EASY-RSA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# EASY-RSA_IPK_DIR is the directory in which the ipk is built.
# EASY-RSA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
EASY-RSA_BUILD_DIR=$(BUILD_DIR)/easy-rsa
EASY-RSA_SOURCE_DIR=$(SOURCE_DIR)/easy-rsa
EASY-RSA_IPK_DIR=$(BUILD_DIR)/easy-rsa-$(EASY-RSA_VERSION)-ipk
EASY-RSA_IPK=$(BUILD_DIR)/easy-rsa_$(EASY-RSA_VERSION)-$(EASY-RSA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: easy-rsa-source easy-rsa-unpack easy-rsa easy-rsa-stage easy-rsa-ipk easy-rsa-clean easy-rsa-dirclean easy-rsa-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(EASY-RSA_SOURCE):
	$(WGET) -P $(@D) $(EASY-RSA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
easy-rsa-source: $(DL_DIR)/$(EASY-RSA_SOURCE) $(EASY-RSA_PATCHES)

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
$(EASY-RSA_BUILD_DIR)/.configured: $(DL_DIR)/$(EASY-RSA_SOURCE) $(EASY-RSA_PATCHES) make/easy-rsa.mk
# 	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(EASY-RSA_DIR) $(@D)
	$(EASY-RSA_UNZIP) $(DL_DIR)/$(EASY-RSA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(EASY-RSA_PATCHES)" ; \
		then cat $(EASY-RSA_PATCHES) | \
		patch -d $(BUILD_DIR)/$(EASY-RSA_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(EASY-RSA_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(EASY-RSA_DIR) $(@D) ; \
	fi
	echo >> $(@D)/README.orig
	echo "*********************************************************" >> $(@D)/README.orig
	echo >> $(@D)/README.orig
	cat $(@D)/README >> $(@D)/README.orig
	cp $(@D)/README.orig $(@D)/README
	sed -i.orig -e 's|/bin/bash|/bin/sh|' `find $(@D) -type f`
	rm -f $(@D)/*.orig
	touch $@

easy-rsa-unpack: $(EASY-RSA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(EASY-RSA_BUILD_DIR)/.built: $(EASY-RSA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) all
	touch $@

#
# This is the build convenience target.
#
easy-rsa: $(EASY-RSA_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/easy-rsa
#
$(EASY-RSA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: easy-rsa" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(EASY-RSA_PRIORITY)" >>$@
	@echo "Section: $(EASY-RSA_SECTION)" >>$@
	@echo "Version: $(EASY-RSA_VERSION)-$(EASY-RSA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(EASY-RSA_MAINTAINER)" >>$@
	@echo "Source: $(EASY-RSA_SITE)/$(EASY-RSA_SOURCE)" >>$@
	@echo "Description: $(EASY-RSA_DESCRIPTION)" >>$@
	@echo "Depends: $(EASY-RSA_DEPENDS)" >>$@
	@echo "Suggests: $(EASY-RSA_SUGGESTS)" >>$@
	@echo "Conflicts: $(EASY-RSA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(EASY-RSA_IPK_DIR)/opt/sbin or $(EASY-RSA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(EASY-RSA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(EASY-RSA_IPK_DIR)/opt/etc/easy-rsa/...
# Documentation files should be installed in $(EASY-RSA_IPK_DIR)/opt/doc/easy-rsa/...
# Daemon startup scripts should be installed in $(EASY-RSA_IPK_DIR)/opt/etc/init.d/S??easy-rsa
#
# You may need to patch your application to make it use these locations.
#
$(EASY-RSA_IPK): $(EASY-RSA_BUILD_DIR)/.built
	rm -rf $(EASY-RSA_IPK_DIR) $(BUILD_DIR)/easy-rsa_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(EASY-RSA_BUILD_DIR) DESTDIR=$(EASY-RSA_IPK_DIR) PREFIX=/opt/share/easy-rsa install
	$(MAKE) $(EASY-RSA_IPK_DIR)/CONTROL/control
	echo $(EASY-RSA_CONFFILES) | sed -e 's/ /\n/g' > $(EASY-RSA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EASY-RSA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
easy-rsa-ipk: $(EASY-RSA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
easy-rsa-clean:
	rm -f $(EASY-RSA_BUILD_DIR)/.built
	-$(MAKE) -C $(EASY-RSA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
easy-rsa-dirclean:
	rm -rf $(BUILD_DIR)/$(EASY-RSA_DIR) $(EASY-RSA_BUILD_DIR) $(EASY-RSA_IPK_DIR) $(EASY-RSA_IPK)
#
#
# Some sanity check for the package.
#
easy-rsa-check: $(EASY-RSA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
