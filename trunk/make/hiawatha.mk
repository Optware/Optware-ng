###########################################################
#
# hiawatha
#
###########################################################
#
# HIAWATHA_VERSION, HIAWATHA_SITE and HIAWATHA_SOURCE define
# the upstream location of the source code for the package.
# HIAWATHA_DIR is the directory which is created when the source
# archive is unpacked.
# HIAWATHA_UNZIP is the command used to unzip the source.
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
HIAWATHA_SITE=http://www.hiawatha-webserver.org/files
HIAWATHA_VERSION=6.12
HIAWATHA_SOURCE=hiawatha-$(HIAWATHA_VERSION).tar.gz
HIAWATHA_DIR=hiawatha-$(HIAWATHA_VERSION)
HIAWATHA_UNZIP=zcat
HIAWATHA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HIAWATHA_DESCRIPTION=Hiawatha is a webserver for Unix with 'being secure' as its main goal.
HIAWATHA_SECTION=web
HIAWATHA_PRIORITY=optional
HIAWATHA_DEPENDS=openssl
HIAWATHA_SUGGESTS=
HIAWATHA_CONFLICTS=

#
# HIAWATHA_IPK_VERSION should be incremented when the ipk changes.
#
HIAWATHA_IPK_VERSION=1

#
# HIAWATHA_CONFFILES should be a list of user-editable files
HIAWATHA_CONFFILES=\
/opt/etc/hiawatha/mimetype.conf \
/opt/etc/hiawatha/httpd.conf \
/opt/etc/hiawatha/php-fcgi.conf \
/opt/etc/hiawatha/cgi-wrapper.conf \

#
# HIAWATHA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#HIAWATHA_PATCHES=$(HIAWATHA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HIAWATHA_CPPFLAGS=
HIAWATHA_LDFLAGS=

#
# HIAWATHA_BUILD_DIR is the directory in which the build is done.
# HIAWATHA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HIAWATHA_IPK_DIR is the directory in which the ipk is built.
# HIAWATHA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HIAWATHA_BUILD_DIR=$(BUILD_DIR)/hiawatha
HIAWATHA_SOURCE_DIR=$(SOURCE_DIR)/hiawatha
HIAWATHA_IPK_DIR=$(BUILD_DIR)/hiawatha-$(HIAWATHA_VERSION)-ipk
HIAWATHA_IPK=$(BUILD_DIR)/hiawatha_$(HIAWATHA_VERSION)-$(HIAWATHA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: hiawatha-source hiawatha-unpack hiawatha hiawatha-stage hiawatha-ipk hiawatha-clean hiawatha-dirclean hiawatha-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HIAWATHA_SOURCE):
	$(WGET) -P $(@D) $(HIAWATHA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hiawatha-source: $(DL_DIR)/$(HIAWATHA_SOURCE) $(HIAWATHA_PATCHES)

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
$(HIAWATHA_BUILD_DIR)/.configured: $(DL_DIR)/$(HIAWATHA_SOURCE) $(HIAWATHA_PATCHES) make/hiawatha.mk
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(HIAWATHA_DIR) $(@D)
	$(HIAWATHA_UNZIP) $(DL_DIR)/$(HIAWATHA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HIAWATHA_PATCHES)" ; \
		then cat $(HIAWATHA_PATCHES) | \
		patch -d $(BUILD_DIR)/$(HIAWATHA_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HIAWATHA_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(HIAWATHA_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HIAWATHA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HIAWATHA_LDFLAGS)" \
		ac_cv_file__dev_urandom=/dev/urandom \
		webrootdir=/opt/share/www/hiawatha \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

hiawatha-unpack: $(HIAWATHA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HIAWATHA_BUILD_DIR)/.built: $(HIAWATHA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
hiawatha: $(HIAWATHA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HIAWATHA_BUILD_DIR)/.staged: $(HIAWATHA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

hiawatha-stage: $(HIAWATHA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hiawatha
#
$(HIAWATHA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: hiawatha" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HIAWATHA_PRIORITY)" >>$@
	@echo "Section: $(HIAWATHA_SECTION)" >>$@
	@echo "Version: $(HIAWATHA_VERSION)-$(HIAWATHA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HIAWATHA_MAINTAINER)" >>$@
	@echo "Source: $(HIAWATHA_SITE)/$(HIAWATHA_SOURCE)" >>$@
	@echo "Description: $(HIAWATHA_DESCRIPTION)" >>$@
	@echo "Depends: $(HIAWATHA_DEPENDS)" >>$@
	@echo "Suggests: $(HIAWATHA_SUGGESTS)" >>$@
	@echo "Conflicts: $(HIAWATHA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HIAWATHA_IPK_DIR)/opt/sbin or $(HIAWATHA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HIAWATHA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HIAWATHA_IPK_DIR)/opt/etc/hiawatha/...
# Documentation files should be installed in $(HIAWATHA_IPK_DIR)/opt/doc/hiawatha/...
# Daemon startup scripts should be installed in $(HIAWATHA_IPK_DIR)/opt/etc/init.d/S??hiawatha
#
# You may need to patch your application to make it use these locations.
#
$(HIAWATHA_IPK): $(HIAWATHA_BUILD_DIR)/.built
	rm -rf $(HIAWATHA_IPK_DIR) $(BUILD_DIR)/hiawatha_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HIAWATHA_BUILD_DIR) DESTDIR=$(HIAWATHA_IPK_DIR) transform='' install-strip
#	install -d $(HIAWATHA_IPK_DIR)/opt/etc/
#	install -m 644 $(HIAWATHA_SOURCE_DIR)/hiawatha.conf $(HIAWATHA_IPK_DIR)/opt/etc/hiawatha.conf
#	install -d $(HIAWATHA_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(HIAWATHA_SOURCE_DIR)/rc.hiawatha $(HIAWATHA_IPK_DIR)/opt/etc/init.d/SXXhiawatha
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HIAWATHA_IPK_DIR)/opt/etc/init.d/SXXhiawatha
	$(MAKE) $(HIAWATHA_IPK_DIR)/CONTROL/control
#	install -m 755 $(HIAWATHA_SOURCE_DIR)/postinst $(HIAWATHA_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HIAWATHA_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(HIAWATHA_SOURCE_DIR)/prerm $(HIAWATHA_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HIAWATHA_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(HIAWATHA_IPK_DIR)/CONTROL/postinst $(HIAWATHA_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(HIAWATHA_CONFFILES) | sed -e 's/ /\n/g' > $(HIAWATHA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HIAWATHA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
hiawatha-ipk: $(HIAWATHA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hiawatha-clean:
	rm -f $(HIAWATHA_BUILD_DIR)/.built
	-$(MAKE) -C $(HIAWATHA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hiawatha-dirclean:
	rm -rf $(BUILD_DIR)/$(HIAWATHA_DIR) $(HIAWATHA_BUILD_DIR) $(HIAWATHA_IPK_DIR) $(HIAWATHA_IPK)
#
#
# Some sanity check for the package.
#
hiawatha-check: $(HIAWATHA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
