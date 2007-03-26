###########################################################
#
# lame
#
###########################################################

# You must replace "lame" and "LAME" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LAME_VERSION, LAME_SITE and LAME_SOURCE define
# the upstream location of the source code for the package.
# LAME_DIR is the directory which is created when the source
# archive is unpacked.
# LAME_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LAME_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/lame
LAME_VERSION=3.97
LAME_SOURCE=lame-$(LAME_VERSION).tar.gz
LAME_DIR=lame-$(LAME_VERSION)
LAME_UNZIP=zcat
LAME_MAINTAINER=Keith Garry Boyce <nslu2-linux@yahoogroups.com>
LAME_DESCRIPTION=LAME is an LGPL MP3 encoder.
LAME_SECTION=lib
LAME_PRIORITY=optional
LAME_DEPENDS=ncurses
LAME_CONFLICTS=

#
# LAME_IPK_VERSION should be incremented when the ipk changes.
#
LAME_IPK_VERSION=1

#
# LAME_CONFFILES should be a list of user-editable files
LAME_CONFFILES=/opt/etc/lame.conf /opt/etc/init.d/SXXlame

#
## LAME_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LAME_PATCHES=$(LAME_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LAME_CPPFLAGS=
LAME_LDFLAGS=

#
# LAME_BUILD_DIR is the directory in which the build is done.
# LAME_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LAME_IPK_DIR is the directory in which the ipk is built.
# LAME_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LAME_BUILD_DIR=$(BUILD_DIR)/lame
LAME_SOURCE_DIR=$(SOURCE_DIR)/lame
LAME_IPK_DIR=$(BUILD_DIR)/lame-$(LAME_VERSION)-ipk
LAME_IPK=$(BUILD_DIR)/lame_$(LAME_VERSION)-$(LAME_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lame-source lame-unpack lame lame-stage lame-ipk lame-clean lame-dirclean lame-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LAME_SOURCE):
	$(WGET) -P $(DL_DIR) $(LAME_SITE)/$(LAME_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lame-source: $(DL_DIR)/$(LAME_SOURCE)

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
## first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(LAME_BUILD_DIR)/.configured: $(DL_DIR)/$(LAME_SOURCE) $(LAME_PATCHES)
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(LAME_DIR) $(LAME_BUILD_DIR)
	$(LAME_UNZIP) $(DL_DIR)/$(LAME_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LAME_PATCHES) | patch -d $(BUILD_DIR)/$(LAME_DIR) -p1
	mv $(BUILD_DIR)/$(LAME_DIR) $(LAME_BUILD_DIR)
	(cd $(LAME_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LAME_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LAME_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(LAME_BUILD_DIR)/.configured

lame-unpack: $(LAME_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LAME_BUILD_DIR)/.built: $(LAME_BUILD_DIR)/.configured
	rm -f $(LAME_BUILD_DIR)/.built
	$(MAKE) -C $(LAME_BUILD_DIR)
	touch $(LAME_BUILD_DIR)/.built

#
# This is the build convenience target.
#
lame: $(LAME_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LAME_BUILD_DIR)/.staged: $(LAME_BUILD_DIR)/.built
	rm -f $(LAME_BUILD_DIR)/.staged
	$(MAKE) -C $(LAME_BUILD_DIR) DESTDIR=$(STAGING_DIR) install-strip
	touch $(LAME_BUILD_DIR)/.staged

lame-stage: $(LAME_BUILD_DIR)/.staged


#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lame
#
$(LAME_IPK_DIR)/CONTROL/control:
	@install -d $(LAME_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: lame" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LAME_PRIORITY)" >>$@
	@echo "Section: $(LAME_SECTION)" >>$@
	@echo "Version: $(LAME_VERSION)-$(LAME_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LAME_MAINTAINER)" >>$@
	@echo "Source: $(LAME_SITE)/$(LAME_SOURCE)" >>$@
	@echo "Description: $(LAME_DESCRIPTION)" >>$@
	@echo "Depends: $(LAME_DEPENDS)" >>$@
	@echo "Conflicts: $(LAME_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LAME_IPK_DIR)/opt/sbin or $(LAME_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LAME_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LAME_IPK_DIR)/opt/etc/lame/...
# Documentation files should be installed in $(LAME_IPK_DIR)/opt/doc/lame/...
# Daemon startup scripts should be installed in $(LAME_IPK_DIR)/opt/etc/init.d/S??lame
#
# You may need to patch your application to make it use these locations.
#
$(LAME_IPK): $(LAME_BUILD_DIR)/.built
	rm -rf $(LAME_IPK_DIR) $(BUILD_DIR)/lame_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LAME_BUILD_DIR) DESTDIR=$(LAME_IPK_DIR) install-strip
	rm -f $(LAME_IPK_DIR)/opt/lib/libmp3lame.a
	$(MAKE) $(LAME_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LAME_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lame-ipk: $(LAME_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lame-clean:
	-$(MAKE) -C $(LAME_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lame-dirclean:
	rm -rf $(BUILD_DIR)/$(LAME_DIR) $(LAME_BUILD_DIR) $(LAME_IPK_DIR) $(LAME_IPK)

#
# Some sanity check for the package.
#
lame-check: $(LAME_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LAME_IPK)
