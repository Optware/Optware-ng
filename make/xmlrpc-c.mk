###########################################################
#
# xmlrpc-c
#
###########################################################
#
# XMLRPC-C_VERSION, XMLRPC-C_SITE and XMLRPC-C_SOURCE define
# the upstream location of the source code for the package.
# XMLRPC-C_DIR is the directory which is created when the source
# archive is unpacked.
# XMLRPC-C_UNZIP is the command used to unzip the source.
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
XMLRPC-C_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/xmlrpc-c
XMLRPC-C_VERSION=1.11.00
XMLRPC-C_SOURCE=xmlrpc-c-$(XMLRPC-C_VERSION).tgz
XMLRPC-C_DIR=xmlrpc-c-$(XMLRPC-C_VERSION)
XMLRPC-C_UNZIP=zcat
XMLRPC-C_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XMLRPC-C_DESCRIPTION=A library providing modular implementation of XML-RPC for C and C++.
XMLRPC-C_SECTION=lib
XMLRPC-C_PRIORITY=optional
XMLRPC-C_DEPENDS=libcurl, libxml2, openssl, zlib
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
XMLRPC-C_DEPENDS+=, libiconv
endif
XMLRPC-C_SUGGESTS=
XMLRPC-C_CONFLICTS=

#
# XMLRPC-C_IPK_VERSION should be incremented when the ipk changes.
#
XMLRPC-C_IPK_VERSION=2

#
# XMLRPC-C_CONFFILES should be a list of user-editable files
#XMLRPC-C_CONFFILES=/opt/etc/xmlrpc-c.conf /opt/etc/init.d/SXXxmlrpc-c

#
# XMLRPC-C_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XMLRPC-C_PATCHES=$(XMLRPC-C_SOURCE_DIR)/ltconfig.patch $(XMLRPC-C_SOURCE_DIR)/Makefile.config.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XMLRPC-C_CPPFLAGS=
XMLRPC-C_LDFLAGS=

#
# XMLRPC-C_BUILD_DIR is the directory in which the build is done.
# XMLRPC-C_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XMLRPC-C_IPK_DIR is the directory in which the ipk is built.
# XMLRPC-C_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XMLRPC-C_BUILD_DIR=$(BUILD_DIR)/xmlrpc-c
XMLRPC-C_SOURCE_DIR=$(SOURCE_DIR)/xmlrpc-c
XMLRPC-C_IPK_DIR=$(BUILD_DIR)/xmlrpc-c-$(XMLRPC-C_VERSION)-ipk
XMLRPC-C_IPK=$(BUILD_DIR)/xmlrpc-c_$(XMLRPC-C_VERSION)-$(XMLRPC-C_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: xmlrpc-c-source xmlrpc-c-unpack xmlrpc-c xmlrpc-c-stage xmlrpc-c-ipk xmlrpc-c-clean xmlrpc-c-dirclean xmlrpc-c-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XMLRPC-C_SOURCE):
	$(WGET) -P $(DL_DIR) $(XMLRPC-C_SITE)/$(XMLRPC-C_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(XMLRPC-C_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xmlrpc-c-source: $(DL_DIR)/$(XMLRPC-C_SOURCE) $(XMLRPC-C_PATCHES)

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
$(XMLRPC-C_BUILD_DIR)/.configured: $(DL_DIR)/$(XMLRPC-C_SOURCE) $(XMLRPC-C_PATCHES) make/xmlrpc-c.mk
	$(MAKE) libcurl-stage libxml2-stage openssl-stage zlib-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(XMLRPC-C_DIR) $(XMLRPC-C_BUILD_DIR)
	$(XMLRPC-C_UNZIP) $(DL_DIR)/$(XMLRPC-C_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(XMLRPC-C_PATCHES)" ; \
		then cat $(XMLRPC-C_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(XMLRPC-C_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(XMLRPC-C_DIR)" != "$(XMLRPC-C_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(XMLRPC-C_DIR) $(XMLRPC-C_BUILD_DIR) ; \
	fi
#	sed -i -e '/ifeq.*linux-gnu/s/.*/ifeq (1,1)/' $(@D)/Makefile.config.in
	sed -i '/FLAGS_COMMON *=/s|$$| $$(CPPFLAGS)|' $(@D)/Makefile.common
	(cd $(XMLRPC-C_BUILD_DIR); \
		PATH=$(STAGING_PREFIX)/bin:$$PATH \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XMLRPC-C_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XMLRPC-C_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-libxml2-backend \
		--disable-cplusplus \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) \
	-e 's|CC -shared|& $(STAGING_LDFLAGS) $(XMLRPC-C_LDFLAGS)|' \
	$(XMLRPC-C_BUILD_DIR)/libtool
	touch $@

xmlrpc-c-unpack: $(XMLRPC-C_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XMLRPC-C_BUILD_DIR)/.built: $(XMLRPC-C_BUILD_DIR)/.configured
	rm -f $@
	PATH=$(STAGING_PREFIX)/bin:$$PATH \
	$(MAKE) -C $(XMLRPC-C_BUILD_DIR) \
		HOST_OS=linux-gnu \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XMLRPC-C_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XMLRPC-C_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
xmlrpc-c: $(XMLRPC-C_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XMLRPC-C_BUILD_DIR)/.staged: $(XMLRPC-C_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(XMLRPC-C_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libxmlrpc*.la
	sed -i -e '/cflags/s|-I$$HEADERINST_DIR|-I$(STAGING_INCLUDE_DIR)|' \
		$(STAGING_PREFIX)/bin/xmlrpc-c-config
	touch $@

xmlrpc-c-stage: $(XMLRPC-C_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/xmlrpc-c
#
$(XMLRPC-C_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: xmlrpc-c" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XMLRPC-C_PRIORITY)" >>$@
	@echo "Section: $(XMLRPC-C_SECTION)" >>$@
	@echo "Version: $(XMLRPC-C_VERSION)-$(XMLRPC-C_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XMLRPC-C_MAINTAINER)" >>$@
	@echo "Source: $(XMLRPC-C_SITE)/$(XMLRPC-C_SOURCE)" >>$@
	@echo "Description: $(XMLRPC-C_DESCRIPTION)" >>$@
	@echo "Depends: $(XMLRPC-C_DEPENDS)" >>$@
	@echo "Suggests: $(XMLRPC-C_SUGGESTS)" >>$@
	@echo "Conflicts: $(XMLRPC-C_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(XMLRPC-C_IPK_DIR)/opt/sbin or $(XMLRPC-C_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XMLRPC-C_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XMLRPC-C_IPK_DIR)/opt/etc/xmlrpc-c/...
# Documentation files should be installed in $(XMLRPC-C_IPK_DIR)/opt/doc/xmlrpc-c/...
# Daemon startup scripts should be installed in $(XMLRPC-C_IPK_DIR)/opt/etc/init.d/S??xmlrpc-c
#
# You may need to patch your application to make it use these locations.
#
$(XMLRPC-C_IPK): $(XMLRPC-C_BUILD_DIR)/.built
	rm -rf $(XMLRPC-C_IPK_DIR) $(BUILD_DIR)/xmlrpc-c_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XMLRPC-C_BUILD_DIR) DESTDIR=$(XMLRPC-C_IPK_DIR) install
	rm -f $(XMLRPC-C_IPK_DIR)/opt/lib/*.a $(XMLRPC-C_IPK_DIR)/opt/lib/*.la
	$(STRIP_COMMAND) $(XMLRPC-C_IPK_DIR)/opt/lib/libxmlrpc*.so.[0-9]*.*
	$(MAKE) $(XMLRPC-C_IPK_DIR)/CONTROL/control
	echo $(XMLRPC-C_CONFFILES) | sed -e 's/ /\n/g' > $(XMLRPC-C_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XMLRPC-C_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xmlrpc-c-ipk: $(XMLRPC-C_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xmlrpc-c-clean:
	rm -f $(XMLRPC-C_BUILD_DIR)/.built
	-$(MAKE) -C $(XMLRPC-C_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xmlrpc-c-dirclean:
	rm -rf $(BUILD_DIR)/$(XMLRPC-C_DIR) $(XMLRPC-C_BUILD_DIR) $(XMLRPC-C_IPK_DIR) $(XMLRPC-C_IPK)
#
#
# Some sanity check for the package.
#
xmlrpc-c-check: $(XMLRPC-C_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(XMLRPC-C_IPK)
