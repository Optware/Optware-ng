###########################################################
#
# spawn-fcgi
#
###########################################################
#
# SPAWN-FCGI_VERSION, SPAWN-FCGI_SITE and SPAWN-FCGI_SOURCE define
# the upstream location of the source code for the package.
# SPAWN-FCGI_DIR is the directory which is created when the source
# archive is unpacked.
# SPAWN-FCGI_UNZIP is the command used to unzip the source.
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
SPAWN-FCGI_SITE=http://www.lighttpd.net/download
SPAWN-FCGI_VERSION=1.6.2
SPAWN-FCGI_SOURCE=spawn-fcgi-$(SPAWN-FCGI_VERSION).tar.bz2
SPAWN-FCGI_DIR=spawn-fcgi-$(SPAWN-FCGI_VERSION)
SPAWN-FCGI_UNZIP=bzcat
SPAWN-FCGI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SPAWN-FCGI_DESCRIPTION=spawn-fcgi is used to spawn fastcgi applications
SPAWN-FCGI_SECTION=utils
SPAWN-FCGI_PRIORITY=optional
SPAWN-FCGI_DEPENDS=
SPAWN-FCGI_SUGGESTS=
SPAWN-FCGI_CONFLICTS=

#
# SPAWN-FCGI_IPK_VERSION should be incremented when the ipk changes.
#
SPAWN-FCGI_IPK_VERSION=1

#
# SPAWN-FCGI_CONFFILES should be a list of user-editable files
#SPAWN-FCGI_CONFFILES=/opt/etc/spawn-fcgi.conf /opt/etc/init.d/SXXspawn-fcgi

#
# SPAWN-FCGI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SPAWN-FCGI_PATCHES=$(SPAWN-FCGI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SPAWN-FCGI_CPPFLAGS=
SPAWN-FCGI_LDFLAGS=

#
# SPAWN-FCGI_BUILD_DIR is the directory in which the build is done.
# SPAWN-FCGI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SPAWN-FCGI_IPK_DIR is the directory in which the ipk is built.
# SPAWN-FCGI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SPAWN-FCGI_BUILD_DIR=$(BUILD_DIR)/spawn-fcgi
SPAWN-FCGI_SOURCE_DIR=$(SOURCE_DIR)/spawn-fcgi
SPAWN-FCGI_IPK_DIR=$(BUILD_DIR)/spawn-fcgi-$(SPAWN-FCGI_VERSION)-ipk
SPAWN-FCGI_IPK=$(BUILD_DIR)/spawn-fcgi_$(SPAWN-FCGI_VERSION)-$(SPAWN-FCGI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: spawn-fcgi-source spawn-fcgi-unpack spawn-fcgi spawn-fcgi-stage spawn-fcgi-ipk spawn-fcgi-clean spawn-fcgi-dirclean spawn-fcgi-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SPAWN-FCGI_SOURCE):
	$(WGET) -P $(@D) $(SPAWN-FCGI_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
spawn-fcgi-source: $(DL_DIR)/$(SPAWN-FCGI_SOURCE) $(SPAWN-FCGI_PATCHES)

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
$(SPAWN-FCGI_BUILD_DIR)/.configured: $(DL_DIR)/$(SPAWN-FCGI_SOURCE) $(SPAWN-FCGI_PATCHES) make/spawn-fcgi.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SPAWN-FCGI_DIR) $(@D)
	$(SPAWN-FCGI_UNZIP) $(DL_DIR)/$(SPAWN-FCGI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SPAWN-FCGI_PATCHES)" ; \
		then cat $(SPAWN-FCGI_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SPAWN-FCGI_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SPAWN-FCGI_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SPAWN-FCGI_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SPAWN-FCGI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SPAWN-FCGI_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
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

spawn-fcgi-unpack: $(SPAWN-FCGI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SPAWN-FCGI_BUILD_DIR)/.built: $(SPAWN-FCGI_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
spawn-fcgi: $(SPAWN-FCGI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SPAWN-FCGI_BUILD_DIR)/.staged: $(SPAWN-FCGI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

spawn-fcgi-stage: $(SPAWN-FCGI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/spawn-fcgi
#
$(SPAWN-FCGI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: spawn-fcgi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SPAWN-FCGI_PRIORITY)" >>$@
	@echo "Section: $(SPAWN-FCGI_SECTION)" >>$@
	@echo "Version: $(SPAWN-FCGI_VERSION)-$(SPAWN-FCGI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SPAWN-FCGI_MAINTAINER)" >>$@
	@echo "Source: $(SPAWN-FCGI_SITE)/$(SPAWN-FCGI_SOURCE)" >>$@
	@echo "Description: $(SPAWN-FCGI_DESCRIPTION)" >>$@
	@echo "Depends: $(SPAWN-FCGI_DEPENDS)" >>$@
	@echo "Suggests: $(SPAWN-FCGI_SUGGESTS)" >>$@
	@echo "Conflicts: $(SPAWN-FCGI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SPAWN-FCGI_IPK_DIR)/opt/sbin or $(SPAWN-FCGI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SPAWN-FCGI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SPAWN-FCGI_IPK_DIR)/opt/etc/spawn-fcgi/...
# Documentation files should be installed in $(SPAWN-FCGI_IPK_DIR)/opt/doc/spawn-fcgi/...
# Daemon startup scripts should be installed in $(SPAWN-FCGI_IPK_DIR)/opt/etc/init.d/S??spawn-fcgi
#
# You may need to patch your application to make it use these locations.
#
$(SPAWN-FCGI_IPK): $(SPAWN-FCGI_BUILD_DIR)/.built
	rm -rf $(SPAWN-FCGI_IPK_DIR) $(BUILD_DIR)/spawn-fcgi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SPAWN-FCGI_BUILD_DIR) DESTDIR=$(SPAWN-FCGI_IPK_DIR) install-strip
#	install -d $(SPAWN-FCGI_IPK_DIR)/opt/etc/
#	install -m 644 $(SPAWN-FCGI_SOURCE_DIR)/spawn-fcgi.conf $(SPAWN-FCGI_IPK_DIR)/opt/etc/spawn-fcgi.conf
#	install -d $(SPAWN-FCGI_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SPAWN-FCGI_SOURCE_DIR)/rc.spawn-fcgi $(SPAWN-FCGI_IPK_DIR)/opt/etc/init.d/SXXspawn-fcgi
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPAWN-FCGI_IPK_DIR)/opt/etc/init.d/SXXspawn-fcgi
	$(MAKE) $(SPAWN-FCGI_IPK_DIR)/CONTROL/control
#	install -m 755 $(SPAWN-FCGI_SOURCE_DIR)/postinst $(SPAWN-FCGI_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPAWN-FCGI_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SPAWN-FCGI_SOURCE_DIR)/prerm $(SPAWN-FCGI_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPAWN-FCGI_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SPAWN-FCGI_IPK_DIR)/CONTROL/postinst $(SPAWN-FCGI_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SPAWN-FCGI_CONFFILES) | sed -e 's/ /\n/g' > $(SPAWN-FCGI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SPAWN-FCGI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
spawn-fcgi-ipk: $(SPAWN-FCGI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
spawn-fcgi-clean:
	rm -f $(SPAWN-FCGI_BUILD_DIR)/.built
	-$(MAKE) -C $(SPAWN-FCGI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
spawn-fcgi-dirclean:
	rm -rf $(BUILD_DIR)/$(SPAWN-FCGI_DIR) $(SPAWN-FCGI_BUILD_DIR) $(SPAWN-FCGI_IPK_DIR) $(SPAWN-FCGI_IPK)
#
#
# Some sanity check for the package.
#
spawn-fcgi-check: $(SPAWN-FCGI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
