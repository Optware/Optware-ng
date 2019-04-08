###########################################################
#
# xmlstarlet
#
###########################################################
#
# XMLSTARLET_VERSION, XMLSTARLET_SITE and XMLSTARLET_SOURCE define
# the upstream location of the source code for the package.
# XMLSTARLET_DIR is the directory which is created when the source
# archive is unpacked.
# XMLSTARLET_UNZIP is the command used to unzip the source.
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
XMLSTARLET_URL=https://sourceforge.net/projects/xmlstar/files/xmlstarlet/$(XMLSTARLET_VERSION)/xmlstarlet-$(XMLSTARLET_VERSION).tar.gz/download
XMLSTARLET_VERSION=1.6.1
XMLSTARLET_SOURCE=xmlstarlet-$(XMLSTARLET_VERSION).tar.gz
XMLSTARLET_DIR=xmlstarlet-$(XMLSTARLET_VERSION)
XMLSTARLET_UNZIP=zcat
XMLSTARLET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XMLSTARLET_DESCRIPTION=A set of tools to transform, query, validate, and edit XML documents.
XMLSTARLET_SECTION=util
XMLSTARLET_PRIORITY=optional
XMLSTARLET_DEPENDS=libxml2, libxslt
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
XMLSTARLET_DEPENDS+=, libiconv
endif
XMLSTARLET_SUGGESTS=
XMLSTARLET_CONFLICTS=

#
# XMLSTARLET_IPK_VERSION should be incremented when the ipk changes.
#
XMLSTARLET_IPK_VERSION=1

#
# XMLSTARLET_CONFFILES should be a list of user-editable files
#XMLSTARLET_CONFFILES=$(TARGET_PREFIX)/etc/xmlstarlet.conf $(TARGET_PREFIX)/etc/init.d/SXXxmlstarlet

#
# XMLSTARLET_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XMLSTARLET_PATCHES=$(XMLSTARLET_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XMLSTARLET_CPPFLAGS=
XMLSTARLET_LDFLAGS=

ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
XMLSTARLET_ARGS+= --with-libiconv-prefix=$(STAGING_PREFIX)
endif

#
# XMLSTARLET_BUILD_DIR is the directory in which the build is done.
# XMLSTARLET_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XMLSTARLET_IPK_DIR is the directory in which the ipk is built.
# XMLSTARLET_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XMLSTARLET_BUILD_DIR=$(BUILD_DIR)/xmlstarlet
XMLSTARLET_SOURCE_DIR=$(SOURCE_DIR)/xmlstarlet
XMLSTARLET_IPK_DIR=$(BUILD_DIR)/xmlstarlet-$(XMLSTARLET_VERSION)-ipk
XMLSTARLET_IPK=$(BUILD_DIR)/xmlstarlet_$(XMLSTARLET_VERSION)-$(XMLSTARLET_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: xmlstarlet-source xmlstarlet-unpack xmlstarlet xmlstarlet-stage xmlstarlet-ipk xmlstarlet-clean xmlstarlet-dirclean xmlstarlet-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(XMLSTARLET_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(XMLSTARLET_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(XMLSTARLET_SOURCE).sha512
#
$(DL_DIR)/$(XMLSTARLET_SOURCE):
	$(WGET) -O $@ $(XMLSTARLET_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xmlstarlet-source: $(DL_DIR)/$(XMLSTARLET_SOURCE) $(XMLSTARLET_PATCHES)

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
$(XMLSTARLET_BUILD_DIR)/.configured: $(DL_DIR)/$(XMLSTARLET_SOURCE) $(XMLSTARLET_PATCHES) make/xmlstarlet.mk
	$(MAKE) libxml2-stage libxslt-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(XMLSTARLET_DIR) $(@D)
	$(XMLSTARLET_UNZIP) $(DL_DIR)/$(XMLSTARLET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(XMLSTARLET_PATCHES)" ; \
		then cat $(XMLSTARLET_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XMLSTARLET_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(XMLSTARLET_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XMLSTARLET_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XMLSTARLET_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XMLSTARLET_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
		--disable-nls \
		--with-libxml-prefix=$(STAGING_PREFIX) \
		--with-libxslt-prefix=$(STAGING_PREFIX) \
		$(XMLSTARLET_ARGS) \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

xmlstarlet-unpack: $(XMLSTARLET_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XMLSTARLET_BUILD_DIR)/.built: $(XMLSTARLET_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xmlstarlet: $(XMLSTARLET_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XMLSTARLET_BUILD_DIR)/.staged: $(XMLSTARLET_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

xmlstarlet-stage: $(XMLSTARLET_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/xmlstarlet
#
$(XMLSTARLET_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: xmlstarlet" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XMLSTARLET_PRIORITY)" >>$@
	@echo "Section: $(XMLSTARLET_SECTION)" >>$@
	@echo "Version: $(XMLSTARLET_VERSION)-$(XMLSTARLET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XMLSTARLET_MAINTAINER)" >>$@
	@echo "Source: $(XMLSTARLET_URL)" >>$@
	@echo "Description: $(XMLSTARLET_DESCRIPTION)" >>$@
	@echo "Depends: $(XMLSTARLET_DEPENDS)" >>$@
	@echo "Suggests: $(XMLSTARLET_SUGGESTS)" >>$@
	@echo "Conflicts: $(XMLSTARLET_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(XMLSTARLET_IPK_DIR)$(TARGET_PREFIX)/sbin or $(XMLSTARLET_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XMLSTARLET_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(XMLSTARLET_IPK_DIR)$(TARGET_PREFIX)/etc/xmlstarlet/...
# Documentation files should be installed in $(XMLSTARLET_IPK_DIR)$(TARGET_PREFIX)/doc/xmlstarlet/...
# Daemon startup scripts should be installed in $(XMLSTARLET_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??xmlstarlet
#
# You may need to patch your application to make it use these locations.
#
$(XMLSTARLET_IPK): $(XMLSTARLET_BUILD_DIR)/.built
	rm -rf $(XMLSTARLET_IPK_DIR) $(BUILD_DIR)/xmlstarlet_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XMLSTARLET_BUILD_DIR) DESTDIR=$(XMLSTARLET_IPK_DIR) install-strip
#	$(INSTALL) -d $(XMLSTARLET_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(XMLSTARLET_SOURCE_DIR)/xmlstarlet.conf $(XMLSTARLET_IPK_DIR)$(TARGET_PREFIX)/etc/xmlstarlet.conf
#	$(INSTALL) -d $(XMLSTARLET_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(XMLSTARLET_SOURCE_DIR)/rc.xmlstarlet $(XMLSTARLET_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXxmlstarlet
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XMLSTARLET_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXxmlstarlet
	$(MAKE) $(XMLSTARLET_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(XMLSTARLET_SOURCE_DIR)/postinst $(XMLSTARLET_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XMLSTARLET_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(XMLSTARLET_SOURCE_DIR)/prerm $(XMLSTARLET_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XMLSTARLET_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(XMLSTARLET_IPK_DIR)/CONTROL/postinst $(XMLSTARLET_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(XMLSTARLET_CONFFILES) | sed -e 's/ /\n/g' > $(XMLSTARLET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XMLSTARLET_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(XMLSTARLET_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xmlstarlet-ipk: $(XMLSTARLET_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xmlstarlet-clean:
	rm -f $(XMLSTARLET_BUILD_DIR)/.built
	-$(MAKE) -C $(XMLSTARLET_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xmlstarlet-dirclean:
	rm -rf $(BUILD_DIR)/$(XMLSTARLET_DIR) $(XMLSTARLET_BUILD_DIR) $(XMLSTARLET_IPK_DIR) $(XMLSTARLET_IPK)
#
#
# Some sanity check for the package.
#
xmlstarlet-check: $(XMLSTARLET_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
