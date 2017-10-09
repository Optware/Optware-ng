###########################################################
#
# oscam
#
###########################################################
#
# OSCAM_VERSION, OSCAM_SITE and OSCAM_SOURCE define
# the upstream location of the source code for the package.
# OSCAM_DIR is the directory which is created when the source
# archive is unpacked.
# OSCAM_UNZIP is the command used to unzip the source.
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
OSCAM_SVN=http://www.streamboard.tv/svn/oscam/trunk
OSCAM_REVISION=11160
OSCAM_VERSION=1.20-rev$(OSCAM_REVISION)
OSCAM_SOURCE=oscam-$(OSCAM_VERSION).tar.bz2
OSCAM_DIR=oscam-$(OSCAM_VERSION)
OSCAM_UNZIP=bzcat
OSCAM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OSCAM_DESCRIPTION=OSCam is an Open Source Conditional Access Module software, based on the very good MpCS version 0.9d created by ​dukat.
OSCAM_DOCS_DESCRIPTION=OSCam docs: man pages, examples and html/txt
OSCAM_SECTION=misc
OSCAM_PRIORITY=optional
OSCAM_DEPENDS=openssl, libusb1, pcsc-lite
OSCAM_SUGGESTS=
OSCAM_CONFLICTS=

#
# OSCAM_IPK_VERSION should be incremented when the ipk changes.
#
OSCAM_IPK_VERSION=3

#
# OSCAM_CONFFILES should be a list of user-editable files
OSCAM_CONFFILES=$(TARGET_PREFIX)/etc/init.d/S30oscam

#
# OSCAM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#OSCAM_PATCHES=$(OSCAM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OSCAM_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/libusb-1.0 -I$(STAGING_INCLUDE_DIR)/PCSC
OSCAM_LDFLAGS=

#
# OSCAM_BUILD_DIR is the directory in which the build is done.
# OSCAM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OSCAM_IPK_DIR is the directory in which the ipk is built.
# OSCAM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OSCAM_BUILD_DIR=$(BUILD_DIR)/oscam
OSCAM_SOURCE_DIR=$(SOURCE_DIR)/oscam

OSCAM_IPK_DIR=$(BUILD_DIR)/oscam-$(OSCAM_VERSION)-ipk
OSCAM_IPK=$(BUILD_DIR)/oscam_$(OSCAM_VERSION)-$(OSCAM_IPK_VERSION)_$(TARGET_ARCH).ipk

OSCAM_DOCS_IPK_DIR=$(BUILD_DIR)/oscam-docs-$(OSCAM_VERSION)-ipk
OSCAM_DOCS_IPK=$(BUILD_DIR)/oscam-docs_$(OSCAM_VERSION)-$(OSCAM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: oscam-source oscam-unpack oscam oscam-stage oscam-ipk oscam-clean oscam-dirclean oscam-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using svn.
#
$(DL_DIR)/$(OSCAM_SOURCE):
	( cd $(BUILD_DIR) ; \
		rm -rf $(OSCAM_DIR) && \
		svn co -r $(OSCAM_REVISION) $(OSCAM_SVN) \
			$(OSCAM_DIR) && \
		tar -cjf $@ --exclude .svn $(OSCAM_DIR) && \
		rm -rf $(OSCAM_DIR) \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
oscam-source: $(DL_DIR)/$(OSCAM_SOURCE) $(OSCAM_PATCHES)

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
$(OSCAM_BUILD_DIR)/.configured: $(DL_DIR)/$(OSCAM_SOURCE) $(OSCAM_PATCHES) make/oscam.mk
	$(MAKE) openssl-stage libusb1-stage pcsc-lite-stage
	rm -rf $(BUILD_DIR)/$(OSCAM_DIR) $(@D)
	$(OSCAM_UNZIP) $(DL_DIR)/$(OSCAM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(OSCAM_PATCHES)" ; \
		then cat $(OSCAM_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(OSCAM_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(OSCAM_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(OSCAM_DIR) $(@D) ; \
	fi
	touch $@

oscam-unpack: $(OSCAM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OSCAM_BUILD_DIR)/.built: $(OSCAM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		CROSS=$(TARGET_CROSS) \
		HOSTCC=$(HOSTCC) \
		CONF_DIR=$(TARGET_PREFIX)/etc/oscam \
		USE_LIBUSB=1 LIBUSB_LIB="-lusb-1.0 -pthread" USE_PCSC=1 USE_SSL=1 \
		EXTRA_CFLAGS="$(STAGING_CPPFLAGS) $(OSCAM_CPPFLAGS)" \
		EXTRA_LDFLAGS="$(STAGING_LDFLAGS) $(OSCAM_LDFLAGS)" \
		OSCAM_BIN=oscam \
		LIST_SMARGO_BIN=list_smargo
	touch $@

#
# This is the build convenience target.
#
oscam: $(OSCAM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OSCAM_BUILD_DIR)/.staged: $(OSCAM_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

oscam-stage: $(OSCAM_BUILD_DIR)/.staged

#
# This rule creates a control files for ipkg
#
$(OSCAM_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: oscam" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OSCAM_PRIORITY)" >>$@
	@echo "Section: $(OSCAM_SECTION)" >>$@
	@echo "Version: $(OSCAM_VERSION)-$(OSCAM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OSCAM_MAINTAINER)" >>$@
	@echo "Source: $(OSCAM_SVN)" >>$@
	@echo "Description: $(OSCAM_DESCRIPTION)" >>$@
	@echo "Depends: $(OSCAM_DEPENDS)" >>$@
	@echo "Suggests: $(OSCAM_SUGGESTS)" >>$@
	@echo "Conflicts: $(OSCAM_CONFLICTS)" >>$@

$(OSCAM_DOCS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: oscam-docs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OSCAM_PRIORITY)" >>$@
	@echo "Section: $(OSCAM_SECTION)" >>$@
	@echo "Version: $(OSCAM_VERSION)-$(OSCAM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OSCAM_MAINTAINER)" >>$@
	@echo "Source: $(OSCAM_SVN)" >>$@
	@echo "Description: $(OSCAM_DOCS_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
	@echo "Suggests: oscam" >>$@
	@echo "Conflicts: " >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OSCAM_IPK_DIR)$(TARGET_PREFIX)/sbin or $(OSCAM_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OSCAM_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(OSCAM_IPK_DIR)$(TARGET_PREFIX)/etc/oscam/...
# Documentation files should be installed in $(OSCAM_IPK_DIR)$(TARGET_PREFIX)/doc/oscam/...
# Daemon startup scripts should be installed in $(OSCAM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??oscam
#
# You may need to patch your application to make it use these locations.
#
$(OSCAM_IPK): $(OSCAM_BUILD_DIR)/.built
	rm -rf $(OSCAM_IPK_DIR) $(BUILD_DIR)/oscam_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(OSCAM_IPK_DIR)$(TARGET_PREFIX)/{bin,etc/init.d}
	$(INSTALL) -m 755 $(OSCAM_BUILD_DIR)/oscam $(OSCAM_BUILD_DIR)/list_smargo \
		$(OSCAM_IPK_DIR)$(TARGET_PREFIX)/bin
	$(STRIP_COMMAND) $(OSCAM_IPK_DIR)$(TARGET_PREFIX)/bin/*
	$(INSTALL) -m 755 $(OSCAM_SOURCE_DIR)/rc.oscam $(OSCAM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S30oscam
	$(MAKE) $(OSCAM_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(OSCAM_SOURCE_DIR)/postinst $(OSCAM_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(OSCAM_SOURCE_DIR)/prerm $(OSCAM_IPK_DIR)/CONTROL/prerm
	echo $(OSCAM_CONFFILES) | sed -e 's/ /\n/g' > $(OSCAM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OSCAM_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(OSCAM_IPK_DIR)

$(OSCAM_DOCS_IPK): $(OSCAM_BUILD_DIR)/.built
	rm -rf $(OSCAM_DOCS_IPK_DIR) $(BUILD_DIR)/oscam-docs_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d 	$(OSCAM_DOCS_IPK_DIR)$(TARGET_PREFIX)/share/man/man{1,5} \
			$(OSCAM_DOCS_IPK_DIR)$(TARGET_PREFIX)/share/doc/oscam
	$(INSTALL) -m 644 	$(OSCAM_BUILD_DIR)/Distribution/doc/man/*.1 \
				$(OSCAM_DOCS_IPK_DIR)$(TARGET_PREFIX)/share/man/man1
	$(INSTALL) -m 644 	$(OSCAM_BUILD_DIR)/Distribution/doc/man/*.5 \
				$(OSCAM_DOCS_IPK_DIR)$(TARGET_PREFIX)/share/man/man5
	cp -af 	$(OSCAM_BUILD_DIR)/Distribution/doc/{example,html,txt} \
		$(OSCAM_DOCS_IPK_DIR)$(TARGET_PREFIX)/share/doc/oscam
	$(MAKE) $(OSCAM_DOCS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OSCAM_DOCS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(OSCAM_DOCS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
oscam-ipk: $(OSCAM_IPK) $(OSCAM_DOCS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
oscam-clean:
	rm -f $(OSCAM_BUILD_DIR)/.built
	-$(MAKE) -C $(OSCAM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
oscam-dirclean:
	rm -rf 	$(BUILD_DIR)/$(OSCAM_DIR) $(OSCAM_BUILD_DIR) \
		$(OSCAM_IPK_DIR) $(OSCAM_IPK) \
		$(OSCAM_DOCS_IPK_DIR) $(OSCAM_DOCS_IPK)
#
#
# Some sanity check for the package.
#
oscam-check: $(OSCAM_IPK) $(OSCAM_DOCS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
