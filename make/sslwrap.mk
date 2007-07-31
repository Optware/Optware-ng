###########################################################
#
# sslwrap
#
###########################################################
#
# SSLWRAP_VERSION, SSLWRAP_SITE and SSLWRAP_SOURCE define
# the upstream location of the source code for the package.
# SSLWRAP_DIR is the directory which is created when the source
# archive is unpacked.
# SSLWRAP_UNZIP is the command used to unzip the source.
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
SSLWRAP_SITE=http://www.rickk.com/sslwrap
SSLWRAP_VERSION=206
SSLWRAP_SOURCE=sslwrap.tar.gz
SSLWRAP_DIR=sslwrap$(SSLWRAP_VERSION)
SSLWRAP_UNZIP=zcat
SSLWRAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SSLWRAP_DESCRIPTION=sslwrap is a simple Unix service that sits over any simple TCP service such as POP3, IMAP, SMTP, and encrypts all of the data on the connection using TLS/SSL.
SSLWRAP_SECTION=net
SSLWRAP_PRIORITY=optional
SSLWRAP_DEPENDS=openssl
SSLWRAP_SUGGESTS=
SSLWRAP_CONFLICTS=

#
# SSLWRAP_IPK_VERSION should be incremented when the ipk changes.
#
SSLWRAP_IPK_VERSION=1

#
# SSLWRAP_CONFFILES should be a list of user-editable files
#SSLWRAP_CONFFILES=/opt/etc/sslwrap.conf /opt/etc/init.d/SXXsslwrap

#
# SSLWRAP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SSLWRAP_PATCHES=$(SSLWRAP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SSLWRAP_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/openssl
SSLWRAP_LDFLAGS=

#
# SSLWRAP_BUILD_DIR is the directory in which the build is done.
# SSLWRAP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SSLWRAP_IPK_DIR is the directory in which the ipk is built.
# SSLWRAP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SSLWRAP_BUILD_DIR=$(BUILD_DIR)/sslwrap
SSLWRAP_SOURCE_DIR=$(SOURCE_DIR)/sslwrap
SSLWRAP_IPK_DIR=$(BUILD_DIR)/sslwrap-$(SSLWRAP_VERSION)-ipk
SSLWRAP_IPK=$(BUILD_DIR)/sslwrap_$(SSLWRAP_VERSION)-$(SSLWRAP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sslwrap-source sslwrap-unpack sslwrap sslwrap-stage sslwrap-ipk sslwrap-clean sslwrap-dirclean sslwrap-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SSLWRAP_SOURCE):
	$(WGET) -P $(DL_DIR) $(SSLWRAP_SITE)/$(SSLWRAP_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SSLWRAP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sslwrap-source: $(DL_DIR)/$(SSLWRAP_SOURCE) $(SSLWRAP_PATCHES)

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
$(SSLWRAP_BUILD_DIR)/.configured: $(DL_DIR)/$(SSLWRAP_SOURCE) $(SSLWRAP_PATCHES) make/sslwrap.mk
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(SSLWRAP_DIR) $(SSLWRAP_BUILD_DIR)
	$(SSLWRAP_UNZIP) $(DL_DIR)/$(SSLWRAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SSLWRAP_PATCHES)" ; \
		then cat $(SSLWRAP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SSLWRAP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SSLWRAP_DIR)" != "$(SSLWRAP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SSLWRAP_DIR) $(SSLWRAP_BUILD_DIR) ; \
	fi
	sed -i -e 's|gcc |$$(CC) |' \
	       -e 's|-L/usr/local/ssl/lib |$$(LDFLAGS) |' \
	       -e 's|-I/usr/local/ssl/include |$$(CPPFLAGS) |' \
	       $(SSLWRAP_BUILD_DIR)/Makefile;
	sed -i -e 's/SSL_OP_NON_EXPORT_FIRST/SSL_OP_CIPHER_SERVER_PREFERENCE/g' \
		$(SSLWRAP_BUILD_DIR)/s_server.c
#	(cd $(SSLWRAP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SSLWRAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SSLWRAP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(SSLWRAP_BUILD_DIR)/libtool
	touch $@

sslwrap-unpack: $(SSLWRAP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SSLWRAP_BUILD_DIR)/.built: $(SSLWRAP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SSLWRAP_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SSLWRAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SSLWRAP_LDFLAGS)" \
		OPENSSL="" \
		;
	touch $@

#
# This is the build convenience target.
#
sslwrap: $(SSLWRAP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SSLWRAP_BUILD_DIR)/.staged: $(SSLWRAP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SSLWRAP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

sslwrap-stage: $(SSLWRAP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sslwrap
#
$(SSLWRAP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sslwrap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SSLWRAP_PRIORITY)" >>$@
	@echo "Section: $(SSLWRAP_SECTION)" >>$@
	@echo "Version: $(SSLWRAP_VERSION)-$(SSLWRAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SSLWRAP_MAINTAINER)" >>$@
	@echo "Source: $(SSLWRAP_SITE)/$(SSLWRAP_SOURCE)" >>$@
	@echo "Description: $(SSLWRAP_DESCRIPTION)" >>$@
	@echo "Depends: $(SSLWRAP_DEPENDS)" >>$@
	@echo "Suggests: $(SSLWRAP_SUGGESTS)" >>$@
	@echo "Conflicts: $(SSLWRAP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SSLWRAP_IPK_DIR)/opt/sbin or $(SSLWRAP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SSLWRAP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SSLWRAP_IPK_DIR)/opt/etc/sslwrap/...
# Documentation files should be installed in $(SSLWRAP_IPK_DIR)/opt/doc/sslwrap/...
# Daemon startup scripts should be installed in $(SSLWRAP_IPK_DIR)/opt/etc/init.d/S??sslwrap
#
# You may need to patch your application to make it use these locations.
#
$(SSLWRAP_IPK): $(SSLWRAP_BUILD_DIR)/.built
	rm -rf $(SSLWRAP_IPK_DIR) $(BUILD_DIR)/sslwrap_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(SSLWRAP_BUILD_DIR) DESTDIR=$(SSLWRAP_IPK_DIR) install-strip
	install -d $(SSLWRAP_IPK_DIR)/opt/bin
	install -m 755 $(SSLWRAP_BUILD_DIR)/sslwrap $(SSLWRAP_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(SSLWRAP_IPK_DIR)/opt/bin/sslwrap
#	install -m 644 $(SSLWRAP_SOURCE_DIR)/sslwrap.conf $(SSLWRAP_IPK_DIR)/opt/etc/sslwrap.conf
#	install -d $(SSLWRAP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SSLWRAP_SOURCE_DIR)/rc.sslwrap $(SSLWRAP_IPK_DIR)/opt/etc/init.d/SXXsslwrap
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SSLWRAP_IPK_DIR)/opt/etc/init.d/SXXsslwrap
	$(MAKE) $(SSLWRAP_IPK_DIR)/CONTROL/control
#	install -m 755 $(SSLWRAP_SOURCE_DIR)/postinst $(SSLWRAP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SSLWRAP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SSLWRAP_SOURCE_DIR)/prerm $(SSLWRAP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SSLWRAP_IPK_DIR)/CONTROL/prerm
	echo $(SSLWRAP_CONFFILES) | sed -e 's/ /\n/g' > $(SSLWRAP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SSLWRAP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sslwrap-ipk: $(SSLWRAP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sslwrap-clean:
	rm -f $(SSLWRAP_BUILD_DIR)/.built
	-$(MAKE) -C $(SSLWRAP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sslwrap-dirclean:
	rm -rf $(BUILD_DIR)/$(SSLWRAP_DIR) $(SSLWRAP_BUILD_DIR) $(SSLWRAP_IPK_DIR) $(SSLWRAP_IPK)
#
#
# Some sanity check for the package.
#
sslwrap-check: $(SSLWRAP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SSLWRAP_IPK)
