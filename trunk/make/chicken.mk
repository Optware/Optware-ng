###########################################################
#
# chicken
#
###########################################################
#
# CHICKEN_VERSION, CHICKEN_SITE and CHICKEN_SOURCE define
# the upstream location of the source code for the package.
# CHICKEN_DIR is the directory which is created when the source
# archive is unpacked.
# CHICKEN_UNZIP is the command used to unzip the source.
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
CHICKEN_SITE=http://www.call-with-current-continuation.org
CHICKEN_VERSION=2.6
CHICKEN_SOURCE=chicken-$(CHICKEN_VERSION).tar.gz
CHICKEN_DIR=chicken-$(CHICKEN_VERSION)
CHICKEN_UNZIP=zcat
CHICKEN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CHICKEN_DESCRIPTION=A practical and portable Scheme system.
CHICKEN_SECTION=lang
CHICKEN_PRIORITY=optional
CHICKEN_DEPENDS=
CHICKEN_SUGGESTS=
CHICKEN_CONFLICTS=

#
# CHICKEN_IPK_VERSION should be incremented when the ipk changes.
#
CHICKEN_IPK_VERSION=1

#
# CHICKEN_CONFFILES should be a list of user-editable files
#CHICKEN_CONFFILES=/opt/etc/chicken.conf /opt/etc/init.d/SXXchicken

#
# CHICKEN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CHICKEN_PATCHES=$(CHICKEN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CHICKEN_CPPFLAGS=
CHICKEN_LDFLAGS=

#
# CHICKEN_BUILD_DIR is the directory in which the build is done.
# CHICKEN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CHICKEN_IPK_DIR is the directory in which the ipk is built.
# CHICKEN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CHICKEN_BUILD_DIR=$(BUILD_DIR)/chicken
CHICKEN_SOURCE_DIR=$(SOURCE_DIR)/chicken
CHICKEN_IPK_DIR=$(BUILD_DIR)/chicken-$(CHICKEN_VERSION)-ipk
CHICKEN_IPK=$(BUILD_DIR)/chicken_$(CHICKEN_VERSION)-$(CHICKEN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: chicken-source chicken-unpack chicken chicken-stage chicken-ipk chicken-clean chicken-dirclean chicken-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CHICKEN_SOURCE):
	$(WGET) -P $(DL_DIR) $(CHICKEN_SITE)/$(CHICKEN_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(CHICKEN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
chicken-source: $(DL_DIR)/$(CHICKEN_SOURCE) $(CHICKEN_PATCHES)

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
$(CHICKEN_BUILD_DIR)/.configured: $(DL_DIR)/$(CHICKEN_SOURCE) $(CHICKEN_PATCHES) make/chicken.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(CHICKEN_DIR) $(CHICKEN_BUILD_DIR)
	$(CHICKEN_UNZIP) $(DL_DIR)/$(CHICKEN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CHICKEN_PATCHES)" ; \
		then cat $(CHICKEN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CHICKEN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CHICKEN_DIR)" != "$(CHICKEN_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CHICKEN_DIR) $(CHICKEN_BUILD_DIR) ; \
	fi
	(cd $(CHICKEN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CHICKEN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CHICKEN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(CHICKEN_BUILD_DIR)/libtool
	touch $@

chicken-unpack: $(CHICKEN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CHICKEN_BUILD_DIR)/.built: $(CHICKEN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(CHICKEN_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
chicken: $(CHICKEN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CHICKEN_BUILD_DIR)/.staged: $(CHICKEN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(CHICKEN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

chicken-stage: $(CHICKEN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/chicken
#
$(CHICKEN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: chicken" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CHICKEN_PRIORITY)" >>$@
	@echo "Section: $(CHICKEN_SECTION)" >>$@
	@echo "Version: $(CHICKEN_VERSION)-$(CHICKEN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CHICKEN_MAINTAINER)" >>$@
	@echo "Source: $(CHICKEN_SITE)/$(CHICKEN_SOURCE)" >>$@
	@echo "Description: $(CHICKEN_DESCRIPTION)" >>$@
	@echo "Depends: $(CHICKEN_DEPENDS)" >>$@
	@echo "Suggests: $(CHICKEN_SUGGESTS)" >>$@
	@echo "Conflicts: $(CHICKEN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CHICKEN_IPK_DIR)/opt/sbin or $(CHICKEN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CHICKEN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CHICKEN_IPK_DIR)/opt/etc/chicken/...
# Documentation files should be installed in $(CHICKEN_IPK_DIR)/opt/doc/chicken/...
# Daemon startup scripts should be installed in $(CHICKEN_IPK_DIR)/opt/etc/init.d/S??chicken
#
# You may need to patch your application to make it use these locations.
#
$(CHICKEN_IPK): $(CHICKEN_BUILD_DIR)/.built
	rm -rf $(CHICKEN_IPK_DIR) $(BUILD_DIR)/chicken_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CHICKEN_BUILD_DIR) DESTDIR=$(CHICKEN_IPK_DIR) install-strip
#	install -d $(CHICKEN_IPK_DIR)/opt/etc/
#	install -m 644 $(CHICKEN_SOURCE_DIR)/chicken.conf $(CHICKEN_IPK_DIR)/opt/etc/chicken.conf
#	install -d $(CHICKEN_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CHICKEN_SOURCE_DIR)/rc.chicken $(CHICKEN_IPK_DIR)/opt/etc/init.d/SXXchicken
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CHICKEN_IPK_DIR)/opt/etc/init.d/SXXchicken
	$(MAKE) $(CHICKEN_IPK_DIR)/CONTROL/control
#	install -m 755 $(CHICKEN_SOURCE_DIR)/postinst $(CHICKEN_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CHICKEN_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CHICKEN_SOURCE_DIR)/prerm $(CHICKEN_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CHICKEN_IPK_DIR)/CONTROL/prerm
	echo $(CHICKEN_CONFFILES) | sed -e 's/ /\n/g' > $(CHICKEN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CHICKEN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
chicken-ipk: $(CHICKEN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
chicken-clean:
	rm -f $(CHICKEN_BUILD_DIR)/.built
	-$(MAKE) -C $(CHICKEN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
chicken-dirclean:
	rm -rf $(BUILD_DIR)/$(CHICKEN_DIR) $(CHICKEN_BUILD_DIR) $(CHICKEN_IPK_DIR) $(CHICKEN_IPK)
#
#
# Some sanity check for the package.
#
chicken-check: $(CHICKEN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CHICKEN_IPK)
