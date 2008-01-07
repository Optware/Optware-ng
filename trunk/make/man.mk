###########################################################
#
# man
#
###########################################################

#
# MAN_VERSION, MAN_SITE and MAN_SOURCE define
# the upstream location of the source code for the package.
# MAN_DIR is the directory which is created when the source
# archive is unpacked.
# MAN_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
MAN_SITE=http://primates.ximian.com/~flucifredi/man
MAN_VERSION=1.6f
MAN_SOURCE=man-$(MAN_VERSION).tar.gz
MAN_DIR=man-$(MAN_VERSION)
MAN_UNZIP=zcat
MAN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MAN_DESCRIPTION=unix manual page reader
MAN_SECTION=documentation
MAN_PRIORITY=optional
MAN_DEPENDS=groff, less
MAN_CONFLICTS=

#
# MAN_IPK_VERSION should be incremented when the ipk changes.
#
MAN_IPK_VERSION=1

#
# MAN_CONFFILES should be a list of user-editable files
MAN_CONFFILES=/opt/etc/man.conf

#
# MAN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MAN_PATCHES=$(MAN_SOURCE_DIR)/man-configure.patch $(MAN_SOURCE_DIR)/man2html-Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MAN_CPPFLAGS=
MAN_LDFLAGS=

#
# MAN_BUILD_DIR is the directory in which the build is done.
# MAN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MAN_IPK_DIR is the directory in which the ipk is built.
# MAN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MAN_BUILD_DIR=$(BUILD_DIR)/man
MAN_SOURCE_DIR=$(SOURCE_DIR)/man
MAN_IPK_DIR=$(BUILD_DIR)/man-$(MAN_VERSION)-ipk
MAN_IPK=$(BUILD_DIR)/man_$(MAN_VERSION)-$(MAN_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MAN_SOURCE):
	$(WGET) -P $(DL_DIR) $(MAN_SITE)/$(MAN_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(MAN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
man-source: $(DL_DIR)/$(MAN_SOURCE) $(MAN_PATCHES)

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
$(MAN_BUILD_DIR)/.configured: $(DL_DIR)/$(MAN_SOURCE) $(MAN_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MAN_DIR) $(MAN_BUILD_DIR)
	$(MAN_UNZIP) $(DL_DIR)/$(MAN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(MAN_PATCHES) | patch -d $(BUILD_DIR)/$(MAN_DIR) -p1
	mv $(BUILD_DIR)/$(MAN_DIR) $(MAN_BUILD_DIR)
	(cd $(MAN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MAN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MAN_LDFLAGS)" \
		BUILD_CC=$(HOSTCC) \
		./configure \
		--prefix=/opt \
		-confdir /opt/etc \
	)
	touch $@

man-unpack: $(MAN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MAN_BUILD_DIR)/.built: $(MAN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
man: $(MAN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MAN_BUILD_DIR)/.staged: $(MAN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

man-stage: $(MAN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/man
# 
$(MAN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: man" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MAN_PRIORITY)" >>$@
	@echo "Section: $(MAN_SECTION)" >>$@
	@echo "Version: $(MAN_VERSION)-$(MAN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MAN_MAINTAINER)" >>$@
	@echo "Source: $(MAN_SITE)/$(MAN_SOURCE)" >>$@
	@echo "Description: $(MAN_DESCRIPTION)" >>$@
	@echo "Depends: $(MAN_DEPENDS)" >>$@
	@echo "Conflicts: $(MAN_CONFLICTS)" >>$@

#
#
# This builds the IPK file.
#
# Binaries should be installed into $(MAN_IPK_DIR)/opt/sbin or $(MAN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MAN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MAN_IPK_DIR)/opt/etc/man/...
# Documentation files should be installed in $(MAN_IPK_DIR)/opt/doc/man/...
# Daemon startup scripts should be installed in $(MAN_IPK_DIR)/opt/etc/init.d/S??man
#
# You may need to patch your application to make it use these locations.
#
$(MAN_IPK): $(MAN_BUILD_DIR)/.built
	rm -rf $(MAN_IPK_DIR) $(BUILD_DIR)/man_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MAN_BUILD_DIR) DESTDIR=$(MAN_IPK_DIR) install
	$(STRIP_COMMAND) $(MAN_IPK_DIR)/opt/bin/man2html
	install -d $(MAN_IPK_DIR)/opt/etc/
	install -m 644 $(MAN_SOURCE_DIR)/man.conf $(MAN_IPK_DIR)/opt/etc/man.conf
#	install -d $(MAN_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MAN_SOURCE_DIR)/rc.man $(MAN_IPK_DIR)/opt/etc/init.d/SXXman
	$(MAKE) $(MAN_IPK_DIR)/CONTROL/control
#	install -m 644 $(MAN_SOURCE_DIR)/postinst $(MAN_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(MAN_SOURCE_DIR)/prerm $(MAN_IPK_DIR)/CONTROL/prerm
	echo $(MAN_CONFFILES) | sed -e 's/ /\n/g' > $(MAN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MAN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
man-ipk: $(MAN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
man-clean:
	-$(MAKE) -C $(MAN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
man-dirclean:
	rm -rf $(BUILD_DIR)/$(MAN_DIR) $(MAN_BUILD_DIR) $(MAN_IPK_DIR) $(MAN_IPK)

#
# Some sanity check for the package.
#
man-check: $(MAN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MAN_IPK)
