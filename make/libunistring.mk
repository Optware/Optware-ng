###########################################################
#
# libunistring
#
###########################################################
#
# LIBUNISTRING_VERSION, LIBUNISTRING_SITE and LIBUNISTRING_SOURCE define
# the upstream location of the source code for the package.
# LIBUNISTRING_DIR is the directory which is created when the source
# archive is unpacked.
# LIBUNISTRING_UNZIP is the command used to unzip the source.
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
LIBUNISTRING_SITE=http://ftp.gnu.org/gnu/libunistring/
LIBUNISTRING_VERSION=0.9.3
LIBUNISTRING_SOURCE=libunistring-$(LIBUNISTRING_VERSION).tar.gz
LIBUNISTRING_DIR=libunistring-$(LIBUNISTRING_VERSION)
LIBUNISTRING_UNZIP=zcat
LIBUNISTRING_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBUNISTRING_DESCRIPTION=Describe libunistring here.
LIBUNISTRING_SECTION=libs
LIBUNISTRING_PRIORITY=optional
LIBUNISTRING_DEPENDS=
LIBUNISTRING_SUGGESTS=
LIBUNISTRING_CONFLICTS=

#
# LIBUNISTRING_IPK_VERSION should be incremented when the ipk changes.
#
LIBUNISTRING_IPK_VERSION=1

#
# LIBUNISTRING_CONFFILES should be a list of user-editable files
#LIBUNISTRING_CONFFILES=/opt/etc/libunistring.conf /opt/etc/init.d/SXXlibunistring

#
# LIBUNISTRING_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBUNISTRING_PATCHES=$(LIBUNISTRING_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBUNISTRING_CPPFLAGS=
LIBUNISTRING_LDFLAGS=

#
# LIBUNISTRING_BUILD_DIR is the directory in which the build is done.
# LIBUNISTRING_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBUNISTRING_IPK_DIR is the directory in which the ipk is built.
# LIBUNISTRING_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBUNISTRING_BUILD_DIR=$(BUILD_DIR)/libunistring
LIBUNISTRING_SOURCE_DIR=$(SOURCE_DIR)/libunistring
LIBUNISTRING_IPK_DIR=$(BUILD_DIR)/libunistring-$(LIBUNISTRING_VERSION)-ipk
LIBUNISTRING_IPK=$(BUILD_DIR)/libunistring_$(LIBUNISTRING_VERSION)-$(LIBUNISTRING_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libunistring-source libunistring-unpack libunistring libunistring-stage libunistring-ipk libunistring-clean libunistring-dirclean libunistring-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBUNISTRING_SOURCE):
	$(WGET) -P $(@D) $(LIBUNISTRING_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libunistring-source: $(DL_DIR)/$(LIBUNISTRING_SOURCE) $(LIBUNISTRING_PATCHES)

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
$(LIBUNISTRING_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBUNISTRING_SOURCE) $(LIBUNISTRING_PATCHES) make/libunistring.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBUNISTRING_DIR) $(@D)
	$(LIBUNISTRING_UNZIP) $(DL_DIR)/$(LIBUNISTRING_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBUNISTRING_PATCHES)" ; \
		then cat $(LIBUNISTRING_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBUNISTRING_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBUNISTRING_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBUNISTRING_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBUNISTRING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBUNISTRING_LDFLAGS)" \
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

libunistring-unpack: $(LIBUNISTRING_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBUNISTRING_BUILD_DIR)/.built: $(LIBUNISTRING_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libunistring: $(LIBUNISTRING_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBUNISTRING_BUILD_DIR)/.staged: $(LIBUNISTRING_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

libunistring-stage: $(LIBUNISTRING_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libunistring
#
$(LIBUNISTRING_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libunistring" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBUNISTRING_PRIORITY)" >>$@
	@echo "Section: $(LIBUNISTRING_SECTION)" >>$@
	@echo "Version: $(LIBUNISTRING_VERSION)-$(LIBUNISTRING_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBUNISTRING_MAINTAINER)" >>$@
	@echo "Source: $(LIBUNISTRING_SITE)/$(LIBUNISTRING_SOURCE)" >>$@
	@echo "Description: $(LIBUNISTRING_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBUNISTRING_DEPENDS)" >>$@
	@echo "Suggests: $(LIBUNISTRING_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBUNISTRING_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBUNISTRING_IPK_DIR)/opt/sbin or $(LIBUNISTRING_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBUNISTRING_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBUNISTRING_IPK_DIR)/opt/etc/libunistring/...
# Documentation files should be installed in $(LIBUNISTRING_IPK_DIR)/opt/doc/libunistring/...
# Daemon startup scripts should be installed in $(LIBUNISTRING_IPK_DIR)/opt/etc/init.d/S??libunistring
#
# You may need to patch your application to make it use these locations.
#
$(LIBUNISTRING_IPK): $(LIBUNISTRING_BUILD_DIR)/.built
	rm -rf $(LIBUNISTRING_IPK_DIR) $(BUILD_DIR)/libunistring_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBUNISTRING_BUILD_DIR) DESTDIR=$(LIBUNISTRING_IPK_DIR) install-strip
#	install -d $(LIBUNISTRING_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBUNISTRING_SOURCE_DIR)/libunistring.conf $(LIBUNISTRING_IPK_DIR)/opt/etc/libunistring.conf
#	install -d $(LIBUNISTRING_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBUNISTRING_SOURCE_DIR)/rc.libunistring $(LIBUNISTRING_IPK_DIR)/opt/etc/init.d/SXXlibunistring
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBUNISTRING_IPK_DIR)/opt/etc/init.d/SXXlibunistring
	$(MAKE) $(LIBUNISTRING_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBUNISTRING_SOURCE_DIR)/postinst $(LIBUNISTRING_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBUNISTRING_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBUNISTRING_SOURCE_DIR)/prerm $(LIBUNISTRING_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBUNISTRING_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBUNISTRING_IPK_DIR)/CONTROL/postinst $(LIBUNISTRING_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBUNISTRING_CONFFILES) | sed -e 's/ /\n/g' > $(LIBUNISTRING_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBUNISTRING_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBUNISTRING_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libunistring-ipk: $(LIBUNISTRING_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libunistring-clean:
	rm -f $(LIBUNISTRING_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBUNISTRING_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libunistring-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBUNISTRING_DIR) $(LIBUNISTRING_BUILD_DIR) $(LIBUNISTRING_IPK_DIR) $(LIBUNISTRING_IPK)
#
#
# Some sanity check for the package.
#
libunistring-check: $(LIBUNISTRING_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
