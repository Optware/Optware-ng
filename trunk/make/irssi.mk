###########################################################
#
# irssi
#
###########################################################

#
# IRSSI_VERSION, IRSSI_SITE and IRSSI_SOURCE define
# the upstream location of the source code for the package.
# IRSSI_DIR is the directory which is created when the source
# archive is unpacked.
# IRSSI_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
IRSSI_SITE=http://irssi.org/
IRSSI_VERSION=20050206
IRSSI_SOURCE=irssi-$(IRSSI_VERSION).tar.gz
IRSSI_DIR=irssi-$(IRSSI_VERSION)
IRSSI_UNZIP=zcat
IRSSI_REPOSITORY=:pserver:anonymous@cvs.irssi.org:/home/cvs
IRSSI_TAG="-D 2005-02-06"
IRSSI_MODULE=irssi

#
# IRSSI_IPK_VERSION should be incremented when the ipk changes.
#
IRSSI_IPK_VERSION=1

#
# IRSSI_CONFFILES should be a list of user-editable files
#IRSSI_CONFFILES=/opt/etc/irssi.conf /opt/etc/init.d/SXXirssi

#
# IRSSI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#IRSSI_PATCHES=$(IRSSI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IRSSI_CPPFLAGS=
IRSSI_LDFLAGS=

#
# IRSSI_BUILD_DIR is the directory in which the build is done.
# IRSSI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IRSSI_IPK_DIR is the directory in which the ipk is built.
# IRSSI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IRSSI_BUILD_DIR=$(BUILD_DIR)/irssi
IRSSI_SOURCE_DIR=$(SOURCE_DIR)/irssi
IRSSI_IPK_DIR=$(BUILD_DIR)/irssi-$(IRSSI_VERSION)-ipk
IRSSI_IPK=$(BUILD_DIR)/irssi_$(IRSSI_VERSION)-$(IRSSI_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IRSSI_SOURCE):
	cd $(DL_DIR) ; $(CVS) -d $(IRSSI_REPOSITORY) co $(IRSSI_TAG) $(IRSSI_MODULE)
	mv $(DL_DIR)/$(IRSSI_MODULE) $(DL_DIR)/$(IRSSI_DIR)
	cd $(DL_DIR) ; tar zcvf $(IRSSI_SOURCE) $(IRSSI_DIR)
	rm -rf $(DL_DIR)/$(IRSSI_DIR)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
irssi-source: $(DL_DIR)/$(IRSSI_SOURCE) $(IRSSI_PATCHES)

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
$(IRSSI_BUILD_DIR)/.configured: $(DL_DIR)/$(IRSSI_SOURCE) $(IRSSI_PATCHES)
	$(MAKE) glib-stage ncurses-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(IRSSI_DIR) $(IRSSI_BUILD_DIR)
	$(IRSSI_UNZIP) $(DL_DIR)/$(IRSSI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(IRSSI_PATCHES) | patch -d $(BUILD_DIR)/$(IRSSI_DIR) -p1
	mv $(BUILD_DIR)/$(IRSSI_DIR) $(IRSSI_BUILD_DIR)
	(cd $(IRSSI_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IRSSI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IRSSI_LDFLAGS)" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-perl \
		--with-ncurses=/opt \
		--enable-ipv6 \
	)
	touch $(IRSSI_BUILD_DIR)/.configured

irssi-unpack: $(IRSSI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IRSSI_BUILD_DIR)/.built: $(IRSSI_BUILD_DIR)/.configured
	rm -f $(IRSSI_BUILD_DIR)/.built
	$(MAKE) -C $(IRSSI_BUILD_DIR)
	touch $(IRSSI_BUILD_DIR)/.built

#
# This is the build convenience target.
#
irssi: $(IRSSI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(IRSSI_BUILD_DIR)/.staged: $(IRSSI_BUILD_DIR)/.built
	rm -f $(IRSSI_BUILD_DIR)/.staged
	$(MAKE) -C $(IRSSI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(IRSSI_BUILD_DIR)/.staged

irssi-stage: $(IRSSI_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(IRSSI_IPK_DIR)/opt/sbin or $(IRSSI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IRSSI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IRSSI_IPK_DIR)/opt/etc/irssi/...
# Documentation files should be installed in $(IRSSI_IPK_DIR)/opt/doc/irssi/...
# Daemon startup scripts should be installed in $(IRSSI_IPK_DIR)/opt/etc/init.d/S??irssi
#
# You may need to patch your application to make it use these locations.
#
$(IRSSI_IPK): $(IRSSI_BUILD_DIR)/.built
	rm -rf $(IRSSI_IPK_DIR) $(BUILD_DIR)/irssi_*_armeb.ipk
	$(MAKE) -C $(IRSSI_BUILD_DIR) DESTDIR=$(IRSSI_IPK_DIR) install-strip
#	install -d $(IRSSI_IPK_DIR)/opt/etc/
#	install -m 644 $(IRSSI_SOURCE_DIR)/irssi.conf $(IRSSI_IPK_DIR)/opt/etc/irssi.conf
#	install -d $(IRSSI_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(IRSSI_SOURCE_DIR)/rc.irssi $(IRSSI_IPK_DIR)/opt/etc/init.d/SXXirssi
	install -d $(IRSSI_IPK_DIR)/CONTROL
	install -m 644 $(IRSSI_SOURCE_DIR)/control $(IRSSI_IPK_DIR)/CONTROL/control
#	install -m 644 $(IRSSI_SOURCE_DIR)/postinst $(IRSSI_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(IRSSI_SOURCE_DIR)/prerm $(IRSSI_IPK_DIR)/CONTROL/prerm
#	echo $(IRSSI_CONFFILES) | sed -e 's/ /\n/g' > $(IRSSI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IRSSI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
irssi-ipk: $(IRSSI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
irssi-clean:
	-$(MAKE) -C $(IRSSI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
irssi-dirclean:
	rm -rf $(BUILD_DIR)/$(IRSSI_DIR) $(IRSSI_BUILD_DIR) $(IRSSI_IPK_DIR) $(IRSSI_IPK)
