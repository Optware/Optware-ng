###########################################################
#
# nanoblogger
#
###########################################################
#
# NANOBLOGGER_VERSION, NANOBLOGGER_SITE and NANOBLOGGER_SOURCE define
# the upstream location of the source code for the package.
# NANOBLOGGER_DIR is the directory which is created when the source
# archive is unpacked.
# NANOBLOGGER_UNZIP is the command used to unzip the source.
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
NANOBLOGGER_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/nanoblogger
NANOBLOGGER_VERSION=3.3
NANOBLOGGER_SOURCE=nanoblogger-$(NANOBLOGGER_VERSION).tar.gz
NANOBLOGGER_DIR=nanoblogger-$(NANOBLOGGER_VERSION)
NANOBLOGGER_UNZIP=zcat
NANOBLOGGER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NANOBLOGGER_DESCRIPTION=A small weblog engine written in Bash for the command line.
NANOBLOGGER_SECTION=web
NANOBLOGGER_PRIORITY=optional
NANOBLOGGER_DEPENDS=bash, grep, sed, coreutils, bsdmainutils
NANOBLOGGER_SUGGESTS=
NANOBLOGGER_CONFLICTS=

#
# NANOBLOGGER_IPK_VERSION should be incremented when the ipk changes.
#
NANOBLOGGER_IPK_VERSION=3

#
# NANOBLOGGER_CONFFILES should be a list of user-editable files
NANOBLOGGER_CONFFILES=/opt/etc/nb.conf

#
# NANOBLOGGER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NANOBLOGGER_PATCHES=$(NANOBLOGGER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NANOBLOGGER_CPPFLAGS=
NANOBLOGGER_LDFLAGS=

#
# NANOBLOGGER_BUILD_DIR is the directory in which the build is done.
# NANOBLOGGER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NANOBLOGGER_IPK_DIR is the directory in which the ipk is built.
# NANOBLOGGER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NANOBLOGGER_BUILD_DIR=$(BUILD_DIR)/nanoblogger
NANOBLOGGER_SOURCE_DIR=$(SOURCE_DIR)/nanoblogger
NANOBLOGGER_IPK_DIR=$(BUILD_DIR)/nanoblogger-$(NANOBLOGGER_VERSION)-ipk
NANOBLOGGER_IPK=$(BUILD_DIR)/nanoblogger_$(NANOBLOGGER_VERSION)-$(NANOBLOGGER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nanoblogger-source nanoblogger-unpack nanoblogger nanoblogger-stage nanoblogger-ipk nanoblogger-clean nanoblogger-dirclean nanoblogger-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NANOBLOGGER_SOURCE):
	$(WGET) -P $(DL_DIR) $(NANOBLOGGER_SITE)/$(NANOBLOGGER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nanoblogger-source: $(DL_DIR)/$(NANOBLOGGER_SOURCE) $(NANOBLOGGER_PATCHES)

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
$(NANOBLOGGER_BUILD_DIR)/.configured: $(DL_DIR)/$(NANOBLOGGER_SOURCE) $(NANOBLOGGER_PATCHES) make/nanoblogger.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(NANOBLOGGER_DIR) $(NANOBLOGGER_BUILD_DIR)
	$(NANOBLOGGER_UNZIP) $(DL_DIR)/$(NANOBLOGGER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NANOBLOGGER_PATCHES)" ; \
		then cat $(NANOBLOGGER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NANOBLOGGER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NANOBLOGGER_DIR)" != "$(NANOBLOGGER_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NANOBLOGGER_DIR) $(NANOBLOGGER_BUILD_DIR) ; \
	fi
	sed -i -e 's|/bin/bash|/opt/bin/bash|' \
		-e '/^NB_BASE_DIR=/s|.*|NB_BASE_DIR=/opt/share/nanoblogger|' \
		-e '/^NB_CFG_DIR=/s|.*|NB_CFG_DIR=/opt/etc|' \
		$(NANOBLOGGER_BUILD_DIR)/nb
	sed -i -e '/BLOG_DIR/s|.*|BLOG_DIR=/opt/share/www|' \
		$(NANOBLOGGER_BUILD_DIR)/nb.conf
	touch $(NANOBLOGGER_BUILD_DIR)/.configured

nanoblogger-unpack: $(NANOBLOGGER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NANOBLOGGER_BUILD_DIR)/.built: $(NANOBLOGGER_BUILD_DIR)/.configured
	rm -f $(NANOBLOGGER_BUILD_DIR)/.built
#	$(MAKE) -C $(NANOBLOGGER_BUILD_DIR)
	touch $(NANOBLOGGER_BUILD_DIR)/.built

#
# This is the build convenience target.
#
nanoblogger: $(NANOBLOGGER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NANOBLOGGER_BUILD_DIR)/.staged: $(NANOBLOGGER_BUILD_DIR)/.built
	rm -f $(NANOBLOGGER_BUILD_DIR)/.staged
#	$(MAKE) -C $(NANOBLOGGER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(NANOBLOGGER_BUILD_DIR)/.staged

nanoblogger-stage: $(NANOBLOGGER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nanoblogger
#
$(NANOBLOGGER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nanoblogger" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NANOBLOGGER_PRIORITY)" >>$@
	@echo "Section: $(NANOBLOGGER_SECTION)" >>$@
	@echo "Version: $(NANOBLOGGER_VERSION)-$(NANOBLOGGER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NANOBLOGGER_MAINTAINER)" >>$@
	@echo "Source: $(NANOBLOGGER_SITE)/$(NANOBLOGGER_SOURCE)" >>$@
	@echo "Description: $(NANOBLOGGER_DESCRIPTION)" >>$@
	@echo "Depends: $(NANOBLOGGER_DEPENDS)" >>$@
	@echo "Suggests: $(NANOBLOGGER_SUGGESTS)" >>$@
	@echo "Conflicts: $(NANOBLOGGER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NANOBLOGGER_IPK_DIR)/opt/sbin or $(NANOBLOGGER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NANOBLOGGER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NANOBLOGGER_IPK_DIR)/opt/etc/nanoblogger/...
# Documentation files should be installed in $(NANOBLOGGER_IPK_DIR)/opt/doc/nanoblogger/...
# Daemon startup scripts should be installed in $(NANOBLOGGER_IPK_DIR)/opt/etc/init.d/S??nanoblogger
#
# You may need to patch your application to make it use these locations.
#
$(NANOBLOGGER_IPK): $(NANOBLOGGER_BUILD_DIR)/.built
	rm -rf $(NANOBLOGGER_IPK_DIR) $(BUILD_DIR)/nanoblogger_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(NANOBLOGGER_BUILD_DIR) DESTDIR=$(NANOBLOGGER_IPK_DIR) install-strip
	install -d $(NANOBLOGGER_IPK_DIR)/opt/bin/
	install -d $(NANOBLOGGER_IPK_DIR)/opt/share/
	install -d $(NANOBLOGGER_IPK_DIR)/opt/etc/ 
	cp -r $(NANOBLOGGER_BUILD_DIR) $(NANOBLOGGER_IPK_DIR)/opt/share/
	cd $(NANOBLOGGER_IPK_DIR)/opt/share/nanoblogger; \
		rm -f .configured .built; \
		mv nb $(NANOBLOGGER_IPK_DIR)/opt/bin/; \
		mv nb.conf $(NANOBLOGGER_IPK_DIR)/opt/etc
	install -d $(NANOBLOGGER_IPK_DIR)/opt/share/www
#	install -m 644 $(NANOBLOGGER_SOURCE_DIR)/nanoblogger.conf $(NANOBLOGGER_IPK_DIR)/opt/etc/nanoblogger.conf
#	install -d $(NANOBLOGGER_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NANOBLOGGER_SOURCE_DIR)/rc.nanoblogger $(NANOBLOGGER_IPK_DIR)/opt/etc/init.d/SXXnanoblogger
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXnanoblogger
	$(MAKE) $(NANOBLOGGER_IPK_DIR)/CONTROL/control
#	install -m 755 $(NANOBLOGGER_SOURCE_DIR)/postinst $(NANOBLOGGER_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NANOBLOGGER_SOURCE_DIR)/prerm $(NANOBLOGGER_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(NANOBLOGGER_CONFFILES) | sed -e 's/ /\n/g' > $(NANOBLOGGER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NANOBLOGGER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nanoblogger-ipk: $(NANOBLOGGER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nanoblogger-clean:
	rm -f $(NANOBLOGGER_BUILD_DIR)/.built
	-$(MAKE) -C $(NANOBLOGGER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nanoblogger-dirclean:
	rm -rf $(BUILD_DIR)/$(NANOBLOGGER_DIR) $(NANOBLOGGER_BUILD_DIR) $(NANOBLOGGER_IPK_DIR) $(NANOBLOGGER_IPK)
#
#
# Some sanity check for the package.
#
nanoblogger-check: $(NANOBLOGGER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NANOBLOGGER_IPK)
