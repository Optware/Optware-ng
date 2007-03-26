###########################################################
#
# libmtp
#
###########################################################
#
# LIBMTP_VERSION, LIBMTP_SITE and LIBMTP_SOURCE define
# the upstream location of the source code for the package.
# LIBMTP_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMTP_UNZIP is the command used to unzip the source.
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
LIBMTP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libmtp
LIBMTP_VERSION=0.1.4
LIBMTP_SOURCE=libmtp-$(LIBMTP_VERSION).tar.gz
LIBMTP_DIR=libmtp-$(LIBMTP_VERSION)
LIBMTP_UNZIP=zcat
LIBMTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMTP_DESCRIPTION=Implementation of the Media Transfer Protocol (MTP).
LIBMTP_SECTION=net
LIBMTP_PRIORITY=optional
LIBMTP_DEPENDS=libusb
LIBMTP_SUGGESTS=
LIBMTP_CONFLICTS=

#
# LIBMTP_IPK_VERSION should be incremented when the ipk changes.
#
LIBMTP_IPK_VERSION=1

#
# LIBMTP_CONFFILES should be a list of user-editable files
#LIBMTP_CONFFILES=/opt/etc/libmtp.conf /opt/etc/init.d/SXXlibmtp

#
# LIBMTP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBMTP_PATCHES=$(LIBMTP_SOURCE_DIR)/configure.patch \
		$(LIBMTP_SOURCE_DIR)/Makefile.in.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMTP_CPPFLAGS=
LIBMTP_LDFLAGS=

#
# LIBMTP_BUILD_DIR is the directory in which the build is done.
# LIBMTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMTP_IPK_DIR is the directory in which the ipk is built.
# LIBMTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMTP_BUILD_DIR=$(BUILD_DIR)/libmtp
LIBMTP_SOURCE_DIR=$(SOURCE_DIR)/libmtp
LIBMTP_IPK_DIR=$(BUILD_DIR)/libmtp-$(LIBMTP_VERSION)-ipk
LIBMTP_IPK=$(BUILD_DIR)/libmtp_$(LIBMTP_VERSION)-$(LIBMTP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmtp-source libmtp-unpack libmtp libmtp-stage libmtp-ipk libmtp-clean libmtp-dirclean libmtp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMTP_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBMTP_SITE)/$(LIBMTP_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBMTP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmtp-source: $(DL_DIR)/$(LIBMTP_SOURCE) $(LIBMTP_PATCHES)

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
$(LIBMTP_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMTP_SOURCE) $(LIBMTP_PATCHES) make/libmtp.mk
	$(MAKE) libusb-stage
	rm -rf $(BUILD_DIR)/$(LIBMTP_DIR) $(LIBMTP_BUILD_DIR)
	$(LIBMTP_UNZIP) $(DL_DIR)/$(LIBMTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMTP_PATCHES)" ; \
		then cat $(LIBMTP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBMTP_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMTP_DIR)" != "$(LIBMTP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBMTP_DIR) $(LIBMTP_BUILD_DIR) ; \
	fi
	(cd $(LIBMTP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMTP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMTP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBMTP_BUILD_DIR)/libtool
	touch $@

libmtp-unpack: $(LIBMTP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMTP_BUILD_DIR)/.built: $(LIBMTP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBMTP_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libmtp: $(LIBMTP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMTP_BUILD_DIR)/.staged: $(LIBMTP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBMTP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

libmtp-stage: $(LIBMTP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmtp
#
$(LIBMTP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libmtp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMTP_PRIORITY)" >>$@
	@echo "Section: $(LIBMTP_SECTION)" >>$@
	@echo "Version: $(LIBMTP_VERSION)-$(LIBMTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMTP_MAINTAINER)" >>$@
	@echo "Source: $(LIBMTP_SITE)/$(LIBMTP_SOURCE)" >>$@
	@echo "Description: $(LIBMTP_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMTP_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMTP_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMTP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMTP_IPK_DIR)/opt/sbin or $(LIBMTP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMTP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBMTP_IPK_DIR)/opt/etc/libmtp/...
# Documentation files should be installed in $(LIBMTP_IPK_DIR)/opt/doc/libmtp/...
# Daemon startup scripts should be installed in $(LIBMTP_IPK_DIR)/opt/etc/init.d/S??libmtp
#
# You may need to patch your application to make it use these locations.
#
$(LIBMTP_IPK): $(LIBMTP_BUILD_DIR)/.built
	rm -rf $(LIBMTP_IPK_DIR) $(BUILD_DIR)/libmtp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMTP_BUILD_DIR) DESTDIR=$(LIBMTP_IPK_DIR) install-strip
#	install -d $(LIBMTP_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBMTP_SOURCE_DIR)/libmtp.conf $(LIBMTP_IPK_DIR)/opt/etc/libmtp.conf
#	install -d $(LIBMTP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBMTP_SOURCE_DIR)/rc.libmtp $(LIBMTP_IPK_DIR)/opt/etc/init.d/SXXlibmtp
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMTP_IPK_DIR)/opt/etc/init.d/SXXlibmtp
	$(MAKE) $(LIBMTP_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBMTP_SOURCE_DIR)/postinst $(LIBMTP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMTP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBMTP_SOURCE_DIR)/prerm $(LIBMTP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMTP_IPK_DIR)/CONTROL/prerm
#	echo $(LIBMTP_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMTP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmtp-ipk: $(LIBMTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmtp-clean:
	rm -f $(LIBMTP_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmtp-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMTP_DIR) $(LIBMTP_BUILD_DIR) $(LIBMTP_IPK_DIR) $(LIBMTP_IPK)
#
#
# Some sanity check for the package.
#
libmtp-check: $(LIBMTP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBMTP_IPK)
