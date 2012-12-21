###########################################################
#
# libical
#
###########################################################
#
# LIBICAL_VERSION, LIBICAL_SITE and LIBICAL_SOURCE define
# the upstream location of the source code for the package.
# LIBICAL_DIR is the directory which is created when the source
# archive is unpacked.
# LIBICAL_UNZIP is the command used to unzip the source.
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
LIBICAL_SITE=http://$(SOURCEFORGE_MIRROR)/freeassociation
LIBICAL_VERSION=0.48
LIBICAL_SOURCE=libical-$(LIBICAL_VERSION).tar.gz
LIBICAL_DIR=libical-$(LIBICAL_VERSION)
LIBICAL_UNZIP=zcat
LIBICAL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBICAL_DESCRIPTION=The libical package is an implementation of iCalendar protocols and data formats.
LIBICAL_SECTION=libs
LIBICAL_PRIORITY=optional
LIBICAL_DEPENDS=
LIBICAL_SUGGESTS=
LIBICAL_CONFLICTS=

#
# LIBICAL_IPK_VERSION should be incremented when the ipk changes.
#
LIBICAL_IPK_VERSION=1

#
# LIBICAL_CONFFILES should be a list of user-editable files
#LIBICAL_CONFFILES=/opt/etc/libical.conf /opt/etc/init.d/SXXlibical

#
# LIBICAL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBICAL_PATCHES=$(LIBICAL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBICAL_CPPFLAGS=
LIBICAL_LDFLAGS=

#
# LIBICAL_BUILD_DIR is the directory in which the build is done.
# LIBICAL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBICAL_IPK_DIR is the directory in which the ipk is built.
# LIBICAL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBICAL_BUILD_DIR=$(BUILD_DIR)/libical
LIBICAL_SOURCE_DIR=$(SOURCE_DIR)/libical
LIBICAL_IPK_DIR=$(BUILD_DIR)/libical-$(LIBICAL_VERSION)-ipk
LIBICAL_IPK=$(BUILD_DIR)/libical_$(LIBICAL_VERSION)-$(LIBICAL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libical-source libical-unpack libical libical-stage libical-ipk libical-clean libical-dirclean libical-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBICAL_SOURCE):
	$(WGET) -P $(@D) $(LIBICAL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libical-source: $(DL_DIR)/$(LIBICAL_SOURCE) $(LIBICAL_PATCHES)

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
$(LIBICAL_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBICAL_SOURCE) $(LIBICAL_PATCHES) make/libical.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBICAL_DIR) $(@D)
	$(LIBICAL_UNZIP) $(DL_DIR)/$(LIBICAL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBICAL_PATCHES)" ; \
		then cat $(LIBICAL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBICAL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBICAL_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBICAL_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBICAL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBICAL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libical-unpack: $(LIBICAL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBICAL_BUILD_DIR)/.built: $(LIBICAL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libical: $(LIBICAL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBICAL_BUILD_DIR)/.staged: $(LIBICAL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

libical-stage: $(LIBICAL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libical
#
$(LIBICAL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libical" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBICAL_PRIORITY)" >>$@
	@echo "Section: $(LIBICAL_SECTION)" >>$@
	@echo "Version: $(LIBICAL_VERSION)-$(LIBICAL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBICAL_MAINTAINER)" >>$@
	@echo "Source: $(LIBICAL_SITE)/$(LIBICAL_SOURCE)" >>$@
	@echo "Description: $(LIBICAL_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBICAL_DEPENDS)" >>$@
	@echo "Suggests: $(LIBICAL_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBICAL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBICAL_IPK_DIR)/opt/sbin or $(LIBICAL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBICAL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBICAL_IPK_DIR)/opt/etc/libical/...
# Documentation files should be installed in $(LIBICAL_IPK_DIR)/opt/doc/libical/...
# Daemon startup scripts should be installed in $(LIBICAL_IPK_DIR)/opt/etc/init.d/S??libical
#
# You may need to patch your application to make it use these locations.
#
$(LIBICAL_IPK): $(LIBICAL_BUILD_DIR)/.built
	rm -rf $(LIBICAL_IPK_DIR) $(BUILD_DIR)/libical_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBICAL_BUILD_DIR) DESTDIR=$(LIBICAL_IPK_DIR) install-strip
#	install -d $(LIBICAL_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBICAL_SOURCE_DIR)/libical.conf $(LIBICAL_IPK_DIR)/opt/etc/libical.conf
#	install -d $(LIBICAL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBICAL_SOURCE_DIR)/rc.libical $(LIBICAL_IPK_DIR)/opt/etc/init.d/SXXlibical
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBICAL_IPK_DIR)/opt/etc/init.d/SXXlibical
	$(MAKE) $(LIBICAL_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBICAL_SOURCE_DIR)/postinst $(LIBICAL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBICAL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBICAL_SOURCE_DIR)/prerm $(LIBICAL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBICAL_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBICAL_IPK_DIR)/CONTROL/postinst $(LIBICAL_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBICAL_CONFFILES) | sed -e 's/ /\n/g' > $(LIBICAL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBICAL_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBICAL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libical-ipk: $(LIBICAL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libical-clean:
	rm -f $(LIBICAL_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBICAL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libical-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBICAL_DIR) $(LIBICAL_BUILD_DIR) $(LIBICAL_IPK_DIR) $(LIBICAL_IPK)
#
#
# Some sanity check for the package.
#
libical-check: $(LIBICAL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
