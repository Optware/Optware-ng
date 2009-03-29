###########################################################
#
# ices0
#
###########################################################

# You must replace "ices" and "ICES" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ICES0_VERSION, ICES0_SITE and ICES0_SOURCE define
# the upstream location of the source code for the package.
# ICES0_DIR is the directory which is created when the source
# archive is unpacked.
# ICES0_UNZIP is the command used to unzip the source.
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
ICES0_SITE=http://downloads.us.xiph.org/releases/ices
ICES0_VERSION=0.4
ICES0_SOURCE=ices-$(ICES0_VERSION).tar.gz
ICES0_DIR=ices-$(ICES0_VERSION)
ICES0_UNZIP=zcat
ICES0_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ICES0_DESCRIPTION=source client for broadcasting in MP3 format to an icecast2 server
ICES0_SECTION=multimedia
ICES0_PRIORITY=optional
ICES0_DEPENDS=libshout, libxml2
#ICES0_SUGGESTS=
#ICES0_CONFLICTS=

#
# ICES0_IPK_VERSION should be incremented when the ipk changes.
#
ICES0_IPK_VERSION=1

#
# ICES0_CONFFILES should be a list of user-editable files
#ICES0_CONFFILES=/opt/etc/ices.conf /opt/etc/init.d/SXXices

#
# ICES0_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ICES0_PATCHES=$(ICES0_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ICES0_CPPFLAGS=
ICES0_LDFLAGS=

#
# ICES0_BUILD_DIR is the directory in which the build is done.
# ICES0_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ICES0_IPK_DIR is the directory in which the ipk is built.
# ICES0_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ICES0_BUILD_DIR=$(BUILD_DIR)/ices0
ICES0_SOURCE_DIR=$(SOURCE_DIR)/ices0
ICES0_IPK_DIR=$(BUILD_DIR)/ices0-$(ICES0_VERSION)-ipk
ICES0_IPK=$(BUILD_DIR)/ices0_$(ICES0_VERSION)-$(ICES0_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ices0-source ices0-unpack ices0 ices0-stage ices0-ipk ices0-clean ices0-dirclean ices0-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ICES0_SOURCE):
	$(WGET) -P $(@D) $(ICES0_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ices0-source: $(DL_DIR)/$(ICES0_SOURCE) $(ICES0_PATCHES)

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
$(ICES0_BUILD_DIR)/.configured: $(DL_DIR)/$(ICES0_SOURCE) $(ICES0_PATCHES) make/ices0.mk
	$(MAKE) libshout-stage libxml2-stage
	rm -rf $(BUILD_DIR)/$(ICES0_DIR) $(@D)
	$(ICES0_UNZIP) $(DL_DIR)/$(ICES0_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ICES0_PATCHES)" ; \
		then cat $(ICES0_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ICES0_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ICES0_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ICES0_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ICES0_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ICES0_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PATH="$(STAGING_PREFIX)/bin:$$PATH" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-faad \
		--without-flac \
		--without-lame \
		--without-vorbis \
		--without-perl \
		--without-python \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

ices0-unpack: $(ICES0_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ICES0_BUILD_DIR)/.built: $(ICES0_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ices0: $(ICES0_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ICES0_BUILD_DIR)/.staged: $(ICES0_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ices0-stage: $(ICES0_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ices
#
$(ICES0_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ices0" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ICES0_PRIORITY)" >>$@
	@echo "Section: $(ICES0_SECTION)" >>$@
	@echo "Version: $(ICES0_VERSION)-$(ICES0_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ICES0_MAINTAINER)" >>$@
	@echo "Source: $(ICES0_SITE)/$(ICES0_SOURCE)" >>$@
	@echo "Description: $(ICES0_DESCRIPTION)" >>$@
	@echo "Depends: $(ICES0_DEPENDS)" >>$@
	@echo "Suggests: $(ICES0_SUGGESTS)" >>$@
	@echo "Conflicts: $(ICES0_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ICES0_IPK_DIR)/opt/sbin or $(ICES0_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ICES0_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ICES0_IPK_DIR)/opt/etc/ices/...
# Documentation files should be installed in $(ICES0_IPK_DIR)/opt/doc/ices/...
# Daemon startup scripts should be installed in $(ICES0_IPK_DIR)/opt/etc/init.d/S??ices
#
# You may need to patch your application to make it use these locations.
#
$(ICES0_IPK): $(ICES0_BUILD_DIR)/.built
	rm -rf $(ICES0_IPK_DIR) $(BUILD_DIR)/ices_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ICES0_BUILD_DIR) DESTDIR=$(ICES0_IPK_DIR) install-strip
#	install -d $(ICES0_IPK_DIR)/opt/etc/
#	install -m 644 $(ICES0_SOURCE_DIR)/ices.conf $(ICES0_IPK_DIR)/opt/etc/ices.conf
#	install -d $(ICES0_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ICES0_SOURCE_DIR)/rc.ices $(ICES0_IPK_DIR)/opt/etc/init.d/SXXices
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ICES0_IPK_DIR)/opt/etc/init.d/SXXices
	$(MAKE) $(ICES0_IPK_DIR)/CONTROL/control
#	install -m 755 $(ICES0_SOURCE_DIR)/postinst $(ICES0_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ICES0_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ICES0_SOURCE_DIR)/prerm $(ICES0_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ICES0_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(ICES0_IPK_DIR)/CONTROL/postinst $(ICES0_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(ICES0_CONFFILES) | sed -e 's/ /\n/g' > $(ICES0_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ICES0_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ices0-ipk: $(ICES0_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ices0-clean:
	rm -f $(ICES0_BUILD_DIR)/.built
	-$(MAKE) -C $(ICES0_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ices0-dirclean:
	rm -rf $(BUILD_DIR)/$(ICES0_DIR) $(ICES0_BUILD_DIR) $(ICES0_IPK_DIR) $(ICES0_IPK)
#
#
# Some sanity check for the package.
#
ices0-check: $(ICES0_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
