###########################################################
#
# motor
#
###########################################################

# You must replace "motor" and "MOTOR" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MOTOR_VERSION, MOTOR_SITE and MOTOR_SOURCE define
# the upstream location of the source code for the package.
# MOTOR_DIR is the directory which is created when the source
# archive is unpacked.
# MOTOR_UNZIP is the command used to unzip the source.
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
MOTOR_SITE=http://konst.org.ua/download
MOTOR_VERSION=3.4.0
MOTOR_SOURCE=motor-$(MOTOR_VERSION).tar.gz
MOTOR_DIR=motor-$(MOTOR_VERSION)
MOTOR_UNZIP=zcat
MOTOR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MOTOR_DESCRIPTION=Integrated IDE that works in the console
MOTOR_SECTION=util
MOTOR_PRIORITY=optional
MOTOR_DEPENDS=ncurses
ifneq (,$(filter libiconv, $(PACKAGES)))
MOTOR_DEPENDS +=, libiconv
endif
MOTOR_SUGGESTS=
MOTOR_CONFLICTS=

#
# MOTOR_IPK_VERSION should be incremented when the ipk changes.
#
MOTOR_IPK_VERSION=1

#
# MOTOR_CONFFILES should be a list of user-editable files
#MOTOR_CONFFILES=/opt/etc/motor.conf /opt/etc/init.d/SXXmotor

#
# MOTOR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MOTOR_PATCHES=$(MOTOR_SOURCE_DIR)/share-Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MOTOR_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses -Wno-deprecated
MOTOR_LDFLAGS=

#
# MOTOR_BUILD_DIR is the directory in which the build is done.
# MOTOR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MOTOR_IPK_DIR is the directory in which the ipk is built.
# MOTOR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MOTOR_BUILD_DIR=$(BUILD_DIR)/motor
MOTOR_SOURCE_DIR=$(SOURCE_DIR)/motor
MOTOR_IPK_DIR=$(BUILD_DIR)/motor-$(MOTOR_VERSION)-ipk
MOTOR_IPK=$(BUILD_DIR)/motor_$(MOTOR_VERSION)-$(MOTOR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: motor-source motor-unpack motor motor-stage motor-ipk motor-clean motor-dirclean motor-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MOTOR_SOURCE):
	$(WGET) -P $(@D) $(MOTOR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
motor-source: $(DL_DIR)/$(MOTOR_SOURCE) $(MOTOR_PATCHES)

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
$(MOTOR_BUILD_DIR)/.configured: $(DL_DIR)/$(MOTOR_SOURCE) $(MOTOR_PATCHES) make/motor.mk
	$(MAKE) ncurses-stage
ifneq (,$(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(MOTOR_DIR) $(@D)
	$(MOTOR_UNZIP) $(DL_DIR)/$(MOTOR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MOTOR_PATCHES)" ; \
		then cat $(MOTOR_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MOTOR_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MOTOR_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MOTOR_DIR) $(@D) ; \
	fi
	find $(@D) -name Makefile.in | xargs sed -i -e '/^CPPFLAGS *=/s|$$| @CPPFLAGS@|'
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MOTOR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MOTOR_LDFLAGS)" \
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

motor-unpack: $(MOTOR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MOTOR_BUILD_DIR)/.built: $(MOTOR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
motor: $(MOTOR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MOTOR_BUILD_DIR)/.staged: $(MOTOR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

motor-stage: $(MOTOR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/motor
#
$(MOTOR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: motor" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MOTOR_PRIORITY)" >>$@
	@echo "Section: $(MOTOR_SECTION)" >>$@
	@echo "Version: $(MOTOR_VERSION)-$(MOTOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MOTOR_MAINTAINER)" >>$@
	@echo "Source: $(MOTOR_SITE)/$(MOTOR_SOURCE)" >>$@
	@echo "Description: $(MOTOR_DESCRIPTION)" >>$@
	@echo "Depends: $(MOTOR_DEPENDS)" >>$@
	@echo "Suggests: $(MOTOR_SUGGESTS)" >>$@
	@echo "Conflicts: $(MOTOR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MOTOR_IPK_DIR)/opt/sbin or $(MOTOR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MOTOR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MOTOR_IPK_DIR)/opt/etc/motor/...
# Documentation files should be installed in $(MOTOR_IPK_DIR)/opt/doc/motor/...
# Daemon startup scripts should be installed in $(MOTOR_IPK_DIR)/opt/etc/init.d/S??motor
#
# You may need to patch your application to make it use these locations.
#
$(MOTOR_IPK): $(MOTOR_BUILD_DIR)/.built
	rm -rf $(MOTOR_IPK_DIR) $(BUILD_DIR)/motor_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MOTOR_BUILD_DIR) DESTDIR=$(MOTOR_IPK_DIR) install
	$(STRIP_COMMAND) $(MOTOR_IPK_DIR)/opt/bin/motor
#	install -d $(MOTOR_IPK_DIR)/opt/etc/
#	install -m 644 $(MOTOR_SOURCE_DIR)/motor.conf $(MOTOR_IPK_DIR)/opt/etc/motor.conf
#	install -d $(MOTOR_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MOTOR_SOURCE_DIR)/rc.motor $(MOTOR_IPK_DIR)/opt/etc/init.d/SXXmotor
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOTOR_IPK_DIR)/opt/etc/init.d/SXXmotor
	$(MAKE) $(MOTOR_IPK_DIR)/CONTROL/control
#	install -m 755 $(MOTOR_SOURCE_DIR)/postinst $(MOTOR_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOTOR_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MOTOR_SOURCE_DIR)/prerm $(MOTOR_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOTOR_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MOTOR_IPK_DIR)/CONTROL/postinst $(MOTOR_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MOTOR_CONFFILES) | sed -e 's/ /\n/g' > $(MOTOR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MOTOR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
motor-ipk: $(MOTOR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
motor-clean:
	rm -f $(MOTOR_BUILD_DIR)/.built
	-$(MAKE) -C $(MOTOR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
motor-dirclean:
	rm -rf $(BUILD_DIR)/$(MOTOR_DIR) $(MOTOR_BUILD_DIR) $(MOTOR_IPK_DIR) $(MOTOR_IPK)
#
#
# Some sanity check for the package.
#
motor-check: $(MOTOR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
