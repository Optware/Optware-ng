###########################################################
#
# exo
#
###########################################################

# You must replace "exo" and "EXO" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# EXO_VERSION, EXO_SITE and EXO_SOURCE define
# the upstream location of the source code for the package.
# EXO_DIR is the directory which is created when the source
# archive is unpacked.
# EXO_UNZIP is the command used to unzip the source.
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
EXO_SITE=http://archive.xfce.org/src/xfce/exo/0.10
EXO_VERSION=0.10.4
EXO_SOURCE=exo-$(EXO_VERSION).tar.bz2
EXO_DIR=exo-$(EXO_VERSION)
EXO_UNZIP=bzcat
EXO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
EXO_DESCRIPTION=Support library used in the Xfce desktop.
EXO_SECTION=lib
EXO_PRIORITY=optional
EXO_DEPENDS=libxfce4ui-1, libxfce4util
ifeq (perl-uri, $(filter perl-uri, $(PACKAGES)))
EXO_DEPENDS+=, perl-uri
endif
EXO_SUGGESTS=
EXO_CONFLICTS=

#
# EXO_IPK_VERSION should be incremented when the ipk changes.
#
EXO_IPK_VERSION=2

#
# EXO_CONFFILES should be a list of user-editable files
#EXO_CONFFILES=$(TARGET_PREFIX)/etc/exo.conf $(TARGET_PREFIX)/etc/init.d/SXXexo

#
# EXO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#EXO_PATCHES=$(EXO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
EXO_CPPFLAGS=
EXO_LDFLAGS=

#
# EXO_BUILD_DIR is the directory in which the build is done.
# EXO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# EXO_IPK_DIR is the directory in which the ipk is built.
# EXO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
EXO_BUILD_DIR=$(BUILD_DIR)/exo
EXO_SOURCE_DIR=$(SOURCE_DIR)/exo
EXO_IPK_DIR=$(BUILD_DIR)/exo-$(EXO_VERSION)-ipk
EXO_IPK=$(BUILD_DIR)/exo_$(EXO_VERSION)-$(EXO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: exo-source exo-unpack exo exo-stage exo-ipk exo-clean exo-dirclean exo-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(EXO_SOURCE):
	$(WGET) -P $(@D) $(EXO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
exo-source: $(DL_DIR)/$(EXO_SOURCE) $(EXO_PATCHES)

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
$(EXO_BUILD_DIR)/.configured: $(DL_DIR)/$(EXO_SOURCE) $(EXO_PATCHES) make/exo.mk
	$(MAKE) libxfce4ui-stage libxfce4util-stage
	rm -rf $(BUILD_DIR)/$(EXO_DIR) $(@D)
	$(EXO_UNZIP) $(DL_DIR)/$(EXO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(EXO_PATCHES)" ; \
		then cat $(EXO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(EXO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(EXO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(EXO_DIR) $(@D) ; \
	fi
	sed -i -e 's/as_fn_error \$$? "cannot run test/echo "cannot run test/' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(EXO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(EXO_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	sed -i -e '/^\ttests/s/^/#/' $(@D)/Makefile
	touch $@

exo-unpack: $(EXO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(EXO_BUILD_DIR)/.built: $(EXO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
exo: $(EXO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(EXO_BUILD_DIR)/.staged: $(EXO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libexo-1.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/exo-1.pc
	touch $@

exo-stage: $(EXO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/exo
#
$(EXO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: exo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(EXO_PRIORITY)" >>$@
	@echo "Section: $(EXO_SECTION)" >>$@
	@echo "Version: $(EXO_VERSION)-$(EXO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(EXO_MAINTAINER)" >>$@
	@echo "Source: $(EXO_SITE)/$(EXO_SOURCE)" >>$@
	@echo "Description: $(EXO_DESCRIPTION)" >>$@
	@echo "Depends: $(EXO_DEPENDS)" >>$@
	@echo "Suggests: $(EXO_SUGGESTS)" >>$@
	@echo "Conflicts: $(EXO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(EXO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(EXO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(EXO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(EXO_IPK_DIR)$(TARGET_PREFIX)/etc/exo/...
# Documentation files should be installed in $(EXO_IPK_DIR)$(TARGET_PREFIX)/doc/exo/...
# Daemon startup scripts should be installed in $(EXO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??exo
#
# You may need to patch your application to make it use these locations.
#
$(EXO_IPK): $(EXO_BUILD_DIR)/.built
	rm -rf $(EXO_IPK_DIR) $(BUILD_DIR)/exo_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(EXO_BUILD_DIR) DESTDIR=$(EXO_IPK_DIR) install-strip
	rm -f $(EXO_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(EXO_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(EXO_SOURCE_DIR)/exo.conf $(EXO_IPK_DIR)$(TARGET_PREFIX)/etc/exo.conf
#	$(INSTALL) -d $(EXO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(EXO_SOURCE_DIR)/rc.exo $(EXO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXexo
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(EXO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXexo
	$(MAKE) $(EXO_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(EXO_SOURCE_DIR)/postinst $(EXO_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(EXO_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(EXO_SOURCE_DIR)/prerm $(EXO_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(EXO_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(EXO_IPK_DIR)/CONTROL/postinst $(EXO_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(EXO_CONFFILES) | sed -e 's/ /\n/g' > $(EXO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EXO_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(EXO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
exo-ipk: $(EXO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
exo-clean:
	rm -f $(EXO_BUILD_DIR)/.built
	-$(MAKE) -C $(EXO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
exo-dirclean:
	rm -rf $(BUILD_DIR)/$(EXO_DIR) $(EXO_BUILD_DIR) $(EXO_IPK_DIR) $(EXO_IPK)
#
#
# Some sanity check for the package.
#
exo-check: $(EXO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
