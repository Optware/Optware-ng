###########################################################
#
# bitchx
#
###########################################################

# You must replace "bitchx" and "BITCHX" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# BITCHX_VERSION, BITCHX_SITE and BITCHX_SOURCE define
# the upstream location of the source code for the package.
# BITCHX_DIR is the directory which is created when the source
# archive is unpacked.
# BITCHX_UNZIP is the command used to unzip the source.
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
BITCHX_SITE=ftp://ftp.FreeBSD.org/pub/FreeBSD/ports/distfiles
BITCHX_VERSION=1.1a-final
BITCHX_SOURCE=ircii-pana-$(BITCHX_VERSION).tar.gz
BITCHX_DIR=BitchX
BITCHX_UNZIP=zcat
BITCHX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BITCHX_DESCRIPTION=Text mode IRC client
BITCHX_SECTION=misc
BITCHX_PRIORITY=optional
BITCHX_DEPENDS=ncurses

#
# BITCHX_IPK_VERSION should be incremented when the ipk changes.
#
BITCHX_IPK_VERSION=1

#
# BITCHX_CONFFILES should be a list of user-editable files
# BITCHX_CONFFILES=/opt/etc/bitchx.conf /opt/etc/init.d/SXXbitchx

#
# BITCHX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
BITCHX_PATCHES=$(BITCHX_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BITCHX_CPPFLAGS=
BITCHX_LDFLAGS=

#
# BITCHX_BUILD_DIR is the directory in which the build is done.
# BITCHX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BITCHX_IPK_DIR is the directory in which the ipk is built.
# BITCHX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BITCHX_BUILD_DIR=$(BUILD_DIR)/bitchx
BITCHX_SOURCE_DIR=$(SOURCE_DIR)/bitchx
BITCHX_IPK_DIR=$(BUILD_DIR)/bitchx-$(BITCHX_VERSION)-ipk
BITCHX_IPK=$(BUILD_DIR)/bitchx_$(BITCHX_VERSION)-$(BITCHX_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BITCHX_SOURCE):
	$(WGET) -P $(DL_DIR) $(BITCHX_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bitchx-source: $(DL_DIR)/$(BITCHX_SOURCE) $(BITCHX_PATCHES)

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
$(BITCHX_BUILD_DIR)/.configured: $(DL_DIR)/$(BITCHX_SOURCE) $(BITCHX_PATCHES)
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(BITCHX_DIR) $(BITCHX_BUILD_DIR)
	$(BITCHX_UNZIP) $(DL_DIR)/$(BITCHX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(BITCHX_PATCHES) | patch -d $(BUILD_DIR)/$(BITCHX_DIR) -p1
	mv $(BUILD_DIR)/$(BITCHX_DIR) $(BITCHX_BUILD_DIR)
	(cd $(BITCHX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BITCHX_CPPFLAGS)" \
		INCLUDES="$(STAGING_CPPFLAGS) $(BITCHX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BITCHX_LDFLAGS) -s" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(BITCHX_BUILD_DIR)/.configured

bitchx-unpack: $(BITCHX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BITCHX_BUILD_DIR)/.built: $(BITCHX_BUILD_DIR)/.configured
	rm -f $(BITCHX_BUILD_DIR)/.built
	$(MAKE) -C $(BITCHX_BUILD_DIR)
	touch $(BITCHX_BUILD_DIR)/.built

#
# This is the build convenience target.
#
bitchx: $(BITCHX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BITCHX_BUILD_DIR)/.staged: $(BITCHX_BUILD_DIR)/.built
	rm -f $(BITCHX_BUILD_DIR)/.staged
	$(MAKE) -C $(BITCHX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(BITCHX_BUILD_DIR)/.staged

bitchx-stage: $(BITCHX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bitchx
#
$(BITCHX_IPK_DIR)/CONTROL/control:
	@install -d $(BITCHX_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: bitchx" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BITCHX_PRIORITY)" >>$@
	@echo "Section: $(BITCHX_SECTION)" >>$@
	@echo "Version: $(BITCHX_VERSION)-$(BITCHX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BITCHX_MAINTAINER)" >>$@
	@echo "Source: $(BITCHX_SITE)/$(BITCHX_SOURCE)" >>$@
	@echo "Description: $(BITCHX_DESCRIPTION)" >>$@
	@echo "Depends: $(BITCHX_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BITCHX_IPK_DIR)/opt/sbin or $(BITCHX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BITCHX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BITCHX_IPK_DIR)/opt/etc/bitchx/...
# Documentation files should be installed in $(BITCHX_IPK_DIR)/opt/doc/bitchx/...
# Daemon startup scripts should be installed in $(BITCHX_IPK_DIR)/opt/etc/init.d/S??bitchx
#
# You may need to patch your application to make it use these locations.
#
$(BITCHX_IPK): $(BITCHX_BUILD_DIR)/.built
	rm -rf $(BITCHX_IPK_DIR) $(BUILD_DIR)/bitchx_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BITCHX_BUILD_DIR) DESTDIR=$(BITCHX_IPK_DIR) prefix=$(BITCHX_IPK_DIR)/opt install
	$(MAKE) $(BITCHX_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BITCHX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bitchx-ipk: $(BITCHX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bitchx-clean:
	-$(MAKE) -C $(BITCHX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bitchx-dirclean:
	rm -rf $(BUILD_DIR)/$(BITCHX_DIR) $(BITCHX_BUILD_DIR) $(BITCHX_IPK_DIR) $(BITCHX_IPK)

#
# Some sanity check for the package.
#
bitchx-check: $(BITCHX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BITCHX_IPK)
