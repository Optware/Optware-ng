###########################################################
#
# mxml
#
###########################################################
#
# MXML_VERSION, MXML_SITE and MXML_SOURCE define
# the upstream location of the source code for the package.
# MXML_DIR is the directory which is created when the source
# archive is unpacked.
# MXML_UNZIP is the command used to unzip the source.
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
MXML_VERSION=2.5
MXML_SITE=ftp://ftp.easysw.com/pub/mxml/$(MXML_VERSION)
MXML_SOURCE=mxml-$(MXML_VERSION).tar.gz
MXML_DIR=mxml-$(MXML_VERSION)
MXML_UNZIP=zcat
MXML_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MXML_DESCRIPTION=Mini-XML is a small XML parsing library that \
you can use to read XML and XML-like data files in your application \
without requiring large non-standard libraries.
MXML_SECTION=libs
MXML_PRIORITY=optional
MXML_DEPENDS=
MXML_SUGGESTS=
MXML_CONFLICTS=

#
# MXML_IPK_VERSION should be incremented when the ipk changes.
#
MXML_IPK_VERSION=1

#
# MXML_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MXML_PATCHES=$(MXML_SOURCE_DIR)/mxml.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MXML_CPPFLAGS=
MXML_LDFLAGS=

#
# MXML_BUILD_DIR is the directory in which the build is done.
# MXML_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MXML_IPK_DIR is the directory in which the ipk is built.
# MXML_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MXML_SOURCE_DIR=$(SOURCE_DIR)/mxml
MXML_BUILD_DIR=$(BUILD_DIR)/mxml
MXML_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/mxml
MXML_IPK_DIR=$(BUILD_DIR)/mxml-$(MXML_VERSION)-ipk
MXML_IPK=$(BUILD_DIR)/mxml_$(MXML_VERSION)-$(MXML_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mxml-source mxml-unpack mxml mxml-stage mxml-ipk mxml-clean mxml-dirclean mxml-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MXML_SOURCE):
	$(WGET) -P $(@D) $(MXML_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mxml-source: $(DL_DIR)/$(MXML_SOURCE) $(MXML_PATCHES)

$(MXML_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(MXML_SOURCE) make/mxml.mk
	rm -rf $(HOST_BUILD_DIR)/$(MXML_DIR) $(@D)
	$(MXML_UNZIP) $(DL_DIR)/$(MXML_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(MXML_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(MXML_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		./configure \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(MAKE) -C $(@D) mxmldoc-static
	touch $@

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
ifeq ($(HOST_CC), $(TARGET_CC))
$(MXML_BUILD_DIR)/.configured: $(DL_DIR)/$(MXML_SOURCE) $(MXML_PATCHES) make/mxml.mk
else
$(MXML_BUILD_DIR)/.configured: $(MXML_HOST_BUILD_DIR)/.built $(MXML_PATCHES)
endif
	rm -rf $(BUILD_DIR)/$(MXML_DIR) $(@D)
	$(MXML_UNZIP) $(DL_DIR)/$(MXML_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MXML_PATCHES)" ; \
		then cat $(MXML_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(MXML_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MXML_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MXML_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MXML_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MXML_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--enable-shared \
		--disable-static \
	)
	touch $@

mxml-unpack: $(MXML_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MXML_BUILD_DIR)/.built: $(MXML_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) $(if $(filter $(HOST_CC), $(TARGET_CC)),,MXMLDOC_DIR=$(MXML_HOST_BUILD_DIR))
	touch $@

#
# This is the build convenience target.
#
mxml: $(MXML_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MXML_BUILD_DIR)/.staged: $(MXML_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) DSTROOT=$(STAGING_DIR) install
	sed -i -e 's|prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/mxml.pc
	touch $@

mxml-stage: $(MXML_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mxml
#
$(MXML_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mxml" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MXML_PRIORITY)" >>$@
	@echo "Section: $(MXML_SECTION)" >>$@
	@echo "Version: $(MXML_VERSION)-$(MXML_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MXML_MAINTAINER)" >>$@
	@echo "Source: $(MXML_SITE)/$(MXML_SOURCE)" >>$@
	@echo "Description: $(MXML_DESCRIPTION)" >>$@
	@echo "Depends: $(MXML_DEPENDS)" >>$@
	@echo "Suggests: $(MXML_SUGGESTS)" >>$@
	@echo "Conflicts: $(MXML_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MXML_IPK_DIR)/opt/sbin or $(MXML_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MXML_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MXML_IPK_DIR)/opt/etc/mxml/...
# Documentation files should be installed in $(MXML_IPK_DIR)/opt/doc/mxml/...
# Daemon startup scripts should be installed in $(MXML_IPK_DIR)/opt/etc/init.d/S??mxml
#
# You may need to patch your application to make it use these locations.
#
$(MXML_IPK): $(MXML_BUILD_DIR)/.built
	rm -rf $(MXML_IPK_DIR) $(BUILD_DIR)/mxml_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MXML_BUILD_DIR) DESTDIR=$(MXML_IPK_DIR) DSTROOT=$(MXML_IPK_DIR) install
	rm -f $(MXML_IPK_DIR)/opt/lib/libmxml.a
	$(STRIP_COMMAND) $(MXML_IPK_DIR)/opt/bin/mxmldoc
	$(STRIP_COMMAND) $(MXML_IPK_DIR)/opt/lib/libmxml.so*
	$(MAKE) $(MXML_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MXML_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mxml-ipk: $(MXML_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mxml-clean:
	rm -f $(MXML_BUILD_DIR)/.built
	-$(MAKE) -C $(MXML_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mxml-dirclean:
	rm -rf $(BUILD_DIR)/$(MXML_DIR) $(MXML_BUILD_DIR) $(MXML_IPK_DIR) $(MXML_IPK)
#
#
# Some sanity check for the package.
#
mxml-check: $(MXML_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MXML_IPK)
