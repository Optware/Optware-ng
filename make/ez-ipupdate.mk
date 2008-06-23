###########################################################
#
# ez-ipupdate
#
###########################################################
#
# EZ-IPUPDATE_VERSION, EZ-IPUPDATE_SITE and EZ-IPUPDATE_SOURCE define
# the upstream location of the source code for the package.
# EZ-IPUPDATE_DIR is the directory which is created when the source
# archive is unpacked.
# EZ-IPUPDATE_UNZIP is the command used to unzip the source.
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
EZ-IPUPDATE_SITE=http://ez-ipupdate.com/dist
EZ-IPUPDATE_VERSION=3.0.11b7
EZ-IPUPDATE_SOURCE=ez-ipupdate-$(EZ-IPUPDATE_VERSION).tar.gz
EZ-IPUPDATE_DIR=ez-ipupdate-$(EZ-IPUPDATE_VERSION)
EZ-IPUPDATE_UNZIP=zcat
EZ-IPUPDATE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
EZ-IPUPDATE_DESCRIPTION=A small utility for updating your host name for several dynamic DNS services.
EZ-IPUPDATE_SECTION=sysadmin
EZ-IPUPDATE_PRIORITY=optional
EZ-IPUPDATE_DEPENDS=
EZ-IPUPDATE_SUGGESTS=
EZ-IPUPDATE_CONFLICTS=

#
# EZ-IPUPDATE_IPK_VERSION should be incremented when the ipk changes.
#
EZ-IPUPDATE_IPK_VERSION=1

#
# EZ-IPUPDATE_CONFFILES should be a list of user-editable files
#EZ-IPUPDATE_CONFFILES=/opt/etc/ez-ipupdate.conf /opt/etc/init.d/SXXez-ipupdate

#
# EZ-IPUPDATE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
EZ-IPUPDATE_PATCHES=$(EZ-IPUPDATE_SOURCE_DIR)/errno.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
EZ-IPUPDATE_CPPFLAGS=
EZ-IPUPDATE_LDFLAGS=

#
# EZ-IPUPDATE_BUILD_DIR is the directory in which the build is done.
# EZ-IPUPDATE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# EZ-IPUPDATE_IPK_DIR is the directory in which the ipk is built.
# EZ-IPUPDATE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
EZ-IPUPDATE_BUILD_DIR=$(BUILD_DIR)/ez-ipupdate
EZ-IPUPDATE_SOURCE_DIR=$(SOURCE_DIR)/ez-ipupdate
EZ-IPUPDATE_IPK_DIR=$(BUILD_DIR)/ez-ipupdate-$(EZ-IPUPDATE_VERSION)-ipk
EZ-IPUPDATE_IPK=$(BUILD_DIR)/ez-ipupdate_$(EZ-IPUPDATE_VERSION)-$(EZ-IPUPDATE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ez-ipupdate-source ez-ipupdate-unpack ez-ipupdate ez-ipupdate-stage ez-ipupdate-ipk ez-ipupdate-clean ez-ipupdate-dirclean ez-ipupdate-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(EZ-IPUPDATE_SOURCE):
	$(WGET) -P $(@D) $(EZ-IPUPDATE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ez-ipupdate-source: $(DL_DIR)/$(EZ-IPUPDATE_SOURCE) $(EZ-IPUPDATE_PATCHES)

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
$(EZ-IPUPDATE_BUILD_DIR)/.configured: $(DL_DIR)/$(EZ-IPUPDATE_SOURCE) $(EZ-IPUPDATE_PATCHES) make/ez-ipupdate.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(EZ-IPUPDATE_DIR) $(@D)
	$(EZ-IPUPDATE_UNZIP) $(DL_DIR)/$(EZ-IPUPDATE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(EZ-IPUPDATE_PATCHES)" ; \
		then cat $(EZ-IPUPDATE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(EZ-IPUPDATE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(EZ-IPUPDATE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(EZ-IPUPDATE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(EZ-IPUPDATE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(EZ-IPUPDATE_LDFLAGS)" \
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

ez-ipupdate-unpack: $(EZ-IPUPDATE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(EZ-IPUPDATE_BUILD_DIR)/.built: $(EZ-IPUPDATE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ez-ipupdate: $(EZ-IPUPDATE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(EZ-IPUPDATE_BUILD_DIR)/.staged: $(EZ-IPUPDATE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ez-ipupdate-stage: $(EZ-IPUPDATE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ez-ipupdate
#
$(EZ-IPUPDATE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ez-ipupdate" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(EZ-IPUPDATE_PRIORITY)" >>$@
	@echo "Section: $(EZ-IPUPDATE_SECTION)" >>$@
	@echo "Version: $(EZ-IPUPDATE_VERSION)-$(EZ-IPUPDATE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(EZ-IPUPDATE_MAINTAINER)" >>$@
	@echo "Source: $(EZ-IPUPDATE_SITE)/$(EZ-IPUPDATE_SOURCE)" >>$@
	@echo "Description: $(EZ-IPUPDATE_DESCRIPTION)" >>$@
	@echo "Depends: $(EZ-IPUPDATE_DEPENDS)" >>$@
	@echo "Suggests: $(EZ-IPUPDATE_SUGGESTS)" >>$@
	@echo "Conflicts: $(EZ-IPUPDATE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(EZ-IPUPDATE_IPK_DIR)/opt/sbin or $(EZ-IPUPDATE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(EZ-IPUPDATE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(EZ-IPUPDATE_IPK_DIR)/opt/etc/ez-ipupdate/...
# Documentation files should be installed in $(EZ-IPUPDATE_IPK_DIR)/opt/doc/ez-ipupdate/...
# Daemon startup scripts should be installed in $(EZ-IPUPDATE_IPK_DIR)/opt/etc/init.d/S??ez-ipupdate
#
# You may need to patch your application to make it use these locations.
#
$(EZ-IPUPDATE_IPK): $(EZ-IPUPDATE_BUILD_DIR)/.built
	rm -rf $(EZ-IPUPDATE_IPK_DIR) $(BUILD_DIR)/ez-ipupdate_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(EZ-IPUPDATE_BUILD_DIR) DESTDIR=$(EZ-IPUPDATE_IPK_DIR) install
	$(STRIP_COMMAND) $(EZ-IPUPDATE_IPK_DIR)/opt/bin/ez-ipupdate
	install -d $(EZ-IPUPDATE_IPK_DIR)/opt/share/doc/ez-ipupdate
	install -m 644 $(EZ-IPUPDATE_BUILD_DIR)/[CR]* $(EZ-IPUPDATE_IPK_DIR)/opt/share/doc/ez-ipupdate
#	install -d $(EZ-IPUPDATE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(EZ-IPUPDATE_SOURCE_DIR)/rc.ez-ipupdate $(EZ-IPUPDATE_IPK_DIR)/opt/etc/init.d/SXXez-ipupdate
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(EZ-IPUPDATE_IPK_DIR)/opt/etc/init.d/SXXez-ipupdate
	$(MAKE) $(EZ-IPUPDATE_IPK_DIR)/CONTROL/control
	echo $(EZ-IPUPDATE_CONFFILES) | sed -e 's/ /\n/g' > $(EZ-IPUPDATE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EZ-IPUPDATE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ez-ipupdate-ipk: $(EZ-IPUPDATE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ez-ipupdate-clean:
	rm -f $(EZ-IPUPDATE_BUILD_DIR)/.built
	-$(MAKE) -C $(EZ-IPUPDATE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ez-ipupdate-dirclean:
	rm -rf $(BUILD_DIR)/$(EZ-IPUPDATE_DIR) $(EZ-IPUPDATE_BUILD_DIR) $(EZ-IPUPDATE_IPK_DIR) $(EZ-IPUPDATE_IPK)
#
#
# Some sanity check for the package.
#
ez-ipupdate-check: $(EZ-IPUPDATE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(EZ-IPUPDATE_IPK)
