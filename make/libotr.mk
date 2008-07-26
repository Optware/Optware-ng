###########################################################
#
# libotr
#
###########################################################
#
# LIBOTR_VERSION, LIBOTR_SITE and LIBOTR_SOURCE define
# the upstream location of the source code for the package.
# LIBOTR_DIR is the directory which is created when the source
# archive is unpacked.
# LIBOTR_UNZIP is the command used to unzip the source.
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
LIBOTR_SITE=http://www.cypherpunks.ca/otr
LIBOTR_VERSION=3.2.0
LIBOTR_SOURCE=libotr-$(LIBOTR_VERSION).tar.gz
LIBOTR_DIR=libotr-$(LIBOTR_VERSION)
LIBOTR_UNZIP=zcat
LIBOTR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBOTR_DESCRIPTION=Off-the-Record (OTR) Messaging.
LIBOTR_SECTION=lib
LIBOTR_PRIORITY=optional
LIBOTR_DEPENDS=libgcrypt
LIBOTR_SUGGESTS=
LIBOTR_CONFLICTS=

#
# LIBOTR_IPK_VERSION should be incremented when the ipk changes.
#
LIBOTR_IPK_VERSION=1

#
# LIBOTR_CONFFILES should be a list of user-editable files
#LIBOTR_CONFFILES=/opt/etc/libotr.conf /opt/etc/init.d/SXXlibotr

#
# LIBOTR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBOTR_PATCHES=$(LIBOTR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBOTR_CPPFLAGS=
LIBOTR_LDFLAGS=

#
# LIBOTR_BUILD_DIR is the directory in which the build is done.
# LIBOTR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBOTR_IPK_DIR is the directory in which the ipk is built.
# LIBOTR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBOTR_BUILD_DIR=$(BUILD_DIR)/libotr
LIBOTR_SOURCE_DIR=$(SOURCE_DIR)/libotr
LIBOTR_IPK_DIR=$(BUILD_DIR)/libotr-$(LIBOTR_VERSION)-ipk
LIBOTR_IPK=$(BUILD_DIR)/libotr_$(LIBOTR_VERSION)-$(LIBOTR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libotr-source libotr-unpack libotr libotr-stage libotr-ipk libotr-clean libotr-dirclean libotr-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBOTR_SOURCE):
	$(WGET) -P $(@D) $(LIBOTR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libotr-source: $(DL_DIR)/$(LIBOTR_SOURCE) $(LIBOTR_PATCHES)

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
$(LIBOTR_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBOTR_SOURCE) $(LIBOTR_PATCHES) make/libotr.mk
	$(MAKE) libgpg-error-stage libgcrypt-stage
	rm -rf $(BUILD_DIR)/$(LIBOTR_DIR) $(@D)
	$(LIBOTR_UNZIP) $(DL_DIR)/$(LIBOTR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBOTR_PATCHES)" ; \
		then cat $(LIBOTR_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBOTR_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBOTR_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBOTR_DIR) $(@D) ; \
	fi
	sed -i -e '/^INCLUDES/s|-I$$(includedir) ||' $(@D)/toolkit/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBOTR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBOTR_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-libgcrypt-prefix=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libotr-unpack: $(LIBOTR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBOTR_BUILD_DIR)/.built: $(LIBOTR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libotr: $(LIBOTR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBOTR_BUILD_DIR)/.staged: $(LIBOTR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libotr.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libotr.pc
	touch $@

libotr-stage: $(LIBOTR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libotr
#
$(LIBOTR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libotr" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBOTR_PRIORITY)" >>$@
	@echo "Section: $(LIBOTR_SECTION)" >>$@
	@echo "Version: $(LIBOTR_VERSION)-$(LIBOTR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBOTR_MAINTAINER)" >>$@
	@echo "Source: $(LIBOTR_SITE)/$(LIBOTR_SOURCE)" >>$@
	@echo "Description: $(LIBOTR_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBOTR_DEPENDS)" >>$@
	@echo "Suggests: $(LIBOTR_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBOTR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBOTR_IPK_DIR)/opt/sbin or $(LIBOTR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBOTR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBOTR_IPK_DIR)/opt/etc/libotr/...
# Documentation files should be installed in $(LIBOTR_IPK_DIR)/opt/doc/libotr/...
# Daemon startup scripts should be installed in $(LIBOTR_IPK_DIR)/opt/etc/init.d/S??libotr
#
# You may need to patch your application to make it use these locations.
#
$(LIBOTR_IPK): $(LIBOTR_BUILD_DIR)/.built
	rm -rf $(LIBOTR_IPK_DIR) $(BUILD_DIR)/libotr_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBOTR_BUILD_DIR) DESTDIR=$(LIBOTR_IPK_DIR) install-strip
#	install -d $(LIBOTR_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBOTR_SOURCE_DIR)/libotr.conf $(LIBOTR_IPK_DIR)/opt/etc/libotr.conf
#	install -d $(LIBOTR_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBOTR_SOURCE_DIR)/rc.libotr $(LIBOTR_IPK_DIR)/opt/etc/init.d/SXXlibotr
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBOTR_IPK_DIR)/opt/etc/init.d/SXXlibotr
	$(MAKE) $(LIBOTR_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBOTR_SOURCE_DIR)/postinst $(LIBOTR_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBOTR_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBOTR_SOURCE_DIR)/prerm $(LIBOTR_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBOTR_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBOTR_IPK_DIR)/CONTROL/postinst $(LIBOTR_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBOTR_CONFFILES) | sed -e 's/ /\n/g' > $(LIBOTR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBOTR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libotr-ipk: $(LIBOTR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libotr-clean:
	rm -f $(LIBOTR_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBOTR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libotr-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBOTR_DIR) $(LIBOTR_BUILD_DIR) $(LIBOTR_IPK_DIR) $(LIBOTR_IPK)
#
#
# Some sanity check for the package.
#
libotr-check: $(LIBOTR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBOTR_IPK)
