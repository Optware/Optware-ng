###########################################################
#
# fcron
#
###########################################################
#
# FCRON_VERSION, FCRON_SITE and FCRON_SOURCE define
# the upstream location of the source code for the package.
# FCRON_DIR is the directory which is created when the source
# archive is unpacked.
# FCRON_UNZIP is the command used to unzip the source.
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
FCRON_SITE=ftp://ftp.seul.org/pub/fcron
FCRON_VERSION=3.0.3
FCRON_SOURCE=fcron-$(FCRON_VERSION).src.tar.gz
FCRON_DIR=fcron-$(FCRON_VERSION)
FCRON_UNZIP=zcat
FCRON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FCRON_DESCRIPTION=Describe fcron here.
FCRON_SECTION=admin
FCRON_PRIORITY=optional
FCRON_DEPENDS=
FCRON_SUGGESTS=
FCRON_CONFLICTS=

#
# FCRON_IPK_VERSION should be incremented when the ipk changes.
#
FCRON_IPK_VERSION=1

#
# FCRON_CONFFILES should be a list of user-editable files
FCRON_CONFFILES=/opt/etc/fcron.conf /opt/etc/fcron.allow /opt/etc/fcron.deny

#
# FCRON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FCRON_PATCHES=$(FCRON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FCRON_CPPFLAGS=
FCRON_LDFLAGS=

#
# FCRON_BUILD_DIR is the directory in which the build is done.
# FCRON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FCRON_IPK_DIR is the directory in which the ipk is built.
# FCRON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FCRON_BUILD_DIR=$(BUILD_DIR)/fcron
FCRON_SOURCE_DIR=$(SOURCE_DIR)/fcron
FCRON_IPK_DIR=$(BUILD_DIR)/fcron-$(FCRON_VERSION)-ipk
FCRON_IPK=$(BUILD_DIR)/fcron_$(FCRON_VERSION)-$(FCRON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fcron-source fcron-unpack fcron fcron-stage fcron-ipk fcron-clean fcron-dirclean fcron-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FCRON_SOURCE):
	$(WGET) -P $(DL_DIR) $(FCRON_SITE)/$(FCRON_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(FCRON_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fcron-source: $(DL_DIR)/$(FCRON_SOURCE) $(FCRON_PATCHES)

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
$(FCRON_BUILD_DIR)/.configured: $(DL_DIR)/$(FCRON_SOURCE) $(FCRON_PATCHES) make/fcron.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(FCRON_DIR) $(FCRON_BUILD_DIR)
	$(FCRON_UNZIP) $(DL_DIR)/$(FCRON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FCRON_PATCHES)" ; \
		then cat $(FCRON_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FCRON_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FCRON_DIR)" != "$(FCRON_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FCRON_DIR) $(FCRON_BUILD_DIR) ; \
	fi
	sed -i -e '/user-group/s/^/#/' $(FCRON_BUILD_DIR)/Makefile.in
	(cd $(FCRON_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FCRON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FCRON_LDFLAGS)" \
		ac_cv_func_memcmp_working=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(FCRON_BUILD_DIR)/libtool
	touch $@

fcron-unpack: $(FCRON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FCRON_BUILD_DIR)/.built: $(FCRON_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(FCRON_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
fcron: $(FCRON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FCRON_BUILD_DIR)/.staged: $(FCRON_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(FCRON_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

fcron-stage: $(FCRON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fcron
#
$(FCRON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: fcron" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FCRON_PRIORITY)" >>$@
	@echo "Section: $(FCRON_SECTION)" >>$@
	@echo "Version: $(FCRON_VERSION)-$(FCRON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FCRON_MAINTAINER)" >>$@
	@echo "Source: $(FCRON_SITE)/$(FCRON_SOURCE)" >>$@
	@echo "Description: $(FCRON_DESCRIPTION)" >>$@
	@echo "Depends: $(FCRON_DEPENDS)" >>$@
	@echo "Suggests: $(FCRON_SUGGESTS)" >>$@
	@echo "Conflicts: $(FCRON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FCRON_IPK_DIR)/opt/sbin or $(FCRON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FCRON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FCRON_IPK_DIR)/opt/etc/fcron/...
# Documentation files should be installed in $(FCRON_IPK_DIR)/opt/doc/fcron/...
# Daemon startup scripts should be installed in $(FCRON_IPK_DIR)/opt/etc/init.d/S??fcron
#
# You may need to patch your application to make it use these locations.
#
$(FCRON_IPK): $(FCRON_BUILD_DIR)/.built
	rm -rf $(FCRON_IPK_DIR) $(BUILD_DIR)/fcron_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FCRON_BUILD_DIR) DESTDIR=$(FCRON_IPK_DIR) install-staged
	$(STRIP_COMMAND) $(FCRON_IPK_DIR)/opt/*bin/fcron*
#	install -d $(FCRON_IPK_DIR)/opt/etc/
#	install -m 644 $(FCRON_SOURCE_DIR)/fcron.conf $(FCRON_IPK_DIR)/opt/etc/fcron.conf
#	install -d $(FCRON_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(FCRON_SOURCE_DIR)/rc.fcron $(FCRON_IPK_DIR)/opt/etc/init.d/SXXfcron
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FCRON_IPK_DIR)/opt/etc/init.d/SXXfcron
	$(MAKE) $(FCRON_IPK_DIR)/CONTROL/control
#	install -m 755 $(FCRON_SOURCE_DIR)/postinst $(FCRON_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FCRON_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(FCRON_SOURCE_DIR)/prerm $(FCRON_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FCRON_IPK_DIR)/CONTROL/prerm
	echo $(FCRON_CONFFILES) | sed -e 's/ /\n/g' > $(FCRON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FCRON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fcron-ipk: $(FCRON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fcron-clean:
	rm -f $(FCRON_BUILD_DIR)/.built
	-$(MAKE) -C $(FCRON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fcron-dirclean:
	rm -rf $(BUILD_DIR)/$(FCRON_DIR) $(FCRON_BUILD_DIR) $(FCRON_IPK_DIR) $(FCRON_IPK)
#
#
# Some sanity check for the package.
#
fcron-check: $(FCRON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FCRON_IPK)
