###########################################################
#
# c-ares
#
###########################################################
#
# C_ARES_VERSION, C_ARES_SITE and C_ARES_SOURCE define
# the upstream location of the source code for the package.
# C_ARES_DIR is the directory which is created when the source
# archive is unpacked.
# C_ARES_UNZIP is the command used to unzip the source.
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
C_ARES_SITE=http://daniel.haxx.se/projects/c-ares
C_ARES_VERSION=1.5.2
C_ARES_SOURCE=c-ares-$(C_ARES_VERSION).tar.gz
C_ARES_DIR=c-ares-$(C_ARES_VERSION)
C_ARES_UNZIP=zcat
C_ARES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
C_ARES_DESCRIPTION=C library that performs DNS requests and name resolves asynchronously
C_ARES_SECTION=libs
C_ARES_PRIORITY=optional
C_ARES_DEPENDS=
C_ARES_SUGGESTS=
C_ARES_CONFLICTS=

#
# C_ARES_IPK_VERSION should be incremented when the ipk changes.
#
C_ARES_IPK_VERSION=1

#
# C_ARES_CONFFILES should be a list of user-editable files
#C_ARES_CONFFILES=/opt/etc/c-ares.conf /opt/etc/init.d/SXXc-ares

#
# C_ARES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#C_ARES_PATCHES=$(C_ARES_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
C_ARES_CPPFLAGS=
C_ARES_LDFLAGS=

#
# C_ARES_BUILD_DIR is the directory in which the build is done.
# C_ARES_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# C_ARES_IPK_DIR is the directory in which the ipk is built.
# C_ARES_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
C_ARES_BUILD_DIR=$(BUILD_DIR)/c-ares
C_ARES_SOURCE_DIR=$(SOURCE_DIR)/c-ares
C_ARES_IPK_DIR=$(BUILD_DIR)/c-ares-$(C_ARES_VERSION)-ipk
C_ARES_IPK=$(BUILD_DIR)/c-ares_$(C_ARES_VERSION)-$(C_ARES_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: c-ares-source c-ares-unpack c-ares c-ares-stage c-ares-ipk c-ares-clean c-ares-dirclean c-ares-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(C_ARES_SOURCE):
	$(WGET) -P $(@D) $(C_ARES_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
c-ares-source: $(DL_DIR)/$(C_ARES_SOURCE) $(C_ARES_PATCHES)

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
$(C_ARES_BUILD_DIR)/.configured: $(DL_DIR)/$(C_ARES_SOURCE) $(C_ARES_PATCHES) make/c-ares.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(C_ARES_DIR) $(@D)
	$(C_ARES_UNZIP) $(DL_DIR)/$(C_ARES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(C_ARES_PATCHES)" ; \
		then cat $(C_ARES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(C_ARES_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(C_ARES_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(C_ARES_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(C_ARES_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(C_ARES_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--enable-shared \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

c-ares-unpack: $(C_ARES_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(C_ARES_BUILD_DIR)/.built: $(C_ARES_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
c-ares: $(C_ARES_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(C_ARES_BUILD_DIR)/.staged: $(C_ARES_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libcares.pc
	touch $@

c-ares-stage: $(C_ARES_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/c-ares
#
$(C_ARES_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: c-ares" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(C_ARES_PRIORITY)" >>$@
	@echo "Section: $(C_ARES_SECTION)" >>$@
	@echo "Version: $(C_ARES_VERSION)-$(C_ARES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(C_ARES_MAINTAINER)" >>$@
	@echo "Source: $(C_ARES_SITE)/$(C_ARES_SOURCE)" >>$@
	@echo "Description: $(C_ARES_DESCRIPTION)" >>$@
	@echo "Depends: $(C_ARES_DEPENDS)" >>$@
	@echo "Suggests: $(C_ARES_SUGGESTS)" >>$@
	@echo "Conflicts: $(C_ARES_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(C_ARES_IPK_DIR)/opt/sbin or $(C_ARES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(C_ARES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(C_ARES_IPK_DIR)/opt/etc/c-ares/...
# Documentation files should be installed in $(C_ARES_IPK_DIR)/opt/doc/c-ares/...
# Daemon startup scripts should be installed in $(C_ARES_IPK_DIR)/opt/etc/init.d/S??c-ares
#
# You may need to patch your application to make it use these locations.
#
$(C_ARES_IPK): $(C_ARES_BUILD_DIR)/.built
	rm -rf $(C_ARES_IPK_DIR) $(BUILD_DIR)/c-ares_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(C_ARES_BUILD_DIR) DESTDIR=$(C_ARES_IPK_DIR) install-strip
#	install -d $(C_ARES_IPK_DIR)/opt/etc/
#	install -m 644 $(C_ARES_SOURCE_DIR)/c-ares.conf $(C_ARES_IPK_DIR)/opt/etc/c-ares.conf
#	install -d $(C_ARES_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(C_ARES_SOURCE_DIR)/rc.c-ares $(C_ARES_IPK_DIR)/opt/etc/init.d/SXXc-ares
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXc-ares
	$(MAKE) $(C_ARES_IPK_DIR)/CONTROL/control
#	install -m 755 $(C_ARES_SOURCE_DIR)/postinst $(C_ARES_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(C_ARES_SOURCE_DIR)/prerm $(C_ARES_IPK_DIR)/CONTROL/prerm
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
#	echo $(C_ARES_CONFFILES) | sed -e 's/ /\n/g' > $(C_ARES_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(C_ARES_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
c-ares-ipk: $(C_ARES_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
c-ares-clean:
	rm -f $(C_ARES_BUILD_DIR)/.built
	-$(MAKE) -C $(C_ARES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
c-ares-dirclean:
	rm -rf $(BUILD_DIR)/$(C_ARES_DIR) $(C_ARES_BUILD_DIR) $(C_ARES_IPK_DIR) $(C_ARES_IPK)
#
#
# Some sanity check for the package.
#
c-ares-check: $(C_ARES_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(C_ARES_IPK)
