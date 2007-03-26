###########################################################
#
# libtasn1
#
###########################################################

# You must replace "libtasn1" and "LIBTASN1" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBTASN1_VERSION, LIBTASN1_SITE and LIBTASN1_SOURCE define
# the upstream location of the source code for the package.
# LIBTASN1_DIR is the directory which is created when the source
# archive is unpacked.
# LIBTASN1_UNZIP is the command used to unzip the source.
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
LIBTASN1_SITE=http://josefsson.org/gnutls/releases/libtasn1
LIBTASN1_VERSION=0.3.9
LIBTASN1_SOURCE=libtasn1-$(LIBTASN1_VERSION).tar.gz
LIBTASN1_DIR=libtasn1-$(LIBTASN1_VERSION)
LIBTASN1_UNZIP=zcat
LIBTASN1_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBTASN1_DESCRIPTION=ASN.1 structure parser library.
LIBTASN1_SECTION=libs
LIBTASN1_PRIORITY=optional
LIBTASN1_DEPENDS=
LIBTASN1_SUGGESTS=
LIBTASN1_CONFLICTS=

#
# LIBTASN1_IPK_VERSION should be incremented when the ipk changes.
#
LIBTASN1_IPK_VERSION=1

#
# LIBTASN1_CONFFILES should be a list of user-editable files
LIBTASN1_CONFFILES=#/opt/etc/libtasn1.conf /opt/etc/init.d/SXXlibtasn1

#
# LIBTASN1_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBTASN1_PATCHES=#$(LIBTASN1_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBTASN1_CPPFLAGS=
LIBTASN1_LDFLAGS=

#
# LIBTASN1_BUILD_DIR is the directory in which the build is done.
# LIBTASN1_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBTASN1_IPK_DIR is the directory in which the ipk is built.
# LIBTASN1_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBTASN1_BUILD_DIR=$(BUILD_DIR)/libtasn1
LIBTASN1_SOURCE_DIR=$(SOURCE_DIR)/libtasn1
LIBTASN1_IPK_DIR=$(BUILD_DIR)/libtasn1-$(LIBTASN1_VERSION)-ipk
LIBTASN1_IPK=$(BUILD_DIR)/libtasn1_$(LIBTASN1_VERSION)-$(LIBTASN1_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libtasn1-source libtasn1-unpack libtasn1 libtasn1-stage libtasn1-ipk libtasn1-clean libtasn1-dirclean libtasn1-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBTASN1_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBTASN1_SITE)/$(LIBTASN1_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libtasn1-source: $(DL_DIR)/$(LIBTASN1_SOURCE) $(LIBTASN1_PATCHES)

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
$(LIBTASN1_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBTASN1_SOURCE) $(LIBTASN1_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBTASN1_DIR) $(LIBTASN1_BUILD_DIR)
	$(LIBTASN1_UNZIP) $(DL_DIR)/$(LIBTASN1_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(LIBTASN1_PATCHES) | patch -d $(BUILD_DIR)/$(LIBTASN1_DIR) -p1
	mv $(BUILD_DIR)/$(LIBTASN1_DIR) $(LIBTASN1_BUILD_DIR)
	(cd $(LIBTASN1_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBTASN1_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBTASN1_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBTASN1_BUILD_DIR)/libtool
	touch $@

libtasn1-unpack: $(LIBTASN1_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBTASN1_BUILD_DIR)/.built: $(LIBTASN1_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBTASN1_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libtasn1: $(LIBTASN1_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBTASN1_BUILD_DIR)/.staged: $(LIBTASN1_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBTASN1_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|echo $$includes $$tasn1_cflags|echo "-I$(STAGING_INCLUDE_DIR)"|' $(STAGING_PREFIX)/bin/libtasn1-config
	rm -f $(STAGING_DIR)/opt/lib/libtasn1.la
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libtasn1.pc
	touch $@

libtasn1-stage: $(LIBTASN1_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libtasn1
#
$(LIBTASN1_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libtasn1" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBTASN1_PRIORITY)" >>$@
	@echo "Section: $(LIBTASN1_SECTION)" >>$@
	@echo "Version: $(LIBTASN1_VERSION)-$(LIBTASN1_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBTASN1_MAINTAINER)" >>$@
	@echo "Source: $(LIBTASN1_SITE)/$(LIBTASN1_SOURCE)" >>$@
	@echo "Description: $(LIBTASN1_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBTASN1_DEPENDS)" >>$@
	@echo "Suggests: $(LIBTASN1_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBTASN1_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBTASN1_IPK_DIR)/opt/sbin or $(LIBTASN1_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBTASN1_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBTASN1_IPK_DIR)/opt/etc/libtasn1/...
# Documentation files should be installed in $(LIBTASN1_IPK_DIR)/opt/doc/libtasn1/...
# Daemon startup scripts should be installed in $(LIBTASN1_IPK_DIR)/opt/etc/init.d/S??libtasn1
#
# You may need to patch your application to make it use these locations.
#
$(LIBTASN1_IPK): $(LIBTASN1_BUILD_DIR)/.built
	rm -rf $(LIBTASN1_IPK_DIR) $(BUILD_DIR)/libtasn1_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBTASN1_BUILD_DIR) DESTDIR=$(LIBTASN1_IPK_DIR) install-strip
#	rm -r $(LIBTASN1_IPK_DIR)/opt/info
	#install -d $(LIBTASN1_IPK_DIR)/opt/etc/
	#install -m 644 $(LIBTASN1_SOURCE_DIR)/libtasn1.conf $(LIBTASN1_IPK_DIR)/opt/etc/libtasn1.conf
	#install -d $(LIBTASN1_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(LIBTASN1_SOURCE_DIR)/rc.libtasn1 $(LIBTASN1_IPK_DIR)/opt/etc/init.d/SXXlibtasn1
	$(MAKE) $(LIBTASN1_IPK_DIR)/CONTROL/control
	#install -m 755 $(LIBTASN1_SOURCE_DIR)/postinst $(LIBTASN1_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(LIBTASN1_SOURCE_DIR)/prerm $(LIBTASN1_IPK_DIR)/CONTROL/prerm
	echo $(LIBTASN1_CONFFILES) | sed -e 's/ /\n/g' > $(LIBTASN1_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBTASN1_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libtasn1-ipk: $(LIBTASN1_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libtasn1-clean:
	-$(MAKE) -C $(LIBTASN1_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libtasn1-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBTASN1_DIR) $(LIBTASN1_BUILD_DIR) $(LIBTASN1_IPK_DIR) $(LIBTASN1_IPK)

#
# Some sanity check for the package.
#
libtasn1-check: $(LIBTASN1_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBTASN1_IPK)
