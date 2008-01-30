###########################################################
#
# mini-sendmail
#
###########################################################
#
# MINI_SENDMAIL_VERSION, MINI_SENDMAIL_SITE and MINI_SENDMAIL_SOURCE define
# the upstream location of the source code for the package.
# MINI_SENDMAIL_DIR is the directory which is created when the source
# archive is unpacked.
# MINI_SENDMAIL_UNZIP is the command used to unzip the source.
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
MINI_SENDMAIL_SITE=http://www.acme.com/software/mini_sendmail
MINI_SENDMAIL_VERSION=1.3.6
MINI_SENDMAIL_SOURCE=mini_sendmail-$(MINI_SENDMAIL_VERSION).tar.gz
MINI_SENDMAIL_DIR=mini_sendmail-$(MINI_SENDMAIL_VERSION)
MINI_SENDMAIL_UNZIP=zcat
MINI_SENDMAIL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MINI_SENDMAIL_DESCRIPTION=small sendmail-compatible mail forwarder
MINI_SENDMAIL_SECTION=net
MINI_SENDMAIL_PRIORITY=optional
MINI_SENDMAIL_DEPENDS=
MINI_SENDMAIL_SUGGESTS=
MINI_SENDMAIL_CONFLICTS=

#
# MINI_SENDMAIL_IPK_VERSION should be incremented when the ipk changes.
#
MINI_SENDMAIL_IPK_VERSION=1

#
# MINI_SENDMAIL_CONFFILES should be a list of user-editable files
#MINI_SENDMAIL_CONFFILES=/opt/etc/mini-sendmail.conf /opt/etc/init.d/SXXmini-sendmail

#
# MINI_SENDMAIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MINI_SENDMAIL_PATCHES=$(MINI_SENDMAIL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MINI_SENDMAIL_CPPFLAGS=
MINI_SENDMAIL_LDFLAGS=

#
# MINI_SENDMAIL_BUILD_DIR is the directory in which the build is done.
# MINI_SENDMAIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MINI_SENDMAIL_IPK_DIR is the directory in which the ipk is built.
# MINI_SENDMAIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MINI_SENDMAIL_BUILD_DIR=$(BUILD_DIR)/mini-sendmail
MINI_SENDMAIL_SOURCE_DIR=$(SOURCE_DIR)/mini-sendmail
MINI_SENDMAIL_IPK_DIR=$(BUILD_DIR)/mini-sendmail-$(MINI_SENDMAIL_VERSION)-ipk
MINI_SENDMAIL_IPK=$(BUILD_DIR)/mini-sendmail_$(MINI_SENDMAIL_VERSION)-$(MINI_SENDMAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mini-sendmail-source mini-sendmail-unpack mini-sendmail mini-sendmail-stage mini-sendmail-ipk mini-sendmail-clean mini-sendmail-dirclean mini-sendmail-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MINI_SENDMAIL_SOURCE):
	$(WGET) -P $(DL_DIR) $(MINI_SENDMAIL_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mini-sendmail-source: $(DL_DIR)/$(MINI_SENDMAIL_SOURCE) $(MINI_SENDMAIL_PATCHES)

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
$(MINI_SENDMAIL_BUILD_DIR)/.configured: $(DL_DIR)/$(MINI_SENDMAIL_SOURCE) $(MINI_SENDMAIL_PATCHES) make/mini-sendmail.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MINI_SENDMAIL_DIR) $(@D)
	$(MINI_SENDMAIL_UNZIP) $(DL_DIR)/$(MINI_SENDMAIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MINI_SENDMAIL_PATCHES)" ; \
		then cat $(MINI_SENDMAIL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MINI_SENDMAIL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MINI_SENDMAIL_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MINI_SENDMAIL_DIR) $(@D) ; \
	fi
	sed -i -e '/^CC\|^LDFLAGS\|^CFLAGS/d' \
		-e 's|^BINDIR.*|BINDIR=$$(DESTDIR)/opt/bin|' \
		-e 's|^MANDIR.*|MANDIR=$$(DESTDIR)/opt/man|' \
		$(MINI_SENDMAIL_BUILD_DIR)/Makefile	
	touch $@

mini-sendmail-unpack: $(MINI_SENDMAIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MINI_SENDMAIL_BUILD_DIR)/.built: $(MINI_SENDMAIL_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(STAGING_CPPFLAGS) $(MINI_SENDMAIL_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(MINI_SENDMAIL_LDFLAGS)" \
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
mini-sendmail: $(MINI_SENDMAIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MINI_SENDMAIL_BUILD_DIR)/.staged: $(MINI_SENDMAIL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

mini-sendmail-stage: $(MINI_SENDMAIL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mini-sendmail
#
$(MINI_SENDMAIL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mini-sendmail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MINI_SENDMAIL_PRIORITY)" >>$@
	@echo "Section: $(MINI_SENDMAIL_SECTION)" >>$@
	@echo "Version: $(MINI_SENDMAIL_VERSION)-$(MINI_SENDMAIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MINI_SENDMAIL_MAINTAINER)" >>$@
	@echo "Source: $(MINI_SENDMAIL_SITE)/$(MINI_SENDMAIL_SOURCE)" >>$@
	@echo "Description: $(MINI_SENDMAIL_DESCRIPTION)" >>$@
	@echo "Depends: $(MINI_SENDMAIL_DEPENDS)" >>$@
	@echo "Suggests: $(MINI_SENDMAIL_SUGGESTS)" >>$@
	@echo "Conflicts: $(MINI_SENDMAIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MINI_SENDMAIL_IPK_DIR)/opt/sbin or $(MINI_SENDMAIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MINI_SENDMAIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MINI_SENDMAIL_IPK_DIR)/opt/etc/mini-sendmail/...
# Documentation files should be installed in $(MINI_SENDMAIL_IPK_DIR)/opt/doc/mini-sendmail/...
# Daemon startup scripts should be installed in $(MINI_SENDMAIL_IPK_DIR)/opt/etc/init.d/S??mini-sendmail
#
# You may need to patch your application to make it use these locations.
#
$(MINI_SENDMAIL_IPK): $(MINI_SENDMAIL_BUILD_DIR)/.built
	rm -rf $(MINI_SENDMAIL_IPK_DIR) $(BUILD_DIR)/mini-sendmail_*_$(TARGET_ARCH).ipk
	install -d $(MINI_SENDMAIL_IPK_DIR)/opt/bin
	install -d $(MINI_SENDMAIL_IPK_DIR)/opt/man/man8
	$(MAKE) -C $(MINI_SENDMAIL_BUILD_DIR) DESTDIR=$(MINI_SENDMAIL_IPK_DIR) install
	$(TARGET_STRIP) $(MINI_SENDMAIL_IPK_DIR)/opt/bin/mini_sendmail
#	install -m 644 $(MINI_SENDMAIL_SOURCE_DIR)/mini-sendmail.conf $(MINI_SENDMAIL_IPK_DIR)/opt/etc/mini-sendmail.conf
#	install -d $(MINI_SENDMAIL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MINI_SENDMAIL_SOURCE_DIR)/rc.mini-sendmail $(MINI_SENDMAIL_IPK_DIR)/opt/etc/init.d/SXXmini-sendmail
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MINI_SENDMAIL_IPK_DIR)/opt/etc/init.d/SXXmini-sendmail
	$(MAKE) $(MINI_SENDMAIL_IPK_DIR)/CONTROL/control
#	install -m 755 $(MINI_SENDMAIL_SOURCE_DIR)/postinst $(MINI_SENDMAIL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MINI_SENDMAIL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MINI_SENDMAIL_SOURCE_DIR)/prerm $(MINI_SENDMAIL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MINI_SENDMAIL_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MINI_SENDMAIL_IPK_DIR)/CONTROL/postinst $(MINI_SENDMAIL_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MINI_SENDMAIL_CONFFILES) | sed -e 's/ /\n/g' > $(MINI_SENDMAIL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MINI_SENDMAIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mini-sendmail-ipk: $(MINI_SENDMAIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mini-sendmail-clean:
	rm -f $(MINI_SENDMAIL_BUILD_DIR)/.built
	-$(MAKE) -C $(MINI_SENDMAIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mini-sendmail-dirclean:
	rm -rf $(BUILD_DIR)/$(MINI_SENDMAIL_DIR) $(MINI_SENDMAIL_BUILD_DIR) $(MINI_SENDMAIL_IPK_DIR) $(MINI_SENDMAIL_IPK)
#
#
# Some sanity check for the package.
#
mini-sendmail-check: $(MINI_SENDMAIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MINI_SENDMAIL_IPK)
