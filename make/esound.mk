###########################################################
#
# esound
#
###########################################################

# You must replace "esound" and "ESOUND" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ESOUND_VERSION, ESOUND_SITE and ESOUND_SOURCE define
# the upstream location of the source code for the package.
# ESOUND_DIR is the directory which is created when the source
# archive is unpacked.
# ESOUND_UNZIP is the command used to unzip the source.
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
ESOUND_SITE=ftp://ftp.gnome.org/pub/GNOME/sources/esound/0.2
ESOUND_VERSION=0.2.38
ESOUND_SOURCE=esound-$(ESOUND_VERSION).tar.gz
ESOUND_DIR=esound-$(ESOUND_VERSION)
ESOUND_UNZIP=zcat
ESOUND_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ESOUND_DESCRIPTION=The Enlighted Sound Daemon.
ESOUND_SECTION=misc
ESOUND_PRIORITY=optional
ESOUND_DEPENDS=audiofile
ESOUND_CONFLICTS=

#
# ESOUND_IPK_VERSION should be incremented when the ipk changes.
#
ESOUND_IPK_VERSION=1

#
# ESOUND_CONFFILES should be a list of user-editable files
ESOUND_CONFFILES=#/opt/etc/esound.conf /opt/etc/init.d/SXXesound

#
# ESOUND_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ESOUND_PATCHES=#$(ESOUND_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ESOUND_CPPFLAGS=
ifeq ($(OPTWARE_TARGET), ts101)
ESOUND_CPPFLAGS+= -fno-builtin-cos -fno-builtin-sin
endif
ESOUND_LDFLAGS=

ifeq (no,$(IPV6))
ESOUND_CONFIGURE_OPTIONS+=--disable-ipv6
else
ESOUND_CONFIGURE_OPTIONS+=--enable-ipv6
endif

#
# ESOUND_BUILD_DIR is the directory in which the build is done.
# ESOUND_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ESOUND_IPK_DIR is the directory in which the ipk is built.
# ESOUND_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ESOUND_BUILD_DIR=$(BUILD_DIR)/esound
ESOUND_SOURCE_DIR=$(SOURCE_DIR)/esound
ESOUND_IPK_DIR=$(BUILD_DIR)/esound-$(ESOUND_VERSION)-ipk
ESOUND_IPK=$(BUILD_DIR)/esound_$(ESOUND_VERSION)-$(ESOUND_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ESOUND_SOURCE):
	$(WGET) -P $(DL_DIR) $(ESOUND_SITE)/$(ESOUND_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
esound-source: $(DL_DIR)/$(ESOUND_SOURCE) $(ESOUND_PATCHES)

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
$(ESOUND_BUILD_DIR)/.configured: $(DL_DIR)/$(ESOUND_SOURCE) $(ESOUND_PATCHES)
	$(MAKE) audiofile-stage
	rm -rf $(BUILD_DIR)/$(ESOUND_DIR) $(ESOUND_BUILD_DIR)
	$(ESOUND_UNZIP) $(DL_DIR)/$(ESOUND_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(ESOUND_PATCHES) | patch -d $(BUILD_DIR)/$(ESOUND_DIR) -p1
	mv $(BUILD_DIR)/$(ESOUND_DIR) $(ESOUND_BUILD_DIR)
	ACLOCAL="aclocal-1.9 -I $(STAGING_DIR)/opt/share/aclocal" AUTOMAKE=automake-1.9 \
		autoreconf -vif $(ESOUND_BUILD_DIR)
	sed -ie 's/artsc-config --cflags |//' $(ESOUND_BUILD_DIR)/configure
	(cd $(ESOUND_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ESOUND_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ESOUND_LDFLAGS)" \
		PATH="$(STAGING_DIR)/bin:$(PATH)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_path_ARTS_CONFIG=$(STAGING_PREFIX)/bin/libart2-config \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(ESOUND_CONFIGURE_OPTIONS) \
		--with-audiofile-prefix=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-alsa \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(ESOUND_BUILD_DIR)/libtool
	touch $(ESOUND_BUILD_DIR)/.configured

esound-unpack: $(ESOUND_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ESOUND_BUILD_DIR)/.built: $(ESOUND_BUILD_DIR)/.configured
	rm -f $(ESOUND_BUILD_DIR)/.built
	$(MAKE) -C $(ESOUND_BUILD_DIR)
	touch $(ESOUND_BUILD_DIR)/.built

#
# This is the build convenience target.
#
esound: $(ESOUND_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ESOUND_BUILD_DIR)/.staged: $(ESOUND_BUILD_DIR)/.built
	rm -f $(ESOUND_BUILD_DIR)/.staged
	$(MAKE) -C $(ESOUND_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	cp $(STAGING_DIR)/opt/bin/esd-config $(STAGING_DIR)/bin/esd-config
	touch $(ESOUND_BUILD_DIR)/.staged

esound-stage: $(ESOUND_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/esound
#
$(ESOUND_IPK_DIR)/CONTROL/control:
	@install -d $(ESOUND_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: esound" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ESOUND_PRIORITY)" >>$@
	@echo "Section: $(ESOUND_SECTION)" >>$@
	@echo "Version: $(ESOUND_VERSION)-$(ESOUND_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ESOUND_MAINTAINER)" >>$@
	@echo "Source: $(ESOUND_SITE)/$(ESOUND_SOURCE)" >>$@
	@echo "Description: $(ESOUND_DESCRIPTION)" >>$@
	@echo "Depends: $(ESOUND_DEPENDS)" >>$@
	@echo "Conflicts: $(ESOUND_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ESOUND_IPK_DIR)/opt/sbin or $(ESOUND_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ESOUND_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ESOUND_IPK_DIR)/opt/etc/esound/...
# Documentation files should be installed in $(ESOUND_IPK_DIR)/opt/doc/esound/...
# Daemon startup scripts should be installed in $(ESOUND_IPK_DIR)/opt/etc/init.d/S??esound
#
# You may need to patch your application to make it use these locations.
#
$(ESOUND_IPK): $(ESOUND_BUILD_DIR)/.built
	rm -rf $(ESOUND_IPK_DIR) $(BUILD_DIR)/esound_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ESOUND_BUILD_DIR) DESTDIR=$(ESOUND_IPK_DIR) install-strip
	#install -d $(ESOUND_IPK_DIR)/opt/etc/
	#install -m 644 $(ESOUND_SOURCE_DIR)/esound.conf $(ESOUND_IPK_DIR)/opt/etc/esound.conf
	#install -d $(ESOUND_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(ESOUND_SOURCE_DIR)/rc.esound $(ESOUND_IPK_DIR)/opt/etc/init.d/SXXesound
	$(MAKE) $(ESOUND_IPK_DIR)/CONTROL/control
	#install -m 755 $(ESOUND_SOURCE_DIR)/postinst $(ESOUND_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(ESOUND_SOURCE_DIR)/prerm $(ESOUND_IPK_DIR)/CONTROL/prerm
	echo $(ESOUND_CONFFILES) | sed -e 's/ /\n/g' > $(ESOUND_IPK_DIR)/CONTROL/conffiles
	rm -f $(ESOUND_IPK_DIR)/opt/lib/libesd.la
	rm -f $(ESOUND_IPK_DIR)/opt/lib/libesddsp.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ESOUND_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
esound-ipk: $(ESOUND_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
esound-clean:
	-$(MAKE) -C $(ESOUND_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
esound-dirclean:
	rm -rf $(BUILD_DIR)/$(ESOUND_DIR) $(ESOUND_BUILD_DIR) $(ESOUND_IPK_DIR) $(ESOUND_IPK)

#
# Some sanity check for the package.
#
esound-check: $(ESOUND_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ESOUND_IPK)
