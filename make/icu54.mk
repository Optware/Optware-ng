###########################################################
#
# icu54
#
###########################################################

# You must replace "icu54" and "ICU54" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ICU54_VERSION, ICU54_SITE and ICU54_SOURCE define
# the upstream location of the source code for the package.
# ICU54_DIR is the directory which is created when the source
# archive is unpacked.
# ICU54_UNZIP is the command used to unzip the source.
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
ICU54_SITE=http://download.icu54-project.org/files/icu4c/54.1/
ICU54_VERSION=54.1
ICU54_SOURCE=icu4c-54_1-src.tgz
ICU54_DIR=icu54
ICU54_UNZIP=zcat
ICU54_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ICU54_DESCRIPTION=ICU54 is a mature, widely used set of portable libraries for Unicode support, software internationalization and globalization.
ICU54_SECTION=admin
ICU54_PRIORITY=optional
ICU54_DEPENDS=
ICU54_SUGGESTS=
ICU54_CONFLICTS=

#
# ICU54_IPK_VERSION should be incremented when the ipk changes.
#
ICU54_IPK_VERSION=1

#
# ICU54_CONFFILES should be a list of user-editable files
#ICU54_CONFFILES=/opt/etc/icu54.conf /opt/etc/init.d/SXXicu54

#
# ICU54_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ICU54_PATCHES=$(ICU54_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ICU54_CPPFLAGS=
ICU54_LDFLAGS=

#
# ICU54_BUILD_DIR is the directory in which the build is done.
# ICU54_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ICU54_IPK_DIR is the directory in which the ipk is built.
# ICU54_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ICU54_BUILD_DIR=$(BUILD_DIR)/icu54
ICU54_SOURCE_DIR=$(SOURCE_DIR)/icu54
ICU54_IPK_DIR=$(BUILD_DIR)/icu54-$(ICU54_VERSION)-ipk
ICU54_IPK=$(BUILD_DIR)/icu54_$(ICU54_VERSION)-$(ICU54_IPK_VERSION)_$(TARGET_ARCH).ipk
ICU54_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/icu54

.PHONY: icu54-source icu54-unpack icu54 icu54-stage icu54-ipk icu54-clean icu54-dirclean icu54-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ICU54_SOURCE):
	$(WGET) -P $(@D) $(ICU54_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
icu54-source: $(DL_DIR)/$(ICU54_SOURCE) $(ICU54_PATCHES)

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
$(ICU54_BUILD_DIR)/.configured: $(DL_DIR)/$(ICU54_SOURCE) $(ICU54_PATCHES) make/icu54.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ICU54_DIR) $(@D)
	mkdir -p $(@D)
	$(ICU54_UNZIP) $(DL_DIR)/$(ICU54_SOURCE) | tar -C $(@D) -xvf - --strip 1
	if test -n "$(ICU54_PATCHES)" ; \
		then cat $(ICU54_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ICU54_DIR) -p0 ; \
	fi
	(cd $(@D)/source; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(TARGET_CFLAGS) $(ICU54_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ICU54_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-library-suffix=54 \
		--includedir=/opt/include/icu54 \
		--disable-tools \
		--disable-tests \
		--disable-extras \
		--disable-samples \
		--disable-nls \
		--disable-static \
		--with-cross-build=$(ICU54_HOST_BUILD_DIR) \
	)

#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

icu54-unpack: $(ICU54_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ICU54_BUILD_DIR)/.built: $(ICU54_HOST_BUILD_DIR)/.built $(ICU54_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/source
	touch $@

#
# This is the build convenience target.
#
icu: $(ICU54_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ICU54_BUILD_DIR)/.staged: $(ICU54_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/source bindir=/opt/bin/icu54 libdir=/opt/lib/icu54 DESTDIR=$(STAGING_DIR) install
	mv -f $(STAGING_LIB_DIR)/icu54/lib*.so* $(STAGING_LIB_DIR)
	rm -rf $(STAGING_LIB_DIR)/icu54
	cp -f $(ICU54_HOST_BUILD_DIR)/bin/pkgdata $(STAGING_DIR)/opt/bin/pkgdata54
	touch $@

icu54-stage: $(ICU54_BUILD_DIR)/.staged

$(ICU54_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(ICU54_SOURCE)
	rm -rf $(HOST_BUILD_DIR)/$(ICU54_DIR) $(@D)
	mkdir -p $(@D)
	$(ICU54_UNZIP) $(DL_DIR)/$(ICU54_SOURCE) | tar -C $(@D) -xvf - --strip 1
	mv $(@D)/source/* $(@D)/
	(cd $(@D); \
		./configure \
		--disable-threads \
	)

	$(MAKE) -C $(@D)
	touch $@

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/icu
#
$(ICU54_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: icu54" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ICU54_PRIORITY)" >>$@
	@echo "Section: $(ICU54_SECTION)" >>$@
	@echo "Version: $(ICU54_VERSION)-$(ICU54_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ICU54_MAINTAINER)" >>$@
	@echo "Source: $(ICU54_SITE)/$(ICU54_SOURCE)" >>$@
	@echo "Description: $(ICU54_DESCRIPTION)" >>$@
	@echo "Depends: $(ICU54_DEPENDS)" >>$@
	@echo "Suggests: $(ICU54_SUGGESTS)" >>$@
	@echo "Conflicts: $(ICU54_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ICU54_IPK_DIR)/opt/sbin or $(ICU54_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ICU54_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ICU54_IPK_DIR)/opt/etc/icu/...
# Documentation files should be installed in $(ICU54_IPK_DIR)/opt/doc/icu/...
# Daemon startup scripts should be installed in $(ICU54_IPK_DIR)/opt/etc/init.d/S??icu
#
# You may need to patch your application to make it use these locations.
#
$(ICU54_IPK): $(ICU54_BUILD_DIR)/.built
	rm -rf $(ICU54_IPK_DIR) $(BUILD_DIR)/icu_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ICU54_BUILD_DIR)/source bindir=/opt/bin/icu54 DESTDIR=$(ICU54_IPK_DIR) install
	$(STRIP_COMMAND) \
		`ls $(ICU54_IPK_DIR)/opt/bin/* | grep -v icu-config` \
		$(ICU54_IPK_DIR)/opt/lib/lib*.so.*.*
	rm -rf $(ICU54_IPK_DIR)/opt/sbin $(ICU54_IPK_DIR)/opt/share/man $(ICU54_IPK_DIR)/opt/lib/pkgconfig
	mv -f $(ICU54_IPK_DIR)/opt/bin/icu54/icu-config $(ICU54_IPK_DIR)/opt/bin/icu54-config
	rm -rf $(ICU54_IPK_DIR)/opt/bin/icu54
#	install -d $(ICU54_IPK_DIR)/opt/etc/
#	install -m 644 $(ICU54_SOURCE_DIR)/icu.conf $(ICU54_IPK_DIR)/opt/etc/icu.conf
#	install -d $(ICU54_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ICU54_SOURCE_DIR)/rc.icu $(ICU54_IPK_DIR)/opt/etc/init.d/SXXicu
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ICU54_IPK_DIR)/opt/etc/init.d/SXXicu
	$(MAKE) $(ICU54_IPK_DIR)/CONTROL/control
#	install -m 755 $(ICU54_SOURCE_DIR)/postinst $(ICU54_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ICU54_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ICU54_SOURCE_DIR)/prerm $(ICU54_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ICU54_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(ICU54_IPK_DIR)/CONTROL/postinst $(ICU54_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(ICU54_CONFFILES) | sed -e 's/ /\n/g' > $(ICU54_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ICU54_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
icu54-ipk: $(ICU54_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
icu54-clean:
	rm -f $(ICU54_BUILD_DIR)/.built
	-$(MAKE) -C $(ICU54_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
icu54-dirclean:
	rm -rf $(BUILD_DIR)/$(ICU54_DIR) $(ICU54_BUILD_DIR) $(ICU54_HOST_BUILD_DIR) $(ICU54_IPK_DIR) $(ICU54_IPK)
#
#
# Some sanity check for the package.
#
icu54-check: $(ICU54_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
