###########################################################
#
# softethervpn
#
###########################################################
#
# SOFTETHERVPN_VERSION, SOFTETHERVPN_SITE and SOFTETHERVPN_SOURCE define
# the upstream location of the source code for the package.
# SOFTETHERVPN_DIR is the directory which is created when the source
# archive is unpacked.
# SOFTETHERVPN_UNZIP is the command used to unzip the source.
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
SOFTETHERVPN_GIT_REPO=https://github.com/SoftEtherVPN/SoftEtherVPN.git
SOFTETHERVPN_VERSION=4.21-9613-beta
SOFTETHERVPN_TREEISH=`git rev-list --max-count=1 --until=2016-04-24 HEAD`
SOFTETHERVPN_SOURCE=softethervpn-$(SOFTETHERVPN_VERSION).tar.bz2
SOFTETHERVPN_DIR=softethervpn-$(SOFTETHERVPN_VERSION)
SOFTETHERVPN_UNZIP=bzcat
SOFTETHERVPN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SOFTETHERVPN_DESCRIPTION=A Free Cross-platform Multi-protocol VPN Software, developed by SoftEther VPN Project at University of Tsukuba, Japan.
SOFTETHERVPN_SECTION=net
SOFTETHERVPN_PRIORITY=optional
SOFTETHERVPN_DEPENDS=openssl, readline, zlib
SOFTETHERVPN_SUGGESTS=
SOFTETHERVPN_CONFLICTS=

#
# SOFTETHERVPN_IPK_VERSION should be incremented when the ipk changes.
#
SOFTETHERVPN_IPK_VERSION=3

#
# SOFTETHERVPN_CONFFILES should be a list of user-editable files
#SOFTETHERVPN_CONFFILES=$(TARGET_PREFIX)/etc/softethervpn.conf $(TARGET_PREFIX)/etc/init.d/SXXsoftethervpn

#
# SOFTETHERVPN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SOFTETHERVPN_PATCHES=\
$(SOFTETHERVPN_SOURCE_DIR)/ar_ranlib.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SOFTETHERVPN_CPPFLAGS=
SOFTETHERVPN_LDFLAGS=

#
# SOFTETHERVPN_BUILD_DIR is the directory in which the build is done.
# SOFTETHERVPN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SOFTETHERVPN_IPK_DIR is the directory in which the ipk is built.
# SOFTETHERVPN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SOFTETHERVPN_BUILD_DIR=$(BUILD_DIR)/softethervpn
SOFTETHERVPN_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/softethervpn
SOFTETHERVPN_SOURCE_DIR=$(SOURCE_DIR)/softethervpn
SOFTETHERVPN_IPK_DIR=$(BUILD_DIR)/softethervpn-$(SOFTETHERVPN_VERSION)-ipk
SOFTETHERVPN_IPK=$(BUILD_DIR)/softethervpn_$(SOFTETHERVPN_VERSION)-$(SOFTETHERVPN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: softethervpn-source softethervpn-unpack softethervpn softethervpn-stage softethervpn-ipk softethervpn-clean softethervpn-dirclean softethervpn-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the repo using git.
#
$(DL_DIR)/$(SOFTETHERVPN_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf softethervpn && \
		git clone --bare $(SOFTETHERVPN_GIT_REPO) softethervpn && \
		(cd softethervpn && \
		git archive --format=tar --prefix=$(SOFTETHERVPN_DIR)/ $(SOFTETHERVPN_TREEISH) | bzip2 - > $@) && \
		rm -rf softethervpn ; \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
softethervpn-source: $(DL_DIR)/$(SOFTETHERVPN_SOURCE) $(SOFTETHERVPN_PATCHES)

$(SOFTETHERVPN_HOST_BUILD_DIR)/.built: $(DL_DIR)/$(SOFTETHERVPN_SOURCE)
	$(MAKE) openssl-host-stage readline-host-stage zlib-host-stage
	rm -rf $(HOST_BUILD_DIR)/$(SOFTETHERVPN_DIR) $(@D)
	$(SOFTETHERVPN_UNZIP) $(DL_DIR)/$(SOFTETHERVPN_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(SOFTETHERVPN_DIR)" != "$(@D)" ; \
	        then mv $(HOST_BUILD_DIR)/$(SOFTETHERVPN_DIR) $(@D) ; \
	fi
	if $(HOSTCC) -E -P $(SOURCE_DIR)/common/bits.c | grep -q puts.*32-bit; then \
	        cp -f $(@D)/src/makefiles/linux_32bit.mak $(@D)/Makefile; \
	else \
	        cp -f $(@D)/src/makefiles/linux_64bit.mak $(@D)/Makefile; \
	fi
	$(MAKE) -C $(@D) \
	        CC="$(HOSTCC) -I$(HOST_STAGING_INCLUDE_DIR) -L$(HOST_STAGING_LIB_DIR) -Wl,-rpath,$(HOST_STAGING_LIB_DIR)"
	touch $@

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
$(SOFTETHERVPN_BUILD_DIR)/.configured: $(DL_DIR)/$(SOFTETHERVPN_SOURCE) $(SOFTETHERVPN_PATCHES) make/softethervpn.mk \
					$(SOFTETHERVPN_HOST_BUILD_DIR)/.built
	$(MAKE) openssl-stage readline-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(SOFTETHERVPN_DIR) $(@D)
	$(SOFTETHERVPN_UNZIP) $(DL_DIR)/$(SOFTETHERVPN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SOFTETHERVPN_PATCHES)" ; \
		then cat $(SOFTETHERVPN_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(SOFTETHERVPN_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(SOFTETHERVPN_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SOFTETHERVPN_DIR) $(@D) ; \
	fi
	if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/bits.c | grep -q puts.*32-bit; then \
		cp -f $(@D)/src/makefiles/linux_32bit.mak $(@D)/Makefile; \
	else \
		cp -f $(@D)/src/makefiles/linux_64bit.mak $(@D)/Makefile; \
	fi
	sed -i  -e 's|DIR=/usr/|DIR=\$$(DESTDIR)$(TARGET_PREFIX)/|' \
		-e 's|^\ttmp/hamcorebuilder|\t$(SOFTETHERVPN_HOST_BUILD_DIR)/tmp/hamcorebuilder|' $(@D)/Makefile
	touch $@

softethervpn-unpack: $(SOFTETHERVPN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SOFTETHERVPN_BUILD_DIR)/.built: $(SOFTETHERVPN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		HOSTCC=$(HOSTCC) \
		CC="$(TARGET_CC) $(STAGING_LDFLAGS) $(SOFTETHERVPN_LDFLAGS) \
				 $(STAGING_CPPFLAGS) $(SOFTETHERVPN_CPPFLAGS)"
	touch $@

#
# This is the build convenience target.
#
softethervpn: $(SOFTETHERVPN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SOFTETHERVPN_BUILD_DIR)/.staged: $(SOFTETHERVPN_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

softethervpn-stage: $(SOFTETHERVPN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/softethervpn
#
$(SOFTETHERVPN_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: softethervpn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SOFTETHERVPN_PRIORITY)" >>$@
	@echo "Section: $(SOFTETHERVPN_SECTION)" >>$@
	@echo "Version: $(SOFTETHERVPN_VERSION)-$(SOFTETHERVPN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SOFTETHERVPN_MAINTAINER)" >>$@
	@echo "Source: $(SOFTETHERVPN_GIT_REPO)" >>$@
	@echo "Description: $(SOFTETHERVPN_DESCRIPTION)" >>$@
	@echo "Depends: $(SOFTETHERVPN_DEPENDS)" >>$@
	@echo "Suggests: $(SOFTETHERVPN_SUGGESTS)" >>$@
	@echo "Conflicts: $(SOFTETHERVPN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SOFTETHERVPN_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SOFTETHERVPN_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SOFTETHERVPN_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SOFTETHERVPN_IPK_DIR)$(TARGET_PREFIX)/etc/softethervpn/...
# Documentation files should be installed in $(SOFTETHERVPN_IPK_DIR)$(TARGET_PREFIX)/doc/softethervpn/...
# Daemon startup scripts should be installed in $(SOFTETHERVPN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??softethervpn
#
# You may need to patch your application to make it use these locations.
#
$(SOFTETHERVPN_IPK): $(SOFTETHERVPN_BUILD_DIR)/.built
	rm -rf $(SOFTETHERVPN_IPK_DIR) $(BUILD_DIR)/softethervpn_*_$(TARGET_ARCH).ipk
	mkdir -p $(SOFTETHERVPN_IPK_DIR)$(TARGET_PREFIX)/{bin,vpnserver,vpnbridge,vpnclient,vpncmd}
	$(MAKE) -C $(SOFTETHERVPN_BUILD_DIR) DESTDIR=$(SOFTETHERVPN_IPK_DIR) install
	$(STRIP_COMMAND) $(SOFTETHERVPN_IPK_DIR)$(TARGET_PREFIX)/{vpnbridge/vpnbridge,vpnclient/vpnclient,vpncmd/vpncmd,vpnserver/vpnserver}
	sed -i -e 's|$(SOFTETHERVPN_IPK_DIR)||' $(SOFTETHERVPN_IPK_DIR)$(TARGET_PREFIX)/bin/*
#	$(INSTALL) -d $(SOFTETHERVPN_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(SOFTETHERVPN_SOURCE_DIR)/softethervpn.conf $(SOFTETHERVPN_IPK_DIR)$(TARGET_PREFIX)/etc/softethervpn.conf
#	$(INSTALL) -d $(SOFTETHERVPN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(SOFTETHERVPN_SOURCE_DIR)/rc.softethervpn $(SOFTETHERVPN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXsoftethervpn
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SOFTETHERVPN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXsoftethervpn
	$(MAKE) $(SOFTETHERVPN_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(SOFTETHERVPN_SOURCE_DIR)/postinst $(SOFTETHERVPN_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SOFTETHERVPN_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(SOFTETHERVPN_SOURCE_DIR)/prerm $(SOFTETHERVPN_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SOFTETHERVPN_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SOFTETHERVPN_IPK_DIR)/CONTROL/postinst $(SOFTETHERVPN_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SOFTETHERVPN_CONFFILES) | sed -e 's/ /\n/g' > $(SOFTETHERVPN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SOFTETHERVPN_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SOFTETHERVPN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
softethervpn-ipk: $(SOFTETHERVPN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
softethervpn-clean:
	rm -f $(SOFTETHERVPN_BUILD_DIR)/.built
	-$(MAKE) -C $(SOFTETHERVPN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
softethervpn-dirclean:
	rm -rf $(BUILD_DIR)/$(SOFTETHERVPN_DIR) $(SOFTETHERVPN_BUILD_DIR) $(SOFTETHERVPN_IPK_DIR) $(SOFTETHERVPN_IPK)
#
#
# Some sanity check for the package.
#
softethervpn-check: $(SOFTETHERVPN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
