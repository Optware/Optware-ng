###########################################################
#
# rlfe
#
###########################################################
#
# RLFE_VERSION, RLFE_SITE and RLFE_SOURCE define
# the upstream location of the source code for the package.
# RLFE_DIR is the directory which is created when the source
# archive is unpacked.
# RLFE_UNZIP is the command used to unzip the source.
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
RLFE_SITE=$(READLINE_SITE)
RLFE_VERSION=$(READLINE_VERSION)
RLFE_SOURCE=$(READLINE_SOURCE)
RLFE_DIR=$(READLINE_DIR)
RLFE_UNZIP=zcat
RLFE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RLFE_DESCRIPTION=Readline front-end, add readline to command line programs.
RLFE_SECTION=misc
RLFE_PRIORITY=optional
RLFE_DEPENDS=readline, ncurses
RLFE_SUGGESTS=
RLFE_CONFLICTS=

#
# RLFE_IPK_VERSION should be incremented when the ipk changes.
#
RLFE_IPK_VERSION=1

#
# RLFE_CONFFILES should be a list of user-editable files
#RLFE_CONFFILES=/opt/etc/rlfe.conf /opt/etc/init.d/SXXrlfe

#
# RLFE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#RLFE_PATCHES=$(RLFE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RLFE_CPPFLAGS=
RLFE_LDFLAGS=

#
# RLFE_BUILD_DIR is the directory in which the build is done.
# RLFE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RLFE_IPK_DIR is the directory in which the ipk is built.
# RLFE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RLFE_BUILD_DIR=$(BUILD_DIR)/rlfe
RLFE_SOURCE_DIR=$(SOURCE_DIR)/rlfe
RLFE_IPK_DIR=$(BUILD_DIR)/rlfe-$(RLFE_VERSION)-ipk
RLFE_IPK=$(BUILD_DIR)/rlfe_$(RLFE_VERSION)-$(RLFE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rlfe-source rlfe-unpack rlfe rlfe-stage rlfe-ipk rlfe-clean rlfe-dirclean rlfe-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
# $(DL_DIR)/$(RLFE_SOURCE):
# 	$(WGET) -P $(DL_DIR) $(RLFE_SITE)/$(RLFE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rlfe-source: $(DL_DIR)/$(RLFE_SOURCE) $(RLFE_PATCHES)

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
$(RLFE_BUILD_DIR)/.configured: $(DL_DIR)/$(RLFE_SOURCE) $(RLFE_PATCHES) make/rlfe.mk
	$(MAKE) readline-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(RLFE_DIR) $(RLFE_BUILD_DIR)
	$(RLFE_UNZIP) $(DL_DIR)/$(RLFE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RLFE_PATCHES)" ; \
		then cat $(RLFE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RLFE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(RLFE_DIR)" != "$(RLFE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(RLFE_DIR) $(RLFE_BUILD_DIR) ; \
	fi
	(cd $(RLFE_BUILD_DIR)/examples/rlfe; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RLFE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RLFE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(RLFE_BUILD_DIR)/libtool
	touch $(RLFE_BUILD_DIR)/.configured

rlfe-unpack: $(RLFE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RLFE_BUILD_DIR)/.built: $(RLFE_BUILD_DIR)/.configured
	rm -f $(RLFE_BUILD_DIR)/.built
	$(MAKE) -C $(RLFE_BUILD_DIR)/examples/rlfe OPTIONS="$(STAGING_CPPFLAGS) $(RLFE_CPPFLAGS)"
	touch $(RLFE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
rlfe: $(RLFE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RLFE_BUILD_DIR)/.staged: $(RLFE_BUILD_DIR)/.built
	rm -f $(RLFE_BUILD_DIR)/.staged
#	$(MAKE) -C $(RLFE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(RLFE_BUILD_DIR)/.staged

rlfe-stage: $(RLFE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rlfe
#
$(RLFE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: rlfe" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RLFE_PRIORITY)" >>$@
	@echo "Section: $(RLFE_SECTION)" >>$@
	@echo "Version: $(RLFE_VERSION)-$(RLFE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RLFE_MAINTAINER)" >>$@
	@echo "Source: $(RLFE_SITE)/$(RLFE_SOURCE)" >>$@
	@echo "Description: $(RLFE_DESCRIPTION)" >>$@
	@echo "Depends: $(RLFE_DEPENDS)" >>$@
	@echo "Suggests: $(RLFE_SUGGESTS)" >>$@
	@echo "Conflicts: $(RLFE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RLFE_IPK_DIR)/opt/sbin or $(RLFE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RLFE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RLFE_IPK_DIR)/opt/etc/rlfe/...
# Documentation files should be installed in $(RLFE_IPK_DIR)/opt/doc/rlfe/...
# Daemon startup scripts should be installed in $(RLFE_IPK_DIR)/opt/etc/init.d/S??rlfe
#
# You may need to patch your application to make it use these locations.
#
$(RLFE_IPK): $(RLFE_BUILD_DIR)/.built
	rm -rf $(RLFE_IPK_DIR) $(BUILD_DIR)/rlfe_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(RLFE_BUILD_DIR)/examples/rlfe DESTDIR=$(RLFE_IPK_DIR) install_bin
	install -d $(RLFE_IPK_DIR)/opt/bin/
	install $(RLFE_BUILD_DIR)/examples/rlfe/rlfe $(RLFE_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(RLFE_IPK_DIR)/opt/bin/*
#	install -d $(RLFE_IPK_DIR)/opt/etc/
#	install -m 644 $(RLFE_SOURCE_DIR)/rlfe.conf $(RLFE_IPK_DIR)/opt/etc/rlfe.conf
#	install -d $(RLFE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(RLFE_SOURCE_DIR)/rc.rlfe $(RLFE_IPK_DIR)/opt/etc/init.d/SXXrlfe
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXrlfe
	$(MAKE) $(RLFE_IPK_DIR)/CONTROL/control
#	install -m 755 $(RLFE_SOURCE_DIR)/postinst $(RLFE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(RLFE_SOURCE_DIR)/prerm $(RLFE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(RLFE_CONFFILES) | sed -e 's/ /\n/g' > $(RLFE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RLFE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rlfe-ipk: $(RLFE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rlfe-clean:
	rm -f $(RLFE_BUILD_DIR)/.built
	-$(MAKE) -C $(RLFE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rlfe-dirclean:
	rm -rf $(BUILD_DIR)/$(RLFE_DIR) $(RLFE_BUILD_DIR) $(RLFE_IPK_DIR) $(RLFE_IPK)
#
#
# Some sanity check for the package.
#
rlfe-check: $(RLFE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(RLFE_IPK)
