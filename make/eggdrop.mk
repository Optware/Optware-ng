###########################################################
#
# eggdrop
#
###########################################################

# You must replace "eggdrop" and "EGGDROP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# EGGDROP_VERSION, EGGDROP_SITE and EGGDROP_SOURCE define
# the upstream location of the source code for the package.
# EGGDROP_DIR is the directory which is created when the source
# archive is unpacked.
# EGGDROP_UNZIP is the command used to unzip the source.
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
EGGDROP_SITE=ftp://ftp.eggheads.org/pub/eggdrop/source/1.6
EGGDROP_VERSION=1.6.21
EGGDROP_SOURCE=eggdrop$(EGGDROP_VERSION).tar.bz2
EGGDROP_DIR=eggdrop$(EGGDROP_VERSION)
EGGDROP_UNZIP=bzcat
EGGDROP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
EGGDROP_DESCRIPTION=Eggdrop is a popular Open Source IRC bot
EGGDROP_SECTION=util
EGGDROP_PRIORITY=optional
EGGDROP_DEPENDS=tcl, zlib, adduser, psmisc
EGGDROP_SUGGESTS=
EGGDROP_CONFLICTS=

#
# EGGDROP_IPK_VERSION should be incremented when the ipk changes.
#
EGGDROP_IPK_VERSION=2

#
# EGGDROP_CONFFILES should be a list of user-editable files
EGGDROP_CONFFILES=$(TARGET_PREFIX)/etc/eggdrop.conf $(TARGET_PREFIX)/etc/init.d/S50eggdrop

#
# EGGDROP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
EGGDROP_PATCHES=$(EGGDROP_SOURCE_DIR)/Makefile.in.patch $(EGGDROP_SOURCE_DIR)/004-main_c.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
EGGDROP_CPPFLAGS=-DHAVE_SOCKLEN_T -std=gnu89
EGGDROP_LDFLAGS=-lresolv

#
# EGGDROP_BUILD_DIR is the directory in which the build is done.
# EGGDROP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# EGGDROP_IPK_DIR is the directory in which the ipk is built.
# EGGDROP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
EGGDROP_BUILD_DIR=$(BUILD_DIR)/eggdrop
EGGDROP_SOURCE_DIR=$(SOURCE_DIR)/eggdrop
EGGDROP_IPK_DIR=$(BUILD_DIR)/eggdrop-$(EGGDROP_VERSION)-ipk
EGGDROP_IPK=$(BUILD_DIR)/eggdrop_$(EGGDROP_VERSION)-$(EGGDROP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(EGGDROP_SOURCE):
	$(WGET) -P $(@D) $(EGGDROP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
eggdrop-source: $(DL_DIR)/$(EGGDROP_SOURCE) $(EGGDROP_PATCHES)

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
$(EGGDROP_BUILD_DIR)/.configured: $(DL_DIR)/$(EGGDROP_SOURCE) $(EGGDROP_PATCHES) make/eggdrop.mk
	$(MAKE) tcl-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(EGGDROP_DIR) $(@D)
	$(EGGDROP_UNZIP) $(DL_DIR)/$(EGGDROP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(EGGDROP_PATCHES) | $(PATCH) -bd $(BUILD_DIR)/$(EGGDROP_DIR) -p1
	mv $(BUILD_DIR)/$(EGGDROP_DIR) $(@D)
	$(AUTORECONF1.10) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(EGGDROP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(EGGDROP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX)/share/eggdrop \
		--disable-nls \
		--with-tclinc=$(STAGING_INCLUDE_DIR)/tcl.h \
		--with-tcllib=$(STAGING_LIB_DIR)/libtcl.so \
	)
	touch $@

eggdrop-unpack: $(EGGDROP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(EGGDROP_BUILD_DIR)/.built: $(EGGDROP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) config -C $(@D)
	$(MAKE) -C $(@D) \
		LDFLAGS="$(STAGING_LDFLAGS) $(EGGDROP_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
eggdrop: $(EGGDROP_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/eggdrop
#
$(EGGDROP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: eggdrop" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(EGGDROP_PRIORITY)" >>$@
	@echo "Section: $(EGGDROP_SECTION)" >>$@
	@echo "Version: $(EGGDROP_VERSION)-$(EGGDROP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(EGGDROP_MAINTAINER)" >>$@
	@echo "Source: $(EGGDROP_SITE)/$(EGGDROP_SOURCE)" >>$@
	@echo "Description: $(EGGDROP_DESCRIPTION)" >>$@
	@echo "Depends: $(EGGDROP_DEPENDS)" >>$@
	@echo "Suggests: $(EGGDROP_SUGGESTS)" >>$@
	@echo "Conflicts: $(EGGDROP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(EGGDROP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(EGGDROP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(EGGDROP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(EGGDROP_IPK_DIR)$(TARGET_PREFIX)/etc/eggdrop/...
# Documentation files should be installed in $(EGGDROP_IPK_DIR)$(TARGET_PREFIX)/doc/eggdrop/...
# Daemon startup scripts should be installed in $(EGGDROP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??eggdrop
#
# You may need to patch your application to make it use these locations.
#
$(EGGDROP_IPK): $(EGGDROP_BUILD_DIR)/.built
	rm -rf $(EGGDROP_IPK_DIR) $(BUILD_DIR)/eggdrop_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(EGGDROP_BUILD_DIR) DEST=$(EGGDROP_IPK_DIR)$(TARGET_PREFIX)/share/eggdrop install -j 1
	$(STRIP_COMMAND) $(EGGDROP_IPK_DIR)$(TARGET_PREFIX)/share/eggdrop/eggdrop-$(EGGDROP_VERSION)
	$(STRIP_COMMAND) $(EGGDROP_IPK_DIR)$(TARGET_PREFIX)/share/eggdrop/modules-$(EGGDROP_VERSION)/*.so
	mv $(EGGDROP_IPK_DIR)$(TARGET_PREFIX)/share/eggdrop/eggdrop.conf $(EGGDROP_IPK_DIR)$(TARGET_PREFIX)/share/eggdrop/eggdrop-orig.conf
	$(MAKE) $(EGGDROP_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(EGGDROP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(EGGDROP_SOURCE_DIR)/rc.eggdrop $(EGGDROP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S50eggdrop
	$(INSTALL) -m 644 $(EGGDROP_BUILD_DIR)/eggdrop.conf $(EGGDROP_IPK_DIR)$(TARGET_PREFIX)/etc/
	$(INSTALL) -m 755 $(EGGDROP_SOURCE_DIR)/postinst $(EGGDROP_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EGGDROP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
eggdrop-ipk: $(EGGDROP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
eggdrop-clean:
	-$(MAKE) -C $(EGGDROP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
eggdrop-dirclean:
	rm -rf $(BUILD_DIR)/$(EGGDROP_DIR) $(EGGDROP_BUILD_DIR) $(EGGDROP_IPK_DIR) $(EGGDROP_IPK)

#
# Some sanity check for the package.
#
eggdrop-check: $(EGGDROP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
