###########################################################
#
# unixodbc
#
###########################################################
#
# UNIXODBC_VERSION, UNIXODBC_SITE and UNIXODBC_SOURCE define
# the upstream location of the source code for the package.
# UNIXODBC_DIR is the directory which is created when the source
# archive is unpacked.
# UNIXODBC_UNZIP is the command used to unzip the source.
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
UNIXODBC_SITE=http://www.unixodbc.org
UNIXODBC_VERSION=2.2.14
UNIXODBC_SOURCE=unixODBC-$(UNIXODBC_VERSION).tar.gz
UNIXODBC_DIR=unixODBC-$(UNIXODBC_VERSION)
UNIXODBC_UNZIP=zcat
UNIXODBC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UNIXODBC_DESCRIPTION=ODBC is an open specification for providing \
application developers with a predictable API with which to access Data Sources.
UNIXODBC_SECTION=util
UNIXODBC_PRIORITY=optional
UNIXODBC_DEPENDS=libtool
UNIXODBC_SUGGESTS=
UNIXODBC_CONFLICTS=

#
# UNIXODBC_IPK_VERSION should be incremented when the ipk changes.
#
UNIXODBC_IPK_VERSION=1

#
# UNIXODBC_CONFFILES should be a list of user-editable files
UNIXODBC_CONFFILES=/opt/etc/odbc.ini /opt/etc/odbcinst.ini

#
# UNIXODBC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(HOSTCC), $(TARGET_CC))
UNIXODBC_PATCHES=$(UNIXODBC_SOURCE_DIR)/odbc_config.host.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UNIXODBC_CPPFLAGS=
UNIXODBC_LDFLAGS=

#
# UNIXODBC_BUILD_DIR is the directory in which the build is done.
# UNIXODBC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UNIXODBC_IPK_DIR is the directory in which the ipk is built.
# UNIXODBC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UNIXODBC_BUILD_DIR=$(BUILD_DIR)/unixodbc
UNIXODBC_SOURCE_DIR=$(SOURCE_DIR)/unixodbc
UNIXODBC_IPK_DIR=$(BUILD_DIR)/unixodbc-$(UNIXODBC_VERSION)-ipk
UNIXODBC_IPK=$(BUILD_DIR)/unixodbc_$(UNIXODBC_VERSION)-$(UNIXODBC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: unixodbc-source unixodbc-unpack unixodbc unixodbc-stage unixodbc-ipk unixodbc-clean unixodbc-dirclean unixodbc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UNIXODBC_SOURCE):
	$(WGET) -P $(@D) $(UNIXODBC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
unixodbc-source: $(DL_DIR)/$(UNIXODBC_SOURCE) $(UNIXODBC_PATCHES)

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
$(UNIXODBC_BUILD_DIR)/.configured: $(DL_DIR)/$(UNIXODBC_SOURCE) $(UNIXODBC_PATCHES) make/unixodbc.mk
	$(MAKE) libtool-stage
	rm -rf $(BUILD_DIR)/$(UNIXODBC_DIR) $(@D)
	$(UNIXODBC_UNZIP) $(DL_DIR)/$(UNIXODBC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UNIXODBC_PATCHES)" ; \
		then cat $(UNIXODBC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(UNIXODBC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UNIXODBC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(UNIXODBC_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UNIXODBC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UNIXODBC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--enable-gui=no \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

unixodbc-unpack: $(UNIXODBC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UNIXODBC_BUILD_DIR)/.built: $(UNIXODBC_BUILD_DIR)/.configured
	rm -f $@
ifneq ($(HOSTCC), $(TARGET_CC))
	$(MAKE) -C $(@D)/exe odbc_config.host
endif
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
unixodbc: $(UNIXODBC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UNIXODBC_BUILD_DIR)/.staged: $(UNIXODBC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

unixodbc-stage: $(UNIXODBC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/unixodbc
#
$(UNIXODBC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: unixodbc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UNIXODBC_PRIORITY)" >>$@
	@echo "Section: $(UNIXODBC_SECTION)" >>$@
	@echo "Version: $(UNIXODBC_VERSION)-$(UNIXODBC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UNIXODBC_MAINTAINER)" >>$@
	@echo "Source: $(UNIXODBC_SITE)/$(UNIXODBC_SOURCE)" >>$@
	@echo "Description: $(UNIXODBC_DESCRIPTION)" >>$@
	@echo "Depends: $(UNIXODBC_DEPENDS)" >>$@
	@echo "Suggests: $(UNIXODBC_SUGGESTS)" >>$@
	@echo "Conflicts: $(UNIXODBC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UNIXODBC_IPK_DIR)/opt/sbin or $(UNIXODBC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UNIXODBC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UNIXODBC_IPK_DIR)/opt/etc/unixodbc/...
# Documentation files should be installed in $(UNIXODBC_IPK_DIR)/opt/doc/unixodbc/...
# Daemon startup scripts should be installed in $(UNIXODBC_IPK_DIR)/opt/etc/init.d/S??unixodbc
#
# You may need to patch your application to make it use these locations.
#
$(UNIXODBC_IPK): $(UNIXODBC_BUILD_DIR)/.built
	rm -rf $(UNIXODBC_IPK_DIR) $(BUILD_DIR)/unixodbc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(UNIXODBC_BUILD_DIR) DESTDIR=$(UNIXODBC_IPK_DIR) install-strip
	$(MAKE) $(UNIXODBC_IPK_DIR)/CONTROL/control
	echo $(UNIXODBC_CONFFILES) | sed -e 's/ /\n/g' > $(UNIXODBC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNIXODBC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
unixodbc-ipk: $(UNIXODBC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
unixodbc-clean:
	rm -f $(UNIXODBC_BUILD_DIR)/.built
	-$(MAKE) -C $(UNIXODBC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
unixodbc-dirclean:
	rm -rf $(BUILD_DIR)/$(UNIXODBC_DIR) $(UNIXODBC_BUILD_DIR) $(UNIXODBC_IPK_DIR) $(UNIXODBC_IPK)
#
#
# Some sanity check for the package.
#
unixodbc-check: $(UNIXODBC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
