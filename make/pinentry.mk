###########################################################
#
# pinentry
#
###########################################################
#
# PINENTRY_VERSION, PINENTRY_SITE and PINENTRY_SOURCE define
# the upstream location of the source code for the package.
# PINENTRY_DIR is the directory which is created when the source
# archive is unpacked.
# PINENTRY_UNZIP is the command used to unzip the source.
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
PINENTRY_SITE=ftp://ftp.gnupg.org/gcrypt/pinentry
PINENTRY_VERSION=0.7.5
PINENTRY_SOURCE=pinentry-$(PINENTRY_VERSION).tar.gz
PINENTRY_DIR=pinentry-$(PINENTRY_VERSION)
PINENTRY_UNZIP=zcat
PINENTRY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PINENTRY_DESCRIPTION=Describe pinentry here.
PINENTRY_SECTION=utility
PINENTRY_PRIORITY=optional
PINENTRY_DEPENDS=ncurses
ifneq (, $(filter libiconv, $(PACKAGES)))
PINENTRY_DEPENDS += , libiconv
endif
PINENTRY_SUGGESTS=
PINENTRY_CONFLICTS=

#
# PINENTRY_IPK_VERSION should be incremented when the ipk changes.
#
PINENTRY_IPK_VERSION=2

#
# PINENTRY_CONFFILES should be a list of user-editable files
#PINENTRY_CONFFILES=/opt/etc/pinentry.conf /opt/etc/init.d/SXXpinentry

#
# PINENTRY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PINENTRY_PATCHES=$(PINENTRY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PINENTRY_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
PINENTRY_LDFLAGS=

#
# PINENTRY_BUILD_DIR is the directory in which the build is done.
# PINENTRY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PINENTRY_IPK_DIR is the directory in which the ipk is built.
# PINENTRY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PINENTRY_BUILD_DIR=$(BUILD_DIR)/pinentry
PINENTRY_SOURCE_DIR=$(SOURCE_DIR)/pinentry
PINENTRY_IPK_DIR=$(BUILD_DIR)/pinentry-$(PINENTRY_VERSION)-ipk
PINENTRY_IPK=$(BUILD_DIR)/pinentry_$(PINENTRY_VERSION)-$(PINENTRY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pinentry-source pinentry-unpack pinentry pinentry-stage pinentry-ipk pinentry-clean pinentry-dirclean pinentry-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PINENTRY_SOURCE):
	$(WGET) -P $(@D) $(PINENTRY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pinentry-source: $(DL_DIR)/$(PINENTRY_SOURCE) $(PINENTRY_PATCHES)

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
$(PINENTRY_BUILD_DIR)/.configured: $(DL_DIR)/$(PINENTRY_SOURCE) $(PINENTRY_PATCHES) make/pinentry.mk
	$(MAKE) ncurses-stage
ifneq (, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(PINENTRY_DIR) $(@D)
	$(PINENTRY_UNZIP) $(DL_DIR)/$(PINENTRY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PINENTRY_PATCHES)" ; \
		then cat $(PINENTRY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PINENTRY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PINENTRY_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PINENTRY_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PINENTRY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PINENTRY_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-pinentry-curses \
		--disable-pinentry-gtk \
		--disable-pinentry-gtk2 \
		--disable-pinentry-qt \
		--without-x \
		--with-ncurses-include-dir=$(STAGING_INCLUDE_DIR)/ncurses \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

pinentry-unpack: $(PINENTRY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PINENTRY_BUILD_DIR)/.built: $(PINENTRY_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
pinentry: $(PINENTRY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PINENTRY_BUILD_DIR)/.staged: $(PINENTRY_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

pinentry-stage: $(PINENTRY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pinentry
#
$(PINENTRY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: pinentry" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PINENTRY_PRIORITY)" >>$@
	@echo "Section: $(PINENTRY_SECTION)" >>$@
	@echo "Version: $(PINENTRY_VERSION)-$(PINENTRY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PINENTRY_MAINTAINER)" >>$@
	@echo "Source: $(PINENTRY_SITE)/$(PINENTRY_SOURCE)" >>$@
	@echo "Description: $(PINENTRY_DESCRIPTION)" >>$@
	@echo "Depends: $(PINENTRY_DEPENDS)" >>$@
	@echo "Suggests: $(PINENTRY_SUGGESTS)" >>$@
	@echo "Conflicts: $(PINENTRY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PINENTRY_IPK_DIR)/opt/sbin or $(PINENTRY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PINENTRY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PINENTRY_IPK_DIR)/opt/etc/pinentry/...
# Documentation files should be installed in $(PINENTRY_IPK_DIR)/opt/doc/pinentry/...
# Daemon startup scripts should be installed in $(PINENTRY_IPK_DIR)/opt/etc/init.d/S??pinentry
#
# You may need to patch your application to make it use these locations.
#
$(PINENTRY_IPK): $(PINENTRY_BUILD_DIR)/.built
	rm -rf $(PINENTRY_IPK_DIR) $(BUILD_DIR)/pinentry_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PINENTRY_BUILD_DIR) DESTDIR=$(PINENTRY_IPK_DIR) install-strip
#	install -d $(PINENTRY_IPK_DIR)/opt/etc/
#	install -m 644 $(PINENTRY_SOURCE_DIR)/pinentry.conf $(PINENTRY_IPK_DIR)/opt/etc/pinentry.conf
#	install -d $(PINENTRY_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PINENTRY_SOURCE_DIR)/rc.pinentry $(PINENTRY_IPK_DIR)/opt/etc/init.d/SXXpinentry
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PINENTRY_IPK_DIR)/opt/etc/init.d/SXXpinentry
	$(MAKE) $(PINENTRY_IPK_DIR)/CONTROL/control
#	install -m 755 $(PINENTRY_SOURCE_DIR)/postinst $(PINENTRY_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PINENTRY_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PINENTRY_SOURCE_DIR)/prerm $(PINENTRY_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PINENTRY_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(PINENTRY_IPK_DIR)/CONTROL/postinst $(PINENTRY_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(PINENTRY_CONFFILES) | sed -e 's/ /\n/g' > $(PINENTRY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PINENTRY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pinentry-ipk: $(PINENTRY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pinentry-clean:
	rm -f $(PINENTRY_BUILD_DIR)/.built
	-$(MAKE) -C $(PINENTRY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pinentry-dirclean:
	rm -rf $(BUILD_DIR)/$(PINENTRY_DIR) $(PINENTRY_BUILD_DIR) $(PINENTRY_IPK_DIR) $(PINENTRY_IPK)
#
#
# Some sanity check for the package.
#
pinentry-check: $(PINENTRY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PINENTRY_IPK)
