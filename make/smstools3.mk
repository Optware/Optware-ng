###########################################################
#
# smstools3
#
###########################################################
#
# SMSTOOLS3_VERSION, SMSTOOLS3_SITE and SMSTOOLS3_SOURCE define
# the upstream location of the source code for the package.
# SMSTOOLS3_DIR is the directory which is created when the source
# archive is unpacked.
# SMSTOOLS3_UNZIP is the command used to unzip the source.
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
SMSTOOLS3_URL=http://smstools3.kekekasvi.com/packages/smstools3-$(SMSTOOLS3_VERSION).tar.gz
SMSTOOLS3_VERSION=3.1.15
SMSTOOLS3_SOURCE=smstools3-$(SMSTOOLS3_VERSION).tar.gz
SMSTOOLS3_DIR=smstools3
SMSTOOLS3_UNZIP=zcat
SMSTOOLS3_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SMSTOOLS3_DESCRIPTION=SMS Gateway software which can send and receive short messages through GSM modems and mobile phones.
SMSTOOLS3_SECTION=misc
SMSTOOLS3_PRIORITY=optional
SMSTOOLS3_DEPENDS=busybox-base, bash, libmm
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
SMSTOOLS3_DEPENDS+=, libiconv
endif
SMSTOOLS3_SUGGESTS=
SMSTOOLS3_CONFLICTS=

#
# SMSTOOLS3_IPK_VERSION should be incremented when the ipk changes.
#
SMSTOOLS3_IPK_VERSION=1

#
# SMSTOOLS3_CONFFILES should be a list of user-editable files
SMSTOOLS3_CONFFILES=$(TARGET_PREFIX)/etc/smsd.conf $(TARGET_PREFIX)/etc/init.d/S89smstools3

#
# SMSTOOLS3_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SMSTOOLS3_PATCHES=\
$(SMSTOOLS3_SOURCE_DIR)/Makefile.patch \
$(SMSTOOLS3_SOURCE_DIR)/paths.patch \
$(SMSTOOLS3_SOURCE_DIR)/scripts.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SMSTOOLS3_CPPFLAGS=-D NUMBER_OF_MODEMS=64
SMSTOOLS3_LDFLAGS=-lmm
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
SMSTOOLS3_LDFLAGS += -liconv
endif

#
# SMSTOOLS3_BUILD_DIR is the directory in which the build is done.
# SMSTOOLS3_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SMSTOOLS3_IPK_DIR is the directory in which the ipk is built.
# SMSTOOLS3_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SMSTOOLS3_BUILD_DIR=$(BUILD_DIR)/smstools3
SMSTOOLS3_SOURCE_DIR=$(SOURCE_DIR)/smstools3
SMSTOOLS3_IPK_DIR=$(BUILD_DIR)/smstools3-$(SMSTOOLS3_VERSION)-ipk
SMSTOOLS3_IPK=$(BUILD_DIR)/smstools3_$(SMSTOOLS3_VERSION)-$(SMSTOOLS3_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: smstools3-source smstools3-unpack smstools3 smstools3-stage smstools3-ipk smstools3-clean smstools3-dirclean smstools3-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(SMSTOOLS3_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(SMSTOOLS3_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(SMSTOOLS3_SOURCE).sha512
#
$(DL_DIR)/$(SMSTOOLS3_SOURCE):
	$(WGET) -O $@ $(SMSTOOLS3_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
smstools3-source: $(DL_DIR)/$(SMSTOOLS3_SOURCE) $(SMSTOOLS3_PATCHES)

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
$(SMSTOOLS3_BUILD_DIR)/.configured: $(DL_DIR)/$(SMSTOOLS3_SOURCE) $(SMSTOOLS3_PATCHES) make/smstools3.mk
	$(MAKE) libmm-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(SMSTOOLS3_DIR) $(@D)
	$(SMSTOOLS3_UNZIP) $(DL_DIR)/$(SMSTOOLS3_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SMSTOOLS3_PATCHES)" ; \
		then cat $(SMSTOOLS3_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(SMSTOOLS3_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(SMSTOOLS3_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SMSTOOLS3_DIR) $(@D) ; \
	fi
	touch $@

smstools3-unpack: $(SMSTOOLS3_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SMSTOOLS3_BUILD_DIR)/.built: $(SMSTOOLS3_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/src \
		CC=$(TARGET_CC) \
		CFLAGS="$(STAGING_CPPFLAGS) $(SMSTOOLS3_CPPFLAGS)" \
		LFLAGS="$(STAGING_LDFLAGS) $(SMSTOOLS3_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
smstools3: $(SMSTOOLS3_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(SMSTOOLS3_BUILD_DIR)/.staged: $(SMSTOOLS3_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#smstools3-stage: $(SMSTOOLS3_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/smstools3
#
$(SMSTOOLS3_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: smstools3" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SMSTOOLS3_PRIORITY)" >>$@
	@echo "Section: $(SMSTOOLS3_SECTION)" >>$@
	@echo "Version: $(SMSTOOLS3_VERSION)-$(SMSTOOLS3_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SMSTOOLS3_MAINTAINER)" >>$@
	@echo "Source: $(SMSTOOLS3_URL)" >>$@
	@echo "Description: $(SMSTOOLS3_DESCRIPTION)" >>$@
	@echo "Depends: $(SMSTOOLS3_DEPENDS)" >>$@
	@echo "Suggests: $(SMSTOOLS3_SUGGESTS)" >>$@
	@echo "Conflicts: $(SMSTOOLS3_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SMSTOOLS3_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SMSTOOLS3_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SMSTOOLS3_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SMSTOOLS3_IPK_DIR)$(TARGET_PREFIX)/etc/smstools3/...
# Documentation files should be installed in $(SMSTOOLS3_IPK_DIR)$(TARGET_PREFIX)/doc/smstools3/...
# Daemon startup scripts should be installed in $(SMSTOOLS3_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??smstools3
#
# You may need to patch your application to make it use these locations.
#
$(SMSTOOLS3_IPK): $(SMSTOOLS3_BUILD_DIR)/.built
	rm -rf $(SMSTOOLS3_IPK_DIR) $(BUILD_DIR)/smstools3_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(SMSTOOLS3_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(SMSTOOLS3_BUILD_DIR)/src/smsd $(SMSTOOLS3_IPK_DIR)$(TARGET_PREFIX)/bin
	$(STRIP_COMMAND) $(SMSTOOLS3_IPK_DIR)$(TARGET_PREFIX)/bin/smsd
	$(INSTALL) -m 755 $(SMSTOOLS3_BUILD_DIR)/scripts/{sendsms,sms2html,sms2unicode,unicode2sms} $(SMSTOOLS3_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -d $(SMSTOOLS3_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 644 $(SMSTOOLS3_SOURCE_DIR)/smsd.conf $(SMSTOOLS3_IPK_DIR)$(TARGET_PREFIX)/etc/smsd.conf
	$(INSTALL) -m 755 $(SMSTOOLS3_SOURCE_DIR)/rc.smsd $(SMSTOOLS3_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S89smstools3
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SMSTOOLS3_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXsmstools3
	$(MAKE) $(SMSTOOLS3_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(SMSTOOLS3_SOURCE_DIR)/postinst $(SMSTOOLS3_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SMSTOOLS3_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(SMSTOOLS3_SOURCE_DIR)/prerm $(SMSTOOLS3_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SMSTOOLS3_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SMSTOOLS3_IPK_DIR)/CONTROL/postinst $(SMSTOOLS3_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SMSTOOLS3_CONFFILES) | sed -e 's/ /\n/g' > $(SMSTOOLS3_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SMSTOOLS3_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SMSTOOLS3_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
smstools3-ipk: $(SMSTOOLS3_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
smstools3-clean:
	rm -f $(SMSTOOLS3_BUILD_DIR)/.built
	-$(MAKE) -C $(SMSTOOLS3_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
smstools3-dirclean:
	rm -rf $(BUILD_DIR)/$(SMSTOOLS3_DIR) $(SMSTOOLS3_BUILD_DIR) $(SMSTOOLS3_IPK_DIR) $(SMSTOOLS3_IPK)
#
#
# Some sanity check for the package.
#
smstools3-check: $(SMSTOOLS3_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
