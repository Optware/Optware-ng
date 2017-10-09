###########################################################
#
# cups-filters
#
###########################################################
#
# CUPS_FILTERS_VERSION, CUPS_FILTERS_SITE and CUPS_FILTERS_SOURCE define
# the upstream location of the source code for the package.
# CUPS_FILTERS_DIR is the directory which is created when the source
# archive is unpacked.
# CUPS_FILTERS_UNZIP is the command used to unzip the source.
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
CUPS_FILTERS_URL=https://www.openprinting.org/download/cups-filters/cups-filters-$(CUPS_FILTERS_VERSION).tar.xz
CUPS_FILTERS_VERSION=1.11.2
CUPS_FILTERS_SOURCE=cups-filters-$(CUPS_FILTERS_VERSION).tar.gz
CUPS_FILTERS_DIR=cups-filters-$(CUPS_FILTERS_VERSION)
CUPS_FILTERS_UNZIP=xzcat
CUPS_FILTERS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CUPS_FILTERS_DESCRIPTION=OpenPrinting CUPS Filters: additional CUPS filters which are not provided by the CUPS project itself
CUPS_FILTERS_DOC_DESCRIPTION=OpenPrinting CUPS Filters: docs
LIBFONTEMBED_DESCRIPTION=OpenPrinting CUPS Filters - Font Embed Shared library
LIBFONTEMBED_DEV_DESCRIPTION=OpenPrinting CUPS Filters - Development files for font embed library
LIBCUPSFILTERS_DESCRIPTION=OpenPrinting CUPS Filters - Shared library
LIBCUPSFILTERS_DEV_DESCRIPTION=OpenPrinting CUPS Filters - Development files for the library
CUPS_FILTERS_SECTION=misc
CUPS_FILTERS_DOC_SECTION=docs
LIBFONTEMBED_SECTION=libs
LIBFONTEMBED_DEV_SECTION=dev
LIBCUPSFILTERS_SECTION=libs
LIBCUPSFILTERS_DEV_SECTION=dev
CUPS_FILTERS_PRIORITY=optional
CUPS_FILTERS_DOC_PRIORITY=optional
LIBFONTEMBED_PRIORITY=optional
LIBFONTEMBED_DEV_PRIORITY=optional
LIBCUPSFILTERS_PRIORITY=optional
LIBCUPSFILTERS_DEV_PRIORITY=optional
CUPS_FILTERS_DEPENDS=libavahi-client, libavahi-common, libavahi-glib, libcupsfilters, libcupsimage, libcups, libfontembed, libijs, openldap-libs, libpoppler, libqpdf, ghostscript
CUPS_FILTERS_DOC_DEPENDS=cups-filters
LIBFONTEMBED_DEPENDS=libjpeg, openldap-libs, libtiff
LIBFONTEMBED_DEV_DEPENDS=
LIBCUPSFILTERS_DEPENDS=libcups, libcupsimage, openldap-libs, zlib
LIBCUPSFILTERS_DEV_DEPENDS=
ifneq ($(filter libiconv, $(PACKAGES)), )
CUPS_FILTERS_DEPENDS +=, libiconv
LIBFONTEMBED_DEPENDS +=, libiconv
LIBCUPSFILTERS_DEPENDS +=, libiconv
endif
CUPS_FILTERS_SUGGESTS=
CUPS_FILTERS_CONFLICTS=

#
# CUPS_FILTERS_IPK_VERSION should be incremented when the ipk changes.
#
CUPS_FILTERS_IPK_VERSION=5

#
# CUPS_FILTERS_CONFFILES should be a list of user-editable files
CUPS_FILTERS_CONFFILES=\
$(TARGET_PREFIX)/etc/fonts/conf.d/99pdftoopvp.conf \
$(TARGET_PREFIX)/etc/cups/cups-browsed.conf \
$(TARGET_PREFIX)/share/cups/mime/braille.convs \
$(TARGET_PREFIX)/share/cups/mime/braille.types \
$(TARGET_PREFIX)/share/cups/mime/cupsfilters.convs \
$(TARGET_PREFIX)/share/cups/mime/cupsfilters-ghostscript.convs \
$(TARGET_PREFIX)/share/cups/mime/cupsfilters-mupdf.convs \
$(TARGET_PREFIX)/share/cups/mime/cupsfilters-poppler.convs \
$(TARGET_PREFIX)/share/cups/mime/cupsfilters.types \
#$(TARGET_PREFIX)/etc/init.d/SXXcups-filters

#
# CUPS_FILTERS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CUPS_FILTERS_PATCHES=\
$(CUPS_FILTERS_SOURCE_DIR)/enable_gs_ps2write.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CUPS_FILTERS_CPPFLAGS=
CUPS_FILTERS_LDFLAGS=
ifneq ($(filter libiconv, $(PACKAGES)), )
CUPS_FILTERS_LDFLAGS += -liconv
endif

#
# CUPS_FILTERS_BUILD_DIR is the directory in which the build is done.
# CUPS_FILTERS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CUPS_FILTERS_IPK_DIR is the directory in which the ipk is built.
# CUPS_FILTERS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CUPS_FILTERS_BUILD_DIR=$(BUILD_DIR)/cups-filters
CUPS_FILTERS_SOURCE_DIR=$(SOURCE_DIR)/cups-filters

CUPS_FILTERS_IPK_DIR=$(BUILD_DIR)/cups-filters-$(CUPS_FILTERS_VERSION)-ipk
CUPS_FILTERS_IPK=$(BUILD_DIR)/cups-filters_$(CUPS_FILTERS_VERSION)-$(CUPS_FILTERS_IPK_VERSION)_$(TARGET_ARCH).ipk

CUPS_FILTERS_DOC_IPK_DIR=$(BUILD_DIR)/cups-filters-doc-$(CUPS_FILTERS_VERSION)-ipk
CUPS_FILTERS_DOC_IPK=$(BUILD_DIR)/cups-filters-doc_$(CUPS_FILTERS_VERSION)-$(CUPS_FILTERS_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBFONTEMBED_IPK_DIR=$(BUILD_DIR)/libfontembed-$(CUPS_FILTERS_VERSION)-ipk
LIBFONTEMBED_IPK=$(BUILD_DIR)/libfontembed_$(CUPS_FILTERS_VERSION)-$(CUPS_FILTERS_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBFONTEMBED_DEV_IPK_DIR=$(BUILD_DIR)/libfontembed-dev-$(CUPS_FILTERS_VERSION)-ipk
LIBFONTEMBED_DEV_IPK=$(BUILD_DIR)/libfontembed-dev_$(CUPS_FILTERS_VERSION)-$(CUPS_FILTERS_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBCUPSFILTERS_IPK_DIR=$(BUILD_DIR)/libcupsfilters-$(CUPS_FILTERS_VERSION)-ipk
LIBCUPSFILTERS_IPK=$(BUILD_DIR)/libcupsfilters_$(CUPS_FILTERS_VERSION)-$(CUPS_FILTERS_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBCUPSFILTERS_DEV_IPK_DIR=$(BUILD_DIR)/libcupsfilters-dev-$(CUPS_FILTERS_VERSION)-ipk
LIBCUPSFILTERS_DEV_IPK=$(BUILD_DIR)/libcupsfilters-dev_$(CUPS_FILTERS_VERSION)-$(CUPS_FILTERS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cups-filters-source cups-filters-unpack cups-filters cups-filters-stage cups-filters-ipk cups-filters-clean cups-filters-dirclean cups-filters-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(CUPS_FILTERS_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(CUPS_FILTERS_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(CUPS_FILTERS_SOURCE).sha512
#
$(DL_DIR)/$(CUPS_FILTERS_SOURCE):
	$(WGET) -O $@ $(CUPS_FILTERS_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cups-filters-source: $(DL_DIR)/$(CUPS_FILTERS_SOURCE) $(CUPS_FILTERS_PATCHES)

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
$(CUPS_FILTERS_BUILD_DIR)/.configured: $(DL_DIR)/$(CUPS_FILTERS_SOURCE) $(CUPS_FILTERS_PATCHES) make/cups-filters.mk
	$(MAKE) cups-stage glib-stage libijs-stage poppler-stage qpdf-stage openldap-stage
ifneq ($(filter libiconv, $(PACKAGES)), )
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(CUPS_FILTERS_DIR) $(@D)
	$(CUPS_FILTERS_UNZIP) $(DL_DIR)/$(CUPS_FILTERS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CUPS_FILTERS_PATCHES)" ; \
		then cat $(CUPS_FILTERS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(CUPS_FILTERS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(CUPS_FILTERS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CUPS_FILTERS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CUPS_FILTERS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CUPS_FILTERS_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--sysconfdir=$(TARGET_PREFIX)/etc \
		--localstatedir=$(TARGET_PREFIX)/var \
		--with-cups-config=$(STAGING_PREFIX)/bin/cups-config \
		--without-rcdir \
		--with-gs-path=$(TARGET_PREFIX)/bin/gs \
		--enable-gs-ps2write \
		--with-pdftops-path=$(TARGET_PREFIX)/bin/gs \
		--docdir=$(TARGET_PREFIX)/share/doc/cups-filters \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

cups-filters-unpack: $(CUPS_FILTERS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CUPS_FILTERS_BUILD_DIR)/.built: $(CUPS_FILTERS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
cups-filters: $(CUPS_FILTERS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CUPS_FILTERS_BUILD_DIR)/.staged: $(CUPS_FILTERS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/{libfontembed,libcupsfilters}.la
	sed -i -e '/^prefix=\|exec_prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/{libfontembed,libcupsfilters}.pc
	touch $@

cups-filters-stage: $(CUPS_FILTERS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cups-filters
#
$(CUPS_FILTERS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: cups-filters" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS_FILTERS_PRIORITY)" >>$@
	@echo "Section: $(CUPS_FILTERS_SECTION)" >>$@
	@echo "Version: $(CUPS_FILTERS_VERSION)-$(CUPS_FILTERS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_FILTERS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_FILTERS_URL)" >>$@
	@echo "Description: $(CUPS_FILTERS_DESCRIPTION)" >>$@
	@echo "Depends: $(CUPS_FILTERS_DEPENDS)" >>$@
	@echo "Suggests: $(CUPS_FILTERS_SUGGESTS)" >>$@
	@echo "Conflicts: $(CUPS_FILTERS_CONFLICTS)" >>$@

$(CUPS_FILTERS_DOC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: cups-filters-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS_FILTERS_DOC_PRIORITY)" >>$@
	@echo "Section: $(CUPS_FILTERS_DOC_SECTION)" >>$@
	@echo "Version: $(CUPS_FILTERS_VERSION)-$(CUPS_FILTERS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_FILTERS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_FILTERS_URL)" >>$@
	@echo "Description: $(CUPS_FILTERS_DOC_DESCRIPTION)" >>$@
	@echo "Depends: $(CUPS_FILTERS_DOC_DEPENDS)" >>$@
	@echo "Suggests: $(CUPS_FILTERS_DOC_SUGGESTS)" >>$@
	@echo "Conflicts: $(CUPS_FILTERS_DOC_CONFLICTS)" >>$@

$(LIBFONTEMBED_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libfontembed" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBFONTEMBED_PRIORITY)" >>$@
	@echo "Section: $(LIBFONTEMBED_SECTION)" >>$@
	@echo "Version: $(CUPS_FILTERS_VERSION)-$(CUPS_FILTERS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_FILTERS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_FILTERS_URL)" >>$@
	@echo "Description: $(LIBFONTEMBED_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBFONTEMBED_DEPENDS)" >>$@
	@echo "Suggests: $(LIBFONTEMBED_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBFONTEMBED_CONFLICTS)" >>$@

$(LIBFONTEMBED_DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libfontembed-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBFONTEMBED_DEV_PRIORITY)" >>$@
	@echo "Section: $(LIBFONTEMBED_DEV_SECTION)" >>$@
	@echo "Version: $(CUPS_FILTERS_VERSION)-$(CUPS_FILTERS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_FILTERS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_FILTERS_URL)" >>$@
	@echo "Description: $(LIBFONTEMBED_DEV_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBFONTEMBED_DEV_DEPENDS)" >>$@
	@echo "Suggests: $(LIBFONTEMBED_DEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBFONTEMBED_DEV_CONFLICTS)" >>$@

$(LIBCUPSFILTERS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libcupsfilters" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBCUPSFILTERS_PRIORITY)" >>$@
	@echo "Section: $(LIBCUPSFILTERS_SECTION)" >>$@
	@echo "Version: $(CUPS_FILTERS_VERSION)-$(CUPS_FILTERS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_FILTERS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_FILTERS_URL)" >>$@
	@echo "Description: $(LIBCUPSFILTERS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBCUPSFILTERS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBCUPSFILTERS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBCUPSFILTERS_CONFLICTS)" >>$@

$(LIBCUPSFILTERS_DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libcupsfilters-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBCUPSFILTERS_DEV_PRIORITY)" >>$@
	@echo "Section: $(LIBCUPSFILTERS_DEV_SECTION)" >>$@
	@echo "Version: $(CUPS_FILTERS_VERSION)-$(CUPS_FILTERS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_FILTERS_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_FILTERS_URL)" >>$@
	@echo "Description: $(LIBCUPSFILTERS_DEV_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBCUPSFILTERS_DEV_DEPENDS)" >>$@
	@echo "Suggests: $(LIBCUPSFILTERS_DEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBCUPSFILTERS_DEV_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/etc/cups-filters/...
# Documentation files should be installed in $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/doc/cups-filters/...
# Daemon startup scripts should be installed in $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??cups-filters
#
# You may need to patch your application to make it use these locations.
#
$(CUPS_FILTERS_IPK) $(CUPS_FILTERS_DOC_IPK) $(LIBFONTEMBED_IPK) $(LIBFONTEMBED_DEV_IPK) \
$(LIBCUPSFILTERS_IPK) $(LIBCUPSFILTERS_DEV_IPK): $(CUPS_FILTERS_BUILD_DIR)/.built
	rm -rf  $(CUPS_FILTERS_IPK_DIR) $(BUILD_DIR)/cups-filters_*_$(TARGET_ARCH).ipk \
		$(CUPS_FILTERS_DOC_IPK_DIR) $(BUILD_DIR)/cups-filters-doc_*_$(TARGET_ARCH).ipk \
		$(LIBFONTEMBED_IPK_DIR) $(BUILD_DIR)/libfontembed_*_$(TARGET_ARCH).ipk \
		$(LIBFONTEMBED_DEV_IPK_DIR) $(BUILD_DIR)/libfontembed-dev_*_$(TARGET_ARCH).ipk \
		$(LIBCUPSFILTERS_IPK_DIR) $(BUILD_DIR)/libcupsfilters_*_$(TARGET_ARCH).ipk \
		$(LIBCUPSFILTERS_DEV_IPK_DIR) $(BUILD_DIR)/libcupsfilters-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CUPS_FILTERS_BUILD_DIR) DESTDIR=$(CUPS_FILTERS_IPK_DIR) install-strip
	chmod 755 $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/lib/cups/*
	rm -f $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	sed -i -e 's|$(STAGING_PREFIX)|$(TARGET_PREFIX)|g' $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig/{libfontembed,libcupsfilters}.pc
	$(INSTALL) -d $(CUPS_FILTERS_DOC_IPK_DIR)$(TARGET_PREFIX)/share
	mv -f $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/share/doc $(CUPS_FILTERS_DOC_IPK_DIR)$(TARGET_PREFIX)/share
	$(INSTALL) -d $(LIBFONTEMBED_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/lib/libfontembed.so* $(LIBFONTEMBED_IPK_DIR)$(TARGET_PREFIX)/lib
	$(INSTALL) -d $(LIBFONTEMBED_DEV_IPK_DIR)$(TARGET_PREFIX)/{lib/pkgconfig,include}
	mv -f $(LIBFONTEMBED_IPK_DIR)$(TARGET_PREFIX)/lib/libfontembed.so $(LIBFONTEMBED_DEV_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig/libfontembed.pc $(LIBFONTEMBED_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig
	mv -f $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/include/fontembed $(LIBFONTEMBED_DEV_IPK_DIR)$(TARGET_PREFIX)/include
	$(INSTALL) -d $(LIBCUPSFILTERS_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/lib/libcupsfilters.so* $(LIBCUPSFILTERS_IPK_DIR)$(TARGET_PREFIX)/lib
	$(INSTALL) -d $(LIBCUPSFILTERS_DEV_IPK_DIR)$(TARGET_PREFIX)/{lib/pkgconfig,include}
	mv -f $(LIBCUPSFILTERS_IPK_DIR)$(TARGET_PREFIX)/lib/libcupsfilters.so $(LIBCUPSFILTERS_DEV_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig/libcupsfilters.pc $(LIBCUPSFILTERS_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig
	mv -f $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/include/cupsfilters $(LIBCUPSFILTERS_DEV_IPK_DIR)$(TARGET_PREFIX)/include
	rm -rf $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/{lib/pkgconfig,include}
#	$(INSTALL) -d $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(CUPS_FILTERS_SOURCE_DIR)/cups-filters.conf $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/etc/cups-filters.conf
#	$(INSTALL) -d $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(CUPS_FILTERS_SOURCE_DIR)/rc.cups-filters $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXcups-filters
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CUPS_FILTERS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXcups-filters
	$(MAKE) $(CUPS_FILTERS_IPK_DIR)/CONTROL/control $(CUPS_FILTERS_DOC_IPK_DIR)/CONTROL/control \
		$(LIBFONTEMBED_IPK_DIR)/CONTROL/control $(LIBFONTEMBED_DEV_IPK_DIR)/CONTROL/control \
		$(LIBCUPSFILTERS_IPK_DIR)/CONTROL/control $(LIBCUPSFILTERS_DEV_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(CUPS_FILTERS_SOURCE_DIR)/postinst $(CUPS_FILTERS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CUPS_FILTERS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(CUPS_FILTERS_SOURCE_DIR)/prerm $(CUPS_FILTERS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CUPS_FILTERS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(CUPS_FILTERS_IPK_DIR)/CONTROL/postinst $(CUPS_FILTERS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(CUPS_FILTERS_CONFFILES) | sed -e 's/ /\n/g' > $(CUPS_FILTERS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_FILTERS_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_FILTERS_DOC_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBFONTEMBED_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBFONTEMBED_DEV_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBCUPSFILTERS_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBCUPSFILTERS_DEV_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(CUPS_FILTERS_IPK_DIR) $(CUPS_FILTERS_DOC_IPK_DIR) $(LIBFONTEMBED_IPK_DIR) \
				$(LIBFONTEMBED_DEV_IPK_DIR) $(LIBCUPSFILTERS_IPK_DIR) $(LIBCUPSFILTERS_DEV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cups-filters-ipk: $(CUPS_FILTERS_IPK) $(CUPS_FILTERS_DOC_IPK) $(LIBFONTEMBED_IPK) $(LIBFONTEMBED_DEV_IPK) $(LIBCUPSFILTERS_IPK) $(LIBCUPSFILTERS_DEV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cups-filters-clean:
	rm -f $(CUPS_FILTERS_BUILD_DIR)/.built
	-$(MAKE) -C $(CUPS_FILTERS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cups-filters-dirclean:
	rm -rf  $(BUILD_DIR)/$(CUPS_FILTERS_DIR) $(CUPS_FILTERS_BUILD_DIR) \
		$(CUPS_FILTERS_IPK_DIR) $(CUPS_FILTERS_IPK) \
		$(CUPS_FILTERS_DOC_IPK_DIR) $(CUPS_FILTERS_DOC_IPK) \
		$(LIBFONTEMBED_IPK_DIR) $(LIBFONTEMBED_IPK) \
		$(LIBFONTEMBED_DEV_IPK_DIR) $(LIBFONTEMBED_DEV_IPK) \
		$(LIBCUPSFILTERS_IPK_DIR) $(LIBCUPSFILTERS_IPK) \
		$(LIBCUPSFILTERS_DEV_IPK_DIR) $(LIBCUPSFILTERS_DEV_IPK)
#
#
# Some sanity check for the package.
#
cups-filters-check: $(CUPS_FILTERS_IPK) $(CUPS_FILTERS_DOC_IPK) $(LIBFONTEMBED_IPK) $(LIBFONTEMBED_DEV_IPK) $(LIBCUPSFILTERS_IPK) $(LIBCUPSFILTERS_DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
