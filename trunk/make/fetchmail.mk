###########################################################
#
# fetchmail
#
###########################################################

# You must replace "fetchmail" and "FETCHMAIL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# FETCHMAIL_VERSION, FETCHMAIL_SITE and FETCHMAIL_SOURCE define
# the upstream location of the source code for the package.
# FETCHMAIL_DIR is the directory which is created when the source
# archive is unpacked.
# FETCHMAIL_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
FETCHMAIL_SITE=http://download.berlios.de/fetchmail
FETCHMAIL_VERSION=6.3.8
FETCHMAIL_SOURCE=fetchmail-$(FETCHMAIL_VERSION).tar.bz2
FETCHMAIL_DIR=fetchmail-$(FETCHMAIL_VERSION)
FETCHMAIL_UNZIP=bzcat
FETCHMAIL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FETCHMAIL_DESCRIPTION=A remote mail retrieval and forwarding utility
FETCHMAIL_SECTION=util
FETCHMAIL_PRIORITY=optional
FETCHMAIL_DEPENDS=openssl
FETCHMAIL_CONFLICTS=

#
# FETCHMAIL_IPK_VERSION should be incremented when the ipk changes.
#
FETCHMAIL_IPK_VERSION=1

#
# FETCHMAIL_CONFFILES should be a list of user-editable files
FETCHMAIL_CONFFILES=/opt/etc/fetchmailrc /opt/etc/init.d/S52fetchmail

ifeq ($(OPTWARE_TARGET),ds101g)
FETCHMAIL_LOGGING=--syslog
else
FETCHMAIL_LOGGING=-L /opt/var/log/fetchmail
endif

#
# FETCHMAIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FETCHMAIL_PATCHES=$(FETCHMAIL_SOURCE_DIR)/configure.patch
FETCHMAIL_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FETCHMAIL_CPPFLAGS=
FETCHMAIL_LDFLAGS=

#
# FETCHMAIL_BUILD_DIR is the directory in which the build is done.
# FETCHMAIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FETCHMAIL_IPK_DIR is the directory in which the ipk is built.
# FETCHMAIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FETCHMAIL_BUILD_DIR=$(BUILD_DIR)/fetchmail
FETCHMAIL_SOURCE_DIR=$(SOURCE_DIR)/fetchmail
FETCHMAIL_IPK_DIR=$(BUILD_DIR)/fetchmail-$(FETCHMAIL_VERSION)-ipk
FETCHMAIL_IPK=$(BUILD_DIR)/fetchmail_$(FETCHMAIL_VERSION)-$(FETCHMAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fetchmail-source fetchmail-unpack fetchmail fetchmail-stage fetchmail-ipk fetchmail-clean fetchmail-dirclean fetchmail-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FETCHMAIL_SOURCE):
	$(WGET) -P $(DL_DIR) $(FETCHMAIL_SITE)/$(FETCHMAIL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fetchmail-source: $(DL_DIR)/$(FETCHMAIL_SOURCE) $(FETCHMAIL_PATCHES)

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
$(FETCHMAIL_BUILD_DIR)/.configured: $(DL_DIR)/$(FETCHMAIL_SOURCE) $(FETCHMAIL_PATCHES)
	$(MAKE) zlib-stage
	$(MAKE) openssl-stage
#	$(MAKE) openssh-stage
	rm -rf $(BUILD_DIR)/$(FETCHMAIL_DIR) $(FETCHMAIL_BUILD_DIR)
	$(FETCHMAIL_UNZIP) $(DL_DIR)/$(FETCHMAIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(FETCHMAIL_PATCHES) | patch -d $(BUILD_DIR)/$(FETCHMAIL_DIR) -p1
	mv $(BUILD_DIR)/$(FETCHMAIL_DIR) $(FETCHMAIL_BUILD_DIR)
	(cd $(FETCHMAIL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FETCHMAIL_CPPFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(FETCHMAIL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FETCHMAIL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-ssl=$(STAGING_DIR)/opt \
		--without-kerberos5 \
		--without-kerberos \
		--without-hesiod \
		--prefix=/opt \
		--disable-nls \
		--program-prefix= \
	)
ifeq ($(LIBC_STYLE), uclibc)
ifneq ($(OPTWARE_TARGET), wl500g)
	sed -i \
	-e 's|#define HAVE_RESOLV_H 1|#undef HAVE_RESOLV_H|' \
	-e 's|#define HAVE_RES_SEARCH 1|#undef HAVE_RES_SEARCH|' \
		$(FETCHMAIL_BUILD_DIR)/config.h
endif
endif
	touch $(FETCHMAIL_BUILD_DIR)/.configured

fetchmail-unpack: $(FETCHMAIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FETCHMAIL_BUILD_DIR)/.built: $(FETCHMAIL_BUILD_DIR)/.configured
	rm -f $(FETCHMAIL_BUILD_DIR)/.built
	$(MAKE) -C $(FETCHMAIL_BUILD_DIR)
	touch $(FETCHMAIL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
fetchmail: $(FETCHMAIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FETCHMAIL_BUILD_DIR)/.staged: $(FETCHMAIL_BUILD_DIR)/.built
	rm -f $(FETCHMAIL_BUILD_DIR)/.staged
	$(MAKE) -C $(FETCHMAIL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(FETCHMAIL_BUILD_DIR)/.staged

fetchmail-stage: $(FETCHMAIL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fetchmail
#
$(FETCHMAIL_IPK_DIR)/CONTROL/control:
	@install -d $(FETCHMAIL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: fetchmail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FETCHMAIL_PRIORITY)" >>$@
	@echo "Section: $(FETCHMAIL_SECTION)" >>$@
	@echo "Version: $(FETCHMAIL_VERSION)-$(FETCHMAIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FETCHMAIL_MAINTAINER)" >>$@
	@echo "Source: $(FETCHMAIL_SITE)/$(FETCHMAIL_SOURCE)" >>$@
	@echo "Description: $(FETCHMAIL_DESCRIPTION)" >>$@
	@echo "Depends: $(FETCHMAIL_DEPENDS)" >>$@
	@echo "Conflicts: $(FETCHMAIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FETCHMAIL_IPK_DIR)/opt/sbin or $(FETCHMAIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FETCHMAIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FETCHMAIL_IPK_DIR)/opt/etc/fetchmail/...
# Documentation files should be installed in $(FETCHMAIL_IPK_DIR)/opt/doc/fetchmail/...
# Daemon startup scripts should be installed in $(FETCHMAIL_IPK_DIR)/opt/etc/init.d/S??fetchmail
#
# You may need to patch your application to make it use these locations.
#
$(FETCHMAIL_IPK): $(FETCHMAIL_BUILD_DIR)/.built
	rm -rf $(FETCHMAIL_IPK_DIR) $(BUILD_DIR)/fetchmail_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FETCHMAIL_BUILD_DIR) DESTDIR=$(FETCHMAIL_IPK_DIR) install
	$(STRIP_COMMAND) $(FETCHMAIL_IPK_DIR)/opt/bin/fetchmail
	find $(FETCHMAIL_IPK_DIR) -type d -exec chmod go+rx {} \;
	install -d $(FETCHMAIL_IPK_DIR)/opt/etc/
	install -m 600 $(FETCHMAIL_SOURCE_DIR)/fetchmailrc $(FETCHMAIL_IPK_DIR)/opt/etc/fetchmailrc
	install -d $(FETCHMAIL_IPK_DIR)/opt/etc/init.d
	install -m 755 $(FETCHMAIL_SOURCE_DIR)/rc.fetchmail $(FETCHMAIL_IPK_DIR)/opt/etc/init.d/S52fetchmail
	sed -i -e 's|@LOGGING@|${FETCHMAIL_LOGGING}|' $(FETCHMAIL_IPK_DIR)/opt/etc/init.d/S52fetchmail
	$(MAKE) $(FETCHMAIL_IPK_DIR)/CONTROL/control
	install -m 644 $(FETCHMAIL_SOURCE_DIR)/postinst $(FETCHMAIL_IPK_DIR)/CONTROL/postinst
	install -m 644 $(FETCHMAIL_SOURCE_DIR)/prerm $(FETCHMAIL_IPK_DIR)/CONTROL/prerm
	echo $(FETCHMAIL_CONFFILES) | sed -e 's/ /\n/g' > $(FETCHMAIL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FETCHMAIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fetchmail-ipk: $(FETCHMAIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fetchmail-clean:
	-$(MAKE) -C $(FETCHMAIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fetchmail-dirclean:
	rm -rf $(BUILD_DIR)/$(FETCHMAIL_DIR) $(FETCHMAIL_BUILD_DIR) $(FETCHMAIL_IPK_DIR) $(FETCHMAIL_IPK)
#
#
# Some sanity check for the package.
# 
#
fetchmail-check: $(FETCHMAIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FETCHMAIL_IPK)
