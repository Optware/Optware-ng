###########################################################
#
# libdaemon
#
###########################################################
#
# LIBDAEMON_VERSION, LIBDAEMON_SITE and LIBDAEMON_SOURCE define
# the upstream location of the source code for the package.
# LIBDAEMON_DIR is the directory which is created when the source
# archive is unpacked.
# LIBDAEMON_UNZIP is the command used to unzip the source.
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
LIBDAEMON_SITE=http://0pointer.de/lennart/projects/libdaemon
LIBDAEMON_VERSION=0.10
LIBDAEMON_SOURCE=libdaemon-$(LIBDAEMON_VERSION).tar.gz
LIBDAEMON_DIR=libdaemon-$(LIBDAEMON_VERSION)
LIBDAEMON_UNZIP=zcat
LIBDAEMON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBDAEMON_DESCRIPTION=A lightweight C library that eases the writing of UNIX daemons.
LIBDAEMON_SECTION=lib
LIBDAEMON_PRIORITY=optional
LIBDAEMON_DEPENDS=
LIBDAEMON_SUGGESTS=
LIBDAEMON_CONFLICTS=

#
# LIBDAEMON_IPK_VERSION should be incremented when the ipk changes.
#
LIBDAEMON_IPK_VERSION=2

#
# LIBDAEMON_CONFFILES should be a list of user-editable files
#LIBDAEMON_CONFFILES=/opt/etc/libdaemon.conf /opt/etc/init.d/SXXlibdaemon

#
# LIBDAEMON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBDAEMON_PATCHES=$(LIBDAEMON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBDAEMON_CPPFLAGS=
LIBDAEMON_LDFLAGS=

#
# LIBDAEMON_BUILD_DIR is the directory in which the build is done.
# LIBDAEMON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBDAEMON_IPK_DIR is the directory in which the ipk is built.
# LIBDAEMON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBDAEMON_BUILD_DIR=$(BUILD_DIR)/libdaemon
LIBDAEMON_SOURCE_DIR=$(SOURCE_DIR)/libdaemon
LIBDAEMON_IPK_DIR=$(BUILD_DIR)/libdaemon-$(LIBDAEMON_VERSION)-ipk
LIBDAEMON_IPK=$(BUILD_DIR)/libdaemon_$(LIBDAEMON_VERSION)-$(LIBDAEMON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libdaemon-source libdaemon-unpack libdaemon libdaemon-stage libdaemon-ipk libdaemon-clean libdaemon-dirclean libdaemon-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBDAEMON_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBDAEMON_SITE)/$(LIBDAEMON_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBDAEMON_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libdaemon-source: $(DL_DIR)/$(LIBDAEMON_SOURCE) $(LIBDAEMON_PATCHES)

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
$(LIBDAEMON_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBDAEMON_SOURCE) $(LIBDAEMON_PATCHES) make/libdaemon.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBDAEMON_DIR) $(LIBDAEMON_BUILD_DIR)
	$(LIBDAEMON_UNZIP) $(DL_DIR)/$(LIBDAEMON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBDAEMON_PATCHES)" ; \
		then cat $(LIBDAEMON_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBDAEMON_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBDAEMON_DIR)" != "$(LIBDAEMON_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBDAEMON_DIR) $(LIBDAEMON_BUILD_DIR) ; \
	fi
	(cd $(LIBDAEMON_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBDAEMON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBDAEMON_LDFLAGS)" \
		ac_cv_func_setpgrp_void=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-lynx \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBDAEMON_BUILD_DIR)/libtool
	touch $@

libdaemon-unpack: $(LIBDAEMON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBDAEMON_BUILD_DIR)/.built: $(LIBDAEMON_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBDAEMON_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libdaemon: $(LIBDAEMON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBDAEMON_BUILD_DIR)/.staged: $(LIBDAEMON_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBDAEMON_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libdaemon.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libdaemon.pc
	touch $@

libdaemon-stage: $(LIBDAEMON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libdaemon
#
$(LIBDAEMON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libdaemon" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBDAEMON_PRIORITY)" >>$@
	@echo "Section: $(LIBDAEMON_SECTION)" >>$@
	@echo "Version: $(LIBDAEMON_VERSION)-$(LIBDAEMON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBDAEMON_MAINTAINER)" >>$@
	@echo "Source: $(LIBDAEMON_SITE)/$(LIBDAEMON_SOURCE)" >>$@
	@echo "Description: $(LIBDAEMON_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBDAEMON_DEPENDS)" >>$@
	@echo "Suggests: $(LIBDAEMON_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBDAEMON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBDAEMON_IPK_DIR)/opt/sbin or $(LIBDAEMON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBDAEMON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBDAEMON_IPK_DIR)/opt/etc/libdaemon/...
# Documentation files should be installed in $(LIBDAEMON_IPK_DIR)/opt/doc/libdaemon/...
# Daemon startup scripts should be installed in $(LIBDAEMON_IPK_DIR)/opt/etc/init.d/S??libdaemon
#
# You may need to patch your application to make it use these locations.
#
$(LIBDAEMON_IPK): $(LIBDAEMON_BUILD_DIR)/.built
	rm -rf $(LIBDAEMON_IPK_DIR) $(BUILD_DIR)/libdaemon_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBDAEMON_BUILD_DIR) DESTDIR=$(LIBDAEMON_IPK_DIR) install-strip
	rm -f $(LIBDAEMON_IPK_DIR)/opt/lib/libdaemon.la
#	install -d $(LIBDAEMON_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBDAEMON_SOURCE_DIR)/libdaemon.conf $(LIBDAEMON_IPK_DIR)/opt/etc/libdaemon.conf
#	install -d $(LIBDAEMON_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBDAEMON_SOURCE_DIR)/rc.libdaemon $(LIBDAEMON_IPK_DIR)/opt/etc/init.d/SXXlibdaemon
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBDAEMON_IPK_DIR)/opt/etc/init.d/SXXlibdaemon
	$(MAKE) $(LIBDAEMON_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBDAEMON_SOURCE_DIR)/postinst $(LIBDAEMON_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBDAEMON_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBDAEMON_SOURCE_DIR)/prerm $(LIBDAEMON_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBDAEMON_IPK_DIR)/CONTROL/prerm
	echo $(LIBDAEMON_CONFFILES) | sed -e 's/ /\n/g' > $(LIBDAEMON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBDAEMON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libdaemon-ipk: $(LIBDAEMON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libdaemon-clean:
	rm -f $(LIBDAEMON_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBDAEMON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libdaemon-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBDAEMON_DIR) $(LIBDAEMON_BUILD_DIR) $(LIBDAEMON_IPK_DIR) $(LIBDAEMON_IPK)
#
#
# Some sanity check for the package.
#
libdaemon-check: $(LIBDAEMON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBDAEMON_IPK)
