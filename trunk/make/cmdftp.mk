###########################################################
#
# cmdftp
#
###########################################################
#
# CMDFTP_VERSION, CMDFTP_SITE and CMDFTP_SOURCE define
# the upstream location of the source code for the package.
# CMDFTP_DIR is the directory which is created when the source
# archive is unpacked.
# CMDFTP_UNZIP is the command used to unzip the source.
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
CMDFTP_SITE=http://download.savannah.nongnu.org/releases/cmdftp
CMDFTP_VERSION=0.9.7
CMDFTP_SOURCE=cmdftp-$(CMDFTP_VERSION).tar.bz2
CMDFTP_DIR=cmdftp-$(CMDFTP_VERSION)
CMDFTP_UNZIP=bzcat
CMDFTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CMDFTP_DESCRIPTION=cmdftp is a tiny command line FTP client that features shell-like functions, passive mode, local and remote transparent modes, broken connection resumption, multiple and recursive file transfers, auto-login, completion, and large file support.
CMDFTP_SECTION=net
CMDFTP_PRIORITY=optional
CMDFTP_DEPENDS=
CMDFTP_SUGGESTS=
CMDFTP_CONFLICTS=

#
# CMDFTP_IPK_VERSION should be incremented when the ipk changes.
#
CMDFTP_IPK_VERSION=1

#
# CMDFTP_CONFFILES should be a list of user-editable files
#CMDFTP_CONFFILES=/opt/etc/cmdftp.conf /opt/etc/init.d/SXXcmdftp

#
# CMDFTP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CMDFTP_PATCHES=$(CMDFTP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CMDFTP_CPPFLAGS=
CMDFTP_LDFLAGS=

#
# CMDFTP_BUILD_DIR is the directory in which the build is done.
# CMDFTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CMDFTP_IPK_DIR is the directory in which the ipk is built.
# CMDFTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CMDFTP_BUILD_DIR=$(BUILD_DIR)/cmdftp
CMDFTP_SOURCE_DIR=$(SOURCE_DIR)/cmdftp
CMDFTP_IPK_DIR=$(BUILD_DIR)/cmdftp-$(CMDFTP_VERSION)-ipk
CMDFTP_IPK=$(BUILD_DIR)/cmdftp_$(CMDFTP_VERSION)-$(CMDFTP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cmdftp-source cmdftp-unpack cmdftp cmdftp-stage cmdftp-ipk cmdftp-clean cmdftp-dirclean cmdftp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CMDFTP_SOURCE):
	$(WGET) -P $(DL_DIR) $(CMDFTP_SITE)/$(CMDFTP_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(CMDFTP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cmdftp-source: $(DL_DIR)/$(CMDFTP_SOURCE) $(CMDFTP_PATCHES)

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
$(CMDFTP_BUILD_DIR)/.configured: $(DL_DIR)/$(CMDFTP_SOURCE) $(CMDFTP_PATCHES) make/cmdftp.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(CMDFTP_DIR) $(CMDFTP_BUILD_DIR)
	$(CMDFTP_UNZIP) $(DL_DIR)/$(CMDFTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CMDFTP_PATCHES)" ; \
		then cat $(CMDFTP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CMDFTP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CMDFTP_DIR)" != "$(CMDFTP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CMDFTP_DIR) $(CMDFTP_BUILD_DIR) ; \
	fi
	(cd $(CMDFTP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CMDFTP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CMDFTP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(CMDFTP_BUILD_DIR)/libtool
	touch $@

cmdftp-unpack: $(CMDFTP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CMDFTP_BUILD_DIR)/.built: $(CMDFTP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(CMDFTP_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
cmdftp: $(CMDFTP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CMDFTP_BUILD_DIR)/.staged: $(CMDFTP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(CMDFTP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

cmdftp-stage: $(CMDFTP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cmdftp
#
$(CMDFTP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: cmdftp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CMDFTP_PRIORITY)" >>$@
	@echo "Section: $(CMDFTP_SECTION)" >>$@
	@echo "Version: $(CMDFTP_VERSION)-$(CMDFTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CMDFTP_MAINTAINER)" >>$@
	@echo "Source: $(CMDFTP_SITE)/$(CMDFTP_SOURCE)" >>$@
	@echo "Description: $(CMDFTP_DESCRIPTION)" >>$@
	@echo "Depends: $(CMDFTP_DEPENDS)" >>$@
	@echo "Suggests: $(CMDFTP_SUGGESTS)" >>$@
	@echo "Conflicts: $(CMDFTP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CMDFTP_IPK_DIR)/opt/sbin or $(CMDFTP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CMDFTP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CMDFTP_IPK_DIR)/opt/etc/cmdftp/...
# Documentation files should be installed in $(CMDFTP_IPK_DIR)/opt/doc/cmdftp/...
# Daemon startup scripts should be installed in $(CMDFTP_IPK_DIR)/opt/etc/init.d/S??cmdftp
#
# You may need to patch your application to make it use these locations.
#
$(CMDFTP_IPK): $(CMDFTP_BUILD_DIR)/.built
	rm -rf $(CMDFTP_IPK_DIR) $(BUILD_DIR)/cmdftp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CMDFTP_BUILD_DIR) install-strip \
		DESTDIR=$(CMDFTP_IPK_DIR) transform=""
	$(MAKE) $(CMDFTP_IPK_DIR)/CONTROL/control
	echo $(CMDFTP_CONFFILES) | sed -e 's/ /\n/g' > $(CMDFTP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CMDFTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cmdftp-ipk: $(CMDFTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cmdftp-clean:
	rm -f $(CMDFTP_BUILD_DIR)/.built
	-$(MAKE) -C $(CMDFTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cmdftp-dirclean:
	rm -rf $(BUILD_DIR)/$(CMDFTP_DIR) $(CMDFTP_BUILD_DIR) $(CMDFTP_IPK_DIR) $(CMDFTP_IPK)
#
#
# Some sanity check for the package.
#
cmdftp-check: $(CMDFTP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CMDFTP_IPK)
