###########################################################
#
# tinyproxy
#
###########################################################
#
# TINYPROXY_VERSION, TINYPROXY_SITE and TINYPROXY_SOURCE define
# the upstream location of the source code for the package.
# TINYPROXY_DIR is the directory which is created when the source
# archive is unpacked.
# TINYPROXY_UNZIP is the command used to unzip the source.
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
TINYPROXY_SITE=http://www.banu.com/pub/tinyproxy/1.6
TINYPROXY_VERSION=1.6.4
TINYPROXY_SOURCE=tinyproxy-$(TINYPROXY_VERSION).tar.gz
TINYPROXY_DIR=tinyproxy-$(TINYPROXY_VERSION)
TINYPROXY_UNZIP=zcat
TINYPROXY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TINYPROXY_DESCRIPTION=Tinyproxy is a fast light-weight HTTP proxy.
TINYPROXY_SECTION=net
TINYPROXY_PRIORITY=optional
ifeq (uclibc, $(LIBC_STYLE))
TINYPROXY_DEPENDS=gettext
else
TINYPROXY_DEPENDS=
endif
TINYPROXY_SUGGESTS=
TINYPROXY_CONFLICTS=

#
# TINYPROXY_IPK_VERSION should be incremented when the ipk changes.
#
TINYPROXY_IPK_VERSION=2

#
# TINYPROXY_CONFFILES should be a list of user-editable files
TINYPROXY_CONFFILES=/opt/etc/tinyproxy/tinyproxy.conf

#
# TINYPROXY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TINYPROXY_PATCHES=$(TINYPROXY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TINYPROXY_CPPFLAGS=
TINYPROXY_LDFLAGS=
ifeq (uclibc, $(LIBC_STYLE))
TINYPROXY_LDFLAGS += -lintl
endif

#
# TINYPROXY_BUILD_DIR is the directory in which the build is done.
# TINYPROXY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TINYPROXY_IPK_DIR is the directory in which the ipk is built.
# TINYPROXY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TINYPROXY_BUILD_DIR=$(BUILD_DIR)/tinyproxy
TINYPROXY_SOURCE_DIR=$(SOURCE_DIR)/tinyproxy
TINYPROXY_IPK_DIR=$(BUILD_DIR)/tinyproxy-$(TINYPROXY_VERSION)-ipk
TINYPROXY_IPK=$(BUILD_DIR)/tinyproxy_$(TINYPROXY_VERSION)-$(TINYPROXY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tinyproxy-source tinyproxy-unpack tinyproxy tinyproxy-stage tinyproxy-ipk tinyproxy-clean tinyproxy-dirclean tinyproxy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TINYPROXY_SOURCE):
	$(WGET) -P $(@D) $(TINYPROXY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tinyproxy-source: $(DL_DIR)/$(TINYPROXY_SOURCE) $(TINYPROXY_PATCHES)

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
$(TINYPROXY_BUILD_DIR)/.configured: $(DL_DIR)/$(TINYPROXY_SOURCE) $(TINYPROXY_PATCHES) make/tinyproxy.mk
ifeq (uclibc, $(LIBC_STYLE))
	$(MAKE) gettext-stage
endif
	rm -rf $(BUILD_DIR)/$(TINYPROXY_DIR) $(@D)
	$(TINYPROXY_UNZIP) $(DL_DIR)/$(TINYPROXY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TINYPROXY_PATCHES)" ; \
		then cat $(TINYPROXY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TINYPROXY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TINYPROXY_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TINYPROXY_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TINYPROXY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TINYPROXY_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-shared \
		--enable-transparent-proxy \
		--disable-nls \
	)
#		--disable-static \
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

tinyproxy-unpack: $(TINYPROXY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TINYPROXY_BUILD_DIR)/.built: $(TINYPROXY_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
tinyproxy: $(TINYPROXY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(TINYPROXY_BUILD_DIR)/.staged: $(TINYPROXY_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#tinyproxy-stage: $(TINYPROXY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tinyproxy
#
$(TINYPROXY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tinyproxy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TINYPROXY_PRIORITY)" >>$@
	@echo "Section: $(TINYPROXY_SECTION)" >>$@
	@echo "Version: $(TINYPROXY_VERSION)-$(TINYPROXY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TINYPROXY_MAINTAINER)" >>$@
	@echo "Source: $(TINYPROXY_SITE)/$(TINYPROXY_SOURCE)" >>$@
	@echo "Description: $(TINYPROXY_DESCRIPTION)" >>$@
	@echo "Depends: $(TINYPROXY_DEPENDS)" >>$@
	@echo "Suggests: $(TINYPROXY_SUGGESTS)" >>$@
	@echo "Conflicts: $(TINYPROXY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TINYPROXY_IPK_DIR)/opt/sbin or $(TINYPROXY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TINYPROXY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TINYPROXY_IPK_DIR)/opt/etc/tinyproxy/...
# Documentation files should be installed in $(TINYPROXY_IPK_DIR)/opt/doc/tinyproxy/...
# Daemon startup scripts should be installed in $(TINYPROXY_IPK_DIR)/opt/etc/init.d/S??tinyproxy
#
# You may need to patch your application to make it use these locations.
#
$(TINYPROXY_IPK): $(TINYPROXY_BUILD_DIR)/.built
	rm -rf $(TINYPROXY_IPK_DIR) $(BUILD_DIR)/tinyproxy_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TINYPROXY_BUILD_DIR) install-strip \
		DESTDIR=$(TINYPROXY_IPK_DIR) transform=''
	install -d $(TINYPROXY_IPK_DIR)/opt/share/doc/tinyproxy
	install -m 644 $(TINYPROXY_BUILD_DIR)/[ACINRT]* $(TINYPROXY_IPK_DIR)/opt/share/doc/tinyproxy
#	install -d $(TINYPROXY_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TINYPROXY_SOURCE_DIR)/rc.tinyproxy $(TINYPROXY_IPK_DIR)/opt/etc/init.d/SXXtinyproxy
	$(MAKE) $(TINYPROXY_IPK_DIR)/CONTROL/control
#	install -m 755 $(TINYPROXY_SOURCE_DIR)/postinst $(TINYPROXY_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TINYPROXY_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TINYPROXY_SOURCE_DIR)/prerm $(TINYPROXY_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TINYPROXY_IPK_DIR)/CONTROL/prerm
	echo $(TINYPROXY_CONFFILES) | sed -e 's/ /\n/g' > $(TINYPROXY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TINYPROXY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tinyproxy-ipk: $(TINYPROXY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tinyproxy-clean:
	rm -f $(TINYPROXY_BUILD_DIR)/.built
	-$(MAKE) -C $(TINYPROXY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tinyproxy-dirclean:
	rm -rf $(BUILD_DIR)/$(TINYPROXY_DIR) $(TINYPROXY_BUILD_DIR) $(TINYPROXY_IPK_DIR) $(TINYPROXY_IPK)
#
#
# Some sanity check for the package.
#
tinyproxy-check: $(TINYPROXY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TINYPROXY_IPK)
