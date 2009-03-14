###########################################################
#
# libidn
#
###########################################################

# You must replace "libidn" and "LIBIDN" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBIDN_VERSION, LIBIDN_SITE and LIBIDN_SOURCE define
# the upstream location of the source code for the package.
# LIBIDN_DIR is the directory which is created when the source
# archive is unpacked.
# LIBIDN_UNZIP is the command used to unzip the source.
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
LIBIDN_SITE=http://ftp.gnu.org/gnu/libidn
LIBIDN_VERSION=1.13
LIBIDN_SOURCE=libidn-$(LIBIDN_VERSION).tar.gz
LIBIDN_DIR=libidn-$(LIBIDN_VERSION)
LIBIDN_UNZIP=zcat
LIBIDN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBIDN_DESCRIPTION=GNU Libidn is an implementation of the Stringprep, Punycode and IDNA specifications defined by the IETF Internationalized Domain Names (IDN) working group, used for internationalized domain names.
LIBIDN_SECTION=lib
LIBIDN_PRIORITY=optional
LIBIDN_DEPENDS=
LIBIDN_SUGGESTS=
LIBIDN_CONFLICTS=

#
# LIBIDN_IPK_VERSION should be incremented when the ipk changes.
#
LIBIDN_IPK_VERSION=1

#
# LIBIDN_CONFFILES should be a list of user-editable files
#LIBIDN_CONFFILES=/opt/etc/libidn.conf /opt/etc/init.d/SXXlibidn

#
# LIBIDN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBIDN_PATCHES=$(LIBIDN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBIDN_CPPFLAGS=
LIBIDN_LDFLAGS=

#
# LIBIDN_BUILD_DIR is the directory in which the build is done.
# LIBIDN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBIDN_IPK_DIR is the directory in which the ipk is built.
# LIBIDN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBIDN_BUILD_DIR=$(BUILD_DIR)/libidn
LIBIDN_SOURCE_DIR=$(SOURCE_DIR)/libidn
LIBIDN_IPK_DIR=$(BUILD_DIR)/libidn-$(LIBIDN_VERSION)-ipk
LIBIDN_IPK=$(BUILD_DIR)/libidn_$(LIBIDN_VERSION)-$(LIBIDN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libidn-source libidn-unpack libidn libidn-stage libidn-ipk libidn-clean libidn-dirclean libidn-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBIDN_SOURCE):
	$(WGET) -P $(@D) $(LIBIDN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libidn-source: $(DL_DIR)/$(LIBIDN_SOURCE) $(LIBIDN_PATCHES)

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
$(LIBIDN_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBIDN_SOURCE) $(LIBIDN_PATCHES) make/libidn.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBIDN_DIR) $(@D)
	$(LIBIDN_UNZIP) $(DL_DIR)/$(LIBIDN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBIDN_PATCHES) | patch -d $(BUILD_DIR)/$(LIBIDN_DIR) -p1
	mv $(BUILD_DIR)/$(LIBIDN_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBIDN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBIDN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-csharp \
		--disable-java \
		--prefix=/opt \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libidn-unpack: $(LIBIDN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBIDN_BUILD_DIR)/.built: $(LIBIDN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libidn: $(LIBIDN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBIDN_BUILD_DIR)/.staged: $(LIBIDN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install-strip
	rm -f $(STAGING_LIB_DIR)/libidn.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libidn.pc
	touch $@

libidn-stage: $(LIBIDN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libidn
#
$(LIBIDN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libidn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBIDN_PRIORITY)" >>$@
	@echo "Section: $(LIBIDN_SECTION)" >>$@
	@echo "Version: $(LIBIDN_VERSION)-$(LIBIDN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBIDN_MAINTAINER)" >>$@
	@echo "Source: $(LIBIDN_SITE)/$(LIBIDN_SOURCE)" >>$@
	@echo "Description: $(LIBIDN_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBIDN_DEPENDS)" >>$@
	@echo "Suggests: $(LIBIDN_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBIDN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBIDN_IPK_DIR)/opt/sbin or $(LIBIDN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBIDN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBIDN_IPK_DIR)/opt/etc/libidn/...
# Documentation files should be installed in $(LIBIDN_IPK_DIR)/opt/doc/libidn/...
# Daemon startup scripts should be installed in $(LIBIDN_IPK_DIR)/opt/etc/init.d/S??libidn
#
# You may need to patch your application to make it use these locations.
#
$(LIBIDN_IPK): $(LIBIDN_BUILD_DIR)/.built
	rm -rf $(LIBIDN_IPK_DIR) $(BUILD_DIR)/libidn_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBIDN_BUILD_DIR) DESTDIR=$(LIBIDN_IPK_DIR) install-strip
	rm -f $(LIBIDN_IPK_DIR)/opt/lib/libidn.a
	$(MAKE) $(LIBIDN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBIDN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libidn-ipk: $(LIBIDN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libidn-clean:
	-$(MAKE) -C $(LIBIDN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libidn-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBIDN_DIR) $(LIBIDN_BUILD_DIR) $(LIBIDN_IPK_DIR) $(LIBIDN_IPK)

libidn-check: $(LIBIDN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
