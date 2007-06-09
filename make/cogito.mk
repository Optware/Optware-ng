###########################################################
#
# cogito
#
###########################################################

#
# COGITO_VERSION, COGITO_SITE and COGITO_SOURCE define
# the upstream location of the source code for the package.
# COGITO_DIR is the directory which is created when the source
# archive is unpacked.
# COGITO_UNZIP is the command used to unzip the source.
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
COGITO_SITE=http://www.kernel.org/pub/software/scm/cogito
COGITO_VERSION=0.18.2
COGITO_SOURCE=cogito-$(COGITO_VERSION).tar.bz2
COGITO_DIR=cogito-$(COGITO_VERSION)
COGITO_UNZIP=bzcat
COGITO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
COGITO_DESCRIPTION=Petr "Pasky" Baudis's SCM layer over Linus Torvald's git, formerly called git-pasky
COGITO_SECTION=net
COGITO_PRIORITY=optional
COGITO_DEPENDS=git, rsync, patch, mktemp, coreutils, grep, rcs
COGITO_CONFLICTS=

#
# COGITO_IPK_VERSION should be incremented when the ipk changes.
#
COGITO_IPK_VERSION=2

#
# COGITO_CONFFILES should be a list of user-editable files
COGITO_CONFFILES=

#
# COGITO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#COGITO_PATCHES=$(COGITO_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
COGITO_CPPFLAGS=
COGITO_LDFLAGS=

#
# COGITO_BUILD_DIR is the directory in which the build is done.
# COGITO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# COGITO_IPK_DIR is the directory in which the ipk is built.
# COGITO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
COGITO_BUILD_DIR=$(BUILD_DIR)/cogito
COGITO_SOURCE_DIR=$(SOURCE_DIR)/cogito
COGITO_IPK_DIR=$(BUILD_DIR)/cogito-$(COGITO_VERSION)-ipk
COGITO_IPK=$(BUILD_DIR)/cogito_$(COGITO_VERSION)-$(COGITO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cogito-source cogito-unpack cogito cogito-stage cogito-ipk cogito-clean cogito-dirclean cogito-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(COGITO_SOURCE):
	$(WGET) -P $(DL_DIR) $(COGITO_SITE)/$(COGITO_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cogito-source: $(DL_DIR)/$(COGITO_SOURCE) $(COGITO_PATCHES)

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
$(COGITO_BUILD_DIR)/.configured: $(DL_DIR)/$(COGITO_SOURCE) $(COGITO_PATCHES)
#	$(MAKE) libcurl-stage openssl-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(COGITO_DIR) $(COGITO_BUILD_DIR)
	$(COGITO_UNZIP) $(DL_DIR)/$(COGITO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(COGITO_PATCHES) | patch -d $(BUILD_DIR)/$(COGITO_DIR) -p1
	mv $(BUILD_DIR)/$(COGITO_DIR) $(COGITO_BUILD_DIR)
	touch $(COGITO_BUILD_DIR)/.configured

cogito-unpack: $(COGITO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(COGITO_BUILD_DIR)/.built: $(COGITO_BUILD_DIR)/.configured
	rm -f $(COGITO_BUILD_DIR)/.built
	$(MAKE) -C $(COGITO_BUILD_DIR) $(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)"
	touch $(COGITO_BUILD_DIR)/.built

#
# This is the build convenience target.
#
cogito: $(COGITO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(COGITO_BUILD_DIR)/.staged: $(COGITO_BUILD_DIR)/.built
	rm -f $(COGITO_BUILD_DIR)/.staged
	$(MAKE) -C $(COGITO_BUILD_DIR) HOME=$(STAGING_DIR)/opt install
	touch $(COGITO_BUILD_DIR)/.staged

cogito-stage: $(COGITO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cogito
#
$(COGITO_IPK_DIR)/CONTROL/control:
	@install -d $(COGITO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: cogito" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(COGITO_PRIORITY)" >>$@
	@echo "Section: $(COGITO_SECTION)" >>$@
	@echo "Version: $(COGITO_VERSION)-$(COGITO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(COGITO_MAINTAINER)" >>$@
	@echo "Source: $(COGITO_SITE)/$(COGITO_SOURCE)" >>$@
	@echo "Description: $(COGITO_DESCRIPTION)" >>$@
	@echo "Depends: $(COGITO_DEPENDS)" >>$@
	@echo "Conflicts: $(COGITO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(COGITO_IPK_DIR)/opt/sbin or $(COGITO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(COGITO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(COGITO_IPK_DIR)/opt/etc/cogito/...
# Documentation files should be installed in $(COGITO_IPK_DIR)/opt/doc/cogito/...
# Daemon startup scripts should be installed in $(COGITO_IPK_DIR)/opt/etc/init.d/S??cogito
#
# You may need to patch your application to make it use these locations.
#
$(COGITO_IPK): $(COGITO_BUILD_DIR)/.built
	rm -rf $(COGITO_IPK_DIR) $(BUILD_DIR)/cogito_*_$(TARGET_ARCH).ipk
	install -d $(COGITO_IPK_DIR)/opt/bin
	$(MAKE) -C $(COGITO_BUILD_DIR) DESTDIR=$(COGITO_IPK_DIR) prefix=/opt install
	$(MAKE) $(COGITO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(COGITO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cogito-ipk: $(COGITO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cogito-clean:
	-$(MAKE) -C $(COGITO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cogito-dirclean:
	rm -rf $(BUILD_DIR)/$(COGITO_DIR) $(COGITO_BUILD_DIR) $(COGITO_IPK_DIR) $(COGITO_IPK)

#
# Some sanity check for the package.
#
cogito-check: $(COGITO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(COGITO_IPK)
