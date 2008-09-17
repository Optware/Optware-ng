###########################################################
#
# fribidi
#
###########################################################
#
# FRIBIDI_VERSION, FRIBIDI_SITE and FRIBIDI_SOURCE define
# the upstream location of the source code for the package.
# FRIBIDI_DIR is the directory which is created when the source
# archive is unpacked.
# FRIBIDI_UNZIP is the command used to unzip the source.
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
FRIBIDI_SITE=http://fribidi.org/download
FRIBIDI_VERSION=0.10.9
FRIBIDI_SOURCE=fribidi-$(FRIBIDI_VERSION).tar.gz
FRIBIDI_DIR=fribidi-$(FRIBIDI_VERSION)
FRIBIDI_UNZIP=zcat
FRIBIDI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FRIBIDI_DESCRIPTION=An implementation of the Unicode Bidirectional Algorithm (bidi).
FRIBIDI_SECTION=lib
FRIBIDI_PRIORITY=optional
FRIBIDI_DEPENDS=
FRIBIDI_SUGGESTS=
FRIBIDI_CONFLICTS=

#
# FRIBIDI_IPK_VERSION should be incremented when the ipk changes.
#
FRIBIDI_IPK_VERSION=1

#
# FRIBIDI_CONFFILES should be a list of user-editable files
#FRIBIDI_CONFFILES=/opt/etc/fribidi.conf /opt/etc/init.d/SXXfribidi

#
# FRIBIDI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FRIBIDI_PATCHES=$(FRIBIDI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FRIBIDI_CPPFLAGS=
FRIBIDI_LDFLAGS=

#
# FRIBIDI_BUILD_DIR is the directory in which the build is done.
# FRIBIDI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FRIBIDI_IPK_DIR is the directory in which the ipk is built.
# FRIBIDI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FRIBIDI_BUILD_DIR=$(BUILD_DIR)/fribidi
FRIBIDI_SOURCE_DIR=$(SOURCE_DIR)/fribidi
FRIBIDI_IPK_DIR=$(BUILD_DIR)/fribidi-$(FRIBIDI_VERSION)-ipk
FRIBIDI_IPK=$(BUILD_DIR)/fribidi_$(FRIBIDI_VERSION)-$(FRIBIDI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fribidi-source fribidi-unpack fribidi fribidi-stage fribidi-ipk fribidi-clean fribidi-dirclean fribidi-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FRIBIDI_SOURCE):
	$(WGET) -P $(@D) $(FRIBIDI_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fribidi-source: $(DL_DIR)/$(FRIBIDI_SOURCE) $(FRIBIDI_PATCHES)

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
$(FRIBIDI_BUILD_DIR)/.configured: $(DL_DIR)/$(FRIBIDI_SOURCE) $(FRIBIDI_PATCHES) make/fribidi.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(FRIBIDI_DIR) $(@D)
	$(FRIBIDI_UNZIP) $(DL_DIR)/$(FRIBIDI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FRIBIDI_PATCHES)" ; \
		then cat $(FRIBIDI_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FRIBIDI_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FRIBIDI_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FRIBIDI_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FRIBIDI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FRIBIDI_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

fribidi-unpack: $(FRIBIDI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FRIBIDI_BUILD_DIR)/.built: $(FRIBIDI_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
fribidi: $(FRIBIDI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FRIBIDI_BUILD_DIR)/.staged: $(FRIBIDI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libfribidi.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/fribidi.pc
	touch $@

fribidi-stage: $(FRIBIDI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fribidi
#
$(FRIBIDI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: fribidi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FRIBIDI_PRIORITY)" >>$@
	@echo "Section: $(FRIBIDI_SECTION)" >>$@
	@echo "Version: $(FRIBIDI_VERSION)-$(FRIBIDI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FRIBIDI_MAINTAINER)" >>$@
	@echo "Source: $(FRIBIDI_SITE)/$(FRIBIDI_SOURCE)" >>$@
	@echo "Description: $(FRIBIDI_DESCRIPTION)" >>$@
	@echo "Depends: $(FRIBIDI_DEPENDS)" >>$@
	@echo "Suggests: $(FRIBIDI_SUGGESTS)" >>$@
	@echo "Conflicts: $(FRIBIDI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FRIBIDI_IPK_DIR)/opt/sbin or $(FRIBIDI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FRIBIDI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FRIBIDI_IPK_DIR)/opt/etc/fribidi/...
# Documentation files should be installed in $(FRIBIDI_IPK_DIR)/opt/doc/fribidi/...
# Daemon startup scripts should be installed in $(FRIBIDI_IPK_DIR)/opt/etc/init.d/S??fribidi
#
# You may need to patch your application to make it use these locations.
#
$(FRIBIDI_IPK): $(FRIBIDI_BUILD_DIR)/.built
	rm -rf $(FRIBIDI_IPK_DIR) $(BUILD_DIR)/fribidi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FRIBIDI_BUILD_DIR) DESTDIR=$(FRIBIDI_IPK_DIR) install-strip
#	install -d $(FRIBIDI_IPK_DIR)/opt/etc/
#	install -m 644 $(FRIBIDI_SOURCE_DIR)/fribidi.conf $(FRIBIDI_IPK_DIR)/opt/etc/fribidi.conf
#	install -d $(FRIBIDI_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(FRIBIDI_SOURCE_DIR)/rc.fribidi $(FRIBIDI_IPK_DIR)/opt/etc/init.d/SXXfribidi
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FRIBIDI_IPK_DIR)/opt/etc/init.d/SXXfribidi
	$(MAKE) $(FRIBIDI_IPK_DIR)/CONTROL/control
#	install -m 755 $(FRIBIDI_SOURCE_DIR)/postinst $(FRIBIDI_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FRIBIDI_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(FRIBIDI_SOURCE_DIR)/prerm $(FRIBIDI_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FRIBIDI_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(FRIBIDI_IPK_DIR)/CONTROL/postinst $(FRIBIDI_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(FRIBIDI_CONFFILES) | sed -e 's/ /\n/g' > $(FRIBIDI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FRIBIDI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fribidi-ipk: $(FRIBIDI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fribidi-clean:
	rm -f $(FRIBIDI_BUILD_DIR)/.built
	-$(MAKE) -C $(FRIBIDI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fribidi-dirclean:
	rm -rf $(BUILD_DIR)/$(FRIBIDI_DIR) $(FRIBIDI_BUILD_DIR) $(FRIBIDI_IPK_DIR) $(FRIBIDI_IPK)
#
#
# Some sanity check for the package.
#
fribidi-check: $(FRIBIDI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FRIBIDI_IPK)
