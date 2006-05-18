###########################################################
#
# cdparanoia
#
###########################################################
#
# CDPARANOIA_VERSION, CDPARANOIA_SITE and CDPARANOIA_SOURCE define
# the upstream location of the source code for the package.
# CDPARANOIA_DIR is the directory which is created when the source
# archive is unpacked.
# CDPARANOIA_UNZIP is the command used to unzip the source.
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
CDPARANOIA_SITE=http://downloads.xiph.org/releases/cdparanoia/
CDPARANOIA_VERSION=3.9.8
CDPARANOIA_SOURCE=cdparanoia-III-alpha9.8.src.tgz
CDPARANOIA_DIR=cdparanoia-III-alpha9.8
CDPARANOIA_UNZIP=zcat
CDPARANOIA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CDPARANOIA_DESCRIPTION="Use your CDROM drive to read audio tracks.... and have it actually work right!"
CDPARANOIA_SECTION=extras
CDPARANOIA_PRIORITY=optional
CDPARANOIA_DEPENDS=
CDPARANOIA_SUGGESTS=
CDPARANOIA_CONFLICTS=

#
# CDPARANOIA_IPK_VERSION should be incremented when the ipk changes.
#
CDPARANOIA_IPK_VERSION=1

#
# CDPARANOIA_CONFFILES should be a list of user-editable files
#CDPARANOIA_CONFFILES=/opt/etc/cdparanoia.conf /opt/etc/init.d/SXXcdparanoia

#
# CDPARANOIA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CDPARANOIA_PATCHES=$(CDPARANOIA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CDPARANOIA_CPPFLAGS=
CDPARANOIA_LDFLAGS=

#
# CDPARANOIA_BUILD_DIR is the directory in which the build is done.
# CDPARANOIA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CDPARANOIA_IPK_DIR is the directory in which the ipk is built.
# CDPARANOIA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CDPARANOIA_BUILD_DIR=$(BUILD_DIR)/cdparanoia
CDPARANOIA_SOURCE_DIR=$(SOURCE_DIR)/cdparanoia
CDPARANOIA_IPK_DIR=$(BUILD_DIR)/cdparanoia-$(CDPARANOIA_VERSION)-ipk
CDPARANOIA_IPK=$(BUILD_DIR)/cdparanoia_$(CDPARANOIA_VERSION)-$(CDPARANOIA_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CDPARANOIA_SOURCE):
	$(WGET) -P $(DL_DIR) $(CDPARANOIA_SITE)/$(CDPARANOIA_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cdparanoia-source: $(DL_DIR)/$(CDPARANOIA_SOURCE) $(CDPARANOIA_PATCHES)

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
$(CDPARANOIA_BUILD_DIR)/.configured: $(DL_DIR)/$(CDPARANOIA_SOURCE) $(CDPARANOIA_PATCHES) make/cdparanoia.mk
	rm -rf $(BUILD_DIR)/$(CDPARANOIA_DIR) $(CDPARANOIA_BUILD_DIR)
	$(CDPARANOIA_UNZIP) $(DL_DIR)/$(CDPARANOIA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CDPARANOIA_PATCHES)" ; \
		then cat $(CDPARANOIA_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CDPARANOIA_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CDPARANOIA_DIR)" != "$(CDPARANOIA_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CDPARANOIA_DIR) $(CDPARANOIA_BUILD_DIR) ; \
	fi
	sed -i -e 's/strip cdparanoia//' $(CDPARANOIA_BUILD_DIR)/Makefile.in
	rm $(CDPARANOIA_BUILD_DIR)/configure.sub
	rm $(CDPARANOIA_BUILD_DIR)/configure.guess
	# libtool is not really used here - this is just a trick to
	# produce an updated config.sub
	(cd $(CDPARANOIA_BUILD_DIR); \
		libtoolize -c ; \
		cp config.guess configure.guess ; \
		cp config.sub configure.sub ; \
		$(TARGET_CONFIGURE_OPTS) \
		ac_cv_sizeof_short=2 \
		ac_cv_sizeof_long=4 \
		ac_cv_sizeof_int=4 \
		ac_cv_sizeof_long_long=8 \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CDPARANOIA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CDPARANOIA_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $(CDPARANOIA_BUILD_DIR)/.configured

cdparanoia-unpack: $(CDPARANOIA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CDPARANOIA_BUILD_DIR)/.built: $(CDPARANOIA_BUILD_DIR)/.configured
	rm -f $(CDPARANOIA_BUILD_DIR)/.built
	$(MAKE) -C $(CDPARANOIA_BUILD_DIR)
	touch $(CDPARANOIA_BUILD_DIR)/.built

#
# This is the build convenience target.
#
cdparanoia: $(CDPARANOIA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CDPARANOIA_BUILD_DIR)/.staged: $(CDPARANOIA_BUILD_DIR)/.built
	rm -f $(CDPARANOIA_BUILD_DIR)/.staged
	$(MAKE) -C $(CDPARANOIA_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CDPARANOIA_BUILD_DIR)/.staged

cdparanoia-stage: $(CDPARANOIA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cdparanoia
#
$(CDPARANOIA_IPK_DIR)/CONTROL/control:
	@install -d $(CDPARANOIA_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: cdparanoia" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CDPARANOIA_PRIORITY)" >>$@
	@echo "Section: $(CDPARANOIA_SECTION)" >>$@
	@echo "Version: $(CDPARANOIA_VERSION)-$(CDPARANOIA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CDPARANOIA_MAINTAINER)" >>$@
	@echo "Source: $(CDPARANOIA_SITE)/$(CDPARANOIA_SOURCE)" >>$@
	@echo "Description: $(CDPARANOIA_DESCRIPTION)" >>$@
	@echo "Depends: $(CDPARANOIA_DEPENDS)" >>$@
	@echo "Suggests: $(CDPARANOIA_SUGGESTS)" >>$@
	@echo "Conflicts: $(CDPARANOIA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CDPARANOIA_IPK_DIR)/opt/sbin or $(CDPARANOIA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CDPARANOIA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CDPARANOIA_IPK_DIR)/opt/etc/cdparanoia/...
# Documentation files should be installed in $(CDPARANOIA_IPK_DIR)/opt/doc/cdparanoia/...
# Daemon startup scripts should be installed in $(CDPARANOIA_IPK_DIR)/opt/etc/init.d/S??cdparanoia
#
# You may need to patch your application to make it use these locations.
#
$(CDPARANOIA_IPK): $(CDPARANOIA_BUILD_DIR)/.built
	rm -rf $(CDPARANOIA_IPK_DIR) $(BUILD_DIR)/cdparanoia_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CDPARANOIA_BUILD_DIR) DESTDIR=$(CDPARANOIA_IPK_DIR) install-strip
	install -d $(CDPARANOIA_IPK_DIR)/opt/etc/
	install -m 644 $(CDPARANOIA_SOURCE_DIR)/cdparanoia.conf $(CDPARANOIA_IPK_DIR)/opt/etc/cdparanoia.conf
	install -d $(CDPARANOIA_IPK_DIR)/opt/etc/init.d
	install -m 755 $(CDPARANOIA_SOURCE_DIR)/rc.cdparanoia $(CDPARANOIA_IPK_DIR)/opt/etc/init.d/SXXcdparanoia
	$(MAKE) $(CDPARANOIA_IPK_DIR)/CONTROL/control
	install -m 755 $(CDPARANOIA_SOURCE_DIR)/postinst $(CDPARANOIA_IPK_DIR)/CONTROL/postinst
	install -m 755 $(CDPARANOIA_SOURCE_DIR)/prerm $(CDPARANOIA_IPK_DIR)/CONTROL/prerm
	echo $(CDPARANOIA_CONFFILES) | sed -e 's/ /\n/g' > $(CDPARANOIA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CDPARANOIA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cdparanoia-ipk: $(CDPARANOIA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cdparanoia-clean:
	rm -f $(CDPARANOIA_BUILD_DIR)/.built
	-$(MAKE) -C $(CDPARANOIA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cdparanoia-dirclean:
	rm -rf $(BUILD_DIR)/$(CDPARANOIA_DIR) $(CDPARANOIA_BUILD_DIR) $(CDPARANOIA_IPK_DIR) $(CDPARANOIA_IPK)
