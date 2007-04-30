###########################################################
#
# jove
#
###########################################################

JOVE_SITE=ftp://ftp.cs.toronto.edu/cs/ftp/pub/hugh/jove-dev
JOVE_VERSION=4.16.0.70
JOVE_SOURCE=jove$(JOVE_VERSION).tgz
JOVE_DIR=jove$(JOVE_VERSION)
JOVE_UNZIP=zcat
JOVE_MAINTAINER=Ron Pedde <rpedde@users.sourceforge.net>
JOVE_DESCRIPTION=A tiny, fast editor with emacs keybindings
JOVE_SECTION=editor
JOVE_PRIORITY=optional
JOVE_DEPENDS=ncurses
JOVE_SUGGESTS=
JOVE_CONFLICTS=

#
# JOVE_IPK_VERSION should be incremented when the ipk changes.
#
JOVE_IPK_VERSION=1

#
# JOVE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
JOVE_PATCHES=$(JOVE_SOURCE_DIR)/jove.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
JOVE_CPPFLAGS=
JOVE_LDFLAGS=

#
# JOVE_BUILD_DIR is the directory in which the build is done.
# JOVE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# JOVE_IPK_DIR is the directory in which the ipk is built.
# JOVE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
JOVE_BUILD_DIR=$(BUILD_DIR)/jove
JOVE_SOURCE_DIR=$(SOURCE_DIR)/jove
JOVE_IPK_DIR=$(BUILD_DIR)/jove-$(JOVE_VERSION)-ipk
JOVE_IPK=$(BUILD_DIR)/jove_$(JOVE_VERSION)-$(JOVE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(JOVE_SOURCE):
	$(WGET) -P $(DL_DIR) $(JOVE_SITE)/$(JOVE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
jove-source: $(DL_DIR)/$(JOVE_SOURCE) $(JOVE_PATCHES)

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
$(JOVE_BUILD_DIR)/.configured: $(DL_DIR)/$(JOVE_SOURCE) $(JOVE_PATCHES)
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(JOVE_DIR) $(JOVE_BUILD_DIR)
	$(JOVE_UNZIP) $(DL_DIR)/$(JOVE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(JOVE_PATCHES) | patch -d $(BUILD_DIR)/$(JOVE_DIR) -p1
	mv $(BUILD_DIR)/$(JOVE_DIR) $(JOVE_BUILD_DIR)
	touch $(JOVE_BUILD_DIR)/.configured

jove-unpack: $(JOVE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(JOVE_BUILD_DIR)/jjove: $(JOVE_BUILD_DIR)/.configured
	$(MAKE) LDFLAGS="$(STAGING_LDFLAGS) -Xlinker -rpath -Xlinker /opt/lib" LOCALCC=gcc CC=$(TARGET_CC) -C $(JOVE_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
jove: $(JOVE_BUILD_DIR)/jjove

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/jove
#
$(JOVE_IPK_DIR)/CONTROL/control:
	@install -d $(JOVE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: jove" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(JOVE_PRIORITY)" >>$@
	@echo "Section: $(JOVE_SECTION)" >>$@
	@echo "Version: $(JOVE_VERSION)-$(JOVE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(JOVE_MAINTAINER)" >>$@
	@echo "Source: $(JOVE_SITE)/$(JOVE_SOURCE)" >>$@
	@echo "Description: $(JOVE_DESCRIPTION)" >>$@
	@echo "Depends: $(JOVE_DEPENDS)" >>$@
	@echo "Suggests: $(JOVE_SUGGESTS)" >>$@
	@echo "Conflicts: $(JOVE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(JOVE_IPK_DIR)/opt/sbin or $(JOVE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(JOVE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(JOVE_IPK_DIR)/opt/etc/jove/...
# Documentation files should be installed in $(JOVE_IPK_DIR)/opt/doc/jove/...
# Daemon startup scripts should be installed in $(JOVE_IPK_DIR)/opt/etc/init.d/S??jove
#
# You may need to patch your application to make it use these locations.
#
$(JOVE_IPK): $(JOVE_BUILD_DIR)/jjove
	rm -rf $(JOVE_IPK_DIR) $(JOVE_IPK)
	install -d $(JOVE_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(JOVE_BUILD_DIR)/jjove -o $(JOVE_IPK_DIR)/opt/bin/jove
	$(MAKE) $(JOVE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(JOVE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
jove-ipk: $(JOVE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
jove-clean:
	-$(MAKE) -C $(JOVE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
jove-dirclean:
	rm -rf $(BUILD_DIR)/$(JOVE_DIR) $(JOVE_BUILD_DIR) $(JOVE_IPK_DIR) $(JOVE_IPK)

#
# Some sanity check for the package.
#
jove-check: $(JOVE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(JOVE_IPK)
