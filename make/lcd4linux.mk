##########################################################
#
# lcd4linux
#
###########################################################
#
# LCD4LINUX_VERSION, LCD4LINUX_SITE and LCD4LINUX_SOURCE define
# the upstream location of the source code for the package.
# LCD4LINUX_DIR is the directory which is created when the source
# archive is unpacked.
# LCD4LINUX_UNZIP is the command used to unzip the source.
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
LCD4LINUX_SITE=http://ssl.bulix.org/projects/lcd4linux
LCD4LINUX_SVN=https://ssl.bulix.org/svn/lcd4linux/trunk
LCD4LINUX_SVN_REV=758
LCD4LINUX_VERSION=0.10.0+r$(LCD4LINUX_SVN_REV)
LCD4LINUX_SOURCE=lcd4linux-$(LCD4LINUX_VERSION).tar.gz
LCD4LINUX_DIR=lcd4linux
LCD4LINUX_UNZIP=zcat
LCD4LINUX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LCD4LINUX_DESCRIPTION=Grabs information from the kernel and some subsystems and displays it on an external liquid crystal display
LCD4LINUX_SECTION=comm
LCD4LINUX_PRIORITY=optional
LCD4LINUX_DEPENDS=ncurses, libusb, libgd
LCD4LINUX_SUGGESTS=
LCD4LINUX_CONFLICTS=

#
# LCD4LINUX_IPK_VERSION should be incremented when the ipk changes.
#
LCD4LINUX_IPK_VERSION=1

#
# LCD4LINUX_CONFFILES should be a list of user-editable files /opt/etc/init.d/SXXlcd4linux
LCD4LINUX_CONFFILES=/opt/etc/lcd4linux.conf 

#
# LCD4LINUX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LCD4LINUX_PATCHES=$(LCD4LINUX_SOURCE_DIR)/parport-disable.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LCD4LINUX_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
LCD4LINUX_LDFLAGS=

#
# LCD4LINUX_BUILD_DIR is the directory in which the build is done.
# LCD4LINUX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LCD4LINUX_IPK_DIR is the directory in which the ipk is built.
# LCD4LINUX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LCD4LINUX_BUILD_DIR=$(BUILD_DIR)/lcd4linux
LCD4LINUX_SOURCE_DIR=$(SOURCE_DIR)/lcd4linux
LCD4LINUX_IPK_DIR=$(BUILD_DIR)/lcd4linux-$(LCD4LINUX_VERSION)-ipk
LCD4LINUX_IPK=$(BUILD_DIR)/lcd4linux_$(LCD4LINUX_VERSION)-$(LCD4LINUX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lcd4linux-source lcd4linux-unpack lcd4linux lcd4linux-stage lcd4linux-ipk lcd4linux-clean lcd4linux-dirclean lcd4linux-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
#$(DL_DIR)/$(LCD4LINUX_SOURCE):
#	$(WGET) -P $(DL_DIR) $(LCD4LINUX_SITE)/$(LCD4LINUX_SOURCE) || \
#	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LCD4LINUX_SOURCE)

$(DL_DIR)/$(LCD4LINUX_SOURCE):
	( cd $(BUILD_DIR) ; \
		rm -rf $(LCD4LINUX_DIR) && \
		echo "t" | svn co -r $(LCD4LINUX_SVN_REV) $(LCD4LINUX_SVN) \
			$(LCD4LINUX_DIR) && \
		tar -czf $@ $(LCD4LINUX_DIR) && \
		rm -rf $(LCD4LINUX_DIR) \
	)



#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lcd4linux-source: $(DL_DIR)/$(LCD4LINUX_SOURCE) $(LCD4LINUX_PATCHES)

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
$(LCD4LINUX_BUILD_DIR)/.configured: $(DL_DIR)/$(LCD4LINUX_SOURCE) $(LCD4LINUX_PATCHES) make/lcd4linux.mk
	$(MAKE) ncurses-stage libusb-stage libgd-stage
	rm -rf $(BUILD_DIR)/$(LCD4LINUX_DIR) $(LCD4LINUX_BUILD_DIR)
	$(LCD4LINUX_UNZIP) $(DL_DIR)/$(LCD4LINUX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LCD4LINUX_PATCHES)" ; \
		then cat $(LCD4LINUX_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LCD4LINUX_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LCD4LINUX_DIR)" != "$(LCD4LINUX_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LCD4LINUX_DIR) $(LCD4LINUX_BUILD_DIR) ; \
	fi
	(cd $(LCD4LINUX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LCD4LINUX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LCD4LINUX_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-ncurses=$(STAGING_INCLUDE_DIR)/ncurses \
		--without-x \
		--with-plugins=all,\!xmms \
		--with-drivers=all,\!G15,\!RouterBoard \
	)
#	$(PATCH_LIBTOOL) $(LCD4LINUX_BUILD_DIR)/libtool
	touch $@

lcd4linux-unpack: $(LCD4LINUX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LCD4LINUX_BUILD_DIR)/.built: $(LCD4LINUX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LCD4LINUX_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
lcd4linux: $(LCD4LINUX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LCD4LINUX_BUILD_DIR)/.staged: $(LCD4LINUX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LCD4LINUX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

lcd4linux-stage: $(LCD4LINUX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lcd4linux
#
$(LCD4LINUX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: lcd4linux" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LCD4LINUX_PRIORITY)" >>$@
	@echo "Section: $(LCD4LINUX_SECTION)" >>$@
	@echo "Version: $(LCD4LINUX_VERSION)-$(LCD4LINUX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LCD4LINUX_MAINTAINER)" >>$@
	@echo "Source: $(LCD4LINUX_SITE)/$(LCD4LINUX_SOURCE)" >>$@
	@echo "Description: $(LCD4LINUX_DESCRIPTION)" >>$@
	@echo "Depends: $(LCD4LINUX_DEPENDS)" >>$@
	@echo "Suggests: $(LCD4LINUX_SUGGESTS)" >>$@
	@echo "Conflicts: $(LCD4LINUX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LCD4LINUX_IPK_DIR)/opt/sbin or $(LCD4LINUX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LCD4LINUX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LCD4LINUX_IPK_DIR)/opt/etc/lcd4linux/...
# Documentation files should be installed in $(LCD4LINUX_IPK_DIR)/opt/doc/lcd4linux/...
# Daemon startup scripts should be installed in $(LCD4LINUX_IPK_DIR)/opt/etc/init.d/S??lcd4linux
#
# You may need to patch your application to make it use these locations.
#
$(LCD4LINUX_IPK): $(LCD4LINUX_BUILD_DIR)/.built
	rm -rf $(LCD4LINUX_IPK_DIR) $(BUILD_DIR)/lcd4linux_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LCD4LINUX_BUILD_DIR) DESTDIR=$(LCD4LINUX_IPK_DIR) install-strip
	install -d $(LCD4LINUX_IPK_DIR)/opt/etc/
	install -m 644 $(LCD4LINUX_SOURCE_DIR)/lcd4linux.conf $(LCD4LINUX_IPK_DIR)/opt/etc/lcd4linux.conf
#	install -d $(LCD4LINUX_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LCD4LINUX_SOURCE_DIR)/rc.lcd4linux $(LCD4LINUX_IPK_DIR)/opt/etc/init.d/SXXlcd4linux
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LCD4LINUX_IPK_DIR)/opt/etc/init.d/SXXlcd4linux
	$(MAKE) $(LCD4LINUX_IPK_DIR)/CONTROL/control
#	install -m 755 $(LCD4LINUX_SOURCE_DIR)/postinst $(LCD4LINUX_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LCD4LINUX_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LCD4LINUX_SOURCE_DIR)/prerm $(LCD4LINUX_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LCD4LINUX_IPK_DIR)/CONTROL/prerm
	echo $(LCD4LINUX_CONFFILES) | sed -e 's/ /\n/g' > $(LCD4LINUX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LCD4LINUX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lcd4linux-ipk: $(LCD4LINUX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lcd4linux-clean:
	rm -f $(LCD4LINUX_BUILD_DIR)/.built
	-$(MAKE) -C $(LCD4LINUX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lcd4linux-dirclean:
	rm -rf $(BUILD_DIR)/$(LCD4LINUX_DIR) $(LCD4LINUX_BUILD_DIR) $(LCD4LINUX_IPK_DIR) $(LCD4LINUX_IPK)
#
#
# Some sanity check for the package.
#
lcd4linux-check: $(LCD4LINUX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LCD4LINUX_IPK)
