###########################################################
#
# iputils-arping
#
###########################################################
#
# IPUTILS_ARPING_VERSION, IPUTILS_ARPING_SITE and IPUTILS_ARPING_SOURCE define
# the upstream location of the source code for the package.
# IPUTILS_ARPING_DIR is the directory which is created when the source
# archive is unpacked.
# IPUTILS_ARPING_UNZIP is the command used to unzip the source.
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
IPUTILS_ARPING_SITE=http://ftp.debian.org/debian/pool/main/i/iputils
IPUTILS_ARPING_VERSION=20070202
IPUTILS_ARPING_SOURCE=iputils_$(IPUTILS_ARPING_VERSION).orig.tar.gz
IPUTILS_ARPING_DIR=iputils-$(IPUTILS_ARPING_VERSION)
IPUTILS_ARPING_UNZIP=zcat
IPUTILS_ARPING_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IPUTILS_ARPING_DESCRIPTION=The arping command acts like the standard ping command except it pings a machine by its ARP address instead of its IP address.
IPUTILS_ARPING_SECTION=net
IPUTILS_ARPING_PRIORITY=optional
IPUTILS_ARPING_DEPENDS=
IPUTILS_ARPING_SUGGESTS=
IPUTILS_ARPING_CONFLICTS=

#
# IPUTILS_ARPING_IPK_VERSION should be incremented when the ipk changes.
#
IPUTILS_ARPING_IPK_VERSION=1

#
# IPUTILS_ARPING_CONFFILES should be a list of user-editable files
#IPUTILS_ARPING_CONFFILES=/opt/etc/iputils-arping.conf /opt/etc/init.d/SXXiputils-arping

#
# IPUTILS_ARPING_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#IPUTILS_ARPING_PATCHES=$(IPUTILS_ARPING_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IPUTILS_ARPING_CPPFLAGS=
IPUTILS_ARPING_LDFLAGS=

#
# IPUTILS_ARPING_BUILD_DIR is the directory in which the build is done.
# IPUTILS_ARPING_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IPUTILS_ARPING_IPK_DIR is the directory in which the ipk is built.
# IPUTILS_ARPING_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPUTILS_ARPING_BUILD_DIR=$(BUILD_DIR)/iputils-arping
IPUTILS_ARPING_SOURCE_DIR=$(SOURCE_DIR)/iputils-arping
IPUTILS_ARPING_IPK_DIR=$(BUILD_DIR)/iputils-arping-$(IPUTILS_ARPING_VERSION)-ipk
IPUTILS_ARPING_IPK=$(BUILD_DIR)/iputils-arping_$(IPUTILS_ARPING_VERSION)-$(IPUTILS_ARPING_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: iputils-arping-source iputils-arping-unpack iputils-arping iputils-arping-stage iputils-arping-ipk iputils-arping-clean iputils-arping-dirclean iputils-arping-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IPUTILS_ARPING_SOURCE):
	$(WGET) -P $(DL_DIR) $(IPUTILS_ARPING_SITE)/$(IPUTILS_ARPING_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(IPUTILS_ARPING_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
iputils-arping-source: $(DL_DIR)/$(IPUTILS_ARPING_SOURCE) $(IPUTILS_ARPING_PATCHES)

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
$(IPUTILS_ARPING_BUILD_DIR)/.configured: $(DL_DIR)/$(IPUTILS_ARPING_SOURCE) $(IPUTILS_ARPING_PATCHES) make/iputils-arping.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(IPUTILS_ARPING_DIR) $(IPUTILS_ARPING_BUILD_DIR)
	$(IPUTILS_ARPING_UNZIP) $(DL_DIR)/$(IPUTILS_ARPING_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(IPUTILS_ARPING_PATCHES)" ; \
		then cat $(IPUTILS_ARPING_PATCHES) | \
		patch -d $(BUILD_DIR)/$(IPUTILS_ARPING_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(IPUTILS_ARPING_DIR)" != "$(IPUTILS_ARPING_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(IPUTILS_ARPING_DIR) $(IPUTILS_ARPING_BUILD_DIR) ; \
	fi
#	(cd $(IPUTILS_ARPING_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IPUTILS_ARPING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IPUTILS_ARPING_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(IPUTILS_ARPING_BUILD_DIR)/libtool
	touch $@

iputils-arping-unpack: $(IPUTILS_ARPING_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IPUTILS_ARPING_BUILD_DIR)/.built: $(IPUTILS_ARPING_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(IPUTILS_ARPING_BUILD_DIR) arping \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IPUTILS_ARPING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IPUTILS_ARPING_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
iputils-arping: $(IPUTILS_ARPING_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(IPUTILS_ARPING_BUILD_DIR)/.staged: $(IPUTILS_ARPING_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(IPUTILS_ARPING_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

iputils-arping-stage: $(IPUTILS_ARPING_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/iputils-arping
#
$(IPUTILS_ARPING_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: iputils-arping" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPUTILS_ARPING_PRIORITY)" >>$@
	@echo "Section: $(IPUTILS_ARPING_SECTION)" >>$@
	@echo "Version: $(IPUTILS_ARPING_VERSION)-$(IPUTILS_ARPING_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPUTILS_ARPING_MAINTAINER)" >>$@
	@echo "Source: $(IPUTILS_ARPING_SITE)/$(IPUTILS_ARPING_SOURCE)" >>$@
	@echo "Description: $(IPUTILS_ARPING_DESCRIPTION)" >>$@
	@echo "Depends: $(IPUTILS_ARPING_DEPENDS)" >>$@
	@echo "Suggests: $(IPUTILS_ARPING_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPUTILS_ARPING_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IPUTILS_ARPING_IPK_DIR)/opt/sbin or $(IPUTILS_ARPING_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IPUTILS_ARPING_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IPUTILS_ARPING_IPK_DIR)/opt/etc/iputils-arping/...
# Documentation files should be installed in $(IPUTILS_ARPING_IPK_DIR)/opt/doc/iputils-arping/...
# Daemon startup scripts should be installed in $(IPUTILS_ARPING_IPK_DIR)/opt/etc/init.d/S??iputils-arping
#
# You may need to patch your application to make it use these locations.
#
$(IPUTILS_ARPING_IPK): $(IPUTILS_ARPING_BUILD_DIR)/.built
	rm -rf $(IPUTILS_ARPING_IPK_DIR) $(BUILD_DIR)/iputils-arping_*_$(TARGET_ARCH).ipk
	install -d $(IPUTILS_ARPING_IPK_DIR)/opt/bin
	install $(IPUTILS_ARPING_BUILD_DIR)/arping $(IPUTILS_ARPING_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(IPUTILS_ARPING_IPK_DIR)/opt/bin/arping
	$(MAKE) $(IPUTILS_ARPING_IPK_DIR)/CONTROL/control
#	install -m 755 $(IPUTILS_ARPING_SOURCE_DIR)/postinst $(IPUTILS_ARPING_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(IPUTILS_ARPING_SOURCE_DIR)/prerm $(IPUTILS_ARPING_IPK_DIR)/CONTROL/prerm
	echo $(IPUTILS_ARPING_CONFFILES) | sed -e 's/ /\n/g' > $(IPUTILS_ARPING_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPUTILS_ARPING_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
iputils-arping-ipk: $(IPUTILS_ARPING_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
iputils-arping-clean:
	rm -f $(IPUTILS_ARPING_BUILD_DIR)/.built
	-$(MAKE) -C $(IPUTILS_ARPING_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
iputils-arping-dirclean:
	rm -rf $(BUILD_DIR)/$(IPUTILS_ARPING_DIR) $(IPUTILS_ARPING_BUILD_DIR) $(IPUTILS_ARPING_IPK_DIR) $(IPUTILS_ARPING_IPK)
#
#
# Some sanity check for the package.
#
iputils-arping-check: $(IPUTILS_ARPING_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IPUTILS_ARPING_IPK)
