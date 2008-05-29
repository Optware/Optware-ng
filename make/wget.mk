###########################################################
#
# wget and wget-ssl
#
###########################################################
#
# $Header$
#
# WGET_VERSION, WGET_SITE and WGET_SOURCE define
# the upstream location of the source code for the package.
# WGET_DIR is the directory which is created when the source
# archive is unpacked.
# WGET_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
WGET_SITE=http://ftp.gnu.org/pub/gnu/wget
WGET_VERSION=1.11.2
WGET_SOURCE=wget-$(WGET_VERSION).tar.gz
WGET_DIR=wget-$(WGET_VERSION)
WGET_UNZIP=zcat
WGET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
WGET_DESCRIPTION=A network utility to retrieve files from the Web
WGET_SECTION=net
WGET_PRIORITY=optional
WGET_DEPENDS=
WGET_CONFLICTS=wget-ssl
WGET-SSL_DEPENDS=openssl
WGET-SSL_CONFLICTS=wget

#
# WGET_IPK_VERSION should be incremented when the ipk changes.
#
WGET_IPK_VERSION=2

#
# WGET_CONFFILES should be a list of user-editable files
WGET_CONFFILES=/opt/etc/wgetrc

#
# WGET_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
WGET_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WGET_CPPFLAGS=
WGET_LDFLAGS=

#
# WGET_BUILD_DIR is the directory in which the build is done.
# WGET_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WGET_IPK_DIR is the directory in which the ipk is built.
# WGET_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WGET_BUILD_DIR=$(BUILD_DIR)/wget
WGET_SOURCE_DIR=$(SOURCE_DIR)/wget
WGET_IPK_DIR=$(BUILD_DIR)/wget-$(WGET_VERSION)-ipk
WGET_IPK=$(BUILD_DIR)/wget_$(WGET_VERSION)-$(WGET_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# WGET-SSL_BUILD_DIR is the directory in which the build is done.
# WGET-SSL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WGET-SSL_IPK_DIR is the directory in which the ipk is built.
# WGET-SSL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WGET-SSL_BUILD_DIR=$(BUILD_DIR)/wget-ssl
WGET-SSL_SOURCE_DIR=$(SOURCE_DIR)/wget-ssl
WGET-SSL_IPK_DIR=$(BUILD_DIR)/wget-ssl-$(WGET_VERSION)-ipk
WGET-SSL_IPK=$(BUILD_DIR)/wget-ssl_$(WGET_VERSION)-$(WGET_IPK_VERSION)_$(TARGET_ARCH).ipk


#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WGET_SOURCE):
	$(WGET) -P $(@D) $(WGET_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
wget-source: $(DL_DIR)/$(WGET_SOURCE) $(WGET_PATCHES)
wget-ssl-source: $(DL_DIR)/$(WGET_SOURCE) $(WGET_PATCHES)

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
$(WGET_BUILD_DIR)/.configured: $(DL_DIR)/$(WGET_SOURCE) $(WGET_PATCHES)
	rm -rf $(BUILD_DIR)/$(WGET_DIR) $(@D)
	$(WGET_UNZIP) $(DL_DIR)/$(WGET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(WGET_PATCHES) | patch -d $(BUILD_DIR)/$(WGET_DIR) -p1
	mv $(BUILD_DIR)/$(WGET_DIR) $(@D)
ifeq ($(OPTWARE_TARGET), $(filter ts101, $(OPTWARE_TARGET)))
	sed -i -e '/_POSIX_TIMERS/s|#elif .*|#elif 0|' $(@D)/src/ptimer.c
endif
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WGET_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WGET_LDFLAGS)" \
		./configure \
		--disable-rpath \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--without-ssl \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

$(WGET-SSL_BUILD_DIR)/.configured: $(DL_DIR)/$(WGET_SOURCE) $(WGET_PATCHES)
ifneq ($(HOSTCC),$(TARGET_CC))
	$(MAKE) openssl-stage
endif
	rm -rf $(BUILD_DIR)/$(WGET_DIR) $(@D)
	$(WGET_UNZIP) $(DL_DIR)/$(WGET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(WGET_PATCHES) | patch -d $(BUILD_DIR)/$(WGET_DIR) -p1
	mv $(BUILD_DIR)/$(WGET_DIR) $(@D)
ifeq ($(OPTWARE_TARGET), $(filter ts101, $(OPTWARE_TARGET)))
	sed -i -e '/_POSIX_TIMERS/s|#elif .*|#elif 0|' $(@D)/src/ptimer.c
endif
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WGET_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WGET_LDFLAGS)" \
		./configure \
		--disable-rpath \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-ssl \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@


wget-unpack: $(WGET_BUILD_DIR)/.configured
wget-ssl-unpack: $(WGET-SSL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WGET_BUILD_DIR)/.built: $(WGET_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

$(WGET-SSL_BUILD_DIR)/.built: $(WGET-SSL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
#
wget: $(WGET_BUILD_DIR)/.built
wget-ssl: $(WGET-SSL_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/wget
#
$(WGET_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: wget" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WGET_PRIORITY)" >>$@
	@echo "Section: $(WGET_SECTION)" >>$@
	@echo "Version: $(WGET_VERSION)-$(WGET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WGET_MAINTAINER)" >>$@
	@echo "Source: $(WGET_SITE)/$(WGET_SOURCE)" >>$@
	@echo "Description: $(WGET_DESCRIPTION)" >>$@
	@echo "Depends: $(WGET_DEPENDS)" >>$@
	@echo "Conflicts: $(WGET_CONFLICTS)" >>$@

$(WGET-SSL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: wget-ssl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WGET_PRIORITY)" >>$@
	@echo "Section: $(WGET_SECTION)" >>$@
	@echo "Version: $(WGET_VERSION)-$(WGET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WGET_MAINTAINER)" >>$@
	@echo "Source: $(WGET_SITE)/$(WGET_SOURCE)" >>$@
	@echo "Description: $(WGET_DESCRIPTION)" >>$@
	@echo "Depends: $(WGET-SSL_DEPENDS)" >>$@
	@echo "Conflicts: $(WGET-SSL_CONFLICTS)" >>$@



#
# This builds the IPK file.
#
# Binaries should be installed into $(WGET_IPK_DIR)/opt/sbin or $(WGET_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WGET_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WGET_IPK_DIR)/opt/etc/wget/...
# Documentation files should be installed in $(WGET_IPK_DIR)/opt/doc/wget/...
# Daemon startup scripts should be installed in $(WGET_IPK_DIR)/opt/etc/init.d/S??wget
#
# You may need to patch your application to make it use these locations.
#
$(WGET_IPK): $(WGET_BUILD_DIR)/.built
	rm -rf $(WGET_IPK_DIR) $(BUILD_DIR)/wget_*_$(TARGET_ARCH).ipk
	install -d $(WGET_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(WGET_BUILD_DIR)/src/wget -o $(WGET_IPK_DIR)/opt/bin/wget
	install -d $(WGET_IPK_DIR)/opt/man/man1
	install -m 644 $(WGET_BUILD_DIR)/doc/wget.1 $(WGET_IPK_DIR)/opt/man/man1
	install -d $(WGET_IPK_DIR)/opt/etc/
	install -m 755 $(WGET_BUILD_DIR)/doc/sample.wgetrc $(WGET_IPK_DIR)/opt/etc/wgetrc
	$(MAKE) $(WGET_IPK_DIR)/CONTROL/control
#	install -m 644 $(WGET_SOURCE_DIR)/postinst $(WGET_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(WGET_SOURCE_DIR)/prerm $(WGET_IPK_DIR)/CONTROL/prerm
	echo $(WGET_CONFFILES) | sed -e 's/ /\n/g' > $(WGET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WGET_IPK_DIR)

$(WGET_BUILD_DIR)/.ipk: $(WGET_IPK)
	touch $@

$(WGET-SSL_IPK): $(WGET-SSL_BUILD_DIR)/.built
	rm -rf $(WGET-SSL_IPK_DIR) $(BUILD_DIR)/wget-ssl_*_$(TARGET_ARCH).ipk
	install -d $(WGET-SSL_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(WGET-SSL_BUILD_DIR)/src/wget -o $(WGET-SSL_IPK_DIR)/opt/bin/wget
	install -d $(WGET-SSL_IPK_DIR)/opt/man/man1
	install -m 644 $(WGET-SSL_BUILD_DIR)/doc/wget.1 $(WGET-SSL_IPK_DIR)/opt/man/man1
	install -d $(WGET-SSL_IPK_DIR)/opt/etc/
	install -m 755 $(WGET-SSL_BUILD_DIR)/doc/sample.wgetrc $(WGET-SSL_IPK_DIR)/opt/etc/wgetrc
	$(MAKE) $(WGET-SSL_IPK_DIR)/CONTROL/control
#	install -m 644 $(WGET-SSL_SOURCE_DIR)/postinst $(WGET-SSL_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(WGET-SSL_SOURCE_DIR)/prerm $(WGET-SSL_IPK_DIR)/CONTROL/prerm
	echo $(WGET_CONFFILES) | sed -e 's/ /\n/g' > $(WGET-SSL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WGET-SSL_IPK_DIR)

$(WGET-SSL_BUILD_DIR)/.ipk: $(WGET-SSL_IPK)
	touch $@

#
# This is called from the top level makefile to create the IPK file.
#
wget-ipk: $(WGET_IPK) $(WGET-SSL_IPK)

wget-only-ipk: $(WGET_IPK)
wget-ssl-ipk: $(WGET-SSL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
wget-clean:
	-$(MAKE) -C $(WGET_BUILD_DIR) clean
	-$(MAKE) -C $(WGET-SSL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
wget-dirclean:
	rm -rf $(BUILD_DIR)/$(WGET_DIR) $(WGET_BUILD_DIR) $(WGET_IPK_DIR) $(WGET_IPK)
	rm -rf $(BUILD_DIR)/$(WGET_DIR) $(WGET-SSL_BUILD_DIR) $(WGET-SSL_IPK_DIR) $(WGET-SSL_IPK)

#
# Some sanity check for the package.
#
wget-check: $(WGET_IPK) $(WGET-SSL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(WGET_IPK) $(WGET-SSL_IPK)
