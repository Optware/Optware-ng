###########################################################
#
# diffstat
#
###########################################################
#
# DIFFSTAT_VERSION, DIFFSTAT_SITE and DIFFSTAT_SOURCE define
# the upstream location of the source code for the package.
# DIFFSTAT_DIR is the directory which is created when the source
# archive is unpacked.
# DIFFSTAT_UNZIP is the command used to unzip the source.
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
DIFFSTAT_SITE=ftp://invisible-island.net/diffstat
DIFFSTAT_VERSION=1.43
DIFFSTAT_SOURCE=diffstat-$(DIFFSTAT_VERSION).tgz
DIFFSTAT_DIR=diffstat-$(DIFFSTAT_VERSION)
DIFFSTAT_UNZIP=zcat
DIFFSTAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DIFFSTAT_DESCRIPTION=Diffstat reads the output of the diff command and displays a histogram of the insertions, deletions, and modifications in each file.
DIFFSTAT_SECTION=utils
DIFFSTAT_PRIORITY=optional
DIFFSTAT_DEPENDS=
DIFFSTAT_SUGGESTS=
DIFFSTAT_CONFLICTS=

#
# DIFFSTAT_IPK_VERSION should be incremented when the ipk changes.
#
DIFFSTAT_IPK_VERSION=1

#
# DIFFSTAT_CONFFILES should be a list of user-editable files
#DIFFSTAT_CONFFILES=/opt/etc/diffstat.conf /opt/etc/init.d/SXXdiffstat

#
# DIFFSTAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DIFFSTAT_PATCHES=$(DIFFSTAT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DIFFSTAT_CPPFLAGS=
DIFFSTAT_LDFLAGS=

#
# DIFFSTAT_BUILD_DIR is the directory in which the build is done.
# DIFFSTAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DIFFSTAT_IPK_DIR is the directory in which the ipk is built.
# DIFFSTAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DIFFSTAT_BUILD_DIR=$(BUILD_DIR)/diffstat
DIFFSTAT_SOURCE_DIR=$(SOURCE_DIR)/diffstat
DIFFSTAT_IPK_DIR=$(BUILD_DIR)/diffstat-$(DIFFSTAT_VERSION)-ipk
DIFFSTAT_IPK=$(BUILD_DIR)/diffstat_$(DIFFSTAT_VERSION)-$(DIFFSTAT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: diffstat-source diffstat-unpack diffstat diffstat-stage diffstat-ipk diffstat-clean diffstat-dirclean diffstat-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DIFFSTAT_SOURCE):
	$(WGET) -P $(DL_DIR) $(DIFFSTAT_SITE)/$(DIFFSTAT_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(DIFFSTAT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
diffstat-source: $(DL_DIR)/$(DIFFSTAT_SOURCE) $(DIFFSTAT_PATCHES)

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
$(DIFFSTAT_BUILD_DIR)/.configured: $(DL_DIR)/$(DIFFSTAT_SOURCE) $(DIFFSTAT_PATCHES) make/diffstat.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DIFFSTAT_DIR) $(DIFFSTAT_BUILD_DIR)
	$(DIFFSTAT_UNZIP) $(DL_DIR)/$(DIFFSTAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DIFFSTAT_PATCHES)" ; \
		then cat $(DIFFSTAT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DIFFSTAT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DIFFSTAT_DIR)" != "$(DIFFSTAT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DIFFSTAT_DIR) $(DIFFSTAT_BUILD_DIR) ; \
	fi
	(cd $(DIFFSTAT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DIFFSTAT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DIFFSTAT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(DIFFSTAT_BUILD_DIR)/libtool
	touch $@

diffstat-unpack: $(DIFFSTAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DIFFSTAT_BUILD_DIR)/.built: $(DIFFSTAT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(DIFFSTAT_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
diffstat: $(DIFFSTAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DIFFSTAT_BUILD_DIR)/.staged: $(DIFFSTAT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(DIFFSTAT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

diffstat-stage: $(DIFFSTAT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/diffstat
#
$(DIFFSTAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: diffstat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DIFFSTAT_PRIORITY)" >>$@
	@echo "Section: $(DIFFSTAT_SECTION)" >>$@
	@echo "Version: $(DIFFSTAT_VERSION)-$(DIFFSTAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DIFFSTAT_MAINTAINER)" >>$@
	@echo "Source: $(DIFFSTAT_SITE)/$(DIFFSTAT_SOURCE)" >>$@
	@echo "Description: $(DIFFSTAT_DESCRIPTION)" >>$@
	@echo "Depends: $(DIFFSTAT_DEPENDS)" >>$@
	@echo "Suggests: $(DIFFSTAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(DIFFSTAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DIFFSTAT_IPK_DIR)/opt/sbin or $(DIFFSTAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DIFFSTAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DIFFSTAT_IPK_DIR)/opt/etc/diffstat/...
# Documentation files should be installed in $(DIFFSTAT_IPK_DIR)/opt/doc/diffstat/...
# Daemon startup scripts should be installed in $(DIFFSTAT_IPK_DIR)/opt/etc/init.d/S??diffstat
#
# You may need to patch your application to make it use these locations.
#
$(DIFFSTAT_IPK): $(DIFFSTAT_BUILD_DIR)/.built
	rm -rf $(DIFFSTAT_IPK_DIR) $(BUILD_DIR)/diffstat_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DIFFSTAT_BUILD_DIR) DESTDIR=$(DIFFSTAT_IPK_DIR) install
	$(STRIP_COMMAND) $(DIFFSTAT_IPK_DIR)/opt/bin/diffstat
#	install -d $(DIFFSTAT_IPK_DIR)/opt/etc/
#	install -m 644 $(DIFFSTAT_SOURCE_DIR)/diffstat.conf $(DIFFSTAT_IPK_DIR)/opt/etc/diffstat.conf
#	install -d $(DIFFSTAT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(DIFFSTAT_SOURCE_DIR)/rc.diffstat $(DIFFSTAT_IPK_DIR)/opt/etc/init.d/SXXdiffstat
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DIFFSTAT_IPK_DIR)/opt/etc/init.d/SXXdiffstat
	$(MAKE) $(DIFFSTAT_IPK_DIR)/CONTROL/control
#	install -m 755 $(DIFFSTAT_SOURCE_DIR)/postinst $(DIFFSTAT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DIFFSTAT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(DIFFSTAT_SOURCE_DIR)/prerm $(DIFFSTAT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DIFFSTAT_IPK_DIR)/CONTROL/prerm
	echo $(DIFFSTAT_CONFFILES) | sed -e 's/ /\n/g' > $(DIFFSTAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DIFFSTAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
diffstat-ipk: $(DIFFSTAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
diffstat-clean:
	rm -f $(DIFFSTAT_BUILD_DIR)/.built
	-$(MAKE) -C $(DIFFSTAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
diffstat-dirclean:
	rm -rf $(BUILD_DIR)/$(DIFFSTAT_DIR) $(DIFFSTAT_BUILD_DIR) $(DIFFSTAT_IPK_DIR) $(DIFFSTAT_IPK)
#
#
# Some sanity check for the package.
#
diffstat-check: $(DIFFSTAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DIFFSTAT_IPK)
