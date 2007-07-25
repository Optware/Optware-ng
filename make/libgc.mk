###########################################################
#
# libgc
#
###########################################################

# You must replace "libgc" and "LIBGC" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBGC_VERSION, LIBGC_SITE and LIBGC_SOURCE define
# the upstream location of the source code for the package.
# LIBGC_DIR is the directory which is created when the source
# archive is unpacked.
# LIBGC_UNZIP is the command used to unzip the source.
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
LIBGC_SITE=http://www.hpl.hp.com/personal/Hans_Boehm/gc/gc_source
LIBGC_VERSION=6.8
LIBGC_SOURCE=gc$(LIBGC_VERSION).tar.gz
LIBGC_DIR=gc$(LIBGC_VERSION)
LIBGC_UNZIP=zcat
LIBGC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBGC_DESCRIPTION=The Boehm-Demers-Weiser conservative garbage collector can be used as a garbage collecting replacement for C malloc or C++ new.
LIBGC_SECTION=misc
LIBGC_PRIORITY=optional
LIBGC_DEPENDS=
LIBGC_CONFLICTS=

#
# LIBGC_IPK_VERSION should be incremented when the ipk changes.
#
LIBGC_IPK_VERSION=1

#
# LIBGC_CONFFILES should be a list of user-editable files
#LIBGC_CONFFILES=/opt/etc/libgc.conf /opt/etc/init.d/SXXlibgc

#
# LIBGC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(LIBC_STYLE), uclibc)
LIBGC_PATCHES=
else
LIBGC_PATCHES=$(LIBGC_SOURCE_DIR)/backtrace.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBGC_CPPFLAGS=
LIBGC_LDFLAGS=

#
# LIBGC_BUILD_DIR is the directory in which the build is done.
# LIBGC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBGC_IPK_DIR is the directory in which the ipk is built.
# LIBGC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBGC_BUILD_DIR=$(BUILD_DIR)/libgc
LIBGC_SOURCE_DIR=$(SOURCE_DIR)/libgc
LIBGC_IPK_DIR=$(BUILD_DIR)/libgc-$(LIBGC_VERSION)-ipk
LIBGC_IPK=$(BUILD_DIR)/libgc_$(LIBGC_VERSION)-$(LIBGC_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBGC_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBGC_SITE)/$(LIBGC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libgc-source: $(DL_DIR)/$(LIBGC_SOURCE) $(LIBGC_PATCHES)

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
$(LIBGC_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBGC_SOURCE) $(LIBGC_PATCHES) make/libgc.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBGC_DIR) $(LIBGC_BUILD_DIR)
	$(LIBGC_UNZIP) $(DL_DIR)/$(LIBGC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBGC_PATCHES)" ; \
		then cat $(LIBGC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBGC_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(LIBGC_DIR) $(LIBGC_BUILD_DIR)
	cp -f $(SOURCE_DIR)/common/config.* $(LIBGC_BUILD_DIR)/
	(cd $(LIBGC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBGC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBGC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(LIBGC_BUILD_DIR)/libtool
	touch $(LIBGC_BUILD_DIR)/.configured

libgc-unpack: $(LIBGC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBGC_BUILD_DIR)/.built: $(LIBGC_BUILD_DIR)/.configured
	rm -f $(LIBGC_BUILD_DIR)/.built
	$(MAKE) -C $(LIBGC_BUILD_DIR)
	touch $(LIBGC_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libgc: $(LIBGC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBGC_BUILD_DIR)/.staged: $(LIBGC_BUILD_DIR)/.built
	rm -f $(LIBGC_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBGC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libgc.la
	touch $(LIBGC_BUILD_DIR)/.staged

libgc-stage: $(LIBGC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libgc
#
$(LIBGC_IPK_DIR)/CONTROL/control:
	@install -d $(LIBGC_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libgc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBGC_PRIORITY)" >>$@
	@echo "Section: $(LIBGC_SECTION)" >>$@
	@echo "Version: $(LIBGC_VERSION)-$(LIBGC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBGC_MAINTAINER)" >>$@
	@echo "Source: $(LIBGC_SITE)/$(LIBGC_SOURCE)" >>$@
	@echo "Description: $(LIBGC_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBGC_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBGC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBGC_IPK_DIR)/opt/sbin or $(LIBGC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBGC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBGC_IPK_DIR)/opt/etc/libgc/...
# Documentation files should be installed in $(LIBGC_IPK_DIR)/opt/doc/libgc/...
# Daemon startup scripts should be installed in $(LIBGC_IPK_DIR)/opt/etc/init.d/S??libgc
#
# You may need to patch your application to make it use these locations.
#
$(LIBGC_IPK): $(LIBGC_BUILD_DIR)/.built
	rm -rf $(LIBGC_IPK_DIR) $(BUILD_DIR)/libgc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBGC_BUILD_DIR) DESTDIR=$(LIBGC_IPK_DIR) install-strip
#	install -d $(LIBGC_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBGC_SOURCE_DIR)/libgc.conf $(LIBGC_IPK_DIR)/opt/etc/libgc.conf
#	install -d $(LIBGC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBGC_SOURCE_DIR)/rc.libgc $(LIBGC_IPK_DIR)/opt/etc/init.d/SXXlibgc
	$(MAKE) $(LIBGC_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBGC_SOURCE_DIR)/postinst $(LIBGC_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBGC_SOURCE_DIR)/prerm $(LIBGC_IPK_DIR)/CONTROL/prerm
#	echo $(LIBGC_CONFFILES) | sed -e 's/ /\n/g' > $(LIBGC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBGC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libgc-ipk: $(LIBGC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libgc-clean:
	-$(MAKE) -C $(LIBGC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libgc-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBGC_DIR) $(LIBGC_BUILD_DIR) $(LIBGC_IPK_DIR) $(LIBGC_IPK)
