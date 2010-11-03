###########################################################
#
# libogg
#
###########################################################

# You must replace "libogg" and "LIBOGG" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBOGG_VERSION, LIBOGG_SITE and LIBOGG_SOURCE define
# the upstream location of the source code for the package.
# LIBOGG_DIR is the directory which is created when the source
# archive is unpacked.
# LIBOGG_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBOGG_SITE=http://downloads.xiph.org/releases/ogg
LIBOGG_VERSION=1.2.1
LIBOGG_SOURCE=libogg-$(LIBOGG_VERSION).tar.gz
LIBOGG_DIR=libogg-$(LIBOGG_VERSION)
LIBOGG_UNZIP=zcat
LIBOGG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBOGG_DESCRIPTION=Ogg is a multimedia container format.
LIBOGG_SECTION=lib
LIBOGG_PRIORITY=optional
LIBOGG_DEPENDS=
LIBOGG_SUGGESTS=
LIBOGG_CONFLICTS=

#
# LIBOGG_IPK_VERSION should be incremented when the ipk changes.
#
LIBOGG_IPK_VERSION=1

#
# LIBOGG_CONFFILES should be a list of user-editable files
#LIBOGG_CONFFILES=/opt/etc/libogg.conf /opt/etc/init.d/SXXlibogg

#
# LIBOGG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBOGG_PATCHES=$(LIBOGG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBOGG_CPPFLAGS=
LIBOGG_LDFLAGS=

#
# LIBOGG_BUILD_DIR is the directory in which the build is done.
# LIBOGG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBOGG_IPK_DIR is the directory in which the ipk is built.
# LIBOGG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBOGG_BUILD_DIR=$(BUILD_DIR)/libogg
LIBOGG_SOURCE_DIR=$(SOURCE_DIR)/libogg
LIBOGG_IPK_DIR=$(BUILD_DIR)/libogg-$(LIBOGG_VERSION)-ipk
LIBOGG_IPK=$(BUILD_DIR)/libogg_$(LIBOGG_VERSION)-$(LIBOGG_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBOGG_SOURCE):
	$(WGET) -P $(@D) $(LIBOGG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libogg-source: $(DL_DIR)/$(LIBOGG_SOURCE) $(LIBOGG_PATCHES)

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
$(LIBOGG_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBOGG_SOURCE) $(LIBOGG_PATCHES) make/libogg.mk
	rm -rf $(BUILD_DIR)/$(LIBOGG_DIR) $(@D)
	$(LIBOGG_UNZIP) $(DL_DIR)/$(LIBOGG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBOGG_PATCHES) | patch -d $(BUILD_DIR)/$(LIBOGG_DIR) -p1
	mv $(BUILD_DIR)/$(LIBOGG_DIR) $(@D)
	rm -f $(@D)/config.cache; autoreconf -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBOGG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBOGG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

libogg-unpack: $(LIBOGG_BUILD_DIR)/.configured


#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBOGG_BUILD_DIR)/.built: $(LIBOGG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libogg: $(LIBOGG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBOGG_BUILD_DIR)/.staged: $(LIBOGG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|prefix=/opt|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/ogg.pc
	rm -f $(STAGING_LIB_DIR)/libogg.la $(STAGING_LIB_DIR)/libogg.a
	touch $@

libogg-stage: $(LIBOGG_BUILD_DIR)/.staged


$(LIBOGG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libogg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBOGG_PRIORITY)" >>$@
	@echo "Section: $(LIBOGG_SECTION)" >>$@
	@echo "Version: $(LIBOGG_VERSION)-$(LIBOGG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBOGG_MAINTAINER)" >>$@
	@echo "Source: $(LIBOGG_SITE)/$(LIBOGG_SOURCE)" >>$@
	@echo "Description: $(LIBOGG_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBOGG_DEPENDS)" >>$@
	@echo "Suggests: $(LIBOGG_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBOGG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBOGG_IPK_DIR)/opt/sbin or $(LIBOGG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBOGG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBOGG_IPK_DIR)/opt/etc/libogg/...
# Documentation files should be installed in $(LIBOGG_IPK_DIR)/opt/doc/libogg/...
# Daemon startup scripts should be installed in $(LIBOGG_IPK_DIR)/opt/etc/init.d/S??libogg
#
# You may need to patch your application to make it use these locations.
#
$(LIBOGG_IPK): $(LIBOGG_BUILD_DIR)/.built
	rm -rf $(LIBOGG_IPK_DIR) $(BUILD_DIR)/libogg_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBOGG_BUILD_DIR) DESTDIR=$(LIBOGG_IPK_DIR) install-strip
	rm -f $(LIBOGG_IPK_DIR)/opt/lib/libogg.a
	$(MAKE) $(LIBOGG_IPK_DIR)/CONTROL/control
	echo $(LIBOGG_CONFFILES) | sed -e 's/ /\n/g' > $(LIBOGG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBOGG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libogg-ipk: $(LIBOGG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libogg-clean:
	-$(MAKE) -C $(LIBOGG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libogg-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBOGG_DIR) $(LIBOGG_BUILD_DIR) $(LIBOGG_IPK_DIR) $(LIBOGG_IPK)

#
# Some sanity check for the package.
#
libogg-check: $(LIBOGG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
