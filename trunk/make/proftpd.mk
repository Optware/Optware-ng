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
PROFTPD_NAME=proftpd
PROFTPD_SITE=ftp://ftp.proftpd.org/distrib/source
PROFTPD_VERSION=1.3.1
PROFTPD_SOURCE=$(PROFTPD_NAME)-$(PROFTPD_VERSION).tar.bz2
PROFTPD_DIR=$(PROFTPD_NAME)-$(PROFTPD_VERSION)
PROFTPD_UNZIP=bzcat

PROFTPD-MOD-SHAPER_SITE=http://www.castaglia.org/proftpd/modules
PROFTPD-MOD-SHAPER_SOURCE=proftpd-mod-shaper-0.6.3.tar.gz

#
# PROFTPD_IPK_VERSION should be incremented when the ipk changes.
#
PROFTPD_IPK_VERSION=3

#
# Control file info
#
PROFTPD_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
PROFTPD_DESCRIPTION=Highly configurable FTP server with SSL-TLS
PROFTPD_SECTION=net
PROFTPD_PRIORITY=optional
PROFTPD_CONFLICTS=
PROFTPD_DEPENDS=openssl

#
# PROFTPD_CONFFILES should be a list of user-editable files
PROFTPD_CONFFILES=/opt/etc/proftpd.conf /opt/etc/xinetd.d/proftpd

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
PROFTPD_IPK=$(BUILD_DIR)/proftpd_$(PROFTPD_VERSION)-$(PROFTPD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: proftpd-source proftpd-unpack proftpd proftpd-stage proftpd-ipk proftpd-clean proftpd-dirclean proftpd-check

#
# Automatically create a ipkg control file
#
$(PROFTPD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: $(PROFTPD_NAME)" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PROFTPD_PRIORITY)" >>$@
	@echo "Section: $(PROFTPD_SECTION)" >>$@
	@echo "Version: $(PROFTPD_VERSION)-$(PROFTPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PROFTPD_MAINTAINER)" >>$@
	@echo "Source: $(PROFTPD_SITE)/$(PROFTPD_SOURCE)" >>$@
	@echo "Description: $(PROFTPD_DESCRIPTION)" >>$@
	@echo "Depends: $(PROFTPD_DEPENDS)" >>$@
	@echo "Conflicts: $(PROFTPD_CONFLICTS)" >>$@



#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PROFTPD_SOURCE):
	$(WGET) -P $(@D) $(PROFTPD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(PROFTPD-MOD-SHAPER_SOURCE):
	$(WGET) -P $(@D) $(PROFTPD-MOD-SHAPER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
proftpd-source: $(DL_DIR)/$(PROFTPD_SOURCE) $(DL_DIR)/$(PROFTPD-MOD-SHAPER_SOURCE) $(PROFTPD_PATCHES)

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
$(PROFTPD_BUILD_DIR)/.configured: $(DL_DIR)/$(PROFTPD_SOURCE) $(DL_DIR)/$(PROFTPD-MOD-SHAPER_SOURCE) $(PROFTPD_PATCHES)
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(PROFTPD_DIR) $(PROFTPD_BUILD_DIR)
	$(PROFTPD_UNZIP) $(DL_DIR)/$(PROFTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PROFTPD_PATCHES) | patch -d $(BUILD_DIR)/$(PROFTPD_DIR) -p1
	mv $(BUILD_DIR)/$(PROFTPD_DIR) $(PROFTPD_BUILD_DIR)
	zcat $(DL_DIR)/$(PROFTPD-MOD-SHAPER_SOURCE) | tar -C $(@D) -xvf -
	cp $(@D)/mod_shaper/* $(@D)/contrib/
	# Copy required config.cache file
	cp $(PROFTPD_SOURCE_DIR)/config.cache $(@D)/config.cache
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PROFTPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PROFTPD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-ctrls \
		--with-modules=mod_tls:mod_shaper \
		--cache-file=config.cache \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

proftpd-unpack: $(PROFTPD_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PROFTPD_BUILD_DIR)/.built: $(PROFTPD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) HOSTCC=$(HOSTCC)
	touch $@

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
	rm -rf $(PROFTPD_IPK_DIR) $(BUILD_DIR)/proftpd_*_$(TARGET_ARCH).ipk
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
	install -m 0644 $(PROFTPD_BUILD_DIR)/src/ftpdctl.8 $(PROFTPD_IPK_DIR)/opt/man/man8
	install -m 0644 $(PROFTPD_BUILD_DIR)/src/proftpd.8 $(PROFTPD_IPK_DIR)/opt/man/man8   
	install -m 0644 $(PROFTPD_BUILD_DIR)/utils/ftpshut.8 $(PROFTPD_IPK_DIR)/opt/man/man8 
	install -m 0644 $(PROFTPD_BUILD_DIR)/utils/ftpcount.1 $(PROFTPD_IPK_DIR)/opt/man/man1
	install -m 0644 $(PROFTPD_BUILD_DIR)/utils/ftptop.1  $(PROFTPD_IPK_DIR)/opt/man/man1 
	install -m 0644 $(PROFTPD_BUILD_DIR)/utils/ftpwho.1  $(PROFTPD_IPK_DIR)/opt/man/man1 
	install -m 0644 $(PROFTPD_BUILD_DIR)/src/xferlog.5   $(PROFTPD_IPK_DIR)/opt/man/man5
	# Install folder for storing socket file and scoreboard
	install -d $(PROFTPD_IPK_DIR)/opt/var/proftpd
	# Install conf files
	install -d $(PROFTPD_IPK_DIR)/opt/etc/init.d
	install -m 644 $(PROFTPD_SOURCE_DIR)/proftpd.conf $(PROFTPD_IPK_DIR)/opt/etc/proftpd.conf
	# Install xinetd support
	install -d $(PROFTPD_IPK_DIR)/opt/etc/xinetd.d
	install -m 644 $(PROFTPD_SOURCE_DIR)/proftpd $(PROFTPD_IPK_DIR)/opt/etc/xinetd.d
	# Install doc files
	install -d $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 755 $(PROFTPD_SOURCE_DIR)/S58proftpd $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 644 $(PROFTPD_SOURCE_DIR)/proftpd-install.doc $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 644 $(PROFTPD_BUILD_DIR)/sample-configurations/anonymous.conf $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 644 $(PROFTPD_BUILD_DIR)/sample-configurations/basic.conf $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 644 $(PROFTPD_BUILD_DIR)/sample-configurations/complex-virtual.conf $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 644 $(PROFTPD_BUILD_DIR)/sample-configurations/mod_sql.conf $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	install -m 644 $(PROFTPD_BUILD_DIR)/sample-configurations/virtual.conf $(PROFTPD_IPK_DIR)/opt/doc/proftpd
	# Make directory in which to store keys
	install -d $(PROFTPD_IPK_DIR)/opt/etc/ftpd
	# Install control file
	make  $(PROFTPD_IPK_DIR)/CONTROL/control
	install -m 755 $(PROFTPD_SOURCE_DIR)/postinst $(PROFTPD_IPK_DIR)/CONTROL/postinst
	install -m 755 $(PROFTPD_SOURCE_DIR)/prerm $(PROFTPD_IPK_DIR)/CONTROL/prerm
	echo $(PROFTPD_CONFFILES) | sed -e 's/ /\n/g' > $(PROFTPD_IPK_DIR)/CONTROL/conffiles
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

#
# Some sanity check for the package.
#
proftpd-check: $(PROFTPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PROFTPD_IPK)
