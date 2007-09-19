###########################################################
#
# adns
#
###########################################################

#
# ADNS_VERSION, ADNS_SITE and ADNS_SOURCE define
# the upstream location of the source code for the package.
# ADNS_DIR is the directory which is created when the source
# archive is unpacked.
# ADNS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
ADNS_SITE=http://www.chiark.greenend.org.uk/~ian/adns/ftp
ADNS_VERSION=1.4
ADNS_SOURCE=adns-$(ADNS_VERSION).tar.gz
ADNS_DIR=adns-$(ADNS_VERSION)
ADNS_UNZIP=zcat
ADNS_PRIORITY=optional
ADNS_MAINTAINER= NSLU2 Linux <nslu2-linux@yahoogroups.com>
ADNS_SECTION=libraries
ADNS_DEPENDS=
ADNS_DESCRIPTION=Asynchronous resolver library and DNS resolver utilities.

#
# ADNS_IPK_VERSION should be incremented when the ipk changes.
#
ADNS_IPK_VERSION=2

#
# ADNS_CONFFILES should be a list of user-editable files
ADNS_CONFFILES=/opt/etc/adns.conf /opt/etc/init.d/SXXadns

#
# ADNS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ADNS_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ADNS_CPPFLAGS=
ADNS_LDFLAGS=

#
# ADNS_BUILD_DIR is the directory in which the build is done.
# ADNS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ADNS_IPK_DIR is the directory in which the ipk is built.
# ADNS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ADNS_BUILD_DIR=$(BUILD_DIR)/adns
ADNS_SOURCE_DIR=$(SOURCE_DIR)/adns
ADNS_IPK_DIR=$(BUILD_DIR)/adns-$(ADNS_VERSION)-ipk
ADNS_IPK=$(BUILD_DIR)/adns_$(ADNS_VERSION)-$(ADNS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ADNS_SOURCE):
	$(WGET) -P $(DL_DIR) $(ADNS_SITE)/$(ADNS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
adns-source: $(DL_DIR)/$(ADNS_SOURCE) $(ADNS_PATCHES)

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
$(ADNS_BUILD_DIR)/.configured: $(DL_DIR)/$(ADNS_SOURCE) $(ADNS_PATCHES)
	rm -rf $(BUILD_DIR)/$(ADNS_DIR) $(ADNS_BUILD_DIR)
	$(ADNS_UNZIP) $(DL_DIR)/$(ADNS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(ADNS_PATCHES) | patch -d $(BUILD_DIR)/$(ADNS_DIR) -p1
	mv $(BUILD_DIR)/$(ADNS_DIR) $(ADNS_BUILD_DIR)
	(cd $(ADNS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ADNS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ADNS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(ADNS_BUILD_DIR)/.configured

adns-unpack: $(ADNS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ADNS_BUILD_DIR)/.built: $(ADNS_BUILD_DIR)/.configured
	rm -f $(ADNS_BUILD_DIR)/.built
	$(MAKE) -C $(ADNS_BUILD_DIR)
	touch $(ADNS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
adns: $(ADNS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ADNS_BUILD_DIR)/.staged: $(ADNS_BUILD_DIR)/.built
	rm -f $(ADNS_BUILD_DIR)/.staged
	(cd $(ADNS_BUILD_DIR); \
		install -c -m 644 src/libadns.a $(STAGING_LIB_DIR)/libadns.a ; \
		install -c -m 755 dynamic/libadns.so.$(ADNS_VERSION) \
			 $(STAGING_LIB_DIR)/libadns.so.$(ADNS_VERSION) ; \
		ln -sf libadns.so.$(ADNS_VERSION) \
			$(STAGING_LIB_DIR)/libadns.so.1 ; \
		ln -sf libadns.so.$(ADNS_VERSION) $(STAGING_LIB_DIR)/libadns.so ; \
		install -c -m 644 src/adns.h $(STAGING_INCLUDE_DIR)/adns.h ; \
	)
	touch $(ADNS_BUILD_DIR)/.staged

adns-stage: $(ADNS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/<foo>
#
$(ADNS_IPK_DIR)/CONTROL/control:
	@install -d $(ADNS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: adns" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ADNS_PRIORITY)" >>$@
	@echo "Section: $(ADNS_SECTION)" >>$@
	@echo "Version: $(ADNS_VERSION)-$(ADNS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ADNS_MAINTAINER)" >>$@
	@echo "Source: $(ADNS_SITE)/$(ADNS_SOURCE)" >>$@
	@echo "Description: $(ADNS_DESCRIPTION)" >>$@
	@echo "Depends: $(ADNS_DEPENDS)" >>$@
	@echo "Conflicts: $(ADNS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ADNS_IPK_DIR)/opt/sbin or $(ADNS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ADNS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ADNS_IPK_DIR)/opt/etc/adns/...
# Documentation files should be installed in $(ADNS_IPK_DIR)/opt/doc/adns/...
# Daemon startup scripts should be installed in $(ADNS_IPK_DIR)/opt/etc/init.d/S??adns
#
# You may need to patch your application to make it use these locations.
#
$(ADNS_IPK): $(ADNS_BUILD_DIR)/.built
	rm -rf $(ADNS_IPK_DIR) $(BUILD_DIR)/adns_*_$(TARGET_ARCH).ipk
	install -d $(ADNS_IPK_DIR)/opt/lib/
	#install -m 644 $(ADNS_BUILD_DIR)/src/libadns.a $(ADNS_IPK_DIR)/opt/lib/libadns.a
	install -m 755 $(ADNS_BUILD_DIR)/dynamic/libadns.so.[0-9]*.[0-9]* \
		 $(ADNS_IPK_DIR)/opt/lib/
	cd $(ADNS_IPK_DIR)/opt/lib && ln -sf libadns.so.[0-9]*.[0-9]* libadns.so.1
	ln -sf libadns.so.1 $(ADNS_IPK_DIR)/opt/lib/libadns.so
	$(STRIP_COMMAND) $(ADNS_IPK_DIR)/opt/lib/libadns.so.[0-9]*.[0-9]*
	install -d $(ADNS_IPK_DIR)/opt/include/
	install -m 644 $(ADNS_BUILD_DIR)/src/adns.h $(ADNS_IPK_DIR)/opt/include/adns.h
	install -d $(ADNS_IPK_DIR)/opt/bin/
	install -m 755 $(ADNS_BUILD_DIR)/client/adnslogres    $(ADNS_IPK_DIR)/opt/bin/adnslogres
	install -m 755 $(ADNS_BUILD_DIR)/client/adnshost      $(ADNS_IPK_DIR)/opt/bin/adnshost
	install -m 755 $(ADNS_BUILD_DIR)/client/adnsresfilter $(ADNS_IPK_DIR)/opt/bin/adnsresfilter
	$(STRIP_COMMAND) $(ADNS_IPK_DIR)/opt/bin/*
	install -d $(ADNS_IPK_DIR)/CONTROL
	$(MAKE) $(ADNS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ADNS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
adns-ipk: $(ADNS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
adns-clean:
	-$(MAKE) -C $(ADNS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
adns-dirclean:
	rm -rf $(BUILD_DIR)/$(ADNS_DIR) $(ADNS_BUILD_DIR) $(ADNS_IPK_DIR) $(ADNS_IPK)

#
# Some sanity check for the package.
#
adns-check: $(ADNS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ADNS_IPK)
