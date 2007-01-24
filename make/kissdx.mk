###########################################################
#
# kissdx
#
###########################################################

#
# KISSDX_VERSION, KISSDX_SITE and KISSDX_SOURCE define
# the upstream location of the source code for the package.
# KISSDX_DIR is the directory which is created when the source
# archive is unpacked.
# KISSDX_UNZIP is the command used to unzip the source.
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
KISSDX_SITE=http://kissdx.vidartysse.net
KISSDX_VERSION=0.13-10
KISSDX_SOURCE=kissdx-$(KISSDX_VERSION).tar.gz
KISSDX_DIR=kissdx-$(KISSDX_VERSION)
KISSDX_UNZIP=zcat
KISSDX_MAINTAINER=Vidar Tysse <kissdx@vidartysse.net>
KISSDX_DESCRIPTION=kissdx is a PC-Link clone for KiSS media players with added features for DVD, video and picture playback.
KISSDX_SECTION=net
KISSDX_PRIORITY=optional
KISSDX_DEPENDS=libdvdread,libjpeg
KISSDX_SUGGESTS=gconv-modules
KISSDX_CONFLICTS=

#
# KISSDX_IPK_VERSION should be incremented when the ipk changes.
#
KISSDX_IPK_VERSION=1

#
# KISSDX_CONFFILES should be a list of user-editable files
KISSDX_CONFFILES=/opt/etc/kissdx.conf /opt/etc/init.d/S83kissdx

#
# KISSDX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifeq ($(OPTWARE_TARGET),wl500g)
KISSDX_PATCHES=${KISSDX_SOURCE_DIR}/config.c.patch ${KISSDX_SOURCE_DIR}/kissdx.1.patch ${KISSDX_SOURCE_DIR}/kissdx.conf.patch ${KISSDX_SOURCE_DIR}/piccache.c_wl500g.patch ${KISSDX_SOURCE_DIR}/utils.c_wl500g.patch
else
KISSDX_PATCHES=${KISSDX_SOURCE_DIR}/config.c.patch ${KISSDX_SOURCE_DIR}/kissdx.1.patch ${KISSDX_SOURCE_DIR}/kissdx.conf.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
KISSDX_CPPFLAGS=
KISSDX_LDFLAGS=-s

#
# KISSDX_BUILD_DIR is the directory in which the build is done.
# KISSDX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# KISSDX_IPK_DIR is the directory in which the ipk is built.
# KISSDX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
KISSDX_BUILD_DIR=$(BUILD_DIR)/kissdx
KISSDX_SOURCE_DIR=$(SOURCE_DIR)/kissdx
KISSDX_IPK_DIR=$(BUILD_DIR)/kissdx-$(KISSDX_VERSION)-ipk
KISSDX_IPK=$(BUILD_DIR)/kissdx_$(KISSDX_VERSION)-$(KISSDX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: kissdx-source kissdx-unpack kissdx kissdx-stage kissdx-ipk kissdx-clean kissdx-dirclean kissdx-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(KISSDX_SOURCE):
	$(WGET) -P $(DL_DIR) $(KISSDX_SITE)/$(KISSDX_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
kissdx-source: $(DL_DIR)/$(KISSDX_SOURCE) $(KISSDX_PATCHES)

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
$(KISSDX_BUILD_DIR)/.configured: $(DL_DIR)/$(KISSDX_SOURCE) $(KISSDX_PATCHES) make/kissdx.mk
	$(MAKE) libdvdread-stage libjpeg-stage
	rm -rf $(BUILD_DIR)/$(KISSDX_DIR) $(KISSDX_BUILD_DIR)
	$(KISSDX_UNZIP) $(DL_DIR)/$(KISSDX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(KISSDX_PATCHES)" ; \
		then cat $(KISSDX_PATCHES) | \
		patch -d $(BUILD_DIR)/$(KISSDX_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(KISSDX_DIR)" != "$(KISSDX_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(KISSDX_DIR) $(KISSDX_BUILD_DIR) ; \
	fi
#	(cd $(KISSDX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(KISSDX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(KISSDX_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	rm -f $(KISSDX_BUILD_DIR)/Makefile
	mv $(KISSDX_BUILD_DIR)/Makefile-Unslung $(KISSDX_BUILD_DIR)/Makefile
	sed -i "s#CFLAGS = #CFLAGS = ${STAGING_CPPFLAGS} ${KISSDX_CPPFLAGS} #" $(KISSDX_BUILD_DIR)/Makefile
	sed -i "s#-L/opt/lib#${STAGING_LDFLAGS} ${KISSDX_LDFLAGS}#" $(KISSDX_BUILD_DIR)/Makefile
	sed -i "s#$(DESTDIR)/usr/sbin/#${STAGING_DIR}/opt/bin/#g" $(KISSDX_BUILD_DIR)/Makefile
	sed -i "s#$(DESTDIR)/etc/#${STAGING_DIR}/opt/etc/#g" $(KISSDX_BUILD_DIR)/Makefile
	sed -i "s#$(DESTDIR)/usr/share/man/#${STAGING_DIR}/opt/man/#g" $(KISSDX_BUILD_DIR)/Makefile
	sed -i "s#-S .old ##g" $(KISSDX_BUILD_DIR)/Makefile
	touch $(KISSDX_BUILD_DIR)/.configured

kissdx-unpack: $(KISSDX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(KISSDX_BUILD_DIR)/.built: $(KISSDX_BUILD_DIR)/.configured
	rm -f $(KISSDX_BUILD_DIR)/.built
	$(MAKE) -C $(KISSDX_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)
	$(STRIP_COMMAND) $(KISSDX_BUILD_DIR)/kissdx
	touch $(KISSDX_BUILD_DIR)/.built

#
# This is the build convenience target.
#
kissdx: $(KISSDX_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/kissdx
#
$(KISSDX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: kissdx" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(KISSDX_PRIORITY)" >>$@
	@echo "Section: $(KISSDX_SECTION)" >>$@
	@echo "Version: $(KISSDX_VERSION)-$(KISSDX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(KISSDX_MAINTAINER)" >>$@
	@echo "Source: $(KISSDX_SITE)/$(KISSDX_SOURCE)" >>$@
	@echo "Description: $(KISSDX_DESCRIPTION)" >>$@
	@echo "Depends: $(KISSDX_DEPENDS)" >>$@
	@echo "Suggests: $(KISSDX_SUGGESTS)" >>$@
	@echo "Conflicts: $(KISSDX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(KISSDX_IPK_DIR)/opt/sbin or $(KISSDX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(KISSDX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(KISSDX_IPK_DIR)/opt/etc/kissdx/...
# Documentation files should be installed in $(KISSDX_IPK_DIR)/opt/doc/kissdx/...
# Daemon startup scripts should be installed in $(KISSDX_IPK_DIR)/opt/etc/init.d/S??kissdx
#
# You may need to patch your application to make it use these locations.
#
$(KISSDX_IPK): $(KISSDX_BUILD_DIR)/.built
	rm -rf $(KISSDX_IPK_DIR) $(BUILD_DIR)/kissdx_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(KISSDX_BUILD_DIR) DESTDIR=$(KISSDX_IPK_DIR)
	install -d $(KISSDX_IPK_DIR)/opt/bin/
	install -m 755 $(KISSDX_BUILD_DIR)/kissdx $(KISSDX_IPK_DIR)/opt/bin/kissdx
	install -d $(KISSDX_IPK_DIR)/opt/etc/
	install -m 644 $(KISSDX_BUILD_DIR)/kissdx.conf $(KISSDX_IPK_DIR)/opt/etc/kissdx.conf
	install -d $(KISSDX_IPK_DIR)/opt/etc/init.d
	install -m 755 $(KISSDX_SOURCE_DIR)/rc.kissdx $(KISSDX_IPK_DIR)/opt/etc/init.d/S83kissdx
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(KISSDX_IPK_DIR)/opt/etc/init.d/S83kissdx
	install -d $(KISSDX_IPK_DIR)/opt/man/man1/
	install -m 644 $(KISSDX_BUILD_DIR)/kissdx.1 $(KISSDX_IPK_DIR)/opt/man/man1/kissdx.1
	$(MAKE) $(KISSDX_IPK_DIR)/CONTROL/control
	install -m 755 $(KISSDX_SOURCE_DIR)/postinst $(KISSDX_IPK_DIR)/CONTROL/postinst
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(KISSDX_IPK_DIR)/CONTROL/postinst
	install -m 755 $(KISSDX_SOURCE_DIR)/prerm $(KISSDX_IPK_DIR)/CONTROL/prerm
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(KISSDX_IPK_DIR)/CONTROL/prerm
	echo $(KISSDX_CONFFILES) | sed -e 's/ /\n/g' > $(KISSDX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(KISSDX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
kissdx-ipk: $(KISSDX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
kissdx-clean:
	rm -f $(KISSDX_BUILD_DIR)/.built
	-$(MAKE) -C $(KISSDX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
kissdx-dirclean:
	rm -rf $(BUILD_DIR)/$(KISSDX_DIR) $(KISSDX_BUILD_DIR) $(KISSDX_IPK_DIR) $(KISSDX_IPK)
#
#
# Some sanity check for the package.
#
kissdx-check: $(KISSDX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(KISSDX_IPK)
