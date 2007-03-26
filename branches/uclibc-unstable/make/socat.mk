###########################################################
#
# socat
#
###########################################################
#
# SOCAT_VERSION, SOCAT_SITE and SOCAT_SOURCE define
# the upstream location of the source code for the package.
# SOCAT_DIR is the directory which is created when the source
# archive is unpacked.
# SOCAT_UNZIP is the command used to unzip the source.
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
SOCAT_SITE=http://www.dest-unreach.org/socat/download
SOCAT_VERSION=1.6.0.0
SOCAT_SOURCE=socat-$(SOCAT_VERSION).tar.bz2
SOCAT_DIR=socat-$(SOCAT_VERSION)
SOCAT_UNZIP=bzcat
SOCAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SOCAT_DESCRIPTION=A relay for bidirectional data transfer between two independent data channels.
SOCAT_SECTION=net
SOCAT_PRIORITY=optional
SOCAT_DEPENDS=openssl, readline
SOCAT_SUGGESTS=
SOCAT_CONFLICTS=

#
# SOCAT_IPK_VERSION should be incremented when the ipk changes.
#
SOCAT_IPK_VERSION=1

#
# SOCAT_CONFFILES should be a list of user-editable files
#SOCAT_CONFFILES=/opt/etc/socat.conf /opt/etc/init.d/SXXsocat

#
# SOCAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SOCAT_PATCHES=$(SOCAT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SOCAT_CPPFLAGS=
SOCAT_LDFLAGS=

#
# SOCAT_BUILD_DIR is the directory in which the build is done.
# SOCAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SOCAT_IPK_DIR is the directory in which the ipk is built.
# SOCAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SOCAT_BUILD_DIR=$(BUILD_DIR)/socat
SOCAT_SOURCE_DIR=$(SOURCE_DIR)/socat
SOCAT_IPK_DIR=$(BUILD_DIR)/socat-$(SOCAT_VERSION)-ipk
SOCAT_IPK=$(BUILD_DIR)/socat_$(SOCAT_VERSION)-$(SOCAT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: socat-source socat-unpack socat socat-stage socat-ipk socat-clean socat-dirclean socat-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SOCAT_SOURCE):
	$(WGET) -P $(DL_DIR) $(SOCAT_SITE)/$(SOCAT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
socat-source: $(DL_DIR)/$(SOCAT_SOURCE) $(SOCAT_PATCHES)

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
$(SOCAT_BUILD_DIR)/.configured: $(DL_DIR)/$(SOCAT_SOURCE) $(SOCAT_PATCHES) make/socat.mk
	$(MAKE) openssl-stage readline-stage
	rm -rf $(BUILD_DIR)/$(SOCAT_DIR) $(SOCAT_BUILD_DIR)
	$(SOCAT_UNZIP) $(DL_DIR)/$(SOCAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SOCAT_PATCHES)" ; \
		then cat $(SOCAT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SOCAT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SOCAT_DIR)" != "$(SOCAT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SOCAT_DIR) $(SOCAT_BUILD_DIR) ; \
	fi
	# Not very sure about platforms other than nslu2, may need adjust
	(cd $(SOCAT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SOCAT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SOCAT_LDFLAGS)" \
		sc_cv_sys_crdly_shift=9 \
		sc_cv_sys_tabdly_shift=11 \
		sc_cv_sys_csize_shift=4 \
		ac_cv_ispeed_offset=13 \
		ac_cv_have_z_modifier=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--disable-libwrap \
	)
#	$(PATCH_LIBTOOL) $(SOCAT_BUILD_DIR)/libtool
	touch $(SOCAT_BUILD_DIR)/.configured

socat-unpack: $(SOCAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SOCAT_BUILD_DIR)/.built: $(SOCAT_BUILD_DIR)/.configured
	rm -f $(SOCAT_BUILD_DIR)/.built
	$(MAKE) -C $(SOCAT_BUILD_DIR)
	touch $(SOCAT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
socat: $(SOCAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SOCAT_BUILD_DIR)/.staged: $(SOCAT_BUILD_DIR)/.built
	rm -f $(SOCAT_BUILD_DIR)/.staged
	$(MAKE) -C $(SOCAT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SOCAT_BUILD_DIR)/.staged

socat-stage: $(SOCAT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/socat
#
$(SOCAT_IPK_DIR)/CONTROL/control:
	@install -d $(SOCAT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: socat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SOCAT_PRIORITY)" >>$@
	@echo "Section: $(SOCAT_SECTION)" >>$@
	@echo "Version: $(SOCAT_VERSION)-$(SOCAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SOCAT_MAINTAINER)" >>$@
	@echo "Source: $(SOCAT_SITE)/$(SOCAT_SOURCE)" >>$@
	@echo "Description: $(SOCAT_DESCRIPTION)" >>$@
	@echo "Depends: $(SOCAT_DEPENDS)" >>$@
	@echo "Suggests: $(SOCAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(SOCAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SOCAT_IPK_DIR)/opt/sbin or $(SOCAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SOCAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SOCAT_IPK_DIR)/opt/etc/socat/...
# Documentation files should be installed in $(SOCAT_IPK_DIR)/opt/doc/socat/...
# Daemon startup scripts should be installed in $(SOCAT_IPK_DIR)/opt/etc/init.d/S??socat
#
# You may need to patch your application to make it use these locations.
#
$(SOCAT_IPK): $(SOCAT_BUILD_DIR)/.built
	rm -rf $(SOCAT_IPK_DIR) $(BUILD_DIR)/socat_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SOCAT_BUILD_DIR) DESTDIR=$(SOCAT_IPK_DIR) install
	$(STRIP_COMMAND) $(SOCAT_IPK_DIR)/opt/bin/*
#	install -d $(SOCAT_IPK_DIR)/opt/etc/
#	install -m 644 $(SOCAT_SOURCE_DIR)/socat.conf $(SOCAT_IPK_DIR)/opt/etc/socat.conf
#	install -d $(SOCAT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SOCAT_SOURCE_DIR)/rc.socat $(SOCAT_IPK_DIR)/opt/etc/init.d/SXXsocat
	$(MAKE) $(SOCAT_IPK_DIR)/CONTROL/control
#	install -m 755 $(SOCAT_SOURCE_DIR)/postinst $(SOCAT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SOCAT_SOURCE_DIR)/prerm $(SOCAT_IPK_DIR)/CONTROL/prerm
	echo $(SOCAT_CONFFILES) | sed -e 's/ /\n/g' > $(SOCAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SOCAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
socat-ipk: $(SOCAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
socat-clean:
	rm -f $(SOCAT_BUILD_DIR)/.built
	-$(MAKE) -C $(SOCAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
socat-dirclean:
	rm -rf $(BUILD_DIR)/$(SOCAT_DIR) $(SOCAT_BUILD_DIR) $(SOCAT_IPK_DIR) $(SOCAT_IPK)

#
# Some sanity check for the package.
#
socat-check: $(SOCAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SOCAT_IPK)
