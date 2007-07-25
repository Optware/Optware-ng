###########################################################
#
# abook
#
###########################################################

#
# ABOOK_VERSION, ABOOK_SITE and ABOOK_SOURCE define
# the upstream location of the source code for the package.
# ABOOK_DIR is the directory which is created when the source
# archive is unpacked.
# ABOOK_UNZIP is the command used to unzip the source.
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
ABOOK_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/abook
ABOOK_VERSION=0.5.6
ABOOK_SOURCE=abook-$(ABOOK_VERSION).tar.gz
ABOOK_DIR=abook-$(ABOOK_VERSION)
ABOOK_UNZIP=zcat
ABOOK_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
ABOOK_DESCRIPTION=Abook is a text-based addressbook program designed to use with mutt mail client.
ABOOK_SECTION=misc
ABOOK_PRIORITY=optional
ABOOK_DEPENDS=ncurses, readline
ABOOK_CONFLICTS=

#
# ABOOK_IPK_VERSION should be incremented when the ipk changes.
#
ABOOK_IPK_VERSION=1

#
# ABOOK_CONFFILES should be a list of user-editable files
#ABOOK_CONFFILES=/opt/etc/abook.conf /opt/etc/init.d/SXXabook

#
# ABOOK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ABOOK_PATCHES=$(ABOOK_SOURCE_DIR)/0.5.6-01_editor

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ABOOK_CPPFLAGS=
ABOOK_LDFLAGS=

#
# ABOOK_BUILD_DIR is the directory in which the build is done.
# ABOOK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ABOOK_IPK_DIR is the directory in which the ipk is built.
# ABOOK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ABOOK_BUILD_DIR=$(BUILD_DIR)/abook
ABOOK_SOURCE_DIR=$(SOURCE_DIR)/abook
ABOOK_IPK_DIR=$(BUILD_DIR)/abook-$(ABOOK_VERSION)-ipk
ABOOK_IPK=$(BUILD_DIR)/abook_$(ABOOK_VERSION)-$(ABOOK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: abook-source abook-unpack abook abook-stage abook-ipk abook-clean abook-dirclean abook-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ABOOK_SOURCE):
	$(WGET) -P $(DL_DIR) $(ABOOK_SITE)/$(ABOOK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
abook-source: $(DL_DIR)/$(ABOOK_SOURCE) $(ABOOK_PATCHES)

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
$(ABOOK_BUILD_DIR)/.configured: $(DL_DIR)/$(ABOOK_SOURCE) $(ABOOK_PATCHES) make/abook.mk
	$(MAKE) readline-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(ABOOK_DIR) $(ABOOK_BUILD_DIR)
	$(ABOOK_UNZIP) $(DL_DIR)/$(ABOOK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ABOOK_PATCHES)"; \
		then cat $(ABOOK_PATCHES) | patch -d $(BUILD_DIR)/$(ABOOK_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(ABOOK_DIR) $(ABOOK_BUILD_DIR)
	cp -f $(SOURCE_DIR)/common/config.* $(ABOOK_BUILD_DIR)/
	(cd $(ABOOK_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ABOOK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ABOOK_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(ABOOK_BUILD_DIR)/.configured

abook-unpack: $(ABOOK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ABOOK_BUILD_DIR)/.built: $(ABOOK_BUILD_DIR)/.configured
	rm -f $(ABOOK_BUILD_DIR)/.built
	$(MAKE) -C $(ABOOK_BUILD_DIR)
	touch $(ABOOK_BUILD_DIR)/.built

#
# This is the build convenience target.
#
abook: $(ABOOK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ABOOK_BUILD_DIR)/.staged: $(ABOOK_BUILD_DIR)/.built
	rm -f $(ABOOK_BUILD_DIR)/.staged
	$(MAKE) -C $(ABOOK_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ABOOK_BUILD_DIR)/.staged

abook-stage: $(ABOOK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/abook
#
$(ABOOK_IPK_DIR)/CONTROL/control:
	@install -d $(ABOOK_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: abook" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ABOOK_PRIORITY)" >>$@
	@echo "Section: $(ABOOK_SECTION)" >>$@
	@echo "Version: $(ABOOK_VERSION)-$(ABOOK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ABOOK_MAINTAINER)" >>$@
	@echo "Source: $(ABOOK_SITE)/$(ABOOK_SOURCE)" >>$@
	@echo "Description: $(ABOOK_DESCRIPTION)" >>$@
	@echo "Depends: $(ABOOK_DEPENDS)" >>$@
	@echo "Conflicts: $(ABOOK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ABOOK_IPK_DIR)/opt/sbin or $(ABOOK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ABOOK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ABOOK_IPK_DIR)/opt/etc/abook/...
# Documentation files should be installed in $(ABOOK_IPK_DIR)/opt/doc/abook/...
# Daemon startup scripts should be installed in $(ABOOK_IPK_DIR)/opt/etc/init.d/S??abook
#
# You may need to patch your application to make it use these locations.
#
$(ABOOK_IPK): $(ABOOK_BUILD_DIR)/.built
	rm -rf $(ABOOK_IPK_DIR) $(BUILD_DIR)/abook_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ABOOK_BUILD_DIR) DESTDIR=$(ABOOK_IPK_DIR) install-strip
	$(MAKE) $(ABOOK_IPK_DIR)/CONTROL/control
#	echo $(ABOOK_CONFFILES) | sed -e 's/ /\n/g' > $(ABOOK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ABOOK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
abook-ipk: $(ABOOK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
abook-clean:
	-$(MAKE) -C $(ABOOK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
abook-dirclean:
	rm -rf $(BUILD_DIR)/$(ABOOK_DIR) $(ABOOK_BUILD_DIR) $(ABOOK_IPK_DIR) $(ABOOK_IPK)

#
# Some sanity check for the package.
#
abook-check: $(ABOOK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ABOOK_IPK)
