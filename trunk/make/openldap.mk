###########################################################
#
# openldap
#
###########################################################

# You must replace "openldap" and "OPENLDAP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# OPENLDAP_VERSION, OPENLDAP_SITE and OPENLDAP_SOURCE define
# the upstream location of the source code for the package.
# OPENLDAP_DIR is the directory which is created when the source
# archive is unpacked.
# OPENLDAP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
OPENLDAP_SITE=ftp://ftp.openldap.org/pub/openldap/openldap-stable/
OPENLDAP_VERSION=2.2.23
OPENLDAP_SOURCE=openldap-stable-20050125.tgz
OPENLDAP_DIR=openldap-$(OPENLDAP_VERSION)
OPENLDAP_UNZIP=zcat

#
# OPENLDAP_IPK_VERSION should be incremented when the ipk changes.
#
OPENLDAP_IPK_VERSION=1

#
# OPENLDAP_CONFFILES should be a list of user-editable files
#OPENLDAP_CONFFILES=/opt/etc/openldap.conf /opt/etc/init.d/SXXopenldap

#
# OPENLDAP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
OPENLDAP_PATCHES=$(OPENLDAP_SOURCE_DIR)/hostcc.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OPENLDAP_CPPFLAGS=
OPENLDAP_LDFLAGS=

#
# OPENLDAP_BUILD_DIR is the directory in which the build is done.
# OPENLDAP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OPENLDAP_IPK_DIR is the directory in which the ipk is built.
# OPENLDAP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OPENLDAP_BUILD_DIR=$(BUILD_DIR)/openldap
OPENLDAP_SOURCE_DIR=$(SOURCE_DIR)/openldap
OPENLDAP_IPK_DIR=$(BUILD_DIR)/openldap-$(OPENLDAP_VERSION)-ipk
OPENLDAP_IPK=$(BUILD_DIR)/openldap_$(OPENLDAP_VERSION)-$(OPENLDAP_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OPENLDAP_SOURCE):
	$(WGET) -P $(DL_DIR) $(OPENLDAP_SITE)/$(OPENLDAP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
openldap-source: $(DL_DIR)/$(OPENLDAP_SOURCE) $(OPENLDAP_PATCHES)

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
$(OPENLDAP_BUILD_DIR)/.configured: $(DL_DIR)/$(OPENLDAP_SOURCE) $(OPENLDAP_PATCHES)
	$(MAKE) libdb-stage openssl-stage gdbm-stage cyrus-sasl-stage
	rm -rf $(BUILD_DIR)/$(OPENLDAP_DIR) $(OPENLDAP_BUILD_DIR)
	$(OPENLDAP_UNZIP) $(DL_DIR)/$(OPENLDAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(OPENLDAP_PATCHES) | patch -d $(BUILD_DIR)/$(OPENLDAP_DIR) -p1
	mv $(BUILD_DIR)/$(OPENLDAP_DIR) $(OPENLDAP_BUILD_DIR)
	(cd $(OPENLDAP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OPENLDAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OPENLDAP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-yielding-select=yes \
		--disable-nls \
	)
	touch $(OPENLDAP_BUILD_DIR)/.configured

openldap-unpack: $(OPENLDAP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OPENLDAP_BUILD_DIR)/.built: $(OPENLDAP_BUILD_DIR)/.configured
	rm -f $(OPENLDAP_BUILD_DIR)/.built
	$(MAKE) -C $(OPENLDAP_BUILD_DIR) HOSTCC=$(HOSTCC)
	touch $(OPENLDAP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
openldap: $(OPENLDAP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OPENLDAP_BUILD_DIR)/.staged: $(OPENLDAP_BUILD_DIR)/.built
	rm -f $(OPENLDAP_BUILD_DIR)/.staged
	$(MAKE) -C $(OPENLDAP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(OPENLDAP_BUILD_DIR)/.staged

openldap-stage: $(OPENLDAP_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(OPENLDAP_IPK_DIR)/opt/sbin or $(OPENLDAP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OPENLDAP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OPENLDAP_IPK_DIR)/opt/etc/openldap/...
# Documentation files should be installed in $(OPENLDAP_IPK_DIR)/opt/doc/openldap/...
# Daemon startup scripts should be installed in $(OPENLDAP_IPK_DIR)/opt/etc/init.d/S??openldap
#
# You may need to patch your application to make it use these locations.
#
$(OPENLDAP_IPK): $(OPENLDAP_BUILD_DIR)/.built
	rm -rf $(OPENLDAP_IPK_DIR) $(BUILD_DIR)/openldap_*_armeb.ipk
	$(MAKE) -C $(OPENLDAP_BUILD_DIR) DESTDIR=$(OPENLDAP_IPK_DIR) install
	install -d $(OPENLDAP_IPK_DIR)/opt/etc/
#	install -m 755 $(OPENLDAP_SOURCE_DIR)/openldap.conf $(OPENLDAP_IPK_DIR)/opt/etc/openldap.conf
	install -d $(OPENLDAP_IPK_DIR)/opt/etc/init.d
	install -m 755 $(OPENLDAP_SOURCE_DIR)/rc.openldap $(OPENLDAP_IPK_DIR)/opt/etc/init.d/S58slapd
	install -d $(OPENLDAP_IPK_DIR)/CONTROL
	install -m 644 $(OPENLDAP_SOURCE_DIR)/control $(OPENLDAP_IPK_DIR)/CONTROL/control
	install -m 644 $(OPENLDAP_SOURCE_DIR)/postinst $(OPENLDAP_IPK_DIR)/CONTROL/postinst
	install -m 644 $(OPENLDAP_SOURCE_DIR)/prerm $(OPENLDAP_IPK_DIR)/CONTROL/prerm
	echo $(OPENLDAP_CONFFILES) | sed -e 's/ /\n/g' > $(OPENLDAP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENLDAP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
openldap-ipk: $(OPENLDAP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
openldap-clean:
	-$(MAKE) -C $(OPENLDAP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
openldap-dirclean:
	rm -rf $(BUILD_DIR)/$(OPENLDAP_DIR) $(OPENLDAP_BUILD_DIR) $(OPENLDAP_IPK_DIR) $(OPENLDAP_IPK)
