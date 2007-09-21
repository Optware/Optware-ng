###########################################################
#
# msynctool
#
###########################################################
#
# MSYNCTOOL_VERSION, MSYNCTOOL_SITE and MSYNCTOOL_SOURCE define
# the upstream location of the source code for the package.
# MSYNCTOOL_DIR is the directory which is created when the source
# archive is unpacked.
# MSYNCTOOL_UNZIP is the command used to unzip the source.
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
MSYNCTOOL_SITE=http://www.opensync.org/attachment/wiki/download
MSYNCTOOL_VERSION=0.22
MSYNCTOOL_SOURCE=msynctool-$(MSYNCTOOL_VERSION).tar.bz2
MSYNCTOOL_DIR=msynctool-$(MSYNCTOOL_VERSION)
MSYNCTOOL_UNZIP=bzcat
MSYNCTOOL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MSYNCTOOL_DESCRIPTION=CLI for opensync.
MSYNCTOOL_SECTION=misc
MSYNCTOOL_PRIORITY=optional
MSYNCTOOL_DEPENDS=libopensync, libxml2
MSYNCTOOL_SUGGESTS=
MSYNCTOOL_CONFLICTS=

#
# MSYNCTOOL_IPK_VERSION should be incremented when the ipk changes.
#
MSYNCTOOL_IPK_VERSION=1

#
# MSYNCTOOL_CONFFILES should be a list of user-editable files
#MSYNCTOOL_CONFFILES=/opt/etc/msynctool.conf /opt/etc/init.d/SXXmsynctool

#
# MSYNCTOOL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MSYNCTOOL_PATCHES=$(MSYNCTOOL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MSYNCTOOL_CPPFLAGS=
MSYNCTOOL_LDFLAGS=

#
# MSYNCTOOL_BUILD_DIR is the directory in which the build is done.
# MSYNCTOOL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MSYNCTOOL_IPK_DIR is the directory in which the ipk is built.
# MSYNCTOOL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MSYNCTOOL_BUILD_DIR=$(BUILD_DIR)/msynctool
MSYNCTOOL_SOURCE_DIR=$(SOURCE_DIR)/msynctool
MSYNCTOOL_IPK_DIR=$(BUILD_DIR)/msynctool-$(MSYNCTOOL_VERSION)-ipk
MSYNCTOOL_IPK=$(BUILD_DIR)/msynctool_$(MSYNCTOOL_VERSION)-$(MSYNCTOOL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: msynctool-source msynctool-unpack msynctool msynctool-stage msynctool-ipk msynctool-clean msynctool-dirclean msynctool-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MSYNCTOOL_SOURCE):
	$(WGET) -O $(DL_DIR)/$(MSYNCTOOL_SOURCE) "$(MSYNCTOOL_SITE)/$(MSYNCTOOL_SOURCE)?rev=&format=raw" || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(MSYNCTOOL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
msynctool-source: $(DL_DIR)/$(MSYNCTOOL_SOURCE) $(MSYNCTOOL_PATCHES)

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
$(MSYNCTOOL_BUILD_DIR)/.configured: $(DL_DIR)/$(MSYNCTOOL_SOURCE) $(MSYNCTOOL_PATCHES) make/msynctool.mk
	$(MAKE) libopensync-stage
	$(MAKE) libxml2-stage
	rm -rf $(BUILD_DIR)/$(MSYNCTOOL_DIR) $(MSYNCTOOL_BUILD_DIR)
	$(MSYNCTOOL_UNZIP) $(DL_DIR)/$(MSYNCTOOL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MSYNCTOOL_PATCHES)" ; \
		then cat $(MSYNCTOOL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MSYNCTOOL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MSYNCTOOL_DIR)" != "$(MSYNCTOOL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MSYNCTOOL_DIR) $(MSYNCTOOL_BUILD_DIR) ; \
	fi
	(cd $(MSYNCTOOL_BUILD_DIR); \
		ACLOCAL=aclocal-1.9 AUTOMAKE=automake-1.9 \
			autoreconf -sfi; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MSYNCTOOL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MSYNCTOOL_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		PATH=$(STAGING_PREFIX)/bin:$$PATH \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-python \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(MSYNCTOOL_BUILD_DIR)/libtool
	touch $@

msynctool-unpack: $(MSYNCTOOL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MSYNCTOOL_BUILD_DIR)/.built: $(MSYNCTOOL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MSYNCTOOL_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
msynctool: $(MSYNCTOOL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MSYNCTOOL_BUILD_DIR)/.staged: $(MSYNCTOOL_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(MSYNCTOOL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

msynctool-stage: $(MSYNCTOOL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/msynctool
#
$(MSYNCTOOL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: msynctool" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MSYNCTOOL_PRIORITY)" >>$@
	@echo "Section: $(MSYNCTOOL_SECTION)" >>$@
	@echo "Version: $(MSYNCTOOL_VERSION)-$(MSYNCTOOL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MSYNCTOOL_MAINTAINER)" >>$@
	@echo "Source: $(MSYNCTOOL_SITE)/$(MSYNCTOOL_SOURCE)" >>$@
	@echo "Description: $(MSYNCTOOL_DESCRIPTION)" >>$@
	@echo "Depends: $(MSYNCTOOL_DEPENDS)" >>$@
	@echo "Suggests: $(MSYNCTOOL_SUGGESTS)" >>$@
	@echo "Conflicts: $(MSYNCTOOL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MSYNCTOOL_IPK_DIR)/opt/sbin or $(MSYNCTOOL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MSYNCTOOL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MSYNCTOOL_IPK_DIR)/opt/etc/msynctool/...
# Documentation files should be installed in $(MSYNCTOOL_IPK_DIR)/opt/doc/msynctool/...
# Daemon startup scripts should be installed in $(MSYNCTOOL_IPK_DIR)/opt/etc/init.d/S??msynctool
#
# You may need to patch your application to make it use these locations.
#
$(MSYNCTOOL_IPK): $(MSYNCTOOL_BUILD_DIR)/.built
	rm -rf $(MSYNCTOOL_IPK_DIR) $(BUILD_DIR)/msynctool_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MSYNCTOOL_BUILD_DIR) DESTDIR=$(MSYNCTOOL_IPK_DIR) install-strip
#	install -d $(MSYNCTOOL_IPK_DIR)/opt/etc/
#	install -m 644 $(MSYNCTOOL_SOURCE_DIR)/msynctool.conf $(MSYNCTOOL_IPK_DIR)/opt/etc/msynctool.conf
#	install -d $(MSYNCTOOL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MSYNCTOOL_SOURCE_DIR)/rc.msynctool $(MSYNCTOOL_IPK_DIR)/opt/etc/init.d/SXXmsynctool
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MSYNCTOOL_IPK_DIR)/opt/etc/init.d/SXXmsynctool
	$(MAKE) $(MSYNCTOOL_IPK_DIR)/CONTROL/control
#	install -m 755 $(MSYNCTOOL_SOURCE_DIR)/postinst $(MSYNCTOOL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MSYNCTOOL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MSYNCTOOL_SOURCE_DIR)/prerm $(MSYNCTOOL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MSYNCTOOL_IPK_DIR)/CONTROL/prerm
	echo $(MSYNCTOOL_CONFFILES) | sed -e 's/ /\n/g' > $(MSYNCTOOL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MSYNCTOOL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
msynctool-ipk: $(MSYNCTOOL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
msynctool-clean:
	rm -f $(MSYNCTOOL_BUILD_DIR)/.built
	-$(MAKE) -C $(MSYNCTOOL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
msynctool-dirclean:
	rm -rf $(BUILD_DIR)/$(MSYNCTOOL_DIR) $(MSYNCTOOL_BUILD_DIR) $(MSYNCTOOL_IPK_DIR) $(MSYNCTOOL_IPK)
#
#
# Some sanity check for the package.
#
msynctool-check: $(MSYNCTOOL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MSYNCTOOL_IPK)
