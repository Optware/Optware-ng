###########################################################
#
# gnu-httptunnel
#
###########################################################
#
# GNU_HTTPTUNNEL_VERSION, GNU_HTTPTUNNEL_SITE and GNU_HTTPTUNNEL_SOURCE define
# the upstream location of the source code for the package.
# GNU_HTTPTUNNEL_DIR is the directory which is created when the source
# archive is unpacked.
# GNU_HTTPTUNNEL_UNZIP is the command used to unzip the source.
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
GNU_HTTPTUNNEL_SITE=http://www.nocrew.org/software/httptunnel
GNU_HTTPTUNNEL_VERSION=3.3
GNU_HTTPTUNNEL_SOURCE=httptunnel-$(GNU_HTTPTUNNEL_VERSION).tar.gz
GNU_HTTPTUNNEL_DIR=httptunnel-$(GNU_HTTPTUNNEL_VERSION)
GNU_HTTPTUNNEL_UNZIP=zcat
GNU_HTTPTUNNEL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GNU_HTTPTUNNEL_DESCRIPTION=httptunnel creates a bidirectional virtual data connection tunnelled in HTTP requests.
GNU_HTTPTUNNEL_SECTION=net
GNU_HTTPTUNNEL_PRIORITY=optional
GNU_HTTPTUNNEL_DEPENDS=
GNU_HTTPTUNNEL_SUGGESTS=
GNU_HTTPTUNNEL_CONFLICTS=

#
# GNU_HTTPTUNNEL_IPK_VERSION should be incremented when the ipk changes.
#
GNU_HTTPTUNNEL_IPK_VERSION=1

#
# GNU_HTTPTUNNEL_CONFFILES should be a list of user-editable files
#GNU_HTTPTUNNEL_CONFFILES=/opt/etc/gnu-httptunnel.conf /opt/etc/init.d/SXXgnu-httptunnel

#
# GNU_HTTPTUNNEL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GNU_HTTPTUNNEL_PATCHES=$(GNU_HTTPTUNNEL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GNU_HTTPTUNNEL_CPPFLAGS=
GNU_HTTPTUNNEL_LDFLAGS=

#
# GNU_HTTPTUNNEL_BUILD_DIR is the directory in which the build is done.
# GNU_HTTPTUNNEL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GNU_HTTPTUNNEL_IPK_DIR is the directory in which the ipk is built.
# GNU_HTTPTUNNEL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GNU_HTTPTUNNEL_BUILD_DIR=$(BUILD_DIR)/gnu-httptunnel
GNU_HTTPTUNNEL_SOURCE_DIR=$(SOURCE_DIR)/gnu-httptunnel
GNU_HTTPTUNNEL_IPK_DIR=$(BUILD_DIR)/gnu-httptunnel-$(GNU_HTTPTUNNEL_VERSION)-ipk
GNU_HTTPTUNNEL_IPK=$(BUILD_DIR)/gnu-httptunnel_$(GNU_HTTPTUNNEL_VERSION)-$(GNU_HTTPTUNNEL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gnu-httptunnel-source gnu-httptunnel-unpack gnu-httptunnel gnu-httptunnel-stage gnu-httptunnel-ipk gnu-httptunnel-clean gnu-httptunnel-dirclean gnu-httptunnel-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GNU_HTTPTUNNEL_SOURCE):
	$(WGET) -P $(DL_DIR) $(GNU_HTTPTUNNEL_SITE)/$(GNU_HTTPTUNNEL_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(GNU_HTTPTUNNEL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gnu-httptunnel-source: $(DL_DIR)/$(GNU_HTTPTUNNEL_SOURCE) $(GNU_HTTPTUNNEL_PATCHES)

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
$(GNU_HTTPTUNNEL_BUILD_DIR)/.configured: $(DL_DIR)/$(GNU_HTTPTUNNEL_SOURCE) $(GNU_HTTPTUNNEL_PATCHES) make/gnu-httptunnel.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(GNU_HTTPTUNNEL_DIR) $(GNU_HTTPTUNNEL_BUILD_DIR)
	$(GNU_HTTPTUNNEL_UNZIP) $(DL_DIR)/$(GNU_HTTPTUNNEL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GNU_HTTPTUNNEL_PATCHES)" ; \
		then cat $(GNU_HTTPTUNNEL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GNU_HTTPTUNNEL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GNU_HTTPTUNNEL_DIR)" != "$(GNU_HTTPTUNNEL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(GNU_HTTPTUNNEL_DIR) $(GNU_HTTPTUNNEL_BUILD_DIR) ; \
	fi
	(cd $(GNU_HTTPTUNNEL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GNU_HTTPTUNNEL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GNU_HTTPTUNNEL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(GNU_HTTPTUNNEL_BUILD_DIR)/libtool
	touch $@

gnu-httptunnel-unpack: $(GNU_HTTPTUNNEL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GNU_HTTPTUNNEL_BUILD_DIR)/.built: $(GNU_HTTPTUNNEL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(GNU_HTTPTUNNEL_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
gnu-httptunnel: $(GNU_HTTPTUNNEL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GNU_HTTPTUNNEL_BUILD_DIR)/.staged: $(GNU_HTTPTUNNEL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(GNU_HTTPTUNNEL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

gnu-httptunnel-stage: $(GNU_HTTPTUNNEL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gnu-httptunnel
#
$(GNU_HTTPTUNNEL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gnu-httptunnel" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GNU_HTTPTUNNEL_PRIORITY)" >>$@
	@echo "Section: $(GNU_HTTPTUNNEL_SECTION)" >>$@
	@echo "Version: $(GNU_HTTPTUNNEL_VERSION)-$(GNU_HTTPTUNNEL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GNU_HTTPTUNNEL_MAINTAINER)" >>$@
	@echo "Source: $(GNU_HTTPTUNNEL_SITE)/$(GNU_HTTPTUNNEL_SOURCE)" >>$@
	@echo "Description: $(GNU_HTTPTUNNEL_DESCRIPTION)" >>$@
	@echo "Depends: $(GNU_HTTPTUNNEL_DEPENDS)" >>$@
	@echo "Suggests: $(GNU_HTTPTUNNEL_SUGGESTS)" >>$@
	@echo "Conflicts: $(GNU_HTTPTUNNEL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GNU_HTTPTUNNEL_IPK_DIR)/opt/sbin or $(GNU_HTTPTUNNEL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GNU_HTTPTUNNEL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GNU_HTTPTUNNEL_IPK_DIR)/opt/etc/gnu-httptunnel/...
# Documentation files should be installed in $(GNU_HTTPTUNNEL_IPK_DIR)/opt/doc/gnu-httptunnel/...
# Daemon startup scripts should be installed in $(GNU_HTTPTUNNEL_IPK_DIR)/opt/etc/init.d/S??gnu-httptunnel
#
# You may need to patch your application to make it use these locations.
#
$(GNU_HTTPTUNNEL_IPK): $(GNU_HTTPTUNNEL_BUILD_DIR)/.built
	rm -rf $(GNU_HTTPTUNNEL_IPK_DIR) $(BUILD_DIR)/gnu-httptunnel_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GNU_HTTPTUNNEL_BUILD_DIR) DESTDIR=$(GNU_HTTPTUNNEL_IPK_DIR) install
	$(STRIP_COMMAND) $(GNU_HTTPTUNNEL_IPK_DIR)/opt/bin/ht*
#	install -d $(GNU_HTTPTUNNEL_IPK_DIR)/opt/etc/
#	install -m 644 $(GNU_HTTPTUNNEL_SOURCE_DIR)/gnu-httptunnel.conf $(GNU_HTTPTUNNEL_IPK_DIR)/opt/etc/gnu-httptunnel.conf
#	install -d $(GNU_HTTPTUNNEL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(GNU_HTTPTUNNEL_SOURCE_DIR)/rc.gnu-httptunnel $(GNU_HTTPTUNNEL_IPK_DIR)/opt/etc/init.d/SXXgnu-httptunnel
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GNU_HTTPTUNNEL_IPK_DIR)/opt/etc/init.d/SXXgnu-httptunnel
	$(MAKE) $(GNU_HTTPTUNNEL_IPK_DIR)/CONTROL/control
#	install -m 755 $(GNU_HTTPTUNNEL_SOURCE_DIR)/postinst $(GNU_HTTPTUNNEL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GNU_HTTPTUNNEL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GNU_HTTPTUNNEL_SOURCE_DIR)/prerm $(GNU_HTTPTUNNEL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GNU_HTTPTUNNEL_IPK_DIR)/CONTROL/prerm
	echo $(GNU_HTTPTUNNEL_CONFFILES) | sed -e 's/ /\n/g' > $(GNU_HTTPTUNNEL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GNU_HTTPTUNNEL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gnu-httptunnel-ipk: $(GNU_HTTPTUNNEL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gnu-httptunnel-clean:
	rm -f $(GNU_HTTPTUNNEL_BUILD_DIR)/.built
	-$(MAKE) -C $(GNU_HTTPTUNNEL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gnu-httptunnel-dirclean:
	rm -rf $(BUILD_DIR)/$(GNU_HTTPTUNNEL_DIR) $(GNU_HTTPTUNNEL_BUILD_DIR) $(GNU_HTTPTUNNEL_IPK_DIR) $(GNU_HTTPTUNNEL_IPK)
#
#
# Some sanity check for the package.
#
gnu-httptunnel-check: $(GNU_HTTPTUNNEL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GNU_HTTPTUNNEL_IPK)
