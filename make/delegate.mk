###########################################################
#
# delegate
#
###########################################################

DELEGATE_SITE=http://fossies.org/linux/misc
DELEGATE_VERSION=9.9.13
DELEGATE_SOURCE=delegate$(DELEGATE_VERSION).tar.gz
DELEGATE_DIR=delegate$(DELEGATE_VERSION)
DELEGATE_UNZIP=zcat
DELEGATE_MAINTAINER=WebOS Internals <support@webos-internals.org>
DELEGATE_DESCRIPTION=DeleGate is a multi-purpose application level gateway or proxy server. DeleGate mediates communication of various protocols (HTTP, FTP, NNTP, SMTP, POP, IMAP, LDAP, Telnet, SOCKS, DNS, etc.), applying cache and conversion for mediated data, controlling access from clients and routing toward servers. It translates protocols between clients and servers, applying SSL(TLS) to arbitrary protocols, converting between IPv4 and IPv6, merging several servers into a single server view with aliasing and filtering. Born as a tiny proxy for Gopher in March 1994, it has steadily grown into a general purpose proxy server. Besides being a proxy, DeleGate can be used as a simple origin server for some protocols (HTTP, FTP and NNTP).
DELEGATE_SECTION=net
DELEGATE_PRIORITY=optional
DELEGATE_DEPENDS=
DELEGATE_SUGGESTS=
DELEGATE_CONFLICTS=

#
# DELEGATE_IPK_VERSION should be incremented when the ipk changes.
#
DELEGATE_IPK_VERSION=2

#
# DELEGATE_CONFFILES should be a list of user-editable files
#DELEGATE_CONFFILES=$(TARGET_PREFIX)/etc/delegate.conf $(TARGET_PREFIX)/etc/init.d/SXXdelegate

#
# DELEGATE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DELEGATE_PATCHES=$(DELEGATE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DELEGATE_CPPFLAGS=-Wno-narrowing
DELEGATE_LDFLAGS=

#
# DELEGATE_BUILD_DIR is the directory in which the build is done.
# DELEGATE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DELEGATE_IPK_DIR is the directory in which the ipk is built.
# DELEGATE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DELEGATE_BUILD_DIR=$(BUILD_DIR)/delegate
DELEGATE_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/delegate
DELEGATE_SOURCE_DIR=$(SOURCE_DIR)/delegate
DELEGATE_IPK_DIR=$(BUILD_DIR)/delegate-$(DELEGATE_VERSION)-ipk
DELEGATE_IPK=$(BUILD_DIR)/delegate_$(DELEGATE_VERSION)-$(DELEGATE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: delegate-source delegate-unpack delegate delegate-stage delegate-ipk delegate-clean delegate-dirclean delegate-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DELEGATE_SOURCE):
	$(WGET) -P $(@D) $(DELEGATE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
delegate-source: $(DL_DIR)/$(DELEGATE_SOURCE) $(DELEGATE_PATCHES)

$(DELEGATE_HOST_BUILD_DIR)/.configured: host/.configured $(DL_DIR)/$(DELEGATE_SOURCE) $(DELEGATE_PATCHES) # make/delegate.mk
	rm -rf $(HOST_BUILD_DIR)/$(DELEGATE_DIR) $(@D)
	$(DELEGATE_UNZIP) $(DL_DIR)/$(DELEGATE_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(DELEGATE_PATCHES)" ; \
		then cat $(DELEGATE_PATCHES) | \
		$(PATCH) -d $(HOST_BUILD_DIR)/$(DELEGATE_DIR) -p0 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(DELEGATE_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(DELEGATE_DIR) $(@D) ; \
	fi
	touch $@

$(DELEGATE_HOST_BUILD_DIR)/.built: $(DELEGATE_HOST_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) ADMIN=support@webos-internals.org
	touch $@

#
# This is the build convenience target.
#
delegate-host: $(DELEGATE_HOST_BUILD_DIR)/.built

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
$(DELEGATE_BUILD_DIR)/.configured: $(DELEGATE_HOST_BUILD_DIR)/.built $(DL_DIR)/$(DELEGATE_SOURCE) $(DELEGATE_PATCHES) make/delegate.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DELEGATE_DIR) $(@D)
	$(DELEGATE_UNZIP) $(DL_DIR)/$(DELEGATE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DELEGATE_PATCHES)" ; \
		then cat $(DELEGATE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(DELEGATE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DELEGATE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DELEGATE_DIR) $(@D) ; \
	fi
	cp $(DELEGATE_HOST_BUILD_DIR)/mk*.exe $(@D)
	cp $(DELEGATE_HOST_BUILD_DIR)/mkcpp $(@D)
	cp $(DELEGATE_HOST_BUILD_DIR)/filters/mkstab $(@D)/filters/
	touch $@

delegate-unpack: $(DELEGATE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DELEGATE_BUILD_DIR)/.built: $(DELEGATE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) CC=$(TARGET_CC) \
		CFLAGS="$(STAGING_CPPFLAGS) $(DELEGATE_CPPFLAGS)" \
		LIBDIRS="-L../lib $(STAGING_LDFLAGS) $(DELEGATE_LDFLAGS)" \
		PLIBDIRS="-Llib $(STAGING_LDFLAGS) $(DELEGATE_LDFLAGS)" \
		XEMBED=$(DELEGATE_HOST_BUILD_DIR)/src/embed \
		XDG=$(DELEGATE_HOST_BUILD_DIR)/src/dg.exe \
		ADMIN=support@webos-internals.org
	touch $@

#
# This is the build convenience target.
#
delegate: $(DELEGATE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DELEGATE_BUILD_DIR)/.staged: $(DELEGATE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

delegate-stage: $(DELEGATE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/delegate
#
$(DELEGATE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: delegate" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DELEGATE_PRIORITY)" >>$@
	@echo "Section: $(DELEGATE_SECTION)" >>$@
	@echo "Version: $(DELEGATE_VERSION)-$(DELEGATE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DELEGATE_MAINTAINER)" >>$@
	@echo "Source: $(DELEGATE_SITE)/$(DELEGATE_SOURCE)" >>$@
	@echo "Description: $(DELEGATE_DESCRIPTION)" >>$@
	@echo "Depends: $(DELEGATE_DEPENDS)" >>$@
	@echo "Suggests: $(DELEGATE_SUGGESTS)" >>$@
	@echo "Conflicts: $(DELEGATE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DELEGATE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(DELEGATE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DELEGATE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(DELEGATE_IPK_DIR)$(TARGET_PREFIX)/etc/delegate/...
# Documentation files should be installed in $(DELEGATE_IPK_DIR)$(TARGET_PREFIX)/doc/delegate/...
# Daemon startup scripts should be installed in $(DELEGATE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??delegate
#
# You may need to patch your application to make it use these locations.
#
$(DELEGATE_IPK): $(DELEGATE_BUILD_DIR)/.built
	rm -rf $(DELEGATE_IPK_DIR) $(BUILD_DIR)/delegate_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(DELEGATE_IPK_DIR)$(TARGET_PREFIX)/sbin/
	$(INSTALL) -m 0755 $(DELEGATE_BUILD_DIR)/src/delegated $(DELEGATE_IPK_DIR)$(TARGET_PREFIX)/sbin/delegated
#	$(MAKE) -C $(DELEGATE_BUILD_DIR) DESTDIR=$(DELEGATE_IPK_DIR) install-strip
#	$(INSTALL) -d $(DELEGATE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(DELEGATE_SOURCE_DIR)/delegate.conf $(DELEGATE_IPK_DIR)$(TARGET_PREFIX)/etc/delegate.conf
#	$(INSTALL) -d $(DELEGATE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(DELEGATE_SOURCE_DIR)/rc.delegate $(DELEGATE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXdelegate
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DELEGATE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXdelegate
	$(MAKE) $(DELEGATE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(DELEGATE_SOURCE_DIR)/postinst $(DELEGATE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DELEGATE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(DELEGATE_SOURCE_DIR)/prerm $(DELEGATE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DELEGATE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(DELEGATE_IPK_DIR)/CONTROL/postinst $(DELEGATE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(DELEGATE_CONFFILES) | sed -e 's/ /\n/g' > $(DELEGATE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DELEGATE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
delegate-ipk: $(DELEGATE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
delegate-clean:
	rm -f $(DELEGATE_BUILD_DIR)/.built
	-$(MAKE) -C $(DELEGATE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
delegate-dirclean:
	rm -rf $(BUILD_DIR)/$(DELEGATE_DIR) $(DELEGATE_BUILD_DIR) $(DELEGATE_IPK_DIR) $(DELEGATE_IPK)
#
#
# Some sanity check for the package.
#
delegate-check: $(DELEGATE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
