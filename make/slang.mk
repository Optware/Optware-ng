###########################################################
#
# slang
#
###########################################################
#
# SLANG_VERSION, SLANG_SITE and SLANG_SOURCE define
# the upstream location of the source code for the package.
# SLANG_DIR is the directory which is created when the source
# archive is unpacked.
# SLANG_UNZIP is the command used to unzip the source.
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
SLANG_SITE=ftp://space.mit.edu/pub/davis/slang/v2.0
SLANG_VERSION=2.0.7
SLANG_SOURCE=slang-$(SLANG_VERSION).tar.bz2
SLANG_DIR=slang-$(SLANG_VERSION)
SLANG_UNZIP=bzcat
SLANG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SLANG_DESCRIPTION=S-Lang is a multi-platform library designed to allow a developer to create robust multi-platform software.
SLANG_SECTION=lib
SLANG_PRIORITY=optional
SLANG_DEPENDS=
SLANG_SUGGESTS=
SLANG_CONFLICTS=

#
# SLANG_IPK_VERSION should be incremented when the ipk changes.
#
SLANG_IPK_VERSION=1

#
# SLANG_CONFFILES should be a list of user-editable files
#SLANG_CONFFILES=/opt/etc/slang.conf /opt/etc/init.d/SXXslang

#
# SLANG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifeq (uclibc, $(LIBC_STYLE))
SLANG_PATCHES=$(SLANG_SOURCE_DIR)/uclibc.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SLANG_CPPFLAGS=
SLANG_LDFLAGS=

#
# SLANG_BUILD_DIR is the directory in which the build is done.
# SLANG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SLANG_IPK_DIR is the directory in which the ipk is built.
# SLANG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SLANG_BUILD_DIR=$(BUILD_DIR)/slang
SLANG_SOURCE_DIR=$(SOURCE_DIR)/slang
SLANG_IPK_DIR=$(BUILD_DIR)/slang-$(SLANG_VERSION)-ipk
SLANG_IPK=$(BUILD_DIR)/slang_$(SLANG_VERSION)-$(SLANG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: slang-source slang-unpack slang slang-stage slang-ipk slang-clean slang-dirclean slang-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SLANG_SOURCE):
	$(WGET) -P $(DL_DIR) $(SLANG_SITE)/$(SLANG_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SLANG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
slang-source: $(DL_DIR)/$(SLANG_SOURCE) $(SLANG_PATCHES)

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
$(SLANG_BUILD_DIR)/.configured: $(DL_DIR)/$(SLANG_SOURCE) $(SLANG_PATCHES) make/slang.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SLANG_DIR) $(SLANG_BUILD_DIR)
	$(SLANG_UNZIP) $(DL_DIR)/$(SLANG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SLANG_PATCHES)" ; \
		then cat $(SLANG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SLANG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SLANG_DIR)" != "$(SLANG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SLANG_DIR) $(SLANG_BUILD_DIR) ; \
	fi
	(cd $(SLANG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SLANG_CPPFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(SLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SLANG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	sed -i -e '/^LIBS =/s|$$| $$(LDFLAGS)|' $(SLANG_BUILD_DIR)/modules/Makefile
#	$(PATCH_LIBTOOL) $(SLANG_BUILD_DIR)/libtool
	touch $@

slang-unpack: $(SLANG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SLANG_BUILD_DIR)/.built: $(SLANG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SLANG_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
slang: $(SLANG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SLANG_BUILD_DIR)/.staged: $(SLANG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SLANG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install-elf
	rm -f $(STAGING_LIB_DIR)/libslang.a
	touch $@

slang-stage: $(SLANG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/slang
#
$(SLANG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: slang" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SLANG_PRIORITY)" >>$@
	@echo "Section: $(SLANG_SECTION)" >>$@
	@echo "Version: $(SLANG_VERSION)-$(SLANG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SLANG_MAINTAINER)" >>$@
	@echo "Source: $(SLANG_SITE)/$(SLANG_SOURCE)" >>$@
	@echo "Description: $(SLANG_DESCRIPTION)" >>$@
	@echo "Depends: $(SLANG_DEPENDS)" >>$@
	@echo "Suggests: $(SLANG_SUGGESTS)" >>$@
	@echo "Conflicts: $(SLANG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SLANG_IPK_DIR)/opt/sbin or $(SLANG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SLANG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SLANG_IPK_DIR)/opt/etc/slang/...
# Documentation files should be installed in $(SLANG_IPK_DIR)/opt/doc/slang/...
# Daemon startup scripts should be installed in $(SLANG_IPK_DIR)/opt/etc/init.d/S??slang
#
# You may need to patch your application to make it use these locations.
#
$(SLANG_IPK): $(SLANG_BUILD_DIR)/.built
	rm -rf $(SLANG_IPK_DIR) $(BUILD_DIR)/slang_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SLANG_BUILD_DIR) DESTDIR=$(SLANG_IPK_DIR) install-elf
	rm -f $(SLANG_IPK_DIR)/opt/lib/libslang.a
	$(STRIP_COMMAND) $(SLANG_IPK_DIR)/opt/bin/slsh \
		$(SLANG_IPK_DIR)/opt/lib/libslang.so.$(SLANG_VERSION) \
		$(SLANG_IPK_DIR)/opt/lib/slang/v2/modules/*.so
#	install -d $(SLANG_IPK_DIR)/opt/etc/
#	install -m 644 $(SLANG_SOURCE_DIR)/slang.conf $(SLANG_IPK_DIR)/opt/etc/slang.conf
#	install -d $(SLANG_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SLANG_SOURCE_DIR)/rc.slang $(SLANG_IPK_DIR)/opt/etc/init.d/SXXslang
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SLANG_IPK_DIR)/opt/etc/init.d/SXXslang
	$(MAKE) $(SLANG_IPK_DIR)/CONTROL/control
#	install -m 755 $(SLANG_SOURCE_DIR)/postinst $(SLANG_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SLANG_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SLANG_SOURCE_DIR)/prerm $(SLANG_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SLANG_IPK_DIR)/CONTROL/prerm
	echo $(SLANG_CONFFILES) | sed -e 's/ /\n/g' > $(SLANG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SLANG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
slang-ipk: $(SLANG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
slang-clean:
	rm -f $(SLANG_BUILD_DIR)/.built
	-$(MAKE) -C $(SLANG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
slang-dirclean:
	rm -rf $(BUILD_DIR)/$(SLANG_DIR) $(SLANG_BUILD_DIR) $(SLANG_IPK_DIR) $(SLANG_IPK)
#
#
# Some sanity check for the package.
#
slang-check: $(SLANG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SLANG_IPK)
