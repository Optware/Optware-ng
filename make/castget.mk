###########################################################
#
# castget
#
###########################################################

#
# CASTGET_VERSION, CASTGET_SITE and CASTGET_SOURCE define
# the upstream location of the source code for the package.
# CASTGET_DIR is the directory which is created when the source
# archive is unpacked.
# CASTGET_UNZIP is the command used to unzip the source.
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
CASTGET_SITE=http://savannah.nongnu.org/download/castget
CASTGET_VERSION=0.9.6
CASTGET_SOURCE=castget-$(CASTGET_VERSION).tar.gz
CASTGET_DIR=castget-$(CASTGET_VERSION)
CASTGET_UNZIP=zcat
CASTGET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CASTGET_DESCRIPTION=castget is a simple, command-line based RSS enclosure downloader, primarily intended for automatic, unattended downloading of podcasts.
CASTGET_SECTION=net
CASTGET_PRIORITY=optional
CASTGET_DEPENDS=libxml2, libcurl, id3lib, glib
CASTGET_SUGGESTS=
CASTGET_CONFLICTS=

#
# CASTGET_IPK_VERSION should be incremented when the ipk changes.
#
CASTGET_IPK_VERSION=1

#
# CASTGET_CONFFILES should be a list of user-editable files
CASTGET_CONFFILES=

#
# CASTGET_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CASTGET_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CASTGET_CPPFLAGS=
CASTGET_LDFLAGS=

#
# CASTGET_BUILD_DIR is the directory in which the build is done.
# CASTGET_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CASTGET_IPK_DIR is the directory in which the ipk is built.
# CASTGET_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CASTGET_BUILD_DIR=$(BUILD_DIR)/castget
CASTGET_SOURCE_DIR=$(SOURCE_DIR)/castget
CASTGET_IPK_DIR=$(BUILD_DIR)/castget-$(CASTGET_VERSION)-ipk
CASTGET_IPK=$(BUILD_DIR)/castget_$(CASTGET_VERSION)-$(CASTGET_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: castget-source castget-unpack castget castget-stage castget-ipk castget-clean castget-dirclean castget-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CASTGET_SOURCE):
	$(WGET) -P $(DL_DIR) $(CASTGET_SITE)/$(CASTGET_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(CASTGET_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
castget-source: $(DL_DIR)/$(CASTGET_SOURCE) $(CASTGET_PATCHES)

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
# PKG_CONFIG_PATH is set so that pkg-config will locate the correct 
# libs for configure. In a similar way, $(STAGING_DIR)/opt/bin is added 
# to PATH in order to find the correct curl-config script.
# Finally, ac_cv_func_malloc_0_nonnull=yes is needed to force detection
# of a GNU-compatible malloc even when cross compiling.
#
$(CASTGET_BUILD_DIR)/.configured: $(DL_DIR)/$(CASTGET_SOURCE) $(CASTGET_PATCHES) make/castget.mk
	$(MAKE) libxml2-stage libcurl-stage glib-stage id3lib-stage
	rm -rf $(BUILD_DIR)/$(CASTGET_DIR) $(CASTGET_BUILD_DIR)
	$(CASTGET_UNZIP) $(DL_DIR)/$(CASTGET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CASTGET_PATCHES)" ; \
		then cat $(CASTGET_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CASTGET_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CASTGET_DIR)" != "$(CASTGET_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CASTGET_DIR) $(CASTGET_BUILD_DIR) ; \
	fi
	(cd $(CASTGET_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CASTGET_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CASTGET_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_DIR)/opt/lib/pkgconfig" \
		PATH="$(STAGING_DIR)/opt/bin:$(PATH)" \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--mandir=/opt/man \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(CASTGET_BUILD_DIR)/libtool
	touch $@

castget-unpack: $(CASTGET_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CASTGET_BUILD_DIR)/.built: $(CASTGET_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(CASTGET_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
castget: $(CASTGET_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CASTGET_BUILD_DIR)/.staged: $(CASTGET_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(CASTGET_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

castget-stage: $(CASTGET_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/castget
#
$(CASTGET_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: castget" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CASTGET_PRIORITY)" >>$@
	@echo "Section: $(CASTGET_SECTION)" >>$@
	@echo "Version: $(CASTGET_VERSION)-$(CASTGET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CASTGET_MAINTAINER)" >>$@
	@echo "Source: $(CASTGET_SITE)/$(CASTGET_SOURCE)" >>$@
	@echo "Description: $(CASTGET_DESCRIPTION)" >>$@
	@echo "Depends: $(CASTGET_DEPENDS)" >>$@
	@echo "Suggests: $(CASTGET_SUGGESTS)" >>$@
	@echo "Conflicts: $(CASTGET_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CASTGET_IPK_DIR)/opt/sbin or $(CASTGET_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CASTGET_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CASTGET_IPK_DIR)/opt/etc/castget/...
# Documentation files should be installed in $(CASTGET_IPK_DIR)/opt/doc/castget/...
# Daemon startup scripts should be installed in $(CASTGET_IPK_DIR)/opt/etc/init.d/S??castget
#
# You may need to patch your application to make it use these locations.
#
$(CASTGET_IPK): $(CASTGET_BUILD_DIR)/.built
	rm -rf $(CASTGET_IPK_DIR) $(BUILD_DIR)/castget_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CASTGET_BUILD_DIR) DESTDIR=$(CASTGET_IPK_DIR) install-strip
	install -d $(CASTGET_IPK_DIR)/opt/doc/castget
	install -m 644 $(CASTGET_BUILD_DIR)/castgetrc.example $(CASTGET_IPK_DIR)/opt/doc/castget
	$(MAKE) $(CASTGET_IPK_DIR)/CONTROL/control
	#install -m 755 $(CASTGET_SOURCE_DIR)/postinst $(CASTGET_IPK_DIR)/CONTROL/postinst
	#sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CASTGET_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(CASTGET_SOURCE_DIR)/prerm $(CASTGET_IPK_DIR)/CONTROL/prerm
	#sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CASTGET_IPK_DIR)/CONTROL/prerm
	echo $(CASTGET_CONFFILES) | sed -e 's/ /\n/g' > $(CASTGET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CASTGET_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
castget-ipk: $(CASTGET_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
castget-clean:
	rm -f $(CASTGET_BUILD_DIR)/.built
	-$(MAKE) -C $(CASTGET_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
castget-dirclean:
	rm -rf $(BUILD_DIR)/$(CASTGET_DIR) $(CASTGET_BUILD_DIR) $(CASTGET_IPK_DIR) $(CASTGET_IPK)
#
#
# Some sanity check for the package.
#
castget-check: $(CASTGET_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CASTGET_IPK)
