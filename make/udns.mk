###########################################################
#
# udns
#
###########################################################

# You must replace "udns" and "UDNS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# UDNS_VERSION, UDNS_SITE and UDNS_SOURCE define
# the upstream location of the source code for the package.
# UDNS_DIR is the directory which is created when the source
# archive is unpacked.
# UDNS_UNZIP is the command used to unzip the source.
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
UDNS_SITE=http://www.corpit.ru/mjt/udns
UDNS_VERSION=0.4
UDNS_SOURCE=udns-$(UDNS_VERSION).tar.gz
UDNS_DIR=udns-$(UDNS_VERSION)
UDNS_UNZIP=zcat
UDNS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UDNS_DESCRIPTION=UDNS is a stub DNS resolver library with ability to perform both syncronous and asyncronous DNS queries.
UDNS_SECTION=util
LIBUDNS_SECTION=lib
UDNS_PRIORITY=optional
UDNS_DEPENDS=libudns
LIBUDNS_DEPENDS=
UDNS_SUGGESTS=
LIBUDNS_SUGGESTS=
UDNS_CONFLICTS=
LIBUDNS_CONFLICTS=

#
# UDNS_IPK_VERSION should be incremented when the ipk changes.
#
UDNS_IPK_VERSION=1

#
# UDNS_CONFFILES should be a list of user-editable files
#UDNS_CONFFILES=/opt/etc/udns.conf /opt/etc/init.d/SXXudns

#
# UDNS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#UDNS_PATCHES=$(UDNS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UDNS_CPPFLAGS=
UDNS_LDFLAGS=

#
# UDNS_BUILD_DIR is the directory in which the build is done.
# UDNS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UDNS_IPK_DIR is the directory in which the ipk is built.
# UDNS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UDNS_BUILD_DIR=$(BUILD_DIR)/udns
UDNS_SOURCE_DIR=$(SOURCE_DIR)/udns

UDNS_IPK_DIR=$(BUILD_DIR)/udns-$(UDNS_VERSION)-ipk
UDNS_IPK=$(BUILD_DIR)/udns_$(UDNS_VERSION)-$(UDNS_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBUDNS_IPK_DIR=$(BUILD_DIR)/libudns-$(UDNS_VERSION)-ipk
LIBUDNS_IPK=$(BUILD_DIR)/libudns_$(UDNS_VERSION)-$(UDNS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: udns-source udns-unpack udns udns-stage udns-ipk udns-clean udns-dirclean udns-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UDNS_SOURCE):
	$(WGET) -P $(@D) $(UDNS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
udns-source: $(DL_DIR)/$(UDNS_SOURCE) $(UDNS_PATCHES)

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
$(UDNS_BUILD_DIR)/.configured: $(DL_DIR)/$(UDNS_SOURCE) $(UDNS_PATCHES) make/udns.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(UDNS_DIR) $(@D)
	$(UDNS_UNZIP) $(DL_DIR)/$(UDNS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UDNS_PATCHES)" ; \
		then cat $(UDNS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(UDNS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UDNS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(UDNS_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UDNS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UDNS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	echo "#define HAVE_GETOPT 1" > $(@D)/config.h
	echo "#define HAVE_INET_PTON_NTOP 1" >> $(@D)/config.h
ifeq ($(IPV6), yes)
	echo "#define HAVE_IPv6 1" >> $(@D)/config.h
endif
	echo "#define HAVE_POLL 1" >> $(@D)/config.h
	sed -e 's|@CC@|$(TARGET_CC)|' -e 's|@CFLAGS@|$(STAGING_CPPFLAGS) $(UDNS_CPPFLAGS)|' \
	    -e 's|@CDEFS@|-DHAVE_CONFIG_H|' -e 's|@LD@|\$$(CC)|' -e 's|@LDFLAGS@|$(STAGING_LDFLAGS) $(UDNS_LDFLAGS)|' \
	    -e 's|@LIBS@||' -e 's|@LDSHARED@|\$$(LD) -shared|' $(@D)/Makefile.in > $(@D)/Makefile
	touch $@

udns-unpack: $(UDNS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UDNS_BUILD_DIR)/.built: $(UDNS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) shared
	touch $@

#
# This is the build convenience target.
#
udns: $(UDNS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UDNS_BUILD_DIR)/.staged: $(UDNS_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	$(INSTALL) -d $(STAGING_LIB_DIR) $(STAGING_INCLUDE_DIR)
	cp -af $(@D)/libudns*.so* $(STAGING_LIB_DIR)
	cp -f $(@D)/udns.h $(STAGING_INCLUDE_DIR)
	touch $@

libudns-stage udns-stage: $(UDNS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/udns
#
$(UDNS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: udns" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UDNS_PRIORITY)" >>$@
	@echo "Section: $(UDNS_SECTION)" >>$@
	@echo "Version: $(UDNS_VERSION)-$(UDNS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UDNS_MAINTAINER)" >>$@
	@echo "Source: $(UDNS_SITE)/$(UDNS_SOURCE)" >>$@
	@echo "Description: $(UDNS_DESCRIPTION)" >>$@
	@echo "Depends: $(UDNS_DEPENDS)" >>$@
	@echo "Suggests: $(UDNS_SUGGESTS)" >>$@
	@echo "Conflicts: $(UDNS_CONFLICTS)" >>$@

$(LIBUDNS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libudns" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UDNS_PRIORITY)" >>$@
	@echo "Section: $(LIBUDNS_SECTION)" >>$@
	@echo "Version: $(UDNS_VERSION)-$(UDNS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UDNS_MAINTAINER)" >>$@
	@echo "Source: $(UDNS_SITE)/$(UDNS_SOURCE)" >>$@
	@echo "Description: $(UDNS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBUDNS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBUDNS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBUDNS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UDNS_IPK_DIR)/opt/sbin or $(UDNS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UDNS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UDNS_IPK_DIR)/opt/etc/udns/...
# Documentation files should be installed in $(UDNS_IPK_DIR)/opt/doc/udns/...
# Daemon startup scripts should be installed in $(UDNS_IPK_DIR)/opt/etc/init.d/S??udns
#
# You may need to patch your application to make it use these locations.
#
$(UDNS_IPK): $(UDNS_BUILD_DIR)/.built
	rm -rf $(UDNS_IPK_DIR) $(BUILD_DIR)/udns_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(UDNS_IPK_DIR)/opt/bin
	for app in dnsget ex-rdns rblcheck; do \
		$(INSTALL) -m 755 $(UDNS_BUILD_DIR)/$${app}_s $(UDNS_IPK_DIR)/opt/bin/$${app}; \
		$(STRIP_COMMAND) $(UDNS_IPK_DIR)/opt/bin/$${app}; \
	done
#	$(MAKE) -C $(UDNS_BUILD_DIR) DESTDIR=$(UDNS_IPK_DIR) install-strip
#	$(INSTALL) -d $(UDNS_IPK_DIR)/opt/etc/
#	$(INSTALL) -m 644 $(UDNS_SOURCE_DIR)/udns.conf $(UDNS_IPK_DIR)/opt/etc/udns.conf
#	$(INSTALL) -d $(UDNS_IPK_DIR)/opt/etc/init.d
#	$(INSTALL) -m 755 $(UDNS_SOURCE_DIR)/rc.udns $(UDNS_IPK_DIR)/opt/etc/init.d/SXXudns
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UDNS_IPK_DIR)/opt/etc/init.d/SXXudns
	$(MAKE) $(UDNS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(UDNS_SOURCE_DIR)/postinst $(UDNS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UDNS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(UDNS_SOURCE_DIR)/prerm $(UDNS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UDNS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(UDNS_IPK_DIR)/CONTROL/postinst $(UDNS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(UDNS_CONFFILES) | sed -e 's/ /\n/g' > $(UDNS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UDNS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(UDNS_IPK_DIR)

$(LIBUDNS_IPK): $(UDNS_BUILD_DIR)/.built
	rm -rf $(LIBUDNS_IPK_DIR) $(BUILD_DIR)/libudns_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(LIBUDNS_IPK_DIR)/opt/lib $(LIBUDNS_IPK_DIR)/opt/include
	cp -af $(UDNS_BUILD_DIR)/libudns*.so* $(LIBUDNS_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(LIBUDNS_IPK_DIR)/opt/lib/libudns.so.0
	cp -f $(UDNS_BUILD_DIR)/udns.h $(LIBUDNS_IPK_DIR)/opt/include
#	$(MAKE) -C $(UDNS_BUILD_DIR) DESTDIR=$(UDNS_IPK_DIR) install-strip
#	$(INSTALL) -d $(UDNS_IPK_DIR)/opt/etc/
#	$(INSTALL) -m 644 $(UDNS_SOURCE_DIR)/udns.conf $(UDNS_IPK_DIR)/opt/etc/udns.conf
#	$(INSTALL) -d $(UDNS_IPK_DIR)/opt/etc/init.d
#	$(INSTALL) -m 755 $(UDNS_SOURCE_DIR)/rc.udns $(UDNS_IPK_DIR)/opt/etc/init.d/SXXudns
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UDNS_IPK_DIR)/opt/etc/init.d/SXXudns
	$(MAKE) $(LIBUDNS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(UDNS_SOURCE_DIR)/postinst $(UDNS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UDNS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(UDNS_SOURCE_DIR)/prerm $(UDNS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UDNS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(UDNS_IPK_DIR)/CONTROL/postinst $(UDNS_IPK_DIR)/CONTROL/prerm; \
	fi
#	echo $(UDNS_CONFFILES) | sed -e 's/ /\n/g' > $(UDNS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBUDNS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBUDNS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
udns-ipk: $(UDNS_IPK) $(LIBUDNS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
udns-clean:
	rm -f $(UDNS_BUILD_DIR)/.built
	-$(MAKE) -C $(UDNS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
udns-dirclean:
	rm -rf $(BUILD_DIR)/$(UDNS_DIR) $(UDNS_BUILD_DIR) \
	$(UDNS_IPK_DIR) $(UDNS_IPK) \
	$(LIBUDNS_IPK_DIR) $(LIBUDNS_IPK)
#
#
# Some sanity check for the package.
#
udns-check: $(UDNS_IPK) $(LIBUDNS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
