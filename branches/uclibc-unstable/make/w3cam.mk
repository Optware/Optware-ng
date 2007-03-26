###########################################################
#
# w3cam
#
###########################################################

#
# W3CAM_VERSION, W3CAM_SITE and W3CAM_SOURCE define
# the upstream location of the source code for the package.
# W3CAM_DIR is the directory which is created when the source
# archive is unpacked.
# W3CAM_UNZIP is the command used to unzip the source.
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
W3CAM_SITE=http://mpx.freeshell.net
W3CAM_VERSION=0.7.2
W3CAM_SOURCE=w3cam-$(W3CAM_VERSION).tar.gz
W3CAM_DIR=w3cam-$(W3CAM_VERSION)
W3CAM_UNZIP=zcat
W3CAM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
W3CAM_DESCRIPTION=w3cam is a simple CGI to retrieve images from a so called video4linux device
W3CAM_SECTION=misc
W3CAM_PRIORITY=optional
W3CAM_DEPENDS=libjpeg

#
# W3CAM_IPK_VERSION should be incremented when the ipk changes.
#
W3CAM_IPK_VERSION=2

#
# W3CAM_CONFFILES should be a list of user-editable files
W3CAM_CONFFILES=

#
# W3CAM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
W3CAM_PATCHES=$(W3CAM_SOURCE_DIR)/staticpaths.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
W3CAM_CPPFLAGS=
W3CAM_LDFLAGS=

#
# W3CAM_BUILD_DIR is the directory in which the build is done.
# W3CAM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# W3CAM_IPK_DIR is the directory in which the ipk is built.
# W3CAM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
W3CAM_BUILD_DIR=$(BUILD_DIR)/w3cam
W3CAM_SOURCE_DIR=$(SOURCE_DIR)/w3cam
W3CAM_IPK_DIR=$(BUILD_DIR)/w3cam-$(W3CAM_VERSION)-ipk
W3CAM_IPK=$(BUILD_DIR)/w3cam_$(W3CAM_VERSION)-$(W3CAM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: w3cam-source w3cam-unpack w3cam w3cam-stage w3cam-ipk w3cam-clean w3cam-dirclean w3cam-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(W3CAM_SOURCE):
	$(WGET) -P $(DL_DIR) $(W3CAM_SITE)/$(W3CAM_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
w3cam-source: $(DL_DIR)/$(W3CAM_SOURCE) $(W3CAM_PATCHES)

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
$(W3CAM_BUILD_DIR)/.configured: $(DL_DIR)/$(W3CAM_SOURCE) $(W3CAM_PATCHES)
	$(MAKE) libjpeg-stage libpng-stage
	rm -rf $(BUILD_DIR)/$(W3CAM_DIR) $(W3CAM_BUILD_DIR)
	$(W3CAM_UNZIP) $(DL_DIR)/$(W3CAM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(W3CAM_PATCHES) | patch -d $(BUILD_DIR)/$(W3CAM_DIR) -p1
	mv $(BUILD_DIR)/$(W3CAM_DIR) $(W3CAM_BUILD_DIR)
	(cd $(W3CAM_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(W3CAM_CPPFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(W3CAM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(W3CAM_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--without-ttf-inc \
	)
	touch $(W3CAM_BUILD_DIR)/.configured

w3cam-unpack: $(W3CAM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(W3CAM_BUILD_DIR)/.built: $(W3CAM_BUILD_DIR)/.configured
	rm -f $(W3CAM_BUILD_DIR)/.built
	$(MAKE) -C $(W3CAM_BUILD_DIR)
	touch $(W3CAM_BUILD_DIR)/.built

#
# This is the build convenience target.
#
w3cam: $(W3CAM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(W3CAM_BUILD_DIR)/.staged: $(W3CAM_BUILD_DIR)/.built
	rm -f $(W3CAM_BUILD_DIR)/.staged
	$(MAKE) -C $(W3CAM_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(W3CAM_BUILD_DIR)/.staged

w3cam-stage: $(W3CAM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/w3cam
#
$(W3CAM_IPK_DIR)/CONTROL/control:
	@install -d $(W3CAM_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: w3cam" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(W3CAM_PRIORITY)" >>$@
	@echo "Section: $(W3CAM_SECTION)" >>$@
	@echo "Version: $(W3CAM_VERSION)-$(W3CAM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(W3CAM_MAINTAINER)" >>$@
	@echo "Source: $(W3CAM_SITE)/$(W3CAM_SOURCE)" >>$@
	@echo "Description: $(W3CAM_DESCRIPTION)" >>$@
	@echo "Depends: $(W3CAM_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(W3CAM_IPK_DIR)/opt/sbin or $(W3CAM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(W3CAM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(W3CAM_IPK_DIR)/opt/etc/w3cam/...
# Documentation files should be installed in $(W3CAM_IPK_DIR)/opt/doc/w3cam/...
# Daemon startup scripts should be installed in $(W3CAM_IPK_DIR)/opt/etc/init.d/S??w3cam
#
# You may need to patch your application to make it use these locations.
#
$(W3CAM_IPK): $(W3CAM_BUILD_DIR)/.built
	rm -rf $(W3CAM_IPK_DIR) $(BUILD_DIR)/w3cam_*_$(TARGET_ARCH).ipk

	install -d $(W3CAM_IPK_DIR)/opt/bin/
	install -d $(W3CAM_IPK_DIR)/opt/sbin/
	install -d $(W3CAM_IPK_DIR)/opt/man/man1
	install -d $(W3CAM_IPK_DIR)/opt/share/apache2/htdocs/cgi-bin/
	install -m 755 $(W3CAM_BUILD_DIR)/w3camd/w3camd $(W3CAM_IPK_DIR)/opt/sbin/w3camd
	install -m 755 $(W3CAM_BUILD_DIR)/w3cam.cgi $(W3CAM_IPK_DIR)/opt/share/apache2/htdocs/cgi-bin/w3cam.cgi
	install -m 755 $(W3CAM_BUILD_DIR)/vidcat $(W3CAM_IPK_DIR)/opt/bin/vidcat
	install -m 644 $(W3CAM_BUILD_DIR)/vidcat.1 $(W3CAM_IPK_DIR)/opt/man/man1/vidcat.1
	$(MAKE) $(W3CAM_IPK_DIR)/CONTROL/control
	$(STRIP_COMMAND) \
		$(W3CAM_IPK_DIR)/opt/bin/vidcat \
		$(W3CAM_IPK_DIR)/opt/sbin/w3camd \
		$(W3CAM_IPK_DIR)/opt/share/apache2/htdocs/cgi-bin/w3cam.cgi
#	install -m 755 $(W3CAM_SOURCE_DIR)/postinst $(W3CAM_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(W3CAM_SOURCE_DIR)/prerm $(W3CAM_IPK_DIR)/CONTROL/prerm
	echo $(W3CAM_CONFFILES) | sed -e 's/ /\n/g' > $(W3CAM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(W3CAM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
w3cam-ipk: $(W3CAM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
w3cam-clean:
	-$(MAKE) -C $(W3CAM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
w3cam-dirclean:
	rm -rf $(BUILD_DIR)/$(W3CAM_DIR) $(W3CAM_BUILD_DIR) $(W3CAM_IPK_DIR) $(W3CAM_IPK)

#
# Some sanity check for the package.
#
w3cam-check: $(W3CAM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(W3CAM_IPK)
