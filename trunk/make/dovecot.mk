###########################################################
#
# dovecot
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
# Warning:
#	This is work in progress.
# TODO:
#	- wl500g doesn't work
#
DOVECOT_SITE=http://dovecot.org/releases/1.2/beta
DOVECOT_VERSION=1.2.0.beta1
DOVECOT_SRC_VERSION=1.2.beta1
#
# Version 1.2.0 should be greater then 1.2.beta1 so i place
# a extra "0" in the ipk version.
#
DOVECOT_SOURCE=dovecot-$(DOVECOT_SRC_VERSION).tar.gz
DOVECOT_DIR=dovecot-$(DOVECOT_SRC_VERSION)
DOVECOT_UNZIP=zcat
DOVECOT_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
DOVECOT_DESCRIPTION=Dovecot secure IMAP server
DOVECOT_SECTION=net
DOVECOT_PRIORITY=optional
DOVECOT_DEPENDS=openssl
DOVECOT_SUGGESTS=
DOVECOT_CONFLICTS=cyrus-imapd, imap

DOVECOT_DOC_DESCRIPTION=Dovecot documentation
DOVECOT_DOC_SECTION=net
DOVECOT_DOC_PRIORITY=optional
DOVECOT_DOC_DEPENDS=
DOVECOT_DOC_SUGGESTS=dovecot
DOVECOT_DOC_CONFLICTS=

#
# DOVECOT_IPK_VERSION should be incremented when the ipk changes.
#
DOVECOT_IPK_VERSION=2

#
# DOVECOT_CONFFILES should be a list of user-editable files
DOVECOT_CONFFILES= \
	/opt/etc/dovecot/dovecot.conf \
	/opt/etc/dovecot/dovecot-openssl.cnf \
	/opt/etc/init.d/S90dovecot

#
# DOVECOT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DOVECOT_PATCHES=$(DOVECOT_SOURCE_DIR)/configure.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DOVECOT_CPPFLAGS=
DOVECOT_LDFLAGS=

ifeq ($(OPTWARE_TARGET),wl500g)
DOVECOT_CONFIGURE+=--disable-ipv6
endif

ifeq ($(IPV6),no)
DOVECOT_CONFIGURE+=--disable-ipv6
endif

#
# DOVECOT_BUILD_DIR is the directory in which the build is done.
# DOVECOT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DOVECOT_IPK_DIR is the directory in which the ipk is built.
# DOVECOT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DOVECOT_BUILD_DIR=$(BUILD_DIR)/dovecot
DOVECOT_SOURCE_DIR=$(SOURCE_DIR)/dovecot
DOVECOT_IPK_DIR=$(BUILD_DIR)/dovecot-$(DOVECOT_VERSION)-ipk
DOVECOT_IPK=$(BUILD_DIR)/dovecot_$(DOVECOT_VERSION)-$(DOVECOT_IPK_VERSION)_$(TARGET_ARCH).ipk

DOVECOT_DOC_IPK_DIR=$(BUILD_DIR)/dovecot-doc-$(DOVECOT_VERSION)-ipk
DOVECOT_DOC_IPK=$(BUILD_DIR)/dovecot-doc_$(DOVECOT_VERSION)-$(DOVECOT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dovecot-source dovecot-unpack dovecot dovecot-stage dovecot-ipk dovecot-clean dovecot-dirclean dovecot-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DOVECOT_SOURCE):
	$(WGET) -P $(@D) $(DOVECOT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dovecot-source: $(DL_DIR)/$(DOVECOT_SOURCE) $(DOVECOT_PATCHES)

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
$(DOVECOT_BUILD_DIR)/.configured: $(DL_DIR)/$(DOVECOT_SOURCE) $(DOVECOT_PATCHES) make/dovecot.mk
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(DOVECOT_DIR) $(@D)
	$(DOVECOT_UNZIP) $(DL_DIR)/$(DOVECOT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DOVECOT_PATCHES)" ; \
		then cat $(DOVECOT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DOVECOT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DOVECOT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DOVECOT_DIR) $(@D) ; \
	fi
	autoreconf -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DOVECOT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DOVECOT_LDFLAGS)" \
		RPCGEN=__disable_RPCGEN_rquota \
		./configure \
		$(DOVECOT_CONFIGURE) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
		--without-gssapi \
		--without-pam \
		--with-notify=dnotify \
		--sysconfdir=/opt/etc/dovecot \
		--localstatedir=/opt/var \
		--with-ssldir=/opt/etc/dovecot \
		--without-sql-drivers \
		--with-ioloop=poll; \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

dovecot-unpack: $(DOVECOT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DOVECOT_BUILD_DIR)/.built: $(DOVECOT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
dovecot: $(DOVECOT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DOVECOT_BUILD_DIR)/.staged: $(DOVECOT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

dovecot-stage: $(DOVECOT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dovecot
#
$(DOVECOT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dovecot" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DOVECOT_PRIORITY)" >>$@
	@echo "Section: $(DOVECOT_SECTION)" >>$@
	@echo "Version: $(DOVECOT_VERSION)-$(DOVECOT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DOVECOT_MAINTAINER)" >>$@
	@echo "Source: $(DOVECOT_SITE)/$(DOVECOT_SOURCE)" >>$@
	@echo "Description: $(DOVECOT_DESCRIPTION)" >>$@
	@echo "Depends: $(DOVECOT_DEPENDS)" >>$@
	@echo "Suggests: $(DOVECOT_SUGGESTS)" >>$@
	@echo "Conflicts: $(DOVECOT_CONFLICTS)" >>$@

$(DOVECOT_DOC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dovecot-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DOVECOT_PRIORITY)" >>$@
	@echo "Section: $(DOVECOT_DOC_SECTION)" >>$@
	@echo "Version: $(DOVECOT_VERSION)-$(DOVECOT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DOVECOT_MAINTAINER)" >>$@
	@echo "Source: $(DOVECOT_SITE)/$(DOVECOT_SOURCE)" >>$@
	@echo "Description: $(DOVECOT_DOC_DESCRIPTION)" >>$@
	@echo "Depends: $(DOVECOT_DOC_DEPENDS)" >>$@
	@echo "Suggests: $(DOVECOT_DOC_SUGGESTS)" >>$@
	@echo "Conflicts: $(DOVECOT_DOC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DOVECOT_IPK_DIR)/opt/sbin or $(DOVECOT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DOVECOT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DOVECOT_IPK_DIR)/opt/etc/dovecot/...
# Documentation files should be installed in $(DOVECOT_IPK_DIR)/opt/doc/dovecot/...
# Daemon startup scripts should be installed in $(DOVECOT_IPK_DIR)/opt/etc/init.d/S??dovecot
#
# You may need to patch your application to make it use these locations.
#
$(DOVECOT_IPK): $(DOVECOT_BUILD_DIR)/.built
	rm -rf $(DOVECOT_IPK_DIR) $(BUILD_DIR)/dovecot_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DOVECOT_BUILD_DIR) DESTDIR=$(DOVECOT_IPK_DIR) install-strip
	install -d $(DOVECOT_IPK_DIR)/opt/etc/dovecot
	install -m 644 $(DOVECOT_SOURCE_DIR)/dovecot.conf $(DOVECOT_IPK_DIR)/opt/etc/dovecot/
	install -m 644 $(DOVECOT_BUILD_DIR)/doc/dovecot-openssl.cnf $(DOVECOT_IPK_DIR)/opt/etc/dovecot/
	install -m 755 $(DOVECOT_BUILD_DIR)/doc/mkcert.sh $(DOVECOT_IPK_DIR)/opt/etc/dovecot/
	install -m 700 -d $(DOVECOT_IPK_DIR)/opt/var/run/dovecot
	install -d $(DOVECOT_IPK_DIR)/opt/etc/init.d
	install -m 755 $(DOVECOT_SOURCE_DIR)/rc.dovecot $(DOVECOT_IPK_DIR)/opt/etc/init.d/S90dovecot
	$(MAKE) $(DOVECOT_IPK_DIR)/CONTROL/control
	install -m 755 $(DOVECOT_SOURCE_DIR)/postinst $(DOVECOT_IPK_DIR)/CONTROL/postinst
	install -m 755 $(DOVECOT_SOURCE_DIR)/prerm $(DOVECOT_IPK_DIR)/CONTROL/prerm
	echo $(DOVECOT_CONFFILES) | sed -e 's/ /\n/g' > $(DOVECOT_IPK_DIR)/CONTROL/conffiles
	rm -rf $(DOVECOT_IPK_DIR)/opt/share/doc/dovecot
	echo $(DOVECOT_CONFFILES) | sed -e 's/ /\n/g' > $(DOVECOT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DOVECOT_IPK_DIR)

$(DOVECOT_DOC_IPK): $(DOVECOT_BUILD_DIR)/.built
	rm -rf $(DOVECOT_DOC_IPK_DIR) $(BUILD_DIR)/dovecot-doc_*_$(TARGET_ARCH).ipk
	mkdir -p $(DOVECOT_DOC_IPK_DIR)/opt/share/doc/dovecot
	$(MAKE) $(DOVECOT_DOC_IPK_DIR)/CONTROL/control
	cp -r $(DOVECOT_BUILD_DIR)/doc/ $(DOVECOT_DOC_IPK_DIR)/opt/share/doc/dovecot
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DOVECOT_DOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dovecot-ipk: $(DOVECOT_IPK) $(DOVECOT_DOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dovecot-clean:
	rm -f $(DOVECOT_BUILD_DIR)/.built
	-$(MAKE) -C $(DOVECOT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dovecot-dirclean:
	rm -rf $(BUILD_DIR)/$(DOVECOT_DIR) $(DOVECOT_BUILD_DIR) $(DOVECOT_IPK_DIR) $(DOVECOT_IPK)
#
#
# Some sanity check for the package.
#
dovecot-check: $(DOVECOT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
