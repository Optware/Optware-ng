###########################################################
#
# cadaver
#
###########################################################
#
# CADAVER_VERSION, CADAVER_SITE and CADAVER_SOURCE define
# the upstream location of the source code for the package.
# CADAVER_DIR is the directory which is created when the source
# archive is unpacked.
# CADAVER_UNZIP is the command used to unzip the source.
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
CADAVER_SITE=http://www.webdav.org/cadaver
CADAVER_VERSION=0.23.3
CADAVER_SOURCE=cadaver-$(CADAVER_VERSION).tar.gz
CADAVER_DIR=cadaver-$(CADAVER_VERSION)
CADAVER_UNZIP=zcat
CADAVER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CADAVER_DESCRIPTION=Command-line WebDAV client.
CADAVER_SECTION=net
CADAVER_PRIORITY=optional
CADAVER_DEPENDS=expat, ncurses, openssl, readline
CADAVER_SUGGESTS=
CADAVER_CONFLICTS=

#
# CADAVER_IPK_VERSION should be incremented when the ipk changes.
#
CADAVER_IPK_VERSION=2

#
# CADAVER_CONFFILES should be a list of user-editable files
#CADAVER_CONFFILES=$(TARGET_PREFIX)/etc/cadaver.conf $(TARGET_PREFIX)/etc/init.d/SXXcadaver

#
# CADAVER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CADAVER_PATCHES=$(CADAVER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CADAVER_CPPFLAGS=
CADAVER_LDFLAGS=

#
# CADAVER_BUILD_DIR is the directory in which the build is done.
# CADAVER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CADAVER_IPK_DIR is the directory in which the ipk is built.
# CADAVER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CADAVER_BUILD_DIR=$(BUILD_DIR)/cadaver
CADAVER_SOURCE_DIR=$(SOURCE_DIR)/cadaver
CADAVER_IPK_DIR=$(BUILD_DIR)/cadaver-$(CADAVER_VERSION)-ipk
CADAVER_IPK=$(BUILD_DIR)/cadaver_$(CADAVER_VERSION)-$(CADAVER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cadaver-source cadaver-unpack cadaver cadaver-stage cadaver-ipk cadaver-clean cadaver-dirclean cadaver-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CADAVER_SOURCE):
	$(WGET) -P $(@D) $(CADAVER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cadaver-source: $(DL_DIR)/$(CADAVER_SOURCE) $(CADAVER_PATCHES)

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
$(CADAVER_BUILD_DIR)/.configured: $(DL_DIR)/$(CADAVER_SOURCE) $(CADAVER_PATCHES) make/cadaver.mk
	$(MAKE) expat-stage ncurses-stage openssl-stage readline-stage
	rm -rf $(BUILD_DIR)/$(CADAVER_DIR) $(@D)
	$(CADAVER_UNZIP) $(DL_DIR)/$(CADAVER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CADAVER_PATCHES)" ; \
		then cat $(CADAVER_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(CADAVER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CADAVER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CADAVER_DIR) $(@D) ; \
	fi
	sed -i -e '/CC.*LDFLAGS/{s/ $$(LDFLAGS)//;s/$$/ $$(LDFLAGS)/}' $(@D)/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CADAVER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CADAVER_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--with-included-neon \
		--with-libs=$(STAGING_PREFIX) \
		--with-ssl=openssl \
		--disable-nls \
		--disable-static \
	)
	sed -i -e '/HAVE_SETLOCALE/s|^|//|' $(@D)/config.h
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

cadaver-unpack: $(CADAVER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CADAVER_BUILD_DIR)/.built: $(CADAVER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
cadaver: $(CADAVER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CADAVER_BUILD_DIR)/.staged: $(CADAVER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

cadaver-stage: $(CADAVER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cadaver
#
$(CADAVER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: cadaver" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CADAVER_PRIORITY)" >>$@
	@echo "Section: $(CADAVER_SECTION)" >>$@
	@echo "Version: $(CADAVER_VERSION)-$(CADAVER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CADAVER_MAINTAINER)" >>$@
	@echo "Source: $(CADAVER_SITE)/$(CADAVER_SOURCE)" >>$@
	@echo "Description: $(CADAVER_DESCRIPTION)" >>$@
	@echo "Depends: $(CADAVER_DEPENDS)" >>$@
	@echo "Suggests: $(CADAVER_SUGGESTS)" >>$@
	@echo "Conflicts: $(CADAVER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CADAVER_IPK_DIR)$(TARGET_PREFIX)/sbin or $(CADAVER_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CADAVER_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(CADAVER_IPK_DIR)$(TARGET_PREFIX)/etc/cadaver/...
# Documentation files should be installed in $(CADAVER_IPK_DIR)$(TARGET_PREFIX)/doc/cadaver/...
# Daemon startup scripts should be installed in $(CADAVER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??cadaver
#
# You may need to patch your application to make it use these locations.
#
$(CADAVER_IPK): $(CADAVER_BUILD_DIR)/.built
	rm -rf $(CADAVER_IPK_DIR) $(BUILD_DIR)/cadaver_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CADAVER_BUILD_DIR) DESTDIR=$(CADAVER_IPK_DIR) install
	$(STRIP_COMMAND) $(CADAVER_IPK_DIR)$(TARGET_PREFIX)/bin/cadaver
	$(MAKE) $(CADAVER_IPK_DIR)/CONTROL/control
	echo $(CADAVER_CONFFILES) | sed -e 's/ /\n/g' > $(CADAVER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CADAVER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cadaver-ipk: $(CADAVER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cadaver-clean:
	rm -f $(CADAVER_BUILD_DIR)/.built
	-$(MAKE) -C $(CADAVER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cadaver-dirclean:
	rm -rf $(BUILD_DIR)/$(CADAVER_DIR) $(CADAVER_BUILD_DIR) $(CADAVER_IPK_DIR) $(CADAVER_IPK)
#
#
# Some sanity check for the package.
#
cadaver-check: $(CADAVER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
