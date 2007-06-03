###########################################################
#
# yafc
#
###########################################################
#
# YAFC_VERSION, YAFC_SITE and YAFC_SOURCE define
# the upstream location of the source code for the package.
# YAFC_DIR is the directory which is created when the source
# archive is unpacked.
# YAFC_UNZIP is the command used to unzip the source.
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
YAFC_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/yafc
YAFC_VERSION=1.1.1
YAFC_SOURCE=yafc-$(YAFC_VERSION).tar.gz
YAFC_DIR=yafc-$(YAFC_VERSION)
YAFC_UNZIP=zcat
YAFC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
YAFC_DESCRIPTION=Yet Another FTP Client.
YAFC_SECTION=net
YAFC_PRIORITY=optional
YAFC_DEPENDS=ncurses, readline
YAFC_SUGGESTS=
YAFC_CONFLICTS=

#
# YAFC_IPK_VERSION should be incremented when the ipk changes.
#
YAFC_IPK_VERSION=1

#
# YAFC_CONFFILES should be a list of user-editable files
#YAFC_CONFFILES=/opt/etc/yafc.conf /opt/etc/init.d/SXXyafc

#
# YAFC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#YAFC_PATCHES=$(YAFC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
YAFC_CPPFLAGS=
YAFC_LDFLAGS=

ifneq ($(HOSTCC), $(TARGET_CC))
YAFC_CONFIGURE_ENV=bash_cv_func_sigsetjmp=present
endif

#
# YAFC_BUILD_DIR is the directory in which the build is done.
# YAFC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# YAFC_IPK_DIR is the directory in which the ipk is built.
# YAFC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
YAFC_BUILD_DIR=$(BUILD_DIR)/yafc
YAFC_SOURCE_DIR=$(SOURCE_DIR)/yafc
YAFC_IPK_DIR=$(BUILD_DIR)/yafc-$(YAFC_VERSION)-ipk
YAFC_IPK=$(BUILD_DIR)/yafc_$(YAFC_VERSION)-$(YAFC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: yafc-source yafc-unpack yafc yafc-stage yafc-ipk yafc-clean yafc-dirclean yafc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(YAFC_SOURCE):
	$(WGET) -P $(DL_DIR) $(YAFC_SITE)/$(YAFC_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(YAFC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
yafc-source: $(DL_DIR)/$(YAFC_SOURCE) $(YAFC_PATCHES)

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
$(YAFC_BUILD_DIR)/.configured: $(DL_DIR)/$(YAFC_SOURCE) $(YAFC_PATCHES) make/yafc.mk
	$(MAKE) ncurses-stage readline-stage
	rm -rf $(BUILD_DIR)/$(YAFC_DIR) $(YAFC_BUILD_DIR)
	$(YAFC_UNZIP) $(DL_DIR)/$(YAFC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(YAFC_PATCHES)" ; \
		then cat $(YAFC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(YAFC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(YAFC_DIR)" != "$(YAFC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(YAFC_DIR) $(YAFC_BUILD_DIR) ; \
	fi
	(cd $(YAFC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(YAFC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(YAFC_LDFLAGS)" \
		$(YAFC_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-readline=$(STAGING_PREFIX) \
		--without-krb4 \
		--without-krb5 \
		--without-gssapi \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(YAFC_BUILD_DIR)/libtool
	touch $@

yafc-unpack: $(YAFC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(YAFC_BUILD_DIR)/.built: $(YAFC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(YAFC_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
yafc: $(YAFC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(YAFC_BUILD_DIR)/.staged: $(YAFC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(YAFC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

yafc-stage: $(YAFC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/yafc
#
$(YAFC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: yafc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(YAFC_PRIORITY)" >>$@
	@echo "Section: $(YAFC_SECTION)" >>$@
	@echo "Version: $(YAFC_VERSION)-$(YAFC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(YAFC_MAINTAINER)" >>$@
	@echo "Source: $(YAFC_SITE)/$(YAFC_SOURCE)" >>$@
	@echo "Description: $(YAFC_DESCRIPTION)" >>$@
	@echo "Depends: $(YAFC_DEPENDS)" >>$@
	@echo "Suggests: $(YAFC_SUGGESTS)" >>$@
	@echo "Conflicts: $(YAFC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(YAFC_IPK_DIR)/opt/sbin or $(YAFC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(YAFC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(YAFC_IPK_DIR)/opt/etc/yafc/...
# Documentation files should be installed in $(YAFC_IPK_DIR)/opt/doc/yafc/...
# Daemon startup scripts should be installed in $(YAFC_IPK_DIR)/opt/etc/init.d/S??yafc
#
# You may need to patch your application to make it use these locations.
#
$(YAFC_IPK): $(YAFC_BUILD_DIR)/.built
	rm -rf $(YAFC_IPK_DIR) $(BUILD_DIR)/yafc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(YAFC_BUILD_DIR) DESTDIR=$(YAFC_IPK_DIR) install-strip
#	install -d $(YAFC_IPK_DIR)/opt/etc/
#	install -m 644 $(YAFC_SOURCE_DIR)/yafc.conf $(YAFC_IPK_DIR)/opt/etc/yafc.conf
#	install -d $(YAFC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(YAFC_SOURCE_DIR)/rc.yafc $(YAFC_IPK_DIR)/opt/etc/init.d/SXXyafc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(YAFC_IPK_DIR)/opt/etc/init.d/SXXyafc
	$(MAKE) $(YAFC_IPK_DIR)/CONTROL/control
#	install -m 755 $(YAFC_SOURCE_DIR)/postinst $(YAFC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(YAFC_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(YAFC_SOURCE_DIR)/prerm $(YAFC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(YAFC_IPK_DIR)/CONTROL/prerm
	echo $(YAFC_CONFFILES) | sed -e 's/ /\n/g' > $(YAFC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(YAFC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
yafc-ipk: $(YAFC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
yafc-clean:
	rm -f $(YAFC_BUILD_DIR)/.built
	-$(MAKE) -C $(YAFC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
yafc-dirclean:
	rm -rf $(BUILD_DIR)/$(YAFC_DIR) $(YAFC_BUILD_DIR) $(YAFC_IPK_DIR) $(YAFC_IPK)
#
#
# Some sanity check for the package.
#
yafc-check: $(YAFC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(YAFC_IPK)
