###########################################################
#
# cyrus-sasl
#
###########################################################

#
# CYRUS-SASL_VERSION, CYRUS-SASL_SITE and CYRUS-SASL_SOURCE define
# the upstream location of the source code for the package.
# CYRUS-SASL_DIR is the directory which is created when the source
# archive is unpacked.
# CYRUS-SASL_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
CYRUS-SASL_SITE=ftp://ftp.andrew.cmu.edu/pub/cyrus-mail
CYRUS-SASL_VERSION=2.1.22
CYRUS-SASL_SOURCE=cyrus-sasl-$(CYRUS-SASL_VERSION).tar.gz
CYRUS-SASL_DIR=cyrus-sasl-$(CYRUS-SASL_VERSION)
CYRUS-SASL_UNZIP=zcat
CYRUS-SASL_MAINTAINER=Matthias Appel <private_tweety@gmx.net>
CYRUS-SASL_DESCRIPTION=Provides client or server side authentication (see RFC 2222).
CYRUS-SASL_SECTION=util
CYRUS-SASL_PRIORITY=optional
CYRUS-SASL_DEPENDS=
CYRUS-SASL_CONFLICTS=

CYRUS-SASL_IPK_VERSION=2

#
# CYRUS-SASL_CONFFILES should be a list of user-editable files
CYRUS-SASL_CONFFILES=/opt/etc/init.d/S52saslauthd

#
# CYRUS-SASL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CYRUS-SASL_PATCHES=$(CYRUS-SASL_SOURCE_DIR)/Makefile.in.patch \
  $(CYRUS-SASL_SOURCE_DIR)/configure-powerpc.patch \
  $(CYRUS-SASL_SOURCE_DIR)/include-Makefile.in.patch

CYRUS-SASL_BUILD_DIR=$(BUILD_DIR)/cyrus-sasl
CYRUS-SASL_SOURCE_DIR=$(SOURCE_DIR)/cyrus-sasl
CYRUS-SASL_IPK_DIR=$(BUILD_DIR)/cyrus-sasl-$(CYRUS-SASL_VERSION)-ipk
CYRUS-SASL_IPK=$(BUILD_DIR)/cyrus-sasl_$(CYRUS-SASL_VERSION)-$(CYRUS-SASL_IPK_VERSION)_$(TARGET_ARCH).ipk

CYRUS-SASL-LIBS_IPK_DIR=$(BUILD_DIR)/cyrus-sasl-libs-$(CYRUS-SASL_VERSION)-ipk
CYRUS-SASL-LIBS_IPK=$(BUILD_DIR)/cyrus-sasl-libs_$(CYRUS-SASL_VERSION)-$(CYRUS-SASL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cyrus-sasl-source cyrus-sasl-unpack cyrus-sasl cyrus-sasl-stage cyrus-sasl-ipk cyrus-sasl-clean cyrus-sasl-dirclean cyrus-sasl-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CYRUS-SASL_SOURCE):
	$(WGET) -P $(DL_DIR) $(CYRUS-SASL_SITE)/$(CYRUS-SASL_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(CYRUS-SASL_SOURCE)

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(CYRUS-SASL_BUILD_DIR)/.configured: $(DL_DIR)/$(CYRUS-SASL_SOURCE) $(CYRUS-SASL_PATCHES) make/cyrus-sasl.mk
	$(MAKE) libdb-stage openssl-stage 
	rm -rf $(BUILD_DIR)/$(CYRUS-SASL_DIR) $(CYRUS-SASL_BUILD_DIR)
	$(CYRUS-SASL_UNZIP) $(DL_DIR)/$(CYRUS-SASL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(CYRUS-SASL_PATCHES) | patch -d $(BUILD_DIR)/$(CYRUS-SASL_DIR) -p1
	mv $(BUILD_DIR)/$(CYRUS-SASL_DIR) $(CYRUS-SASL_BUILD_DIR)
	cp -f $(SOURCE_DIR)/common/config.* $(CYRUS-SASL_BUILD_DIR)/config/
# We have to remove double blanks. Otherwise configure of saslauthd fails.
	(cd $(CYRUS-SASL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(strip $(STAGING_CPPFLAGS))" \
		CFLAGS="$(strip $(STAGING_CPPFLAGS))" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CYRUS-SASL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-plugindir=/opt/lib/sasl2 \
		--with-saslauthd=/opt/var/state/saslauthd \
		--with-dbpath=/opt/etc/sasl2 \
		--with-openssl="$(STAGING_PREFIX)" \
		--enable-anon \
		--enable-plain \
		--enable-login \
		--disable-gssapi \
		--disable-otp \
		--disable-krb4 \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(CYRUS-SASL_BUILD_DIR)/libtool
	touch $(CYRUS-SASL_BUILD_DIR)/.configured

cyrus-sasl-unpack: $(CYRUS-SASL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CYRUS-SASL_BUILD_DIR)/.built: $(CYRUS-SASL_BUILD_DIR)/.configured
	rm -f $(CYRUS-SASL_BUILD_DIR)/.built
	$(MAKE) -C $(CYRUS-SASL_BUILD_DIR) HOSTCC=$(HOSTCC)
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
	rm -f $(STAGING_LIB_DIR)/libsasl2.la
	touch $(CYRUS-SASL_BUILD_DIR)/.staged

cyrus-sasl-stage: $(CYRUS-SASL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cyrus-sasl
#
$(CYRUS-SASL_IPK_DIR)/CONTROL/control:
	@install -d $(CYRUS-SASL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: cyrus-sasl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CYRUS-SASL_PRIORITY)" >>$@
	@echo "Section: $(CYRUS-SASL_SECTION)" >>$@
	@echo "Version: $(CYRUS-SASL_VERSION)-$(CYRUS-SASL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CYRUS-SASL_MAINTAINER)" >>$@
	@echo "Source: $(CYRUS-SASL_SITE)/$(CYRUS-SASL_SOURCE)" >>$@
	@echo "Description: $(CYRUS-SASL_DESCRIPTION)" >>$@
	@echo "Depends: cyrus-sasl-libs" >>$@
	@echo "Conflicts: $(CYRUS-SASL_CONFLICTS)" >>$@

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cyrus-sasl
#
$(CYRUS-SASL-LIBS_IPK_DIR)/CONTROL/control:
	@install -d $(CYRUS-SASL-LIBS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: cyrus-sasl-libs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CYRUS-SASL_PRIORITY)" >>$@
	@echo "Section: $(CYRUS-SASL_SECTION)" >>$@
	@echo "Version: $(CYRUS-SASL_VERSION)-$(CYRUS-SASL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CYRUS-SASL_MAINTAINER)" >>$@
	@echo "Source: $(CYRUS-SASL_SITE)/$(CYRUS-SASL_SOURCE)" >>$@
	@echo "Description: $(CYRUS-SASL_DESCRIPTION)" >>$@
	@echo "Depends: $(CYRUS-SASL_DEPENDS)" >>$@
	@echo "Conflicts: $(CYRUS-SASL_CONFLICTS)" >>$@
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
	rm -rf $(CYRUS-SASL_IPK_DIR) $(BUILD_DIR)/cyrus-sasl_*_$(TARGET_ARCH).ipk
	rm -rf $(CYRUS-SASL-LIBS_IPK_DIR) $(BUILD_DIR)/cyrus-sasl-libs_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CYRUS-SASL_BUILD_DIR) DESTDIR=$(CYRUS-SASL_IPK_DIR) install-strip
	rm -f $(CYRUS-SASL_IPK_DIR)/opt/lib/libsasl2.la
	rm -f $(CYRUS-SASL_IPK_DIR)/opt/lib/sasl2/*.la
	find $(CYRUS-SASL_IPK_DIR) -type d -exec chmod go+rx {} \;
	$(STRIP_COMMAND) $(CYRUS-SASL_IPK_DIR)/opt/sbin/*
	$(STRIP_COMMAND) $(CYRUS-SASL_IPK_DIR)/opt/lib/*.so
	$(STRIP_COMMAND) $(CYRUS-SASL_IPK_DIR)/opt/lib/sasl2/*.so
	install -d $(CYRUS-SASL_IPK_DIR)/opt/var/state/saslauthd
	install -d $(CYRUS-SASL_IPK_DIR)/opt/etc/init.d
ifeq ($(OPTWARE_TARGET),ds101g)
	install -m 755 $(CYRUS-SASL_SOURCE_DIR)/rc.saslauthd.ds101g $(CYRUS-SASL_IPK_DIR)/opt/etc/init.d/S52saslauthd
else
	install -m 755 $(CYRUS-SASL_SOURCE_DIR)/rc.saslauthd $(CYRUS-SASL_IPK_DIR)/opt/etc/init.d/S52saslauthd
endif
	### build cyrus-sasl-libs
	$(MAKE) $(CYRUS-SASL-LIBS_IPK_DIR)/CONTROL/control
	install -d $(CYRUS-SASL-LIBS_IPK_DIR)/opt
	mv $(CYRUS-SASL_IPK_DIR)/opt/include $(CYRUS-SASL-LIBS_IPK_DIR)/opt
	mv $(CYRUS-SASL_IPK_DIR)/opt/lib $(CYRUS-SASL-LIBS_IPK_DIR)/opt
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CYRUS-SASL-LIBS_IPK_DIR)
	### build the main ipk
	$(MAKE) $(CYRUS-SASL_IPK_DIR)/CONTROL/control
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
#
#
# Some sanity check for the package.
#
cyrus-sasl-check: $(CYRUS-SASL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CYRUS-SASL_IPK)
