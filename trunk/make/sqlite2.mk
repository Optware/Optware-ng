###########################################################
#
# sqlite2
#
###########################################################

# You must replace "sqlite2" and "SQLITE2" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SQLITE2_VERSION, SQLITE2_SITE and SQLITE2_SOURCE define
# the upstream location of the source code for the package.
# SQLITE2_DIR is the directory which is created when the source
# archive is unpacked.
# SQLITE2_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
SQLITE2_SITE=http://sqlite.org
SQLITE2_VERSION=2.8.17
SQLITE2_SOURCE=sqlite-$(SQLITE2_VERSION).tar.gz
SQLITE2_DIR=sqlite-$(SQLITE2_VERSION)
SQLITE2_UNZIP=zcat
SQLITE2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SQLITE2_DESCRIPTION=SQLite is a small C library that implements a self-contained, embeddable, zero-configuration SQL database engine.
SQLITE2_SECTION=lib
SQLITE2_PRIORITY=optional
SQLITE2_DEPENDS=ncurses, readline
SQLITE2_SUGGESTS=
SQLITE2_CONFLICTS=

#
# SQLITE2_IPK_VERSION should be incremented when the ipk changes.
#
SQLITE2_IPK_VERSION=2

#
# SQLITE2_CONFFILES should be a list of user-editable files

#
# SQLITE2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SQLITE2_PATCHES=$(SQLITE2_SOURCE_DIR)/configure.patch
#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SQLITE2_CPPFLAGS=
SQLITE2_LDFLAGS=

#
# SQLITE2_BUILD_DIR is the directory in which the build is done.
# SQLITE2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SQLITE2_IPK_DIR is the directory in which the ipk is built.
# SQLITE2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SQLITE2_BUILD_DIR=$(BUILD_DIR)/sqlite2
SQLITE2_SOURCE_DIR=$(SOURCE_DIR)/sqlite2
SQLITE2_IPK_DIR=$(BUILD_DIR)/sqlite2-$(SQLITE2_VERSION)-ipk
SQLITE2_IPK=$(BUILD_DIR)/sqlite2_$(SQLITE2_VERSION)-$(SQLITE2_IPK_VERSION)_${TARGET_ARCH}.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SQLITE2_SOURCE):
	$(WGET) -P $(@D) $(SQLITE2_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sqlite2-source: $(DL_DIR)/$(SQLITE2_SOURCE) $(SQLITE2_PATCHES)

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
$(SQLITE2_BUILD_DIR)/.configured: $(DL_DIR)/$(SQLITE2_SOURCE) $(SQLITE2_PATCHES)
	$(MAKE) ncurses-stage readline-stage
	rm -rf $(BUILD_DIR)/$(SQLITE2_DIR) $(SQLITE2_BUILD_DIR)
	$(SQLITE2_UNZIP) $(DL_DIR)/$(SQLITE2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SQLITE2_PATCHES)"; \
		then cat $(SQLITE2_PATCHES) | patch -d $(BUILD_DIR)/$(SQLITE2_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(SQLITE2_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SQLITE2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SQLITE2_LDFLAGS)" \
		config_TARGET_READLINE_INC=-I$(STAGING_DIR)/opt/include \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

sqlite2-unpack: $(SQLITE2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SQLITE2_BUILD_DIR)/.built: $(SQLITE2_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
sqlite2: $(SQLITE2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SQLITE2_BUILD_DIR)/.staged: $(SQLITE2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

sqlite2-stage: $(SQLITE2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sqlite2
#
$(SQLITE2_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sqlite2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SQLITE2_PRIORITY)" >>$@
	@echo "Section: $(SQLITE2_SECTION)" >>$@
	@echo "Version: $(SQLITE2_VERSION)-$(SQLITE2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SQLITE2_MAINTAINER)" >>$@
	@echo "Source: $(SQLITE2_SITE)/$(SQLITE2_SOURCE)" >>$@
	@echo "Description: $(SQLITE2_DESCRIPTION)" >>$@
	@echo "Depends: $(SQLITE2_DEPENDS)" >>$@
	@echo "Suggests: $(SQLITE2_SUGGESTS)" >>$@
	@echo "Conflicts: $(SQLITE2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SQLITE2_IPK_DIR)/opt/sbin or $(SQLITE2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SQLITE2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SQLITE2_IPK_DIR)/opt/etc/sqlite2/...
# Documentation files should be installed in $(SQLITE2_IPK_DIR)/opt/doc/sqlite2/...
# Daemon startup scripts should be installed in $(SQLITE2_IPK_DIR)/opt/etc/init.d/S??sqlite2
#
# You may need to patch your application to make it use these locations.
#
$(SQLITE2_IPK): $(SQLITE2_BUILD_DIR)/.built
	rm -rf $(SQLITE2_IPK_DIR) $(BUILD_DIR)/sqlite2_*_${TARGET_ARCH}.ipk
	$(MAKE) -C $(SQLITE2_BUILD_DIR) DESTDIR=$(SQLITE2_IPK_DIR) install
	$(STRIP_COMMAND) $(SQLITE2_IPK_DIR)/opt/bin/sqlite $(SQLITE2_IPK_DIR)/opt/lib/libsqlite.so.*.*.*
	$(MAKE) $(SQLITE2_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SQLITE2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sqlite2-ipk: $(SQLITE2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sqlite2-clean:
	-$(MAKE) -C $(SQLITE2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sqlite2-dirclean:
	rm -rf $(BUILD_DIR)/$(SQLITE2_DIR) $(SQLITE2_BUILD_DIR) $(SQLITE2_IPK_DIR) $(SQLITE2_IPK)

#
# Some sanity check for the package.
#
sqlite2-check: $(SQLITE2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
