###########################################################
#
# automake
#
###########################################################

# You must replace "automake" and "AUTOMAKE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# AUTOMAKE_VERSION, AUTOMAKE_SITE and AUTOMAKE_SOURCE define
# the upstream location of the source code for the package.
# AUTOMAKE_DIR is the directory which is created when the source
# archive is unpacked.
# AUTOMAKE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
AUTOMAKE_SITE=http://ftp.gnu.org/gnu/automake
AUTOMAKE_VERSION=1.9.4
AUTOMAKE_SOURCE=automake-$(AUTOMAKE_VERSION).tar.bz2
AUTOMAKE_DIR=automake-$(AUTOMAKE_VERSION)
AUTOMAKE_UNZIP=bzcat

#
# AUTOMAKE_IPK_VERSION should be incremented when the ipk changes.
#
AUTOMAKE_IPK_VERSION=2

#
# AUTOMAKE_CONFFILES should be a list of user-editable files
#AUTOMAKE_CONFFILES=

#
# AUTOMAKE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#AUTOMAKE_PATCHES=$(AUTOMAKE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
AUTOMAKE_CPPFLAGS=
AUTOMAKE_LDFLAGS=

#
# AUTOMAKE_BUILD_DIR is the directory in which the build is done.
# AUTOMAKE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# AUTOMAKE_IPK_DIR is the directory in which the ipk is built.
# AUTOMAKE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
AUTOMAKE_BUILD_DIR=$(BUILD_DIR)/automake
AUTOMAKE_SOURCE_DIR=$(SOURCE_DIR)/automake
AUTOMAKE_IPK_DIR=$(BUILD_DIR)/automake-$(AUTOMAKE_VERSION)-ipk
AUTOMAKE_IPK=$(BUILD_DIR)/automake_$(AUTOMAKE_VERSION)-$(AUTOMAKE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(AUTOMAKE_SOURCE):
	$(WGET) -P $(DL_DIR) $(AUTOMAKE_SITE)/$(AUTOMAKE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
automake-source: $(DL_DIR)/$(AUTOMAKE_SOURCE) $(AUTOMAKE_PATCHES)

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
$(AUTOMAKE_BUILD_DIR)/.configured: $(DL_DIR)/$(AUTOMAKE_SOURCE) $(AUTOMAKE_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(AUTOMAKE_DIR) $(AUTOMAKE_BUILD_DIR)
	$(AUTOMAKE_UNZIP) $(DL_DIR)/$(AUTOMAKE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(AUTOMAKE_PATCHES) | patch -d $(BUILD_DIR)/$(AUTOMAKE_DIR) -p1
	mv $(BUILD_DIR)/$(AUTOMAKE_DIR) $(AUTOMAKE_BUILD_DIR)
	(cd $(AUTOMAKE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AUTOMAKE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AUTOMAKE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(AUTOMAKE_BUILD_DIR)/.configured

automake-unpack: $(AUTOMAKE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(AUTOMAKE_BUILD_DIR)/.built: $(AUTOMAKE_BUILD_DIR)/.configured
	rm -f $(AUTOMAKE_BUILD_DIR)/.built
	$(MAKE) -C $(AUTOMAKE_BUILD_DIR)
	touch $(AUTOMAKE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
automake: $(AUTOMAKE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libautomake.so.$(AUTOMAKE_VERSION): $(AUTOMAKE_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(AUTOMAKE_BUILD_DIR)/automake.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(AUTOMAKE_BUILD_DIR)/libautomake.a $(STAGING_DIR)/opt/lib
	install -m 644 $(AUTOMAKE_BUILD_DIR)/libautomake.so.$(AUTOMAKE_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libautomake.so.$(AUTOMAKE_VERSION) libautomake.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libautomake.so.$(AUTOMAKE_VERSION) libautomake.so

automake-stage: $(STAGING_DIR)/opt/lib/libautomake.so.$(AUTOMAKE_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(AUTOMAKE_IPK_DIR)/opt/sbin or $(AUTOMAKE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(AUTOMAKE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(AUTOMAKE_IPK_DIR)/opt/etc/automake/...
# Documentation files should be installed in $(AUTOMAKE_IPK_DIR)/opt/doc/automake/...
# Daemon startup scripts should be installed in $(AUTOMAKE_IPK_DIR)/opt/etc/init.d/S??automake
#
# You may need to patch your application to make it use these locations.
#
$(AUTOMAKE_IPK): $(AUTOMAKE_BUILD_DIR)/.built
	rm -rf $(AUTOMAKE_IPK_DIR) $(BUILD_DIR)/automake_*_$(TARGET_ARCH).ipk
	install -d $(AUTOMAKE_IPK_DIR)/opt/bin
	install -d $(AUTOMAKE_IPK_DIR)/opt/info
	install -d $(AUTOMAKE_IPK_DIR)/opt/share/aclocal-1.9
	install -d $(AUTOMAKE_IPK_DIR)/opt/share/automake-1.9/Automake
	install -d $(AUTOMAKE_IPK_DIR)/opt/share/automake-1.9/am
	$(MAKE) -C $(AUTOMAKE_BUILD_DIR) DESTDIR=$(AUTOMAKE_IPK_DIR) install
#	$(STRIP_COMMAND) $(AUTOMAKE_BUILD_DIR)/automake -o $(AUTOMAKE_IPK_DIR)/opt/bin/automake
#	install -d $(AUTOMAKE_IPK_DIR)/opt/etc/
#	install -m 755 $(AUTOMAKE_SOURCE_DIR)/automake.conf $(AUTOMAKE_IPK_DIR)/opt/etc/automake.conf
#	install -d $(AUTOMAKE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(AUTOMAKE_SOURCE_DIR)/rc.automake $(AUTOMAKE_IPK_DIR)/opt/etc/init.d/SXXautomake
	install -d $(AUTOMAKE_IPK_DIR)/CONTROL
	install -m 644 $(AUTOMAKE_SOURCE_DIR)/control $(AUTOMAKE_IPK_DIR)/CONTROL/control
#	install -m 644 $(AUTOMAKE_SOURCE_DIR)/postinst $(AUTOMAKE_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(AUTOMAKE_SOURCE_DIR)/prerm $(AUTOMAKE_IPK_DIR)/CONTROL/prerm
	echo $(AUTOMAKE_CONFFILES) | sed -e 's/ /\n/g' > $(AUTOMAKE_IPK_DIR)/CONTROL/conffiles
	rm -f $(AUTOMAKE_IPK_DIR)/opt/info/dir
	(cd $(AUTOMAKE_IPK_DIR)/opt/bin; \
		rm automake aclocal; \
		ln -s automake-1.9 automake; \
		ln -s aclocal-1.9 aclocal; \
	)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AUTOMAKE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
automake-ipk: $(AUTOMAKE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
automake-clean:
	-$(MAKE) -C $(AUTOMAKE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
automake-dirclean:
	rm -rf $(BUILD_DIR)/$(AUTOMAKE_DIR) $(AUTOMAKE_BUILD_DIR) $(AUTOMAKE_IPK_DIR) $(AUTOMAKE_IPK)
