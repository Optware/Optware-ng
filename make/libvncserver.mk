###########################################################
#
# libvncserver
#
###########################################################
#
# LIBVNCSERVER_VERSION, LIBVNCSERVER_SITE and LIBVNCSERVER_SOURCE define
# the upstream location of the source code for the package.
# LIBVNCSERVER_DIR is the directory which is created when the source
# archive is unpacked.
# LIBVNCSERVER_UNZIP is the command used to unzip the source.
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
LIBVNCSERVER_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libvncserver
LIBVNCSERVER_VERSION=0.9.1
LIBVNCSERVER_SOURCE=LibVNCServer-$(LIBVNCSERVER_VERSION).tar.gz
LIBVNCSERVER_DIR=LibVNCServer-$(LIBVNCSERVER_VERSION)
LIBVNCSERVER_UNZIP=zcat
LIBVNCSERVER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBVNCSERVER_DESCRIPTION=LibVNCServer is a library that makes it easy to make a VNC server.
LIBVNCSERVER_SECTION=lib
LIBVNCSERVER_PRIORITY=optional
LIBVNCSERVER_DEPENDS=libjpeg, zlib
LIBVNCSERVER_SUGGESTS=
LIBVNCSERVER_CONFLICTS=

#
# LIBVNCSERVER_IPK_VERSION should be incremented when the ipk changes.
#
LIBVNCSERVER_IPK_VERSION=1

#
# LIBVNCSERVER_CONFFILES should be a list of user-editable files
#LIBVNCSERVER_CONFFILES=/opt/etc/libvncserver.conf /opt/etc/init.d/SXXlibvncserver

#
# LIBVNCSERVER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBVNCSERVER_PATCHES=$(LIBVNCSERVER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBVNCSERVER_CPPFLAGS=
LIBVNCSERVER_LDFLAGS=

#
# LIBVNCSERVER_BUILD_DIR is the directory in which the build is done.
# LIBVNCSERVER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBVNCSERVER_IPK_DIR is the directory in which the ipk is built.
# LIBVNCSERVER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBVNCSERVER_BUILD_DIR=$(BUILD_DIR)/libvncserver
LIBVNCSERVER_SOURCE_DIR=$(SOURCE_DIR)/libvncserver
LIBVNCSERVER_IPK_DIR=$(BUILD_DIR)/libvncserver-$(LIBVNCSERVER_VERSION)-ipk
LIBVNCSERVER_IPK=$(BUILD_DIR)/libvncserver_$(LIBVNCSERVER_VERSION)-$(LIBVNCSERVER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libvncserver-source libvncserver-unpack libvncserver libvncserver-stage libvncserver-ipk libvncserver-clean libvncserver-dirclean libvncserver-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBVNCSERVER_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBVNCSERVER_SITE)/$(LIBVNCSERVER_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBVNCSERVER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libvncserver-source: $(DL_DIR)/$(LIBVNCSERVER_SOURCE) $(LIBVNCSERVER_PATCHES)

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
$(LIBVNCSERVER_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBVNCSERVER_SOURCE) $(LIBVNCSERVER_PATCHES) make/libvncserver.mk
	$(MAKE) libjpeg-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(LIBVNCSERVER_DIR) $(@D)
	$(LIBVNCSERVER_UNZIP) $(DL_DIR)/$(LIBVNCSERVER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBVNCSERVER_PATCHES)" ; \
		then cat $(LIBVNCSERVER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBVNCSERVER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBVNCSERVER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBVNCSERVER_DIR) $(@D) ; \
	fi
	sed -i -e '/SUBDIRS/s| client_examples test||' $(@D)/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBVNCSERVER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBVNCSERVER_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--without-x \
		--without-avahi \
		--without-v4l \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libvncserver-unpack: $(LIBVNCSERVER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBVNCSERVER_BUILD_DIR)/.built: $(LIBVNCSERVER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libvncserver: $(LIBVNCSERVER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBVNCSERVER_BUILD_DIR)/.staged: $(LIBVNCSERVER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/*.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_PREFIX)/bin/libvncserver-config
	touch $@

libvncserver-stage: $(LIBVNCSERVER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libvncserver
#
$(LIBVNCSERVER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libvncserver" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBVNCSERVER_PRIORITY)" >>$@
	@echo "Section: $(LIBVNCSERVER_SECTION)" >>$@
	@echo "Version: $(LIBVNCSERVER_VERSION)-$(LIBVNCSERVER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBVNCSERVER_MAINTAINER)" >>$@
	@echo "Source: $(LIBVNCSERVER_SITE)/$(LIBVNCSERVER_SOURCE)" >>$@
	@echo "Description: $(LIBVNCSERVER_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBVNCSERVER_DEPENDS)" >>$@
	@echo "Suggests: $(LIBVNCSERVER_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBVNCSERVER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBVNCSERVER_IPK_DIR)/opt/sbin or $(LIBVNCSERVER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBVNCSERVER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBVNCSERVER_IPK_DIR)/opt/etc/libvncserver/...
# Documentation files should be installed in $(LIBVNCSERVER_IPK_DIR)/opt/doc/libvncserver/...
# Daemon startup scripts should be installed in $(LIBVNCSERVER_IPK_DIR)/opt/etc/init.d/S??libvncserver
#
# You may need to patch your application to make it use these locations.
#
$(LIBVNCSERVER_IPK): $(LIBVNCSERVER_BUILD_DIR)/.built
	rm -rf $(LIBVNCSERVER_IPK_DIR) $(BUILD_DIR)/libvncserver_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBVNCSERVER_BUILD_DIR) DESTDIR=$(LIBVNCSERVER_IPK_DIR) install-strip
	rm -f $(LIBVNCSERVER_IPK_DIR)/opt/lib/*.la
	install -d $(LIBVNCSERVER_IPK_DIR)/opt/share/libvncserver/examples
	cd $(LIBVNCSERVER_BUILD_DIR)/examples/.libs/; \
	for f in *; do \
		$(STRIP_COMMAND) $$f -o $(LIBVNCSERVER_IPK_DIR)/opt/share/libvncserver/examples/$$f; \
	done
	$(MAKE) $(LIBVNCSERVER_IPK_DIR)/CONTROL/control
	echo $(LIBVNCSERVER_CONFFILES) | sed -e 's/ /\n/g' > $(LIBVNCSERVER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBVNCSERVER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libvncserver-ipk: $(LIBVNCSERVER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libvncserver-clean:
	rm -f $(LIBVNCSERVER_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBVNCSERVER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libvncserver-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBVNCSERVER_DIR) $(LIBVNCSERVER_BUILD_DIR) $(LIBVNCSERVER_IPK_DIR) $(LIBVNCSERVER_IPK)
#
#
# Some sanity check for the package.
#
libvncserver-check: $(LIBVNCSERVER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBVNCSERVER_IPK)
