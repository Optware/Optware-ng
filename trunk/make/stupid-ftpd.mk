##########################################################
#
# stupid-ftpd
#
###########################################################
#
# STUPID-FTPD_VERSION, STUPID-FTPD_SITE and STUPID-FTPD_SOURCE define
# the upstream location of the source code for the package.
# STUPID-FTPD_DIR is the directory which is created when the source
# archive is unpacked.
# STUPID-FTPD_UNZIP is the command used to unzip the source.
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
STUPID-FTPD_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/stupid-ftpd
STUPID-FTPD_VERSION=1.5beta
STUPID-FTPD_SOURCE=stupid-ftpd-$(STUPID-FTPD_VERSION).tar.gz
STUPID-FTPD_DIR=stupid-ftpd
STUPID-FTPD_UNZIP=zcat
STUPID-FTPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
STUPID-FTPD_DESCRIPTION=FTP server with ftp-daemon functionality and a command-line mode.
STUPID-FTPD_SECTION=net
STUPID-FTPD_PRIORITY=optional
STUPID-FTPD_DEPENDS=
STUPID-FTPD_SUGGESTS=
STUPID-FTPD_CONFLICTS=

#
# STUPID-FTPD_IPK_VERSION should be incremented when the ipk changes.
#
STUPID-FTPD_IPK_VERSION=1

#
# STUPID-FTPD_CONFFILES should be a list of user-editable files
STUPID-FTPD_CONFFILES=/opt/etc/stupid-ftpd.conf
#/opt/etc/init.d/SXXstupid-ftpd

#
# STUPID-FTPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#STUPID-FTPD_PATCHES=$(STUPID-FTPD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
STUPID-FTPD_CPPFLAGS=
STUPID-FTPD_LDFLAGS=

#
# STUPID-FTPD_BUILD_DIR is the directory in which the build is done.
# STUPID-FTPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# STUPID-FTPD_IPK_DIR is the directory in which the ipk is built.
# STUPID-FTPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
STUPID-FTPD_BUILD_DIR=$(BUILD_DIR)/stupid-ftpd
STUPID-FTPD_SOURCE_DIR=$(SOURCE_DIR)/stupid-ftpd
STUPID-FTPD_IPK_DIR=$(BUILD_DIR)/stupid-ftpd-$(STUPID-FTPD_VERSION)-ipk
STUPID-FTPD_IPK=$(BUILD_DIR)/stupid-ftpd_$(STUPID-FTPD_VERSION)-$(STUPID-FTPD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: stupid-ftpd-source stupid-ftpd-unpack stupid-ftpd stupid-ftpd-stage stupid-ftpd-ipk stupid-ftpd-clean stupid-ftpd-dirclean stupid-ftpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(STUPID-FTPD_SOURCE):
	$(WGET) -P $(@D) $(STUPID-FTPD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
stupid-ftpd-source: $(DL_DIR)/$(STUPID-FTPD_SOURCE) $(STUPID-FTPD_PATCHES)

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
$(STUPID-FTPD_BUILD_DIR)/.configured: $(DL_DIR)/$(STUPID-FTPD_SOURCE) $(STUPID-FTPD_PATCHES) make/stupid-ftpd.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(STUPID-FTPD_DIR) $(@D)
	$(STUPID-FTPD_UNZIP) $(DL_DIR)/$(STUPID-FTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(STUPID-FTPD_PATCHES)" ; \
		then cat $(STUPID-FTPD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(STUPID-FTPD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(STUPID-FTPD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(STUPID-FTPD_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		sed -i -e "/^CC/c \\" -e "CC=$(TARGET_CC)" -e "/^CFLAGS/c \\" \
			-e "CFLAGS=$(STAGING_CPPFLAGS) $(STUPID-FTPD_CPPFLAGS)" \
			-e "/^LIBS/c \\" \
			-e "LIBS=$(STAGING_LDFLAGS) $(STUPID-FTPD_LDFLAGS)" \
			Makefile ; \
		sed -i -e 's|/etc/stupid-ftpd/|/opt/etc/|' ftpdconfig.c stupid-ftpd.conf; \
		sed -i -e 's/port=2121/port=21/' \
			-e 's|serverroot=.*|serverroot=/tmp|' \
			stupid-ftpd.conf; \
	)
	touch $@

stupid-ftpd-unpack: $(STUPID-FTPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(STUPID-FTPD_BUILD_DIR)/.built: $(STUPID-FTPD_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(STAGING_CPPFLAGS) $(STUPID-FTPD_CPPFLAGS)" \
	LIBS="$(STAGING_LDFLAGS) $(STUPID-FTPD_LDFLAGS)" \
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
stupid-ftpd: $(STUPID-FTPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STUPID-FTPD_BUILD_DIR)/.staged: $(STUPID-FTPD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

stupid-ftpd-stage: $(STUPID-FTPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/stupid-ftpd
#
$(STUPID-FTPD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: stupid-ftpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(STUPID-FTPD_PRIORITY)" >>$@
	@echo "Section: $(STUPID-FTPD_SECTION)" >>$@
	@echo "Version: $(STUPID-FTPD_VERSION)-$(STUPID-FTPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(STUPID-FTPD_MAINTAINER)" >>$@
	@echo "Source: $(STUPID-FTPD_SITE)/$(STUPID-FTPD_SOURCE)" >>$@
	@echo "Description: $(STUPID-FTPD_DESCRIPTION)" >>$@
	@echo "Depends: $(STUPID-FTPD_DEPENDS)" >>$@
	@echo "Suggests: $(STUPID-FTPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(STUPID-FTPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(STUPID-FTPD_IPK_DIR)/opt/sbin or $(STUPID-FTPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(STUPID-FTPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(STUPID-FTPD_IPK_DIR)/opt/etc/stupid-ftpd/...
# Documentation files should be installed in $(STUPID-FTPD_IPK_DIR)/opt/doc/stupid-ftpd/...
# Daemon startup scripts should be installed in $(STUPID-FTPD_IPK_DIR)/opt/etc/init.d/S??stupid-ftpd
#
# You may need to patch your application to make it use these locations.
#
$(STUPID-FTPD_IPK): $(STUPID-FTPD_BUILD_DIR)/.built
	rm -rf $(STUPID-FTPD_IPK_DIR) $(BUILD_DIR)/STUPID-FTPD_*_$(TARGET_ARCH).ipk
	install -d $(STUPID-FTPD_IPK_DIR)/opt/sbin/
	install -m 755 $(STUPID-FTPD_BUILD_DIR)/stupid-ftpd.Linux6 \
		$(STUPID-FTPD_IPK_DIR)/opt/sbin/stupid-ftpd
	$(STRIP_COMMAND) $(STUPID-FTPD_IPK_DIR)/opt/sbin/stupid-ftpd
	install -d $(STUPID-FTPD_IPK_DIR)/opt/etc/
	install -m 644 $(STUPID-FTPD_BUILD_DIR)/stupid-ftpd.conf \
		$(STUPID-FTPD_IPK_DIR)/opt/etc/stupid-ftpd.conf
#	install -d $(STUPID-FTPD_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(STUPID-FTPD_SOURCE_DIR)/rc.stupid-ftpd $(STUPID-FTPD_IPK_DIR)/opt/etc/init.d/SXXstupid-ftpd
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(STUPID-FTPD_IPK_DIR)/opt/etc/init.d/SXXstupid-ftpd
	$(MAKE) $(STUPID-FTPD_IPK_DIR)/CONTROL/control
#	install -m 755 $(STUPID-FTPD_SOURCE_DIR)/postinst $(STUPID-FTPD_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(STUPID-FTPD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(STUPID-FTPD_SOURCE_DIR)/prerm $(STUPID-FTPD_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(STUPID-FTPD_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(STUPID-FTPD_IPK_DIR)/CONTROL/postinst $(STUPID-FTPD_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(STUPID-FTPD_CONFFILES) | sed -e 's/ /\n/g' > $(STUPID-FTPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(STUPID-FTPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
stupid-ftpd-ipk: $(STUPID-FTPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
stupid-ftpd-clean:
	rm -f $(STUPID-FTPD_BUILD_DIR)/.built
	-$(MAKE) -C $(STUPID-FTPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
stupid-ftpd-dirclean:
	rm -rf $(BUILD_DIR)/$(STUPID-FTPD_DIR) $(STUPID-FTPD_BUILD_DIR) $(STUPID-FTPD_IPK_DIR) $(STUPID-FTPD_IPK)
#
#
# Some sanity check for the package.
#
stupid-ftpd-check: $(STUPID-FTPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(STUPID-FTPD_IPK)
