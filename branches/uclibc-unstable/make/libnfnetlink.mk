###########################################################
#
# libnfnetlink
#
###########################################################
#
# LIBNFNETLINK_VERSION, LIBNFNETLINK_SITE and LIBNFNETLINK_SOURCE define
# the upstream location of the source code for the package.
# LIBNFNETLINK_DIR is the directory which is created when the source
# archive is unpacked.
# LIBNFNETLINK_UNZIP is the command used to unzip the source.
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
LIBNFNETLINK_SITE=ftp://ftp.netfilter.org/pub/libnfnetlink
LIBNFNETLINK_VERSION=0.0.14
LIBNFNETLINK_SOURCE=libnfnetlink-$(LIBNFNETLINK_VERSION).tar.bz2
LIBNFNETLINK_DIR=libnfnetlink-$(LIBNFNETLINK_VERSION)
LIBNFNETLINK_UNZIP=bzcat
LIBNFNETLINK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBNFNETLINK_DESCRIPTION=Low-level library for netfilter related kernel/userspace communication.
LIBNFNETLINK_SECTION=kernel
LIBNFNETLINK_PRIORITY=optional
LIBNFNETLINK_DEPENDS=
LIBNFNETLINK_SUGGESTS=
LIBNFNETLINK_CONFLICTS=

#
# LIBNFNETLINK_IPK_VERSION should be incremented when the ipk changes.
#
LIBNFNETLINK_IPK_VERSION=1

#
# LIBNFNETLINK_CONFFILES should be a list of user-editable files
#LIBNFNETLINK_CONFFILES=/opt/etc/libnfnetlink.conf /opt/etc/init.d/SXXlibnfnetlink

#
# LIBNFNETLINK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBNFNETLINK_PATCHES=$(LIBNFNETLINK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBNFNETLINK_CPPFLAGS=
LIBNFNETLINK_LDFLAGS=

#
# LIBNFNETLINK_BUILD_DIR is the directory in which the build is done.
# LIBNFNETLINK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBNFNETLINK_IPK_DIR is the directory in which the ipk is built.
# LIBNFNETLINK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBNFNETLINK_BUILD_DIR=$(BUILD_DIR)/libnfnetlink
LIBNFNETLINK_SOURCE_DIR=$(SOURCE_DIR)/libnfnetlink
LIBNFNETLINK_IPK_DIR=$(BUILD_DIR)/libnfnetlink-$(LIBNFNETLINK_VERSION)-ipk
LIBNFNETLINK_IPK=$(BUILD_DIR)/libnfnetlink_$(LIBNFNETLINK_VERSION)-$(LIBNFNETLINK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libnfnetlink-source libnfnetlink-unpack libnfnetlink libnfnetlink-stage libnfnetlink-ipk libnfnetlink-clean libnfnetlink-dirclean libnfnetlink-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBNFNETLINK_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBNFNETLINK_SITE)/$(LIBNFNETLINK_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBNFNETLINK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libnfnetlink-source: $(DL_DIR)/$(LIBNFNETLINK_SOURCE) $(LIBNFNETLINK_PATCHES)

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
$(LIBNFNETLINK_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBNFNETLINK_SOURCE) $(LIBNFNETLINK_PATCHES) make/libnfnetlink.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBNFNETLINK_DIR) $(LIBNFNETLINK_BUILD_DIR)
	$(LIBNFNETLINK_UNZIP) $(DL_DIR)/$(LIBNFNETLINK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBNFNETLINK_PATCHES)" ; \
		then cat $(LIBNFNETLINK_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBNFNETLINK_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBNFNETLINK_DIR)" != "$(LIBNFNETLINK_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBNFNETLINK_DIR) $(LIBNFNETLINK_BUILD_DIR) ; \
	fi
	(cd $(LIBNFNETLINK_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBNFNETLINK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBNFNETLINK_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBNFNETLINK_BUILD_DIR)/libtool
	touch $@

libnfnetlink-unpack: $(LIBNFNETLINK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBNFNETLINK_BUILD_DIR)/.built: $(LIBNFNETLINK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBNFNETLINK_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libnfnetlink: $(LIBNFNETLINK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBNFNETLINK_BUILD_DIR)/.staged: $(LIBNFNETLINK_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBNFNETLINK_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

libnfnetlink-stage: $(LIBNFNETLINK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libnfnetlink
#
$(LIBNFNETLINK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libnfnetlink" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBNFNETLINK_PRIORITY)" >>$@
	@echo "Section: $(LIBNFNETLINK_SECTION)" >>$@
	@echo "Version: $(LIBNFNETLINK_VERSION)-$(LIBNFNETLINK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBNFNETLINK_MAINTAINER)" >>$@
	@echo "Source: $(LIBNFNETLINK_SITE)/$(LIBNFNETLINK_SOURCE)" >>$@
	@echo "Description: $(LIBNFNETLINK_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNFNETLINK_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNFNETLINK_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNFNETLINK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBNFNETLINK_IPK_DIR)/opt/sbin or $(LIBNFNETLINK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBNFNETLINK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBNFNETLINK_IPK_DIR)/opt/etc/libnfnetlink/...
# Documentation files should be installed in $(LIBNFNETLINK_IPK_DIR)/opt/doc/libnfnetlink/...
# Daemon startup scripts should be installed in $(LIBNFNETLINK_IPK_DIR)/opt/etc/init.d/S??libnfnetlink
#
# You may need to patch your application to make it use these locations.
#
$(LIBNFNETLINK_IPK): $(LIBNFNETLINK_BUILD_DIR)/.built
	rm -rf $(LIBNFNETLINK_IPK_DIR) $(BUILD_DIR)/libnfnetlink_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBNFNETLINK_BUILD_DIR) DESTDIR=$(LIBNFNETLINK_IPK_DIR) install-strip
	rm -rf $(LIBNFNETLINK_IPK_DIR)/opt/include
#	install -d $(LIBNFNETLINK_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBNFNETLINK_SOURCE_DIR)/libnfnetlink.conf $(LIBNFNETLINK_IPK_DIR)/opt/etc/libnfnetlink.conf
#	install -d $(LIBNFNETLINK_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBNFNETLINK_SOURCE_DIR)/rc.libnfnetlink $(LIBNFNETLINK_IPK_DIR)/opt/etc/init.d/SXXlibnfnetlink
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNFNETLINK_IPK_DIR)/opt/etc/init.d/SXXlibnfnetlink
	$(MAKE) $(LIBNFNETLINK_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBNFNETLINK_SOURCE_DIR)/postinst $(LIBNFNETLINK_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNFNETLINK_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBNFNETLINK_SOURCE_DIR)/prerm $(LIBNFNETLINK_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNFNETLINK_IPK_DIR)/CONTROL/prerm
#	echo $(LIBNFNETLINK_CONFFILES) | sed -e 's/ /\n/g' > $(LIBNFNETLINK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNFNETLINK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libnfnetlink-ipk: $(LIBNFNETLINK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libnfnetlink-clean:
	rm -f $(LIBNFNETLINK_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBNFNETLINK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libnfnetlink-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBNFNETLINK_DIR) $(LIBNFNETLINK_BUILD_DIR) $(LIBNFNETLINK_IPK_DIR) $(LIBNFNETLINK_IPK)
#
#
# Some sanity check for the package.
#
libnfnetlink-check: $(LIBNFNETLINK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBNFNETLINK_IPK)
