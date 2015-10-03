###########################################################
#
# xdg-utils
#
###########################################################

# You must replace "xdg-utils" and "XDG-UTILS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# XDG-UTILS_VERSION, XDG-UTILS_SITE and XDG-UTILS_SOURCE define
# the upstream location of the source code for the package.
# XDG-UTILS_DIR is the directory which is created when the source
# archive is unpacked.
# XDG-UTILS_UNZIP is the command used to unzip the source.
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
XDG-UTILS_SITE=http://people.freedesktop.org/~rdieter/xdg-utils
XDG-UTILS_VERSION=1.1.0-rc3
XDG-UTILS_SOURCE=xdg-utils-$(XDG-UTILS_VERSION).tar.gz
XDG-UTILS_DIR=xdg-utils-$(XDG-UTILS_VERSION)
XDG-UTILS_UNZIP=zcat
XDG-UTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XDG-UTILS_DESCRIPTION=xdg-utils is a set of command line tools that assist applications with a variety of desktop integration tasks.
XDG-UTILS_SECTION=utils
XDG-UTILS_PRIORITY=optional
XDG-UTILS_DEPENDS=
XDG-UTILS_SUGGESTS=
XDG-UTILS_CONFLICTS=

#
# XDG-UTILS_IPK_VERSION should be incremented when the ipk changes.
#
XDG-UTILS_IPK_VERSION=1

#
# XDG-UTILS_CONFFILES should be a list of user-editable files
#XDG-UTILS_CONFFILES=$(TARGET_PREFIX)/etc/xdg-utils.conf $(TARGET_PREFIX)/etc/init.d/SXXxdg-utils

#
# XDG-UTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XDG-UTILS_PATCHES=$(XDG-UTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XDG-UTILS_CPPFLAGS=
XDG-UTILS_LDFLAGS=

#
# XDG-UTILS_BUILD_DIR is the directory in which the build is done.
# XDG-UTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XDG-UTILS_IPK_DIR is the directory in which the ipk is built.
# XDG-UTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XDG-UTILS_BUILD_DIR=$(BUILD_DIR)/xdg-utils
XDG-UTILS_SOURCE_DIR=$(SOURCE_DIR)/xdg-utils
XDG-UTILS_IPK_DIR=$(BUILD_DIR)/xdg-utils-$(XDG-UTILS_VERSION)-ipk
XDG-UTILS_IPK=$(BUILD_DIR)/xdg-utils_$(XDG-UTILS_VERSION)-$(XDG-UTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: xdg-utils-source xdg-utils-unpack xdg-utils xdg-utils-stage xdg-utils-ipk xdg-utils-clean xdg-utils-dirclean xdg-utils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XDG-UTILS_SOURCE):
	$(WGET) -P $(@D) $(XDG-UTILS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xdg-utils-source: $(DL_DIR)/$(XDG-UTILS_SOURCE) $(XDG-UTILS_PATCHES)

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
$(XDG-UTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(XDG-UTILS_SOURCE) $(XDG-UTILS_PATCHES) make/xdg-utils.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(XDG-UTILS_DIR) $(@D)
	$(XDG-UTILS_UNZIP) $(DL_DIR)/$(XDG-UTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(XDG-UTILS_PATCHES)" ; \
		then cat $(XDG-UTILS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XDG-UTILS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(XDG-UTILS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XDG-UTILS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XDG-UTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XDG-UTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--mandir=$(TARGET_PREFIX)/share/man \
		--disable-nls \
		--disable-static \
	)
	touch $@

xdg-utils-unpack: $(XDG-UTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XDG-UTILS_BUILD_DIR)/.built: $(XDG-UTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xdg-utils: $(XDG-UTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(XDG-UTILS_BUILD_DIR)/.staged: $(XDG-UTILS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

#xdg-utils-stage: $(XDG-UTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/xdg-utils
#
$(XDG-UTILS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: xdg-utils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XDG-UTILS_PRIORITY)" >>$@
	@echo "Section: $(XDG-UTILS_SECTION)" >>$@
	@echo "Version: $(XDG-UTILS_VERSION)-$(XDG-UTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XDG-UTILS_MAINTAINER)" >>$@
	@echo "Source: $(XDG-UTILS_SITE)/$(XDG-UTILS_SOURCE)" >>$@
	@echo "Description: $(XDG-UTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(XDG-UTILS_DEPENDS)" >>$@
	@echo "Suggests: $(XDG-UTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(XDG-UTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(XDG-UTILS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(XDG-UTILS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XDG-UTILS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(XDG-UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/xdg-utils/...
# Documentation files should be installed in $(XDG-UTILS_IPK_DIR)$(TARGET_PREFIX)/doc/xdg-utils/...
# Daemon startup scripts should be installed in $(XDG-UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??xdg-utils
#
# You may need to patch your application to make it use these locations.
#
$(XDG-UTILS_IPK): $(XDG-UTILS_BUILD_DIR)/.built
	rm -rf $(XDG-UTILS_IPK_DIR) $(BUILD_DIR)/xdg-utils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XDG-UTILS_BUILD_DIR) DESTDIR=$(XDG-UTILS_IPK_DIR) install
	sed -i -e 's|/usr/local/share:/usr/share|$(TARGET_PREFIX)/share|g' -e 's|\$$PATH|$(TARGET_PREFIX)/bin:$(TARGET_PREFIX)/sbin:&|g' $(XDG-UTILS_IPK_DIR)$(TARGET_PREFIX)/bin/*
#	$(INSTALL) -d $(XDG-UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(XDG-UTILS_SOURCE_DIR)/xdg-utils.conf $(XDG-UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/xdg-utils.conf
#	$(INSTALL) -d $(XDG-UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(XDG-UTILS_SOURCE_DIR)/rc.xdg-utils $(XDG-UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXxdg-utils
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XDG-UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXxdg-utils
	$(MAKE) $(XDG-UTILS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(XDG-UTILS_SOURCE_DIR)/postinst $(XDG-UTILS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XDG-UTILS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(XDG-UTILS_SOURCE_DIR)/prerm $(XDG-UTILS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XDG-UTILS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(XDG-UTILS_IPK_DIR)/CONTROL/postinst $(XDG-UTILS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(XDG-UTILS_CONFFILES) | sed -e 's/ /\n/g' > $(XDG-UTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XDG-UTILS_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(XDG-UTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xdg-utils-ipk: $(XDG-UTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xdg-utils-clean:
	rm -f $(XDG-UTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(XDG-UTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xdg-utils-dirclean:
	rm -rf $(BUILD_DIR)/$(XDG-UTILS_DIR) $(XDG-UTILS_BUILD_DIR) $(XDG-UTILS_IPK_DIR) $(XDG-UTILS_IPK)
#
#
# Some sanity check for the package.
#
xdg-utils-check: $(XDG-UTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
