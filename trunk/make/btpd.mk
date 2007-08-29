###########################################################
#
# btpd
#
###########################################################
#
# BTPD_VERSION, BTPD_SITE and BTPD_SOURCE define
# the upstream location of the source code for the package.
# BTPD_DIR is the directory which is created when the source
# archive is unpacked.
# BTPD_UNZIP is the command used to unzip the source.
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
BTPD_SITE=http://www.murmeldjur.se/btpd
BTPD_VERSION=0.13
BTPD_SOURCE=btpd-$(BTPD_VERSION).tar.gz
BTPD_DIR=btpd-$(BTPD_VERSION)
BTPD_UNZIP=zcat
BTPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BTPD_DESCRIPTION=BTPD is a bittorrent client consisting of a daemon and a cli client, which can be used to read and/or manipulate the daemon state.
BTPD_SECTION=net
BTPD_PRIORITY=optional
BTPD_DEPENDS=
BTPD_SUGGESTS=
BTPD_CONFLICTS=

#
# BTPD_IPK_VERSION should be incremented when the ipk changes.
#
BTPD_IPK_VERSION=1

#
# BTPD_CONFFILES should be a list of user-editable files
#BTPD_CONFFILES=/opt/etc/btpd.conf /opt/etc/init.d/SXXbtpd

#
# BTPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BTPD_PATCHES=$(BTPD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BTPD_CPPFLAGS=
ifeq ($(OPTWARE_TARGET), slugosbe)
BTPD_CPPFLAGS+=-DIOV_MAX=1024
endif
ifeq ($(LIBC_STYLE), uclibc)
BTPD_CPPFLAGS+= -DCLOCK_MONOTONIC=1 -DCLOCK_REALTIME=0
endif
BTPD_LDFLAGS=

#
# BTPD_BUILD_DIR is the directory in which the build is done.
# BTPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BTPD_IPK_DIR is the directory in which the ipk is built.
# BTPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BTPD_BUILD_DIR=$(BUILD_DIR)/btpd
BTPD_SOURCE_DIR=$(SOURCE_DIR)/btpd
BTPD_IPK_DIR=$(BUILD_DIR)/btpd-$(BTPD_VERSION)-ipk
BTPD_IPK=$(BUILD_DIR)/btpd_$(BTPD_VERSION)-$(BTPD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: btpd-source btpd-unpack btpd btpd-stage btpd-ipk btpd-clean btpd-dirclean btpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BTPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(BTPD_SITE)/$(BTPD_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(BTPD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
btpd-source: $(DL_DIR)/$(BTPD_SOURCE) $(BTPD_PATCHES)

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
$(BTPD_BUILD_DIR)/.configured: $(DL_DIR)/$(BTPD_SOURCE) $(BTPD_PATCHES) make/btpd.mk
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(BTPD_DIR) $(BTPD_BUILD_DIR)
	$(BTPD_UNZIP) $(DL_DIR)/$(BTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BTPD_PATCHES)" ; \
		then cat $(BTPD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(BTPD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(BTPD_DIR)" != "$(BTPD_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(BTPD_DIR) $(BTPD_BUILD_DIR) ; \
	fi
	(cd $(BTPD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BTPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BTPD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(BTPD_BUILD_DIR)/libtool
	touch $@

btpd-unpack: $(BTPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BTPD_BUILD_DIR)/.built: $(BTPD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(BTPD_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
btpd: $(BTPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BTPD_BUILD_DIR)/.staged: $(BTPD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(BTPD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

btpd-stage: $(BTPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/btpd
#
$(BTPD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: btpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BTPD_PRIORITY)" >>$@
	@echo "Section: $(BTPD_SECTION)" >>$@
	@echo "Version: $(BTPD_VERSION)-$(BTPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BTPD_MAINTAINER)" >>$@
	@echo "Source: $(BTPD_SITE)/$(BTPD_SOURCE)" >>$@
	@echo "Description: $(BTPD_DESCRIPTION)" >>$@
	@echo "Depends: $(BTPD_DEPENDS)" >>$@
	@echo "Suggests: $(BTPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(BTPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BTPD_IPK_DIR)/opt/sbin or $(BTPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BTPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BTPD_IPK_DIR)/opt/etc/btpd/...
# Documentation files should be installed in $(BTPD_IPK_DIR)/opt/doc/btpd/...
# Daemon startup scripts should be installed in $(BTPD_IPK_DIR)/opt/etc/init.d/S??btpd
#
# You may need to patch your application to make it use these locations.
#
$(BTPD_IPK): $(BTPD_BUILD_DIR)/.built
	rm -rf $(BTPD_IPK_DIR) $(BUILD_DIR)/btpd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BTPD_BUILD_DIR) DESTDIR=$(BTPD_IPK_DIR) install-strip
	install -d $(BTPD_IPK_DIR)/opt/share/doc/btpd
	install $(BTPD_BUILD_DIR)/README $(BTPD_IPK_DIR)/opt/share/doc/btpd/
	$(MAKE) $(BTPD_IPK_DIR)/CONTROL/control
	echo $(BTPD_CONFFILES) | sed -e 's/ /\n/g' > $(BTPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BTPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
btpd-ipk: $(BTPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
btpd-clean:
	rm -f $(BTPD_BUILD_DIR)/.built
	-$(MAKE) -C $(BTPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
btpd-dirclean:
	rm -rf $(BUILD_DIR)/$(BTPD_DIR) $(BTPD_BUILD_DIR) $(BTPD_IPK_DIR) $(BTPD_IPK)
#
#
# Some sanity check for the package.
#
btpd-check: $(BTPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BTPD_IPK)
