###########################################################
#
# asterisk
#
###########################################################

# You must replace "asterisk" and "ASTERISK" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# asterisk must always be done to ensure we have unique names.

#
# ASTERISK_VERSION, ASTERISK_SITE and ASTERISK_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK_DIR is the directory asterisk is created when the source
# archive is unpacked.
# ASTERISK_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
ASTERISK_SITE=ftp://ftp.asterisk.org/pub/asterisk
ASTERISK_VERSION=1.0.5
ASTERISK_SOURCE=asterisk-1.0.5.tar.gz
ASTERISK_DIR=asterisk-1.0.5
ASTERISK_UNZIP=zcat

#
# ASTERISK_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK_IPK_VERSION=1

#
# ASTERISK_PATCHES should list any patches, in the the order in
# asterisk they should be applied to the source code.
#
ASTERISK_PATCHES=$(ASTERISK_SOURCE_DIR)/asterisk.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASTERISK_CPPFLAGS=-lcrypto -L/opt/lib -I/opt/include
ASTERISK_LDFLAGS=-lcrypto -L/opt/lib -I/opt/include

#
# ASTERISK_BUILD_DIR is the directory in asterisk the build is done.
# ASTERISK_SOURCE_DIR is the directory asterisk holds all the
# patches and ipkg control files.
# ASTERISK_IPK_DIR is the directory in asterisk the ipk is built.
# ASTERISK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK_BUILD_DIR=$(BUILD_DIR)/asterisk
ASTERISK_SOURCE_DIR=$(SOURCE_DIR)/asterisk
ASTERISK_IPK_DIR=$(BUILD_DIR)/asterisk-$(ASTERISK_VERSION)-ipk
ASTERISK_IPK=$(BUILD_DIR)/asterisk_$(ASTERISK_VERSION)-$(ASTERISK_IPK_VERSION)_armeb.ipk

ASTERISK_INST_DIR=/opt
ASTERISK_BIN_DIR=$(ASTERISK_INST_DIR)/bin
ASTERISK_SBIN_DIR=$(ASTERISK_INST_DIR)/sbin
ASTERISK_LIBEXEC_DIR=$(ASTERISK_INST_DIR)/libexec
ASTERISK_DATA_DIR=$(ASTERISK_INST_DIR)/share/asterisk
ASTERISK_SYSCONF_DIR=$(ASTERISK_INST_DIR)/etc/asterisk
ASTERISK_SHAREDSTATE_DIR=$(ASTERISK_INST_DIR)/com/asterisk
ASTERISK_LOCALSTATE_DIR=$(ASTERISK_INST_DIR)/var/asterisk
ASTERISK_LIB_DIR=$(ASTERISK_INST_DIR)/lib/asterisk
ASTERISK_INCLUDE_DIR=$(ASTERISK_INST_DIR)/include/asterisk
ASTERISK_INFO_DIR=$(ASTERISK_INST_DIR)/info
ASTERISK_MAN_DIR=$(ASTERISK_INST_DIR)/man
ASTERISK_SYSCONF_SAMPLE_DIR=$(ASTERISK_INST_DIR)/etc/asterisk/sample


#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASTERISK_SOURCE):
	$(WGET) -P $(DL_DIR) $(ASTERISK_SITE)/$(ASTERISK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
asterisk-source: $(DL_DIR)/$(ASTERISK_SOURCE) $(ASTERISK_PATCHES)

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
$(ASTERISK_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK_SOURCE) $(ASTERISK_PATCHES)
	rm -rf $(BUILD_DIR)/$(ASTERISK_DIR) $(ASTERISK_BUILD_DIR)
	$(ASTERISK_UNZIP) $(DL_DIR)/$(ASTERISK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(ASTERISK_PATCHES) | patch -d $(BUILD_DIR)/$(ASTERISK_DIR) -p1
	mv $(BUILD_DIR)/$(ASTERISK_DIR) $(ASTERISK_BUILD_DIR)
	touch $(ASTERISK_BUILD_DIR)/.configured

asterisk-unpack: $(ASTERISK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK_BUILD_DIR)/.built: $(ASTERISK_BUILD_DIR)/.configured
	rm -f $(ASTERISK_BUILD_DIR)/.built
	$(MAKE) -C $(ASTERISK_BUILD_DIR) INSTALL_PREFIX=$(ASTERISK_INST_DIR)
	touch $(ASTERISK_BUILD_DIR)/.built

#
# This is the build convenience target.
#
asterisk: $(ASTERISK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK_BUILD_DIR)/.staged: $(ASTERISK_BUILD_DIR)/.built
	rm -f $(ASTERISK_BUILD_DIR)/.staged
	$(MAKE) -C $(ASTERISK_BUILD_DIR) DESTDIR=$(STAGING_DIR) INSTALL_PREFIX=$(ASTERISK_INST_DIR) install
	touch $(ASTERISK_BUILD_DIR)/.staged

asterisk-stage: $(ASTERISK_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK_IPK_DIR)/opt/sbin or $(ASTERISK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ASTERISK_IPK_DIR)/opt/etc/asterisk/...
# Documentation files should be installed in $(ASTERISK_IPK_DIR)/opt/doc/asterisk/...
# Daemon startup scripts should be installed in $(ASTERISK_IPK_DIR)/opt/etc/init.d/S??asterisk
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK_IPK): $(ASTERISK_BUILD_DIR)/.built
	rm -rf $(ASTERISK_IPK_DIR) $(BUILD_DIR)/asterisk_*_armeb.ipk
	($(MAKE) -C $(ASTERISK_BUILD_DIR) DESTDIR=$(ASTERISK_IPK_DIR) \
		INSTALL_PREFIX=$(ASTERISK_INST_DIR) \
		ASTHEADERDIR=$(ASTERISK_INCLUDE_DIR) \
		ASTBINDIR=$(ASTERISK_BIN_DIR) \
		ASTSBINDIR=$(ASTERISK_SBIN_DIR) \
		ASTMANDIR=$(ASTERISK_MAN_DIR) \
		ASTLIBDIR=$(ASTERISK_LIB_DIR) \
		install )
	($(MAKE) -C $(ASTERISK_BUILD_DIR) DESTDIR=$(ASTERISK_IPK_DIR) \
		INSTALL_PREFIX=$(ASTERISK_INST_DIR) \
                ASTHEADERDIR=$(ASTERISK_INCLUDE_DIR) \
                ASTBINDIR=$(ASTERISK_BIN_DIR) \
                ASTSBINDIR=$(ASTERISK_SBIN_DIR) \
                ASTMANDIR=$(ASTERISK_MAN_DIR) \
                ASTLIBDIR=$(ASTERISK_LIB_DIR) \
		ASTETCDIR=$(ASTERISK_SYSCONF_SAMPLE_DIR) \
		samples )
	install -d $(ASTERISK_IPK_DIR)/CONTROL
	install -m 644 $(ASTERISK_SOURCE_DIR)/control $(ASTERISK_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk-ipk: $(ASTERISK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk-clean:
	-$(MAKE) -C $(ASTERISK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK_DIR) $(ASTERISK_BUILD_DIR) $(ASTERISK_IPK_DIR) $(ASTERISK_IPK)
