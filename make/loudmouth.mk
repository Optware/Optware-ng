###########################################################
#
# loudmouth
#
###########################################################
#
# LOUDMOUTH_VERSION, LOUDMOUTH_SITE and LOUDMOUTH_SOURCE define
# the upstream location of the source code for the package.
# LOUDMOUTH_DIR is the directory which is created when the source
# archive is unpacked.
# LOUDMOUTH_UNZIP is the command used to unzip the source.
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
LOUDMOUTH_SITE=http://ftp.imendio.com/pub/imendio/loudmouth/src
LOUDMOUTH_VERSION=1.2.3
LOUDMOUTH_SOURCE=loudmouth-$(LOUDMOUTH_VERSION).tar.gz
LOUDMOUTH_DIR=loudmouth-$(LOUDMOUTH_VERSION)
LOUDMOUTH_UNZIP=zcat
LOUDMOUTH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LOUDMOUTH_DESCRIPTION=Loudmouth is a lightweight and easy-to-use C library for programming with the Jabber protocol.
LOUDMOUTH_SECTION=net
LOUDMOUTH_PRIORITY=optional
LOUDMOUTH_DEPENDS=gnutls, libidn
LOUDMOUTH_SUGGESTS=
LOUDMOUTH_CONFLICTS=

#
# LOUDMOUTH_IPK_VERSION should be incremented when the ipk changes.
#
LOUDMOUTH_IPK_VERSION=2

#
# LOUDMOUTH_CONFFILES should be a list of user-editable files
#LOUDMOUTH_CONFFILES=/opt/etc/loudmouth.conf /opt/etc/init.d/SXXloudmouth

#
# LOUDMOUTH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LOUDMOUTH_PATCHES=$(LOUDMOUTH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LOUDMOUTH_CPPFLAGS=
LOUDMOUTH_LDFLAGS=

#
# LOUDMOUTH_BUILD_DIR is the directory in which the build is done.
# LOUDMOUTH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LOUDMOUTH_IPK_DIR is the directory in which the ipk is built.
# LOUDMOUTH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LOUDMOUTH_BUILD_DIR=$(BUILD_DIR)/loudmouth
LOUDMOUTH_SOURCE_DIR=$(SOURCE_DIR)/loudmouth
LOUDMOUTH_IPK_DIR=$(BUILD_DIR)/loudmouth-$(LOUDMOUTH_VERSION)-ipk
LOUDMOUTH_IPK=$(BUILD_DIR)/loudmouth_$(LOUDMOUTH_VERSION)-$(LOUDMOUTH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: loudmouth-source loudmouth-unpack loudmouth loudmouth-stage loudmouth-ipk loudmouth-clean loudmouth-dirclean loudmouth-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LOUDMOUTH_SOURCE):
	$(WGET) -P $(DL_DIR) $(LOUDMOUTH_SITE)/$(LOUDMOUTH_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LOUDMOUTH_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
loudmouth-source: $(DL_DIR)/$(LOUDMOUTH_SOURCE) $(LOUDMOUTH_PATCHES)

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
$(LOUDMOUTH_BUILD_DIR)/.configured: $(DL_DIR)/$(LOUDMOUTH_SOURCE) $(LOUDMOUTH_PATCHES) make/loudmouth.mk
	$(MAKE) gnutls-stage libidn-stage
	rm -rf $(BUILD_DIR)/$(LOUDMOUTH_DIR) $(LOUDMOUTH_BUILD_DIR)
	$(LOUDMOUTH_UNZIP) $(DL_DIR)/$(LOUDMOUTH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LOUDMOUTH_PATCHES)" ; \
		then cat $(LOUDMOUTH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LOUDMOUTH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LOUDMOUTH_DIR)" != "$(LOUDMOUTH_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LOUDMOUTH_DIR) $(LOUDMOUTH_BUILD_DIR) ; \
	fi
	(cd $(LOUDMOUTH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LOUDMOUTH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LOUDMOUTH_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-libgnutls-prefix=$(STAGING_PREFIX) \
		--without-check \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LOUDMOUTH_BUILD_DIR)/libtool
	touch $@

loudmouth-unpack: $(LOUDMOUTH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LOUDMOUTH_BUILD_DIR)/.built: $(LOUDMOUTH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LOUDMOUTH_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
loudmouth: $(LOUDMOUTH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LOUDMOUTH_BUILD_DIR)/.staged: $(LOUDMOUTH_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LOUDMOUTH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/loudmouth*.pc
	rm -f $(STAGING_LIB_DIR)/libloudmouth*.la
	touch $@

loudmouth-stage: $(LOUDMOUTH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/loudmouth
#
$(LOUDMOUTH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: loudmouth" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LOUDMOUTH_PRIORITY)" >>$@
	@echo "Section: $(LOUDMOUTH_SECTION)" >>$@
	@echo "Version: $(LOUDMOUTH_VERSION)-$(LOUDMOUTH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LOUDMOUTH_MAINTAINER)" >>$@
	@echo "Source: $(LOUDMOUTH_SITE)/$(LOUDMOUTH_SOURCE)" >>$@
	@echo "Description: $(LOUDMOUTH_DESCRIPTION)" >>$@
	@echo "Depends: $(LOUDMOUTH_DEPENDS)" >>$@
	@echo "Suggests: $(LOUDMOUTH_SUGGESTS)" >>$@
	@echo "Conflicts: $(LOUDMOUTH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LOUDMOUTH_IPK_DIR)/opt/sbin or $(LOUDMOUTH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LOUDMOUTH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LOUDMOUTH_IPK_DIR)/opt/etc/loudmouth/...
# Documentation files should be installed in $(LOUDMOUTH_IPK_DIR)/opt/doc/loudmouth/...
# Daemon startup scripts should be installed in $(LOUDMOUTH_IPK_DIR)/opt/etc/init.d/S??loudmouth
#
# You may need to patch your application to make it use these locations.
#
$(LOUDMOUTH_IPK): $(LOUDMOUTH_BUILD_DIR)/.built
	rm -rf $(LOUDMOUTH_IPK_DIR) $(BUILD_DIR)/loudmouth_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LOUDMOUTH_BUILD_DIR) DESTDIR=$(LOUDMOUTH_IPK_DIR) install-strip
	rm -f $(LOUDMOUTH_IPK_DIR)/opt/lib/libloudmouth*.la
#	install -d $(LOUDMOUTH_IPK_DIR)/opt/etc/
#	install -m 644 $(LOUDMOUTH_SOURCE_DIR)/loudmouth.conf $(LOUDMOUTH_IPK_DIR)/opt/etc/loudmouth.conf
#	install -d $(LOUDMOUTH_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LOUDMOUTH_SOURCE_DIR)/rc.loudmouth $(LOUDMOUTH_IPK_DIR)/opt/etc/init.d/SXXloudmouth
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LOUDMOUTH_IPK_DIR)/opt/etc/init.d/SXXloudmouth
	$(MAKE) $(LOUDMOUTH_IPK_DIR)/CONTROL/control
#	install -m 755 $(LOUDMOUTH_SOURCE_DIR)/postinst $(LOUDMOUTH_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LOUDMOUTH_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LOUDMOUTH_SOURCE_DIR)/prerm $(LOUDMOUTH_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LOUDMOUTH_IPK_DIR)/CONTROL/prerm
	echo $(LOUDMOUTH_CONFFILES) | sed -e 's/ /\n/g' > $(LOUDMOUTH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LOUDMOUTH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
loudmouth-ipk: $(LOUDMOUTH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
loudmouth-clean:
	rm -f $(LOUDMOUTH_BUILD_DIR)/.built
	-$(MAKE) -C $(LOUDMOUTH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
loudmouth-dirclean:
	rm -rf $(BUILD_DIR)/$(LOUDMOUTH_DIR) $(LOUDMOUTH_BUILD_DIR) $(LOUDMOUTH_IPK_DIR) $(LOUDMOUTH_IPK)
#
#
# Some sanity check for the package.
#
loudmouth-check: $(LOUDMOUTH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LOUDMOUTH_IPK)
