###########################################################
#
# harfbuzz
#
###########################################################

# You must replace "harfbuzz" and "HARFBUZZ" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# HARFBUZZ_VERSION, HARFBUZZ_SITE and HARFBUZZ_SOURCE define
# the upstream location of the source code for the package.
# HARFBUZZ_DIR is the directory which is created when the source
# archive is unpacked.
# HARFBUZZ_UNZIP is the command used to unzip the source.
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
HARFBUZZ_SITE=http://www.freedesktop.org/software/harfbuzz/release
HARFBUZZ_VERSION=0.9.38
HARFBUZZ_SOURCE=harfbuzz-$(HARFBUZZ_VERSION).tar.bz2
HARFBUZZ_DIR=harfbuzz-$(HARFBUZZ_VERSION)
HARFBUZZ_UNZIP=bzcat
HARFBUZZ_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HARFBUZZ_DESCRIPTION=HarfBuzz is an OpenType text shaping engine.
HARFBUZZ_SECTION=lib
HARFBUZZ_PRIORITY=optional
HARFBUZZ_DEPENDS=glib, freetype, cairo
HARFBUZZ_SUGGESTS=
HARFBUZZ_CONFLICTS=

#
# HARFBUZZ_IPK_VERSION should be incremented when the ipk changes.
#
HARFBUZZ_IPK_VERSION=2

#
# HARFBUZZ_CONFFILES should be a list of user-editable files
#HARFBUZZ_CONFFILES=$(TARGET_PREFIX)/etc/harfbuzz.conf $(TARGET_PREFIX)/etc/init.d/SXXharfbuzz

#
# HARFBUZZ_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#HARFBUZZ_PATCHES=$(HARFBUZZ_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HARFBUZZ_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/freetype2
HARFBUZZ_LDFLAGS=

#
# HARFBUZZ_BUILD_DIR is the directory in which the build is done.
# HARFBUZZ_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HARFBUZZ_IPK_DIR is the directory in which the ipk is built.
# HARFBUZZ_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HARFBUZZ_BUILD_DIR=$(BUILD_DIR)/harfbuzz
HARFBUZZ_SOURCE_DIR=$(SOURCE_DIR)/harfbuzz
HARFBUZZ_IPK_DIR=$(BUILD_DIR)/harfbuzz-$(HARFBUZZ_VERSION)-ipk
HARFBUZZ_IPK=$(BUILD_DIR)/harfbuzz_$(HARFBUZZ_VERSION)-$(HARFBUZZ_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: harfbuzz-source harfbuzz-unpack harfbuzz harfbuzz-stage harfbuzz-ipk harfbuzz-clean harfbuzz-dirclean harfbuzz-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HARFBUZZ_SOURCE):
	$(WGET) -P $(@D) $(HARFBUZZ_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
harfbuzz-source: $(DL_DIR)/$(HARFBUZZ_SOURCE) $(HARFBUZZ_PATCHES)

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
$(HARFBUZZ_BUILD_DIR)/.configured: $(DL_DIR)/$(HARFBUZZ_SOURCE) $(HARFBUZZ_PATCHES) make/harfbuzz.mk
	$(MAKE) glib-stage freetype-stage cairo-stage
	rm -rf $(BUILD_DIR)/$(HARFBUZZ_DIR) $(@D)
	$(HARFBUZZ_UNZIP) $(DL_DIR)/$(HARFBUZZ_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HARFBUZZ_PATCHES)" ; \
		then cat $(HARFBUZZ_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(HARFBUZZ_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HARFBUZZ_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(HARFBUZZ_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HARFBUZZ_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HARFBUZZ_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--with-freetype=yes \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

harfbuzz-unpack: $(HARFBUZZ_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HARFBUZZ_BUILD_DIR)/.built: $(HARFBUZZ_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
harfbuzz: $(HARFBUZZ_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HARFBUZZ_BUILD_DIR)/.staged: $(HARFBUZZ_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libharfbuzz.la
	sed -ie 's|=$(TARGET_PREFIX)|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/harfbuzz.pc
	touch $@

harfbuzz-stage: $(HARFBUZZ_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/harfbuzz
#
$(HARFBUZZ_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: harfbuzz" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HARFBUZZ_PRIORITY)" >>$@
	@echo "Section: $(HARFBUZZ_SECTION)" >>$@
	@echo "Version: $(HARFBUZZ_VERSION)-$(HARFBUZZ_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HARFBUZZ_MAINTAINER)" >>$@
	@echo "Source: $(HARFBUZZ_SITE)/$(HARFBUZZ_SOURCE)" >>$@
	@echo "Description: $(HARFBUZZ_DESCRIPTION)" >>$@
	@echo "Depends: $(HARFBUZZ_DEPENDS)" >>$@
	@echo "Suggests: $(HARFBUZZ_SUGGESTS)" >>$@
	@echo "Conflicts: $(HARFBUZZ_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HARFBUZZ_IPK_DIR)$(TARGET_PREFIX)/sbin or $(HARFBUZZ_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HARFBUZZ_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(HARFBUZZ_IPK_DIR)$(TARGET_PREFIX)/etc/harfbuzz/...
# Documentation files should be installed in $(HARFBUZZ_IPK_DIR)$(TARGET_PREFIX)/doc/harfbuzz/...
# Daemon startup scripts should be installed in $(HARFBUZZ_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??harfbuzz
#
# You may need to patch your application to make it use these locations.
#
$(HARFBUZZ_IPK): $(HARFBUZZ_BUILD_DIR)/.built
	rm -rf $(HARFBUZZ_IPK_DIR) $(BUILD_DIR)/harfbuzz_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HARFBUZZ_BUILD_DIR) DESTDIR=$(HARFBUZZ_IPK_DIR) install-strip
#	$(INSTALL) -d $(HARFBUZZ_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(HARFBUZZ_SOURCE_DIR)/harfbuzz.conf $(HARFBUZZ_IPK_DIR)$(TARGET_PREFIX)/etc/harfbuzz.conf
#	$(INSTALL) -d $(HARFBUZZ_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(HARFBUZZ_SOURCE_DIR)/rc.harfbuzz $(HARFBUZZ_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXharfbuzz
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HARFBUZZ_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXharfbuzz
	$(MAKE) $(HARFBUZZ_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(HARFBUZZ_SOURCE_DIR)/postinst $(HARFBUZZ_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HARFBUZZ_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(HARFBUZZ_SOURCE_DIR)/prerm $(HARFBUZZ_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HARFBUZZ_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(HARFBUZZ_IPK_DIR)/CONTROL/postinst $(HARFBUZZ_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(HARFBUZZ_CONFFILES) | sed -e 's/ /\n/g' > $(HARFBUZZ_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HARFBUZZ_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(HARFBUZZ_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
harfbuzz-ipk: $(HARFBUZZ_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
harfbuzz-clean:
	rm -f $(HARFBUZZ_BUILD_DIR)/.built
	-$(MAKE) -C $(HARFBUZZ_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
harfbuzz-dirclean:
	rm -rf $(BUILD_DIR)/$(HARFBUZZ_DIR) $(HARFBUZZ_BUILD_DIR) $(HARFBUZZ_IPK_DIR) $(HARFBUZZ_IPK)
#
#
# Some sanity check for the package.
#
harfbuzz-check: $(HARFBUZZ_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
