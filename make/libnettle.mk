###########################################################
#
# libnettle
#
###########################################################

#
# LIBNETTLE_VERSION, LIBNETTLE_SITE and LIBNETTLE_SOURCE define
# the upstream location of the source code for the package.
# LIBNETTLE_DIR is the directory which is created when the source
# archive is unpacked.
# LIBNETTLE_UNZIP is the command used to unzip the source.
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
LIBNETTLE_SITE=ftp://ftp.gnu.org/gnu/nettle
LIBNETTLE_VERSION=3.1.1
LIBNETTLE_SOURCE=nettle-$(LIBNETTLE_VERSION).tar.gz
LIBNETTLE_DIR=nettle-$(LIBNETTLE_VERSION)
LIBNETTLE_UNZIP=zcat
LIBNETTLE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBNETTLE_DESCRIPTION=Nettle is a cryptographic library that is designed to fit easily in more or less any context: In crypto toolkits for object-oriented languages (C++, Python, Pike, ...), in applications like LSH or GNUPG, or even in kernel space.
LIBNETTLE_SECTION=misc
LIBNETTLE_PRIORITY=optional
LIBNETTLE_DEPENDS=libgmp
LIBNETTLE_SUGGESTS=
LIBNETTLE_CONFLICTS=

#
# LIBNETTLE_IPK_VERSION should be incremented when the ipk changes.
#
LIBNETTLE_IPK_VERSION=1

#
# LIBNETTLE_CONFFILES should be a list of user-editable files
#LIBNETTLE_CONFFILES=$(TARGET_PREFIX)/etc/libnettle.conf $(TARGET_PREFIX)/etc/init.d/SXXlibnettle

#
# LIBNETTLE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBNETTLE_PATCHES=$(LIBNETTLE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBNETTLE_CPPFLAGS=
LIBNETTLE_LDFLAGS=

#
# LIBNETTLE_BUILD_DIR is the directory in which the build is done.
# LIBNETTLE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBNETTLE_IPK_DIR is the directory in which the ipk is built.
# LIBNETTLE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBNETTLE_BUILD_DIR=$(BUILD_DIR)/libnettle
LIBNETTLE_SOURCE_DIR=$(SOURCE_DIR)/libnettle
LIBNETTLE_IPK_DIR=$(BUILD_DIR)/libnettle-$(LIBNETTLE_VERSION)-ipk
LIBNETTLE_IPK=$(BUILD_DIR)/libnettle_$(LIBNETTLE_VERSION)-$(LIBNETTLE_IPK_VERSION)_$(TARGET_ARCH).ipk


.PHONY: libnettle-source libnettle-unpack libnettle libnettle-stage libnettle-ipk libnettle-clean libnettle-dirclean libnettle-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBNETTLE_SOURCE):
	$(WGET) -P $(@D) $(LIBNETTLE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libnettle-source: $(DL_DIR)/$(LIBNETTLE_SOURCE) $(LIBNETTLE_PATCHES)

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
$(LIBNETTLE_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBNETTLE_SOURCE) $(LIBNETTLE_PATCHES) make/libnettle.mk
	$(MAKE) libgmp-stage
	rm -rf $(BUILD_DIR)/$(LIBNETTLE_DIR) $(@D)
	$(LIBNETTLE_UNZIP) $(DL_DIR)/$(LIBNETTLE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBNETTLE_PATCHES)" ; \
		then cat $(LIBNETTLE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBNETTLE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBNETTLE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBNETTLE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBNETTLE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBNETTLE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libnettle-unpack: $(LIBNETTLE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBNETTLE_BUILD_DIR)/.built: $(LIBNETTLE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libnettle: $(LIBNETTLE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBNETTLE_BUILD_DIR)/.staged: $(LIBNETTLE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libnettle.a
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/nettle.pc
	touch $@

libnettle-stage: $(LIBNETTLE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libnettle
#
$(LIBNETTLE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libnettle" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBNETTLE_PRIORITY)" >>$@
	@echo "Section: $(LIBNETTLE_SECTION)" >>$@
	@echo "Version: $(LIBNETTLE_VERSION)-$(LIBNETTLE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBNETTLE_MAINTAINER)" >>$@
	@echo "Source: $(LIBNETTLE_SITE)/$(LIBNETTLE_SOURCE)" >>$@
	@echo "Description: $(LIBNETTLE_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNETTLE_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNETTLE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNETTLE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBNETTLE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBNETTLE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBNETTLE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBNETTLE_IPK_DIR)$(TARGET_PREFIX)/etc/libnettle/...
# Documentation files should be installed in $(LIBNETTLE_IPK_DIR)$(TARGET_PREFIX)/doc/libnettle/...
# Daemon startup scripts should be installed in $(LIBNETTLE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libnettle
#
# You may need to patch your application to make it use these locations.
#
$(LIBNETTLE_IPK): $(LIBNETTLE_BUILD_DIR)/.built
	rm -rf $(LIBNETTLE_IPK_DIR) $(BUILD_DIR)/libnettle_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBNETTLE_BUILD_DIR) DESTDIR=$(LIBNETTLE_IPK_DIR) install
	$(STRIP_COMMAND) $(LIBNETTLE_IPK_DIR)$(TARGET_PREFIX)/lib/lib*.so $(LIBNETTLE_IPK_DIR)$(TARGET_PREFIX)/bin/*
	rm -f $(LIBNETTLE_IPK_DIR)$(TARGET_PREFIX)/lib/lib{nettle,hogweed}.a
#	$(INSTALL) -d $(LIBNETTLE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBNETTLE_SOURCE_DIR)/libnettle.conf $(LIBNETTLE_IPK_DIR)$(TARGET_PREFIX)/etc/libnettle.conf
#	$(INSTALL) -d $(LIBNETTLE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBNETTLE_SOURCE_DIR)/rc.libnettle $(LIBNETTLE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibnettle
	rm -f $(LIBNETTLE_IPK_DIR)$(TARGET_PREFIX)/share/info/dir
	$(MAKE) $(LIBNETTLE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBNETTLE_SOURCE_DIR)/postinst $(LIBNETTLE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBNETTLE_SOURCE_DIR)/prerm $(LIBNETTLE_IPK_DIR)/CONTROL/prerm
	echo $(LIBNETTLE_CONFFILES) | sed -e 's/ /\n/g' > $(LIBNETTLE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNETTLE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libnettle-ipk: $(LIBNETTLE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libnettle-clean:
	rm -f $(LIBNETTLE_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBNETTLE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libnettle-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBNETTLE_DIR) $(LIBNETTLE_BUILD_DIR) $(LIBNETTLE_IPK_DIR) $(LIBNETTLE_IPK)

#
# Some sanity check for the package.
#
libnettle-check: $(LIBNETTLE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
