###########################################################
#
# jre-cacerts
#
###########################################################
#
# JRE_CACERTS_VERSION, JRE_CACERTS_SITE and JRE_CACERTS_SOURCE define
# the upstream location of the source code for the package.
# JRE_CACERTS_DIR is the directory which is created when the source
# archive is unpacked.
# JRE_CACERTS_UNZIP is the command used to unzip the source.
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
JRE_CACERTS_URL=http://www.linuxfromscratch.org/blfs/view/cvs/postlfs/cacerts.html
JRE_CACERTS_VERSION=$(CACERTS_VERSION)
JRE_CACERTS_DIR=jre-cacerts
JRE_CACERTS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
JRE_CACERTS_DESCRIPTION=JRE Certificate Authority Certificates.
JRE_CACERTS_SECTION=misc
JRE_CACERTS_PRIORITY=optional
JRE_CACERTS_DEPENDS=
JRE_CACERTS_SUGGESTS=
JRE_CACERTS_CONFLICTS=

#
# JRE_CACERTS_IPK_VERSION should be incremented when the ipk changes.
#
JRE_CACERTS_IPK_VERSION=1

#
# JRE_CACERTS_CONFFILES should be a list of user-editable files
#JRE_CACERTS_CONFFILES=$(TARGET_PREFIX)/etc/jre-cacerts.conf $(TARGET_PREFIX)/etc/init.d/SXXjre-cacerts

#
# JRE_CACERTS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#JRE_CACERTS_PATCHES=$(JRE_CACERTS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
JRE_CACERTS_CPPFLAGS=
JRE_CACERTS_LDFLAGS=

#
# JRE_CACERTS_BUILD_DIR is the directory in which the build is done.
# JRE_CACERTS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# JRE_CACERTS_IPK_DIR is the directory in which the ipk is built.
# JRE_CACERTS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
JRE_CACERTS_BUILD_DIR=$(HOST_BUILD_DIR)/jre-cacerts
JRE_CACERTS_SOURCE_DIR=$(SOURCE_DIR)/jre-cacerts
JRE_CACERTS_IPK_DIR=$(BUILD_DIR)/jre-cacerts-$(JRE_CACERTS_VERSION)-ipk
JRE_CACERTS_IPK=$(BUILD_DIR)/jre-cacerts_$(JRE_CACERTS_VERSION)-$(JRE_CACERTS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: jre-cacerts-source jre-cacerts-unpack jre-cacerts jre-cacerts-stage jre-cacerts-ipk jre-cacerts-clean jre-cacerts-dirclean jre-cacerts-check

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
$(JRE_CACERTS_BUILD_DIR)/.configured: host/.configured $(CACERTS_BUILD_DIR)/.built $(JRE_CACERTS_PATCHES) #make/jre-cacerts.mk
	$(MAKE) openssl-host-stage
	rm -rf $(@D)
	$(INSTALL) -d $(@D)
	touch $@

jre-cacerts-unpack: $(JRE_CACERTS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(JRE_CACERTS_BUILD_DIR)/.built: $(JRE_CACERTS_BUILD_DIR)/.configured
	rm -f $@
	$(SHELL) $(JRE_CACERTS_SOURCE_DIR)/mkcacerts.sh   \
			-d "$(CACERTS_BUILD_DIR)/certs/"           \
			-k "keytool"      \
			-s "$(HOST_STAGING_PREFIX)/bin/openssl"          \
			-o "$(@D)/jre-cacerts"
	touch $@

#
# This is the build convenience target.
#
jre-cacerts: $(JRE_CACERTS_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/jre-cacerts
#
$(JRE_CACERTS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: jre-cacerts" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(JRE_CACERTS_PRIORITY)" >>$@
	@echo "Section: $(JRE_CACERTS_SECTION)" >>$@
	@echo "Version: $(JRE_CACERTS_VERSION)-$(JRE_CACERTS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(JRE_CACERTS_MAINTAINER)" >>$@
	@echo "Source: $(JRE_CACERTS_URL)" >>$@
	@echo "Description: $(JRE_CACERTS_DESCRIPTION)" >>$@
	@echo "Depends: $(JRE_CACERTS_DEPENDS)" >>$@
	@echo "Suggests: $(JRE_CACERTS_SUGGESTS)" >>$@
	@echo "Conflicts: $(JRE_CACERTS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(JRE_CACERTS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(JRE_CACERTS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(JRE_CACERTS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(JRE_CACERTS_IPK_DIR)$(TARGET_PREFIX)/etc/jre-cacerts/...
# Documentation files should be installed in $(JRE_CACERTS_IPK_DIR)$(TARGET_PREFIX)/doc/jre-cacerts/...
# Daemon startup scripts should be installed in $(JRE_CACERTS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??jre-cacerts
#
# You may need to patch your application to make it use these locations.
#
$(JRE_CACERTS_IPK): $(JRE_CACERTS_BUILD_DIR)/.built
	rm -rf $(JRE_CACERTS_IPK_DIR) $(BUILD_DIR)/jre-cacerts_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(JRE_CACERTS_IPK_DIR)$(TARGET_PREFIX)/etc/ssl
	cp -af $(JRE_CACERTS_BUILD_DIR)/jre-cacerts $(JRE_CACERTS_IPK_DIR)$(TARGET_PREFIX)/etc/ssl
	$(MAKE) $(JRE_CACERTS_IPK_DIR)/CONTROL/control
	echo $(JRE_CACERTS_CONFFILES) | sed -e 's/ /\n/g' > $(JRE_CACERTS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(JRE_CACERTS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(JRE_CACERTS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
jre-cacerts-ipk: $(JRE_CACERTS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
jre-cacerts-clean:
	rm -f $(JRE_CACERTS_BUILD_DIR)/.built
	-$(MAKE) -C $(JRE_CACERTS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
jre-cacerts-dirclean:
	rm -rf $(BUILD_DIR)/$(JRE_CACERTS_DIR) $(JRE_CACERTS_BUILD_DIR) $(JRE_CACERTS_IPK_DIR) $(JRE_CACERTS_IPK)
#
#
# Some sanity check for the package.
#
jre-cacerts-check: $(JRE_CACERTS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
