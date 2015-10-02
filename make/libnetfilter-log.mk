###########################################################
#
# libnetfilter-log
#
###########################################################
#
# LIBNETFILTER_LOG_VERSION, LIBNETFILTER_LOG_SITE and LIBNETFILTER_LOG_SOURCE define
# the upstream location of the source code for the package.
# LIBNETFILTER_LOG_DIR is the directory which is created when the source
# archive is unpacked.
# LIBNETFILTER_LOG_UNZIP is the command used to unzip the source.
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
LIBNETFILTER_LOG_SITE=ftp://ftp.netfilter.org/pub/libnetfilter_log
LIBNETFILTER_LOG_VERSION=1.0.1
LIBNETFILTER_LOG_SOURCE=libnetfilter_log-$(LIBNETFILTER_LOG_VERSION).tar.bz2
LIBNETFILTER_LOG_DIR=libnetfilter_log-$(LIBNETFILTER_LOG_VERSION)
LIBNETFILTER_LOG_UNZIP=bzcat
LIBNETFILTER_LOG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBNETFILTER_LOG_DESCRIPTION=Userspace library providing interface to packets that have been logged by the kernel packet filter.
LIBNETFILTER_LOG_SECTION=kernel
LIBNETFILTER_LOG_PRIORITY=optional
LIBNETFILTER_LOG_DEPENDS=libnfnetlink
LIBNETFILTER_LOG_SUGGESTS=
LIBNETFILTER_LOG_CONFLICTS=

#
# LIBNETFILTER_LOG_IPK_VERSION should be incremented when the ipk changes.
#
LIBNETFILTER_LOG_IPK_VERSION=1

#
# LIBNETFILTER_LOG_CONFFILES should be a list of user-editable files
#LIBNETFILTER_LOG_CONFFILES=/opt/etc/libnetfilter-log.conf /opt/etc/init.d/SXXlibnetfilter-log

#
# LIBNETFILTER_LOG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBNETFILTER_LOG_PATCHES=$(LIBNETFILTER_LOG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBNETFILTER_LOG_CPPFLAGS=
LIBNETFILTER_LOG_LDFLAGS=

#
# LIBNETFILTER_LOG_BUILD_DIR is the directory in which the build is done.
# LIBNETFILTER_LOG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBNETFILTER_LOG_IPK_DIR is the directory in which the ipk is built.
# LIBNETFILTER_LOG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBNETFILTER_LOG_BUILD_DIR=$(BUILD_DIR)/libnetfilter-log
LIBNETFILTER_LOG_SOURCE_DIR=$(SOURCE_DIR)/libnetfilter-log
LIBNETFILTER_LOG_IPK_DIR=$(BUILD_DIR)/libnetfilter-log-$(LIBNETFILTER_LOG_VERSION)-ipk
LIBNETFILTER_LOG_IPK=$(BUILD_DIR)/libnetfilter-log_$(LIBNETFILTER_LOG_VERSION)-$(LIBNETFILTER_LOG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libnetfilter-log-source libnetfilter-log-unpack libnetfilter-log libnetfilter-log-stage libnetfilter-log-ipk libnetfilter-log-clean libnetfilter-log-dirclean libnetfilter-log-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBNETFILTER_LOG_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBNETFILTER_LOG_SITE)/$(LIBNETFILTER_LOG_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBNETFILTER_LOG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libnetfilter-log-source: $(DL_DIR)/$(LIBNETFILTER_LOG_SOURCE) $(LIBNETFILTER_LOG_PATCHES)

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
$(LIBNETFILTER_LOG_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBNETFILTER_LOG_SOURCE) $(LIBNETFILTER_LOG_PATCHES) make/libnetfilter-log.mk
	$(MAKE) libnfnetlink-stage
	rm -rf $(BUILD_DIR)/$(LIBNETFILTER_LOG_DIR) $(LIBNETFILTER_LOG_BUILD_DIR)
	$(LIBNETFILTER_LOG_UNZIP) $(DL_DIR)/$(LIBNETFILTER_LOG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBNETFILTER_LOG_PATCHES)" ; \
		then cat $(LIBNETFILTER_LOG_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBNETFILTER_LOG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBNETFILTER_LOG_DIR)" != "$(LIBNETFILTER_LOG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBNETFILTER_LOG_DIR) $(LIBNETFILTER_LOG_BUILD_DIR) ; \
	fi
	(cd $(LIBNETFILTER_LOG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBNETFILTER_LOG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBNETFILTER_LOG_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBNETFILTER_LOG_BUILD_DIR)/libtool
	touch $@

libnetfilter-log-unpack: $(LIBNETFILTER_LOG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBNETFILTER_LOG_BUILD_DIR)/.built: $(LIBNETFILTER_LOG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBNETFILTER_LOG_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libnetfilter-log: $(LIBNETFILTER_LOG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBNETFILTER_LOG_BUILD_DIR)/.staged: $(LIBNETFILTER_LOG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBNETFILTER_LOG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libnetfilter_log.pc
	rm -f $(STAGING_LIB_DIR)/libnetfilter_log.la
	touch $@

libnetfilter-log-stage: $(LIBNETFILTER_LOG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libnetfilter-log
#
$(LIBNETFILTER_LOG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libnetfilter-log" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBNETFILTER_LOG_PRIORITY)" >>$@
	@echo "Section: $(LIBNETFILTER_LOG_SECTION)" >>$@
	@echo "Version: $(LIBNETFILTER_LOG_VERSION)-$(LIBNETFILTER_LOG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBNETFILTER_LOG_MAINTAINER)" >>$@
	@echo "Source: $(LIBNETFILTER_LOG_SITE)/$(LIBNETFILTER_LOG_SOURCE)" >>$@
	@echo "Description: $(LIBNETFILTER_LOG_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNETFILTER_LOG_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNETFILTER_LOG_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNETFILTER_LOG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBNETFILTER_LOG_IPK_DIR)/opt/sbin or $(LIBNETFILTER_LOG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBNETFILTER_LOG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBNETFILTER_LOG_IPK_DIR)/opt/etc/libnetfilter-log/...
# Documentation files should be installed in $(LIBNETFILTER_LOG_IPK_DIR)/opt/doc/libnetfilter-log/...
# Daemon startup scripts should be installed in $(LIBNETFILTER_LOG_IPK_DIR)/opt/etc/init.d/S??libnetfilter-log
#
# You may need to patch your application to make it use these locations.
#
$(LIBNETFILTER_LOG_IPK): $(LIBNETFILTER_LOG_BUILD_DIR)/.built
	rm -rf $(LIBNETFILTER_LOG_IPK_DIR) $(BUILD_DIR)/libnetfilter-log_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBNETFILTER_LOG_BUILD_DIR) DESTDIR=$(LIBNETFILTER_LOG_IPK_DIR) install-strip
	rm -rf $(LIBNETFILTER_LOG_IPK_DIR)/opt/include
#	$(INSTALL) -d $(LIBNETFILTER_LOG_IPK_DIR)/opt/etc/
#	$(INSTALL) -m 644 $(LIBNETFILTER_LOG_SOURCE_DIR)/libnetfilter-log.conf $(LIBNETFILTER_LOG_IPK_DIR)/opt/etc/libnetfilter-log.conf
#	$(INSTALL) -d $(LIBNETFILTER_LOG_IPK_DIR)/opt/etc/init.d
#	$(INSTALL) -m 755 $(LIBNETFILTER_LOG_SOURCE_DIR)/rc.libnetfilter-log $(LIBNETFILTER_LOG_IPK_DIR)/opt/etc/init.d/SXXlibnetfilter-log
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNETFILTER_LOG_IPK_DIR)/opt/etc/init.d/SXXlibnetfilter-log
	$(MAKE) $(LIBNETFILTER_LOG_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBNETFILTER_LOG_SOURCE_DIR)/postinst $(LIBNETFILTER_LOG_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNETFILTER_LOG_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBNETFILTER_LOG_SOURCE_DIR)/prerm $(LIBNETFILTER_LOG_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNETFILTER_LOG_IPK_DIR)/CONTROL/prerm
#	echo $(LIBNETFILTER_LOG_CONFFILES) | sed -e 's/ /\n/g' > $(LIBNETFILTER_LOG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNETFILTER_LOG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libnetfilter-log-ipk: $(LIBNETFILTER_LOG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libnetfilter-log-clean:
	rm -f $(LIBNETFILTER_LOG_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBNETFILTER_LOG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libnetfilter-log-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBNETFILTER_LOG_DIR) $(LIBNETFILTER_LOG_BUILD_DIR) $(LIBNETFILTER_LOG_IPK_DIR) $(LIBNETFILTER_LOG_IPK)
#
#
# Some sanity check for the package.
#
libnetfilter-log-check: $(LIBNETFILTER_LOG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBNETFILTER_LOG_IPK)
