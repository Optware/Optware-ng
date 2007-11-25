###########################################################
#
# softflowd
#
###########################################################
#
# SOFTFLOWD_VERSION, SOFTFLOWD_SITE and SOFTFLOWD_SOURCE define
# the upstream location of the source code for the package.
# SOFTFLOWD_DIR is the directory which is created when the source
# archive is unpacked.
# SOFTFLOWD_UNZIP is the command used to unzip the source.
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
SOFTFLOWD_SITE=http://www.mindrot.org/files/softflowd
SOFTFLOWD_VERSION=0.9.8
SOFTFLOWD_SOURCE=softflowd-$(SOFTFLOWD_VERSION).tar.gz
SOFTFLOWD_DIR=softflowd-$(SOFTFLOWD_VERSION)
SOFTFLOWD_UNZIP=zcat
SOFTFLOWD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SOFTFLOWD_DESCRIPTION=Softflowd is flow-based network traffic analyser capable of Cisco NetFlow(tm) data export.
SOFTFLOWD_SECTION=net
SOFTFLOWD_PRIORITY=optional
SOFTFLOWD_DEPENDS=
SOFTFLOWD_SUGGESTS=
SOFTFLOWD_CONFLICTS=

#
# SOFTFLOWD_IPK_VERSION should be incremented when the ipk changes.
#
SOFTFLOWD_IPK_VERSION=1

#
# SOFTFLOWD_CONFFILES should be a list of user-editable files
#SOFTFLOWD_CONFFILES=/opt/etc/softflowd.conf /opt/etc/init.d/SXXsoftflowd

#
# SOFTFLOWD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SOFTFLOWD_PATCHES=$(SOFTFLOWD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SOFTFLOWD_CPPFLAGS=
SOFTFLOWD_LDFLAGS=

#
# SOFTFLOWD_BUILD_DIR is the directory in which the build is done.
# SOFTFLOWD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SOFTFLOWD_IPK_DIR is the directory in which the ipk is built.
# SOFTFLOWD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SOFTFLOWD_BUILD_DIR=$(BUILD_DIR)/softflowd
SOFTFLOWD_SOURCE_DIR=$(SOURCE_DIR)/softflowd
SOFTFLOWD_IPK_DIR=$(BUILD_DIR)/softflowd-$(SOFTFLOWD_VERSION)-ipk
SOFTFLOWD_IPK=$(BUILD_DIR)/softflowd_$(SOFTFLOWD_VERSION)-$(SOFTFLOWD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: softflowd-source softflowd-unpack softflowd softflowd-stage softflowd-ipk softflowd-clean softflowd-dirclean softflowd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SOFTFLOWD_SOURCE):
	$(WGET) -P $(DL_DIR) $(SOFTFLOWD_SITE)/$(SOFTFLOWD_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SOFTFLOWD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
softflowd-source: $(DL_DIR)/$(SOFTFLOWD_SOURCE) $(SOFTFLOWD_PATCHES)

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
$(SOFTFLOWD_BUILD_DIR)/.configured: $(DL_DIR)/$(SOFTFLOWD_SOURCE) $(SOFTFLOWD_PATCHES) make/softflowd.mk
	$(MAKE) libpcap-stage
	rm -rf $(BUILD_DIR)/$(SOFTFLOWD_DIR) $(SOFTFLOWD_BUILD_DIR)
	$(SOFTFLOWD_UNZIP) $(DL_DIR)/$(SOFTFLOWD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SOFTFLOWD_PATCHES)" ; \
		then cat $(SOFTFLOWD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SOFTFLOWD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SOFTFLOWD_DIR)" != "$(SOFTFLOWD_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SOFTFLOWD_DIR) $(SOFTFLOWD_BUILD_DIR) ; \
	fi
	sed -i -e '/$$(INSTALL)/s/-s //' $(@D)/Makefile.in
	(cd $(SOFTFLOWD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SOFTFLOWD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SOFTFLOWD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(SOFTFLOWD_BUILD_DIR)/libtool
	touch $@

softflowd-unpack: $(SOFTFLOWD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SOFTFLOWD_BUILD_DIR)/.built: $(SOFTFLOWD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SOFTFLOWD_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
softflowd: $(SOFTFLOWD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SOFTFLOWD_BUILD_DIR)/.staged: $(SOFTFLOWD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SOFTFLOWD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

softflowd-stage: $(SOFTFLOWD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/softflowd
#
$(SOFTFLOWD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: softflowd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SOFTFLOWD_PRIORITY)" >>$@
	@echo "Section: $(SOFTFLOWD_SECTION)" >>$@
	@echo "Version: $(SOFTFLOWD_VERSION)-$(SOFTFLOWD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SOFTFLOWD_MAINTAINER)" >>$@
	@echo "Source: $(SOFTFLOWD_SITE)/$(SOFTFLOWD_SOURCE)" >>$@
	@echo "Description: $(SOFTFLOWD_DESCRIPTION)" >>$@
	@echo "Depends: $(SOFTFLOWD_DEPENDS)" >>$@
	@echo "Suggests: $(SOFTFLOWD_SUGGESTS)" >>$@
	@echo "Conflicts: $(SOFTFLOWD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SOFTFLOWD_IPK_DIR)/opt/sbin or $(SOFTFLOWD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SOFTFLOWD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SOFTFLOWD_IPK_DIR)/opt/etc/softflowd/...
# Documentation files should be installed in $(SOFTFLOWD_IPK_DIR)/opt/doc/softflowd/...
# Daemon startup scripts should be installed in $(SOFTFLOWD_IPK_DIR)/opt/etc/init.d/S??softflowd
#
# You may need to patch your application to make it use these locations.
#
$(SOFTFLOWD_IPK): $(SOFTFLOWD_BUILD_DIR)/.built
	rm -rf $(SOFTFLOWD_IPK_DIR) $(BUILD_DIR)/softflowd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SOFTFLOWD_BUILD_DIR) DESTDIR=$(SOFTFLOWD_IPK_DIR) install
	$(STRIP_COMMAND) $(SOFTFLOWD_IPK_DIR)/opt/sbin/*
	$(MAKE) $(SOFTFLOWD_IPK_DIR)/CONTROL/control
	echo $(SOFTFLOWD_CONFFILES) | sed -e 's/ /\n/g' > $(SOFTFLOWD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SOFTFLOWD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
softflowd-ipk: $(SOFTFLOWD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
softflowd-clean:
	rm -f $(SOFTFLOWD_BUILD_DIR)/.built
	-$(MAKE) -C $(SOFTFLOWD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
softflowd-dirclean:
	rm -rf $(BUILD_DIR)/$(SOFTFLOWD_DIR) $(SOFTFLOWD_BUILD_DIR) $(SOFTFLOWD_IPK_DIR) $(SOFTFLOWD_IPK)
#
#
# Some sanity check for the package.
#
softflowd-check: $(SOFTFLOWD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SOFTFLOWD_IPK)
