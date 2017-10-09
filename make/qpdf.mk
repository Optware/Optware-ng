###########################################################
#
# qpdf
#
###########################################################
#
# QPDF_VERSION, QPDF_SITE and QPDF_SOURCE define
# the upstream location of the source code for the package.
# QPDF_DIR is the directory which is created when the source
# archive is unpacked.
# QPDF_UNZIP is the command used to unzip the source.
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
QPDF_URL=http://$(SOURCEFORGE_MIRROR)/sourceforge/qpdf/qpdf-$(QPDF_VERSION).tar.gz
QPDF_VERSION=6.0.0
QPDF_SOURCE=qpdf-$(QPDF_VERSION).tar.gz
QPDF_DIR=qpdf-$(QPDF_VERSION)
QPDF_UNZIP=zcat
QPDF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
QPDF_DESCRIPTION=Tools for transforming and inspecting PDF files
LIBQPDF_DESCRIPTION=Runtime library for PDF transformation/inspection software
LIBQPDF_DEV_DESCRIPTION=libqpdf development files
QPDF_DOC_DESCRIPTION=qpdf docs
QPDF_SECTION=misc
LIBQPDF_SECTION=libs
LIBQPDF_DEV_SECTION=dev
QPDF_DOC_SECTION=doc
QPDF_PRIORITY=optional
LIBQPDF_PRIORITY=optional
LIBQPDF_DEV_PRIORITY=optional
QPDF_DOC_PRIORITY=optional
QPDF_DEPENDS=libqpdf
LIBQPDF_DEPENDS=libstdc++, pcre, zlib
LIBQPDF_DEV_DEPENDS=libqpdf
QPDF_DOC_DEPENDS=qpdf
QPDF_SUGGESTS=
QPDF_CONFLICTS=

#
# QPDF_IPK_VERSION should be incremented when the ipk changes.
#
QPDF_IPK_VERSION=2

#
# QPDF_CONFFILES should be a list of user-editable files
#QPDF_CONFFILES=$(TARGET_PREFIX)/etc/qpdf.conf $(TARGET_PREFIX)/etc/init.d/SXXqpdf

#
# QPDF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#QPDF_PATCHES=$(QPDF_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
QPDF_CPPFLAGS=
QPDF_LDFLAGS=

#
# QPDF_BUILD_DIR is the directory in which the build is done.
# QPDF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# QPDF_IPK_DIR is the directory in which the ipk is built.
# QPDF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
QPDF_BUILD_DIR=$(BUILD_DIR)/qpdf
QPDF_SOURCE_DIR=$(SOURCE_DIR)/qpdf

QPDF_IPK_DIR=$(BUILD_DIR)/qpdf-$(QPDF_VERSION)-ipk
QPDF_IPK=$(BUILD_DIR)/qpdf_$(QPDF_VERSION)-$(QPDF_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBQPDF_IPK_DIR=$(BUILD_DIR)/libqpdf-$(QPDF_VERSION)-ipk
LIBQPDF_IPK=$(BUILD_DIR)/libqpdf_$(QPDF_VERSION)-$(QPDF_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBQPDF_DEV_IPK_DIR=$(BUILD_DIR)/libqpdf-dev-$(QPDF_VERSION)-ipk
LIBQPDF_DEV_IPK=$(BUILD_DIR)/libqpdf-dev_$(QPDF_VERSION)-$(QPDF_IPK_VERSION)_$(TARGET_ARCH).ipk

QPDF_DOC_IPK_DIR=$(BUILD_DIR)/qpdf-doc-$(QPDF_VERSION)-ipk
QPDF_DOC_IPK=$(BUILD_DIR)/qpdf-doc_$(QPDF_VERSION)-$(QPDF_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: qpdf-source qpdf-unpack qpdf qpdf-stage qpdf-ipk qpdf-clean qpdf-dirclean qpdf-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(QPDF_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(QPDF_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(QPDF_SOURCE).sha512
#
$(DL_DIR)/$(QPDF_SOURCE):
	$(WGET) -O $@ $(QPDF_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
qpdf-source: $(DL_DIR)/$(QPDF_SOURCE) $(QPDF_PATCHES)

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
$(QPDF_BUILD_DIR)/.configured: $(DL_DIR)/$(QPDF_SOURCE) $(QPDF_PATCHES) make/qpdf.mk
	$(MAKE) pcre-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(QPDF_DIR) $(@D)
	$(QPDF_UNZIP) $(DL_DIR)/$(QPDF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(QPDF_PATCHES)" ; \
		then cat $(QPDF_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(QPDF_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(QPDF_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(QPDF_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(QPDF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(QPDF_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--docdir=$(TARGET_PREFIX)/share/doc/qpdf \
		--with-random=/dev/urandom \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

qpdf-unpack: $(QPDF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(QPDF_BUILD_DIR)/.built: $(QPDF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
qpdf: $(QPDF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(QPDF_BUILD_DIR)/.staged: $(QPDF_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libqpdf.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libqpdf.pc
	touch $@

qpdf-stage: $(QPDF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/qpdf
#
$(QPDF_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: qpdf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(QPDF_PRIORITY)" >>$@
	@echo "Section: $(QPDF_SECTION)" >>$@
	@echo "Version: $(QPDF_VERSION)-$(QPDF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(QPDF_MAINTAINER)" >>$@
	@echo "Source: $(QPDF_URL)" >>$@
	@echo "Description: $(QPDF_DESCRIPTION)" >>$@
	@echo "Depends: $(QPDF_DEPENDS)" >>$@
	@echo "Suggests: $(QPDF_SUGGESTS)" >>$@
	@echo "Conflicts: $(QPDF_CONFLICTS)" >>$@

$(LIBQPDF_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libqpdf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(QPDF_PRIORITY)" >>$@
	@echo "Section: $(LIBQPDF_SECTION)" >>$@
	@echo "Version: $(QPDF_VERSION)-$(QPDF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(QPDF_MAINTAINER)" >>$@
	@echo "Source: $(QPDF_URL)" >>$@
	@echo "Description: $(LIBQPDF_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBQPDF_DEPENDS)" >>$@
	@echo "Suggests: $(LIBQPDF_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBQPDF_CONFLICTS)" >>$@

$(LIBQPDF_DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libqpdf-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBQPDF_DEV_PRIORITY)" >>$@
	@echo "Section: $(LIBQPDF_DEV_SECTION)" >>$@
	@echo "Version: $(QPDF_VERSION)-$(QPDF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(QPDF_MAINTAINER)" >>$@
	@echo "Source: $(QPDF_URL)" >>$@
	@echo "Description: $(LIBQPDF_DEV_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBQPDF_DEV_DEPENDS)" >>$@
	@echo "Suggests: $(LIBQPDF_DEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBQPDF_DEV_CONFLICTS)" >>$@

$(QPDF_DOC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: qpdf-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(QPDF_DOC_PRIORITY)" >>$@
	@echo "Section: $(QPDF_DOC_SECTION)" >>$@
	@echo "Version: $(QPDF_VERSION)-$(QPDF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(QPDF_MAINTAINER)" >>$@
	@echo "Source: $(QPDF_URL)" >>$@
	@echo "Description: $(QPDF_DOC_DESCRIPTION)" >>$@
	@echo "Depends: $(QPDF_DOC_DEPENDS)" >>$@
	@echo "Suggests: $(QPDF_DOC_SUGGESTS)" >>$@
	@echo "Conflicts: $(QPDF_DOC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(QPDF_IPK_DIR)$(TARGET_PREFIX)/sbin or $(QPDF_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(QPDF_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(QPDF_IPK_DIR)$(TARGET_PREFIX)/etc/qpdf/...
# Documentation files should be installed in $(QPDF_IPK_DIR)$(TARGET_PREFIX)/doc/qpdf/...
# Daemon startup scripts should be installed in $(QPDF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??qpdf
#
# You may need to patch your application to make it use these locations.
#
$(QPDF_IPK) $(LIBQPDF_IPK) $(LIBQPDF_DEV_IPK) $(QPDF_DOC_IPK): $(QPDF_BUILD_DIR)/.built
	rm -rf  $(QPDF_IPK_DIR) $(BUILD_DIR)/qpdf_*_$(TARGET_ARCH).ipk \
		$(LIBQPDF_IPK_DIR) $(BUILD_DIR)/libqpdf_*_$(TARGET_ARCH).ipk \
		$(LIBQPDF_DEV_IPK_DIR) $(BUILD_DIR)/libqpdf-dev_*_$(TARGET_ARCH).ipk \
		$(QPDF_DOC_IPK_DIR) $(BUILD_DIR)/qpdf-doc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(QPDF_BUILD_DIR) DESTDIR=$(QPDF_IPK_DIR) install
	rm -f $(QPDF_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	$(STRIP_COMMAND) $(QPDF_IPK_DIR)$(TARGET_PREFIX)/{bin/{qpdf,zlib-flate},lib/libqpdf.so}
#	$(INSTALL) -d $(QPDF_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(QPDF_SOURCE_DIR)/qpdf.conf $(QPDF_IPK_DIR)$(TARGET_PREFIX)/etc/qpdf.conf
#	$(INSTALL) -d $(QPDF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(QPDF_SOURCE_DIR)/rc.qpdf $(QPDF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXqpdf
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(QPDF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXqpdf
	$(INSTALL) -d $(LIBQPDF_IPK_DIR)$(TARGET_PREFIX)
	mv -f  $(QPDF_IPK_DIR)$(TARGET_PREFIX)/lib $(LIBQPDF_IPK_DIR)$(TARGET_PREFIX)
	$(INSTALL) -d $(LIBQPDF_DEV_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(LIBQPDF_IPK_DIR)$(TARGET_PREFIX)/lib/{*.so,pkgconfig} $(LIBQPDF_DEV_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f  $(QPDF_IPK_DIR)$(TARGET_PREFIX)/include $(LIBQPDF_DEV_IPK_DIR)$(TARGET_PREFIX)
	$(INSTALL) -d $(QPDF_DOC_IPK_DIR)$(TARGET_PREFIX)/share
	mv -f $(QPDF_IPK_DIR)$(TARGET_PREFIX)/share/doc $(QPDF_DOC_IPK_DIR)$(TARGET_PREFIX)/share
	$(MAKE) $(QPDF_IPK_DIR)/CONTROL/control $(LIBQPDF_IPK_DIR)/CONTROL/control \
		$(LIBQPDF_DEV_IPK_DIR)/CONTROL/control $(QPDF_DOC_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(QPDF_SOURCE_DIR)/postinst $(QPDF_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(QPDF_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(QPDF_SOURCE_DIR)/prerm $(QPDF_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(QPDF_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(QPDF_IPK_DIR)/CONTROL/postinst $(QPDF_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(QPDF_CONFFILES) | sed -e 's/ /\n/g' > $(QPDF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(QPDF_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBQPDF_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBQPDF_DEV_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(QPDF_DOC_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(QPDF_IPK_DIR) $(LIBQPDF_IPK_DIR) $(LIBQPDF_DEV_IPK_DIR) $(QPDF_DOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
qpdf-ipk: $(QPDF_IPK) $(LIBQPDF_IPK) $(LIBQPDF_DEV_IPK) $(QPDF_DOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
qpdf-clean:
	rm -f $(QPDF_BUILD_DIR)/.built
	-$(MAKE) -C $(QPDF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
qpdf-dirclean:
	rm -rf  $(BUILD_DIR)/$(QPDF_DIR) $(QPDF_BUILD_DIR) \
		$(QPDF_IPK_DIR) $(QPDF_IPK) \
		$(LIBQPDF_IPK_DIR) $(LIBQPDF_IPK) \
		$(LIBQPDF_DEV_IPK_DIR) $(LIBQPDF_DEV_IPK) \
		$(QPDF_DOC_IPK_DIR) $(QPDF_DOC_IPK)
#
#
# Some sanity check for the package.
#
qpdf-check: $(QPDF_IPK) $(LIBQPDF_IPK) $(LIBQPDF_DEV_IPK) $(QPDF_DOC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
