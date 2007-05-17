###########################################################
#
# libelf
#
###########################################################
#
# LIBELF_VERSION, LIBELF_SITE and LIBELF_SOURCE define
# the upstream location of the source code for the package.
# LIBELF_DIR is the directory which is created when the source
# archive is unpacked.
# LIBELF_UNZIP is the command used to unzip the source.
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
LIBELF_SITE=http://www.mr511.de/software
LIBELF_VERSION=0.8.9
LIBELF_SOURCE=libelf-$(LIBELF_VERSION).tar.gz
LIBELF_DIR=libelf-$(LIBELF_VERSION)
LIBELF_UNZIP=zcat
LIBELF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBELF_DESCRIPTION=libelf lets you read, modify or create ELF files in an architecture-independent way.
LIBELF_SECTION=lib
LIBELF_PRIORITY=optional
LIBELF_DEPENDS=
LIBELF_SUGGESTS=
LIBELF_CONFLICTS=

#
# LIBELF_IPK_VERSION should be incremented when the ipk changes.
#
LIBELF_IPK_VERSION=1

#
# LIBELF_CONFFILES should be a list of user-editable files
#LIBELF_CONFFILES=/opt/etc/libelf.conf /opt/etc/init.d/SXXlibelf

#
# LIBELF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBELF_PATCHES=$(LIBELF_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBELF_CPPFLAGS=
LIBELF_LDFLAGS=

#
# LIBELF_BUILD_DIR is the directory in which the build is done.
# LIBELF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBELF_IPK_DIR is the directory in which the ipk is built.
# LIBELF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBELF_BUILD_DIR=$(BUILD_DIR)/libelf
LIBELF_SOURCE_DIR=$(SOURCE_DIR)/libelf
LIBELF_IPK_DIR=$(BUILD_DIR)/libelf-$(LIBELF_VERSION)-ipk
LIBELF_IPK=$(BUILD_DIR)/libelf_$(LIBELF_VERSION)-$(LIBELF_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libelf-source libelf-unpack libelf libelf-stage libelf-ipk libelf-clean libelf-dirclean libelf-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBELF_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBELF_SITE)/$(LIBELF_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBELF_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libelf-source: $(DL_DIR)/$(LIBELF_SOURCE) $(LIBELF_PATCHES)

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
$(LIBELF_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBELF_SOURCE) $(LIBELF_PATCHES) make/libelf.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBELF_DIR) $(LIBELF_BUILD_DIR)
	$(LIBELF_UNZIP) $(DL_DIR)/$(LIBELF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBELF_PATCHES)" ; \
		then cat $(LIBELF_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBELF_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBELF_DIR)" != "$(LIBELF_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBELF_DIR) $(LIBELF_BUILD_DIR) ; \
	fi
	(cd $(LIBELF_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBELF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBELF_LDFLAGS)" \
		ac_cv_sizeof_long_long=8 \
		ac_cv_func_mmap_fixed_mapped=yes \
		libelf_cv_working_memmove=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-shared \
	)
#	$(PATCH_LIBTOOL) $(LIBELF_BUILD_DIR)/libtool
	touch $@

libelf-unpack: $(LIBELF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBELF_BUILD_DIR)/.built: $(LIBELF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBELF_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libelf: $(LIBELF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBELF_BUILD_DIR)/.staged: $(LIBELF_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBELF_BUILD_DIR) prefix=$(STAGING_PREFIX) install
	sed -i -e '/^prefix=/s|=/opt|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libelf.pc
	touch $@

libelf-stage: $(LIBELF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libelf
#
$(LIBELF_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libelf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBELF_PRIORITY)" >>$@
	@echo "Section: $(LIBELF_SECTION)" >>$@
	@echo "Version: $(LIBELF_VERSION)-$(LIBELF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBELF_MAINTAINER)" >>$@
	@echo "Source: $(LIBELF_SITE)/$(LIBELF_SOURCE)" >>$@
	@echo "Description: $(LIBELF_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBELF_DEPENDS)" >>$@
	@echo "Suggests: $(LIBELF_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBELF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBELF_IPK_DIR)/opt/sbin or $(LIBELF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBELF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBELF_IPK_DIR)/opt/etc/libelf/...
# Documentation files should be installed in $(LIBELF_IPK_DIR)/opt/doc/libelf/...
# Daemon startup scripts should be installed in $(LIBELF_IPK_DIR)/opt/etc/init.d/S??libelf
#
# You may need to patch your application to make it use these locations.
#
$(LIBELF_IPK): $(LIBELF_BUILD_DIR)/.built
	rm -rf $(LIBELF_IPK_DIR) $(BUILD_DIR)/libelf_*_$(TARGET_ARCH).ipk
#	install -d $(LIBELF_IPK_DIR)/opt
	$(MAKE) -C $(LIBELF_BUILD_DIR) prefix=$(LIBELF_IPK_DIR)/opt install
#	install -d $(LIBELF_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBELF_SOURCE_DIR)/libelf.conf $(LIBELF_IPK_DIR)/opt/etc/libelf.conf
#	install -d $(LIBELF_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBELF_SOURCE_DIR)/rc.libelf $(LIBELF_IPK_DIR)/opt/etc/init.d/SXXlibelf
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBELF_IPK_DIR)/opt/etc/init.d/SXXlibelf
	$(MAKE) $(LIBELF_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBELF_SOURCE_DIR)/postinst $(LIBELF_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBELF_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBELF_SOURCE_DIR)/prerm $(LIBELF_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBELF_IPK_DIR)/CONTROL/prerm
	echo $(LIBELF_CONFFILES) | sed -e 's/ /\n/g' > $(LIBELF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBELF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libelf-ipk: $(LIBELF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libelf-clean:
	rm -f $(LIBELF_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBELF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libelf-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBELF_DIR) $(LIBELF_BUILD_DIR) $(LIBELF_IPK_DIR) $(LIBELF_IPK)
#
#
# Some sanity check for the package.
#
libelf-check: $(LIBELF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBELF_IPK)
