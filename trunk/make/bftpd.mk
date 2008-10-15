###########################################################
#
# bftpd
#
###########################################################
#
# BFTPD_VERSION, BFTPD_SITE and BFTPD_SOURCE define
# the upstream location of the source code for the package.
# BFTPD_DIR is the directory which is created when the source
# archive is unpacked.
# BFTPD_UNZIP is the command used to unzip the source.
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
BFTPD_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/bftpd
BFTPD_VERSION=2.3
BFTPD_SOURCE=bftpd-$(BFTPD_VERSION).tar.gz
BFTPD_DIR=bftpd
BFTPD_UNZIP=zcat
BFTPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BFTPD_DESCRIPTION=bftpd is a very configurable Linux FTP server which can do chroot without special configuration or directory preparation.
BFTPD_SECTION=net
BFTPD_PRIORITY=optional
BFTPD_DEPENDS=zlib
BFTPD_SUGGESTS=
BFTPD_CONFLICTS=

#
# BFTPD_IPK_VERSION should be incremented when the ipk changes.
#
BFTPD_IPK_VERSION=1

#
# BFTPD_CONFFILES should be a list of user-editable files
BFTPD_CONFFILES=/opt/etc/bftpd.conf

#
# BFTPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BFTPD_PATCHES=$(BFTPD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BFTPD_CPPFLAGS=
BFTPD_LDFLAGS=

#
# BFTPD_BUILD_DIR is the directory in which the build is done.
# BFTPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BFTPD_IPK_DIR is the directory in which the ipk is built.
# BFTPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BFTPD_BUILD_DIR=$(BUILD_DIR)/bftpd
BFTPD_SOURCE_DIR=$(SOURCE_DIR)/bftpd
BFTPD_IPK_DIR=$(BUILD_DIR)/bftpd-$(BFTPD_VERSION)-ipk
BFTPD_IPK=$(BUILD_DIR)/bftpd_$(BFTPD_VERSION)-$(BFTPD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bftpd-source bftpd-unpack bftpd bftpd-stage bftpd-ipk bftpd-clean bftpd-dirclean bftpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BFTPD_SOURCE):
	$(WGET) -P $(@D) $(BFTPD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bftpd-source: $(DL_DIR)/$(BFTPD_SOURCE) $(BFTPD_PATCHES)

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
$(BFTPD_BUILD_DIR)/.configured: $(DL_DIR)/$(BFTPD_SOURCE) $(BFTPD_PATCHES) make/bftpd.mk
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(BFTPD_DIR) $(BFTPD_BUILD_DIR)
	$(BFTPD_UNZIP) $(DL_DIR)/$(BFTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BFTPD_PATCHES)" ; \
		then cat $(BFTPD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(BFTPD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(BFTPD_DIR)" != "$(BFTPD_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(BFTPD_DIR) $(BFTPD_BUILD_DIR) ; \
	fi
	sed -i -e '/INSTALL/s/-[go] 0//g' \
	       -e 's| /var/| $$(DESTDIR)/opt/var/|' \
	       -e '/^CFLAGS/s|$$| $$(CPPFLAGS)|' \
	       -e 's|/etc/|/opt/etc/|g' \
		$(BFTPD_BUILD_DIR)/Makefile.in
	sed -i -e 's|/etc/|/opt/etc/|g' $(BFTPD_BUILD_DIR)/mypaths.h
	(cd $(BFTPD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BFTPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BFTPD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--sysconfdir=/opt/etc \
		--localstatedir=/opt/var \
		--enable-libz \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(BFTPD_BUILD_DIR)/libtool
	touch $@

bftpd-unpack: $(BFTPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BFTPD_BUILD_DIR)/.built: $(BFTPD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(BFTPD_BUILD_DIR) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BFTPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BFTPD_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
bftpd: $(BFTPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BFTPD_BUILD_DIR)/.staged: $(BFTPD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(BFTPD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

bftpd-stage: $(BFTPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bftpd
#
$(BFTPD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: bftpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BFTPD_PRIORITY)" >>$@
	@echo "Section: $(BFTPD_SECTION)" >>$@
	@echo "Version: $(BFTPD_VERSION)-$(BFTPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BFTPD_MAINTAINER)" >>$@
	@echo "Source: $(BFTPD_SITE)/$(BFTPD_SOURCE)" >>$@
	@echo "Description: $(BFTPD_DESCRIPTION)" >>$@
	@echo "Depends: $(BFTPD_DEPENDS)" >>$@
	@echo "Suggests: $(BFTPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(BFTPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BFTPD_IPK_DIR)/opt/sbin or $(BFTPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BFTPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BFTPD_IPK_DIR)/opt/etc/bftpd/...
# Documentation files should be installed in $(BFTPD_IPK_DIR)/opt/doc/bftpd/...
# Daemon startup scripts should be installed in $(BFTPD_IPK_DIR)/opt/etc/init.d/S??bftpd
#
# You may need to patch your application to make it use these locations.
#
$(BFTPD_IPK): $(BFTPD_BUILD_DIR)/.built
	rm -rf $(BFTPD_IPK_DIR) $(BUILD_DIR)/bftpd_*_$(TARGET_ARCH).ipk
	install -d $(BFTPD_IPK_DIR)/opt/etc
	install -d $(BFTPD_IPK_DIR)/opt/sbin
	install -d $(BFTPD_IPK_DIR)/opt/man/man8
	install -d $(BFTPD_IPK_DIR)/opt/var/log
	touch $(BFTPD_IPK_DIR)/opt/etc/bftpd.conf
	$(MAKE) -C $(BFTPD_BUILD_DIR) DESTDIR=$(BFTPD_IPK_DIR) install
	$(STRIP_COMMAND) $(BFTPD_IPK_DIR)/opt/sbin/bftpd
	rm -f $(BFTPD_IPK_DIR)/opt/var/log/bftpd.log
#	install -d $(BFTPD_IPK_DIR)/opt/etc/
#	install -m 644 $(BFTPD_SOURCE_DIR)/bftpd.conf $(BFTPD_IPK_DIR)/opt/etc/bftpd.conf
#	install -d $(BFTPD_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(BFTPD_SOURCE_DIR)/rc.bftpd $(BFTPD_IPK_DIR)/opt/etc/init.d/SXXbftpd
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(BFTPD_IPK_DIR)/opt/etc/init.d/SXXbftpd
	$(MAKE) $(BFTPD_IPK_DIR)/CONTROL/control
#	install -m 755 $(BFTPD_SOURCE_DIR)/postinst $(BFTPD_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(BFTPD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(BFTPD_SOURCE_DIR)/prerm $(BFTPD_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(BFTPD_IPK_DIR)/CONTROL/prerm
	echo $(BFTPD_CONFFILES) | sed -e 's/ /\n/g' > $(BFTPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BFTPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bftpd-ipk: $(BFTPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bftpd-clean:
	rm -f $(BFTPD_BUILD_DIR)/.built
	-$(MAKE) -C $(BFTPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bftpd-dirclean:
	rm -rf $(BUILD_DIR)/$(BFTPD_DIR) $(BFTPD_BUILD_DIR) $(BFTPD_IPK_DIR) $(BFTPD_IPK)
#
#
# Some sanity check for the package.
#
bftpd-check: $(BFTPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BFTPD_IPK)
