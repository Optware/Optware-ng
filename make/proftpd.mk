###########################################################
#
# proftpd
#
###########################################################

# You must replace "proftpd" and "PROFTPD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PROFTPD_VERSION, PROFTPD_SITE and PROFTPD_SOURCE define
# the upstream location of the source code for the package.
# PROFTPD_DIR is the directory which is created when the source
# archive is unpacked.
# PROFTPD_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
PROFTPD_SITE=ftp://ftp.proftpd.org/distrib/source
PROFTPD_VERSION=1.2.10
PROFTPD_SOURCE=proftpd-$(PROFTPD_VERSION).tar.gz
PROFTPD_DIR=proftpd-$(PROFTPD_VERSION)
PROFTPD_UNZIP=zcat

#
# PROFTPD_IPK_VERSION should be incremented when the ipk changes.
#
PROFTPD_IPK_VERSION=2

#
# PROFTPD_CONFFILES should be a list of user-editable files
PROFTPD_CONFFILES=/opt/etc/proftpd.conf 

#
# PROFTPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PROFTPD_PATCHES=$(PROFTPD_SOURCE_DIR)/libcap-makefile.patch $(PROFTPD_SOURCE_DIR)/default_paths.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PROFTPD_CPPFLAGS=-DHAVE_LLU=1 -UHAVE_LU -DFTPUSERS_PATH='\"/opt/etc/ftpusers\"'
PROFTPD_LDFLAGS=

#
# PROFTPD_BUILD_DIR is the directory in which the build is done.
# PROFTPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PROFTPD_IPK_DIR is the directory in which the ipk is built.
# PROFTPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PROFTPD_BUILD_DIR=$(BUILD_DIR)/proftpd
PROFTPD_SOURCE_DIR=$(SOURCE_DIR)/proftpd
PROFTPD_IPK_DIR=$(BUILD_DIR)/proftpd-$(PROFTPD_VERSION)-ipk
PROFTPD_IPK=$(BUILD_DIR)/proftpd_$(PROFTPD_VERSION)-$(PROFTPD_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PROFTPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(PROFTPD_SITE)/$(PROFTPD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
proftpd-source: $(DL_DIR)/$(PROFTPD_SOURCE) $(PROFTPD_PATCHES)

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
$(PROFTPD_BUILD_DIR)/.configured: $(DL_DIR)/$(PROFTPD_SOURCE) $(PROFTPD_PATCHES)
ifneq ($(HOST_MACHINE),armv5b)
	$(MAKE) openssl-stage
endif
	rm -rf $(BUILD_DIR)/$(PROFTPD_DIR) $(PROFTPD_BUILD_DIR)
	$(PROFTPD_UNZIP) $(DL_DIR)/$(PROFTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PROFTPD_PATCHES) | patch -d $(BUILD_DIR)/$(PROFTPD_DIR) -p1
	mv $(BUILD_DIR)/$(PROFTPD_DIR) $(PROFTPD_BUILD_DIR)
	# Copy required config.cache file
	cp $(PROFTPD_SOURCE_DIR)/config.cache $(PROFTPD_BUILD_DIR)/config.cache
	(cd $(PROFTPD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PROFTPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PROFTPD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-modules=mod_tls \
		--enable-ctrls \
		--cache-file=config.cache \
	)
	touch $(PROFTPD_BUILD_DIR)/.configured

proftpd-unpack: $(PROFTPD_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PROFTPD_BUILD_DIR)/.built: $(PROFTPD_BUILD_DIR)/.configured
	rm -f $(PROFTPD_BUILD_DIR)/.built
	$(MAKE) -C $(PROFTPD_BUILD_DIR) $(TARGET_CONFIGURE_OPTS) HOSTCC=$(HOSTCC)
	touch $(PROFTPD_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
proftpd: $(PROFTPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#


proftpd-stage: $(STAGING_DIR)/opt/lib/libproftpd.so.$(PROFTPD_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(PROFTPD_IPK_DIR)/opt/sbin or $(PROFTPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PROFTPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PROFTPD_IPK_DIR)/opt/etc/proftpd/...
# Documentation files should be installed in $(PROFTPD_IPK_DIR)/opt/doc/proftpd/...
# Daemon startup scripts should be installed in $(PROFTPD_IPK_DIR)/opt/etc/init.d/S??proftpd
#
# You may need to patch your application to make it use these locations.
#
$(PROFTPD_IPK): $(PROFTPD_BUILD_DIR)/.built
	# Clean it all
	rm -rf $(PROFTPD_IPK_DIR) $(BUILD_DIR)/proftpd_*_armeb.ipk
	# Install sbin files
	install -d $(PROFTPD_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(PROFTPD_BUILD_DIR)/proftpd -o $(PROFTPD_IPK_DIR)/opt/sbin/proftpd
	$(STRIP_COMMAND) $(PROFTPD_BUILD_DIR)/ftpshut -o $(PROFTPD_IPK_DIR)/opt/sbin/ftpshut
	# Install bin files
	install -d $(PROFTPD_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(PROFTPD_BUILD_DIR)/ftpdctl -o $(PROFTPD_IPK_DIR)/opt/bin/ftpdctl
	$(STRIP_COMMAND) $(PROFTPD_BUILD_DIR)/ftptop -o $(PROFTPD_IPK_DIR)/opt/bin/ftptop
	$(STRIP_COMMAND) $(PROFTPD_BUILD_DIR)/ftpcount -o $(PROFTPD_IPK_DIR)/opt/bin/ftpcount
	$(STRIP_COMMAND) $(PROFTPD_BUILD_DIR)/ftpwho -o $(PROFTPD_IPK_DIR)/opt/bin/ftpwho
	# Install man files
	install -d $(PROFTPD_IPK_DIR)/opt/man/man1
	install -d $(PROFTPD_IPK_DIR)/opt/man/man5
	install -d $(PROFTPD_IPK_DIR)/opt/man/man8	
	$(MAKE) -C $(PROFTPD_BUILD_DIR) DESTDIR=$(PROFTPD_IPK_DIR) install-man
	# Install empty file
	install -d $(PROFTPD_IPK_DIR)/usr/share/empty
	# Install conf files
	install -d $(PROFTPD_IPK_DIR)/opt/etc/init.d
	install -m 644 $(PROFTPD_SOURCE_DIR)/proftpd.conf $(PROFTPD_IPK_DIR)/opt/etc/proftpd.conf
	# Install doc file
	install -d $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 755 $(PROFTPD_SOURCE_DIR)/S58proftpd $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 755 $(PROFTPD_SOURCE_DIR)/rc.xinetd.proftpd $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 644 $(PROFTPD_SOURCE_DIR)/proftpd-install.doc $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 644 $(PROFTPD_SOURCE_DIR)/proftpd.xinetd $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 644 $(PROFTPD_SOURCE_DIR)/inetd.conf.proftpd $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 644 $(PROFTPD_BUILD_DIR)/sample-configurations/anonymous.conf $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 644 $(PROFTPD_BUILD_DIR)/sample-configurations/basic.conf $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 644 $(PROFTPD_BUILD_DIR)/sample-configurations/complex-virtual.conf $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 644 $(PROFTPD_BUILD_DIR)/sample-configurations/mod_sql.conf $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 644 $(PROFTPD_BUILD_DIR)/sample-configurations/virtual.conf $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	# Make directory in which to store keys
	install -d $(PROFTPD_IPK_DIR)/opt/etc/ftpd
	# Install control files
	install -d $(PROFTPD_IPK_DIR)/CONTROL
	install -m 644 $(PROFTPD_SOURCE_DIR)/control $(PROFTPD_IPK_DIR)/CONTROL/control
	install -m 644 $(PROFTPD_SOURCE_DIR)/postinst $(PROFTPD_IPK_DIR)/CONTROL/postinst
	install -m 644 $(PROFTPD_SOURCE_DIR)/prerm $(PROFTPD_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PROFTPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
proftpd-ipk: $(PROFTPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
proftpd-clean:
	-$(MAKE) -C $(PROFTPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
proftpd-dirclean:
	rm -rf $(BUILD_DIR)/$(PROFTPD_DIR) $(PROFTPD_BUILD_DIR) $(PROFTPD_IPK_DIR) $(PROFTPD_IPK)
