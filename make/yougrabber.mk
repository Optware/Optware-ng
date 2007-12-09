###########################################################
#
# yougrabber
#
###########################################################
#
# YOUGRABBER_VERSION, YOUGRABBER_SITE and YOUGRABBER_SOURCE define
# the upstream location of the source code for the package.
# YOUGRABBER_DIR is the directory which is created when the source
# archive is unpacked.
# YOUGRABBER_UNZIP is the command used to unzip the source.
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
YOUGRABBER_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/yougrabber
YOUGRABBER_VERSION=0.29.2
YOUGRABBER_SOURCE=yougrabber-$(YOUGRABBER_VERSION).tar.bz2
YOUGRABBER_DIR=yougrabber-$(YOUGRABBER_VERSION)
YOUGRABBER_UNZIP=bzcat
YOUGRABBER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
YOUGRABBER_DESCRIPTION=YouGrabber is a lightweight, multi-threaded (NPTL based) command line YouTube.com video downloader.
YOUGRABBER_SECTION=misc
YOUGRABBER_PRIORITY=optional
YOUGRABBER_DEPENDS=glib, libcurl, ncurses, openssl
YOUGRABBER_SUGGESTS=
YOUGRABBER_CONFLICTS=

#
# YOUGRABBER_IPK_VERSION should be incremented when the ipk changes.
#
YOUGRABBER_IPK_VERSION=1

#
# YOUGRABBER_CONFFILES should be a list of user-editable files
#YOUGRABBER_CONFFILES=/opt/etc/yougrabber.conf /opt/etc/init.d/SXXyougrabber

#
# YOUGRABBER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#YOUGRABBER_PATCHES=$(YOUGRABBER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
YOUGRABBER_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
YOUGRABBER_LDFLAGS=

#
# YOUGRABBER_BUILD_DIR is the directory in which the build is done.
# YOUGRABBER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# YOUGRABBER_IPK_DIR is the directory in which the ipk is built.
# YOUGRABBER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
YOUGRABBER_BUILD_DIR=$(BUILD_DIR)/yougrabber
YOUGRABBER_SOURCE_DIR=$(SOURCE_DIR)/yougrabber
YOUGRABBER_IPK_DIR=$(BUILD_DIR)/yougrabber-$(YOUGRABBER_VERSION)-ipk
YOUGRABBER_IPK=$(BUILD_DIR)/yougrabber_$(YOUGRABBER_VERSION)-$(YOUGRABBER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: yougrabber-source yougrabber-unpack yougrabber yougrabber-stage yougrabber-ipk yougrabber-clean yougrabber-dirclean yougrabber-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(YOUGRABBER_SOURCE):
	$(WGET) -P $(DL_DIR) $(YOUGRABBER_SITE)/$(YOUGRABBER_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(YOUGRABBER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
yougrabber-source: $(DL_DIR)/$(YOUGRABBER_SOURCE) $(YOUGRABBER_PATCHES)

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
$(YOUGRABBER_BUILD_DIR)/.configured: $(DL_DIR)/$(YOUGRABBER_SOURCE) $(YOUGRABBER_PATCHES) make/yougrabber.mk
	$(MAKE) glib-stage libcurl-stage ncurses-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(YOUGRABBER_DIR) $(@D)
	$(YOUGRABBER_UNZIP) $(DL_DIR)/$(YOUGRABBER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(YOUGRABBER_PATCHES)" ; \
		then cat $(YOUGRABBER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(YOUGRABBER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(YOUGRABBER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(YOUGRABBER_DIR) $(@D) ; \
	fi
#	(cd $(YOUGRABBER_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(YOUGRABBER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(YOUGRABBER_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(YOUGRABBER_BUILD_DIR)/libtool
	touch $@

yougrabber-unpack: $(YOUGRABBER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(YOUGRABBER_BUILD_DIR)/.built: $(YOUGRABBER_BUILD_DIR)/.configured
	rm -f $@
	PATH=$(STAGING_PREFIX)/bin:$$PATH \
	PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
	$(MAKE) -C $(@D)/src \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(YOUGRABBER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(YOUGRABBER_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
yougrabber: $(YOUGRABBER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(YOUGRABBER_BUILD_DIR)/.staged: $(YOUGRABBER_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(YOUGRABBER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

yougrabber-stage: $(YOUGRABBER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/yougrabber
#
$(YOUGRABBER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: yougrabber" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(YOUGRABBER_PRIORITY)" >>$@
	@echo "Section: $(YOUGRABBER_SECTION)" >>$@
	@echo "Version: $(YOUGRABBER_VERSION)-$(YOUGRABBER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(YOUGRABBER_MAINTAINER)" >>$@
	@echo "Source: $(YOUGRABBER_SITE)/$(YOUGRABBER_SOURCE)" >>$@
	@echo "Description: $(YOUGRABBER_DESCRIPTION)" >>$@
	@echo "Depends: $(YOUGRABBER_DEPENDS)" >>$@
	@echo "Suggests: $(YOUGRABBER_SUGGESTS)" >>$@
	@echo "Conflicts: $(YOUGRABBER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(YOUGRABBER_IPK_DIR)/opt/sbin or $(YOUGRABBER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(YOUGRABBER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(YOUGRABBER_IPK_DIR)/opt/etc/yougrabber/...
# Documentation files should be installed in $(YOUGRABBER_IPK_DIR)/opt/doc/yougrabber/...
# Daemon startup scripts should be installed in $(YOUGRABBER_IPK_DIR)/opt/etc/init.d/S??yougrabber
#
# You may need to patch your application to make it use these locations.
#
$(YOUGRABBER_IPK): $(YOUGRABBER_BUILD_DIR)/.built
	rm -rf $(YOUGRABBER_IPK_DIR) $(BUILD_DIR)/yougrabber_*_$(TARGET_ARCH).ipk
	install -d $(YOUGRABBER_IPK_DIR)/opt/bin
	$(MAKE) -C $(YOUGRABBER_BUILD_DIR)/src install \
		PREFIX=$(YOUGRABBER_IPK_DIR)/opt \
		COPY=install
	$(STRIP_COMMAND) $(YOUGRABBER_IPK_DIR)/opt/bin/yg
	install -d $(YOUGRABBER_IPK_DIR)/opt/share/doc/yougrabber
	install $(YOUGRABBER_BUILD_DIR)/CHANGELOG \
		$(YOUGRABBER_BUILD_DIR)/CONTRIBUTORS \
		$(YOUGRABBER_BUILD_DIR)/INSTALL \
		$(YOUGRABBER_BUILD_DIR)/LICENSE \
		$(YOUGRABBER_BUILD_DIR)/README \
		$(YOUGRABBER_BUILD_DIR)/yg.conf.example \
		$(YOUGRABBER_IPK_DIR)/opt/share/doc/yougrabber
	$(MAKE) $(YOUGRABBER_IPK_DIR)/CONTROL/control
	echo $(YOUGRABBER_CONFFILES) | sed -e 's/ /\n/g' > $(YOUGRABBER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(YOUGRABBER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
yougrabber-ipk: $(YOUGRABBER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
yougrabber-clean:
	rm -f $(YOUGRABBER_BUILD_DIR)/.built
	-$(MAKE) -C $(YOUGRABBER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
yougrabber-dirclean:
	rm -rf $(BUILD_DIR)/$(YOUGRABBER_DIR) $(YOUGRABBER_BUILD_DIR) $(YOUGRABBER_IPK_DIR) $(YOUGRABBER_IPK)
#
#
# Some sanity check for the package.
#
yougrabber-check: $(YOUGRABBER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(YOUGRABBER_IPK)
