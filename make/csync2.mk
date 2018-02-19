###########################################################
#
# csync2
#
###########################################################
#
# CSYNC2_VERSION, CSYNC2_SITE and CSYNC2_SOURCE define
# the upstream location of the source code for the package.
# CSYNC2_DIR is the directory which is created when the source
# archive is unpacked.
# CSYNC2_UNZIP is the command used to unzip the source.
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
CSYNC2_GIT=https://github.com/LINBIT/csync2.git
CSYNC2_HASH=1d4da1bdb7c5fbb3990386fc7c3b698a720f2fba
CSYNC2_VERSION=2.0+git20171027
CSYNC2_SOURCE=csync2-$(CSYNC2_VERSION).tar.gz
CSYNC2_DIR=csync2-$(CSYNC2_VERSION)
CSYNC2_UNZIP=zcat
CSYNC2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CSYNC2_DESCRIPTION=Cluster synchronization tool.
CSYNC2_SECTION=net
CSYNC2_PRIORITY=optional
CSYNC2_DEPENDS=librsync, gnutls
CSYNC2_SUGGESTS=bash
CSYNC2_CONFLICTS=

#
# CSYNC2_IPK_VERSION should be incremented when the ipk changes.
#
CSYNC2_IPK_VERSION=2

#
# CSYNC2_CONFFILES should be a list of user-editable files
CSYNC2_CONFFILES=$(TARGET_PREFIX)/etc/csync2.cfg

#
# CSYNC2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CSYNC2_PATCHES=\
$(CSYNC2_SOURCE_DIR)/strlcpy_compat.patch \
$(CSYNC2_SOURCE_DIR)/optware-bash.patch \
$(CSYNC2_SOURCE_DIR)/libsqlite3-name.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CSYNC2_CPPFLAGS=
CSYNC2_LDFLAGS=

#
# CSYNC2_BUILD_DIR is the directory in which the build is done.
# CSYNC2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CSYNC2_IPK_DIR is the directory in which the ipk is built.
# CSYNC2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CSYNC2_BUILD_DIR=$(BUILD_DIR)/csync2
CSYNC2_SOURCE_DIR=$(SOURCE_DIR)/csync2
CSYNC2_IPK_DIR=$(BUILD_DIR)/csync2-$(CSYNC2_VERSION)-ipk
CSYNC2_IPK=$(BUILD_DIR)/csync2_$(CSYNC2_VERSION)-$(CSYNC2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: csync2-source csync2-unpack csync2 csync2-stage csync2-ipk csync2-clean csync2-dirclean csync2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(CSYNC2_GIT) holds the link to the source,
# which is saved to $(DL_DIR)/$(CSYNC2_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(CSYNC2_SOURCE).sha512
#
$(DL_DIR)/$(CSYNC2_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf csync2 && \
		git clone --bare $(CSYNC2_GIT) csync2 && \
		(cd csync2 && \
		git archive --format=tar --prefix=$(CSYNC2_DIR)/ $(CSYNC2_HASH) | gzip > $@) && \
		rm -rf csync2 ; \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
csync2-source: $(DL_DIR)/$(CSYNC2_SOURCE) $(CSYNC2_PATCHES)

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
$(CSYNC2_BUILD_DIR)/.configured: $(DL_DIR)/$(CSYNC2_SOURCE) $(CSYNC2_PATCHES) make/csync2.mk
	$(MAKE) librsync-stage gnutls-stage 
	rm -rf $(BUILD_DIR)/$(CSYNC2_DIR) $(@D)
	$(CSYNC2_UNZIP) $(DL_DIR)/$(CSYNC2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CSYNC2_PATCHES)" ; \
		then cat $(CSYNC2_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(CSYNC2_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(CSYNC2_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CSYNC2_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.14) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CSYNC2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CSYNC2_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
	)
	touch $@

csync2-unpack: $(CSYNC2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CSYNC2_BUILD_DIR)/.built: $(CSYNC2_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
csync2: $(CSYNC2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CSYNC2_BUILD_DIR)/.staged: $(CSYNC2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

csync2-stage: $(CSYNC2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/csync2
#
$(CSYNC2_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: csync2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CSYNC2_PRIORITY)" >>$@
	@echo "Section: $(CSYNC2_SECTION)" >>$@
	@echo "Version: $(CSYNC2_VERSION)-$(CSYNC2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CSYNC2_MAINTAINER)" >>$@
	@echo "Source: $(CSYNC2_GIT)" >>$@
	@echo "Description: $(CSYNC2_DESCRIPTION)" >>$@
	@echo "Depends: $(CSYNC2_DEPENDS)" >>$@
	@echo "Suggests: $(CSYNC2_SUGGESTS)" >>$@
	@echo "Conflicts: $(CSYNC2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CSYNC2_IPK_DIR)$(TARGET_PREFIX)/sbin or $(CSYNC2_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CSYNC2_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(CSYNC2_IPK_DIR)$(TARGET_PREFIX)/etc/csync2/...
# Documentation files should be installed in $(CSYNC2_IPK_DIR)$(TARGET_PREFIX)/doc/csync2/...
# Daemon startup scripts should be installed in $(CSYNC2_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??csync2
#
# You may need to patch your application to make it use these locations.
#
$(CSYNC2_IPK): $(CSYNC2_BUILD_DIR)/.built
	rm -rf $(CSYNC2_IPK_DIR) $(BUILD_DIR)/csync2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CSYNC2_BUILD_DIR) DESTDIR=$(CSYNC2_IPK_DIR) install-strip
#	$(INSTALL) -d $(CSYNC2_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(CSYNC2_SOURCE_DIR)/csync2.conf $(CSYNC2_IPK_DIR)$(TARGET_PREFIX)/etc/csync2.conf
#	$(INSTALL) -d $(CSYNC2_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(CSYNC2_SOURCE_DIR)/rc.csync2 $(CSYNC2_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXcsync2
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CSYNC2_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXcsync2
	$(MAKE) $(CSYNC2_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(CSYNC2_SOURCE_DIR)/postinst $(CSYNC2_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CSYNC2_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(CSYNC2_SOURCE_DIR)/prerm $(CSYNC2_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CSYNC2_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(CSYNC2_IPK_DIR)/CONTROL/postinst $(CSYNC2_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(CSYNC2_CONFFILES) | sed -e 's/ /\n/g' > $(CSYNC2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CSYNC2_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(CSYNC2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
csync2-ipk: $(CSYNC2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
csync2-clean:
	rm -f $(CSYNC2_BUILD_DIR)/.built
	-$(MAKE) -C $(CSYNC2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
csync2-dirclean:
	rm -rf $(BUILD_DIR)/$(CSYNC2_DIR) $(CSYNC2_BUILD_DIR) $(CSYNC2_IPK_DIR) $(CSYNC2_IPK)
#
#
# Some sanity check for the package.
#
csync2-check: $(CSYNC2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
