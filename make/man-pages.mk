###########################################################
#
# man-pages
#
###########################################################

#
# MAN_PAGES_VERSION, MAN_PAGES_SITE and MAN_PAGES_SOURCE define
# the upstream location of the source code for the package.
# MAN_PAGES_DIR is the directory which is created when the source
# archive is unpacked.
# MAN_PAGES_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
MAN_PAGES_SITE=http://www.kernel.org/pub/linux/docs/manpages
MAN_PAGES_VERSION=2.76
MAN_PAGES_SOURCE=man-pages-$(MAN_PAGES_VERSION).tar.gz
MAN_PAGES_DIR=man-pages-$(MAN_PAGES_VERSION)
MAN_PAGES_UNZIP=zcat
MAN_PAGES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MAN_PAGES_DESCRIPTION=unix manual pages
MAN_PAGES_SECTION=documentation
MAN_PAGES_PRIORITY=optional
MAN_PAGES_DEPENDS=man
MAN_PAGES_CONFLICTS=

#
# MAN_PAGES_IPK_VERSION should be incremented when the ipk changes.
#
MAN_PAGES_IPK_VERSION=1

#
# MAN_PAGES_CONFFILES should be a list of user-editable files
#MAN_PAGES_CONFFILES=/opt/etc/man-pages.conf /opt/etc/init.d/SXXman-pages

#
# MAN_PAGES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MAN_PAGES_PATCHES=$(MAN_PAGES_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MAN_PAGES_CPPFLAGS=
MAN_PAGES_LDFLAGS=

#
# MAN_PAGES_BUILD_DIR is the directory in which the build is done.
# MAN_PAGES_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MAN_PAGES_IPK_DIR is the directory in which the ipk is built.
# MAN_PAGES_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MAN_PAGES_BUILD_DIR=$(BUILD_DIR)/man-pages
MAN_PAGES_SOURCE_DIR=$(SOURCE_DIR)/man-pages
MAN_PAGES_IPK_DIR=$(BUILD_DIR)/man-pages-$(MAN_PAGES_VERSION)-ipk
MAN_PAGES_IPK=$(BUILD_DIR)/man-pages_$(MAN_PAGES_VERSION)-$(MAN_PAGES_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MAN_PAGES_SOURCE):
	$(WGET) -P $(DL_DIR) $(MAN_PAGES_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(MAN_PAGES_SITE)/Archive/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
man-pages-source: $(DL_DIR)/$(MAN_PAGES_SOURCE) $(MAN_PAGES_PATCHES)

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
$(MAN_PAGES_BUILD_DIR)/.configured: $(DL_DIR)/$(MAN_PAGES_SOURCE) $(MAN_PAGES_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MAN_PAGES_DIR) $(@D)
	$(MAN_PAGES_UNZIP) $(DL_DIR)/$(MAN_PAGES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(MAN_PAGES_PATCHES) | patch -d $(BUILD_DIR)/$(MAN_PAGES_DIR) -p1
	mv $(BUILD_DIR)/$(MAN_PAGES_DIR) $(@D)
#	(cd $(MAN_PAGES_BUILD_DIR); \
#		$(TARGET_CONFIGURE_OPTS) \
#		CPPFLAGS="$(STAGING_CPPFLAGS) $(MAN_PAGES_CPPFLAGS)" \
#		LDFLAGS="$(STAGING_LDFLAGS) $(MAN_PAGES_LDFLAGS)" \
#		./configure \
#		--build=$(GNU_HOST_NAME) \
#		--host=$(GNU_TARGET_NAME) \
#		--target=$(GNU_TARGET_NAME) \
#		--prefix=/opt \
#		--disable-nls \
#	)
	touch $@

man-pages-unpack: $(MAN_PAGES_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MAN_PAGES_BUILD_DIR)/.built: $(MAN_PAGES_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) MANDIR=/opt/man gz
	touch $@

#
# This is the build convenience target.
#
man-pages: $(MAN_PAGES_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MAN_PAGES_BUILD_DIR)/.staged: $(MAN_PAGES_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

man-pages-stage: $(MAN_PAGES_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/man-pages
# 
$(MAN_PAGES_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: man-pages" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MAN_PAGES_PRIORITY)" >>$@
	@echo "Section: $(MAN_PAGES_SECTION)" >>$@
	@echo "Version: $(MAN_PAGES_VERSION)-$(MAN_PAGES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MAN_PAGES_MAINTAINER)" >>$@
	@echo "Source: $(MAN_PAGES_SITE)/$(MAN_PAGES_SOURCE)" >>$@
	@echo "Description: $(MAN_PAGES_DESCRIPTION)" >>$@
	@echo "Depends: $(MAN_PAGES_DEPENDS)" >>$@
	@echo "Conflicts: $(MAN_PAGES_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MAN_PAGES_IPK_DIR)/opt/sbin or $(MAN_PAGES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MAN_PAGES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MAN_PAGES_IPK_DIR)/opt/etc/man-pages/...
# Documentation files should be installed in $(MAN_PAGES_IPK_DIR)/opt/doc/man-pages/...
# Daemon startup scripts should be installed in $(MAN_PAGES_IPK_DIR)/opt/etc/init.d/S??man-pages
#
# You may need to patch your application to make it use these locations.
#
$(MAN_PAGES_IPK): $(MAN_PAGES_BUILD_DIR)/.built
	rm -rf $(MAN_PAGES_IPK_DIR) $(BUILD_DIR)/man-pages_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MAN_PAGES_BUILD_DIR) MANDIR=$(MAN_PAGES_IPK_DIR)/opt/man install
#	install -d $(MAN_PAGES_IPK_DIR)/opt/etc/
#	install -m 755 $(MAN_PAGES_SOURCE_DIR)/man-pages.conf $(MAN_PAGES_IPK_DIR)/opt/etc/man-pages.conf
#	install -d $(MAN_PAGES_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MAN_PAGES_SOURCE_DIR)/rc.man-pages $(MAN_PAGES_IPK_DIR)/opt/etc/init.d/SXXman-pages
	$(MAKE) $(MAN_PAGES_IPK_DIR)/CONTROL/control
#	install -m 644 $(MAN_PAGES_SOURCE_DIR)/postinst $(MAN_PAGES_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(MAN_PAGES_SOURCE_DIR)/prerm $(MAN_PAGES_IPK_DIR)/CONTROL/prerm
#	echo $(MAN_PAGES_CONFFILES) | sed -e 's/ /\n/g' > $(MAN_PAGES_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MAN_PAGES_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
man-pages-ipk: $(MAN_PAGES_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
man-pages-clean:
	-$(MAKE) -C $(MAN_PAGES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
man-pages-dirclean:
	rm -rf $(BUILD_DIR)/$(MAN_PAGES_DIR) $(MAN_PAGES_BUILD_DIR) $(MAN_PAGES_IPK_DIR) $(MAN_PAGES_IPK)
