###########################################################
#
# catdoc
#
###########################################################
#
# CATDOC_VERSION, CATDOC_SITE and CATDOC_SOURCE define
# the upstream location of the source code for the package.
# CATDOC_DIR is the directory which is created when the source
# archive is unpacked.
# CATDOC_UNZIP is the command used to unzip the source.
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
CATDOC_SITE=http://ftp.45.free.net/pub/catdoc
CATDOC_VERSION=0.94.2
CATDOC_SOURCE=catdoc-$(CATDOC_VERSION).tar.gz
CATDOC_DIR=catdoc-$(CATDOC_VERSION)
CATDOC_UNZIP=zcat
CATDOC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CATDOC_DESCRIPTION=catdoc can extract text from Microsoft word files, and xls2csv does roughly same for Excel files.
CATDOC_SECTION=misc
CATDOC_PRIORITY=optional
CATDOC_DEPENDS=
CATDOC_SUGGESTS=
CATDOC_CONFLICTS=

#
# CATDOC_IPK_VERSION should be incremented when the ipk changes.
#
CATDOC_IPK_VERSION=1

#
# CATDOC_CONFFILES should be a list of user-editable files
#CATDOC_CONFFILES=/opt/etc/catdoc.conf /opt/etc/init.d/SXXcatdoc

#
# CATDOC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CATDOC_PATCHES=$(CATDOC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CATDOC_CPPFLAGS=
CATDOC_LDFLAGS=

#
# CATDOC_BUILD_DIR is the directory in which the build is done.
# CATDOC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CATDOC_IPK_DIR is the directory in which the ipk is built.
# CATDOC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CATDOC_BUILD_DIR=$(BUILD_DIR)/catdoc
CATDOC_SOURCE_DIR=$(SOURCE_DIR)/catdoc
CATDOC_IPK_DIR=$(BUILD_DIR)/catdoc-$(CATDOC_VERSION)-ipk
CATDOC_IPK=$(BUILD_DIR)/catdoc_$(CATDOC_VERSION)-$(CATDOC_IPK_VERSION)_$(TARGET_ARCH).ipk

ifneq ($(HOSTCC),$(TARGET_CC))
CATDOC_CROSS_CONFIGURE_ENV=ac_cv_func_setvbuf_reversed=no
endif

.PHONY: catdoc-source catdoc-unpack catdoc catdoc-stage catdoc-ipk catdoc-clean catdoc-dirclean catdoc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CATDOC_SOURCE):
	$(WGET) -P $(DL_DIR) $(CATDOC_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
catdoc-source: $(DL_DIR)/$(CATDOC_SOURCE) $(CATDOC_PATCHES)

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
$(CATDOC_BUILD_DIR)/.configured: $(DL_DIR)/$(CATDOC_SOURCE) $(CATDOC_PATCHES) make/catdoc.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(CATDOC_DIR) $(CATDOC_BUILD_DIR)
	$(CATDOC_UNZIP) $(DL_DIR)/$(CATDOC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CATDOC_PATCHES)" ; \
		then cat $(CATDOC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CATDOC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CATDOC_DIR)" != "$(CATDOC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CATDOC_DIR) $(CATDOC_BUILD_DIR) ; \
	fi
	(cd $(CATDOC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CATDOC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CATDOC_LDFLAGS)" \
		$(CATDOC_CROSS_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-wish \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(CATDOC_BUILD_DIR)/libtool
	touch $(CATDOC_BUILD_DIR)/.configured

catdoc-unpack: $(CATDOC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CATDOC_BUILD_DIR)/.built: $(CATDOC_BUILD_DIR)/.configured
	rm -f $(CATDOC_BUILD_DIR)/.built
	$(MAKE) -C $(CATDOC_BUILD_DIR)
	touch $(CATDOC_BUILD_DIR)/.built

#
# This is the build convenience target.
#
catdoc: $(CATDOC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CATDOC_BUILD_DIR)/.staged: $(CATDOC_BUILD_DIR)/.built
	rm -f $(CATDOC_BUILD_DIR)/.staged
	$(MAKE) -C $(CATDOC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CATDOC_BUILD_DIR)/.staged

catdoc-stage: $(CATDOC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/catdoc
#
$(CATDOC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: catdoc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CATDOC_PRIORITY)" >>$@
	@echo "Section: $(CATDOC_SECTION)" >>$@
	@echo "Version: $(CATDOC_VERSION)-$(CATDOC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CATDOC_MAINTAINER)" >>$@
	@echo "Source: $(CATDOC_SITE)/$(CATDOC_SOURCE)" >>$@
	@echo "Description: $(CATDOC_DESCRIPTION)" >>$@
	@echo "Depends: $(CATDOC_DEPENDS)" >>$@
	@echo "Suggests: $(CATDOC_SUGGESTS)" >>$@
	@echo "Conflicts: $(CATDOC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CATDOC_IPK_DIR)/opt/sbin or $(CATDOC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CATDOC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CATDOC_IPK_DIR)/opt/etc/catdoc/...
# Documentation files should be installed in $(CATDOC_IPK_DIR)/opt/doc/catdoc/...
# Daemon startup scripts should be installed in $(CATDOC_IPK_DIR)/opt/etc/init.d/S??catdoc
#
# You may need to patch your application to make it use these locations.
#
$(CATDOC_IPK): $(CATDOC_BUILD_DIR)/.built
	rm -rf $(CATDOC_IPK_DIR) $(BUILD_DIR)/catdoc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CATDOC_BUILD_DIR) prefix=$(CATDOC_IPK_DIR)/opt install
	rm -f $(CATDOC_IPK_DIR)/opt/bin/wordview
	$(STRIP_COMMAND) $(CATDOC_IPK_DIR)/opt/bin/*
#	install -d $(CATDOC_IPK_DIR)/opt/etc/
#	install -m 644 $(CATDOC_SOURCE_DIR)/catdoc.conf $(CATDOC_IPK_DIR)/opt/etc/catdoc.conf
#	install -d $(CATDOC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CATDOC_SOURCE_DIR)/rc.catdoc $(CATDOC_IPK_DIR)/opt/etc/init.d/SXXcatdoc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXcatdoc
	$(MAKE) $(CATDOC_IPK_DIR)/CONTROL/control
#	install -m 755 $(CATDOC_SOURCE_DIR)/postinst $(CATDOC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CATDOC_SOURCE_DIR)/prerm $(CATDOC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(CATDOC_CONFFILES) | sed -e 's/ /\n/g' > $(CATDOC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CATDOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
catdoc-ipk: $(CATDOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
catdoc-clean:
	rm -f $(CATDOC_BUILD_DIR)/.built
	-$(MAKE) -C $(CATDOC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
catdoc-dirclean:
	rm -rf $(BUILD_DIR)/$(CATDOC_DIR) $(CATDOC_BUILD_DIR) $(CATDOC_IPK_DIR) $(CATDOC_IPK)
#
#
# Some sanity check for the package.
#
catdoc-check: $(CATDOC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CATDOC_IPK)
