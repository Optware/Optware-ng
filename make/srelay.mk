###########################################################
#
# srelay
#
###########################################################
#
# SRELAY_VERSION, SRELAY_SITE and SRELAY_SOURCE define
# the upstream location of the source code for the package.
# SRELAY_DIR is the directory which is created when the source
# archive is unpacked.
# SRELAY_UNZIP is the command used to unzip the source.
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
SRELAY_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/socks-relay
SRELAY_VERSION=0.4.6
SRELAY_SOURCE=srelay-$(SRELAY_VERSION).tar.gz
SRELAY_DIR=srelay-$(SRELAY_VERSION)
SRELAY_UNZIP=zcat
SRELAY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SRELAY_DESCRIPTION=Socks proxy server.
SRELAY_SECTION=net
SRELAY_PRIORITY=optional
SRELAY_DEPENDS=
SRELAY_SUGGESTS=
SRELAY_CONFLICTS=

#
# SRELAY_IPK_VERSION should be incremented when the ipk changes.
#
SRELAY_IPK_VERSION=1

#
# SRELAY_CONFFILES should be a list of user-editable files
SRELAY_CONFFILES=/opt/etc/srelay.conf

#
# SRELAY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SRELAY_PATCHES=$(SRELAY_SOURCE_DIR)/configure.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SRELAY_CPPFLAGS=-DLINUX
SRELAY_LDFLAGS=

#
# SRELAY_BUILD_DIR is the directory in which the build is done.
# SRELAY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SRELAY_IPK_DIR is the directory in which the ipk is built.
# SRELAY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SRELAY_BUILD_DIR=$(BUILD_DIR)/srelay
SRELAY_SOURCE_DIR=$(SOURCE_DIR)/srelay
SRELAY_IPK_DIR=$(BUILD_DIR)/srelay-$(SRELAY_VERSION)-ipk
SRELAY_IPK=$(BUILD_DIR)/srelay_$(SRELAY_VERSION)-$(SRELAY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: srelay-source srelay-unpack srelay srelay-stage srelay-ipk srelay-clean srelay-dirclean srelay-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SRELAY_SOURCE):
	$(WGET) -P $(DL_DIR) $(SRELAY_SITE)/$(SRELAY_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
srelay-source: $(DL_DIR)/$(SRELAY_SOURCE) $(SRELAY_PATCHES)

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
$(SRELAY_BUILD_DIR)/.configured: $(DL_DIR)/$(SRELAY_SOURCE) $(SRELAY_PATCHES) make/srelay.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SRELAY_DIR) $(SRELAY_BUILD_DIR)
	$(SRELAY_UNZIP) $(DL_DIR)/$(SRELAY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SRELAY_PATCHES)" ; \
		then cat $(SRELAY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SRELAY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SRELAY_DIR)" != "$(SRELAY_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SRELAY_DIR) $(SRELAY_BUILD_DIR) ; \
	fi
	(cd $(SRELAY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SRELAY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SRELAY_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-thread \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(SRELAY_BUILD_DIR)/libtool
	touch $(SRELAY_BUILD_DIR)/.configured

srelay-unpack: $(SRELAY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SRELAY_BUILD_DIR)/.built: $(SRELAY_BUILD_DIR)/.configured
	rm -f $(SRELAY_BUILD_DIR)/.built
	$(MAKE) -C $(SRELAY_BUILD_DIR)
	touch $(SRELAY_BUILD_DIR)/.built

#
# This is the build convenience target.
#
srelay: $(SRELAY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SRELAY_BUILD_DIR)/.staged: $(SRELAY_BUILD_DIR)/.built
	rm -f $(SRELAY_BUILD_DIR)/.staged
	$(MAKE) -C $(SRELAY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SRELAY_BUILD_DIR)/.staged

srelay-stage: $(SRELAY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/srelay
#
$(SRELAY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: srelay" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SRELAY_PRIORITY)" >>$@
	@echo "Section: $(SRELAY_SECTION)" >>$@
	@echo "Version: $(SRELAY_VERSION)-$(SRELAY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SRELAY_MAINTAINER)" >>$@
	@echo "Source: $(SRELAY_SITE)/$(SRELAY_SOURCE)" >>$@
	@echo "Description: $(SRELAY_DESCRIPTION)" >>$@
	@echo "Depends: $(SRELAY_DEPENDS)" >>$@
	@echo "Suggests: $(SRELAY_SUGGESTS)" >>$@
	@echo "Conflicts: $(SRELAY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SRELAY_IPK_DIR)/opt/sbin or $(SRELAY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SRELAY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SRELAY_IPK_DIR)/opt/etc/srelay/...
# Documentation files should be installed in $(SRELAY_IPK_DIR)/opt/doc/srelay/...
# Daemon startup scripts should be installed in $(SRELAY_IPK_DIR)/opt/etc/init.d/S??srelay
#
# You may need to patch your application to make it use these locations.
#
$(SRELAY_IPK): $(SRELAY_BUILD_DIR)/.built
	rm -rf $(SRELAY_IPK_DIR) $(BUILD_DIR)/srelay_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(SRELAY_BUILD_DIR) DESTDIR=$(SRELAY_IPK_DIR) install
	install -d $(SRELAY_IPK_DIR)/opt/etc/ $(SRELAY_IPK_DIR)/opt/bin/ $(SRELAY_IPK_DIR)/opt/share/man/man8/
	install -m 644 $(SRELAY_BUILD_DIR)/srelay.conf $(SRELAY_IPK_DIR)/opt/etc/
	install -m 755 $(SRELAY_BUILD_DIR)/srelay $(SRELAY_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(SRELAY_IPK_DIR)/opt/bin/srelay
	install -m 644 $(SRELAY_BUILD_DIR)/srelay.8 $(SRELAY_IPK_DIR)/opt/share/man/man8/
#	install -d $(SRELAY_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SRELAY_SOURCE_DIR)/rc.srelay $(SRELAY_IPK_DIR)/opt/etc/init.d/SXXsrelay
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXsrelay
	$(MAKE) $(SRELAY_IPK_DIR)/CONTROL/control
#	install -m 755 $(SRELAY_SOURCE_DIR)/postinst $(SRELAY_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SRELAY_SOURCE_DIR)/prerm $(SRELAY_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(SRELAY_CONFFILES) | sed -e 's/ /\n/g' > $(SRELAY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SRELAY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
srelay-ipk: $(SRELAY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
srelay-clean:
	rm -f $(SRELAY_BUILD_DIR)/.built
	-$(MAKE) -C $(SRELAY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
srelay-dirclean:
	rm -rf $(BUILD_DIR)/$(SRELAY_DIR) $(SRELAY_BUILD_DIR) $(SRELAY_IPK_DIR) $(SRELAY_IPK)
#
#
# Some sanity check for the package.
#
srelay-check: $(SRELAY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SRELAY_IPK)
