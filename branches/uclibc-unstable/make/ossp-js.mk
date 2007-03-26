###########################################################
#
# ossp-js
#
###########################################################
#
# OSSP_JS_VERSION, OSSP_JS_SITE and OSSP_JS_SOURCE define
# the upstream location of the source code for the package.
# OSSP_JS_DIR is the directory which is created when the source
# archive is unpacked.
# OSSP_JS_UNZIP is the command used to unzip the source.
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
OSSP_JS_SITE=ftp://ftp.ossp.org/pkg/lib/js
OSSP_JS_VERSION=1.6.20070208
OSSP_JS_SOURCE=js-$(OSSP_JS_VERSION).tar.gz
OSSP_JS_DIR=js-$(OSSP_JS_VERSION)
OSSP_JS_UNZIP=zcat
OSSP_JS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OSSP_JS_DESCRIPTION=a stand-alone distribution of the JavaScript (JS) programming language reference implementation from Mozilla.
OSSP_JS_SECTION=lang
OSSP_JS_PRIORITY=optional
OSSP_JS_DEPENDS=
OSSP_JS_SUGGESTS=
OSSP_JS_CONFLICTS=

#
# OSSP_JS_IPK_VERSION should be incremented when the ipk changes.
#
OSSP_JS_IPK_VERSION=1

#
# OSSP_JS_CONFFILES should be a list of user-editable files
#OSSP_JS_CONFFILES=/opt/etc/ossp-js.conf /opt/etc/init.d/SXXossp-js

#
# OSSP_JS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#OSSP_JS_PATCHES=$(OSSP_JS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OSSP_JS_CPPFLAGS=
OSSP_JS_LDFLAGS=

#
# OSSP_JS_BUILD_DIR is the directory in which the build is done.
# OSSP_JS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OSSP_JS_IPK_DIR is the directory in which the ipk is built.
# OSSP_JS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OSSP_JS_BUILD_DIR=$(BUILD_DIR)/ossp-js
OSSP_JS_SOURCE_DIR=$(SOURCE_DIR)/ossp-js
OSSP_JS_IPK_DIR=$(BUILD_DIR)/ossp-js-$(OSSP_JS_VERSION)-ipk
OSSP_JS_IPK=$(BUILD_DIR)/ossp-js_$(OSSP_JS_VERSION)-$(OSSP_JS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ossp-js-source ossp-js-unpack ossp-js ossp-js-stage ossp-js-ipk ossp-js-clean ossp-js-dirclean ossp-js-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OSSP_JS_SOURCE):
	$(WGET) -P $(DL_DIR) $(OSSP_JS_SITE)/$(OSSP_JS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ossp-js-source: $(DL_DIR)/$(OSSP_JS_SOURCE) $(OSSP_JS_PATCHES)

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
$(OSSP_JS_BUILD_DIR)/.configured: $(DL_DIR)/$(OSSP_JS_SOURCE) $(OSSP_JS_PATCHES) make/ossp-js.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(OSSP_JS_DIR) $(OSSP_JS_BUILD_DIR)
	$(OSSP_JS_UNZIP) $(DL_DIR)/$(OSSP_JS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(OSSP_JS_PATCHES)" ; \
		then cat $(OSSP_JS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(OSSP_JS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(OSSP_JS_DIR)" != "$(OSSP_JS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(OSSP_JS_DIR) $(OSSP_JS_BUILD_DIR) ; \
	fi
	(cd $(OSSP_JS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OSSP_JS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OSSP_JS_LDFLAGS)" \
		ac_cv_va_copy=C99 \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
ifneq ($(HOSTCC), $(TARGET_CC))
	cp $(OSSP_JS_SOURCE_DIR)/prtypes.h $(OSSP_JS_BUILD_DIR)/
endif
	$(PATCH_LIBTOOL) $(OSSP_JS_BUILD_DIR)/libtool
	touch $@

ossp-js-unpack: $(OSSP_JS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#		CPPFLAGS="-I. -DCROSS_COMPILE=1 -DIS_BIG_ENDIAN=1" \
#
$(OSSP_JS_BUILD_DIR)/.built: $(OSSP_JS_BUILD_DIR)/.configured
	rm -f $@
ifneq ($(HOSTCC), $(TARGET_CC))
	$(MAKE) -C $(OSSP_JS_BUILD_DIR) jscpucfg \
		CC=$(HOSTCC) \
		CPPFLAGS="-I. -DCROSS_COMPILE=1" \
		LDFLAGS=""
endif
	$(MAKE) -C $(OSSP_JS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
ossp-js: $(OSSP_JS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OSSP_JS_BUILD_DIR)/.staged: $(OSSP_JS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(OSSP_JS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/js.pc
	touch $@

ossp-js-stage: $(OSSP_JS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ossp-js
#
$(OSSP_JS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ossp-js" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OSSP_JS_PRIORITY)" >>$@
	@echo "Section: $(OSSP_JS_SECTION)" >>$@
	@echo "Version: $(OSSP_JS_VERSION)-$(OSSP_JS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OSSP_JS_MAINTAINER)" >>$@
	@echo "Source: $(OSSP_JS_SITE)/$(OSSP_JS_SOURCE)" >>$@
	@echo "Description: $(OSSP_JS_DESCRIPTION)" >>$@
	@echo "Depends: $(OSSP_JS_DEPENDS)" >>$@
	@echo "Suggests: $(OSSP_JS_SUGGESTS)" >>$@
	@echo "Conflicts: $(OSSP_JS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OSSP_JS_IPK_DIR)/opt/sbin or $(OSSP_JS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OSSP_JS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OSSP_JS_IPK_DIR)/opt/etc/ossp-js/...
# Documentation files should be installed in $(OSSP_JS_IPK_DIR)/opt/doc/ossp-js/...
# Daemon startup scripts should be installed in $(OSSP_JS_IPK_DIR)/opt/etc/init.d/S??ossp-js
#
# You may need to patch your application to make it use these locations.
#
$(OSSP_JS_IPK): $(OSSP_JS_BUILD_DIR)/.built
	rm -rf $(OSSP_JS_IPK_DIR) $(BUILD_DIR)/ossp-js_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(OSSP_JS_BUILD_DIR) DESTDIR=$(OSSP_JS_IPK_DIR) install
	$(STRIP_COMMAND) $(OSSP_JS_IPK_DIR)/opt/bin/js $(OSSP_JS_IPK_DIR)/opt/lib/libjs.so.*
#	install -d $(OSSP_JS_IPK_DIR)/opt/etc/
#	install -m 644 $(OSSP_JS_SOURCE_DIR)/ossp-js.conf $(OSSP_JS_IPK_DIR)/opt/etc/ossp-js.conf
#	install -d $(OSSP_JS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(OSSP_JS_SOURCE_DIR)/rc.ossp-js $(OSSP_JS_IPK_DIR)/opt/etc/init.d/SXXossp-js
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXossp-js
	$(MAKE) $(OSSP_JS_IPK_DIR)/CONTROL/control
#	install -m 755 $(OSSP_JS_SOURCE_DIR)/postinst $(OSSP_JS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(OSSP_JS_SOURCE_DIR)/prerm $(OSSP_JS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(OSSP_JS_CONFFILES) | sed -e 's/ /\n/g' > $(OSSP_JS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OSSP_JS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ossp-js-ipk: $(OSSP_JS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ossp-js-clean:
	rm -f $(OSSP_JS_BUILD_DIR)/.built
	-$(MAKE) -C $(OSSP_JS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ossp-js-dirclean:
	rm -rf $(BUILD_DIR)/$(OSSP_JS_DIR) $(OSSP_JS_BUILD_DIR) $(OSSP_JS_IPK_DIR) $(OSSP_JS_IPK)
#
#
# Some sanity check for the package.
#
ossp-js-check: $(OSSP_JS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OSSP_JS_IPK)
