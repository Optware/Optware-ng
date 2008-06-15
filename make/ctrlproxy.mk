###########################################################
#
# ctrlproxy
#
###########################################################

# You must replace "ctrlproxy" and "CTRLPROXY" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# CTRLPROXY_VERSION, CTRLPROXY_SITE and CTRLPROXY_SOURCE define
# the upstream location of the source code for the package.
# CTRLPROXY_DIR is the directory which is created when the source
# archive is unpacked.
# CTRLPROXY_UNZIP is the command used to unzip the source.
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
CTRLPROXY_SITE=http://www.ctrlproxy.org/releases
CTRLPROXY_VERSION=3.0.7
CTRLPROXY_SOURCE=ctrlproxy-$(CTRLPROXY_VERSION).tar.gz
CTRLPROXY_DIR=ctrlproxy-$(CTRLPROXY_VERSION)
CTRLPROXY_UNZIP=zcat
CTRLPROXY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CTRLPROXY_DESCRIPTION=An IRC server with multiserver support.
CTRLPROXY_SECTION=irc
CTRLPROXY_PRIORITY=optional
CTRLPROXY_DEPENDS=glib, libxml2, popt, gnutls, pcre

#
# CTRLPROXY_IPK_VERSION should be incremented when the ipk changes.
#
CTRLPROXY_IPK_VERSION=1

#
# CTRLPROXY_CONFFILES should be a list of user-editable files
CTRLPROXY_CONFFILES=

#
# CTRLPROXY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CTRLPROXY_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CTRLPROXY_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -D__USE_POSIX
CTRLPROXY_LDFLAGS=

#
# CTRLPROXY_BUILD_DIR is the directory in which the build is done.
# CTRLPROXY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CTRLPROXY_IPK_DIR is the directory in which the ipk is built.
# CTRLPROXY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CTRLPROXY_BUILD_DIR=$(BUILD_DIR)/ctrlproxy
CTRLPROXY_SOURCE_DIR=$(SOURCE_DIR)/ctrlproxy
CTRLPROXY_IPK_DIR=$(BUILD_DIR)/ctrlproxy-$(CTRLPROXY_VERSION)-ipk
CTRLPROXY_IPK=$(BUILD_DIR)/ctrlproxy_$(CTRLPROXY_VERSION)-$(CTRLPROXY_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CTRLPROXY_SOURCE):
	$(WGET) -P $(@D) $(CTRLPROXY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ctrlproxy-source: $(DL_DIR)/$(CTRLPROXY_SOURCE) $(CTRLPROXY_PATCHES)

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
$(CTRLPROXY_BUILD_DIR)/.configured: $(DL_DIR)/$(CTRLPROXY_SOURCE) $(CTRLPROXY_PATCHES) make/ctrlproxy.mk
	$(MAKE) glib-stage libxml2-stage popt-stage pcre-stage gnutls-stage
	rm -rf $(BUILD_DIR)/$(CTRLPROXY_DIR) $(CTRLPROXY_BUILD_DIR)
	$(CTRLPROXY_UNZIP) $(DL_DIR)/$(CTRLPROXY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test "$(CTRLPROXY_PATCHES)"; \
		then cat $(CTRLPROXY_PATCHES) | patch -d $(BUILD_DIR)/$(CTRLPROXY_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(CTRLPROXY_DIR) $(CTRLPROXY_BUILD_DIR)
	(cd $(CTRLPROXY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CTRLPROXY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CTRLPROXY_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--oldincludedir=$(STAGING_DIR)/opt/include \
		--prefix=/opt \
		--disable-gcov \
		--disable-nls \
	)
	sed -i -e '/WITH_GCOV/s|1|0|' $(@D)/Makefile.settings
	touch $@

ctrlproxy-unpack: $(CTRLPROXY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CTRLPROXY_BUILD_DIR)/.built: $(CTRLPROXY_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ctrlproxy: $(CTRLPROXY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CTRLPROXY_BUILD_DIR)/.staged: $(CTRLPROXY_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ctrlproxy-stage: $(CTRLPROXY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ctrlproxy
#
$(CTRLPROXY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ctrlproxy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CTRLPROXY_PRIORITY)" >>$@
	@echo "Section: $(CTRLPROXY_SECTION)" >>$@
	@echo "Version: $(CTRLPROXY_VERSION)-$(CTRLPROXY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CTRLPROXY_MAINTAINER)" >>$@
	@echo "Source: $(CTRLPROXY_SITE)/$(CTRLPROXY_SOURCE)" >>$@
	@echo "Description: $(CTRLPROXY_DESCRIPTION)" >>$@
	@echo "Depends: $(CTRLPROXY_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CTRLPROXY_IPK_DIR)/opt/sbin or $(CTRLPROXY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CTRLPROXY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CTRLPROXY_IPK_DIR)/opt/etc/ctrlproxy/...
# Documentation files should be installed in $(CTRLPROXY_IPK_DIR)/opt/doc/ctrlproxy/...
# Daemon startup scripts should be installed in $(CTRLPROXY_IPK_DIR)/opt/etc/init.d/S??ctrlproxy
#
# You may need to patch your application to make it use these locations.
#
$(CTRLPROXY_IPK): $(CTRLPROXY_BUILD_DIR)/.built
	rm -rf $(CTRLPROXY_IPK_DIR) $(BUILD_DIR)/ctrlproxy_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CTRLPROXY_BUILD_DIR) DESTDIR=$(CTRLPROXY_IPK_DIR) \
		all install-dirs install-bin install-data install-doc
	$(STRIP_COMMAND) $(CTRLPROXY_IPK_DIR)/opt/bin/ctrlproxy
#	install -d $(CTRLPROXY_IPK_DIR)/opt/etc/
#	install -m 644 $(CTRLPROXY_SOURCE_DIR)/ctrlproxy.conf $(CTRLPROXY_IPK_DIR)/opt/etc/ctrlproxy.conf
#	install -d $(CTRLPROXY_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CTRLPROXY_SOURCE_DIR)/rc.ctrlproxy $(CTRLPROXY_IPK_DIR)/opt/etc/init.d/SXXctrlproxy
	$(MAKE) $(CTRLPROXY_IPK_DIR)/CONTROL/control
#	install -m 755 $(CTRLPROXY_SOURCE_DIR)/postinst $(CTRLPROXY_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CTRLPROXY_SOURCE_DIR)/prerm $(CTRLPROXY_IPK_DIR)/CONTROL/prerm
	echo $(CTRLPROXY_CONFFILES) | sed -e 's/ /\n/g' > $(CTRLPROXY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CTRLPROXY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ctrlproxy-ipk: $(CTRLPROXY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ctrlproxy-clean:
	-$(MAKE) -C $(CTRLPROXY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ctrlproxy-dirclean:
	rm -rf $(BUILD_DIR)/$(CTRLPROXY_DIR) $(CTRLPROXY_BUILD_DIR) $(CTRLPROXY_IPK_DIR) $(CTRLPROXY_IPK)

#
# Some sanity check for the package.
#
ctrlproxy-check: $(CTRLPROXY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CTRLPROXY_IPK)
