###########################################################
#
# libmpdclient
#
###########################################################
#
# LIBMPDCLIENT_VERSION, LIBMPDCLIENT_SITE and LIBMPDCLIENT_SOURCE define
# the upstream location of the source code for the package.
# LIBMPDCLIENT_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMPDCLIENT_UNZIP is the command used to unzip the source.
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
LIBMPDCLIENT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/musicpd
LIBMPDCLIENT_VERSION=2.1
LIBMPDCLIENT_SOURCE=libmpdclient-$(LIBMPDCLIENT_VERSION).tar.bz2
LIBMPDCLIENT_DIR=libmpdclient-$(LIBMPDCLIENT_VERSION)
LIBMPDCLIENT_UNZIP=bzcat
LIBMPDCLIENT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMPDCLIENT_DESCRIPTION=A stable, documented, asynchronous API library for interfacing MPD in the C, C++ & Objective C languages
LIBMPDCLIENT_SECTION=lib
LIBMPDCLIENT_PRIORITY=optional
LIBMPDCLIENT_DEPENDS=
LIBMPDCLIENT_SUGGESTS=
LIBMPDCLIENT_CONFLICTS=

#
# LIBMPDCLIENT_IPK_VERSION should be incremented when the ipk changes.
#
LIBMPDCLIENT_IPK_VERSION=1

#
# LIBMPDCLIENT_CONFFILES should be a list of user-editable files
#LIBMPDCLIENT_CONFFILES=/opt/etc/libmpdclient.conf /opt/etc/init.d/SXXlibmpdclient

#
# LIBMPDCLIENT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBMPDCLIENT_PATCHES=$(LIBMPDCLIENT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMPDCLIENT_CPPFLAGS=
LIBMPDCLIENT_LDFLAGS=

#
# LIBMPDCLIENT_BUILD_DIR is the directory in which the build is done.
# LIBMPDCLIENT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMPDCLIENT_IPK_DIR is the directory in which the ipk is built.
# LIBMPDCLIENT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMPDCLIENT_BUILD_DIR=$(BUILD_DIR)/libmpdclient
LIBMPDCLIENT_SOURCE_DIR=$(SOURCE_DIR)/libmpdclient
LIBMPDCLIENT_IPK_DIR=$(BUILD_DIR)/libmpdclient-$(LIBMPDCLIENT_VERSION)-ipk
LIBMPDCLIENT_IPK=$(BUILD_DIR)/libmpdclient_$(LIBMPDCLIENT_VERSION)-$(LIBMPDCLIENT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmpdclient-source libmpdclient-unpack libmpdclient libmpdclient-stage libmpdclient-ipk libmpdclient-clean libmpdclient-dirclean libmpdclient-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMPDCLIENT_SOURCE):
	$(WGET) -P $(@D) $(LIBMPDCLIENT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmpdclient-source: $(DL_DIR)/$(LIBMPDCLIENT_SOURCE) $(LIBMPDCLIENT_PATCHES)

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
$(LIBMPDCLIENT_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMPDCLIENT_SOURCE) $(LIBMPDCLIENT_PATCHES) make/libmpdclient.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBMPDCLIENT_DIR) $(@D)
	$(LIBMPDCLIENT_UNZIP) $(DL_DIR)/$(LIBMPDCLIENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMPDCLIENT_PATCHES)" ; \
		then cat $(LIBMPDCLIENT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBMPDCLIENT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMPDCLIENT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBMPDCLIENT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMPDCLIENT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMPDCLIENT_LDFLAGS)" \
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

libmpdclient-unpack: $(LIBMPDCLIENT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMPDCLIENT_BUILD_DIR)/.built: $(LIBMPDCLIENT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libmpdclient: $(LIBMPDCLIENT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMPDCLIENT_BUILD_DIR)/.staged: $(LIBMPDCLIENT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libmpdclient.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libmpdclient.pc
	touch $@

libmpdclient-stage: $(LIBMPDCLIENT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmpdclient
#
$(LIBMPDCLIENT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libmpdclient" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMPDCLIENT_PRIORITY)" >>$@
	@echo "Section: $(LIBMPDCLIENT_SECTION)" >>$@
	@echo "Version: $(LIBMPDCLIENT_VERSION)-$(LIBMPDCLIENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMPDCLIENT_MAINTAINER)" >>$@
	@echo "Source: $(LIBMPDCLIENT_SITE)/$(LIBMPDCLIENT_SOURCE)" >>$@
	@echo "Description: $(LIBMPDCLIENT_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMPDCLIENT_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMPDCLIENT_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMPDCLIENT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMPDCLIENT_IPK_DIR)/opt/sbin or $(LIBMPDCLIENT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMPDCLIENT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBMPDCLIENT_IPK_DIR)/opt/etc/libmpdclient/...
# Documentation files should be installed in $(LIBMPDCLIENT_IPK_DIR)/opt/doc/libmpdclient/...
# Daemon startup scripts should be installed in $(LIBMPDCLIENT_IPK_DIR)/opt/etc/init.d/S??libmpdclient
#
# You may need to patch your application to make it use these locations.
#
$(LIBMPDCLIENT_IPK): $(LIBMPDCLIENT_BUILD_DIR)/.built
	rm -rf $(LIBMPDCLIENT_IPK_DIR) $(BUILD_DIR)/libmpdclient_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMPDCLIENT_BUILD_DIR) DESTDIR=$(LIBMPDCLIENT_IPK_DIR) install-strip
#	install -d $(LIBMPDCLIENT_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBMPDCLIENT_SOURCE_DIR)/libmpdclient.conf $(LIBMPDCLIENT_IPK_DIR)/opt/etc/libmpdclient.conf
#	install -d $(LIBMPDCLIENT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBMPDCLIENT_SOURCE_DIR)/rc.libmpdclient $(LIBMPDCLIENT_IPK_DIR)/opt/etc/init.d/SXXlibmpdclient
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMPDCLIENT_IPK_DIR)/opt/etc/init.d/SXXlibmpdclient
	$(MAKE) $(LIBMPDCLIENT_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBMPDCLIENT_SOURCE_DIR)/postinst $(LIBMPDCLIENT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMPDCLIENT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBMPDCLIENT_SOURCE_DIR)/prerm $(LIBMPDCLIENT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMPDCLIENT_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBMPDCLIENT_IPK_DIR)/CONTROL/postinst $(LIBMPDCLIENT_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBMPDCLIENT_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMPDCLIENT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMPDCLIENT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmpdclient-ipk: $(LIBMPDCLIENT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmpdclient-clean:
	rm -f $(LIBMPDCLIENT_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMPDCLIENT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmpdclient-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMPDCLIENT_DIR) $(LIBMPDCLIENT_BUILD_DIR) $(LIBMPDCLIENT_IPK_DIR) $(LIBMPDCLIENT_IPK)
#
#
# Some sanity check for the package.
#
libmpdclient-check: $(LIBMPDCLIENT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
