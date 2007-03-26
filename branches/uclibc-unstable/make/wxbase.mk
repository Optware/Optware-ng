###########################################################
#
# wxbase
#
###########################################################

# You must replace "wxbase" and "WXBASE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# WXBASE_VERSION, WXBASE_SITE and WXBASE_SOURCE define
# the upstream location of the source code for the package.
# WXBASE_DIR is the directory which is created when the source
# archive is unpacked.
# WXBASE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
WXBASE_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/wxwindows
WXBASE_VERSION=2.8.0
WXBASE_SOURCE=wxWidgets-$(WXBASE_VERSION).tar.bz2
WXBASE_DIR=wxWidgets-$(WXBASE_VERSION)
WXBASE_UNZIP=bzcat
WXBASE_MAINTAINER=Gorion <mail4tmp@gmail.com>
WXBASE_DESCRIPTION=wxbase is a basic (non-windows) part of wxWidget toolkit
WXBASE_SECTION=libs
WXBASE_PRIORITY=optional
WXBASE_DEPENDS=libstdc++, expat, zlib
WXBASE_CONFLICTS=

#
# WXBASE_IPK_VERSION should be incremented when the ipk changes.
#
WXBASE_IPK_VERSION=5

#
# WXBASE_CONFFILES should be a list of user-editable files
## WXBASE_CONFFILES=/opt/etc/wxbase.conf /opt/etc/init.d/SXXwxbase

#
# WXBASE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
WXBASE_PATCHES=$(WXBASE_SOURCE_DIR)/Makefile.in.patch
ifeq ($(OPTWARE_TARGET), ts101)
WXBASE_PATCHES+=$(WXBASE_SOURCE_DIR)/filename.h.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WXBASE_CPPFLAGS=
WXBASE_LDFLAGS=

#
# WXBASE_BUILD_DIR is the directory in which the build is done.
# WXBASE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WXBASE_IPK_DIR is the directory in which the ipk is built.
# WXBASE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WXBASE_BUILD_DIR=$(BUILD_DIR)/wxbase
WXBASE_SOURCE_DIR=$(SOURCE_DIR)/wxbase
WXBASE_IPK_DIR=$(BUILD_DIR)/wxbase-$(WXBASE_VERSION)-ipk
WXBASE_IPK=$(BUILD_DIR)/wxbase_$(WXBASE_VERSION)-$(WXBASE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: wxbase-source wxbase-unpack wxbase wxbase-stage wxbase-ipk wxbase-clean wxbase-dirclean wxbase-check
#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WXBASE_SOURCE):
	$(WGET) -P $(DL_DIR) $(WXBASE_SITE)/$(WXBASE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
wxbase-source: $(DL_DIR)/$(WXBASE_SOURCE) $(WXBASE_PATCHES)

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

$(WXBASE_BUILD_DIR)/.configured: $(DL_DIR)/$(WXBASE_SOURCE) $(WXBASE_PATCHES)
	make libstdc++-stage expat-stage zlib-stage
	rm -rf  $(WXBASE_BUILD_DIR) $(BUILD_DIR)/$(WXBASE_DIR)
	$(WXBASE_UNZIP) $(DL_DIR)/$(WXBASE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(WXBASE_PATCHES)" ; \
		then cat $(WXBASE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(WXBASE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(WXBASE_DIR)" != "$(WXBASE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(WXBASE_DIR) $(WXBASE_BUILD_DIR) ; \
	fi
	(cd $(WXBASE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WXBASE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WXBASE_LDFLAGS)" \
		ac_cv_path_SDL_CONFIG=no \
		./configure \
		--prefix=/opt \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-precomp-headers \
		--disable-gui \
		--without-subdirs \
		--with-regex=builtin \
		--with-zlib=sys \
		--with-expat=sys \
		--enable-largefile \
		--without-sdl \
		--disable-sdltest \
		--enable-unicode \
		)
	touch $(WXBASE_BUILD_DIR)/.configured

wxbase-unpack: $(WXBASE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WXBASE_BUILD_DIR)/.built: $(WXBASE_BUILD_DIR)/.configured
	rm -f $(WXBASE_BUILD_DIR)/.built
	$(MAKE) -C $(WXBASE_BUILD_DIR)
	touch $(WXBASE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
wxbase: $(WXBASE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(WXBASE_BUILD_DIR)/.staged: $(WXBASE_BUILD_DIR)/.built
	rm -f $(WXBASE_BUILD_DIR)/.staged
	rm -rf $(STAGING_INCLUDE_DIR)/wx $(STAGING_INCLUDE_DIR)/wx-*
	$(MAKE) -C $(WXBASE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	install -d $(STAGING_INCLUDE_DIR)/wx-2.8
	cp $(STAGING_PREFIX)/lib/wx/include/$(GNU_TARGET_NAME)-base-unicode*/wx/setup.h $(STAGING_INCLUDE_DIR)/wx-2.8/wx/
	cd $(STAGING_PREFIX)/bin; rm -rf wx-config; \
		ln -s ../lib/wx/config/$(GNU_TARGET_NAME)*-unicode-release-* wx-config
	touch $(WXBASE_BUILD_DIR)/.staged



wxbase-stage: $(WXBASE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/wxbase
#
$(WXBASE_IPK_DIR)/CONTROL/control:
	@install -d $(WXBASE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: wxbase" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WXBASE_PRIORITY)" >>$@
	@echo "Section: $(WXBASE_SECTION)" >>$@
	@echo "Version: $(WXBASE_VERSION)-$(WXBASE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WXBASE_MAINTAINER)" >>$@
	@echo "Source: $(WXBASE_SITE)/$(WXBASE_SOURCE)" >>$@
	@echo "Description: $(WXBASE_DESCRIPTION)" >>$@
	@echo "Depends: $(WXBASE_DEPENDS)" >>$@
	@echo "Conflicts: $(WXBASE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(WXBASE_IPK_DIR)/opt/sbin or $(WXBASE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WXBASE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WXBASE_IPK_DIR)/opt/etc/wxbase/...
# Documentation files should be installed in $(WXBASE_IPK_DIR)/opt/doc/wxbase/...
# Daemon startup scripts should be installed in $(WXBASE_IPK_DIR)/opt/etc/init.d/S??wxbase
#
# You may need to patch your application to make it use these locations.
#
$(WXBASE_IPK): $(WXBASE_BUILD_DIR)/.built
	rm -rf $(WXBASE_IPK_DIR) $(BUILD_DIR)/wxbase_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(WXBASE_BUILD_DIR) DESTDIR=$(WXBASE_IPK_DIR) install-strip
	$(STRIP_COMMAND) $(WXBASE_IPK_DIR)/opt/lib/libwx_baseu_net-*.so.*.*.*
	$(MAKE) $(WXBASE_IPK_DIR)/CONTROL/control
	cd $(WXBASE_IPK_DIR)/opt/bin; rm -rf wx-config; \
		ln -s ../lib/wx/config/$(GNU_TARGET_NAME)* wx-config
	cp $(WXBASE_IPK_DIR)/opt/lib/wx/include/$(GNU_TARGET_NAME)-*/wx/setup.h $(WXBASE_IPK_DIR)/opt/include/wx-2.8/wx/
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WXBASE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
wxbase-ipk: $(WXBASE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
wxbase-clean:
	rm -f $(WXBASE_BUILD_DIR)/.built
	-$(MAKE) -C $(WXBASE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
wxbase-dirclean:
	rm -rf $(BUILD_DIR)/$(WXBASE_DIR) $(WXBASE_BUILD_DIR) $(WXBASE_IPK_DIR) $(WXBASE_IPK)

#
#
# Some sanity check for the package.
#
wxbase-check: $(WXBASE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(WXBASE_IPK)

