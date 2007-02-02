###########################################################
#
# tin
#
###########################################################

# You must replace "tin" and "TIN" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# TIN_VERSION, TIN_SITE and TIN_SOURCE define
# the upstream location of the source code for the package.
# TIN_DIR is the directory which is created when the source
# archive is unpacked.
# TIN_UNZIP is the command used to unzip the source.
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
TIN_SITE=ftp://ftp.tin.org/pub/news/clients/tin/v1.8
TIN_SITE2=ftp://ftp.stikman.com/pub/tin/v1.8
TIN_VERSION=1.8.3
TIN_SOURCE=tin-$(TIN_VERSION).tar.gz
TIN_DIR=tin-$(TIN_VERSION)
TIN_UNZIP=zcat
TIN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TIN_DESCRIPTION=tin is a threaded NNTP and spool based UseNet newsreader
TIN_SECTION=misc
TIN_PRIORITY=optional
TIN_DEPENDS=

#
# TIN_IPK_VERSION should be incremented when the ipk changes.
#
TIN_IPK_VERSION=1

#
# TIN_CONFFILES should be a list of user-editable files
#TIN_CONFFILES=/opt/etc/tin.conf /opt/etc/init.d/SXXtin

#
# TIN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TIN_PATCHES=$(TIN_SOURCE_DIR)/src-Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TIN_CPPFLAGS=
TIN_LDFLAGS=

#
# TIN_BUILD_DIR is the directory in which the build is done.
# TIN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TIN_IPK_DIR is the directory in which the ipk is built.
# TIN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TIN_BUILD_DIR=$(BUILD_DIR)/tin
TIN_SOURCE_DIR=$(SOURCE_DIR)/tin
TIN_IPK_DIR=$(BUILD_DIR)/tin-$(TIN_VERSION)-ipk
TIN_IPK=$(BUILD_DIR)/tin_$(TIN_VERSION)-$(TIN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tin-source tin-unpack tin tin-stage tin-ipk tin-clean tin-dirclean tin-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TIN_SOURCE):
	$(WGET) -P $(DL_DIR) $(TIN_SITE)/$(TIN_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(TIN_SITE2)/$(TIN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tin-source: $(DL_DIR)/$(TIN_SOURCE) $(TIN_PATCHES)

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
$(TIN_BUILD_DIR)/.configured: $(DL_DIR)/$(TIN_SOURCE) $(TIN_PATCHES)
	make ncurses-stage
	rm -rf $(BUILD_DIR)/$(TIN_DIR) $(TIN_BUILD_DIR)
	$(TIN_UNZIP) $(DL_DIR)/$(TIN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(TIN_PATCHES) | patch -d $(BUILD_DIR)/$(TIN_DIR) -p1
	mv $(BUILD_DIR)/$(TIN_DIR) $(TIN_BUILD_DIR)
	(cd $(TIN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TIN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TIN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-build-cc=$(HOSTCC) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(TIN_BUILD_DIR)/.configured

tin-unpack: $(TIN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TIN_BUILD_DIR)/.built: $(TIN_BUILD_DIR)/.configured
	rm -f $(TIN_BUILD_DIR)/.built
	$(MAKE) -C $(TIN_BUILD_DIR) build BUILD_CC=$(HOSTCC)
	touch $(TIN_BUILD_DIR)/.built

#
# This is the build convenience target.
#
tin: $(TIN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TIN_BUILD_DIR)/.staged: $(TIN_BUILD_DIR)/.built
	rm -f $(TIN_BUILD_DIR)/.staged
	$(MAKE) -C $(TIN_BUILD_DIR) DESTDIR=$(STAGING_DIR) STRIP="$(STRIP_COMMAND)" install
	touch $(TIN_BUILD_DIR)/.staged

tin-stage: $(TIN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tin
#
$(TIN_IPK_DIR)/CONTROL/control:
	@install -d $(TIN_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: tin" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TIN_PRIORITY)" >>$@
	@echo "Section: $(TIN_SECTION)" >>$@
	@echo "Version: $(TIN_VERSION)-$(TIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TIN_MAINTAINER)" >>$@
	@echo "Source: $(TIN_SITE)/$(TIN_SOURCE)" >>$@
	@echo "Description: $(TIN_DESCRIPTION)" >>$@
	@echo "Depends: $(TIN_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TIN_IPK_DIR)/opt/sbin or $(TIN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TIN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TIN_IPK_DIR)/opt/etc/tin/...
# Documentation files should be installed in $(TIN_IPK_DIR)/opt/doc/tin/...
# Daemon startup scripts should be installed in $(TIN_IPK_DIR)/opt/etc/init.d/S??tin
#
# You may need to patch your application to make it use these locations.
#
$(TIN_IPK): $(TIN_BUILD_DIR)/.built
	rm -rf $(TIN_IPK_DIR) $(BUILD_DIR)/tin_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TIN_BUILD_DIR) DESTDIR=$(TIN_IPK_DIR) STRIP="$(STRIP_COMMAND)" install
	install -d $(TIN_IPK_DIR)/opt/etc/
#	install -m 644 $(TIN_SOURCE_DIR)/tin.conf $(TIN_IPK_DIR)/opt/etc/tin.conf
#	install -d $(TIN_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TIN_SOURCE_DIR)/rc.tin $(TIN_IPK_DIR)/opt/etc/init.d/SXXtin
	$(MAKE) $(TIN_IPK_DIR)/CONTROL/control
#	install -m 755 $(TIN_SOURCE_DIR)/postinst $(TIN_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TIN_SOURCE_DIR)/prerm $(TIN_IPK_DIR)/CONTROL/prerm
#	echo $(TIN_CONFFILES) | sed -e 's/ /\n/g' > $(TIN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TIN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tin-ipk: $(TIN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tin-clean:
	-$(MAKE) -C $(TIN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tin-dirclean:
	rm -rf $(BUILD_DIR)/$(TIN_DIR) $(TIN_BUILD_DIR) $(TIN_IPK_DIR) $(TIN_IPK)

#
# Some sanity check for the package.
#
tin-check: $(TIN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TIN_IPK)
