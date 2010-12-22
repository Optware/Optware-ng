###########################################################
#
# ulogd
#
###########################################################
#
# ULOGD_VERSION, ULOGD_SITE and ULOGD_SOURCE define
# the upstream location of the source code for the package.
# ULOGD_DIR is the directory which is created when the source
# archive is unpacked.
# ULOGD_UNZIP is the command used to unzip the source.
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
ULOGD_SITE=http://www.netfilter.org/projects/ulogd/files
ULOGD_VERSION=1.24
ULOGD_SOURCE=ulogd-$(ULOGD_VERSION).tar.bz2
ULOGD_DIR=ulogd-$(ULOGD_VERSION)
ULOGD_UNZIP=bzcat
ULOGD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ULOGD_DESCRIPTION=A userspace logging daemon for netfilter/iptables
ULOGD_SECTION=utils
ULOGD_PRIORITY=optional
ULOGD_DEPENDS=
ULOGD_SUGGESTS=
ULOGD_CONFLICTS=

#
# ULOGD_IPK_VERSION should be incremented when the ipk changes.
#
ULOGD_IPK_VERSION=1

#
# ULOGD_CONFFILES should be a list of user-editable files
#ULOGD_CONFFILES=/opt/etc/ulogd.conf /opt/etc/init.d/SXXulogd

#
# ULOGD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ULOGD_PATCHES=$(ULOGD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ULOGD_CPPFLAGS=-I$(ULOGD_BUILD_DIR)/include -I$(ULOGD_BUILD_DIR)/libipulog/include
ULOGD_LDFLAGS=

#
# ULOGD_BUILD_DIR is the directory in which the build is done.
# ULOGD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ULOGD_IPK_DIR is the directory in which the ipk is built.
# ULOGD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ULOGD_BUILD_DIR=$(BUILD_DIR)/ulogd
ULOGD_SOURCE_DIR=$(SOURCE_DIR)/ulogd
ULOGD_IPK_DIR=$(BUILD_DIR)/ulogd-$(ULOGD_VERSION)-ipk
ULOGD_IPK=$(BUILD_DIR)/ulogd_$(ULOGD_VERSION)-$(ULOGD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ulogd-source ulogd-unpack ulogd ulogd-stage ulogd-ipk ulogd-clean ulogd-dirclean ulogd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ULOGD_SOURCE):
	$(WGET) -P $(@D) $(ULOGD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ulogd-source: $(DL_DIR)/$(ULOGD_SOURCE) $(ULOGD_PATCHES)

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
$(ULOGD_BUILD_DIR)/.configured: $(DL_DIR)/$(ULOGD_SOURCE) $(ULOGD_PATCHES) make/ulogd.mk
	$(MAKE) libpcap-stage sqlite-stage
	rm -rf $(BUILD_DIR)/$(ULOGD_DIR) $(@D)
	$(ULOGD_UNZIP) $(DL_DIR)/$(ULOGD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ULOGD_PATCHES)" ; \
		then cat $(ULOGD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ULOGD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ULOGD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ULOGD_DIR) $(@D) ; \
	fi
	sed -i -e '/CFLAGS.*uname -r/d' $(@D)/Rules.make.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(ULOGD_CPPFLAGS) $(STAGING_CPPFLAGS)" \
		LDFLAGS="$(ULOGD_LDFLAGS) $(STAGING_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-sqlite3=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

ulogd-unpack: $(ULOGD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ULOGD_BUILD_DIR)/.built: $(ULOGD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		LD="$(TARGET_LD) -L$(STAGING_LIB_DIR) -rpath /opt/lib"
	touch $@

#
# This is the build convenience target.
#
ulogd: $(ULOGD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ULOGD_BUILD_DIR)/.staged: $(ULOGD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ulogd-stage: $(ULOGD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ulogd
#
$(ULOGD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ulogd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ULOGD_PRIORITY)" >>$@
	@echo "Section: $(ULOGD_SECTION)" >>$@
	@echo "Version: $(ULOGD_VERSION)-$(ULOGD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ULOGD_MAINTAINER)" >>$@
	@echo "Source: $(ULOGD_SITE)/$(ULOGD_SOURCE)" >>$@
	@echo "Description: $(ULOGD_DESCRIPTION)" >>$@
	@echo "Depends: $(ULOGD_DEPENDS)" >>$@
	@echo "Suggests: $(ULOGD_SUGGESTS)" >>$@
	@echo "Conflicts: $(ULOGD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ULOGD_IPK_DIR)/opt/sbin or $(ULOGD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ULOGD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ULOGD_IPK_DIR)/opt/etc/ulogd/...
# Documentation files should be installed in $(ULOGD_IPK_DIR)/opt/doc/ulogd/...
# Daemon startup scripts should be installed in $(ULOGD_IPK_DIR)/opt/etc/init.d/S??ulogd
#
# You may need to patch your application to make it use these locations.
#
$(ULOGD_IPK): $(ULOGD_BUILD_DIR)/.built
	rm -rf $(ULOGD_IPK_DIR) $(BUILD_DIR)/ulogd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ULOGD_BUILD_DIR) DESTDIR=$(ULOGD_IPK_DIR) install
	$(STRIP_COMMAND) $(ULOGD_IPK_DIR)/opt/sbin/* $(ULOGD_IPK_DIR)/opt/lib/ulogd/*.so
	$(MAKE) $(ULOGD_IPK_DIR)/CONTROL/control
	echo $(ULOGD_CONFFILES) | sed -e 's/ /\n/g' > $(ULOGD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ULOGD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ulogd-ipk: $(ULOGD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ulogd-clean:
	rm -f $(ULOGD_BUILD_DIR)/.built
	-$(MAKE) -C $(ULOGD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ulogd-dirclean:
	rm -rf $(BUILD_DIR)/$(ULOGD_DIR) $(ULOGD_BUILD_DIR) $(ULOGD_IPK_DIR) $(ULOGD_IPK)
#
#
# Some sanity check for the package.
#
ulogd-check: $(ULOGD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
