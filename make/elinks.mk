###########################################################
#
# elinks
#
###########################################################

# You must replace "elinks" and "ELINKS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ELINKS_VERSION, ELINKS_SITE and ELINKS_SOURCE define
# the upstream location of the source code for the package.
# ELINKS_DIR is the directory which is created when the source
# archive is unpacked.
# ELINKS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
ELINKS_SITE=http://elinks.or.cz/download
ELINKS_VERSION=0.11.4
ELINKS_SOURCE=elinks-$(ELINKS_VERSION).tar.gz
ELINKS_DIR=elinks-$(ELINKS_VERSION)
ELINKS_UNZIP=zcat
ELINKS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ELINKS_DESCRIPTION=Full-Featured Text WWW Browser
ELINKS_SECTION=web
ELINKS_PRIORITY=optional
ELINKS_DEPENDS=openssl, zlib, bzip2, expat, libidn, ossp-js
ELINKS_SUGGESTS=
ELINKS_CONFLICTS=

#
# ELINKS_IPK_VERSION should be incremented when the ipk changes.
#
ELINKS_IPK_VERSION=1

#
# ELINKS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ELINKS_PATCHES=$(ELINKS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ELINKS_CPPFLAGS=
ELINKS_LDFLAGS=-lm

# Clear the follwing variable if preaty-print is favorable
ELINKS_VERBOSE="V=1"

#
# ELINKS_BUILD_DIR is the directory in which the build is done.
# ELINKS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ELINKS_IPK_DIR is the directory in which the ipk is built.
# ELINKS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ELINKS_BUILD_DIR=$(BUILD_DIR)/elinks
ELINKS_SOURCE_DIR=$(SOURCE_DIR)/elinks
ELINKS_IPK_DIR=$(BUILD_DIR)/elinks-$(ELINKS_VERSION)-ipk
ELINKS_IPK=$(BUILD_DIR)/elinks_$(ELINKS_VERSION)-$(ELINKS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ELINKS_SOURCE):
	$(WGET) -P $(@D) $(ELINKS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
elinks-source: $(DL_DIR)/$(ELINKS_SOURCE) $(ELINKS_PATCHES)

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
$(ELINKS_BUILD_DIR)/.configured: $(DL_DIR)/$(ELINKS_SOURCE) $(ELINKS_PATCHES) make/elinks.mk
	$(MAKE) zlib-stage bzip2-stage expat-stage libidn-stage openssl-stage ossp-js-stage
	rm -rf $(BUILD_DIR)/$(ELINKS_DIR) $(@D)
	$(ELINKS_UNZIP) $(DL_DIR)/$(ELINKS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ELINKS_PATCHES)" ; \
		then cat $(ELINKS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ELINKS_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(ELINKS_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ELINKS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ELINKS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--enable-256-colors \
		--with-spidermonkey=$(STAGING_PREFIX) \
		--without-x \
	)
	touch $@

elinks-unpack: $(ELINKS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ELINKS_BUILD_DIR)/.built: $(ELINKS_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	$(MAKE) -C $(@D) \
		C_INCLUDE_PATH=$(STAGING_INCLUDE_DIR) $(ELINKS_VERBOSE) 
	touch $@

#
# This is the build convenience target.
#
elinks: $(ELINKS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ELINKS_BUILD_DIR)/.staged: $(ELINKS_BUILD_DIR)/.built
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	$(MAKE) -C $(@D) 
		DESTDIR=$(STAGING_DIR) $(ELINKS_VERBOSE) install
	touch $@

elinks-stage: $(ELINKS_BUILD_DIR)/.staged

# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/elinks
#
$(ELINKS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: elinks" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ELINKS_PRIORITY)" >>$@
	@echo "Section: $(ELINKS_SECTION)" >>$@
	@echo "Version: $(ELINKS_VERSION)-$(ELINKS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ELINKS_MAINTAINER)" >>$@
	@echo "Source: $(ELINKS_SITE)/$(ELINKS_SOURCE)" >>$@
	@echo "Description: $(ELINKS_DESCRIPTION)" >>$@
	@echo "Depends: $(ELINKS_DEPENDS)" >>$@
	@echo "Suggests: $(ELINKS_SUGGESTS)" >>$@
	@echo "Conflicts: $(ELINKS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ELINKS_IPK_DIR)/opt/sbin or $(ELINKS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ELINKS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ELINKS_IPK_DIR)/opt/etc/elinks/...
# Documentation files should be installed in $(ELINKS_IPK_DIR)/opt/doc/elinks/...
# Daemon startup scripts should be installed in $(ELINKS_IPK_DIR)/opt/etc/init.d/S??elinks
#
# You may need to patch your application to make it use these locations.
#
$(ELINKS_IPK): $(ELINKS_BUILD_DIR)/.built
	rm -rf $(ELINKS_IPK_DIR) $(BUILD_DIR)/elinks_*_$(TARGET_ARCH).ipk
	$(TARGET_CONFIGURE_OPTS) \
	$(MAKE) -C $(ELINKS_BUILD_DIR) DESTDIR=$(ELINKS_IPK_DIR) \
		$(ELINKS_VERBOSE) install
	$(STRIP_COMMAND) $(ELINKS_IPK_DIR)/opt/bin/elinks
	$(MAKE) $(ELINKS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ELINKS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
elinks-ipk: $(ELINKS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
elinks-clean:
	-$(MAKE) -C $(ELINKS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
elinks-dirclean:
	rm -rf $(BUILD_DIR)/$(ELINKS_DIR) $(ELINKS_BUILD_DIR) $(ELINKS_IPK_DIR) $(ELINKS_IPK)

#
# Some sanity check for the package.
#
elinks-check: $(ELINKS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ELINKS_IPK)
