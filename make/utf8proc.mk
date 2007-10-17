###########################################################
#
# utf8proc
#
###########################################################
#
# UTF8PROC_VERSION, UTF8PROC_SITE and UTF8PROC_SOURCE define
# the upstream location of the source code for the package.
# UTF8PROC_DIR is the directory which is created when the source
# archive is unpacked.
# UTF8PROC_UNZIP is the command used to unzip the source.
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
UTF8PROC_SITE=http://www.flexiguided.de/pub
UTF8PROC_VERSION=1.1.2
UTF8PROC_SOURCE=utf8proc-v$(UTF8PROC_VERSION).tar.gz
UTF8PROC_DIR=utf8proc
UTF8PROC_UNZIP=zcat
UTF8PROC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UTF8PROC_DESCRIPTION=utf8proc is a library for processing UTF-8 encoded Unicode strings.
UTF8PROC_SECTION=lib
UTF8PROC_PRIORITY=optional
UTF8PROC_DEPENDS=
UTF8PROC_SUGGESTS=
UTF8PROC_CONFLICTS=

#
# UTF8PROC_IPK_VERSION should be incremented when the ipk changes.
#
UTF8PROC_IPK_VERSION=1

#
# UTF8PROC_CONFFILES should be a list of user-editable files
#UTF8PROC_CONFFILES=/opt/etc/utf8proc.conf /opt/etc/init.d/SXXutf8proc

#
# UTF8PROC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#UTF8PROC_PATCHES=$(UTF8PROC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UTF8PROC_CPPFLAGS=
UTF8PROC_LDFLAGS=

#
# UTF8PROC_BUILD_DIR is the directory in which the build is done.
# UTF8PROC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UTF8PROC_IPK_DIR is the directory in which the ipk is built.
# UTF8PROC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UTF8PROC_BUILD_DIR=$(BUILD_DIR)/utf8proc
UTF8PROC_SOURCE_DIR=$(SOURCE_DIR)/utf8proc
UTF8PROC_IPK_DIR=$(BUILD_DIR)/utf8proc-$(UTF8PROC_VERSION)-ipk
UTF8PROC_IPK=$(BUILD_DIR)/utf8proc_$(UTF8PROC_VERSION)-$(UTF8PROC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: utf8proc-source utf8proc-unpack utf8proc utf8proc-stage utf8proc-ipk utf8proc-clean utf8proc-dirclean utf8proc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UTF8PROC_SOURCE):
	$(WGET) -P $(DL_DIR) $(UTF8PROC_SITE)/$(UTF8PROC_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(UTF8PROC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
utf8proc-source: $(DL_DIR)/$(UTF8PROC_SOURCE) $(UTF8PROC_PATCHES)

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
$(UTF8PROC_BUILD_DIR)/.configured: $(DL_DIR)/$(UTF8PROC_SOURCE) $(UTF8PROC_PATCHES) make/utf8proc.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(UTF8PROC_DIR) $(UTF8PROC_BUILD_DIR)
	$(UTF8PROC_UNZIP) $(DL_DIR)/$(UTF8PROC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UTF8PROC_PATCHES)" ; \
		then cat $(UTF8PROC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(UTF8PROC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UTF8PROC_DIR)" != "$(UTF8PROC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(UTF8PROC_DIR) $(UTF8PROC_BUILD_DIR) ; \
	fi
#	(cd $(UTF8PROC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UTF8PROC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UTF8PROC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

utf8proc-unpack: $(UTF8PROC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UTF8PROC_BUILD_DIR)/.built: $(UTF8PROC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) utf8proc.o \
		$(TARGET_CONFIGURE_OPTS) \
		cc="$(TARGET_CC) $(STAGING_CPPFLAGS) $(UTF8PROC_CPPFLAGS)" \
		;
	$(MAKE) -C $(@D) libutf8proc.so \
		$(TARGET_CONFIGURE_OPTS) \
		cc="$(TARGET_CC) $(STAGING_LDFLAGS) $(UTF8PROC_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
utf8proc: $(UTF8PROC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UTF8PROC_BUILD_DIR)/.staged: $(UTF8PROC_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(UTF8PROC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	install -d $(STAGING_INCLUDE_DIR)
	install -m 644 $(UTF8PROC_BUILD_DIR)/utf8proc.h $(STAGING_INCLUDE_DIR)/
	install -d $(STAGING_LIB_DIR)
	install -m 755 $(UTF8PROC_BUILD_DIR)/libutf8proc.so $(STAGING_LIB_DIR)/
	touch $@

utf8proc-stage: $(UTF8PROC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/utf8proc
#
$(UTF8PROC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: utf8proc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UTF8PROC_PRIORITY)" >>$@
	@echo "Section: $(UTF8PROC_SECTION)" >>$@
	@echo "Version: $(UTF8PROC_VERSION)-$(UTF8PROC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UTF8PROC_MAINTAINER)" >>$@
	@echo "Source: $(UTF8PROC_SITE)/$(UTF8PROC_SOURCE)" >>$@
	@echo "Description: $(UTF8PROC_DESCRIPTION)" >>$@
	@echo "Depends: $(UTF8PROC_DEPENDS)" >>$@
	@echo "Suggests: $(UTF8PROC_SUGGESTS)" >>$@
	@echo "Conflicts: $(UTF8PROC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UTF8PROC_IPK_DIR)/opt/sbin or $(UTF8PROC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UTF8PROC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UTF8PROC_IPK_DIR)/opt/etc/utf8proc/...
# Documentation files should be installed in $(UTF8PROC_IPK_DIR)/opt/doc/utf8proc/...
# Daemon startup scripts should be installed in $(UTF8PROC_IPK_DIR)/opt/etc/init.d/S??utf8proc
#
# You may need to patch your application to make it use these locations.
#
$(UTF8PROC_IPK): $(UTF8PROC_BUILD_DIR)/.built
	rm -rf $(UTF8PROC_IPK_DIR) $(BUILD_DIR)/utf8proc_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(UTF8PROC_BUILD_DIR) DESTDIR=$(UTF8PROC_IPK_DIR) install-strip
	install -d $(UTF8PROC_IPK_DIR)/opt/include $(UTF8PROC_IPK_DIR)/opt/lib
	install -m 644 $(UTF8PROC_BUILD_DIR)/utf8proc.h $(UTF8PROC_IPK_DIR)/opt/include/
	install -m 755 $(UTF8PROC_BUILD_DIR)/libutf8proc.so $(UTF8PROC_IPK_DIR)/opt/lib/
	$(STRIP_COMMAND) $(UTF8PROC_IPK_DIR)/opt/lib/libutf8proc.so
	$(MAKE) $(UTF8PROC_IPK_DIR)/CONTROL/control
	echo $(UTF8PROC_CONFFILES) | sed -e 's/ /\n/g' > $(UTF8PROC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UTF8PROC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
utf8proc-ipk: $(UTF8PROC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
utf8proc-clean:
	rm -f $(UTF8PROC_BUILD_DIR)/.built
	-$(MAKE) -C $(UTF8PROC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
utf8proc-dirclean:
	rm -rf $(BUILD_DIR)/$(UTF8PROC_DIR) $(UTF8PROC_BUILD_DIR) $(UTF8PROC_IPK_DIR) $(UTF8PROC_IPK)
#
#
# Some sanity check for the package.
#
utf8proc-check: $(UTF8PROC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(UTF8PROC_IPK)
