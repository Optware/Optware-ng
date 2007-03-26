###########################################################
#
# tmsnc
#
###########################################################
#
# TMSNC_VERSION, TMSNC_SITE and TMSNC_SOURCE define
# the upstream location of the source code for the package.
# TMSNC_DIR is the directory which is created when the source
# archive is unpacked.
# TMSNC_UNZIP is the command used to unzip the source.
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
TMSNC_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/tmsnc
TMSNC_VERSION=0.3.2
TMSNC_SOURCE=tmsnc-$(TMSNC_VERSION).tar.gz
TMSNC_DIR=tmsnc-$(TMSNC_VERSION)
TMSNC_UNZIP=zcat
TMSNC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TMSNC_DESCRIPTION=Text-based MSN client.
TMSNC_SECTION=net
TMSNC_PRIORITY=optional
TMSNC_DEPENDS=$(NCURSES_FOR_OPTWARE_TARGET), openssl
TMSNC_SUGGESTS=
TMSNC_CONFLICTS=

#
# TMSNC_IPK_VERSION should be incremented when the ipk changes.
#
TMSNC_IPK_VERSION=1

#
# TMSNC_CONFFILES should be a list of user-editable files
#TMSNC_CONFFILES=/opt/etc/tmsnc.conf /opt/etc/init.d/SXXtmsnc

#
# TMSNC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TMSNC_PATCHES=$(TMSNC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TMSNC_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/$(NCURSES_FOR_OPTWARE_TARGET)
TMSNC_LDFLAGS=

#
# TMSNC_BUILD_DIR is the directory in which the build is done.
# TMSNC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TMSNC_IPK_DIR is the directory in which the ipk is built.
# TMSNC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TMSNC_BUILD_DIR=$(BUILD_DIR)/tmsnc
TMSNC_SOURCE_DIR=$(SOURCE_DIR)/tmsnc
TMSNC_IPK_DIR=$(BUILD_DIR)/tmsnc-$(TMSNC_VERSION)-ipk
TMSNC_IPK=$(BUILD_DIR)/tmsnc_$(TMSNC_VERSION)-$(TMSNC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tmsnc-source tmsnc-unpack tmsnc tmsnc-stage tmsnc-ipk tmsnc-clean tmsnc-dirclean tmsnc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TMSNC_SOURCE):
	$(WGET) -P $(DL_DIR) $(TMSNC_SITE)/$(TMSNC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tmsnc-source: $(DL_DIR)/$(TMSNC_SOURCE) $(TMSNC_PATCHES)

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
$(TMSNC_BUILD_DIR)/.configured: $(DL_DIR)/$(TMSNC_SOURCE) $(TMSNC_PATCHES) make/tmsnc.mk
	$(MAKE) $(NCURSES_FOR_OPTWARE_TARGET)-stage
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(TMSNC_DIR) $(TMSNC_BUILD_DIR)
	$(TMSNC_UNZIP) $(DL_DIR)/$(TMSNC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TMSNC_PATCHES)" ; \
		then cat $(TMSNC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TMSNC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TMSNC_DIR)" != "$(TMSNC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TMSNC_DIR) $(TMSNC_BUILD_DIR) ; \
	fi
	(cd $(TMSNC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TMSNC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TMSNC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-$(NCURSES_FOR_OPTWARE_TARGET)=$(STAGING_PREFIX) \
		--with-openssl=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(TMSNC_BUILD_DIR)/libtool
	touch $(TMSNC_BUILD_DIR)/.configured

tmsnc-unpack: $(TMSNC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TMSNC_BUILD_DIR)/.built: $(TMSNC_BUILD_DIR)/.configured
	rm -f $(TMSNC_BUILD_DIR)/.built
	$(MAKE) -C $(TMSNC_BUILD_DIR)
	touch $(TMSNC_BUILD_DIR)/.built

#
# This is the build convenience target.
#
tmsnc: $(TMSNC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TMSNC_BUILD_DIR)/.staged: $(TMSNC_BUILD_DIR)/.built
	rm -f $(TMSNC_BUILD_DIR)/.staged
	$(MAKE) -C $(TMSNC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(TMSNC_BUILD_DIR)/.staged

tmsnc-stage: $(TMSNC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tmsnc
#
$(TMSNC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tmsnc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TMSNC_PRIORITY)" >>$@
	@echo "Section: $(TMSNC_SECTION)" >>$@
	@echo "Version: $(TMSNC_VERSION)-$(TMSNC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TMSNC_MAINTAINER)" >>$@
	@echo "Source: $(TMSNC_SITE)/$(TMSNC_SOURCE)" >>$@
	@echo "Description: $(TMSNC_DESCRIPTION)" >>$@
	@echo "Depends: $(TMSNC_DEPENDS)" >>$@
	@echo "Suggests: $(TMSNC_SUGGESTS)" >>$@
	@echo "Conflicts: $(TMSNC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TMSNC_IPK_DIR)/opt/sbin or $(TMSNC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TMSNC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TMSNC_IPK_DIR)/opt/etc/tmsnc/...
# Documentation files should be installed in $(TMSNC_IPK_DIR)/opt/doc/tmsnc/...
# Daemon startup scripts should be installed in $(TMSNC_IPK_DIR)/opt/etc/init.d/S??tmsnc
#
# You may need to patch your application to make it use these locations.
#
$(TMSNC_IPK): $(TMSNC_BUILD_DIR)/.built
	rm -rf $(TMSNC_IPK_DIR) $(BUILD_DIR)/tmsnc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TMSNC_BUILD_DIR) DESTDIR=$(TMSNC_IPK_DIR) install
	$(STRIP_COMMAND) $(TMSNC_IPK_DIR)/opt/bin/tmsnc
#	install -d $(TMSNC_IPK_DIR)/opt/etc/
#	install -m 644 $(TMSNC_SOURCE_DIR)/tmsnc.conf $(TMSNC_IPK_DIR)/opt/etc/tmsnc.conf
#	install -d $(TMSNC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TMSNC_SOURCE_DIR)/rc.tmsnc $(TMSNC_IPK_DIR)/opt/etc/init.d/SXXtmsnc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXtmsnc
	$(MAKE) $(TMSNC_IPK_DIR)/CONTROL/control
#	install -m 755 $(TMSNC_SOURCE_DIR)/postinst $(TMSNC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TMSNC_SOURCE_DIR)/prerm $(TMSNC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
#	echo $(TMSNC_CONFFILES) | sed -e 's/ /\n/g' > $(TMSNC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TMSNC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tmsnc-ipk: $(TMSNC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tmsnc-clean:
	rm -f $(TMSNC_BUILD_DIR)/.built
	-$(MAKE) -C $(TMSNC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tmsnc-dirclean:
	rm -rf $(BUILD_DIR)/$(TMSNC_DIR) $(TMSNC_BUILD_DIR) $(TMSNC_IPK_DIR) $(TMSNC_IPK)
#
#
# Some sanity check for the package.
#
tmsnc-check: $(TMSNC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TMSNC_IPK)
