###########################################################
#
# slsc
#
###########################################################
#
# SLSC_VERSION, SLSC_SITE and SLSC_SOURCE define
# the upstream location of the source code for the package.
# SLSC_DIR is the directory which is created when the source
# archive is unpacked.
# SLSC_UNZIP is the command used to unzip the source.
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
SLSC_SITE=http://ftp.debian.org/debian/pool/main/s/slsc
SLSC_VERSION=0.2.3
SLSC_SOURCE=slsc_$(SLSC_VERSION).orig.tar.gz
SLSC_DIR=slsc
SLSC_UNZIP=zcat
SLSC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SLSC_DESCRIPTION=S-Language port of the classic SC spreadsheet.
SLSC_SECTION=misc
SLSC_PRIORITY=optional
SLSC_DEPENDS=
SLSC_SUGGESTS=
SLSC_CONFLICTS=

#
# SLSC_IPK_VERSION should be incremented when the ipk changes.
#
SLSC_IPK_VERSION=1

#
# SLSC_CONFFILES should be a list of user-editable files
#SLSC_CONFFILES=/opt/etc/slsc.conf /opt/etc/init.d/SXXslsc

#
# SLSC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SLSC_PATCHES=$(SLSC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SLSC_CPPFLAGS=
SLSC_LDFLAGS=

#
# SLSC_BUILD_DIR is the directory in which the build is done.
# SLSC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SLSC_IPK_DIR is the directory in which the ipk is built.
# SLSC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SLSC_BUILD_DIR=$(BUILD_DIR)/slsc
SLSC_SOURCE_DIR=$(SOURCE_DIR)/slsc
SLSC_IPK_DIR=$(BUILD_DIR)/slsc-$(SLSC_VERSION)-ipk
SLSC_IPK=$(BUILD_DIR)/slsc_$(SLSC_VERSION)-$(SLSC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: slsc-source slsc-unpack slsc slsc-stage slsc-ipk slsc-clean slsc-dirclean slsc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SLSC_SOURCE):
	$(WGET) -P $(DL_DIR) $(SLSC_SITE)/$(SLSC_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SLSC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
slsc-source: $(DL_DIR)/$(SLSC_SOURCE) $(SLSC_PATCHES)

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
$(SLSC_BUILD_DIR)/.configured: $(DL_DIR)/$(SLSC_SOURCE) $(SLSC_PATCHES) make/slsc.mk
	$(MAKE) slang1-stage termcap-stage
	rm -rf $(BUILD_DIR)/$(SLSC_DIR) $(SLSC_BUILD_DIR)
	$(SLSC_UNZIP) $(DL_DIR)/$(SLSC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SLSC_PATCHES)" ; \
		then cat $(SLSC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SLSC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SLSC_DIR)" != "$(SLSC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SLSC_DIR) $(SLSC_BUILD_DIR) ; \
	fi
	sed -i.orig -e '/include_and_lib in $$JD_Search_Dirs/s|$$JD_Search_Dirs|$(STAGING_INCLUDE_DIR)/slang1,$(STAGING_LIB_DIR)/slang1|' \
		$(SLSC_BUILD_DIR)/configure
	sed -i.orig -e '/SLang_Error_Routine/d' $(SLSC_BUILD_DIR)/src/sc.c
	sed -i.orig -e '/EXECLIBS *=/s|$$|$(STAGING_LDFLAGS)|' $(SLSC_BUILD_DIR)/src/Makefile.in
	(cd $(SLSC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SLSC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SLSC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-slang-includes=$(STAGING_INCLUDE_DIR)/slang1 \
		--with-slang-libraries=$(STAGING_LIB_DIR)/slang1 \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(SLSC_BUILD_DIR)/libtool
	touch $@

slsc-unpack: $(SLSC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SLSC_BUILD_DIR)/.built: $(SLSC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SLSC_BUILD_DIR) \
		SLSC_ROOT=/opt/lib/slsc \
		SLSC_BIN=/opt/bin \
		;
	touch $@

#
# This is the build convenience target.
#
slsc: $(SLSC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SLSC_BUILD_DIR)/.staged: $(SLSC_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(SLSC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

slsc-stage: $(SLSC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/slsc
#
$(SLSC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: slsc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SLSC_PRIORITY)" >>$@
	@echo "Section: $(SLSC_SECTION)" >>$@
	@echo "Version: $(SLSC_VERSION)-$(SLSC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SLSC_MAINTAINER)" >>$@
	@echo "Source: $(SLSC_SITE)/$(SLSC_SOURCE)" >>$@
	@echo "Description: $(SLSC_DESCRIPTION)" >>$@
	@echo "Depends: $(SLSC_DEPENDS)" >>$@
	@echo "Suggests: $(SLSC_SUGGESTS)" >>$@
	@echo "Conflicts: $(SLSC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SLSC_IPK_DIR)/opt/sbin or $(SLSC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SLSC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SLSC_IPK_DIR)/opt/etc/slsc/...
# Documentation files should be installed in $(SLSC_IPK_DIR)/opt/doc/slsc/...
# Daemon startup scripts should be installed in $(SLSC_IPK_DIR)/opt/etc/init.d/S??slsc
#
# You may need to patch your application to make it use these locations.
#
$(SLSC_IPK): $(SLSC_BUILD_DIR)/.built
	rm -rf $(SLSC_IPK_DIR) $(BUILD_DIR)/slsc_*_$(TARGET_ARCH).ipk
	install -d $(SLSC_IPK_DIR)/opt/lib
	$(MAKE) -C $(SLSC_BUILD_DIR) DESTDIR=$(SLSC_IPK_DIR) install \
		SLSC_ROOT=$(SLSC_IPK_DIR)/opt/lib/slsc \
		SLSC_BIN=$(SLSC_IPK_DIR)/opt/bin \
		;
	$(STRIP_COMMAND) $(SLSC_IPK_DIR)/opt/bin/slsc $(SLSC_IPK_DIR)/opt/lib/slsc/vprint
	$(MAKE) $(SLSC_IPK_DIR)/CONTROL/control
	echo $(SLSC_CONFFILES) | sed -e 's/ /\n/g' > $(SLSC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SLSC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
slsc-ipk: $(SLSC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
slsc-clean:
	rm -f $(SLSC_BUILD_DIR)/.built
	-$(MAKE) -C $(SLSC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
slsc-dirclean:
	rm -rf $(BUILD_DIR)/$(SLSC_DIR) $(SLSC_BUILD_DIR) $(SLSC_IPK_DIR) $(SLSC_IPK)
#
#
# Some sanity check for the package.
#
slsc-check: $(SLSC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SLSC_IPK)
