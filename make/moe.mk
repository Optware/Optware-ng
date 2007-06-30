###########################################################
#
# moe
#
###########################################################
#
# MOE_VERSION, MOE_SITE and MOE_SOURCE define
# the upstream location of the source code for the package.
# MOE_DIR is the directory which is created when the source
# archive is unpacked.
# MOE_UNZIP is the command used to unzip the source.
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
MOE_SITE=http://ftp.gnu.org/gnu/moe
MOE_VERSION=0.9
MOE_SOURCE=moe-$(MOE_VERSION).tar.bz2
MOE_DIR=moe-$(MOE_VERSION)
MOE_UNZIP=bzcat
MOE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MOE_DESCRIPTION=My own editor, a powerful, 8-bit clean text editor for ISO-8859 and ASCII character encodings.
MOE_SECTION=editor
MOE_PRIORITY=optional
MOE_DEPENDS=$(NCURSES_FOR_OPTWARE_TARGET)
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
MOE_DEPENDS+=, libstdc++
endif
MOE_SUGGESTS=
MOE_CONFLICTS=

#
# MOE_IPK_VERSION should be incremented when the ipk changes.
#
MOE_IPK_VERSION=1

#
# MOE_CONFFILES should be a list of user-editable files
#MOE_CONFFILES=/opt/etc/moe.conf /opt/etc/init.d/SXXmoe

#
# MOE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MOE_PATCHES=$(MOE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MOE_CPPFLAGS=
MOE_LDFLAGS=-l$(NCURSES_FOR_OPTWARE_TARGET)

#
# MOE_BUILD_DIR is the directory in which the build is done.
# MOE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MOE_IPK_DIR is the directory in which the ipk is built.
# MOE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MOE_BUILD_DIR=$(BUILD_DIR)/moe
MOE_SOURCE_DIR=$(SOURCE_DIR)/moe
MOE_IPK_DIR=$(BUILD_DIR)/moe-$(MOE_VERSION)-ipk
MOE_IPK=$(BUILD_DIR)/moe_$(MOE_VERSION)-$(MOE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: moe-source moe-unpack moe moe-stage moe-ipk moe-clean moe-dirclean moe-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MOE_SOURCE):
	$(WGET) -P $(DL_DIR) $(MOE_SITE)/$(MOE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(MOE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
moe-source: $(DL_DIR)/$(MOE_SOURCE) $(MOE_PATCHES)

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
$(MOE_BUILD_DIR)/.configured: $(DL_DIR)/$(MOE_SOURCE) $(MOE_PATCHES) make/moe.mk
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	$(MAKE) $(NCURSES_FOR_OPTWARE_TARGET)-stage
	rm -rf $(BUILD_DIR)/$(MOE_DIR) $(MOE_BUILD_DIR)
	$(MOE_UNZIP) $(DL_DIR)/$(MOE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MOE_PATCHES)" ; \
		then cat $(MOE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MOE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MOE_DIR)" != "$(MOE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MOE_DIR) $(MOE_BUILD_DIR) ; \
	fi
	sed -i -e '/-install-info/s/^/#/' $(MOE_BUILD_DIR)/Makefile.in
	(cd $(MOE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MOE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MOE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MOE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MOE_LDFLAGS)" \
	)
	touch $@

moe-unpack: $(MOE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MOE_BUILD_DIR)/.built: $(MOE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MOE_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
moe: $(MOE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MOE_BUILD_DIR)/.staged: $(MOE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(MOE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

moe-stage: $(MOE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/moe
#
$(MOE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: moe" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MOE_PRIORITY)" >>$@
	@echo "Section: $(MOE_SECTION)" >>$@
	@echo "Version: $(MOE_VERSION)-$(MOE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MOE_MAINTAINER)" >>$@
	@echo "Source: $(MOE_SITE)/$(MOE_SOURCE)" >>$@
	@echo "Description: $(MOE_DESCRIPTION)" >>$@
	@echo "Depends: $(MOE_DEPENDS)" >>$@
	@echo "Suggests: $(MOE_SUGGESTS)" >>$@
	@echo "Conflicts: $(MOE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MOE_IPK_DIR)/opt/sbin or $(MOE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MOE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MOE_IPK_DIR)/opt/etc/moe/...
# Documentation files should be installed in $(MOE_IPK_DIR)/opt/doc/moe/...
# Daemon startup scripts should be installed in $(MOE_IPK_DIR)/opt/etc/init.d/S??moe
#
# You may need to patch your application to make it use these locations.
#
$(MOE_IPK): $(MOE_BUILD_DIR)/.built
	rm -rf $(MOE_IPK_DIR) $(BUILD_DIR)/moe_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MOE_BUILD_DIR) DESTDIR=$(MOE_IPK_DIR) install
	$(STRIP_COMMAND) $(MOE_IPK_DIR)/opt/bin/*
#	install -d $(MOE_IPK_DIR)/opt/etc/
#	install -m 644 $(MOE_SOURCE_DIR)/moe.conf $(MOE_IPK_DIR)/opt/etc/moe.conf
#	install -d $(MOE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MOE_SOURCE_DIR)/rc.moe $(MOE_IPK_DIR)/opt/etc/init.d/SXXmoe
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOE_IPK_DIR)/opt/etc/init.d/SXXmoe
	$(MAKE) $(MOE_IPK_DIR)/CONTROL/control
#	install -m 755 $(MOE_SOURCE_DIR)/postinst $(MOE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MOE_SOURCE_DIR)/prerm $(MOE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOE_IPK_DIR)/CONTROL/prerm
	echo $(MOE_CONFFILES) | sed -e 's/ /\n/g' > $(MOE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MOE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
moe-ipk: $(MOE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
moe-clean:
	rm -f $(MOE_BUILD_DIR)/.built
	-$(MAKE) -C $(MOE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
moe-dirclean:
	rm -rf $(BUILD_DIR)/$(MOE_DIR) $(MOE_BUILD_DIR) $(MOE_IPK_DIR) $(MOE_IPK)
#
#
# Some sanity check for the package.
#
moe-check: $(MOE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MOE_IPK)
