###########################################################
#
# dircproxy
#
###########################################################
#
# DIRCPROXY_VERSION, DIRCPROXY_SITE and DIRCPROXY_SOURCE define
# the upstream location of the source code for the package.
# DIRCPROXY_DIR is the directory which is created when the source
# archive is unpacked.
# DIRCPROXY_UNZIP is the command used to unzip the source.
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
DIRCPROXY_SITE=http://dircproxy.securiweb.net/pub/1.1
DIRCPROXY_VERSION=1.1.0
DIRCPROXY_SOURCE=dircproxy-$(DIRCPROXY_VERSION).tar.gz
DIRCPROXY_DIR=dircproxy-$(DIRCPROXY_VERSION)
DIRCPROXY_UNZIP=zcat
DIRCPROXY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DIRCPROXY_DESCRIPTION=IRC proxy server
DIRCPROXY_SECTION=util
DIRCPROXY_PRIORITY=optional
DIRCPROXY_DEPENDS=
DIRCPROXY_SUGGESTS=
DIRCPROXY_CONFLICTS=

#
# DIRCPROXY_IPK_VERSION should be incremented when the ipk changes.
#
DIRCPROXY_IPK_VERSION=1

#
# DIRCPROXY_CONFFILES should be a list of user-editable files
DIRCPROXY_CONFFILES=/opt/etc/dircproxy.conf /opt/etc/init.d/SXXdircproxy

#
# DIRCPROXY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DIRCPROXY_PATCHES=$(DIRCPROXY_SOURCE_DIR)/dircproxy.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DIRCPROXY_CPPFLAGS=
DIRCPROXY_LDFLAGS=

#
# DIRCPROXY_BUILD_DIR is the directory in which the build is done.
# DIRCPROXY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DIRCPROXY_IPK_DIR is the directory in which the ipk is built.
# DIRCPROXY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DIRCPROXY_BUILD_DIR=$(BUILD_DIR)/dircproxy
DIRCPROXY_SOURCE_DIR=$(SOURCE_DIR)/dircproxy
DIRCPROXY_IPK_DIR=$(BUILD_DIR)/dircproxy-$(DIRCPROXY_VERSION)-ipk
DIRCPROXY_IPK=$(BUILD_DIR)/dircproxy_$(DIRCPROXY_VERSION)-$(DIRCPROXY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dircproxy-source dircproxy-unpack dircproxy dircproxy-stage dircproxy-ipk dircproxy-clean dircproxy-dirclean dircproxy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DIRCPROXY_SOURCE):
	$(WGET) -P $(DL_DIR) $(DIRCPROXY_SITE)/$(DIRCPROXY_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dircproxy-source: $(DL_DIR)/$(DIRCPROXY_SOURCE) $(DIRCPROXY_PATCHES)

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
$(DIRCPROXY_BUILD_DIR)/.configured: $(DL_DIR)/$(DIRCPROXY_SOURCE) $(DIRCPROXY_PATCHES) make/dircproxy.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DIRCPROXY_DIR) $(DIRCPROXY_BUILD_DIR)
	$(DIRCPROXY_UNZIP) $(DL_DIR)/$(DIRCPROXY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DIRCPROXY_PATCHES)" ; \
		then cat $(DIRCPROXY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DIRCPROXY_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(DIRCPROXY_DIR)" != "$(DIRCPROXY_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DIRCPROXY_DIR) $(DIRCPROXY_BUILD_DIR) ; \
	fi
	(cd $(DIRCPROXY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DIRCPROXY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DIRCPROXY_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $(DIRCPROXY_BUILD_DIR)/.configured

dircproxy-unpack: $(DIRCPROXY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DIRCPROXY_BUILD_DIR)/.built: $(DIRCPROXY_BUILD_DIR)/.configured
	rm -f $(DIRCPROXY_BUILD_DIR)/.built
	$(MAKE) -C $(DIRCPROXY_BUILD_DIR)
	touch $(DIRCPROXY_BUILD_DIR)/.built

#
# This is the build convenience target.
#
dircproxy: $(DIRCPROXY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DIRCPROXY_BUILD_DIR)/.staged: $(DIRCPROXY_BUILD_DIR)/.built
	rm -f $(DIRCPROXY_BUILD_DIR)/.staged
	$(MAKE) -C $(DIRCPROXY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(DIRCPROXY_BUILD_DIR)/.staged

dircproxy-stage: $(DIRCPROXY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dircproxy
#
$(DIRCPROXY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dircproxy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DIRCPROXY_PRIORITY)" >>$@
	@echo "Section: $(DIRCPROXY_SECTION)" >>$@
	@echo "Version: $(DIRCPROXY_VERSION)-$(DIRCPROXY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DIRCPROXY_MAINTAINER)" >>$@
	@echo "Source: $(DIRCPROXY_SITE)/$(DIRCPROXY_SOURCE)" >>$@
	@echo "Description: $(DIRCPROXY_DESCRIPTION)" >>$@
	@echo "Depends: $(DIRCPROXY_DEPENDS)" >>$@
	@echo "Suggests: $(DIRCPROXY_SUGGESTS)" >>$@
	@echo "Conflicts: $(DIRCPROXY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DIRCPROXY_IPK_DIR)/opt/sbin or $(DIRCPROXY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DIRCPROXY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DIRCPROXY_IPK_DIR)/opt/etc/dircproxy/...
# Documentation files should be installed in $(DIRCPROXY_IPK_DIR)/opt/doc/dircproxy/...
# Daemon startup scripts should be installed in $(DIRCPROXY_IPK_DIR)/opt/etc/init.d/S??dircproxy
#
# You may need to patch your application to make it use these locations.
#
$(DIRCPROXY_IPK): $(DIRCPROXY_BUILD_DIR)/.built
	rm -rf $(DIRCPROXY_IPK_DIR) $(BUILD_DIR)/dircproxy_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DIRCPROXY_BUILD_DIR) DESTDIR=$(DIRCPROXY_IPK_DIR) install-strip
	$(MAKE) $(DIRCPROXY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DIRCPROXY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dircproxy-ipk: $(DIRCPROXY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dircproxy-clean:
	rm -f $(DIRCPROXY_BUILD_DIR)/.built
	-$(MAKE) -C $(DIRCPROXY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dircproxy-dirclean:
	rm -rf $(BUILD_DIR)/$(DIRCPROXY_DIR) $(DIRCPROXY_BUILD_DIR) $(DIRCPROXY_IPK_DIR) $(DIRCPROXY_IPK)
#
#
# Some sanity check for the package.
#
dircproxy-check: $(DIRCPROXY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DIRCPROXY_IPK)
