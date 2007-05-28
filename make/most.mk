###########################################################
#
# most
#
###########################################################
#
# MOST_VERSION, MOST_SITE and MOST_SOURCE define
# the upstream location of the source code for the package.
# MOST_DIR is the directory which is created when the source
# archive is unpacked.
# MOST_UNZIP is the command used to unzip the source.
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
MOST_SITE=ftp://space.mit.edu/pub/davis/most
MOST_VERSION=4.10.2
MOST_SOURCE=most-$(MOST_VERSION).tar.gz
MOST_DIR=most-$(MOST_VERSION)
MOST_UNZIP=zcat
MOST_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MOST_DESCRIPTION=MOST is a powerful paging program supporting multiple windows and can scroll left and right. Why settle for less?
MOST_SECTION=misc
MOST_PRIORITY=optional
MOST_DEPENDS=slang
MOST_SUGGESTS=
MOST_CONFLICTS=

#
# MOST_IPK_VERSION should be incremented when the ipk changes.
#
MOST_IPK_VERSION=1

#
# MOST_CONFFILES should be a list of user-editable files
#MOST_CONFFILES=/opt/etc/most.conf /opt/etc/init.d/SXXmost

#
# MOST_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MOST_PATCHES=$(MOST_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MOST_CPPFLAGS=
MOST_LDFLAGS=

#
# MOST_BUILD_DIR is the directory in which the build is done.
# MOST_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MOST_IPK_DIR is the directory in which the ipk is built.
# MOST_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MOST_BUILD_DIR=$(BUILD_DIR)/most
MOST_SOURCE_DIR=$(SOURCE_DIR)/most
MOST_IPK_DIR=$(BUILD_DIR)/most-$(MOST_VERSION)-ipk
MOST_IPK=$(BUILD_DIR)/most_$(MOST_VERSION)-$(MOST_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: most-source most-unpack most most-stage most-ipk most-clean most-dirclean most-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MOST_SOURCE):
	$(WGET) -P $(DL_DIR) $(MOST_SITE)/$(MOST_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(MOST_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
most-source: $(DL_DIR)/$(MOST_SOURCE) $(MOST_PATCHES)

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
$(MOST_BUILD_DIR)/.configured: $(DL_DIR)/$(MOST_SOURCE) $(MOST_PATCHES) make/most.mk
	$(MAKE) slang-stage
	rm -rf $(BUILD_DIR)/$(MOST_DIR) $(MOST_BUILD_DIR)
	$(MOST_UNZIP) $(DL_DIR)/$(MOST_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MOST_PATCHES)" ; \
		then cat $(MOST_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MOST_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MOST_DIR)" != "$(MOST_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MOST_DIR) $(MOST_BUILD_DIR) ; \
	fi
	sed -i -e '/\/chkslang.*EXEC/s/^/#/' \
	       -e 's/@RPATH@//' \
	       -e 's/$$(INSTALL) -s/$$(INSTALL)/' \
		$(MOST_BUILD_DIR)/src/Makefile.in
	(cd $(MOST_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MOST_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MOST_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-slang=$(STAGING_PREFIX) \
		--without-x \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MOST_BUILD_DIR)/libtool
	touch $@

most-unpack: $(MOST_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MOST_BUILD_DIR)/.built: $(MOST_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MOST_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
most: $(MOST_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MOST_BUILD_DIR)/.staged: $(MOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(MOST_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

most-stage: $(MOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/most
#
$(MOST_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: most" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MOST_PRIORITY)" >>$@
	@echo "Section: $(MOST_SECTION)" >>$@
	@echo "Version: $(MOST_VERSION)-$(MOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MOST_MAINTAINER)" >>$@
	@echo "Source: $(MOST_SITE)/$(MOST_SOURCE)" >>$@
	@echo "Description: $(MOST_DESCRIPTION)" >>$@
	@echo "Depends: $(MOST_DEPENDS)" >>$@
	@echo "Suggests: $(MOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(MOST_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MOST_IPK_DIR)/opt/sbin or $(MOST_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MOST_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MOST_IPK_DIR)/opt/etc/most/...
# Documentation files should be installed in $(MOST_IPK_DIR)/opt/doc/most/...
# Daemon startup scripts should be installed in $(MOST_IPK_DIR)/opt/etc/init.d/S??most
#
# You may need to patch your application to make it use these locations.
#
$(MOST_IPK): $(MOST_BUILD_DIR)/.built
	rm -rf $(MOST_IPK_DIR) $(BUILD_DIR)/most_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MOST_BUILD_DIR) DESTDIR=$(MOST_IPK_DIR) install
	$(STRIP_COMMAND) $(MOST_IPK_DIR)/opt/bin/most
#	install -d $(MOST_IPK_DIR)/opt/etc/
#	install -m 644 $(MOST_SOURCE_DIR)/most.conf $(MOST_IPK_DIR)/opt/etc/most.conf
#	install -d $(MOST_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MOST_SOURCE_DIR)/rc.most $(MOST_IPK_DIR)/opt/etc/init.d/SXXmost
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOST_IPK_DIR)/opt/etc/init.d/SXXmost
	$(MAKE) $(MOST_IPK_DIR)/CONTROL/control
#	install -m 755 $(MOST_SOURCE_DIR)/postinst $(MOST_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOST_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MOST_SOURCE_DIR)/prerm $(MOST_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOST_IPK_DIR)/CONTROL/prerm
	echo $(MOST_CONFFILES) | sed -e 's/ /\n/g' > $(MOST_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MOST_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
most-ipk: $(MOST_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
most-clean:
	rm -f $(MOST_BUILD_DIR)/.built
	-$(MAKE) -C $(MOST_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
most-dirclean:
	rm -rf $(BUILD_DIR)/$(MOST_DIR) $(MOST_BUILD_DIR) $(MOST_IPK_DIR) $(MOST_IPK)
#
#
# Some sanity check for the package.
#
most-check: $(MOST_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MOST_IPK)
