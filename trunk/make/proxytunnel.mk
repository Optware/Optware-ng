###########################################################
#
# proxytunnel
#
###########################################################
#
# PROXYTUNNEL_VERSION, PROXYTUNNEL_SITE and PROXYTUNNEL_SOURCE define
# the upstream location of the source code for the package.
# PROXYTUNNEL_DIR is the directory which is created when the source
# archive is unpacked.
# PROXYTUNNEL_UNZIP is the command used to unzip the source.
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
PROXYTUNNEL_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/proxytunnel
PROXYTUNNEL_VERSION=1.9.0
PROXYTUNNEL_SOURCE=proxytunnel-$(PROXYTUNNEL_VERSION).tgz
PROXYTUNNEL_DIR=proxytunnel-$(PROXYTUNNEL_VERSION)
PROXYTUNNEL_UNZIP=zcat
PROXYTUNNEL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PROXYTUNNEL_DESCRIPTION=ProxyTunnel is a program that connects stdin and stdout to a server somewhere on the network, through a standard HTTPS proxy.
PROXYTUNNEL_SECTION=net
PROXYTUNNEL_PRIORITY=optional
PROXYTUNNEL_DEPENDS=openssl
PROXYTUNNEL_SUGGESTS=
PROXYTUNNEL_CONFLICTS=

#
# PROXYTUNNEL_IPK_VERSION should be incremented when the ipk changes.
#
PROXYTUNNEL_IPK_VERSION=1

#
# PROXYTUNNEL_CONFFILES should be a list of user-editable files
#PROXYTUNNEL_CONFFILES=/opt/etc/proxytunnel.conf /opt/etc/init.d/SXXproxytunnel

#
# PROXYTUNNEL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PROXYTUNNEL_PATCHES=$(PROXYTUNNEL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PROXYTUNNEL_CPPFLAGS=
PROXYTUNNEL_LDFLAGS=-lssl -lcrypto

#
# PROXYTUNNEL_BUILD_DIR is the directory in which the build is done.
# PROXYTUNNEL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PROXYTUNNEL_IPK_DIR is the directory in which the ipk is built.
# PROXYTUNNEL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PROXYTUNNEL_BUILD_DIR=$(BUILD_DIR)/proxytunnel
PROXYTUNNEL_SOURCE_DIR=$(SOURCE_DIR)/proxytunnel
PROXYTUNNEL_IPK_DIR=$(BUILD_DIR)/proxytunnel-$(PROXYTUNNEL_VERSION)-ipk
PROXYTUNNEL_IPK=$(BUILD_DIR)/proxytunnel_$(PROXYTUNNEL_VERSION)-$(PROXYTUNNEL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: proxytunnel-source proxytunnel-unpack proxytunnel proxytunnel-stage proxytunnel-ipk proxytunnel-clean proxytunnel-dirclean proxytunnel-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PROXYTUNNEL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PROXYTUNNEL_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
proxytunnel-source: $(DL_DIR)/$(PROXYTUNNEL_SOURCE) $(PROXYTUNNEL_PATCHES)

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
$(PROXYTUNNEL_BUILD_DIR)/.configured: $(DL_DIR)/$(PROXYTUNNEL_SOURCE) $(PROXYTUNNEL_PATCHES) make/proxytunnel.mk
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(PROXYTUNNEL_DIR) $(@D)
	$(PROXYTUNNEL_UNZIP) $(DL_DIR)/$(PROXYTUNNEL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PROXYTUNNEL_PATCHES)" ; \
		then cat $(PROXYTUNNEL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PROXYTUNNEL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PROXYTUNNEL_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PROXYTUNNEL_DIR) $(@D) ; \
	fi
	sed -i -e '/^CFLAGS/s|= *|&$$(CPPFLAGS) |' $(@D)/Makefile
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PROXYTUNNEL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PROXYTUNNEL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

proxytunnel-unpack: $(PROXYTUNNEL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PROXYTUNNEL_BUILD_DIR)/.built: $(PROXYTUNNEL_BUILD_DIR)/.configured
	rm -f $@
	PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PROXYTUNNEL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PROXYTUNNEL_LDFLAGS)" \
		PREFIX=/opt \
		;
	touch $@

#
# This is the build convenience target.
#
proxytunnel: $(PROXYTUNNEL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PROXYTUNNEL_BUILD_DIR)/.staged: $(PROXYTUNNEL_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

proxytunnel-stage: $(PROXYTUNNEL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/proxytunnel
#
$(PROXYTUNNEL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: proxytunnel" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PROXYTUNNEL_PRIORITY)" >>$@
	@echo "Section: $(PROXYTUNNEL_SECTION)" >>$@
	@echo "Version: $(PROXYTUNNEL_VERSION)-$(PROXYTUNNEL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PROXYTUNNEL_MAINTAINER)" >>$@
	@echo "Source: $(PROXYTUNNEL_SITE)/$(PROXYTUNNEL_SOURCE)" >>$@
	@echo "Description: $(PROXYTUNNEL_DESCRIPTION)" >>$@
	@echo "Depends: $(PROXYTUNNEL_DEPENDS)" >>$@
	@echo "Suggests: $(PROXYTUNNEL_SUGGESTS)" >>$@
	@echo "Conflicts: $(PROXYTUNNEL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PROXYTUNNEL_IPK_DIR)/opt/sbin or $(PROXYTUNNEL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PROXYTUNNEL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PROXYTUNNEL_IPK_DIR)/opt/etc/proxytunnel/...
# Documentation files should be installed in $(PROXYTUNNEL_IPK_DIR)/opt/doc/proxytunnel/...
# Daemon startup scripts should be installed in $(PROXYTUNNEL_IPK_DIR)/opt/etc/init.d/S??proxytunnel
#
# You may need to patch your application to make it use these locations.
#
$(PROXYTUNNEL_IPK): $(PROXYTUNNEL_BUILD_DIR)/.built
	rm -rf $(PROXYTUNNEL_IPK_DIR) $(BUILD_DIR)/proxytunnel_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PROXYTUNNEL_BUILD_DIR) DESTDIR=$(PROXYTUNNEL_IPK_DIR) PREFIX=/opt install
	$(STRIP_COMMAND) $(PROXYTUNNEL_IPK_DIR)/opt/bin/proxytunnel
	install -d $(PROXYTUNNEL_IPK_DIR)/opt/share/doc/proxytunnel
	install $(PROXYTUNNEL_BUILD_DIR)/[CIKLRT]* $(PROXYTUNNEL_IPK_DIR)/opt/share/doc/proxytunnel
	$(MAKE) $(PROXYTUNNEL_IPK_DIR)/CONTROL/control
	echo $(PROXYTUNNEL_CONFFILES) | sed -e 's/ /\n/g' > $(PROXYTUNNEL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PROXYTUNNEL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
proxytunnel-ipk: $(PROXYTUNNEL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
proxytunnel-clean:
	rm -f $(PROXYTUNNEL_BUILD_DIR)/.built
	-$(MAKE) -C $(PROXYTUNNEL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
proxytunnel-dirclean:
	rm -rf $(BUILD_DIR)/$(PROXYTUNNEL_DIR) $(PROXYTUNNEL_BUILD_DIR) $(PROXYTUNNEL_IPK_DIR) $(PROXYTUNNEL_IPK)
#
#
# Some sanity check for the package.
#
proxytunnel-check: $(PROXYTUNNEL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PROXYTUNNEL_IPK)
