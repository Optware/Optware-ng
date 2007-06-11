###########################################################
#
# slang1
#
###########################################################
#
# SLANG1_VERSION, SLANG1_SITE and SLANG1_SOURCE define
# the upstream location of the source code for the package.
# SLANG1_DIR is the directory which is created when the source
# archive is unpacked.
# SLANG1_UNZIP is the command used to unzip the source.
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
SLANG1_SITE=ftp://space.mit.edu/pub/davis/slang/v1.4
SLANG1_VERSION=1.4.9
SLANG1_SOURCE=slang-$(SLANG1_VERSION).tar.bz2
SLANG1_DIR=slang-$(SLANG1_VERSION)
SLANG1_UNZIP=bzcat
SLANG1_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SLANG1_DESCRIPTION=S-Lang is a multi-platform library designed to allow a developer to create robust multi-platform software, v1.
SLANG1_SECTION=lib
SLANG1_PRIORITY=optional
SLANG1_DEPENDS=
SLANG1_SUGGESTS=
SLANG1_CONFLICTS=

#
# SLANG1_IPK_VERSION should be incremented when the ipk changes.
#
SLANG1_IPK_VERSION=1

#
# SLANG1_CONFFILES should be a list of user-editable files
#SLANG1_CONFFILES=/opt/etc/slang1.conf /opt/etc/init.d/SXXslang1

#
# SLANG1_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SLANG1_PATCHES=
ifeq (uclibc, $(LIBC_STYLE))
SLANG1_PATCHES+=$(SLANG1_SOURCE_DIR)/uclibc.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SLANG1_CPPFLAGS=
SLANG1_LDFLAGS=

#
# SLANG1_BUILD_DIR is the directory in which the build is done.
# SLANG1_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SLANG1_IPK_DIR is the directory in which the ipk is built.
# SLANG1_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SLANG1_BUILD_DIR=$(BUILD_DIR)/slang1
SLANG1_SOURCE_DIR=$(SOURCE_DIR)/slang1
SLANG1_IPK_DIR=$(BUILD_DIR)/slang1-$(SLANG1_VERSION)-ipk
SLANG1_IPK=$(BUILD_DIR)/slang1_$(SLANG1_VERSION)-$(SLANG1_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: slang1-source slang1-unpack slang1 slang1-stage slang1-ipk slang1-clean slang1-dirclean slang1-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SLANG1_SOURCE):
	$(WGET) -P $(DL_DIR) $(SLANG1_SITE)/$(SLANG1_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SLANG1_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
slang1-source: $(DL_DIR)/$(SLANG1_SOURCE) $(SLANG1_PATCHES)

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
$(SLANG1_BUILD_DIR)/.configured: $(DL_DIR)/$(SLANG1_SOURCE) $(SLANG1_PATCHES) make/slang1.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SLANG1_DIR) $(SLANG1_BUILD_DIR)
	$(SLANG1_UNZIP) $(DL_DIR)/$(SLANG1_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SLANG1_PATCHES)" ; \
		then cat $(SLANG1_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SLANG1_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SLANG1_DIR)" != "$(SLANG1_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SLANG1_DIR) $(SLANG1_BUILD_DIR) ; \
	fi
	(cd $(SLANG1_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SLANG1_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SLANG1_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--libdir='$${exec_prefix}/lib/slang1' \
		--includedir='$${prefix}/include/slang1' \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(SLANG1_BUILD_DIR)/libtool
	touch $@

slang1-unpack: $(SLANG1_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SLANG1_BUILD_DIR)/.built: $(SLANG1_BUILD_DIR)/.configured
	rm -f $@
	# build static to avoid conflict with slang2
	$(MAKE) -C $(SLANG1_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
slang1: $(SLANG1_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SLANG1_BUILD_DIR)/.staged: $(SLANG1_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SLANG1_BUILD_DIR)/src prefix=$(STAGING_PREFIX) install_basic_lib
	touch $@

slang1-stage: $(SLANG1_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/slang1
#
$(SLANG1_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: slang1" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SLANG1_PRIORITY)" >>$@
	@echo "Section: $(SLANG1_SECTION)" >>$@
	@echo "Version: $(SLANG1_VERSION)-$(SLANG1_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SLANG1_MAINTAINER)" >>$@
	@echo "Source: $(SLANG1_SITE)/$(SLANG1_SOURCE)" >>$@
	@echo "Description: $(SLANG1_DESCRIPTION)" >>$@
	@echo "Depends: $(SLANG1_DEPENDS)" >>$@
	@echo "Suggests: $(SLANG1_SUGGESTS)" >>$@
	@echo "Conflicts: $(SLANG1_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SLANG1_IPK_DIR)/opt/sbin or $(SLANG1_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SLANG1_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SLANG1_IPK_DIR)/opt/etc/slang1/...
# Documentation files should be installed in $(SLANG1_IPK_DIR)/opt/doc/slang1/...
# Daemon startup scripts should be installed in $(SLANG1_IPK_DIR)/opt/etc/init.d/S??slang1
#
# You may need to patch your application to make it use these locations.
#
$(SLANG1_IPK): $(SLANG1_BUILD_DIR)/.built
	rm -rf $(SLANG1_IPK_DIR) $(BUILD_DIR)/slang1_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SLANG1_BUILD_DIR)/src prefix=$(SLANG1_IPK_DIR)/opt install_basic_lib
	$(MAKE) $(SLANG1_IPK_DIR)/CONTROL/control
	echo $(SLANG1_CONFFILES) | sed -e 's/ /\n/g' > $(SLANG1_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SLANG1_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
slang1-ipk: $(SLANG1_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
slang1-clean:
	rm -f $(SLANG1_BUILD_DIR)/.built
	-$(MAKE) -C $(SLANG1_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
slang1-dirclean:
	rm -rf $(BUILD_DIR)/$(SLANG1_DIR) $(SLANG1_BUILD_DIR) $(SLANG1_IPK_DIR) $(SLANG1_IPK)
#
#
# Some sanity check for the package.
#
slang1-check: $(SLANG1_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SLANG1_IPK)
