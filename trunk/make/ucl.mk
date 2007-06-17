###########################################################
#
# ucl
#
###########################################################
#
# UCL_VERSION, UCL_SITE and UCL_SOURCE define
# the upstream location of the source code for the package.
# UCL_DIR is the directory which is created when the source
# archive is unpacked.
# UCL_UNZIP is the command used to unzip the source.
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
UCL_SITE=http://www.oberhumer.com/opensource/ucl/download
UCL_VERSION=1.03
UCL_SOURCE=ucl-$(UCL_VERSION).tar.gz
UCL_DIR=ucl-$(UCL_VERSION)
UCL_UNZIP=zcat
UCL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UCL_DESCRIPTION=UCL is a portable lossless data compression library written in ANSI C.
UCL_SECTION=lib
UCL_PRIORITY=optional
UCL_DEPENDS=
UCL_SUGGESTS=
UCL_CONFLICTS=

#
# UCL_IPK_VERSION should be incremented when the ipk changes.
#
UCL_IPK_VERSION=1

#
# UCL_CONFFILES should be a list of user-editable files
#UCL_CONFFILES=/opt/etc/ucl.conf /opt/etc/init.d/SXXucl

#
# UCL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#UCL_PATCHES=$(UCL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UCL_CPPFLAGS=
UCL_LDFLAGS=

#
# UCL_BUILD_DIR is the directory in which the build is done.
# UCL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UCL_IPK_DIR is the directory in which the ipk is built.
# UCL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UCL_BUILD_DIR=$(BUILD_DIR)/ucl
UCL_SOURCE_DIR=$(SOURCE_DIR)/ucl
UCL_IPK_DIR=$(BUILD_DIR)/ucl-$(UCL_VERSION)-ipk
UCL_IPK=$(BUILD_DIR)/ucl_$(UCL_VERSION)-$(UCL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ucl-source ucl-unpack ucl ucl-stage ucl-ipk ucl-clean ucl-dirclean ucl-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UCL_SOURCE):
	$(WGET) -P $(DL_DIR) $(UCL_SITE)/$(UCL_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(UCL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ucl-source: $(DL_DIR)/$(UCL_SOURCE) $(UCL_PATCHES)

$(UCL_BUILD_DIR)/.unpacked: $(DL_DIR)/$(UCL_SOURCE) $(UCL_PATCHES) make/ucl.mk
	rm -rf $(BUILD_DIR)/$(UCL_DIR) $(UCL_BUILD_DIR)
	$(UCL_UNZIP) $(DL_DIR)/$(UCL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UCL_PATCHES)" ; \
		then cat $(UCL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(UCL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UCL_DIR)" != "$(UCL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(UCL_DIR) $(UCL_BUILD_DIR) ; \
	fi
	touch $@

ucl-unpack: $(UCL_BUILD_DIR)/.unpacked

$(UCL_BUILD_DIR)/.configured: $(UCL_BUILD_DIR)/.unpacked
#	$(MAKE) <bar>-stage <baz>-stage
	(cd $(UCL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UCL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UCL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-shared \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(UCL_BUILD_DIR)/libtool
	touch $@

ucl-config: $(UCL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UCL_BUILD_DIR)/.built: $(UCL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(UCL_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
ucl: $(UCL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UCL_BUILD_DIR)/.staged: $(UCL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(UCL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libucl.la
	touch $@

ucl-stage: $(UCL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ucl
#
$(UCL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ucl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UCL_PRIORITY)" >>$@
	@echo "Section: $(UCL_SECTION)" >>$@
	@echo "Version: $(UCL_VERSION)-$(UCL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UCL_MAINTAINER)" >>$@
	@echo "Source: $(UCL_SITE)/$(UCL_SOURCE)" >>$@
	@echo "Description: $(UCL_DESCRIPTION)" >>$@
	@echo "Depends: $(UCL_DEPENDS)" >>$@
	@echo "Suggests: $(UCL_SUGGESTS)" >>$@
	@echo "Conflicts: $(UCL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UCL_IPK_DIR)/opt/sbin or $(UCL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UCL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UCL_IPK_DIR)/opt/etc/ucl/...
# Documentation files should be installed in $(UCL_IPK_DIR)/opt/doc/ucl/...
# Daemon startup scripts should be installed in $(UCL_IPK_DIR)/opt/etc/init.d/S??ucl
#
# You may need to patch your application to make it use these locations.
#
$(UCL_IPK): $(UCL_BUILD_DIR)/.built
	rm -rf $(UCL_IPK_DIR) $(BUILD_DIR)/ucl_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(UCL_BUILD_DIR) DESTDIR=$(UCL_IPK_DIR) install-strip
	rm -f $(UCL_IPK_DIR)/opt/lib/libucl.la
#	install -d $(UCL_IPK_DIR)/opt/etc/
#	install -m 644 $(UCL_SOURCE_DIR)/ucl.conf $(UCL_IPK_DIR)/opt/etc/ucl.conf
#	install -d $(UCL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(UCL_SOURCE_DIR)/rc.ucl $(UCL_IPK_DIR)/opt/etc/init.d/SXXucl
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UCL_IPK_DIR)/opt/etc/init.d/SXXucl
	$(MAKE) $(UCL_IPK_DIR)/CONTROL/control
#	install -m 755 $(UCL_SOURCE_DIR)/postinst $(UCL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UCL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(UCL_SOURCE_DIR)/prerm $(UCL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UCL_IPK_DIR)/CONTROL/prerm
	echo $(UCL_CONFFILES) | sed -e 's/ /\n/g' > $(UCL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UCL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ucl-ipk: $(UCL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ucl-clean:
	rm -f $(UCL_BUILD_DIR)/.built
	-$(MAKE) -C $(UCL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ucl-dirclean:
	rm -rf $(BUILD_DIR)/$(UCL_DIR) $(UCL_BUILD_DIR) $(UCL_IPK_DIR) $(UCL_IPK)
#
#
# Some sanity check for the package.
#
ucl-check: $(UCL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(UCL_IPK)
