###########################################################
#
# davtools
#
###########################################################
#
# DAVTOOLS_VERSION, DAVTOOLS_SITE and DAVTOOLS_SOURCE define
# the upstream location of the source code for the package.
# DAVTOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# DAVTOOLS_UNZIP is the command used to unzip the source.
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
DAVTOOLS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/davtools
DAVTOOLS_VERSION=1.2.0
DAVTOOLS_SOURCE=davl-$(DAVTOOLS_VERSION).tar.bz2
DAVTOOLS_DIR=davl-$(DAVTOOLS_VERSION)
DAVTOOLS_UNZIP=bzcat
DAVTOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DAVTOOLS_DESCRIPTION=Disk Allocation Viewer - obtain the state of fragmentation on disk.
DAVTOOLS_SECTION=admin
DAVTOOLS_PRIORITY=optional
DAVTOOLS_DEPENDS=e2fsprogs
DAVTOOLS_SUGGESTS=
DAVTOOLS_CONFLICTS=

#
# DAVTOOLS_IPK_VERSION should be incremented when the ipk changes.
#
DAVTOOLS_IPK_VERSION=1

#
# DAVTOOLS_CONFFILES should be a list of user-editable files
#DAVTOOLS_CONFFILES=/opt/etc/davtools.conf /opt/etc/init.d/SXXdavtools

#
# DAVTOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DAVTOOLS_PATCHES=$(DAVTOOLS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DAVTOOLS_CPPFLAGS=
DAVTOOLS_LDFLAGS=

#
# DAVTOOLS_BUILD_DIR is the directory in which the build is done.
# DAVTOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DAVTOOLS_IPK_DIR is the directory in which the ipk is built.
# DAVTOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DAVTOOLS_BUILD_DIR=$(BUILD_DIR)/davtools
DAVTOOLS_SOURCE_DIR=$(SOURCE_DIR)/davtools
DAVTOOLS_IPK_DIR=$(BUILD_DIR)/davtools-$(DAVTOOLS_VERSION)-ipk
DAVTOOLS_IPK=$(BUILD_DIR)/davtools_$(DAVTOOLS_VERSION)-$(DAVTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: davtools-source davtools-unpack davtools davtools-stage davtools-ipk davtools-clean davtools-dirclean davtools-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DAVTOOLS_SOURCE):
	$(WGET) -P $(DL_DIR) $(DAVTOOLS_SITE)/$(DAVTOOLS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(DAVTOOLS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
davtools-source: $(DL_DIR)/$(DAVTOOLS_SOURCE) $(DAVTOOLS_PATCHES)

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
$(DAVTOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(DAVTOOLS_SOURCE) $(DAVTOOLS_PATCHES) make/davtools.mk
	$(MAKE) e2fsprogs-stage
	rm -rf $(BUILD_DIR)/$(DAVTOOLS_DIR) $(DAVTOOLS_BUILD_DIR)
	$(DAVTOOLS_UNZIP) $(DL_DIR)/$(DAVTOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DAVTOOLS_PATCHES)" ; \
		then cat $(DAVTOOLS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DAVTOOLS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DAVTOOLS_DIR)" != "$(DAVTOOLS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DAVTOOLS_DIR) $(DAVTOOLS_BUILD_DIR) ; \
	fi
	sed -i -e '/^CC/d' -e 's/^CFLAGS =/CFLAGS +=/' \
		$(DAVTOOLS_BUILD_DIR)/src/*/Makefile
	touch $@

davtools-unpack: $(DAVTOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DAVTOOLS_BUILD_DIR)/.built: $(DAVTOOLS_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(STAGING_CPPFLAGS) $(DAVTOOLS_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(DAVTOOLS_LDFLAGS)" \
	$(MAKE) -C $(DAVTOOLS_BUILD_DIR)/src/common
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(STAGING_CPPFLAGS) $(DAVTOOLS_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(DAVTOOLS_LDFLAGS)" \
	$(MAKE) -C $(DAVTOOLS_BUILD_DIR)/src/cdavl
	touch $@

#
# This is the build convenience target.
#
davtools: $(DAVTOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DAVTOOLS_BUILD_DIR)/.staged: $(DAVTOOLS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(DAVTOOLS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

davtools-stage: $(DAVTOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/davtools
#
$(DAVTOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: davtools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DAVTOOLS_PRIORITY)" >>$@
	@echo "Section: $(DAVTOOLS_SECTION)" >>$@
	@echo "Version: $(DAVTOOLS_VERSION)-$(DAVTOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DAVTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(DAVTOOLS_SITE)/$(DAVTOOLS_SOURCE)" >>$@
	@echo "Description: $(DAVTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(DAVTOOLS_DEPENDS)" >>$@
	@echo "Suggests: $(DAVTOOLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(DAVTOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DAVTOOLS_IPK_DIR)/opt/sbin or $(DAVTOOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DAVTOOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DAVTOOLS_IPK_DIR)/opt/etc/davtools/...
# Documentation files should be installed in $(DAVTOOLS_IPK_DIR)/opt/doc/davtools/...
# Daemon startup scripts should be installed in $(DAVTOOLS_IPK_DIR)/opt/etc/init.d/S??davtools
#
# You may need to patch your application to make it use these locations.
#
$(DAVTOOLS_IPK): $(DAVTOOLS_BUILD_DIR)/.built
	rm -rf $(DAVTOOLS_IPK_DIR) $(BUILD_DIR)/davtools_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(DAVTOOLS_BUILD_DIR) DESTDIR=$(DAVTOOLS_IPK_DIR) install-strip
	install -d $(DAVTOOLS_IPK_DIR)/opt/bin
	install -m 755 $(DAVTOOLS_BUILD_DIR)/src/cdavl/cdavl $(DAVTOOLS_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(DAVTOOLS_IPK_DIR)/opt/bin/cdavl
	install -d $(DAVTOOLS_IPK_DIR)/opt/man/man8
	install -m 644 $(DAVTOOLS_BUILD_DIR)/doc/cdavl.8 $(DAVTOOLS_IPK_DIR)/opt/man/man8/
#	install -m 755 $(DAVTOOLS_SOURCE_DIR)/rc.davtools $(DAVTOOLS_IPK_DIR)/opt/etc/init.d/SXXdavtools
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DAVTOOLS_IPK_DIR)/opt/etc/init.d/SXXdavtools
	$(MAKE) $(DAVTOOLS_IPK_DIR)/CONTROL/control
#	install -m 755 $(DAVTOOLS_SOURCE_DIR)/postinst $(DAVTOOLS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DAVTOOLS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(DAVTOOLS_SOURCE_DIR)/prerm $(DAVTOOLS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DAVTOOLS_IPK_DIR)/CONTROL/prerm
#	echo $(DAVTOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(DAVTOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DAVTOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
davtools-ipk: $(DAVTOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
davtools-clean:
	rm -f $(DAVTOOLS_BUILD_DIR)/.built
	-$(MAKE) -C $(DAVTOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
davtools-dirclean:
	rm -rf $(BUILD_DIR)/$(DAVTOOLS_DIR) $(DAVTOOLS_BUILD_DIR) $(DAVTOOLS_IPK_DIR) $(DAVTOOLS_IPK)
#
#
# Some sanity check for the package.
#
davtools-check: $(DAVTOOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DAVTOOLS_IPK)
