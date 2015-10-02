###########################################################
#
# libatomic-ops
#
###########################################################

# You must replace "libatomic-ops" and "LIBATOMIC_OPS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBATOMIC_OPS_VERSION, LIBATOMIC_OPS_SITE and LIBATOMIC_OPS_SOURCE define
# the upstream location of the source code for the package.
# LIBATOMIC_OPS_DIR is the directory which is created when the source
# archive is unpacked.
# LIBATOMIC_OPS_UNZIP is the command used to unzip the source.
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
LIBATOMIC_OPS_SITE=https://github.com/ivmai/libatomic_ops/archive
LIBATOMIC_OPS_VERSION=7.4.2
LIBATOMIC_OPS_SOURCE=libatomic_ops-$(shell echo $(LIBATOMIC_OPS_VERSION)|sed "s/\./_/g").tar.gz
LIBATOMIC_OPS_DIR=libatomic_ops-libatomic_ops-$(shell echo $(LIBATOMIC_OPS_VERSION)|sed "s/\./_/g")
LIBATOMIC_OPS_UNZIP=zcat
LIBATOMIC_OPS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBATOMIC_OPS_DESCRIPTION=The Boehm-Demers-Weiser conservative garbage collector can be used as a garbage collecting replacement for C malloc or C++ new.
LIBATOMIC_OPS_SECTION=misc
LIBATOMIC_OPS_PRIORITY=optional
LIBATOMIC_OPS_DEPENDS=
LIBATOMIC_OPS_CONFLICTS=

#
# LIBATOMIC_OPS_IPK_VERSION should be incremented when the ipk changes.
#
LIBATOMIC_OPS_IPK_VERSION=1

#
# LIBATOMIC_OPS_CONFFILES should be a list of user-editable files
#LIBATOMIC_OPS_CONFFILES=/opt/etc/libatomic-ops.conf /opt/etc/init.d/SXXlibatomic-ops

#
# LIBATOMIC_OPS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBATOMIC_OPS_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBATOMIC_OPS_CPPFLAGS=
LIBATOMIC_OPS_LDFLAGS=

#
# LIBATOMIC_OPS_BUILD_DIR is the directory in which the build is done.
# LIBATOMIC_OPS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBATOMIC_OPS_IPK_DIR is the directory in which the ipk is built.
# LIBATOMIC_OPS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBATOMIC_OPS_BUILD_DIR=$(BUILD_DIR)/libatomic-ops
LIBATOMIC_OPS_SOURCE_DIR=$(SOURCE_DIR)/libatomic-ops
LIBATOMIC_OPS_IPK_DIR=$(BUILD_DIR)/libatomic-ops-$(LIBATOMIC_OPS_VERSION)-ipk
LIBATOMIC_OPS_IPK=$(BUILD_DIR)/libatomic-ops_$(LIBATOMIC_OPS_VERSION)-$(LIBATOMIC_OPS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBATOMIC_OPS_SOURCE):
	$(WGET) -O $@ $(LIBATOMIC_OPS_SITE)/$(LIBATOMIC_OPS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libatomic-ops-source: $(DL_DIR)/$(LIBATOMIC_OPS_SOURCE) $(LIBATOMIC_OPS_PATCHES)

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
$(LIBATOMIC_OPS_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBATOMIC_OPS_SOURCE) $(LIBATOMIC_OPS_PATCHES) make/libatomic-ops.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBATOMIC_OPS_DIR) $(@D)
	$(LIBATOMIC_OPS_UNZIP) $(DL_DIR)/$(LIBATOMIC_OPS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBATOMIC_OPS_PATCHES)" ; \
		then cat $(LIBATOMIC_OPS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBATOMIC_OPS_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(LIBATOMIC_OPS_DIR) $(@D)
	cp -f $(SOURCE_DIR)/common/config.* $(@D)/
	(cd $(@D); \
		./autogen.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBATOMIC_OPS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBATOMIC_OPS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-shared=yes \
		--enable-static=no \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(LIBATOMIC_OPS_BUILD_DIR)/libtool
	touch $@

libatomic-ops-unpack: $(LIBATOMIC_OPS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBATOMIC_OPS_BUILD_DIR)/.built: $(LIBATOMIC_OPS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libatomic-ops: $(LIBATOMIC_OPS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBATOMIC_OPS_BUILD_DIR)/.staged: $(LIBATOMIC_OPS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libatomic-ops.la $(STAGING_LIB_DIR)/libatomic-ops_gpl.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/atomic_ops.pc
	touch $@

libatomic-ops-stage: $(LIBATOMIC_OPS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libatomic-ops
#
$(LIBATOMIC_OPS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(LIBATOMIC_OPS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libatomic-ops" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBATOMIC_OPS_PRIORITY)" >>$@
	@echo "Section: $(LIBATOMIC_OPS_SECTION)" >>$@
	@echo "Version: $(LIBATOMIC_OPS_VERSION)-$(LIBATOMIC_OPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBATOMIC_OPS_MAINTAINER)" >>$@
	@echo "Source: $(LIBATOMIC_OPS_SITE)/$(LIBATOMIC_OPS_SOURCE)" >>$@
	@echo "Description: $(LIBATOMIC_OPS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBATOMIC_OPS_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBATOMIC_OPS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBATOMIC_OPS_IPK_DIR)/opt/sbin or $(LIBATOMIC_OPS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBATOMIC_OPS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBATOMIC_OPS_IPK_DIR)/opt/etc/libatomic-ops/...
# Documentation files should be installed in $(LIBATOMIC_OPS_IPK_DIR)/opt/doc/libatomic-ops/...
# Daemon startup scripts should be installed in $(LIBATOMIC_OPS_IPK_DIR)/opt/etc/init.d/S??libatomic-ops
#
# You may need to patch your application to make it use these locations.
#
$(LIBATOMIC_OPS_IPK): $(LIBATOMIC_OPS_BUILD_DIR)/.built
	rm -rf $(LIBATOMIC_OPS_IPK_DIR) $(BUILD_DIR)/libatomic-ops_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBATOMIC_OPS_BUILD_DIR) DESTDIR=$(LIBATOMIC_OPS_IPK_DIR) install-strip
#	$(INSTALL) -d $(LIBATOMIC_OPS_IPK_DIR)/opt/etc/
#	$(INSTALL) -m 644 $(LIBATOMIC_OPS_SOURCE_DIR)/libatomic-ops.conf $(LIBATOMIC_OPS_IPK_DIR)/opt/etc/libatomic-ops.conf
#	$(INSTALL) -d $(LIBATOMIC_OPS_IPK_DIR)/opt/etc/init.d
#	$(INSTALL) -m 755 $(LIBATOMIC_OPS_SOURCE_DIR)/rc.libatomic-ops $(LIBATOMIC_OPS_IPK_DIR)/opt/etc/init.d/SXXlibatomic-ops
	$(MAKE) $(LIBATOMIC_OPS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBATOMIC_OPS_SOURCE_DIR)/postinst $(LIBATOMIC_OPS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBATOMIC_OPS_SOURCE_DIR)/prerm $(LIBATOMIC_OPS_IPK_DIR)/CONTROL/prerm
#	echo $(LIBATOMIC_OPS_CONFFILES) | sed -e 's/ /\n/g' > $(LIBATOMIC_OPS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBATOMIC_OPS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libatomic-ops-ipk: $(LIBATOMIC_OPS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libatomic-ops-clean:
	-$(MAKE) -C $(LIBATOMIC_OPS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libatomic-ops-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBATOMIC_OPS_DIR) $(LIBATOMIC_OPS_BUILD_DIR) $(LIBATOMIC_OPS_IPK_DIR) $(LIBATOMIC_OPS_IPK)

#
# Some sanity check for the package.
#
libatomic-ops-check: $(LIBATOMIC_OPS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
