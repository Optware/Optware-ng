###########################################################
#
# pound
#
###########################################################
#
# POUND_VERSION, POUND_SITE and POUND_SOURCE define
# the upstream location of the source code for the package.
# POUND_DIR is the directory which is created when the source
# archive is unpacked.
# POUND_UNZIP is the command used to unzip the source.
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
POUND_SITE=http://www.apsis.ch/pound
POUND_VERSION=2.4.1
POUND_SOURCE=Pound-$(POUND_VERSION).tgz
POUND_DIR=Pound-$(POUND_VERSION)
POUND_UNZIP=zcat
POUND_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
POUND_DESCRIPTION=Reverse-proxy and load-balancer.
POUND_SECTION=web
POUND_PRIORITY=optional
POUND_DEPENDS=openssl, pcre
POUND_SUGGESTS=
POUND_CONFLICTS=

#
# POUND_IPK_VERSION should be incremented when the ipk changes.
#
POUND_IPK_VERSION=1

#
# POUND_CONFFILES should be a list of user-editable files
#POUND_CONFFILES=/opt/etc/pound.conf /opt/etc/init.d/SXXpound

#
# POUND_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#POUND_PATCHES=$(POUND_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
POUND_CPPFLAGS=
POUND_LDFLAGS=

#
# POUND_BUILD_DIR is the directory in which the build is done.
# POUND_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# POUND_IPK_DIR is the directory in which the ipk is built.
# POUND_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
POUND_BUILD_DIR=$(BUILD_DIR)/pound
POUND_SOURCE_DIR=$(SOURCE_DIR)/pound
POUND_IPK_DIR=$(BUILD_DIR)/pound-$(POUND_VERSION)-ipk
POUND_IPK=$(BUILD_DIR)/pound_$(POUND_VERSION)-$(POUND_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pound-source pound-unpack pound pound-stage pound-ipk pound-clean pound-dirclean pound-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(POUND_SOURCE):
	$(WGET) -P $(DL_DIR) $(POUND_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pound-source: $(DL_DIR)/$(POUND_SOURCE) $(POUND_PATCHES)

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
$(POUND_BUILD_DIR)/.configured: $(DL_DIR)/$(POUND_SOURCE) $(POUND_PATCHES) make/pound.mk
	$(MAKE) openssl-stage pcre-stage
	rm -rf $(BUILD_DIR)/$(POUND_DIR) $(POUND_BUILD_DIR)
	$(POUND_UNZIP) $(DL_DIR)/$(POUND_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(POUND_PATCHES)" ; \
		then cat $(POUND_PATCHES) | \
		patch -d $(BUILD_DIR)/$(POUND_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(POUND_DIR)" != "$(POUND_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(POUND_DIR) $(POUND_BUILD_DIR) ; \
	fi
	sed -i.orig \
		-e '/@INSTALL@/s/-s //' \
		-e '/@INSTALL@/s/-o.*-g [^ ]*//' \
		-e 's/-m 555 //' $(@D)/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(POUND_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(POUND_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-ssl=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

pound-unpack: $(POUND_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(POUND_BUILD_DIR)/.built: $(POUND_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(POUND_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
pound: $(POUND_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(POUND_BUILD_DIR)/.staged: $(POUND_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(POUND_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

pound-stage: $(POUND_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pound
#
$(POUND_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: pound" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(POUND_PRIORITY)" >>$@
	@echo "Section: $(POUND_SECTION)" >>$@
	@echo "Version: $(POUND_VERSION)-$(POUND_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POUND_MAINTAINER)" >>$@
	@echo "Source: $(POUND_SITE)/$(POUND_SOURCE)" >>$@
	@echo "Description: $(POUND_DESCRIPTION)" >>$@
	@echo "Depends: $(POUND_DEPENDS)" >>$@
	@echo "Suggests: $(POUND_SUGGESTS)" >>$@
	@echo "Conflicts: $(POUND_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(POUND_IPK_DIR)/opt/sbin or $(POUND_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(POUND_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(POUND_IPK_DIR)/opt/etc/pound/...
# Documentation files should be installed in $(POUND_IPK_DIR)/opt/doc/pound/...
# Daemon startup scripts should be installed in $(POUND_IPK_DIR)/opt/etc/init.d/S??pound
#
# You may need to patch your application to make it use these locations.
#
$(POUND_IPK): $(POUND_BUILD_DIR)/.built
	rm -rf $(POUND_IPK_DIR) $(BUILD_DIR)/pound_*_$(TARGET_ARCH).ipk
	install -d $(POUND_IPK_DIR)/opt
	$(MAKE) -C $(POUND_BUILD_DIR) DESTDIR=$(POUND_IPK_DIR) install
	$(STRIP_COMMAND) $(POUND_IPK_DIR)/opt/sbin/pound*
	chmod 555 $(POUND_IPK_DIR)/opt/sbin/pound
#	install -d $(POUND_IPK_DIR)/opt/etc/
#	install -m 644 $(POUND_SOURCE_DIR)/pound.conf $(POUND_IPK_DIR)/opt/etc/pound.conf
#	install -d $(POUND_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(POUND_SOURCE_DIR)/rc.pound $(POUND_IPK_DIR)/opt/etc/init.d/SXXpound
	$(MAKE) $(POUND_IPK_DIR)/CONTROL/control
#	install -m 755 $(POUND_SOURCE_DIR)/postinst $(POUND_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(POUND_SOURCE_DIR)/prerm $(POUND_IPK_DIR)/CONTROL/prerm
	echo $(POUND_CONFFILES) | sed -e 's/ /\n/g' > $(POUND_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POUND_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pound-ipk: $(POUND_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pound-clean:
	rm -f $(POUND_BUILD_DIR)/.built
	-$(MAKE) -C $(POUND_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pound-dirclean:
	rm -rf $(BUILD_DIR)/$(POUND_DIR) $(POUND_BUILD_DIR) $(POUND_IPK_DIR) $(POUND_IPK)

#
# Some sanity check for the package.
#
pound-check: $(POUND_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(POUND_IPK)
