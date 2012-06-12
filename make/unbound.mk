###########################################################
#
# unbound
#
###########################################################

# You must replace "unbound" and "UNBOUND" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# UNBOUND_VERSION, UNBOUND_SITE and UNBOUND_SOURCE define
# the upstream location of the source code for the package.
# UNBOUND_DIR is the directory which is created when the source
# archive is unpacked.
# UNBOUND_UNZIP is the command used to unzip the source.
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
UNBOUND_SITE=http://unbound.net/downloads
UNBOUND_VERSION=1.4.17
UNBOUND_SOURCE=unbound-$(UNBOUND_VERSION).tar.gz
UNBOUND_DIR=unbound-$(UNBOUND_VERSION)
UNBOUND_UNZIP=zcat
UNBOUND_MAINTAINER=Bob Novas <bob@shinkuro.com>
UNBOUND_DESCRIPTION=A validating recursive resolver.
UNBOUND_SECTION=net
UNBOUND_PRIORITY=optional
UNBOUND_DEPENDS=zlib,openssl,ldns,expat
UNBOUND_SUGGESTS=
UNBOUND_CONFLICTS=

#
# UNBOUND_IPK_VERSION should be incremented when the ipk changes.
#
UNBOUND_IPK_VERSION=1

#
# UNBOUND_CONFFILES should be a list of user-editable files
UNBOUND_CONFFILES=/opt/etc/unbound/unbound.conf

#
# UNBOUND_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#UNBOUND_PATCHES=$(UNBOUND_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UNBOUND_CPPFLAGS=-Os
UNBOUND_LDFLAGS=

#
# UNBOUND_BUILD_DIR is the directory in which the build is done.
# UNBOUND_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UNBOUND_IPK_DIR is the directory in which the ipk is built.
# UNBOUND_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UNBOUND_BUILD_DIR=$(BUILD_DIR)/unbound
UNBOUND_SOURCE_DIR=$(SOURCE_DIR)/unbound
UNBOUND_IPK_DIR=$(BUILD_DIR)/unbound-$(UNBOUND_VERSION)-ipk
UNBOUND_IPK=$(BUILD_DIR)/unbound_$(UNBOUND_VERSION)-$(UNBOUND_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: unbound-source unbound-unpack unbound unbound-stage unbound-ipk unbound-clean unbound-dirclean unbound-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UNBOUND_SOURCE):
	$(WGET) -P $(@D) $(UNBOUND_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
unbound-source: $(DL_DIR)/$(UNBOUND_SOURCE) $(UNBOUND_PATCHES)

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
$(UNBOUND_BUILD_DIR)/.configured: $(DL_DIR)/$(UNBOUND_SOURCE) $(UNBOUND_PATCHES) make/unbound.mk
	$(MAKE) zlib-stage
	$(MAKE) OPENSSL_VERSION=1.0.1 openssl-stage
	$(MAKE) ldns-stage
	$(MAKE) expat-stage
	rm -rf $(BUILD_DIR)/$(UNBOUND_DIR) $(@D)
	$(UNBOUND_UNZIP) $(DL_DIR)/$(UNBOUND_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UNBOUND_PATCHES)" ; \
		then cat $(UNBOUND_PATCHES) | \
		patch -d $(BUILD_DIR)/$(UNBOUND_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UNBOUND_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(UNBOUND_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UNBOUND_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UNBOUND_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-ssl=$(STAGING_PREFIX) \
		--enable-allsymbols \
		--without-pthreads \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

unbound-unpack: $(UNBOUND_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UNBOUND_BUILD_DIR)/.built: $(UNBOUND_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
unbound: $(UNBOUND_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UNBOUND_BUILD_DIR)/.staged: $(UNBOUND_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

unbound-stage: $(UNBOUND_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/unbound
#
$(UNBOUND_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: unbound" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UNBOUND_PRIORITY)" >>$@
	@echo "Section: $(UNBOUND_SECTION)" >>$@
	@echo "Version: $(UNBOUND_VERSION)-$(UNBOUND_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UNBOUND_MAINTAINER)" >>$@
	@echo "Source: $(UNBOUND_SITE)/$(UNBOUND_SOURCE)" >>$@
	@echo "Description: $(UNBOUND_DESCRIPTION)" >>$@
	@echo "Depends: $(UNBOUND_DEPENDS)" >>$@
	@echo "Suggests: $(UNBOUND_SUGGESTS)" >>$@
	@echo "Conflicts: $(UNBOUND_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UNBOUND_IPK_DIR)/opt/sbin or $(UNBOUND_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UNBOUND_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UNBOUND_IPK_DIR)/opt/etc/unbound/...
# Documentation files should be installed in $(UNBOUND_IPK_DIR)/opt/doc/unbound/...
# Daemon startup scripts should be installed in $(UNBOUND_IPK_DIR)/opt/etc/init.d/S??unbound
#
# You may need to patch your application to make it use these locations.
#
$(UNBOUND_IPK): $(UNBOUND_BUILD_DIR)/.built
	rm -rf $(UNBOUND_IPK_DIR) $(BUILD_DIR)/unbound_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(UNBOUND_BUILD_DIR) DESTDIR=$(UNBOUND_IPK_DIR) install
	install -d $(UNBOUND_IPK_DIR)/opt/etc/
	install -m 644 $(UNBOUND_SOURCE_DIR)/named.cache $(UNBOUND_IPK_DIR)/opt/etc/unbound/named.cache
	install -m 644 $(UNBOUND_SOURCE_DIR)/root.key $(UNBOUND_IPK_DIR)/opt/etc/unbound/root.key
	install -d $(UNBOUND_IPK_DIR)/opt/var/unbound
	install -m 755 $(UNBOUND_SOURCE_DIR)/start.sh $(UNBOUND_IPK_DIR)/opt/var/unbound/start.sh
	install -d $(UNBOUND_IPK_DIR)/opt/usr/lib
	cd $(UNBOUND_IPK_DIR)/opt/usr/lib; ln -s libldns.so.1.6.12 libldns.so.1
	$(STRIP_COMMAND) \
		$(UNBOUND_IPK_DIR)/opt/sbin/unbound \
		$(UNBOUND_IPK_DIR)/opt/sbin/unbound-anchor \
		$(UNBOUND_IPK_DIR)/opt/sbin/unbound-checkconf \
		$(UNBOUND_IPK_DIR)/opt/sbin/unbound-control \
		$(UNBOUND_IPK_DIR)/opt/sbin/unbound-host
	$(STRIP_COMMAND) \
		$(UNBOUND_IPK_DIR)/opt/lib/libunbound.so.2.1.1
	$(MAKE) $(UNBOUND_IPK_DIR)/CONTROL/control
#	install -m 755 $(UNBOUND_SOURCE_DIR)/postinst $(UNBOUND_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UNBOUND_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(UNBOUND_SOURCE_DIR)/prerm $(UNBOUND_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UNBOUND_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
#		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
#			$(UNBOUND_IPK_DIR)/CONTROL/postinst $(UNBOUND_IPK_DIR)/CONTROL/prerm; \
#	fi
	$(MAKE) $(UNBOUND_IPK_DIR)/opt/sbin
	echo $(UNBOUND_CONFFILES) | sed -e 's/ /\n/g' > $(UNBOUND_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNBOUND_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(UNBOUND_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
unbound-ipk: $(UNBOUND_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
unbound-clean:
	rm -f $(UNBOUND_BUILD_DIR)/.built
	-$(MAKE) -C $(UNBOUND_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
unbound-dirclean:
	rm -rf $(BUILD_DIR)/$(UNBOUND_DIR) $(UNBOUND_BUILD_DIR) $(UNBOUND_IPK_DIR) $(UNBOUND_IPK)
#
#
# Some sanity check for the package.
#
unbound-check: $(UNBOUND_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
