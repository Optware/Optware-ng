###########################################################
#
# nzbget
#
###########################################################
#
# NZBGET_VERSION, NZBGET_SITE and NZBGET_SOURCE define
# the upstream location of the source code for the package.
# NZBGET_DIR is the directory which is created when the source
# archive is unpacked.
# NZBGET_UNZIP is the command used to unzip the source.
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
NZBGET_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/nzbget
NZBGET_VERSION=0.2.3
NZBGET_SOURCE=nzbget-$(NZBGET_VERSION).tar.gz
NZBGET_DIR=nzbget-$(NZBGET_VERSION)
NZBGET_UNZIP=zcat
NZBGET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NZBGET_DESCRIPTION=A command-line based binary newsgrabber supporting nzb-files.
NZBGET_SECTION=net
NZBGET_PRIORITY=optional
NZBGET_DEPENDS=libxml2, ncurses, libstdc++, zlib
NZBGET_SUGGESTS=
NZBGET_CONFLICTS=

#
# NZBGET_IPK_VERSION should be incremented when the ipk changes.
#
NZBGET_IPK_VERSION=1

#
# NZBGET_CONFFILES should be a list of user-editable files
#NZBGET_CONFFILES=/opt/etc/nzbget.conf /opt/etc/init.d/SXXnzbget

#
# NZBGET_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NZBGET_PATCHES=$(NZBGET_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NZBGET_CPPFLAGS=
NZBGET_LDFLAGS=

#
# NZBGET_BUILD_DIR is the directory in which the build is done.
# NZBGET_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NZBGET_IPK_DIR is the directory in which the ipk is built.
# NZBGET_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NZBGET_BUILD_DIR=$(BUILD_DIR)/nzbget
NZBGET_SOURCE_DIR=$(SOURCE_DIR)/nzbget
NZBGET_IPK_DIR=$(BUILD_DIR)/nzbget-$(NZBGET_VERSION)-ipk
NZBGET_IPK=$(BUILD_DIR)/nzbget_$(NZBGET_VERSION)-$(NZBGET_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NZBGET_SOURCE):
	$(WGET) -P $(DL_DIR) $(NZBGET_SITE)/$(NZBGET_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nzbget-source: $(DL_DIR)/$(NZBGET_SOURCE) $(NZBGET_PATCHES)

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
$(NZBGET_BUILD_DIR)/.configured: $(DL_DIR)/$(NZBGET_SOURCE) $(NZBGET_PATCHES) make/nzbget.mk
	$(MAKE) libxml2-stage ncurses-stage libstdc++-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(NZBGET_DIR) $(NZBGET_BUILD_DIR)
	$(NZBGET_UNZIP) $(DL_DIR)/$(NZBGET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NZBGET_PATCHES)" ; \
		then cat $(NZBGET_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NZBGET_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NZBGET_DIR)" != "$(NZBGET_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NZBGET_DIR) $(NZBGET_BUILD_DIR) ; \
	fi
	cp -f $(SOURCE_DIR)/common/config.* $(NZBGET_BUILD_DIR)/
	(cd $(NZBGET_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NZBGET_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NZBGET_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-stl-includes=$(STAGING_INCLUDE_DIR) \
		--with-stl-libraries=$(STAGING_LIB_DIR) \
		--with-libxml2-includes=$(STAGING_INCLUDE_DIR)/libxml2 \
		--with-libxml2-libraries=$(STAGING_LIB_DIR) \
	)
	sed -i -e '/^CPPFLAGS/s:-I/usr.*$$::' -e '/^LDFLAGS/s:-L/usr.*$$::' \
		$(NZBGET_BUILD_DIR)/Makefile
#	$(PATCH_LIBTOOL) $(NZBGET_BUILD_DIR)/libtool
	touch $(NZBGET_BUILD_DIR)/.configured

nzbget-unpack: $(NZBGET_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NZBGET_BUILD_DIR)/.built: $(NZBGET_BUILD_DIR)/.configured
	rm -f $(NZBGET_BUILD_DIR)/.built
	$(MAKE) -C $(NZBGET_BUILD_DIR)
	touch $(NZBGET_BUILD_DIR)/.built

#
# This is the build convenience target.
#
nzbget: $(NZBGET_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NZBGET_BUILD_DIR)/.staged: $(NZBGET_BUILD_DIR)/.built
	rm -f $(NZBGET_BUILD_DIR)/.staged
	$(MAKE) -C $(NZBGET_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(NZBGET_BUILD_DIR)/.staged

nzbget-stage: $(NZBGET_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nzbget
#
$(NZBGET_IPK_DIR)/CONTROL/control:
	@install -d $(NZBGET_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: nzbget" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NZBGET_PRIORITY)" >>$@
	@echo "Section: $(NZBGET_SECTION)" >>$@
	@echo "Version: $(NZBGET_VERSION)-$(NZBGET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NZBGET_MAINTAINER)" >>$@
	@echo "Source: $(NZBGET_SITE)/$(NZBGET_SOURCE)" >>$@
	@echo "Description: $(NZBGET_DESCRIPTION)" >>$@
	@echo "Depends: $(NZBGET_DEPENDS)" >>$@
	@echo "Suggests: $(NZBGET_SUGGESTS)" >>$@
	@echo "Conflicts: $(NZBGET_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NZBGET_IPK_DIR)/opt/sbin or $(NZBGET_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NZBGET_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NZBGET_IPK_DIR)/opt/etc/nzbget/...
# Documentation files should be installed in $(NZBGET_IPK_DIR)/opt/doc/nzbget/...
# Daemon startup scripts should be installed in $(NZBGET_IPK_DIR)/opt/etc/init.d/S??nzbget
#
# You may need to patch your application to make it use these locations.
#
$(NZBGET_IPK): $(NZBGET_BUILD_DIR)/.built
	rm -rf $(NZBGET_IPK_DIR) $(BUILD_DIR)/nzbget_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(NZBGET_BUILD_DIR) DESTDIR=$(NZBGET_IPK_DIR) install
	install -d $(NZBGET_IPK_DIR)/opt/bin $(NZBGET_IPK_DIR)/opt/share/doc/nzbget
	install -m 755 $(NZBGET_BUILD_DIR)/nzbget $(NZBGET_IPK_DIR)/opt/bin/
	install -m 644 $(NZBGET_BUILD_DIR)/nzbget.cfg.example $(NZBGET_IPK_DIR)/opt/share/doc/nzbget/
	$(STRIP_COMMAND) $(NZBGET_IPK_DIR)/opt/bin/nzbget
#	install -d $(NZBGET_IPK_DIR)/opt/etc/
#	install -m 644 $(NZBGET_SOURCE_DIR)/nzbget.conf $(NZBGET_IPK_DIR)/opt/etc/nzbget.conf
#	install -d $(NZBGET_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NZBGET_SOURCE_DIR)/rc.nzbget $(NZBGET_IPK_DIR)/opt/etc/init.d/SXXnzbget
	$(MAKE) $(NZBGET_IPK_DIR)/CONTROL/control
#	install -m 755 $(NZBGET_SOURCE_DIR)/postinst $(NZBGET_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NZBGET_SOURCE_DIR)/prerm $(NZBGET_IPK_DIR)/CONTROL/prerm
	echo $(NZBGET_CONFFILES) | sed -e 's/ /\n/g' > $(NZBGET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NZBGET_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nzbget-ipk: $(NZBGET_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nzbget-clean:
	rm -f $(NZBGET_BUILD_DIR)/.built
	-$(MAKE) -C $(NZBGET_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nzbget-dirclean:
	rm -rf $(BUILD_DIR)/$(NZBGET_DIR) $(NZBGET_BUILD_DIR) $(NZBGET_IPK_DIR) $(NZBGET_IPK)
