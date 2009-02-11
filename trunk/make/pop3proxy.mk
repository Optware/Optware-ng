###########################################################
#
# pop3proxy
#
###########################################################

# You must replace "pop3proxy" and "POP3PROXY" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# POP3PROXY_VERSION, POP3PROXY_SITE and POP3PROXY_SOURCE define
# the upstream location of the source code for the package.
# POP3PROXY_DIR is the directory which is created when the source
# archive is unpacked.
# POP3PROXY_UNZIP is the command used to unzip the source.
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
POP3PROXY_SITE=http://www.quietsche-entchen.de/download
POP3PROXY_VERSION=2.0.0-beta8
POP3PROXY_SOURCE=pop3proxy-$(POP3PROXY_VERSION).tar.gz
POP3PROXY_DIR=pop3proxy-$(POP3PROXY_VERSION)
POP3PROXY_UNZIP=zcat
POP3PROXY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
POP3PROXY_DESCRIPTION=A pop3 proxy server
POP3PROXY_SECTION=net
POP3PROXY_PRIORITY=optional
POP3PROXY_DEPENDS=glib, xinetd
POP3PROXY_SUGGESTS=
POP3PROXY_CONFLICTS=any mail retrieval agent/server using the pop3 port 110

#
# POP3PROXY_IPK_VERSION should be incremented when the ipk changes.
#
POP3PROXY_IPK_VERSION=1

#
# POP3PROXY_CONFFILES should be a list of user-editable files
POP3PROXY_CONFFILES=/opt/etc/xinetd.d/pop3proxy

#
# POP3PROXY_PATCHES should list any patches, in the order in
# which they should be applied to the source code.
#
POP3PROXY_PATCHES=\
		$(POP3PROXY_SOURCE_DIR)/clamav.c.patch \
		$(POP3PROXY_SOURCE_DIR)/pop3.c.patch \
		$(POP3PROXY_SOURCE_DIR)/pop3.h.patch \
		$(POP3PROXY_SOURCE_DIR)/pop3.proxy.1.patch \
		$(POP3PROXY_SOURCE_DIR)/procinfo.c.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
POP3PROXY_CPPFLAGS=
POP3PROXY_LDFLAGS=

#
# POP3PROXY_BUILD_DIR is the directory in which the build is done.
# POP3PROXY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# POP3PROXY_IPK_DIR is the directory in which the ipk is built.
# POP3PROXY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
POP3PROXY_BUILD_DIR=$(BUILD_DIR)/pop3proxy
POP3PROXY_SOURCE_DIR=$(SOURCE_DIR)/pop3proxy
POP3PROXY_IPK_DIR=$(BUILD_DIR)/pop3proxy-$(POP3PROXY_VERSION)-ipk
POP3PROXY_IPK=$(BUILD_DIR)/pop3proxy_$(POP3PROXY_VERSION)-$(POP3PROXY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pop3proxy-source pop3proxy-unpack pop3proxy pop3proxy-stage pop3proxy-ipk pop3proxy-clean pop3proxy-dirclean pop3proxy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(POP3PROXY_SOURCE):
	$(WGET) -P $(@D) $(POP3PROXY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pop3proxy-source: $(DL_DIR)/$(POP3PROXY_SOURCE) $(POP3PROXY_PATCHES)

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
$(POP3PROXY_BUILD_DIR)/.configured: $(DL_DIR)/$(POP3PROXY_SOURCE) $(POP3PROXY_PATCHES) make/pop3proxy.mk
#	$(MAKE) glib-stage
	rm -rf $(BUILD_DIR)/$(POP3PROXY_DIR) $(@D)
	$(POP3PROXY_UNZIP) $(DL_DIR)/$(POP3PROXY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(POP3PROXY_PATCHES)" ; \
		then cat $(POP3PROXY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(POP3PROXY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(POP3PROXY_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(POP3PROXY_DIR) $(@D) ; \
	fi
#	(cd $(@D) ; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(POP3PROXY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(POP3PROXY_LDFLAGS)" \
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

pop3proxy-unpack: $(POP3PROXY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(POP3PROXY_BUILD_DIR)/.built: $(POP3PROXY_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(POP3PROXY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(POP3PROXY_LDFLAGS)" \
;
	touch $@

#
# This is the build convenience target.
#
pop3proxy: $(POP3PROXY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(POP3PROXY_BUILD_DIR)/.staged: $(POP3PROXY_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

pop3proxy-stage: $(POP3PROXY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pop3proxy
#
$(POP3PROXY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: pop3proxy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(POP3PROXY_PRIORITY)" >>$@
	@echo "Section: $(POP3PROXY_SECTION)" >>$@
	@echo "Version: $(POP3PROXY_VERSION)-$(POP3PROXY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POP3PROXY_MAINTAINER)" >>$@
	@echo "Source: $(POP3PROXY_SITE)/$(POP3PROXY_SOURCE)" >>$@
	@echo "Description: $(POP3PROXY_DESCRIPTION)" >>$@
	@echo "Depends: $(POP3PROXY_DEPENDS)" >>$@
	@echo "Suggests: $(POP3PROXY_SUGGESTS)" >>$@
	@echo "Conflicts: $(POP3PROXY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(POP3PROXY_IPK_DIR)/opt/sbin or $(POP3PROXY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(POP3PROXY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(POP3PROXY_IPK_DIR)/opt/etc/pop3proxy/...
# Documentation files should be installed in $(POP3PROXY_IPK_DIR)/opt/doc/pop3proxy/...
# Daemon startup scripts should be installed in $(POP3PROXY_IPK_DIR)/opt/etc/init.d/S??pop3proxy
#
# You may need to patch your application to make it use these locations.
#
$(POP3PROXY_IPK): $(POP3PROXY_BUILD_DIR)/.built
	rm -rf $(POP3PROXY_IPK_DIR) $(BUILD_DIR)/pop3proxy_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(POP3PROXY_BUILD_DIR) DESTDIR=$(POP3PROXY_IPK_DIR) install-strip
	$(STRIP_COMMAND) $(POP3PROXY_BUILD_DIR)/pop3.proxy
	install -d $(POP3PROXY_IPK_DIR)/opt/sbin/
	install -m 755 $(<D)/pop3.proxy $(POP3PROXY_IPK_DIR)/opt/sbin/
	install -d $(POP3PROXY_IPK_DIR)/opt/man/man1/
	install -m 644 $(<D)/pop3.proxy.1 $(POP3PROXY_IPK_DIR)/opt/man/man1/
	install -d $(POP3PROXY_IPK_DIR)/opt/share/doc/pop3proxy/
	install -m 644 $(<D)/acp.pop3 $(<D)/LICENSE $(<D)/pop3proxy.lsm \
		$(<D)/README $(POP3PROXY_IPK_DIR)/opt/share/doc/pop3proxy/
	install -m 644 $(POP3PROXY_SOURCE_DIR)/pop3proxy.txt $(POP3PROXY_IPK_DIR)/opt/share/doc/pop3proxy/
	install -d $(POP3PROXY_IPK_DIR)/opt/etc/xinetd.d/
	install -m 644 $(POP3PROXY_SOURCE_DIR)/pop3proxy $(POP3PROXY_IPK_DIR)/opt/etc/xinetd.d/pop3proxy
	install -d 777 $(POP3PROXY_IPK_DIR)/opt/var/pop3proxy/
#	install -d $(POP3PROXY_IPK_DIR)/opt/etc/
#	install -m 644 $(POP3PROXY_SOURCE_DIR)/pop3proxy.conf $(POP3PROXY_IPK_DIR)/opt/etc/pop3proxy.conf
#	install -d $(POP3PROXY_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(POP3PROXY_SOURCE_DIR)/rc.pop3proxy $(POP3PROXY_IPK_DIR)/opt/etc/init.d/SXXpop3proxy
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(POP3PROXY_IPK_DIR)/opt/etc/init.d/SXXpop3proxy
	$(MAKE) $(POP3PROXY_IPK_DIR)/CONTROL/control
	install -m 755 $(POP3PROXY_SOURCE_DIR)/postinst $(POP3PROXY_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(POP3PROXY_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(POP3PROXY_SOURCE_DIR)/prerm $(POP3PROXY_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(POP3PROXY_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(POP3PROXY_IPK_DIR)/CONTROL/postinst $(POP3PROXY_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(POP3PROXY_CONFFILES) | sed -e 's/ /\n/g' > $(POP3PROXY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POP3PROXY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pop3proxy-ipk: $(POP3PROXY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pop3proxy-clean:
	rm -f $(POP3PROXY_BUILD_DIR)/.built
	-$(MAKE) -C $(POP3PROXY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pop3proxy-dirclean:
	rm -rf $(BUILD_DIR)/$(POP3PROXY_DIR) $(POP3PROXY_BUILD_DIR) $(POP3PROXY_IPK_DIR) $(POP3PROXY_IPK)
#
#
# Some sanity check for the package.
#
pop3proxy-check: $(POP3PROXY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(POP3PROXY_IPK)
