###########################################################
#
# mc
#
###########################################################

MC_SITE=http://ftp.gnu.org/pub/gnu/mc
MC_VERSION=4.5.55
MC_SOURCE=mc-$(MC_VERSION).tar.gz
MC_DIR=mc-$(MC_VERSION)
MC_UNZIP=zcat
MC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MC_DESCRIPTION=Midnight Commander File Manager
MC_SECTION=utilities
MC_PRIORITY=optional
MC_DEPENDS=ncurses, glib
MC_CONFLICTS=

#
# MC_IPK_VERSION should be incremented when the ipk changes.
#
MC_IPK_VERSION=6

#
# MC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifeq ($(OPTWARE_TARGET),wl500g)
MC_PATCHES=$(MC_SOURCE_DIR)/stropts.patch
else
MC_PATCHES=$(MC_SOURCE_DIR)/static-declaration.patch
endif

MC_PATCHES += $(MC_SOURCE_DIR)/terminfo.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
#  When not cross compiling one should use pkg-config
#  PKG_CONFIG_LIBDIR=staging/opt/lib/pkgconfig pkg-config --libs glib-2.0
#

ifeq ($(OPTWARE_TARGET),slugosbe)
MC_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_LIB_DIR)/glib-2.0/include -DNGROUPS_MAX=65536
else
MC_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_LIB_DIR)/glib-2.0/include
endif
MC_LDFLAGS=-lglib-2.0
#
# MC_BUILD_DIR is the directory in which the build is done.
# MC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MC_IPK_DIR is the directory in which the ipk is built.
# MC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MC_BUILD_DIR=$(BUILD_DIR)/mc
MC_SOURCE_DIR=$(SOURCE_DIR)/mc
MC_IPK_DIR=$(BUILD_DIR)/mc-$(MC_VERSION)-ipk
MC_IPK=$(BUILD_DIR)/mc_$(MC_VERSION)-$(MC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mc-source mc-unpack mc mc-stage mc-ipk mc-clean mc-dirclean mc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MC_SOURCE):
	$(WGET) -P $(DL_DIR) $(MC_SITE)/$(MC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mc-source: $(DL_DIR)/$(MC_SOURCE) $(MC_PATCHES)

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
$(MC_BUILD_DIR)/.configured: $(DL_DIR)/$(MC_SOURCE) $(MC_PATCHES)
	rm -rf $(BUILD_DIR)/$(MC_DIR) $(MC_BUILD_DIR)
	$(MAKE) glib-stage
	$(MC_UNZIP) $(DL_DIR)/$(MC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MC_PATCHES)" ; \
		then cat $(MC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MC_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(MC_DIR) $(MC_BUILD_DIR)
	(cd $(MC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MC_LDFLAGS)" \
		ac_cv_path_GLIB_CONFIG=y\
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-glibtest \
	)
	touch $(MC_BUILD_DIR)/.configured

mc-unpack: $(MC_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(MC_BUILD_DIR)/src/mc: $(MC_BUILD_DIR)/.configured
	rm -f $(MC_BUILD_DIR)/src/mc
	$(TARGET_CONFIGURE_OPTS) \
	$(MAKE) -C $(MC_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
mc: $(MC_BUILD_DIR)/src/mc

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mc
#
$(MC_IPK_DIR)/CONTROL/control:
	@install -d $(MC_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: mc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MC_PRIORITY)" >>$@
	@echo "Section: $(MC_SECTION)" >>$@
	@echo "Version: $(MC_VERSION)-$(MC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MC_MAINTAINER)" >>$@
	@echo "Source: $(MC_SITE)/$(MC_SOURCE)" >>$@
	@echo "Description: $(MC_DESCRIPTION)" >>$@
	@echo "Depends: $(MC_DEPENDS)" >>$@
	@echo "Conflicts: $(MC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MC_IPK_DIR)/opt/sbin or $(MC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MC_IPK_DIR)/opt/etc/mc/...
# Documentation files should be installed in $(MC_IPK_DIR)/opt/doc/mc/...
# Daemon startup scripts should be installed in $(MC_IPK_DIR)/opt/etc/init.d/S??mc
#
# You may need to patch your application to make it use these locations.
#
$(MC_IPK): $(MC_BUILD_DIR)/src/mc
	rm -rf $(MC_IPK_DIR) $(MC_IPK)
	install -d $(MC_IPK_DIR)/opt/bin
	install -d $(MC_IPK_DIR)/opt/lib/mc
	install -m 644 $(MC_BUILD_DIR)/lib/mc.ext  $(MC_IPK_DIR)/opt/lib/mc
	install -m 644 $(MC_BUILD_DIR)/lib/mc.hint $(MC_IPK_DIR)/opt/lib/mc
	install -m 644 $(MC_BUILD_DIR)/lib/mc.lib  $(MC_IPK_DIR)/opt/lib/mc
	install -m 644 $(MC_BUILD_DIR)/lib/mc.menu $(MC_IPK_DIR)/opt/lib/mc
	$(STRIP_COMMAND) $(MC_BUILD_DIR)/src/mc -o $(MC_IPK_DIR)/opt/bin/mc
	ln -s mc $(MC_IPK_DIR)/opt/bin/mcedit
	install -d $(MC_IPK_DIR)/opt/lib/mc/syntax
	install -m 644 $(MC_BUILD_DIR)/syntax/* $(MC_IPK_DIR)/opt/lib/mc/syntax
	$(MAKE) $(MC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mc-ipk: $(MC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mc-clean:
	-$(MAKE) -C $(MC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mc-dirclean:
	rm -rf $(BUILD_DIR)/$(MC_DIR) $(MC_BUILD_DIR) $(MC_IPK_DIR) $(MC_IPK)

#
# Some sanity check for the package.
#
mc-check: $(MC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MC_IPK)
