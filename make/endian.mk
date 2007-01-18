###########################################################
#
# endian
#
###########################################################
#
# ENDIAN_VERSION, ENDIAN_SITE and ENDIAN_SOURCE define
# the upstream location of the source code for the package.
# ENDIAN_DIR is the directory which is created when the source
# archive is unpacked.
# ENDIAN_UNZIP is the command used to unzip the source.
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
ENDIAN_SITE=http://bacon.is-a-geek.org/~bacon/Ports/distfiles
ENDIAN_VERSION=1.0
ENDIAN_SOURCE=endian-$(ENDIAN_VERSION).tar.gz
ENDIAN_DIR=endian-$(ENDIAN_VERSION)
ENDIAN_UNZIP=zcat
ENDIAN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ENDIAN_DESCRIPTION=Report endianness of a system to the standard output as "little", "big", or "mixed".
ENDIAN_SECTION=misc
ENDIAN_PRIORITY=optional
ENDIAN_DEPENDS=
ENDIAN_SUGGESTS=
ENDIAN_CONFLICTS=

#
# ENDIAN_IPK_VERSION should be incremented when the ipk changes.
#
ENDIAN_IPK_VERSION=1

#
# ENDIAN_CONFFILES should be a list of user-editable files
#ENDIAN_CONFFILES=/opt/etc/endian.conf /opt/etc/init.d/SXXendian

#
# ENDIAN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ENDIAN_PATCHES=$(ENDIAN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ENDIAN_CPPFLAGS=
ENDIAN_LDFLAGS=

#
# ENDIAN_BUILD_DIR is the directory in which the build is done.
# ENDIAN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ENDIAN_IPK_DIR is the directory in which the ipk is built.
# ENDIAN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ENDIAN_BUILD_DIR=$(BUILD_DIR)/endian
ENDIAN_SOURCE_DIR=$(SOURCE_DIR)/endian
ENDIAN_IPK_DIR=$(BUILD_DIR)/endian-$(ENDIAN_VERSION)-ipk
ENDIAN_IPK=$(BUILD_DIR)/endian_$(ENDIAN_VERSION)-$(ENDIAN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: endian-source endian-unpack endian endian-stage endian-ipk endian-clean endian-dirclean endian-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ENDIAN_SOURCE):
	$(WGET) -P $(DL_DIR) $(ENDIAN_SITE)/$(ENDIAN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
endian-source: $(DL_DIR)/$(ENDIAN_SOURCE) $(ENDIAN_PATCHES)

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
$(ENDIAN_BUILD_DIR)/.configured: $(DL_DIR)/$(ENDIAN_SOURCE) $(ENDIAN_PATCHES) make/endian.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ENDIAN_DIR) $(ENDIAN_BUILD_DIR)
	$(ENDIAN_UNZIP) $(DL_DIR)/$(ENDIAN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ENDIAN_PATCHES)" ; \
		then cat $(ENDIAN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ENDIAN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ENDIAN_DIR)" != "$(ENDIAN_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ENDIAN_DIR) $(ENDIAN_BUILD_DIR) ; \
	fi
#	(cd $(ENDIAN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ENDIAN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ENDIAN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(ENDIAN_BUILD_DIR)/libtool
	touch $@

endian-unpack: $(ENDIAN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ENDIAN_BUILD_DIR)/.built: $(ENDIAN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(ENDIAN_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ENDIAN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ENDIAN_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
endian: $(ENDIAN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ENDIAN_BUILD_DIR)/.staged: $(ENDIAN_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(ENDIAN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

endian-stage: $(ENDIAN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/endian
#
$(ENDIAN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: endian" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ENDIAN_PRIORITY)" >>$@
	@echo "Section: $(ENDIAN_SECTION)" >>$@
	@echo "Version: $(ENDIAN_VERSION)-$(ENDIAN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ENDIAN_MAINTAINER)" >>$@
	@echo "Source: $(ENDIAN_SITE)/$(ENDIAN_SOURCE)" >>$@
	@echo "Description: $(ENDIAN_DESCRIPTION)" >>$@
	@echo "Depends: $(ENDIAN_DEPENDS)" >>$@
	@echo "Suggests: $(ENDIAN_SUGGESTS)" >>$@
	@echo "Conflicts: $(ENDIAN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ENDIAN_IPK_DIR)/opt/sbin or $(ENDIAN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ENDIAN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ENDIAN_IPK_DIR)/opt/etc/endian/...
# Documentation files should be installed in $(ENDIAN_IPK_DIR)/opt/doc/endian/...
# Daemon startup scripts should be installed in $(ENDIAN_IPK_DIR)/opt/etc/init.d/S??endian
#
# You may need to patch your application to make it use these locations.
#
$(ENDIAN_IPK): $(ENDIAN_BUILD_DIR)/.built
	rm -rf $(ENDIAN_IPK_DIR) $(BUILD_DIR)/endian_*_$(TARGET_ARCH).ipk
	install -d $(ENDIAN_IPK_DIR)/opt/bin
	install -d $(ENDIAN_IPK_DIR)/opt/man/man1
	$(MAKE) -C $(ENDIAN_BUILD_DIR) install \
		DESTDIR=$(ENDIAN_IPK_DIR) PREFIX=$(ENDIAN_IPK_DIR)/opt
	$(STRIP_COMMAND) $(ENDIAN_IPK_DIR)/opt/bin/endian
	$(MAKE) $(ENDIAN_IPK_DIR)/CONTROL/control
#	echo $(ENDIAN_CONFFILES) | sed -e 's/ /\n/g' > $(ENDIAN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ENDIAN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
endian-ipk: $(ENDIAN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
endian-clean:
	rm -f $(ENDIAN_BUILD_DIR)/.built
	-$(MAKE) -C $(ENDIAN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
endian-dirclean:
	rm -rf $(BUILD_DIR)/$(ENDIAN_DIR) $(ENDIAN_BUILD_DIR) $(ENDIAN_IPK_DIR) $(ENDIAN_IPK)
#
#
# Some sanity check for the package.
#
endian-check: $(ENDIAN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ENDIAN_IPK)
