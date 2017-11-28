###########################################################
#
# asterisk11-chan-dongle
#
###########################################################
#
# ASTERISK11_CHAN_DONGLE_VERSION, ASTERISK11_CHAN_DONGLE_SITE and ASTERISK11_CHAN_DONGLE_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK11_CHAN_DONGLE_DIR is the directory which is created when the source
# archive is unpacked.
# ASTERISK11_CHAN_DONGLE_UNZIP is the command used to unzip the source.
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
ASTERISK11_CHAN_DONGLE_URL=https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/asterisk-chan-dongle/$(ASTERISK11_CHAN_DONGLE_SOURCE)
ASTERISK11_CHAN_DONGLE_VERSION=1.1.r14
ASTERISK11_CHAN_DONGLE_SOURCE=chan_dongle-$(ASTERISK11_CHAN_DONGLE_VERSION).tgz
ASTERISK11_CHAN_DONGLE_DIR=chan_dongle-$(ASTERISK11_CHAN_DONGLE_VERSION)
ASTERISK11_CHAN_DONGLE_UNZIP=zcat
ASTERISK11_CHAN_DONGLE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ASTERISK11_CHAN_DONGLE_DESCRIPTION=asterisk11 huawei 3g dongle channel driver.
ASTERISK11_CHAN_DONGLE_SECTION=util
ASTERISK11_CHAN_DONGLE_PRIORITY=optional
ASTERISK11_CHAN_DONGLE_DEPENDS=asterisk11
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
ASTERISK11_CHAN_DONGLE_DEPENDS+=, libiconv
endif
ASTERISK11_CHAN_DONGLE_SUGGESTS=
ASTERISK11_CHAN_DONGLE_CONFLICTS=

#
# ASTERISK11_CHAN_DONGLE_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK11_CHAN_DONGLE_IPK_VERSION=1

#
# ASTERISK11_CHAN_DONGLE_CONFFILES should be a list of user-editable files
ASTERISK11_CHAN_DONGLE_CONFFILES=$(TARGET_PREFIX)/etc/asterisk/dongle.conf

#
# ASTERISK11_CHAN_DONGLE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ASTERISK11_CHAN_DONGLE_PATCHES=\
$(ASTERISK11_CHAN_DONGLE_SOURCE_DIR)/configure.patch \
$(ASTERISK11_CHAN_DONGLE_SOURCE_DIR)/asterisk11.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASTERISK11_CHAN_DONGLE_CPPFLAGS=
ASTERISK11_CHAN_DONGLE_LDFLAGS=
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
ASTERISK11_CHAN_DONGLE_LDFLAGS += -liconv
endif

#
# ASTERISK11_CHAN_DONGLE_BUILD_DIR is the directory in which the build is done.
# ASTERISK11_CHAN_DONGLE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASTERISK11_CHAN_DONGLE_IPK_DIR is the directory in which the ipk is built.
# ASTERISK11_CHAN_DONGLE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK11_CHAN_DONGLE_BUILD_DIR=$(BUILD_DIR)/asterisk11-chan-dongle
ASTERISK11_CHAN_DONGLE_SOURCE_DIR=$(SOURCE_DIR)/asterisk11-chan-dongle
ASTERISK11_CHAN_DONGLE_IPK_DIR=$(BUILD_DIR)/asterisk11-chan-dongle-$(ASTERISK11_CHAN_DONGLE_VERSION)-ipk
ASTERISK11_CHAN_DONGLE_IPK=$(BUILD_DIR)/asterisk11-chan-dongle_$(ASTERISK11_CHAN_DONGLE_VERSION)-$(ASTERISK11_CHAN_DONGLE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: asterisk11-chan-dongle-source asterisk11-chan-dongle-unpack asterisk11-chan-dongle asterisk11-chan-dongle-stage asterisk11-chan-dongle-ipk asterisk11-chan-dongle-clean asterisk11-chan-dongle-dirclean asterisk11-chan-dongle-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(ASTERISK11_CHAN_DONGLE_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(ASTERISK11_CHAN_DONGLE_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(ASTERISK11_CHAN_DONGLE_SOURCE).sha512
#
$(DL_DIR)/$(ASTERISK11_CHAN_DONGLE_SOURCE):
	$(WGET) -O $@ $(ASTERISK11_CHAN_DONGLE_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
asterisk11-chan-dongle-source: $(DL_DIR)/$(ASTERISK11_CHAN_DONGLE_SOURCE) $(ASTERISK11_CHAN_DONGLE_PATCHES)

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
$(ASTERISK11_CHAN_DONGLE_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK11_CHAN_DONGLE_SOURCE) \
				$(ASTERISK11_CHAN_DONGLE_PATCHES) make/asterisk11-chan-dongle.mk
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	$(MAKE) asterisk11
	rm -rf $(BUILD_DIR)/$(ASTERISK11_CHAN_DONGLE_DIR) $(@D)
	$(ASTERISK11_CHAN_DONGLE_UNZIP) $(DL_DIR)/$(ASTERISK11_CHAN_DONGLE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASTERISK11_CHAN_DONGLE_PATCHES)" ; \
		then cat $(ASTERISK11_CHAN_DONGLE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(ASTERISK11_CHAN_DONGLE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK11_CHAN_DONGLE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK11_CHAN_DONGLE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK11_CHAN_DONGLE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK11_CHAN_DONGLE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--with-asterisk=$(ASTERISK11_BUILD_DIR)/include \
	)
	touch $@

asterisk11-chan-dongle-unpack: $(ASTERISK11_CHAN_DONGLE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK11_CHAN_DONGLE_BUILD_DIR)/.built: $(ASTERISK11_CHAN_DONGLE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
asterisk11-chan-dongle: $(ASTERISK11_CHAN_DONGLE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK11_CHAN_DONGLE_BUILD_DIR)/.staged: $(ASTERISK11_CHAN_DONGLE_BUILD_DIR)/.built
	rm -f $@
	touch $@

asterisk11-chan-dongle-stage: $(ASTERISK11_CHAN_DONGLE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk11-chan-dongle
#
$(ASTERISK11_CHAN_DONGLE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: asterisk11-chan-dongle" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASTERISK11_CHAN_DONGLE_PRIORITY)" >>$@
	@echo "Section: $(ASTERISK11_CHAN_DONGLE_SECTION)" >>$@
	@echo "Version: $(ASTERISK11_CHAN_DONGLE_VERSION)-$(ASTERISK11_CHAN_DONGLE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASTERISK11_CHAN_DONGLE_MAINTAINER)" >>$@
	@echo "Source: $(ASTERISK11_CHAN_DONGLE_URL)" >>$@
	@echo "Description: $(ASTERISK11_CHAN_DONGLE_DESCRIPTION)" >>$@
	@echo "Depends: $(ASTERISK11_CHAN_DONGLE_DEPENDS)" >>$@
	@echo "Suggests: $(ASTERISK11_CHAN_DONGLE_SUGGESTS)" >>$@
	@echo "Conflicts: $(ASTERISK11_CHAN_DONGLE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK11_CHAN_DONGLE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(ASTERISK11_CHAN_DONGLE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK11_CHAN_DONGLE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(ASTERISK11_CHAN_DONGLE_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk11-chan-dongle/...
# Documentation files should be installed in $(ASTERISK11_CHAN_DONGLE_IPK_DIR)$(TARGET_PREFIX)/doc/asterisk11-chan-dongle/...
# Daemon startup scripts should be installed in $(ASTERISK11_CHAN_DONGLE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??asterisk11-chan-dongle
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK11_CHAN_DONGLE_IPK): $(ASTERISK11_CHAN_DONGLE_BUILD_DIR)/.built
	rm -rf $(ASTERISK11_CHAN_DONGLE_IPK_DIR) $(BUILD_DIR)/asterisk11-chan-dongle_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(ASTERISK11_CHAN_DONGLE_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk
	$(INSTALL) -m 644 $(ASTERISK11_CHAN_DONGLE_BUILD_DIR)/etc/dongle.conf \
			$(ASTERISK11_CHAN_DONGLE_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk
	$(INSTALL) -d $(ASTERISK11_CHAN_DONGLE_IPK_DIR)$(TARGET_PREFIX)/lib/asterisk/modules
	$(INSTALL) -m 755 $(ASTERISK11_CHAN_DONGLE_BUILD_DIR)/chan_dongle.so \
			$(ASTERISK11_CHAN_DONGLE_IPK_DIR)$(TARGET_PREFIX)/lib/asterisk/modules
	$(STRIP_COMMAND) $(ASTERISK11_CHAN_DONGLE_IPK_DIR)$(TARGET_PREFIX)/lib/asterisk/modules/chan_dongle.so
	$(MAKE) $(ASTERISK11_CHAN_DONGLE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(ASTERISK11_CHAN_DONGLE_SOURCE_DIR)/postinst $(ASTERISK11_CHAN_DONGLE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ASTERISK11_CHAN_DONGLE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(ASTERISK11_CHAN_DONGLE_SOURCE_DIR)/prerm $(ASTERISK11_CHAN_DONGLE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ASTERISK11_CHAN_DONGLE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(ASTERISK11_CHAN_DONGLE_IPK_DIR)/CONTROL/postinst $(ASTERISK11_CHAN_DONGLE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(ASTERISK11_CHAN_DONGLE_CONFFILES) | sed -e 's/ /\n/g' > $(ASTERISK11_CHAN_DONGLE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK11_CHAN_DONGLE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ASTERISK11_CHAN_DONGLE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk11-chan-dongle-ipk: $(ASTERISK11_CHAN_DONGLE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk11-chan-dongle-clean:
	rm -f $(ASTERISK11_CHAN_DONGLE_BUILD_DIR)/.built
	-$(MAKE) -C $(ASTERISK11_CHAN_DONGLE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk11-chan-dongle-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK11_CHAN_DONGLE_DIR) $(ASTERISK11_CHAN_DONGLE_BUILD_DIR) $(ASTERISK11_CHAN_DONGLE_IPK_DIR) $(ASTERISK11_CHAN_DONGLE_IPK)
#
#
# Some sanity check for the package.
#
asterisk11-chan-dongle-check: $(ASTERISK11_CHAN_DONGLE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
