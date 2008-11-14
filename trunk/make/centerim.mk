###########################################################
#
# centerim
#
###########################################################
#
# CENTERIM_VERSION, CENTERIM_SITE and CENTERIM_SOURCE define
# the upstream location of the source code for the package.
# CENTERIM_DIR is the directory which is created when the source
# archive is unpacked.
# CENTERIM_UNZIP is the command used to unzip the source.
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
CENTERIM_SITE=http://www.centerim.org/download/releases
CENTERIM_VERSION=4.22.6
CENTERIM_SOURCE=centerim-$(CENTERIM_VERSION).tar.gz
CENTERIM_DIR=centerim-$(CENTERIM_VERSION)
CENTERIM_UNZIP=zcat
CENTERIM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CENTERIM_DESCRIPTION=CenterIM is the forked project based on the good old famous CenterICQ instant messaging client.
CENTERIM_SECTION=net
CENTERIM_PRIORITY=optional
CENTERIM_DEPENDS=gpgme, libcurl, libjpeg, libotr, libstdc++, ncursesw, openssl
CENTERIM_SUGGESTS=
CENTERIM_CONFLICTS=

#
# CENTERIM_IPK_VERSION should be incremented when the ipk changes.
#
CENTERIM_IPK_VERSION=1

#
# CENTERIM_CONFFILES should be a list of user-editable files
#CENTERIM_CONFFILES=/opt/etc/centerim.conf /opt/etc/init.d/SXXcenterim

#
# CENTERIM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CENTERIM_PATCHES=$(CENTERIM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CENTERIM_CPPFLAGS=
CENTERIM_LDFLAGS=

#
# CENTERIM_BUILD_DIR is the directory in which the build is done.
# CENTERIM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CENTERIM_IPK_DIR is the directory in which the ipk is built.
# CENTERIM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CENTERIM_BUILD_DIR=$(BUILD_DIR)/centerim
CENTERIM_SOURCE_DIR=$(SOURCE_DIR)/centerim
CENTERIM_IPK_DIR=$(BUILD_DIR)/centerim-$(CENTERIM_VERSION)-ipk
CENTERIM_IPK=$(BUILD_DIR)/centerim_$(CENTERIM_VERSION)-$(CENTERIM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: centerim-source centerim-unpack centerim centerim-stage centerim-ipk centerim-clean centerim-dirclean centerim-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CENTERIM_SOURCE):
	$(WGET) -P $(@D) $(CENTERIM_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
centerim-source: $(DL_DIR)/$(CENTERIM_SOURCE) $(CENTERIM_PATCHES)

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
$(CENTERIM_BUILD_DIR)/.configured: $(DL_DIR)/$(CENTERIM_SOURCE) $(CENTERIM_PATCHES) make/centerim.mk
	$(MAKE) ncursesw-stage openssl-stage
	$(MAKE) libcurl-stage libjpeg-stage libstdc++-stage
	$(MAKE) gpgme-stage libotr-stage
	rm -rf $(BUILD_DIR)/$(CENTERIM_DIR) $(@D)
	$(CENTERIM_UNZIP) $(DL_DIR)/$(CENTERIM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CENTERIM_PATCHES)" ; \
		then cat $(CENTERIM_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CENTERIM_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CENTERIM_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CENTERIM_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(CENTERIM_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(CENTERIM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CENTERIM_LDFLAGS)" \
		PATH="$(STAGING_PREFIX)/bin:$$PATH" \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-libpth-prefix=$(STAGING_PREFIX) \
		--with-openssl=$(STAGING_PREFIX) \
		--with-gpgme=$(STAGING_PREFIX) \
		--with-libcurl=$(STAGING_PREFIX) \
		--with-libotr \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

centerim-unpack: $(CENTERIM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CENTERIM_BUILD_DIR)/.built: $(CENTERIM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
centerim: $(CENTERIM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CENTERIM_BUILD_DIR)/.staged: $(CENTERIM_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

centerim-stage: $(CENTERIM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/centerim
#
$(CENTERIM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: centerim" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CENTERIM_PRIORITY)" >>$@
	@echo "Section: $(CENTERIM_SECTION)" >>$@
	@echo "Version: $(CENTERIM_VERSION)-$(CENTERIM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CENTERIM_MAINTAINER)" >>$@
	@echo "Source: $(CENTERIM_SITE)/$(CENTERIM_SOURCE)" >>$@
	@echo "Description: $(CENTERIM_DESCRIPTION)" >>$@
	@echo "Depends: $(CENTERIM_DEPENDS)" >>$@
	@echo "Suggests: $(CENTERIM_SUGGESTS)" >>$@
	@echo "Conflicts: $(CENTERIM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CENTERIM_IPK_DIR)/opt/sbin or $(CENTERIM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CENTERIM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CENTERIM_IPK_DIR)/opt/etc/centerim/...
# Documentation files should be installed in $(CENTERIM_IPK_DIR)/opt/doc/centerim/...
# Daemon startup scripts should be installed in $(CENTERIM_IPK_DIR)/opt/etc/init.d/S??centerim
#
# You may need to patch your application to make it use these locations.
#
$(CENTERIM_IPK): $(CENTERIM_BUILD_DIR)/.built
	rm -rf $(CENTERIM_IPK_DIR) $(BUILD_DIR)/centerim_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CENTERIM_BUILD_DIR) DESTDIR=$(CENTERIM_IPK_DIR) install-strip
#	install -d $(CENTERIM_IPK_DIR)/opt/etc/
#	install -m 644 $(CENTERIM_SOURCE_DIR)/centerim.conf $(CENTERIM_IPK_DIR)/opt/etc/centerim.conf
#	install -d $(CENTERIM_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CENTERIM_SOURCE_DIR)/rc.centerim $(CENTERIM_IPK_DIR)/opt/etc/init.d/SXXcenterim
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CENTERIM_IPK_DIR)/opt/etc/init.d/SXXcenterim
	$(MAKE) $(CENTERIM_IPK_DIR)/CONTROL/control
#	install -m 755 $(CENTERIM_SOURCE_DIR)/postinst $(CENTERIM_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CENTERIM_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CENTERIM_SOURCE_DIR)/prerm $(CENTERIM_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CENTERIM_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(CENTERIM_IPK_DIR)/CONTROL/postinst $(CENTERIM_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(CENTERIM_CONFFILES) | sed -e 's/ /\n/g' > $(CENTERIM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CENTERIM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
centerim-ipk: $(CENTERIM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
centerim-clean:
	rm -f $(CENTERIM_BUILD_DIR)/.built
	-$(MAKE) -C $(CENTERIM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
centerim-dirclean:
	rm -rf $(BUILD_DIR)/$(CENTERIM_DIR) $(CENTERIM_BUILD_DIR) $(CENTERIM_IPK_DIR) $(CENTERIM_IPK)
#
#
# Some sanity check for the package.
#
centerim-check: $(CENTERIM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CENTERIM_IPK)
