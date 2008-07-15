##########################################################
#
# stupid-ftpd
#
###########################################################
#
# stupid-ftpd_VERSION, stupid-ftpd_SITE and stupid-ftpd_SOURCE define
# the upstream location of the source code for the package.
# stupid-ftpd_DIR is the directory which is created when the source
# archive is unpacked.
# stupid-ftpd_UNZIP is the command used to unzip the source.
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
stupid-ftpd_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/stupid-ftpd
stupid-ftpd_VERSION=1.5beta
stupid-ftpd_SOURCE=stupid-ftpd-$(stupid-ftpd_VERSION).tar.gz
stupid-ftpd_DIR=stupid-ftpd
stupid-ftpd_UNZIP=zcat
stupid-ftpd_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
stupid-ftpd_DESCRIPTION=FTP server with ftp-daemon functionality and a command-line mode.
stupid-ftpd_SECTION=net
stupid-ftpd_PRIORITY=optional
stupid-ftpd_DEPENDS=
stupid-ftpd_SUGGESTS=
stupid-ftpd_CONFLICTS=

#
# stupid-ftpd_IPK_VERSION should be incremented when the ipk changes.
#
stupid-ftpd_IPK_VERSION=1

#
# stupid-ftpd_CONFFILES should be a list of user-editable files
stupid-ftpd_CONFFILES=/opt/etc/stupid-ftpd.conf
#/opt/etc/init.d/SXXstupid-ftpd

#
# stupid-ftpd_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#stupid-ftpd_PATCHES=$(stupid-ftpd_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
stupid-ftpd_CPPFLAGS=
stupid-ftpd_LDFLAGS=

#
# stupid-ftpd_BUILD_DIR is the directory in which the build is done.
# stupid-ftpd_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# stupid-ftpd_IPK_DIR is the directory in which the ipk is built.
# stupid-ftpd_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
stupid-ftpd_BUILD_DIR=$(BUILD_DIR)/stupid-ftpd
stupid-ftpd_SOURCE_DIR=$(SOURCE_DIR)/stupid-ftpd
stupid-ftpd_IPK_DIR=$(BUILD_DIR)/stupid-ftpd-$(stupid-ftpd_VERSION)-ipk
stupid-ftpd_IPK=$(BUILD_DIR)/stupid-ftpd_$(stupid-ftpd_VERSION)-$(stupid-ftpd_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: stupid-ftpd-source stupid-ftpd-unpack stupid-ftpd stupid-ftpd-stage stupid-ftpd-ipk stupid-ftpd-clean stupid-ftpd-dirclean stupid-ftpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(stupid-ftpd_SOURCE):
	$(WGET) -P $(@D) $(stupid-ftpd_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
stupid-ftpd-source: $(DL_DIR)/$(stupid-ftpd_SOURCE) $(stupid-ftpd_PATCHES)

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
$(stupid-ftpd_BUILD_DIR)/.configured: $(DL_DIR)/$(stupid-ftpd_SOURCE) $(stupid-ftpd_PATCHES) make/stupid-ftpd.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(stupid-ftpd_DIR) $(@D)
	$(stupid-ftpd_UNZIP) $(DL_DIR)/$(stupid-ftpd_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(stupid-ftpd_PATCHES)" ; \
		then cat $(stupid-ftpd_PATCHES) | \
		patch -d $(BUILD_DIR)/$(stupid-ftpd_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(stupid-ftpd_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(stupid-ftpd_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		sed -i -e "/^CC/c \\" -e "CC=$(TARGET_CC)" -e "/^CFLAGS/c \\" \
			-e "CFLAGS=$(STAGING_CPPFLAGS) $(stupid-ftpd_CPPFLAGS)" \
			-e "/^LIBS/c \\" \
			-e "LIBS=$(STAGING_LDFLAGS) $(stupid-ftpd_LDFLAGS)" \
			Makefile ; \
		sed -i -e 's|/etc/stupid-ftpd/|/opt/etc/|' ftpdconfig.c stupid-ftpd.conf; \
		sed -i -e 's/port=2121/port=21/' \
			-e 's|serverroot=.*|serverroot=/tmp|' \
			stupid-ftpd.conf; \
	)
	touch $@

stupid-ftpd-unpack: $(stupid-ftpd_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(stupid-ftpd_BUILD_DIR)/.built: $(stupid-ftpd_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(STAGING_CPPFLAGS) $(stupid-ftpd_CPPFLAGS)" \
	LIBS="$(STAGING_LDFLAGS) $(stupid-ftpd_LDFLAGS)" \
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
stupid-ftpd: $(stupid-ftpd_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(stupid-ftpd_BUILD_DIR)/.staged: $(stupid-ftpd_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

stupid-ftpd-stage: $(stupid-ftpd_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/stupid-ftpd
#
$(stupid-ftpd_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: stupid-ftpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(stupid-ftpd_PRIORITY)" >>$@
	@echo "Section: $(stupid-ftpd_SECTION)" >>$@
	@echo "Version: $(stupid-ftpd_VERSION)-$(stupid-ftpd_IPK_VERSION)" >>$@
	@echo "Maintainer: $(stupid-ftpd_MAINTAINER)" >>$@
	@echo "Source: $(stupid-ftpd_SITE)/$(stupid-ftpd_SOURCE)" >>$@
	@echo "Description: $(stupid-ftpd_DESCRIPTION)" >>$@
	@echo "Depends: $(stupid-ftpd_DEPENDS)" >>$@
	@echo "Suggests: $(stupid-ftpd_SUGGESTS)" >>$@
	@echo "Conflicts: $(stupid-ftpd_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(stupid-ftpd_IPK_DIR)/opt/sbin or $(stupid-ftpd_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(stupid-ftpd_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(stupid-ftpd_IPK_DIR)/opt/etc/stupid-ftpd/...
# Documentation files should be installed in $(stupid-ftpd_IPK_DIR)/opt/doc/stupid-ftpd/...
# Daemon startup scripts should be installed in $(stupid-ftpd_IPK_DIR)/opt/etc/init.d/S??stupid-ftpd
#
# You may need to patch your application to make it use these locations.
#
$(stupid-ftpd_IPK): $(stupid-ftpd_BUILD_DIR)/.built
	rm -rf $(stupid-ftpd_IPK_DIR) $(BUILD_DIR)/stupid-ftpd_*_$(TARGET_ARCH).ipk
	install -d $(stupid-ftpd_IPK_DIR)/opt/sbin/
	install -m 755 $(stupid-ftpd_BUILD_DIR)/stupid-ftpd.Linux6 \
		$(stupid-ftpd_IPK_DIR)/opt/sbin/stupid-ftpd
	$(STRIP_COMMAND) $(stupid-ftpd_IPK_DIR)/opt/sbin/stupid-ftpd
	install -d $(stupid-ftpd_IPK_DIR)/opt/etc/
	install -m 644 $(stupid-ftpd_BUILD_DIR)/stupid-ftpd.conf \
		$(stupid-ftpd_IPK_DIR)/opt/etc/stupid-ftpd.conf
#	install -d $(stupid-ftpd_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(stupid-ftpd_SOURCE_DIR)/rc.stupid-ftpd $(stupid-ftpd_IPK_DIR)/opt/etc/init.d/SXXstupid-ftpd
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(stupid-ftpd_IPK_DIR)/opt/etc/init.d/SXXstupid-ftpd
	$(MAKE) $(stupid-ftpd_IPK_DIR)/CONTROL/control
#	install -m 755 $(stupid-ftpd_SOURCE_DIR)/postinst $(stupid-ftpd_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(stupid-ftpd_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(stupid-ftpd_SOURCE_DIR)/prerm $(stupid-ftpd_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(stupid-ftpd_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(stupid-ftpd_IPK_DIR)/CONTROL/postinst $(stupid-ftpd_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(stupid-ftpd_CONFFILES) | sed -e 's/ /\n/g' > $(stupid-ftpd_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(stupid-ftpd_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
stupid-ftpd-ipk: $(stupid-ftpd_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
stupid-ftpd-clean:
	rm -f $(stupid-ftpd_BUILD_DIR)/.built
	-$(MAKE) -C $(stupid-ftpd_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
stupid-ftpd-dirclean:
	rm -rf $(BUILD_DIR)/$(stupid-ftpd_DIR) $(stupid-ftpd_BUILD_DIR) $(stupid-ftpd_IPK_DIR) $(stupid-ftpd_IPK)
#
#
# Some sanity check for the package.
#
stupid-ftpd-check: $(stupid-ftpd_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(stupid-ftpd_IPK)
