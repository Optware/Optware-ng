###########################################################
#
# autoconf
#
###########################################################

# You must replace "autoconf" and "AUTOCONF" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# AUTOCONF_VERSION, AUTOCONF_SITE and AUTOCONF_SOURCE define
# the upstream location of the source code for the package.
# AUTOCONF_DIR is the directory which is created when the source
# archive is unpacked.
# AUTOCONF_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
AUTOCONF_SITE=http://ftp.gnu.org/gnu/autoconf
AUTOCONF_VERSION=2.59
AUTOCONF_SOURCE=autoconf-$(AUTOCONF_VERSION).tar.bz2
AUTOCONF_DIR=autoconf-$(AUTOCONF_VERSION)
AUTOCONF_UNZIP=bzcat

#
# AUTOCONF_IPK_VERSION should be incremented when the ipk changes.
#
AUTOCONF_IPK_VERSION=1

#
# AUTOCONF_CONFFILES should be a list of user-editable files
#AUTOCONF_CONFFILES=

#
# AUTOCONF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#AUTOCONF_PATCHES=$(AUTOCONF_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
AUTOCONF_CPPFLAGS=
AUTOCONF_LDFLAGS=

#
# AUTOCONF_BUILD_DIR is the directory in which the build is done.
# AUTOCONF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# AUTOCONF_IPK_DIR is the directory in which the ipk is built.
# AUTOCONF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
AUTOCONF_BUILD_DIR=$(BUILD_DIR)/autoconf
AUTOCONF_SOURCE_DIR=$(SOURCE_DIR)/autoconf
AUTOCONF_IPK_DIR=$(BUILD_DIR)/autoconf-$(AUTOCONF_VERSION)-ipk
AUTOCONF_IPK=$(BUILD_DIR)/autoconf_$(AUTOCONF_VERSION)-$(AUTOCONF_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(AUTOCONF_SOURCE):
	$(WGET) -P $(DL_DIR) $(AUTOCONF_SITE)/$(AUTOCONF_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
autoconf-source: $(DL_DIR)/$(AUTOCONF_SOURCE) $(AUTOCONF_PATCHES)

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
$(AUTOCONF_BUILD_DIR)/.configured: $(DL_DIR)/$(AUTOCONF_SOURCE) $(AUTOCONF_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(AUTOCONF_DIR) $(AUTOCONF_BUILD_DIR)
	$(AUTOCONF_UNZIP) $(DL_DIR)/$(AUTOCONF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(AUTOCONF_PATCHES) | patch -d $(BUILD_DIR)/$(AUTOCONF_DIR) -p1
	mv $(BUILD_DIR)/$(AUTOCONF_DIR) $(AUTOCONF_BUILD_DIR)
	(cd $(AUTOCONF_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AUTOCONF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AUTOCONF_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(AUTOCONF_BUILD_DIR)/.configured

autoconf-unpack: $(AUTOCONF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(AUTOCONF_BUILD_DIR)/.built: $(AUTOCONF_BUILD_DIR)/.configured
	rm -f $(AUTOCONF_BUILD_DIR)/.built
	$(MAKE) -C $(AUTOCONF_BUILD_DIR)
	touch $(AUTOCONF_BUILD_DIR)/.built

#
# This is the build convenience target.
#
autoconf: $(AUTOCONF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libautoconf.so.$(AUTOCONF_VERSION): $(AUTOCONF_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(AUTOCONF_BUILD_DIR)/autoconf.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(AUTOCONF_BUILD_DIR)/libautoconf.a $(STAGING_DIR)/opt/lib
	install -m 644 $(AUTOCONF_BUILD_DIR)/libautoconf.so.$(AUTOCONF_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libautoconf.so.$(AUTOCONF_VERSION) libautoconf.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libautoconf.so.$(AUTOCONF_VERSION) libautoconf.so

autoconf-stage: $(STAGING_DIR)/opt/lib/libautoconf.so.$(AUTOCONF_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(AUTOCONF_IPK_DIR)/opt/sbin or $(AUTOCONF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(AUTOCONF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(AUTOCONF_IPK_DIR)/opt/etc/autoconf/...
# Documentation files should be installed in $(AUTOCONF_IPK_DIR)/opt/doc/autoconf/...
# Daemon startup scripts should be installed in $(AUTOCONF_IPK_DIR)/opt/etc/init.d/S??autoconf
#
# You may need to patch your application to make it use these locations.
#
$(AUTOCONF_IPK): $(AUTOCONF_BUILD_DIR)/.built
	rm -rf $(AUTOCONF_IPK_DIR) $(BUILD_DIR)/autoconf_*_$(TARGET_ARCH).ipk
	install -d $(AUTOCONF_IPK_DIR)/opt/bin
	install -d $(AUTOCONF_IPK_DIR)/opt/info
	install -d $(AUTOCONF_IPK_DIR)/opt/man/man1
	install -d $(AUTOCONF_IPK_DIR)/opt/share/autoconf/Autom4te
	install -d $(AUTOCONF_IPK_DIR)/opt/share/autoconf/autoconf
	install -d $(AUTOCONF_IPK_DIR)/opt/share/autoconf/autoscan
	install -d $(AUTOCONF_IPK_DIR)/opt/share/autoconf/autotest
	install -d $(AUTOCONF_IPK_DIR)/opt/share/autoconf/m4sugar
	$(MAKE) -C $(AUTOCONF_BUILD_DIR) DESTDIR=$(AUTOCONF_IPK_DIR) install
	install -d $(AUTOCONF_IPK_DIR)/CONTROL
	install -m 644 $(AUTOCONF_SOURCE_DIR)/control $(AUTOCONF_IPK_DIR)/CONTROL/control
#	install -m 644 $(AUTOCONF_SOURCE_DIR)/postinst $(AUTOCONF_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(AUTOCONF_SOURCE_DIR)/prerm $(AUTOCONF_IPK_DIR)/CONTROL/prerm
#	echo $(AUTOCONF_CONFFILES) | sed -e 's/ /\n/g' > $(AUTOCONF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AUTOCONF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
autoconf-ipk: $(AUTOCONF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
autoconf-clean:
	-$(MAKE) -C $(AUTOCONF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
autoconf-dirclean:
	rm -rf $(BUILD_DIR)/$(AUTOCONF_DIR) $(AUTOCONF_BUILD_DIR) $(AUTOCONF_IPK_DIR) $(AUTOCONF_IPK)
