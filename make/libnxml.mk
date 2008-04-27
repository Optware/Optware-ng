###########################################################
#
# libnxml
#
###########################################################
#
# LIBNXML_VERSION, LIBNXML_SITE and LIBNXML_SOURCE define
# the upstream location of the source code for the package.
# LIBNXML_DIR is the directory which is created when the source
# archive is unpacked.
# LIBNXML_UNZIP is the command used to unzip the source.
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
LIBNXML_SITE=http://www2.autistici.org/bakunin/libnxml
LIBNXML_VERSION=0.18.2
LIBNXML_SOURCE=libnxml-$(LIBNXML_VERSION).tar.gz
LIBNXML_DIR=libnxml-$(LIBNXML_VERSION)
LIBNXML_UNZIP=zcat
LIBNXML_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBNXML_DESCRIPTION=nXML is a C library for parsing, writing and creating XML 1.0 and 1.1 files or streams. It supports utf-8, utf-16be and utf-16le, ucs-4 (1234, 4321, 2143, 2312).
LIBNXML_SECTION=lib
LIBNXML_PRIORITY=optional
LIBNXML_DEPENDS=libcurl
LIBNXML_SUGGESTS=
LIBNXML_CONFLICTS=

#
# LIBNXML_IPK_VERSION should be incremented when the ipk changes.
#
LIBNXML_IPK_VERSION=1

#
# LIBNXML_CONFFILES should be a list of user-editable files
#LIBNXML_CONFFILES=/opt/etc/libnxml.conf /opt/etc/init.d/SXXlibnxml

#
# LIBNXML_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBNXML_PATCHES=$(LIBNXML_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBNXML_CPPFLAGS=
LIBNXML_LDFLAGS=

#
# LIBNXML_BUILD_DIR is the directory in which the build is done.
# LIBNXML_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBNXML_IPK_DIR is the directory in which the ipk is built.
# LIBNXML_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBNXML_BUILD_DIR=$(BUILD_DIR)/libnxml
LIBNXML_SOURCE_DIR=$(SOURCE_DIR)/libnxml
LIBNXML_IPK_DIR=$(BUILD_DIR)/libnxml-$(LIBNXML_VERSION)-ipk
LIBNXML_IPK=$(BUILD_DIR)/libnxml_$(LIBNXML_VERSION)-$(LIBNXML_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libnxml-source libnxml-unpack libnxml libnxml-stage libnxml-ipk libnxml-clean libnxml-dirclean libnxml-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBNXML_SOURCE):
	$(WGET) -P $(@D) $(LIBNXML_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libnxml-source: $(DL_DIR)/$(LIBNXML_SOURCE) $(LIBNXML_PATCHES)

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
$(LIBNXML_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBNXML_SOURCE) $(LIBNXML_PATCHES) make/libnxml.mk
	$(MAKE) libcurl-stage
	rm -rf $(BUILD_DIR)/$(LIBNXML_DIR) $(LIBNXML_BUILD_DIR)
	$(LIBNXML_UNZIP) $(DL_DIR)/$(LIBNXML_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBNXML_PATCHES)" ; \
		then cat $(LIBNXML_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBNXML_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBNXML_DIR)" != "$(LIBNXML_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBNXML_DIR) $(LIBNXML_BUILD_DIR) ; \
	fi
	(cd $(LIBNXML_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBNXML_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBNXML_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBNXML_BUILD_DIR)/libtool
	touch $@

libnxml-unpack: $(LIBNXML_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBNXML_BUILD_DIR)/.built: $(LIBNXML_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBNXML_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libnxml: $(LIBNXML_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBNXML_BUILD_DIR)/.staged: $(LIBNXML_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBNXML_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/nxml.pc
	rm -f $(STAGING_LIB_DIR)/libnxml.la
	touch $@

libnxml-stage: $(LIBNXML_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libnxml
#
$(LIBNXML_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libnxml" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBNXML_PRIORITY)" >>$@
	@echo "Section: $(LIBNXML_SECTION)" >>$@
	@echo "Version: $(LIBNXML_VERSION)-$(LIBNXML_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBNXML_MAINTAINER)" >>$@
	@echo "Source: $(LIBNXML_SITE)/$(LIBNXML_SOURCE)" >>$@
	@echo "Description: $(LIBNXML_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNXML_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNXML_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNXML_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBNXML_IPK_DIR)/opt/sbin or $(LIBNXML_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBNXML_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBNXML_IPK_DIR)/opt/etc/libnxml/...
# Documentation files should be installed in $(LIBNXML_IPK_DIR)/opt/doc/libnxml/...
# Daemon startup scripts should be installed in $(LIBNXML_IPK_DIR)/opt/etc/init.d/S??libnxml
#
# You may need to patch your application to make it use these locations.
#
$(LIBNXML_IPK): $(LIBNXML_BUILD_DIR)/.built
	rm -rf $(LIBNXML_IPK_DIR) $(BUILD_DIR)/libnxml_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBNXML_BUILD_DIR) DESTDIR=$(LIBNXML_IPK_DIR) install-strip
	$(MAKE) $(LIBNXML_IPK_DIR)/CONTROL/control
#	echo $(LIBNXML_CONFFILES) | sed -e 's/ /\n/g' > $(LIBNXML_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNXML_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libnxml-ipk: $(LIBNXML_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libnxml-clean:
	rm -f $(LIBNXML_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBNXML_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libnxml-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBNXML_DIR) $(LIBNXML_BUILD_DIR) $(LIBNXML_IPK_DIR) $(LIBNXML_IPK)
#
#
# Some sanity check for the package.
#
libnxml-check: $(LIBNXML_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBNXML_IPK)
