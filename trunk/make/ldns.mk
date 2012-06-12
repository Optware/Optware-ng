###########################################################
#
# ldns
#
###########################################################

# You must replace "ldns" and "LDNS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LDNS_VERSION, LDNS_SITE and LDNS_SOURCE define
# the upstream location of the source code for the package.
# LDNS_DIR is the directory which is created when the source
# archive is unpacked.
# LDNS_UNZIP is the command used to unzip the source.
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
LDNS_SITE=http://nlnetlabs.nl/downloads/ldns/
LDNS_VERSION=1.6.13
LDNS_SOURCE=ldns-$(LDNS_VERSION).tar.gz
LDNS_DIR=ldns-$(LDNS_VERSION)
LDNS_UNZIP=zcat
LDNS_MAINTAINER=Bob Novas <bob@shinkuro.com>
LDNS_DESCRIPTION=Describe ldns here.
LDNS_SECTION=net
LDNS_PRIORITY=optional
LDNS_DEPENDS=openssl
LDNS_SUGGESTS=
LDNS_CONFLICTS=

#
# LDNS_IPK_VERSION should be incremented when the ipk changes.
#
LDNS_IPK_VERSION=1

#
# LDNS_CONFFILES should be a list of user-editable files
#LDNS_CONFFILES=/opt/etc/ldns.conf /opt/etc/init.d/SXXldns

#
# LDNS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LDNS_PATCHES=$(LDNS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LDNS_CPPFLAGS=-g -O2
LDNS_LDFLAGS=-L/home/bob/Documents/Code/Optware/optware/ddwrt/staging/opt/lib

#
# LDNS_BUILD_DIR is the directory in which the build is done.
# LDNS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LDNS_IPK_DIR is the directory in which the ipk is built.
# LDNS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LDNS_BUILD_DIR=$(BUILD_DIR)/ldns
LDNS_SOURCE_DIR=$(SOURCE_DIR)/ldns
LDNS_IPK_DIR=$(BUILD_DIR)/ldns-$(LDNS_VERSION)-ipk
LDNS_IPK=$(BUILD_DIR)/ldns_$(LDNS_VERSION)-$(LDNS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ldns-source ldns-unpack ldns ldns-stage ldns-ipk ldns-clean ldns-dirclean ldns-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LDNS_SOURCE):
	$(WGET) -P $(@D) $(LDNS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ldns-source: $(DL_DIR)/$(LDNS_SOURCE) $(LDNS_PATCHES)

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
$(LDNS_BUILD_DIR)/.configured: $(DL_DIR)/$(LDNS_SOURCE) $(LDNS_PATCHES) make/ldns.mk
	$(MAKE) OPENSSL_VERSION=1.0.1 openssl-stage
	rm -rf $(BUILD_DIR)/$(LDNS_DIR) $(@D)
	$(LDNS_UNZIP) $(DL_DIR)/$(LDNS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LDNS_PATCHES)" ; \
		then cat $(LDNS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LDNS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LDNS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LDNS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LDNS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LDNS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-ssl=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

ldns-unpack: $(LDNS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LDNS_BUILD_DIR)/.built: $(LDNS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ldns: $(LDNS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LDNS_BUILD_DIR)/.staged: $(LDNS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ldns-stage: $(LDNS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ldns
#
$(LDNS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ldns" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LDNS_PRIORITY)" >>$@
	@echo "Section: $(LDNS_SECTION)" >>$@
	@echo "Version: $(LDNS_VERSION)-$(LDNS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LDNS_MAINTAINER)" >>$@
	@echo "Source: $(LDNS_SITE)/$(LDNS_SOURCE)" >>$@
	@echo "Description: $(LDNS_DESCRIPTION)" >>$@
	@echo "Depends: $(LDNS_DEPENDS)" >>$@
	@echo "Suggests: $(LDNS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LDNS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LDNS_IPK_DIR)/opt/sbin or $(LDNS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LDNS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LDNS_IPK_DIR)/opt/etc/ldns/...
# Documentation files should be installed in $(LDNS_IPK_DIR)/opt/doc/ldns/...
# Daemon startup scripts should be installed in $(LDNS_IPK_DIR)/opt/etc/init.d/S??ldns
#
# You may need to patch your application to make it use these locations.
#
$(LDNS_IPK): $(LDNS_BUILD_DIR)/.built
	rm -rf $(LDNS_IPK_DIR) $(BUILD_DIR)/ldns_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LDNS_BUILD_DIR) DESTDIR=$(LDNS_IPK_DIR) install
	$(STRIP_COMMAND) $(LDNS_IPK_DIR)/opt/lib/libldns.so.1.6.12
#	install -d $(LDNS_IPK_DIR)/opt/etc/
#	install -m 644 $(LDNS_SOURCE_DIR)/ldns.conf $(LDNS_IPK_DIR)/opt/etc/ldns.conf
#	install -d $(LDNS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LDNS_SOURCE_DIR)/rc.ldns $(LDNS_IPK_DIR)/opt/etc/init.d/SXXldns
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LDNS_IPK_DIR)/opt/etc/init.d/SXXldns
	$(MAKE) $(LDNS_IPK_DIR)/CONTROL/control
#	install -m 755 $(LDNS_SOURCE_DIR)/postinst $(LDNS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LDNS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LDNS_SOURCE_DIR)/prerm $(LDNS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LDNS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LDNS_IPK_DIR)/CONTROL/postinst $(LDNS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LDNS_CONFFILES) | sed -e 's/ /\n/g' > $(LDNS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LDNS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LDNS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ldns-ipk: $(LDNS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ldns-clean:
	rm -f $(LDNS_BUILD_DIR)/.built
	-$(MAKE) -C $(LDNS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ldns-dirclean:
	rm -rf $(BUILD_DIR)/$(LDNS_DIR) $(LDNS_BUILD_DIR) $(LDNS_IPK_DIR) $(LDNS_IPK)
#
#
# Some sanity check for the package.
#
ldns-check: $(LDNS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
