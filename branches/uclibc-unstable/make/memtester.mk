###########################################################
#
# memtester
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
MEMTESTER_SITE=http://pyropus.ca/software/memtester/old-versions
MEMTESTER_VERSION=4.0.6
MEMTESTER_SOURCE=memtester-$(MEMTESTER_VERSION).tar.gz
MEMTESTER_DIR=memtester-$(MEMTESTER_VERSION)
MEMTESTER_UNZIP=zcat
MEMTESTER_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
MEMTESTER_DESCRIPTION=A runtime memtest utility
MEMTESTER_SECTION=sysutil
MEMTESTER_PRIORITY=optional
MEMTESTER_DEPENDS=
MEMTESTER_SUGGESTS=
MEMTESTER_CONFLICTS=

#
# MEMTESTER_IPK_VERSION should be incremented when the ipk changes.
#
MEMTESTER_IPK_VERSION=1

#
# MEMTESTER_CONFFILES should be a list of user-editable files
# MEMTESTER_CONFFILES=/opt/etc/memtester.conf /opt/etc/init.d/SXXmemtester

#
# MEMTESTER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# MEMTESTER_PATCHES=$(MEMTESTER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MEMTESTER_CPPFLAGS=
MEMTESTER_LDFLAGS=

#
# MEMTESTER_BUILD_DIR is the directory in which the build is done.
# MEMTESTER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MEMTESTER_IPK_DIR is the directory in which the ipk is built.
# MEMTESTER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MEMTESTER_BUILD_DIR=$(BUILD_DIR)/memtester
MEMTESTER_SOURCE_DIR=$(SOURCE_DIR)/memtester
MEMTESTER_IPK_DIR=$(BUILD_DIR)/memtester-$(MEMTESTER_VERSION)-ipk
MEMTESTER_IPK=$(BUILD_DIR)/memtester_$(MEMTESTER_VERSION)-$(MEMTESTER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: memtester-source memtester-unpack memtester memtester-stage memtester-ipk memtester-clean memtester-dirclean memtester-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MEMTESTER_SOURCE):
	$(WGET) -P $(DL_DIR) $(MEMTESTER_SITE)/$(MEMTESTER_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(MEMTESTER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
memtester-source: $(DL_DIR)/$(MEMTESTER_SOURCE) $(MEMTESTER_PATCHES)

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
$(MEMTESTER_BUILD_DIR)/.configured: $(DL_DIR)/$(MEMTESTER_SOURCE) $(MEMTESTER_PATCHES) make/memtester.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MEMTESTER_DIR) $(MEMTESTER_BUILD_DIR)
	$(MEMTESTER_UNZIP) $(DL_DIR)/$(MEMTESTER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MEMTESTER_PATCHES)" ; \
		then cat $(MEMTESTER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MEMTESTER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MEMTESTER_DIR)" != "$(MEMTESTER_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MEMTESTER_DIR) $(MEMTESTER_BUILD_DIR) ; \
	fi
	#(cd $(MEMTESTER_BUILD_DIR); \
	#	$(TARGET_CONFIGURE_OPTS) \
	#	CPPFLAGS="$(STAGING_CPPFLAGS) $(MEMTESTER_CPPFLAGS)" \
	#	LDFLAGS="$(STAGING_LDFLAGS) $(MEMTESTER_LDFLAGS)" \
	#	./configure \
	#	--build=$(GNU_HOST_NAME) \
	#	--host=$(GNU_TARGET_NAME) \
	#	--target=$(GNU_TARGET_NAME) \
	#	--prefix=/opt \
	#	--disable-nls \
	#	--disable-static \
	#)
	#$(PATCH_LIBTOOL) $(MEMTESTER_BUILD_DIR)/libtool
	cd $(MEMTESTER_BUILD_DIR); \
		sed -i 's#^cc#$(TARGET_CC) $(STAGING_CPPFLAGS) $(MEMTESTER_CPPFLAGS) #' conf-cc; \
		sed -i 's#cc -s#$(TARGET_CC) -s $(STAGING_LDFLAGS) $(MEMTESTER_LDFLAGS)#' conf-ld;
	touch $@

memtester-unpack: $(MEMTESTER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MEMTESTER_BUILD_DIR)/.built: $(MEMTESTER_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(VBLADE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(VBLADE_LDFLAGS)" \
		$(MAKE) -C $(MEMTESTER_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
memtester: $(MEMTESTER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MEMTESTER_BUILD_DIR)/.staged: $(MEMTESTER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(MEMTESTER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

memtester-stage: $(MEMTESTER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/memtester
#
$(MEMTESTER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: memtester" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MEMTESTER_PRIORITY)" >>$@
	@echo "Section: $(MEMTESTER_SECTION)" >>$@
	@echo "Version: $(MEMTESTER_VERSION)-$(MEMTESTER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MEMTESTER_MAINTAINER)" >>$@
	@echo "Source: $(MEMTESTER_SITE)/$(MEMTESTER_SOURCE)" >>$@
	@echo "Description: $(MEMTESTER_DESCRIPTION)" >>$@
	@echo "Depends: $(MEMTESTER_DEPENDS)" >>$@
	@echo "Suggests: $(MEMTESTER_SUGGESTS)" >>$@
	@echo "Conflicts: $(MEMTESTER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MEMTESTER_IPK_DIR)/opt/sbin or $(MEMTESTER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MEMTESTER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MEMTESTER_IPK_DIR)/opt/etc/memtester/...
# Documentation files should be installed in $(MEMTESTER_IPK_DIR)/opt/doc/memtester/...
# Daemon startup scripts should be installed in $(MEMTESTER_IPK_DIR)/opt/etc/init.d/S??memtester
#
# You may need to patch your application to make it use these locations.
#
$(MEMTESTER_IPK): $(MEMTESTER_BUILD_DIR)/.built
	rm -rf $(MEMTESTER_IPK_DIR) $(BUILD_DIR)/memtester_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MEMTESTER_BUILD_DIR) INSTALLPATH=$(MEMTESTER_IPK_DIR)/opt install
	#install -d $(MEMTESTER_IPK_DIR)/opt/etc/
	#install -m 644 $(MEMTESTER_SOURCE_DIR)/memtester.conf $(MEMTESTER_IPK_DIR)/opt/etc/memtester.conf
	#install -d $(MEMTESTER_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(MEMTESTER_SOURCE_DIR)/rc.memtester $(MEMTESTER_IPK_DIR)/opt/etc/init.d/SXXmemtester
	#sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEMTESTER_IPK_DIR)/opt/etc/init.d/SXXmemtester
	$(MAKE) $(MEMTESTER_IPK_DIR)/CONTROL/control
	#install -m 755 $(MEMTESTER_SOURCE_DIR)/postinst $(MEMTESTER_IPK_DIR)/CONTROL/postinst
	#sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEMTESTER_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(MEMTESTER_SOURCE_DIR)/prerm $(MEMTESTER_IPK_DIR)/CONTROL/prerm
	#sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEMTESTER_IPK_DIR)/CONTROL/prerm
	#echo $(MEMTESTER_CONFFILES) | sed -e 's/ /\n/g' > $(MEMTESTER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MEMTESTER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
memtester-ipk: $(MEMTESTER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
memtester-clean:
	rm -f $(MEMTESTER_BUILD_DIR)/.built
	-$(MAKE) -C $(MEMTESTER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
memtester-dirclean:
	rm -rf $(BUILD_DIR)/$(MEMTESTER_DIR) $(MEMTESTER_BUILD_DIR) $(MEMTESTER_IPK_DIR) $(MEMTESTER_IPK)
#
#
# Some sanity check for the package.
#
memtester-check: $(MEMTESTER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MEMTESTER_IPK)
