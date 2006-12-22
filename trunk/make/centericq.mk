###########################################################
#
# centericq
#
###########################################################

# You must replace "centericq" and "CENTERICQ" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# CENTERICQ_VERSION, CENTERICQ_SITE and CENTERICQ_SOURCE define
# the upstream location of the source code for the package.
# CENTERICQ_DIR is the directory which is created when the source
# archive is unpacked.
# CENTERICQ_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
CENTERICQ_SITE=http://konst.org.ua/download
CENTERICQ_VERSION=4.20.0
CENTERICQ_SOURCE=centericq-$(CENTERICQ_VERSION).tar.gz
CENTERICQ_DIR=centericq-$(CENTERICQ_VERSION)
CENTERICQ_UNZIP=zcat

#
# CENTERICQ_IPK_VERSION should be incremented when the ipk changes.
#
CENTERICQ_IPK_VERSION=2

#
# CENTERICQ_CONFFILES should be a list of user-editable files
CENTERICQ_CONFFILES=
#/opt/etc/centericq.conf /opt/etc/init.d/SXXcentericq

#
# CENTERICQ_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CENTERICQ_PATCHES=$(CENTERICQ_SOURCE_DIR)/Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CENTERICQ_CPPFLAGS=
CENTERICQ_LDFLAGS=

#
# CENTERICQ_BUILD_DIR is the directory in which the build is done.
# CENTERICQ_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CENTERICQ_IPK_DIR is the directory in which the ipk is built.
# CENTERICQ_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CENTERICQ_BUILD_DIR=$(BUILD_DIR)/centericq
CENTERICQ_SOURCE_DIR=$(SOURCE_DIR)/centericq
CENTERICQ_IPK_DIR=$(BUILD_DIR)/centericq-$(CENTERICQ_VERSION)-ipk
CENTERICQ_IPK=$(BUILD_DIR)/centericq_$(CENTERICQ_VERSION)-$(CENTERICQ_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CENTERICQ_SOURCE):
	$(WGET) -P $(DL_DIR) $(CENTERICQ_SITE)/$(CENTERICQ_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
centericq-source: $(DL_DIR)/$(CENTERICQ_SOURCE) $(CENTERICQ_PATCHES)

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
$(CENTERICQ_BUILD_DIR)/.configured: $(DL_DIR)/$(CENTERICQ_SOURCE) $(CENTERICQ_PATCHES)
	$(MAKE) ncurses-stage openssl-stage libcurl-stage libstdc++-stage
	rm -rf $(BUILD_DIR)/$(CENTERICQ_DIR) $(CENTERICQ_BUILD_DIR)
	$(CENTERICQ_UNZIP) $(DL_DIR)/$(CENTERICQ_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(CENTERICQ_PATCHES) | patch -d $(BUILD_DIR)/$(CENTERICQ_DIR) -p1
	mv $(BUILD_DIR)/$(CENTERICQ_DIR) $(CENTERICQ_BUILD_DIR)
	(cd $(CENTERICQ_BUILD_DIR); \
		sh -x $(CENTERICQ_SOURCE_DIR)/Makefile.in.sh ; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CENTERICQ_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CENTERICQ_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--with-openssl=$(STAGING_DIR)/opt \
		--without-gpgme \
		--disable-gg \
		--with-curl=$(STAGING_DIR)/bin/curl-config \
	)
	touch $(CENTERICQ_BUILD_DIR)/.configured

centericq-unpack: $(CENTERICQ_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CENTERICQ_BUILD_DIR)/.built: $(CENTERICQ_BUILD_DIR)/.configured
	rm -f $(CENTERICQ_BUILD_DIR)/.built
	$(MAKE) -C $(CENTERICQ_BUILD_DIR)
	touch $(CENTERICQ_BUILD_DIR)/.built

#
# This is the build convenience target.
#
centericq: $(CENTERICQ_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CENTERICQ_BUILD_DIR)/.staged: $(CENTERICQ_BUILD_DIR)/.built
	rm -f $(CENTERICQ_BUILD_DIR)/.staged
	$(MAKE) -C $(CENTERICQ_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CENTERICQ_BUILD_DIR)/.staged

centericq-stage: $(CENTERICQ_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(CENTERICQ_IPK_DIR)/opt/sbin or $(CENTERICQ_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CENTERICQ_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CENTERICQ_IPK_DIR)/opt/etc/centericq/...
# Documentation files should be installed in $(CENTERICQ_IPK_DIR)/opt/doc/centericq/...
# Daemon startup scripts should be installed in $(CENTERICQ_IPK_DIR)/opt/etc/init.d/S??centericq
#
# You may need to patch your application to make it use these locations.
#
$(CENTERICQ_IPK): $(CENTERICQ_BUILD_DIR)/.built
	rm -rf $(CENTERICQ_IPK_DIR) $(BUILD_DIR)/centericq_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CENTERICQ_BUILD_DIR) DESTDIR=$(CENTERICQ_IPK_DIR) install
	# Strip the executables
	$(STRIP_COMMAND) $(CENTERICQ_IPK_DIR)/opt/bin/centericq
#	install -d $(CENTERICQ_IPK_DIR)/opt/etc/
#	install -m 644 $(CENTERICQ_SOURCE_DIR)/centericq.conf $(CENTERICQ_IPK_DIR)/opt/etc/centericq.conf
#	install -d $(CENTERICQ_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CENTERICQ_SOURCE_DIR)/rc.centericq $(CENTERICQ_IPK_DIR)/opt/etc/init.d/SXXcentericq
	install -d $(CENTERICQ_IPK_DIR)/CONTROL
	install -m 644 $(CENTERICQ_SOURCE_DIR)/control $(CENTERICQ_IPK_DIR)/CONTROL/control
#	install -m 755 $(CENTERICQ_SOURCE_DIR)/postinst $(CENTERICQ_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CENTERICQ_SOURCE_DIR)/prerm $(CENTERICQ_IPK_DIR)/CONTROL/prerm
#	echo $(CENTERICQ_CONFFILES) | sed -e 's/ /\n/g' > $(CENTERICQ_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CENTERICQ_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
centericq-ipk: $(CENTERICQ_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
centericq-clean:
	-$(MAKE) -C $(CENTERICQ_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
centericq-dirclean:
	rm -rf $(BUILD_DIR)/$(CENTERICQ_DIR) $(CENTERICQ_BUILD_DIR) $(CENTERICQ_IPK_DIR) $(CENTERICQ_IPK)
