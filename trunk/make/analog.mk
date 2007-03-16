###########################################################
#
# analog
#
###########################################################
#
# ANALOG_VERSION, ANALOG_SITE and ANALOG_SOURCE define
# the upstream location of the source code for the package.
# ANALOG_DIR is the directory which is created when the source
# archive is unpacked.
# ANALOG_UNZIP is the command used to unzip the source.
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
# http://www.analog.cx/docs/Readme.html
# TODO rework for shared libraries
#
ANALOG_SITE=http://www.analog.cx
ANALOG_VERSION=6.0
ANALOG_SOURCE=analog-$(ANALOG_VERSION).tar.gz
ANALOG_DIR=analog-$(ANALOG_VERSION)
ANALOG_UNZIP=zcat
ANALOG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ANALOG_DESCRIPTION=The most popular logfile analyser in the world.
ANALOG_SECTION=web
ANALOG_PRIORITY=optional
ANALOG_DEPENDS=
ANALOG_SUGGESTS=
ANALOG_CONFLICTS=

#
# ANALOG_IPK_VERSION should be incremented when the ipk changes.
#
ANALOG_IPK_VERSION=1

#
# ANALOG_CONFFILES should be a list of user-editable files
ANALOG_CONFFILES=/opt/etc/analog.cfg
#/opt/etc/init.d/SXXanalog

#
# ANALOG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ANALOG_PATCHES=$(ANALOG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ANALOG_CPPFLAGS=
ANALOG_LDFLAGS=

#
# ANALOG_BUILD_DIR is the directory in which the build is done.
# ANALOG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ANALOG_IPK_DIR is the directory in which the ipk is built.
# ANALOG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ANALOG_BUILD_DIR=$(BUILD_DIR)/analog
ANALOG_SOURCE_DIR=$(SOURCE_DIR)/analog
ANALOG_IPK_DIR=$(BUILD_DIR)/analog-$(ANALOG_VERSION)-ipk
ANALOG_IPK=$(BUILD_DIR)/analog_$(ANALOG_VERSION)-$(ANALOG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: analog-source analog-unpack analog analog-stage analog-ipk analog-clean analog-dirclean analog-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ANALOG_SOURCE):
	$(WGET) -P $(DL_DIR) $(ANALOG_SITE)/$(ANALOG_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(ANALOG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
analog-source: $(DL_DIR)/$(ANALOG_SOURCE) $(ANALOG_PATCHES)

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
$(ANALOG_BUILD_DIR)/.configured: $(DL_DIR)/$(ANALOG_SOURCE) $(ANALOG_PATCHES) make/analog.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ANALOG_DIR) $(ANALOG_BUILD_DIR)
	$(ANALOG_UNZIP) $(DL_DIR)/$(ANALOG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ANALOG_PATCHES)" ; \
		then cat $(ANALOG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ANALOG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ANALOG_DIR)" != "$(ANALOG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ANALOG_DIR) $(ANALOG_BUILD_DIR) ; \
	fi
#	(cd $(ANALOG_BUILD_DIR); \
#		$(TARGET_CONFIGURE_OPTS) \
#		CPPFLAGS="$(STAGING_CPPFLAGS) $(ANALOG_CPPFLAGS)" \
#		LDFLAGS="$(STAGING_LDFLAGS) $(ANALOG_LDFLAGS)" \
#		./configure \
#		--build=$(GNU_HOST_NAME) \
#		--host=$(GNU_TARGET_NAME) \
#		--target=$(GNU_TARGET_NAME) \
#		--prefix=/opt \
#		--disable-nls \
#		--disable-static \
#	)
	sed -i -e '/^CC/d;/^CFLAGS/d;' \
		$(ANALOG_BUILD_DIR)/src/Makefile
#	$(PATCH_LIBTOOL) $(ANALOG_BUILD_DIR)/libtool
	touch $@

analog-unpack: $(ANALOG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ANALOG_BUILD_DIR)/.built: $(ANALOG_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(STAGING_CPPFLAGS) $(ANALOG_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(ANALOG_LDFLAGS)" \
	$(MAKE) -C $(ANALOG_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
analog: $(ANALOG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ANALOG_BUILD_DIR)/.staged: $(ANALOG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(ANALOG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

analog-stage: $(ANALOG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/analog
#
$(ANALOG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: analog" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ANALOG_PRIORITY)" >>$@
	@echo "Section: $(ANALOG_SECTION)" >>$@
	@echo "Version: $(ANALOG_VERSION)-$(ANALOG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ANALOG_MAINTAINER)" >>$@
	@echo "Source: $(ANALOG_SITE)/$(ANALOG_SOURCE)" >>$@
	@echo "Description: $(ANALOG_DESCRIPTION)" >>$@
	@echo "Depends: $(ANALOG_DEPENDS)" >>$@
	@echo "Suggests: $(ANALOG_SUGGESTS)" >>$@
	@echo "Conflicts: $(ANALOG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ANALOG_IPK_DIR)/opt/sbin or $(ANALOG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ANALOG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ANALOG_IPK_DIR)/opt/etc/analog/...
# Documentation files should be installed in $(ANALOG_IPK_DIR)/opt/doc/analog/...
# Daemon startup scripts should be installed in $(ANALOG_IPK_DIR)/opt/etc/init.d/S??analog
#
# You may need to patch your application to make it use these locations.
#
$(ANALOG_IPK): $(ANALOG_BUILD_DIR)/.built
	rm -rf $(ANALOG_IPK_DIR) $(BUILD_DIR)/analog_*_$(TARGET_ARCH).ipk
	install -d $(ANALOG_IPK_DIR)/opt/etc
	install -d $(ANALOG_IPK_DIR)/opt/bin
	install -d $(ANALOG_IPK_DIR)/opt/share/analog/lang
	install -d $(ANALOG_IPK_DIR)/opt/share/www/images
	install -m 644 $(ANALOG_BUILD_DIR)/images/* $(ANALOG_IPK_DIR)/opt/share/www/images
	install -m 644 $(ANALOG_BUILD_DIR)/lang/* $(ANALOG_IPK_DIR)/opt/share/analog/lang
	install -m 755 $(ANALOG_BUILD_DIR)/analog $(ANALOG_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(ANALOG_IPK_DIR)/opt/bin/analog
	install -m 644 $(ANALOG_BUILD_DIR)/analog.cfg $(ANALOG_IPK_DIR)/opt/etc
	install -m 644 $(ANALOG_BUILD_DIR)/analog.cfg $(ANALOG_IPK_DIR)/opt/etc/analog.cfg-dist
	install -d $(ANALOG_IPK_DIR)/opt/share/doc/analog
	install -m 644 $(ANALOG_BUILD_DIR)/docs/* $(ANALOG_IPK_DIR)/opt/share/doc/analog
	install -d $(ANALOG_IPK_DIR)/opt/share/doc/analog/examples
	install -m 644 $(ANALOG_BUILD_DIR)/examples/*.cfg  $(ANALOG_IPK_DIR)/opt/share/doc/analog/examples
	install -m 644 $(ANALOG_BUILD_DIR)/anlgform.html $(ANALOG_IPK_DIR)/opt/share/doc/analog/examples
	install -m 644 $(ANALOG_BUILD_DIR)/anlgform.pl $(ANALOG_IPK_DIR)/opt/share/doc/analog/examples
	install -d $(ANALOG_IPK_DIR)/opt/share/doc/analog/examples/css
	install -m 644 $(ANALOG_BUILD_DIR)/examples/css/Readme.txt \
		$(ANALOG_IPK_DIR)/opt/share/doc/analog/examples/css/css
	install -m 644 $(ANALOG_BUILD_DIR)/examples/css/default.css \
		$(ANALOG_IPK_DIR)/opt/share/doc/analog/examples/css
	install -d $(ANALOG_IPK_DIR)/opt/share/doc/analog/examples/css/jreeves
	install -m 644 $(ANALOG_BUILD_DIR)/examples/css/jreeves/* \
		$(ANALOG_IPK_DIR)/opt/share/doc/analog/examples/css/jreeves
	install -d $(ANALOG_IPK_DIR)/opt/man/man1/
	install -m 644 $(ANALOG_BUILD_DIR)/analog.man $(ANALOG_IPK_DIR)/opt/man/man1/analog.1
#	install -d $(ANALOG_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ANALOG_SOURCE_DIR)/rc.analog $(ANALOG_IPK_DIR)/opt/etc/init.d/SXXanalog
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ANALOG_IPK_DIR)/opt/etc/init.d/SXXanalog
	$(MAKE) $(ANALOG_IPK_DIR)/CONTROL/control
#	install -m 755 $(ANALOG_SOURCE_DIR)/postinst $(ANALOG_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ANALOG_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ANALOG_SOURCE_DIR)/prerm $(ANALOG_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ANALOG_IPK_DIR)/CONTROL/prerm
	echo $(ANALOG_CONFFILES) | sed -e 's/ /\n/g' > $(ANALOG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ANALOG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
analog-ipk: $(ANALOG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
analog-clean:
	rm -f $(ANALOG_BUILD_DIR)/.built
	-$(MAKE) -C $(ANALOG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
analog-dirclean:
	rm -rf $(BUILD_DIR)/$(ANALOG_DIR) $(ANALOG_BUILD_DIR) $(ANALOG_IPK_DIR) $(ANALOG_IPK)
#
#
# Some sanity check for the package.
#
analog-check: $(ANALOG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ANALOG_IPK)
