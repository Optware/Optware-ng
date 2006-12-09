###########################################################
#
# mpage
#
###########################################################
#
# MPAGE_VERSION, MPAGE_SITE and MPAGE_SOURCE define
# the upstream location of the source code for the package.
# MPAGE_DIR is the directory which is created when the source
# archive is unpacked.
# MPAGE_UNZIP is the command used to unzip the source.
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
MPAGE_SITE=http://www.mesa.nl/pub/mpage
MPAGE_VERSION=2.5.5
MPAGE_SOURCE=mpage-$(MPAGE_VERSION).tgz
MPAGE_DIR=mpage-$(MPAGE_VERSION)
MPAGE_UNZIP=zcat
MPAGE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MPAGE_DESCRIPTION=Print several pages on a single sheet of paper.
MPAGE_SECTION=misc
MPAGE_PRIORITY=optional
MPAGE_DEPENDS=
MPAGE_SUGGESTS=
MPAGE_CONFLICTS=

#
# MPAGE_IPK_VERSION should be incremented when the ipk changes.
#
MPAGE_IPK_VERSION=1

#
# MPAGE_CONFFILES should be a list of user-editable files
## MPAGE_CONFFILES=/opt/etc/mpage.conf /opt/etc/init.d/SXXmpage

#
# MPAGE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
## MPAGE_PATCHES=$(MPAGE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MPAGE_CPPFLAGS=
MPAGE_LDFLAGS=

#
# MPAGE_BUILD_DIR is the directory in which the build is done.
# MPAGE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MPAGE_IPK_DIR is the directory in which the ipk is built.
# MPAGE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MPAGE_BUILD_DIR=$(BUILD_DIR)/mpage
MPAGE_SOURCE_DIR=$(SOURCE_DIR)/mpage
MPAGE_IPK_DIR=$(BUILD_DIR)/mpage-$(MPAGE_VERSION)-ipk
MPAGE_IPK=$(BUILD_DIR)/mpage_$(MPAGE_VERSION)-$(MPAGE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mpage-source mpage-unpack mpage mpage-stage mpage-ipk mpage-clean mpage-dirclean mpage-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MPAGE_SOURCE):
	$(WGET) -P $(DL_DIR) $(MPAGE_SITE)/$(MPAGE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mpage-source: $(DL_DIR)/$(MPAGE_SOURCE) $(MPAGE_PATCHES)

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
$(MPAGE_BUILD_DIR)/.configured: $(DL_DIR)/$(MPAGE_SOURCE) $(MPAGE_PATCHES) make/mpage.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MPAGE_DIR) $(MPAGE_BUILD_DIR)
	$(MPAGE_UNZIP) $(DL_DIR)/$(MPAGE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MPAGE_PATCHES)" ; \
		then cat $(MPAGE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MPAGE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MPAGE_DIR)" != "$(MPAGE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MPAGE_DIR) $(MPAGE_BUILD_DIR) ; \
	fi
	touch $(MPAGE_BUILD_DIR)/.configured

mpage-unpack: $(MPAGE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MPAGE_BUILD_DIR)/.built: $(MPAGE_BUILD_DIR)/.configured
	rm -f $(MPAGE_BUILD_DIR)/.built
	$(MAKE) -C $(MPAGE_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		PREFIX=/opt
##		CPPFLAGS="$(STAGING_CPPFLAGS) $(MPAGE_CPPFLAGS)" \
##		LDFLAGS="$(STAGING_LDFLAGS) $(MPAGE_LDFLAGS)" \
##		PAGESIZE=letter
	touch $(MPAGE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
mpage: $(MPAGE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MPAGE_BUILD_DIR)/.staged: $(MPAGE_BUILD_DIR)/.built
	rm -f $(MPAGE_BUILD_DIR)/.staged
	$(MAKE) -C $(MPAGE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MPAGE_BUILD_DIR)/.staged

mpage-stage: $(MPAGE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mpage
#
$(MPAGE_IPK_DIR)/CONTROL/control:
	@install -d $(MPAGE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: mpage" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MPAGE_PRIORITY)" >>$@
	@echo "Section: $(MPAGE_SECTION)" >>$@
	@echo "Version: $(MPAGE_VERSION)-$(MPAGE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MPAGE_MAINTAINER)" >>$@
	@echo "Source: $(MPAGE_SITE)/$(MPAGE_SOURCE)" >>$@
	@echo "Description: $(MPAGE_DESCRIPTION)" >>$@
	@echo "Depends: $(MPAGE_DEPENDS)" >>$@
	@echo "Suggests: $(MPAGE_SUGGESTS)" >>$@
	@echo "Conflicts: $(MPAGE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MPAGE_IPK_DIR)/opt/sbin or $(MPAGE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MPAGE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MPAGE_IPK_DIR)/opt/etc/mpage/...
# Documentation files should be installed in $(MPAGE_IPK_DIR)/opt/doc/mpage/...
# Daemon startup scripts should be installed in $(MPAGE_IPK_DIR)/opt/etc/init.d/S??mpage
#
# You may need to patch your application to make it use these locations.
#
$(MPAGE_IPK): $(MPAGE_BUILD_DIR)/.built
	rm -rf $(MPAGE_IPK_DIR) $(BUILD_DIR)/mpage_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MPAGE_BUILD_DIR) PREFIX=$(MPAGE_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(MPAGE_IPK_DIR)/opt/bin/mpage
#	install -d $(MPAGE_IPK_DIR)/opt/etc/
#	install -m 644 $(MPAGE_SOURCE_DIR)/mpage.conf $(MPAGE_IPK_DIR)/opt/etc/mpage.conf
#	install -d $(MPAGE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MPAGE_SOURCE_DIR)/rc.mpage $(MPAGE_IPK_DIR)/opt/etc/init.d/SXXmpage
	$(MAKE) $(MPAGE_IPK_DIR)/CONTROL/control
#	install -m 755 $(MPAGE_SOURCE_DIR)/postinst $(MPAGE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MPAGE_SOURCE_DIR)/prerm $(MPAGE_IPK_DIR)/CONTROL/prerm
	echo $(MPAGE_CONFFILES) | sed -e 's/ /\n/g' > $(MPAGE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MPAGE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mpage-ipk: $(MPAGE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mpage-clean:
	rm -f $(MPAGE_BUILD_DIR)/.built
	-$(MAKE) -C $(MPAGE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mpage-dirclean:
	rm -rf $(BUILD_DIR)/$(MPAGE_DIR) $(MPAGE_BUILD_DIR) $(MPAGE_IPK_DIR) $(MPAGE_IPK)

#
# Some sanity check for the package.
#
mpage-check: $(MPAGE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MPAGE_IPK)
