###########################################################
#
# pure-ftpd
#
###########################################################
#
# PURE-FTPD_VERSION, PURE-FTPD_SITE and PURE-FTPD_SOURCE define
# the upstream location of the source code for the package.
# PURE-FTPD_DIR is the directory which is created when the source
# archive is unpacked.
# PURE-FTPD_UNZIP is the command used to unzip the source.
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
PURE-FTPD_SITE=http://download.pureftpd.org/pub/pure-ftpd/releases
PURE-FTPD_VERSION=1.0.21
PURE-FTPD_SOURCE=pure-ftpd-$(PURE-FTPD_VERSION).tar.bz2
PURE-FTPD_DIR=pure-ftpd-$(PURE-FTPD_VERSION)
PURE-FTPD_UNZIP=bzcat
PURE-FTPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PURE-FTPD_DESCRIPTION=A free (BSD), secure, production-quality and standard-conformant FTP server.
PURE-FTPD_SECTION=net
PURE-FTPD_PRIORITY=optional
PURE-FTPD_DEPENDS=
PURE-FTPD_SUGGESTS=
PURE-FTPD_CONFLICTS=

#
# PURE-FTPD_IPK_VERSION should be incremented when the ipk changes.
#
PURE-FTPD_IPK_VERSION=1

#
# PURE-FTPD_CONFFILES should be a list of user-editable files
#PURE-FTPD_CONFFILES=/opt/etc/pure-ftpd.conf /opt/etc/init.d/SXXpure-ftpd

#
# PURE-FTPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PURE-FTPD_PATCHES=$(PURE-FTPD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PURE-FTPD_CPPFLAGS=
PURE-FTPD_LDFLAGS=

#
# PURE-FTPD_BUILD_DIR is the directory in which the build is done.
# PURE-FTPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PURE-FTPD_IPK_DIR is the directory in which the ipk is built.
# PURE-FTPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PURE-FTPD_BUILD_DIR=$(BUILD_DIR)/pure-ftpd
PURE-FTPD_SOURCE_DIR=$(SOURCE_DIR)/pure-ftpd
PURE-FTPD_IPK_DIR=$(BUILD_DIR)/pure-ftpd-$(PURE-FTPD_VERSION)-ipk
PURE-FTPD_IPK=$(BUILD_DIR)/pure-ftpd_$(PURE-FTPD_VERSION)-$(PURE-FTPD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pure-ftpd-source pure-ftpd-unpack pure-ftpd pure-ftpd-stage pure-ftpd-ipk pure-ftpd-clean pure-ftpd-dirclean pure-ftpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PURE-FTPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(PURE-FTPD_SITE)/$(PURE-FTPD_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PURE-FTPD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pure-ftpd-source: $(DL_DIR)/$(PURE-FTPD_SOURCE) $(PURE-FTPD_PATCHES)

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
$(PURE-FTPD_BUILD_DIR)/.configured: $(DL_DIR)/$(PURE-FTPD_SOURCE) $(PURE-FTPD_PATCHES) make/pure-ftpd.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PURE-FTPD_DIR) $(PURE-FTPD_BUILD_DIR)
	$(PURE-FTPD_UNZIP) $(DL_DIR)/$(PURE-FTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PURE-FTPD_PATCHES)" ; \
		then cat $(PURE-FTPD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PURE-FTPD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PURE-FTPD_DIR)" != "$(PURE-FTPD_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(PURE-FTPD_DIR) $(PURE-FTPD_BUILD_DIR) ; \
	fi
	(cd $(PURE-FTPD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PURE-FTPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PURE-FTPD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(PURE-FTPD_BUILD_DIR)/libtool
	touch $@

pure-ftpd-unpack: $(PURE-FTPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PURE-FTPD_BUILD_DIR)/.built: $(PURE-FTPD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PURE-FTPD_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
pure-ftpd: $(PURE-FTPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PURE-FTPD_BUILD_DIR)/.staged: $(PURE-FTPD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PURE-FTPD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

pure-ftpd-stage: $(PURE-FTPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pure-ftpd
#
$(PURE-FTPD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: pure-ftpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PURE-FTPD_PRIORITY)" >>$@
	@echo "Section: $(PURE-FTPD_SECTION)" >>$@
	@echo "Version: $(PURE-FTPD_VERSION)-$(PURE-FTPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PURE-FTPD_MAINTAINER)" >>$@
	@echo "Source: $(PURE-FTPD_SITE)/$(PURE-FTPD_SOURCE)" >>$@
	@echo "Description: $(PURE-FTPD_DESCRIPTION)" >>$@
	@echo "Depends: $(PURE-FTPD_DEPENDS)" >>$@
	@echo "Suggests: $(PURE-FTPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(PURE-FTPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PURE-FTPD_IPK_DIR)/opt/sbin or $(PURE-FTPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PURE-FTPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PURE-FTPD_IPK_DIR)/opt/etc/pure-ftpd/...
# Documentation files should be installed in $(PURE-FTPD_IPK_DIR)/opt/doc/pure-ftpd/...
# Daemon startup scripts should be installed in $(PURE-FTPD_IPK_DIR)/opt/etc/init.d/S??pure-ftpd
#
# You may need to patch your application to make it use these locations.
#
$(PURE-FTPD_IPK): $(PURE-FTPD_BUILD_DIR)/.built
	rm -rf $(PURE-FTPD_IPK_DIR) $(BUILD_DIR)/pure-ftpd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PURE-FTPD_BUILD_DIR) DESTDIR=$(PURE-FTPD_IPK_DIR) install-strip
#	install -d $(PURE-FTPD_IPK_DIR)/opt/etc/
#	install -m 644 $(PURE-FTPD_SOURCE_DIR)/pure-ftpd.conf $(PURE-FTPD_IPK_DIR)/opt/etc/pure-ftpd.conf
#	install -d $(PURE-FTPD_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PURE-FTPD_SOURCE_DIR)/rc.pure-ftpd $(PURE-FTPD_IPK_DIR)/opt/etc/init.d/SXXpure-ftpd
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PURE-FTPD_IPK_DIR)/opt/etc/init.d/SXXpure-ftpd
	$(MAKE) $(PURE-FTPD_IPK_DIR)/CONTROL/control
#	install -m 755 $(PURE-FTPD_SOURCE_DIR)/postinst $(PURE-FTPD_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PURE-FTPD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PURE-FTPD_SOURCE_DIR)/prerm $(PURE-FTPD_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PURE-FTPD_IPK_DIR)/CONTROL/prerm
	echo $(PURE-FTPD_CONFFILES) | sed -e 's/ /\n/g' > $(PURE-FTPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PURE-FTPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pure-ftpd-ipk: $(PURE-FTPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pure-ftpd-clean:
	rm -f $(PURE-FTPD_BUILD_DIR)/.built
	-$(MAKE) -C $(PURE-FTPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pure-ftpd-dirclean:
	rm -rf $(BUILD_DIR)/$(PURE-FTPD_DIR) $(PURE-FTPD_BUILD_DIR) $(PURE-FTPD_IPK_DIR) $(PURE-FTPD_IPK)
#
#
# Some sanity check for the package.
#
pure-ftpd-check: $(PURE-FTPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PURE-FTPD_IPK)
