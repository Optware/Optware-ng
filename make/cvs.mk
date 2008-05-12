###########################################################
#
# cvs
#
###########################################################

CVS_SITE=http://ftp.gnu.org/non-gnu/cvs/source/stable/$(CVS_VERSION)
CVS_VERSION=1.11.23
CVS_SOURCE=$(CVS_DIR).tar.bz2
CVS_DIR=cvs-$(CVS_VERSION)
CVS_UNZIP=bzcat
CVS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CVS_DESCRIPTION=Concurrent versioning system.
CVS_SECTION=devel
CVS_PRIORITY=optional
CVS_DEPENDS=
CVS_SUGGESTS=
CVS_CONFLICTS=

CVS_IPK_VERSION=1

CVS_IPK=$(BUILD_DIR)/cvs_$(CVS_VERSION)-$(CVS_IPK_VERSION)_$(TARGET_ARCH).ipk
CVS_IPK_DIR=$(BUILD_DIR)/cvs-$(CVS_VERSION)-ipk

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CVS_CPPFLAGS=
CVS_LDFLAGS=

#
# CVS_BUILD_DIR is the directory in which the build is done.
# CVS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CVS_IPK_DIR is the directory in which the ipk is built.
# CVS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CVS_BUILD_DIR=$(BUILD_DIR)/cvs
CVS_SOURCE_DIR=$(SOURCE_DIR)/cvs
CVS_IPK_DIR=$(BUILD_DIR)/cvs-$(CVS_VERSION)-ipk
CVS_IPK=$(BUILD_DIR)/cvs_$(CVS_VERSION)-$(CVS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CVS_SOURCE):
	$(WGET) -P $(@D) $(CVS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cvs-source: $(DL_DIR)/$(CVS_SOURCE) $(CVS_PATCHES)

$(CVS_BUILD_DIR)/.source: $(DL_DIR)/$(CVS_SOURCE)
	$(CVS_UNZIP) $(DL_DIR)/$(CVS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/cvs-$(CVS_VERSION) $(@D)
	touch $@


$(CVS_BUILD_DIR)/.configured: $(DL_DIR)/$(CVS_SOURCE) $(CVS_PATCHES) make/cvs.mk
	rm -rf $(BUILD_DIR)/$(CVS_DIR) $(@D)
	$(CVS_UNZIP) $(DL_DIR)/$(CVS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CVS_PATCHES)" ; \
		then cat $(CVS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CVS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CVS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CVS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CVS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CVS_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		cvs_cv_func_printf=yes \
		cvs_cv_func_printf_ptr=yes \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--without-gssapi \
		--prefix=/opt \
	);
	touch $@

cvs-unpack: $(CVS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CVS_BUILD_DIR)/.built: $(CVS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
cvs: $(CVS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CVS_BUILD_DIR)/.staged: $(CVS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

cvs-stage: $(CVS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cvs
#
$(CVS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: cvs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CVS_PRIORITY)" >>$@
	@echo "Section: $(CVS_SECTION)" >>$@
	@echo "Version: $(CVS_VERSION)-$(CVS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CVS_MAINTAINER)" >>$@
	@echo "Source: $(CVS_SITE)/$(CVS_SOURCE)" >>$@
	@echo "Description: $(CVS_DESCRIPTION)" >>$@
	@echo "Depends: $(CVS_DEPENDS)" >>$@
	@echo "Suggests: $(CVS_SUGGESTS)" >>$@
	@echo "Conflicts: $(CVS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CVS_IPK_DIR)/opt/sbin or $(CVS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CVS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CVS_IPK_DIR)/opt/etc/ushare/...
# Documentation files should be installed in $(CVS_IPK_DIR)/opt/doc/ushare/...
# Daemon startup scripts should be installed in $(CVS_IPK_DIR)/opt/etc/init.d/S??ushare
#
# You may need to patch your application to make it use these locations.
#
$(CVS_IPK): $(CVS_BUILD_DIR)/.built
	rm -rf $(CVS_IPK_DIR) $(BUILD_DIR)/ushare_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CVS_BUILD_DIR) DESTDIR=$(CVS_IPK_DIR) install-strip
#	$(STRIP_COMMAND) $(CVS_BUILD_DIR)/src/cvs -o $(CVS_IPK_DIR)/opt/bin/cvs
	install -d $(CVS_IPK_DIR)/opt/bin/
	$(MAKE) $(CVS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CVS_IPK_DIR)

#
#
# This is called from the top level makefile to create the IPK file.
#
cvs-ipk: $(CVS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cvs-clean:
	rm -f $(CVS_BUILD_DIR)/.built
	-$(MAKE) -C $(CVS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cvs-dirclean:
	rm -rf $(BUILD_DIR)/$(CVS_DIR) $(CVS_BUILD_DIR) $(CVS_IPK_DIR) $(CVS_IPK)

#
# Some sanity check for the package.
#
cvs-check: $(CVS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CVS_IPK)
