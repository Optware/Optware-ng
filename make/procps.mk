###########################################################
#
# procps
#
###########################################################

# You must replace "procps" and "PROCPS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PROCPS_VERSION, PROCPS_SITE and PROCPS_SOURCE define
# the upstream location of the source code for the package.
# PROCPS_DIR is the directory which is created when the source
# archive is unpacked.
# PROCPS_UNZIP is the command used to unzip the source.
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
PROCPS_URL=http://$(SOURCEFORGE_MIRROR)/sourceforge/procps-ng/procps-ng-$(PROCPS_VERSION).tar.xz
PROCPS_VERSION=3.3.12
PROCPS_SOURCE=procps-ng-$(PROCPS_VERSION).tar.xz
PROCPS_DIR=procps-ng-$(PROCPS_VERSION)
PROCPS_UNZIP=xzcat
PROCPS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PROCPS_DESCRIPTION=PROCPS System Utilities
PROCPS_SECTION=system
LIBPROCPS_SECTION=libs
PROCPS_PRIORITY=optional
PROCPS_DEPENDS=ncurses, ncursesw
PROCPS_SUGGESTS=
PROCPS_CONFLICTS=

#
# PROCPS_IPK_VERSION should be incremented when the ipk changes.
#
PROCPS_IPK_VERSION=2

#
# PROCPS_CONFFILES should be a list of user-editable files
#PROCPS_CONFFILES=$(TARGET_PREFIX)/etc/procps.conf $(TARGET_PREFIX)/etc/init.d/SXXprocps

#
# PROCPS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PROCPS_PATCHES=$(PROCPS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PROCPS_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses -I$(STAGING_INCLUDE_DIR)/ncursesw
PROCPS_LDFLAGS=

#
# PROCPS_BUILD_DIR is the directory in which the build is done.
# PROCPS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PROCPS_IPK_DIR is the directory in which the ipk is built.
# PROCPS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PROCPS_BUILD_DIR=$(BUILD_DIR)/procps
PROCPS_SOURCE_DIR=$(SOURCE_DIR)/procps
PROCPS_IPK_DIR=$(BUILD_DIR)/procps-$(PROCPS_VERSION)-ipk
PROCPS_IPK=$(BUILD_DIR)/procps_$(PROCPS_VERSION)-$(PROCPS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: procps-source procps-unpack procps procps-stage procps-ipk procps-clean procps-dirclean procps-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(PROCPS_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(PROCPS_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(PROCPS_SOURCE).sha512
#
$(DL_DIR)/$(PROCPS_SOURCE):
	$(WGET) -O $@ $(PROCPS_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
procps-source: $(DL_DIR)/$(PROCPS_SOURCE) $(PROCPS_PATCHES)

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
$(PROCPS_BUILD_DIR)/.configured: $(DL_DIR)/$(PROCPS_SOURCE) $(PROCPS_PATCHES) make/procps.mk
	$(MAKE) ncurses-stage ncursesw-stage
	rm -rf $(BUILD_DIR)/$(PROCPS_DIR) $(@D)
	$(PROCPS_UNZIP) $(DL_DIR)/$(PROCPS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PROCPS_PATCHES)" ; \
		then cat $(PROCPS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PROCPS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PROCPS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PROCPS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PROCPS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PROCPS_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--exec-prefix='$${prefix}' \
		--libdir='$${prefix}/lib' \
		--docdir=$(TARGET_PREFIX)/share/doc/procps \
		--disable-nls \
		--disable-static \
		--enable-watch8bit \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

procps-unpack: $(PROCPS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PROCPS_BUILD_DIR)/.built: $(PROCPS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
procps: $(PROCPS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PROCPS_BUILD_DIR)/.staged: $(PROCPS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libprocps.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libprocps.pc
	touch $@

procps-stage: $(PROCPS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/procps
#
$(PROCPS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: procps" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PROCPS_PRIORITY)" >>$@
	@echo "Section: $(PROCPS_SECTION)" >>$@
	@echo "Version: $(PROCPS_VERSION)-$(PROCPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PROCPS_MAINTAINER)" >>$@
	@echo "Source: $(PROCPS_URL)" >>$@
	@echo "Description: $(PROCPS_DESCRIPTION)" >>$@
	@echo "Depends: $(PROCPS_DEPENDS)" >>$@
	@echo "Suggests: $(PROCPS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PROCPS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PROCPS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PROCPS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PROCPS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PROCPS_IPK_DIR)$(TARGET_PREFIX)/etc/procps/...
# Documentation files should be installed in $(PROCPS_IPK_DIR)$(TARGET_PREFIX)/doc/procps/...
# Daemon startup scripts should be installed in $(PROCPS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??procps
#
# You may need to patch your application to make it use these locations.
#
$(PROCPS_IPK): $(PROCPS_BUILD_DIR)/.built
	rm -rf $(PROCPS_IPK_DIR) $(BUILD_DIR)/procps_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PROCPS_BUILD_DIR) DESTDIR=$(PROCPS_IPK_DIR) install-strip
	rm -f $(PROCPS_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(PROCPS_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(PROCPS_SOURCE_DIR)/procps.conf $(PROCPS_IPK_DIR)$(TARGET_PREFIX)/etc/procps.conf
#	$(INSTALL) -d $(PROCPS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(PROCPS_SOURCE_DIR)/rc.procps $(PROCPS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXprocps
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PROCPS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXprocps
	$(MAKE) $(PROCPS_IPK_DIR)/CONTROL/control
	for d in $(TARGET_PREFIX)/{bin,sbin} $(TARGET_PREFIX)/share/man/man{1,3,5,8}; do \
	    cd $(PROCPS_IPK_DIR)/$$d; \
	    for f in *; do \
		mv -f $$f procps-$$f; \
		echo "update-alternatives --install $$d/$$f $$f $$d/procps-$$f 79" \
			>> $(PROCPS_IPK_DIR)/CONTROL/postinst; \
		echo "update-alternatives --remove $$f $$d/procps-$$f" \
			>> $(PROCPS_IPK_DIR)/CONTROL/prerm; \
	    done; \
	done
#	$(INSTALL) -m 755 $(PROCPS_SOURCE_DIR)/postinst $(PROCPS_IPK_DIR)/CONTROL/postinst
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PROCPS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(PROCPS_SOURCE_DIR)/prerm $(PROCPS_IPK_DIR)/CONTROL/prerm
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PROCPS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(PROCPS_IPK_DIR)/CONTROL/postinst $(PROCPS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(PROCPS_CONFFILES) | sed -e 's/ /\n/g' > $(PROCPS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PROCPS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PROCPS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
procps-ipk: $(PROCPS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
procps-clean:
	rm -f $(PROCPS_BUILD_DIR)/.built
	-$(MAKE) -C $(PROCPS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
procps-dirclean:
	rm -rf $(BUILD_DIR)/$(PROCPS_DIR) $(PROCPS_BUILD_DIR) $(PROCPS_IPK_DIR) $(PROCPS_IPK)
#
#
# Some sanity check for the package.
#
procps-check: $(PROCPS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
