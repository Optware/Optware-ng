###########################################################
#
# xerces-c
#
###########################################################

# You must replace "xerces-c" and "XERCES-C" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# XERCES-C_VERSION, XERCES-C_SITE and XERCES-C_SOURCE define
# the upstream location of the source code for the package.
# XERCES-C_DIR is the directory which is created when the source
# archive is unpacked.
# XERCES-C_UNZIP is the command used to unzip the source.
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
XERCES-C_SITE=http://www.apache.org/dist/xerces/c/3/sources
XERCES-C_VERSION=3.0.1
XERCES-C_SOURCE=xerces-c-$(XERCES-C_VERSION).tar.gz
XERCES-C_DIR=xerces-c-$(XERCES-C_VERSION)
XERCES-C_UNZIP=zcat
XERCES-C_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XERCES-C_DESCRIPTION=Xerces-C++ is a validating XML parser written in a portable subset of C++.
XERCES-C_SECTION=net
XERCES-C_PRIORITY=optional
XERCES-C_DEPENDS=libcurl, icu
XERCES-C_SUGGESTS=
XERCES-C_CONFLICTS=

#
# XERCES-C_IPK_VERSION should be incremented when the ipk changes.
#
XERCES-C_IPK_VERSION=1

#
# XERCES-C_CONFFILES should be a list of user-editable files
#XERCES-C_CONFFILES=/opt/etc/xerces-c.conf /opt/etc/init.d/SXXxerces-c

#
# XERCES-C_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XERCES-C_PATCHES=$(XERCES-C_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XERCES-C_CPPFLAGS=
XERCES-C_LDFLAGS=

#
# XERCES-C_BUILD_DIR is the directory in which the build is done.
# XERCES-C_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XERCES-C_IPK_DIR is the directory in which the ipk is built.
# XERCES-C_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XERCES-C_BUILD_DIR=$(BUILD_DIR)/xerces-c
XERCES-C_SOURCE_DIR=$(SOURCE_DIR)/xerces-c
XERCES-C_IPK_DIR=$(BUILD_DIR)/xerces-c-$(XERCES-C_VERSION)-ipk
XERCES-C_IPK=$(BUILD_DIR)/xerces-c_$(XERCES-C_VERSION)-$(XERCES-C_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: xerces-c-source xerces-c-unpack xerces-c xerces-c-stage xerces-c-ipk xerces-c-clean xerces-c-dirclean xerces-c-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XERCES-C_SOURCE):
	$(WGET) -P $(@D) $(XERCES-C_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xerces-c-source: $(DL_DIR)/$(XERCES-C_SOURCE) $(XERCES-C_PATCHES)

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
$(XERCES-C_BUILD_DIR)/.configured: $(DL_DIR)/$(XERCES-C_SOURCE) $(XERCES-C_PATCHES) make/xerces-c.mk
	$(MAKE) libcurl-stage icu-stage
	rm -rf $(BUILD_DIR)/$(XERCES-C_DIR) $(@D)
	$(XERCES-C_UNZIP) $(DL_DIR)/$(XERCES-C_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(XERCES-C_PATCHES)" ; \
		then cat $(XERCES-C_PATCHES) | \
		patch -d $(BUILD_DIR)/$(XERCES-C_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(XERCES-C_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XERCES-C_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XERCES-C_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XERCES-C_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--disable-pretty-make \
		--with-curl=$(STAGING_DIR)/opt \
		--with-icu=$(STAGING_DIR)/opt \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

xerces-c-unpack: $(XERCES-C_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XERCES-C_BUILD_DIR)/.built: $(XERCES-C_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xerces-c: $(XERCES-C_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XERCES-C_BUILD_DIR)/.staged: $(XERCES-C_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

xerces-c-stage: $(XERCES-C_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/xerces-c
#
$(XERCES-C_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: xerces-c" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XERCES-C_PRIORITY)" >>$@
	@echo "Section: $(XERCES-C_SECTION)" >>$@
	@echo "Version: $(XERCES-C_VERSION)-$(XERCES-C_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XERCES-C_MAINTAINER)" >>$@
	@echo "Source: $(XERCES-C_SITE)/$(XERCES-C_SOURCE)" >>$@
	@echo "Description: $(XERCES-C_DESCRIPTION)" >>$@
	@echo "Depends: $(XERCES-C_DEPENDS)" >>$@
	@echo "Suggests: $(XERCES-C_SUGGESTS)" >>$@
	@echo "Conflicts: $(XERCES-C_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(XERCES-C_IPK_DIR)/opt/sbin or $(XERCES-C_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XERCES-C_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XERCES-C_IPK_DIR)/opt/etc/xerces-c/...
# Documentation files should be installed in $(XERCES-C_IPK_DIR)/opt/doc/xerces-c/...
# Daemon startup scripts should be installed in $(XERCES-C_IPK_DIR)/opt/etc/init.d/S??xerces-c
#
# You may need to patch your application to make it use these locations.
#
$(XERCES-C_IPK): $(XERCES-C_BUILD_DIR)/.built
	rm -rf $(XERCES-C_IPK_DIR) $(BUILD_DIR)/xerces-c_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XERCES-C_BUILD_DIR) DESTDIR=$(XERCES-C_IPK_DIR) install-strip
#	install -d $(XERCES-C_IPK_DIR)/opt/etc/
#	install -m 644 $(XERCES-C_SOURCE_DIR)/xerces-c.conf $(XERCES-C_IPK_DIR)/opt/etc/xerces-c.conf
#	install -d $(XERCES-C_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(XERCES-C_SOURCE_DIR)/rc.xerces-c $(XERCES-C_IPK_DIR)/opt/etc/init.d/SXXxerces-c
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XERCES-C_IPK_DIR)/opt/etc/init.d/SXXxerces-c
	$(MAKE) $(XERCES-C_IPK_DIR)/CONTROL/control
#	install -m 755 $(XERCES-C_SOURCE_DIR)/postinst $(XERCES-C_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XERCES-C_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(XERCES-C_SOURCE_DIR)/prerm $(XERCES-C_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XERCES-C_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(XERCES-C_IPK_DIR)/CONTROL/postinst $(XERCES-C_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(XERCES-C_CONFFILES) | sed -e 's/ /\n/g' > $(XERCES-C_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XERCES-C_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xerces-c-ipk: $(XERCES-C_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xerces-c-clean:
	rm -f $(XERCES-C_BUILD_DIR)/.built
	-$(MAKE) -C $(XERCES-C_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xerces-c-dirclean:
	rm -rf $(BUILD_DIR)/$(XERCES-C_DIR) $(XERCES-C_BUILD_DIR) $(XERCES-C_IPK_DIR) $(XERCES-C_IPK)
#
#
# Some sanity check for the package.
#
xerces-c-check: $(XERCES-C_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
