###########################################################
#
# cyrus-sasl
#
###########################################################

# You must replace "cyrus-sasl" and "CYRUS-SASL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# CYRUS-SASL_VERSION, CYRUS-SASL_SITE and CYRUS-SASL_SOURCE define
# the upstream location of the source code for the package.
# CYRUS-SASL_DIR is the directory which is created when the source
# archive is unpacked.
# CYRUS-SASL_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
CYRUS-SASL_SITE=ftp://ftp.andrew.cmu.edu/pub/cyrus-mail
CYRUS-SASL_VERSION=2.1.20
CYRUS-SASL_SOURCE=cyrus-sasl-$(CYRUS-SASL_VERSION).tar.gz
CYRUS-SASL_DIR=cyrus-sasl-$(CYRUS-SASL_VERSION)
CYRUS-SASL_UNZIP=zcat

#
# CYRUS-SASL_IPK_VERSION should be incremented when the ipk changes.
#
CYRUS-SASL_IPK_VERSION=1

#
# CYRUS-SASL_CONFFILES should be a list of user-editable files
CYRUS-SASL_CONFFILES=/opt/etc/init.d/S52saslauthd

#
# CYRUS-SASL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CYRUS-SASL_PATCHES=$(CYRUS-SASL_SOURCE_DIR)/Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CYRUS-SASL_CPPFLAGS=
CYRUS-SASL_LDFLAGS=

#
# CYRUS-SASL_BUILD_DIR is the directory in which the build is done.
# CYRUS-SASL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CYRUS-SASL_IPK_DIR is the directory in which the ipk is built.
# CYRUS-SASL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CYRUS-SASL_BUILD_DIR=$(BUILD_DIR)/cyrus-sasl
CYRUS-SASL_SOURCE_DIR=$(SOURCE_DIR)/cyrus-sasl
CYRUS-SASL_IPK_DIR=$(BUILD_DIR)/cyrus-sasl-$(CYRUS-SASL_VERSION)-ipk
CYRUS-SASL_IPK=$(BUILD_DIR)/cyrus-sasl_$(CYRUS-SASL_VERSION)-$(CYRUS-SASL_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CYRUS-SASL_SOURCE):
	$(WGET) -P $(DL_DIR) $(CYRUS-SASL_SITE)/$(CYRUS-SASL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cyrus-sasl-source: $(DL_DIR)/$(CYRUS-SASL_SOURCE) $(CYRUS-SASL_PATCHES)

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
$(CYRUS-SASL_BUILD_DIR)/.configured: $(DL_DIR)/$(CYRUS-SASL_SOURCE) $(CYRUS-SASL_PATCHES)
	$(MAKE) openssl-stage 
	$(MAKE) libdb-stage 
	rm -rf $(BUILD_DIR)/$(CYRUS-SASL_DIR) $(CYRUS-SASL_BUILD_DIR)
	$(CYRUS-SASL_UNZIP) $(DL_DIR)/$(CYRUS-SASL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(CYRUS-SASL_PATCHES) | patch -d $(BUILD_DIR)/$(CYRUS-SASL_DIR) -p1
	mv $(BUILD_DIR)/$(CYRUS-SASL_DIR) $(CYRUS-SASL_BUILD_DIR)
	(cd $(CYRUS-SASL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS=`sed 's/  / /g' "$(STAGING_CPPFLAGS) $(CYRUS-SASL_CPPFLAGS)"` \
		CFLAGS=`sed 's/  / /g' "$(STAGING_CPPFLAGS) $(CYRUS-SASL_CPPFLAGS)"` \
		LDFLAGS="$(STAGING_LDFLAGS) $(CYRUS-SASL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-plugindir=/opt/lib/sasl2 \
		--with-dbpath=/opt/etc/sasl2 \
		--with-openssl="$(STAGING_PREFIX)" \
		--enable-anon \
		--enable-plain \
		--disable-login \
		--disable-gssapi \
		--disable-otp \
		--disable-krb4 \
		--disable-nls \
	)
	touch $(CYRUS-SASL_BUILD_DIR)/.configured

cyrus-sasl-unpack: $(CYRUS-SASL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CYRUS-SASL_BUILD_DIR)/.built: $(CYRUS-SASL_BUILD_DIR)/.configured
	rm -f $(CYRUS-SASL_BUILD_DIR)/.built
	$(MAKE) -C $(CYRUS-SASL_BUILD_DIR)
	touch $(CYRUS-SASL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
cyrus-sasl: $(CYRUS-SASL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CYRUS-SASL_BUILD_DIR)/.staged: $(CYRUS-SASL_BUILD_DIR)/.built
	rm -f $(CYRUS-SASL_BUILD_DIR)/.staged
	$(MAKE) -C $(CYRUS-SASL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CYRUS-SASL_BUILD_DIR)/.staged

cyrus-sasl-stage: $(CYRUS-SASL_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(CYRUS-SASL_IPK_DIR)/opt/sbin or $(CYRUS-SASL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CYRUS-SASL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CYRUS-SASL_IPK_DIR)/opt/etc/cyrus-sasl/...
# Documentation files should be installed in $(CYRUS-SASL_IPK_DIR)/opt/doc/cyrus-sasl/...
# Daemon startup scripts should be installed in $(CYRUS-SASL_IPK_DIR)/opt/etc/init.d/S??cyrus-sasl
#
# You may need to patch your application to make it use these locations.
#
$(CYRUS-SASL_IPK): $(CYRUS-SASL_BUILD_DIR)/.built
	rm -rf $(CYRUS-SASL_IPK_DIR) $(BUILD_DIR)/cyrus-sasl_*_armeb.ipk
	$(MAKE) -C $(CYRUS-SASL_BUILD_DIR) DESTDIR=$(CYRUS-SASL_IPK_DIR) install
	find $(CYRUS-SASL_IPK_DIR) -type d -exec chmod go+rx {} \;
	install -d $(CYRUS-SASL_IPK_DIR)/var/state/saslauthd
	install -d $(CYRUS-SASL_IPK_DIR)/opt/etc/sasl2
	install -d $(CYRUS-SASL_IPK_DIR)/opt/etc/init.d
	install -m 755 $(CYRUS-SASL_SOURCE_DIR)/rc.saslauthd $(CYRUS-SASL_IPK_DIR)/opt/etc/init.d/S52saslauthd
	install -d $(CYRUS-SASL_IPK_DIR)/CONTROL
	install -m 644 $(CYRUS-SASL_SOURCE_DIR)/control $(CYRUS-SASL_IPK_DIR)/CONTROL/control
	install -m 644 $(CYRUS-SASL_SOURCE_DIR)/postinst $(CYRUS-SASL_IPK_DIR)/CONTROL/postinst
	install -m 644 $(CYRUS-SASL_SOURCE_DIR)/prerm $(CYRUS-SASL_IPK_DIR)/CONTROL/prerm
	echo $(CYRUS-SASL_CONFFILES) | sed -e 's/ /\n/g' > $(CYRUS-SASL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CYRUS-SASL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cyrus-sasl-ipk: $(CYRUS-SASL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cyrus-sasl-clean:
	-$(MAKE) -C $(CYRUS-SASL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cyrus-sasl-dirclean:
	rm -rf $(BUILD_DIR)/$(CYRUS-SASL_DIR) $(CYRUS-SASL_BUILD_DIR) $(CYRUS-SASL_IPK_DIR) $(CYRUS-SASL_IPK)
