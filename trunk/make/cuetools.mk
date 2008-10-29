###########################################################
#
# cuetools
#
###########################################################
#
# CUETOOLS_VERSION, CUETOOLS_SITE and CUETOOLS_SOURCE define
# the upstream location of the source code for the package.
# CUETOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# CUETOOLS_UNZIP is the command used to unzip the source.
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
CUETOOLS_SITE=http://download.berlios.de/cuetools
CUETOOLS_VERSION=1.3.1
CUETOOLS_SOURCE=cuetools-$(CUETOOLS_VERSION).tar.gz
CUETOOLS_DIR=cuetools-$(CUETOOLS_VERSION)
CUETOOLS_UNZIP=zcat
CUETOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CUETOOLS_DESCRIPTION=cuetools is a set of utilities for working with cue files and toc files.
CUETOOLS_SECTION=utils
CUETOOLS_PRIORITY=optional
CUETOOLS_DEPENDS=
CUETOOLS_SUGGESTS=
CUETOOLS_CONFLICTS=

#
# CUETOOLS_IPK_VERSION should be incremented when the ipk changes.
#
CUETOOLS_IPK_VERSION=1

#
# CUETOOLS_CONFFILES should be a list of user-editable files
#CUETOOLS_CONFFILES=/opt/etc/cuetools.conf /opt/etc/init.d/SXXcuetools

#
# CUETOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CUETOOLS_PATCHES=$(CUETOOLS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CUETOOLS_CPPFLAGS=
CUETOOLS_LDFLAGS=

#
# CUETOOLS_BUILD_DIR is the directory in which the build is done.
# CUETOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CUETOOLS_IPK_DIR is the directory in which the ipk is built.
# CUETOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CUETOOLS_BUILD_DIR=$(BUILD_DIR)/cuetools
CUETOOLS_SOURCE_DIR=$(SOURCE_DIR)/cuetools
CUETOOLS_IPK_DIR=$(BUILD_DIR)/cuetools-$(CUETOOLS_VERSION)-ipk
CUETOOLS_IPK=$(BUILD_DIR)/cuetools_$(CUETOOLS_VERSION)-$(CUETOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cuetools-source cuetools-unpack cuetools cuetools-stage cuetools-ipk cuetools-clean cuetools-dirclean cuetools-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CUETOOLS_SOURCE):
	$(WGET) -P $(@D) $(CUETOOLS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cuetools-source: $(DL_DIR)/$(CUETOOLS_SOURCE) $(CUETOOLS_PATCHES)

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
$(CUETOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(CUETOOLS_SOURCE) $(CUETOOLS_PATCHES) make/cuetools.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(CUETOOLS_DIR) $(@D)
	$(CUETOOLS_UNZIP) $(DL_DIR)/$(CUETOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CUETOOLS_PATCHES)" ; \
		then cat $(CUETOOLS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CUETOOLS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CUETOOLS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CUETOOLS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CUETOOLS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CUETOOLS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

cuetools-unpack: $(CUETOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CUETOOLS_BUILD_DIR)/.built: $(CUETOOLS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
cuetools: $(CUETOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CUETOOLS_BUILD_DIR)/.staged: $(CUETOOLS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

cuetools-stage: $(CUETOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cuetools
#
$(CUETOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: cuetools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUETOOLS_PRIORITY)" >>$@
	@echo "Section: $(CUETOOLS_SECTION)" >>$@
	@echo "Version: $(CUETOOLS_VERSION)-$(CUETOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUETOOLS_MAINTAINER)" >>$@
	@echo "Source: $(CUETOOLS_SITE)/$(CUETOOLS_SOURCE)" >>$@
	@echo "Description: $(CUETOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(CUETOOLS_DEPENDS)" >>$@
	@echo "Suggests: $(CUETOOLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(CUETOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CUETOOLS_IPK_DIR)/opt/sbin or $(CUETOOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CUETOOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CUETOOLS_IPK_DIR)/opt/etc/cuetools/...
# Documentation files should be installed in $(CUETOOLS_IPK_DIR)/opt/doc/cuetools/...
# Daemon startup scripts should be installed in $(CUETOOLS_IPK_DIR)/opt/etc/init.d/S??cuetools
#
# You may need to patch your application to make it use these locations.
#
$(CUETOOLS_IPK): $(CUETOOLS_BUILD_DIR)/.built
	rm -rf $(CUETOOLS_IPK_DIR) $(BUILD_DIR)/cuetools_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CUETOOLS_BUILD_DIR) DESTDIR=$(CUETOOLS_IPK_DIR) install-strip
#	install -d $(CUETOOLS_IPK_DIR)/opt/etc/
#	install -m 644 $(CUETOOLS_SOURCE_DIR)/cuetools.conf $(CUETOOLS_IPK_DIR)/opt/etc/cuetools.conf
#	install -d $(CUETOOLS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CUETOOLS_SOURCE_DIR)/rc.cuetools $(CUETOOLS_IPK_DIR)/opt/etc/init.d/SXXcuetools
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CUETOOLS_IPK_DIR)/opt/etc/init.d/SXXcuetools
	$(MAKE) $(CUETOOLS_IPK_DIR)/CONTROL/control
#	install -m 755 $(CUETOOLS_SOURCE_DIR)/postinst $(CUETOOLS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CUETOOLS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CUETOOLS_SOURCE_DIR)/prerm $(CUETOOLS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CUETOOLS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(CUETOOLS_IPK_DIR)/CONTROL/postinst $(CUETOOLS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(CUETOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(CUETOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUETOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cuetools-ipk: $(CUETOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cuetools-clean:
	rm -f $(CUETOOLS_BUILD_DIR)/.built
	-$(MAKE) -C $(CUETOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cuetools-dirclean:
	rm -rf $(BUILD_DIR)/$(CUETOOLS_DIR) $(CUETOOLS_BUILD_DIR) $(CUETOOLS_IPK_DIR) $(CUETOOLS_IPK)
#
#
# Some sanity check for the package.
#
cuetools-check: $(CUETOOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CUETOOLS_IPK)
