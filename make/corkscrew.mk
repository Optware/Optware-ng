###########################################################
#
# corkscrew
#
###########################################################
#
# CORKSCREW_VERSION, CORKSCREW_SITE and CORKSCREW_SOURCE define
# the upstream location of the source code for the package.
# CORKSCREW_DIR is the directory which is created when the source
# archive is unpacked.
# CORKSCREW_UNZIP is the command used to unzip the source.
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
CORKSCREW_SITE=http://www.agroman.net/corkscrew
CORKSCREW_VERSION=2.0
CORKSCREW_SOURCE=corkscrew-$(CORKSCREW_VERSION).tar.gz
CORKSCREW_DIR=corkscrew-$(CORKSCREW_VERSION)
CORKSCREW_UNZIP=zcat
CORKSCREW_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CORKSCREW_DESCRIPTION=Corkscrew enables the user to run SSH connections over most HTTP and HTTPS proxy servers.
CORKSCREW_SECTION=net
CORKSCREW_PRIORITY=optional
CORKSCREW_DEPENDS=
CORKSCREW_SUGGESTS=
CORKSCREW_CONFLICTS=

#
# CORKSCREW_IPK_VERSION should be incremented when the ipk changes.
#
CORKSCREW_IPK_VERSION=1

#
# CORKSCREW_CONFFILES should be a list of user-editable files
#CORKSCREW_CONFFILES=/opt/etc/corkscrew.conf /opt/etc/init.d/SXXcorkscrew

#
# CORKSCREW_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CORKSCREW_PATCHES=$(CORKSCREW_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CORKSCREW_CPPFLAGS=
CORKSCREW_LDFLAGS=

#
# CORKSCREW_BUILD_DIR is the directory in which the build is done.
# CORKSCREW_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CORKSCREW_IPK_DIR is the directory in which the ipk is built.
# CORKSCREW_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CORKSCREW_BUILD_DIR=$(BUILD_DIR)/corkscrew
CORKSCREW_SOURCE_DIR=$(SOURCE_DIR)/corkscrew
CORKSCREW_IPK_DIR=$(BUILD_DIR)/corkscrew-$(CORKSCREW_VERSION)-ipk
CORKSCREW_IPK=$(BUILD_DIR)/corkscrew_$(CORKSCREW_VERSION)-$(CORKSCREW_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: corkscrew-source corkscrew-unpack corkscrew corkscrew-stage corkscrew-ipk corkscrew-clean corkscrew-dirclean corkscrew-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CORKSCREW_SOURCE):
	$(WGET) -P $(DL_DIR) $(CORKSCREW_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
corkscrew-source: $(DL_DIR)/$(CORKSCREW_SOURCE) $(CORKSCREW_PATCHES)

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
$(CORKSCREW_BUILD_DIR)/.configured: $(DL_DIR)/$(CORKSCREW_SOURCE) $(CORKSCREW_PATCHES) make/corkscrew.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(CORKSCREW_DIR) $(@D)
	$(CORKSCREW_UNZIP) $(DL_DIR)/$(CORKSCREW_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CORKSCREW_PATCHES)" ; \
		then cat $(CORKSCREW_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CORKSCREW_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CORKSCREW_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CORKSCREW_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CORKSCREW_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CORKSCREW_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

corkscrew-unpack: $(CORKSCREW_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CORKSCREW_BUILD_DIR)/.built: $(CORKSCREW_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
corkscrew: $(CORKSCREW_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CORKSCREW_BUILD_DIR)/.staged: $(CORKSCREW_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

corkscrew-stage: $(CORKSCREW_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/corkscrew
#
$(CORKSCREW_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: corkscrew" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CORKSCREW_PRIORITY)" >>$@
	@echo "Section: $(CORKSCREW_SECTION)" >>$@
	@echo "Version: $(CORKSCREW_VERSION)-$(CORKSCREW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CORKSCREW_MAINTAINER)" >>$@
	@echo "Source: $(CORKSCREW_SITE)/$(CORKSCREW_SOURCE)" >>$@
	@echo "Description: $(CORKSCREW_DESCRIPTION)" >>$@
	@echo "Depends: $(CORKSCREW_DEPENDS)" >>$@
	@echo "Suggests: $(CORKSCREW_SUGGESTS)" >>$@
	@echo "Conflicts: $(CORKSCREW_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CORKSCREW_IPK_DIR)/opt/sbin or $(CORKSCREW_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CORKSCREW_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CORKSCREW_IPK_DIR)/opt/etc/corkscrew/...
# Documentation files should be installed in $(CORKSCREW_IPK_DIR)/opt/doc/corkscrew/...
# Daemon startup scripts should be installed in $(CORKSCREW_IPK_DIR)/opt/etc/init.d/S??corkscrew
#
# You may need to patch your application to make it use these locations.
#
$(CORKSCREW_IPK): $(CORKSCREW_BUILD_DIR)/.built
	rm -rf $(CORKSCREW_IPK_DIR) $(BUILD_DIR)/corkscrew_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CORKSCREW_BUILD_DIR) DESTDIR=$(CORKSCREW_IPK_DIR) install
	$(STRIP_COMMAND) $(CORKSCREW_IPK_DIR)/opt/bin/corkscrew
	install -d $(CORKSCREW_IPK_DIR)/opt/share/doc/corkscrew
	install $(CORKSCREW_BUILD_DIR)/[ACINRT]* $(CORKSCREW_IPK_DIR)/opt/share/doc/corkscrew
	$(MAKE) $(CORKSCREW_IPK_DIR)/CONTROL/control
	echo $(CORKSCREW_CONFFILES) | sed -e 's/ /\n/g' > $(CORKSCREW_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CORKSCREW_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
corkscrew-ipk: $(CORKSCREW_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
corkscrew-clean:
	rm -f $(CORKSCREW_BUILD_DIR)/.built
	-$(MAKE) -C $(CORKSCREW_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
corkscrew-dirclean:
	rm -rf $(BUILD_DIR)/$(CORKSCREW_DIR) $(CORKSCREW_BUILD_DIR) $(CORKSCREW_IPK_DIR) $(CORKSCREW_IPK)
#
#
# Some sanity check for the package.
#
corkscrew-check: $(CORKSCREW_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CORKSCREW_IPK)
