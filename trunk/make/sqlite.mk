###########################################################
#
# sqlite
#
###########################################################
#
# SQLITE_VERSION, SQLITE_SITE and SQLITE_SOURCE define
# the upstream location of the source code for the package.
# SQLITE_DIR is the directory which is created when the source
# archive is unpacked.
# SQLITE_UNZIP is the command used to unzip the source.
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
SQLITE_SITE=http://www.sqlite.org
SQLITE_VERSION=3.6.0
SQLITE_SOURCE=sqlite-$(SQLITE_VERSION).tar.gz
SQLITE_DIR=sqlite-$(SQLITE_VERSION)
SQLITE_UNZIP=zcat
SQLITE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SQLITE_DESCRIPTION=SQLite is a small C library that implements a self-contained, embeddable, zero-configuration SQL database engine.
SQLITE_SECTION=misc
SQLITE_PRIORITY=optional
SQLITE_DEPENDS=readline, ncurses
SQLITE_CONFLICTS=

#
# SQLITE_IPK_VERSION should be incremented when the ipk changes.
#
SQLITE_IPK_VERSION=1

#
# SQLITE_CONFFILES should be a list of user-editable files
#SQLITE_CONFFILES=/opt/etc/sqlite.conf /opt/etc/init.d/SXXsqlite

#
# SQLITE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SQLITE_PATCHES=$(SQLITE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SQLITE_CPPFLAGS=
SQLITE_LDFLAGS=-lreadline -lncurses
ifeq ($(LIBC_STYLE), uclibc)
SQLITE_LDFLAGS+=-lm
endif

#
# SQLITE_BUILD_DIR is the directory in which the build is done.
# SQLITE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SQLITE_IPK_DIR is the directory in which the ipk is built.
# SQLITE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SQLITE_BUILD_DIR=$(BUILD_DIR)/sqlite
SQLITE_SOURCE_DIR=$(SOURCE_DIR)/sqlite
SQLITE_IPK_DIR=$(BUILD_DIR)/sqlite-$(SQLITE_VERSION)-ipk
SQLITE_IPK=$(BUILD_DIR)/sqlite_$(SQLITE_VERSION)-$(SQLITE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sqlite-source sqlite-unpack sqlite sqlite-stage sqlite-ipk sqlite-clean sqlite-dirclean sqlite-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SQLITE_SOURCE):
	$(WGET) -P $(DL_DIR) $(SQLITE_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sqlite-source: $(DL_DIR)/$(SQLITE_SOURCE) $(SQLITE_PATCHES)

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
$(SQLITE_BUILD_DIR)/.configured: $(DL_DIR)/$(SQLITE_SOURCE) $(SQLITE_PATCHES) make/sqlite.mk
	$(MAKE) readline-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(SQLITE_DIR) $(@D)
	$(SQLITE_UNZIP) $(DL_DIR)/$(SQLITE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SQLITE_PATCHES)"; \
		then cat $(SQLITE_PATCHES) | patch -d $(BUILD_DIR)/$(SQLITE_DIR) -p1; \
	fi
	if test "$(BUILD_DIR)/$(SQLITE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SQLITE_DIR) $(@D) ; \
	fi
	if test -n "$(SQLITE_PATCHES)"; \
		then cd $(@D); autoreconf; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		config_BUILD_CC="$(HOSTCC)" \
		config_TARGET_CC="$(TARGET_CC)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-readline-inc="$(STAGING_CPPFLAGS) $(SQLITE_CPPFLAGS)" \
		--with-readline-lib="$(STAGING_LDFLAGS) $(SQLITE_LDFLAGS)" \
		--disable-nls \
		--disable-tcl \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	sed -i "/^shrext_cmds=/a shrext='.so'" $(@D)/libtool
	touch $@

sqlite-unpack: $(SQLITE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SQLITE_BUILD_DIR)/.built: $(SQLITE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
sqlite: $(SQLITE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SQLITE_BUILD_DIR)/.staged: $(SQLITE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/sqlite3.pc
	touch $@

sqlite-stage: $(SQLITE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sqlite
#
$(SQLITE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sqlite" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SQLITE_PRIORITY)" >>$@
	@echo "Section: $(SQLITE_SECTION)" >>$@
	@echo "Version: $(SQLITE_VERSION)-$(SQLITE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SQLITE_MAINTAINER)" >>$@
	@echo "Source: $(SQLITE_SITE)/$(SQLITE_SOURCE)" >>$@
	@echo "Description: $(SQLITE_DESCRIPTION)" >>$@
	@echo "Depends: $(SQLITE_DEPENDS)" >>$@
	@echo "Conflicts: $(SQLITE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SQLITE_IPK_DIR)/opt/sbin or $(SQLITE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SQLITE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SQLITE_IPK_DIR)/opt/etc/sqlite/...
# Documentation files should be installed in $(SQLITE_IPK_DIR)/opt/doc/sqlite/...
# Daemon startup scripts should be installed in $(SQLITE_IPK_DIR)/opt/etc/init.d/S??sqlite
#
# You may need to patch your application to make it use these locations.
#
$(SQLITE_IPK): $(SQLITE_BUILD_DIR)/.built
	rm -rf $(SQLITE_IPK_DIR) $(BUILD_DIR)/sqlite_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SQLITE_BUILD_DIR) DESTDIR=$(SQLITE_IPK_DIR) install
	$(STRIP_COMMAND) $(SQLITE_IPK_DIR)/opt/bin/sqlite3 $(SQLITE_IPK_DIR)/opt/lib/*.so
	rm -f $(SQLITE_IPK_DIR)/opt/lib/libsqlite3.a
	$(MAKE) $(SQLITE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SQLITE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sqlite-ipk: $(SQLITE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sqlite-clean:
	rm -f $(SQLITE_BUILD_DIR)/.built
	-$(MAKE) -C $(SQLITE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sqlite-dirclean:
	rm -rf $(BUILD_DIR)/$(SQLITE_DIR) $(SQLITE_BUILD_DIR) $(SQLITE_IPK_DIR) $(SQLITE_IPK)

#
# Some sanity check for the package.
#
sqlite-check: $(SQLITE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SQLITE_IPK)
