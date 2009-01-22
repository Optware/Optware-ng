###########################################################
#
# wavpack
#
###########################################################
#
# WAVPACK_VERSION, WAVPACK_SITE and WAVPACK_SOURCE define
# the upstream location of the source code for the package.
# WAVPACK_DIR is the directory which is created when the source
# archive is unpacked.
# WAVPACK_UNZIP is the command used to unzip the source.
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
WAVPACK_SITE=http://www.wavpack.com
WAVPACK_VERSION=4.50.1
WAVPACK_SOURCE=wavpack-$(WAVPACK_VERSION).tar.bz2
WAVPACK_DIR=wavpack-$(WAVPACK_VERSION)
WAVPACK_UNZIP=bzcat
WAVPACK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
WAVPACK_DESCRIPTION=WavPack is a completely open audio compression format providing lossless, high-quality lossy, and a unique hybrid compression mode.
WAVPACK_SECTION=audio
WAVPACK_PRIORITY=optional
WAVPACK_DEPENDS=
WAVPACK_SUGGESTS=
WAVPACK_CONFLICTS=

#
# WAVPACK_IPK_VERSION should be incremented when the ipk changes.
#
WAVPACK_IPK_VERSION=1

#
# WAVPACK_CONFFILES should be a list of user-editable files
#WAVPACK_CONFFILES=/opt/etc/wavpack.conf /opt/etc/init.d/SXXwavpack

#
# WAVPACK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#WAVPACK_PATCHES=$(WAVPACK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WAVPACK_CPPFLAGS=
WAVPACK_LDFLAGS=

#
# WAVPACK_BUILD_DIR is the directory in which the build is done.
# WAVPACK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WAVPACK_IPK_DIR is the directory in which the ipk is built.
# WAVPACK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WAVPACK_BUILD_DIR=$(BUILD_DIR)/wavpack
WAVPACK_SOURCE_DIR=$(SOURCE_DIR)/wavpack
WAVPACK_IPK_DIR=$(BUILD_DIR)/wavpack-$(WAVPACK_VERSION)-ipk
WAVPACK_IPK=$(BUILD_DIR)/wavpack_$(WAVPACK_VERSION)-$(WAVPACK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: wavpack-source wavpack-unpack wavpack wavpack-stage wavpack-ipk wavpack-clean wavpack-dirclean wavpack-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WAVPACK_SOURCE):
	$(WGET) -P $(@D) $(WAVPACK_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
wavpack-source: $(DL_DIR)/$(WAVPACK_SOURCE) $(WAVPACK_PATCHES)

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
$(WAVPACK_BUILD_DIR)/.configured: $(DL_DIR)/$(WAVPACK_SOURCE) $(WAVPACK_PATCHES) make/wavpack.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(WAVPACK_DIR) $(@D)
	$(WAVPACK_UNZIP) $(DL_DIR)/$(WAVPACK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(WAVPACK_PATCHES)" ; \
		then cat $(WAVPACK_PATCHES) | \
		patch -d $(BUILD_DIR)/$(WAVPACK_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(WAVPACK_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(WAVPACK_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WAVPACK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WAVPACK_LDFLAGS)" \
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

wavpack-unpack: $(WAVPACK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WAVPACK_BUILD_DIR)/.built: $(WAVPACK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
wavpack: $(WAVPACK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(WAVPACK_BUILD_DIR)/.staged: $(WAVPACK_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

wavpack-stage: $(WAVPACK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/wavpack
#
$(WAVPACK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: wavpack" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WAVPACK_PRIORITY)" >>$@
	@echo "Section: $(WAVPACK_SECTION)" >>$@
	@echo "Version: $(WAVPACK_VERSION)-$(WAVPACK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WAVPACK_MAINTAINER)" >>$@
	@echo "Source: $(WAVPACK_SITE)/$(WAVPACK_SOURCE)" >>$@
	@echo "Description: $(WAVPACK_DESCRIPTION)" >>$@
	@echo "Depends: $(WAVPACK_DEPENDS)" >>$@
	@echo "Suggests: $(WAVPACK_SUGGESTS)" >>$@
	@echo "Conflicts: $(WAVPACK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(WAVPACK_IPK_DIR)/opt/sbin or $(WAVPACK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WAVPACK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WAVPACK_IPK_DIR)/opt/etc/wavpack/...
# Documentation files should be installed in $(WAVPACK_IPK_DIR)/opt/doc/wavpack/...
# Daemon startup scripts should be installed in $(WAVPACK_IPK_DIR)/opt/etc/init.d/S??wavpack
#
# You may need to patch your application to make it use these locations.
#
$(WAVPACK_IPK): $(WAVPACK_BUILD_DIR)/.built
	rm -rf $(WAVPACK_IPK_DIR) $(BUILD_DIR)/wavpack_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(WAVPACK_BUILD_DIR) DESTDIR=$(WAVPACK_IPK_DIR) install-strip
#	install -d $(WAVPACK_IPK_DIR)/opt/etc/
#	install -m 644 $(WAVPACK_SOURCE_DIR)/wavpack.conf $(WAVPACK_IPK_DIR)/opt/etc/wavpack.conf
#	install -d $(WAVPACK_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(WAVPACK_SOURCE_DIR)/rc.wavpack $(WAVPACK_IPK_DIR)/opt/etc/init.d/SXXwavpack
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(WAVPACK_IPK_DIR)/opt/etc/init.d/SXXwavpack
	$(MAKE) $(WAVPACK_IPK_DIR)/CONTROL/control
#	install -m 755 $(WAVPACK_SOURCE_DIR)/postinst $(WAVPACK_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(WAVPACK_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(WAVPACK_SOURCE_DIR)/prerm $(WAVPACK_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(WAVPACK_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(WAVPACK_IPK_DIR)/CONTROL/postinst $(WAVPACK_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(WAVPACK_CONFFILES) | sed -e 's/ /\n/g' > $(WAVPACK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WAVPACK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
wavpack-ipk: $(WAVPACK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
wavpack-clean:
	rm -f $(WAVPACK_BUILD_DIR)/.built
	-$(MAKE) -C $(WAVPACK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
wavpack-dirclean:
	rm -rf $(BUILD_DIR)/$(WAVPACK_DIR) $(WAVPACK_BUILD_DIR) $(WAVPACK_IPK_DIR) $(WAVPACK_IPK)
#
#
# Some sanity check for the package.
#
wavpack-check: $(WAVPACK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
