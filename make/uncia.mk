###########################################################
#
# uncia
#
###########################################################
#
# UNCIA_VERSION, UNCIA_SITE and UNCIA_SOURCE define
# the upstream location of the source code for the package.
# UNCIA_DIR is the directory which is created when the source
# archive is unpacked.
# UNCIA_UNZIP is the command used to unzip the source.
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
UNCIA_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/uncia
UNCIA_VERSION=1.3
UNCIA_SOURCE=uncia-$(UNCIA_VERSION).tar.gz
UNCIA_DIR=uncia-$(UNCIA_VERSION)
UNCIA_UNZIP=zcat
UNCIA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UNCIA_DESCRIPTION=a big cat, ASCII text manipulation tool.
UNCIA_SECTION=utils
UNCIA_PRIORITY=optional
UNCIA_DEPENDS=libstdc++, libcurl, zlib, libexplain
ifneq (libexplain, $(filter libexplain, $(PACKAGES)))
UNCIA_VERSION=1.2
UNCIA_DEPENDS=libstdc++, libcurl, zlib
endif
UNCIA_SUGGESTS=
UNCIA_CONFLICTS=

#
# UNCIA_IPK_VERSION should be incremented when the ipk changes.
#
UNCIA_IPK_VERSION=4

#
# UNCIA_CONFFILES should be a list of user-editable files
#UNCIA_CONFFILES=$(TARGET_PREFIX)/etc/uncia.conf $(TARGET_PREFIX)/etc/init.d/SXXuncia

#
# UNCIA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
UNCIA_PATCHES=\
$(UNCIA_SOURCE_DIR)/cstdarg.patch \
$(UNCIA_SOURCE_DIR)/filter_explicit_convert_istream_to_bool.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UNCIA_CPPFLAGS=
UNCIA_LDFLAGS=-lgcc

#
# UNCIA_BUILD_DIR is the directory in which the build is done.
# UNCIA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UNCIA_IPK_DIR is the directory in which the ipk is built.
# UNCIA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UNCIA_BUILD_DIR=$(BUILD_DIR)/uncia
UNCIA_SOURCE_DIR=$(SOURCE_DIR)/uncia
UNCIA_IPK_DIR=$(BUILD_DIR)/uncia-$(UNCIA_VERSION)-ipk
UNCIA_IPK=$(BUILD_DIR)/uncia_$(UNCIA_VERSION)-$(UNCIA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: uncia-source uncia-unpack uncia uncia-stage uncia-ipk uncia-clean uncia-dirclean uncia-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UNCIA_SOURCE):
	$(WGET) -P $(@D) $(UNCIA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
uncia-source: $(DL_DIR)/$(UNCIA_SOURCE) $(UNCIA_PATCHES)

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
$(UNCIA_BUILD_DIR)/.configured: $(DL_DIR)/$(UNCIA_SOURCE) $(UNCIA_PATCHES) make/uncia.mk
	$(MAKE) libstdc++-stage libcurl-stage zlib-stage libtool-stage boost-stage
ifeq (libexplain, $(filter libexplain, $(PACKAGES)))
	$(MAKE) libexplain-stage
endif
	rm -rf $(BUILD_DIR)/$(UNCIA_DIR) $(@D)
	$(UNCIA_UNZIP) $(DL_DIR)/$(UNCIA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UNCIA_PATCHES)" ; \
		then cat $(UNCIA_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(UNCIA_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UNCIA_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(UNCIA_DIR) $(@D) ; \
	fi
	sed -i -e '/^LIBS/s|$$| $$(LDFLAGS)|' $(@D)/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UNCIA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UNCIA_LDFLAGS)" \
		LIBTOOL=$(STAGING_PREFIX)/bin/libtool \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

uncia-unpack: $(UNCIA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UNCIA_BUILD_DIR)/.built: $(UNCIA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) uncia/gram.yacc.cc
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
uncia: $(UNCIA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UNCIA_BUILD_DIR)/.staged: $(UNCIA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install -j1
	touch $@

uncia-stage: $(UNCIA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/uncia
#
$(UNCIA_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: uncia" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UNCIA_PRIORITY)" >>$@
	@echo "Section: $(UNCIA_SECTION)" >>$@
	@echo "Version: $(UNCIA_VERSION)-$(UNCIA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UNCIA_MAINTAINER)" >>$@
	@echo "Source: $(UNCIA_SITE)/$(UNCIA_SOURCE)" >>$@
	@echo "Description: $(UNCIA_DESCRIPTION)" >>$@
	@echo "Depends: $(UNCIA_DEPENDS)" >>$@
	@echo "Suggests: $(UNCIA_SUGGESTS)" >>$@
	@echo "Conflicts: $(UNCIA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UNCIA_IPK_DIR)$(TARGET_PREFIX)/sbin or $(UNCIA_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UNCIA_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(UNCIA_IPK_DIR)$(TARGET_PREFIX)/etc/uncia/...
# Documentation files should be installed in $(UNCIA_IPK_DIR)$(TARGET_PREFIX)/doc/uncia/...
# Daemon startup scripts should be installed in $(UNCIA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??uncia
#
# You may need to patch your application to make it use these locations.
#
$(UNCIA_IPK): $(UNCIA_BUILD_DIR)/.built
	rm -rf $(UNCIA_IPK_DIR) $(BUILD_DIR)/uncia_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(UNCIA_BUILD_DIR) DESTDIR=$(UNCIA_IPK_DIR) install -j1
	$(STRIP_COMMAND) $(UNCIA_IPK_DIR)$(TARGET_PREFIX)/bin/* \
		$(UNCIA_IPK_DIR)$(TARGET_PREFIX)/lib/libuncia.so
	$(MAKE) $(UNCIA_IPK_DIR)/CONTROL/control
	echo $(UNCIA_CONFFILES) | sed -e 's/ /\n/g' > $(UNCIA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNCIA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
uncia-ipk: $(UNCIA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
uncia-clean:
	rm -f $(UNCIA_BUILD_DIR)/.built
	-$(MAKE) -C $(UNCIA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
uncia-dirclean:
	rm -rf $(BUILD_DIR)/$(UNCIA_DIR) $(UNCIA_BUILD_DIR) $(UNCIA_IPK_DIR) $(UNCIA_IPK)
#
#
# Some sanity check for the package.
#
uncia-check: $(UNCIA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
