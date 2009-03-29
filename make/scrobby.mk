###########################################################
#
# scrobby
#
###########################################################

# You must replace "scrobby" and "SCROBBY" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SCROBBY_VERSION, SCROBBY_SITE and SCROBBY_SOURCE define
# the upstream location of the source code for the package.
# SCROBBY_DIR is the directory which is created when the source
# archive is unpacked.
# SCROBBY_UNZIP is the command used to unzip the source.
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
SCROBBY_SITE=http://unkart.ovh.org/scrobby
SCROBBY_VERSION=0.1
SCROBBY_SOURCE=scrobby-$(SCROBBY_VERSION).tar.bz2
SCROBBY_DIR=scrobby-$(SCROBBY_VERSION)
SCROBBY_UNZIP=bzcat
SCROBBY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SCROBBY_DESCRIPTION=an audioscrobbler mpd client written in C++
SCROBBY_SECTION=multimedia
SCROBBY_PRIORITY=optional
SCROBBY_DEPENDS=openssl, libcurl, libstdc++
#SCROBBY_SUGGESTS=
#SCROBBY_CONFLICTS=

#
# SCROBBY_IPK_VERSION should be incremented when the ipk changes.
#
SCROBBY_IPK_VERSION=1

#
# SCROBBY_CONFFILES should be a list of user-editable files
#SCROBBY_CONFFILES=/opt/etc/scrobby.conf /opt/etc/init.d/SXXscrobby

#
# SCROBBY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SCROBBY_PATCHES=$(SCROBBY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SCROBBY_CPPFLAGS=
SCROBBY_LDFLAGS=

#
# SCROBBY_BUILD_DIR is the directory in which the build is done.
# SCROBBY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SCROBBY_IPK_DIR is the directory in which the ipk is built.
# SCROBBY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SCROBBY_BUILD_DIR=$(BUILD_DIR)/scrobby
SCROBBY_SOURCE_DIR=$(SOURCE_DIR)/scrobby
SCROBBY_IPK_DIR=$(BUILD_DIR)/scrobby-$(SCROBBY_VERSION)-ipk
SCROBBY_IPK=$(BUILD_DIR)/scrobby_$(SCROBBY_VERSION)-$(SCROBBY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: scrobby-source scrobby-unpack scrobby scrobby-stage scrobby-ipk scrobby-clean scrobby-dirclean scrobby-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SCROBBY_SOURCE):
	$(WGET) -P $(@D) $(SCROBBY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
scrobby-source: $(DL_DIR)/$(SCROBBY_SOURCE) $(SCROBBY_PATCHES)

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
$(SCROBBY_BUILD_DIR)/.configured: $(DL_DIR)/$(SCROBBY_SOURCE) $(SCROBBY_PATCHES) make/scrobby.mk
	$(MAKE) openssl-stage libcurl-stage libstdc++-stage
	rm -rf $(BUILD_DIR)/$(SCROBBY_DIR) $(@D)
	$(SCROBBY_UNZIP) $(DL_DIR)/$(SCROBBY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SCROBBY_PATCHES)" ; \
		then cat $(SCROBBY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SCROBBY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SCROBBY_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SCROBBY_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SCROBBY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SCROBBY_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		CURL_CONFIG="$(STAGING_DIR)/bin/curl-config" \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

scrobby-unpack: $(SCROBBY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SCROBBY_BUILD_DIR)/.built: $(SCROBBY_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
scrobby: $(SCROBBY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SCROBBY_BUILD_DIR)/.staged: $(SCROBBY_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

scrobby-stage: $(SCROBBY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/scrobby
#
$(SCROBBY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: scrobby" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SCROBBY_PRIORITY)" >>$@
	@echo "Section: $(SCROBBY_SECTION)" >>$@
	@echo "Version: $(SCROBBY_VERSION)-$(SCROBBY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SCROBBY_MAINTAINER)" >>$@
	@echo "Source: $(SCROBBY_SITE)/$(SCROBBY_SOURCE)" >>$@
	@echo "Description: $(SCROBBY_DESCRIPTION)" >>$@
	@echo "Depends: $(SCROBBY_DEPENDS)" >>$@
	@echo "Suggests: $(SCROBBY_SUGGESTS)" >>$@
	@echo "Conflicts: $(SCROBBY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SCROBBY_IPK_DIR)/opt/sbin or $(SCROBBY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SCROBBY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SCROBBY_IPK_DIR)/opt/etc/scrobby/...
# Documentation files should be installed in $(SCROBBY_IPK_DIR)/opt/doc/scrobby/...
# Daemon startup scripts should be installed in $(SCROBBY_IPK_DIR)/opt/etc/init.d/S??scrobby
#
# You may need to patch your application to make it use these locations.
#
$(SCROBBY_IPK): $(SCROBBY_BUILD_DIR)/.built
	rm -rf $(SCROBBY_IPK_DIR) $(BUILD_DIR)/scrobby_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SCROBBY_BUILD_DIR) DESTDIR=$(SCROBBY_IPK_DIR) install-strip
#	install -d $(SCROBBY_IPK_DIR)/opt/etc/
#	install -m 644 $(SCROBBY_SOURCE_DIR)/scrobby.conf $(SCROBBY_IPK_DIR)/opt/etc/scrobby.conf
#	install -d $(SCROBBY_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SCROBBY_SOURCE_DIR)/rc.scrobby $(SCROBBY_IPK_DIR)/opt/etc/init.d/SXXscrobby
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SCROBBY_IPK_DIR)/opt/etc/init.d/SXXscrobby
	$(MAKE) $(SCROBBY_IPK_DIR)/CONTROL/control
#	install -m 755 $(SCROBBY_SOURCE_DIR)/postinst $(SCROBBY_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SCROBBY_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SCROBBY_SOURCE_DIR)/prerm $(SCROBBY_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SCROBBY_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SCROBBY_IPK_DIR)/CONTROL/postinst $(SCROBBY_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SCROBBY_CONFFILES) | sed -e 's/ /\n/g' > $(SCROBBY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SCROBBY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
scrobby-ipk: $(SCROBBY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
scrobby-clean:
	rm -f $(SCROBBY_BUILD_DIR)/.built
	-$(MAKE) -C $(SCROBBY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
scrobby-dirclean:
	rm -rf $(BUILD_DIR)/$(SCROBBY_DIR) $(SCROBBY_BUILD_DIR) $(SCROBBY_IPK_DIR) $(SCROBBY_IPK)
#
#
# Some sanity check for the package.
#
scrobby-check: $(SCROBBY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
