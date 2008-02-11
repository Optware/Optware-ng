###########################################################
#
# texinfo
#
###########################################################
#
# TEXINFO_VERSION, TEXINFO_SITE and TEXINFO_SOURCE define
# the upstream location of the source code for the package.
# TEXINFO_DIR is the directory which is created when the source
# archive is unpacked.
# TEXINFO_UNZIP is the command used to unzip the source.
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
TEXINFO_SITE=http://ftp.gnu.org/gnu/texinfo
TEXINFO_VERSION=4.11
TEXINFO_SOURCE=texinfo-$(TEXINFO_VERSION).tar.bz2
TEXINFO_DIR=texinfo-$(TEXINFO_VERSION)
TEXINFO_UNZIP=bzcat
TEXINFO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TEXINFO_DESCRIPTION=The GNU Documentation System.
TEXINFO_SECTION=documentation
TEXINFO_PRIORITY=optional
TEXINFO_DEPENDS=ncurses
TEXINFO_SUGGESTS=
TEXINFO_CONFLICTS=

#
# TEXINFO_IPK_VERSION should be incremented when the ipk changes.
#
TEXINFO_IPK_VERSION=1

#
# TEXINFO_CONFFILES should be a list of user-editable files
#TEXINFO_CONFFILES=/opt/etc/texinfo.conf /opt/etc/init.d/SXXtexinfo

#
# TEXINFO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TEXINFO_PATCHES=$(TEXINFO_SOURCE_DIR)/mbstate_t.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TEXINFO_CPPFLAGS=
TEXINFO_LDFLAGS=

#
# TEXINFO_BUILD_DIR is the directory in which the build is done.
# TEXINFO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TEXINFO_IPK_DIR is the directory in which the ipk is built.
# TEXINFO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TEXINFO_BUILD_DIR=$(BUILD_DIR)/texinfo
TEXINFO_SOURCE_DIR=$(SOURCE_DIR)/texinfo
TEXINFO_IPK_DIR=$(BUILD_DIR)/texinfo-$(TEXINFO_VERSION)-ipk
TEXINFO_IPK=$(BUILD_DIR)/texinfo_$(TEXINFO_VERSION)-$(TEXINFO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: texinfo-source texinfo-unpack texinfo texinfo-stage texinfo-ipk texinfo-clean texinfo-dirclean texinfo-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TEXINFO_SOURCE):
	$(WGET) -P $(DL_DIR) $(TEXINFO_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
texinfo-source: $(DL_DIR)/$(TEXINFO_SOURCE) $(TEXINFO_PATCHES)

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
$(TEXINFO_BUILD_DIR)/.configured: $(DL_DIR)/$(TEXINFO_SOURCE) $(TEXINFO_PATCHES) make/texinfo.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(TEXINFO_DIR) $(@D)
	$(TEXINFO_UNZIP) $(DL_DIR)/$(TEXINFO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TEXINFO_PATCHES)" ; \
		then cat $(TEXINFO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TEXINFO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(TEXINFO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TEXINFO_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TEXINFO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TEXINFO_LDFLAGS)" \
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

texinfo-unpack: $(TEXINFO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TEXINFO_BUILD_DIR)/.built: $(TEXINFO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/tools/gnulib/lib
	$(MAKE) -C $(@D)/tools
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
texinfo: $(TEXINFO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TEXINFO_BUILD_DIR)/.staged: $(TEXINFO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

texinfo-stage: $(TEXINFO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/texinfo
#
$(TEXINFO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: texinfo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TEXINFO_PRIORITY)" >>$@
	@echo "Section: $(TEXINFO_SECTION)" >>$@
	@echo "Version: $(TEXINFO_VERSION)-$(TEXINFO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TEXINFO_MAINTAINER)" >>$@
	@echo "Source: $(TEXINFO_SITE)/$(TEXINFO_SOURCE)" >>$@
	@echo "Description: $(TEXINFO_DESCRIPTION)" >>$@
	@echo "Depends: $(TEXINFO_DEPENDS)" >>$@
	@echo "Suggests: $(TEXINFO_SUGGESTS)" >>$@
	@echo "Conflicts: $(TEXINFO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TEXINFO_IPK_DIR)/opt/sbin or $(TEXINFO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TEXINFO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TEXINFO_IPK_DIR)/opt/etc/texinfo/...
# Documentation files should be installed in $(TEXINFO_IPK_DIR)/opt/doc/texinfo/...
# Daemon startup scripts should be installed in $(TEXINFO_IPK_DIR)/opt/etc/init.d/S??texinfo
#
# You may need to patch your application to make it use these locations.
#
$(TEXINFO_IPK): $(TEXINFO_BUILD_DIR)/.built
	rm -rf $(TEXINFO_IPK_DIR) $(BUILD_DIR)/texinfo_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TEXINFO_BUILD_DIR) DESTDIR=$(TEXINFO_IPK_DIR) install-strip
#	install -d $(TEXINFO_IPK_DIR)/opt/etc/
#	install -m 644 $(TEXINFO_SOURCE_DIR)/texinfo.conf $(TEXINFO_IPK_DIR)/opt/etc/texinfo.conf
#	install -d $(TEXINFO_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TEXINFO_SOURCE_DIR)/rc.texinfo $(TEXINFO_IPK_DIR)/opt/etc/init.d/SXXtexinfo
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TEXINFO_IPK_DIR)/opt/etc/init.d/SXXtexinfo
	$(MAKE) $(TEXINFO_IPK_DIR)/CONTROL/control
#	install -m 755 $(TEXINFO_SOURCE_DIR)/postinst $(TEXINFO_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TEXINFO_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TEXINFO_SOURCE_DIR)/prerm $(TEXINFO_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TEXINFO_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(TEXINFO_IPK_DIR)/CONTROL/postinst $(TEXINFO_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(TEXINFO_CONFFILES) | sed -e 's/ /\n/g' > $(TEXINFO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TEXINFO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
texinfo-ipk: $(TEXINFO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
texinfo-clean:
	rm -f $(TEXINFO_BUILD_DIR)/.built
	-$(MAKE) -C $(TEXINFO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
texinfo-dirclean:
	rm -rf $(BUILD_DIR)/$(TEXINFO_DIR) $(TEXINFO_BUILD_DIR) $(TEXINFO_IPK_DIR) $(TEXINFO_IPK)
#
#
# Some sanity check for the package.
#
texinfo-check: $(TEXINFO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TEXINFO_IPK)
