###########################################################
#
# asterisk16-addons
#
###########################################################
#
# ASTERISK16_ADDONS_VERSION, ASTERISK16_ADDONS_SITE and ASTERISK16_ADDONS_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK16_ADDONS_DIR is the directory which is created when the source
# archive is unpacked.
# ASTERISK16_ADDONS_UNZIP is the command used to unzip the source.
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
ASTERISK16_ADDONS_SITE=http://downloads.digium.com/pub/asterisk
ASTERISK16_ADDONS_VERSION=1.6.0-beta2
ASTERISK16_ADDONS_SOURCE=asterisk-addons-$(ASTERISK16_ADDONS_VERSION).tar.gz
ASTERISK16_ADDONS_DIR=asterisk-addons-$(ASTERISK16_ADDONS_VERSION)
ASTERISK16_ADDONS_UNZIP=zcat
ASTERISK16_ADDONS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ASTERISK16_ADDONS_DESCRIPTION=Describe asterisk16-addons here.
ASTERISK16_ADDONS_SECTION=voip
ASTERISK16_ADDONS_PRIORITY=optional
ASTERISK16_ADDONS_DEPENDS=mysql
ASTERISK16_ADDONS_SUGGESTS=
ASTERISK16_ADDONS_CONFLICTS=

#
# ASTERISK16_ADDONS_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK16_ADDONS_IPK_VERSION=1

#
# ASTERISK16_ADDONS_CONFFILES should be a list of user-editable files
ASTERISK16_ADDONS_CONFFILES=\
/opt/etc/asterisk/mobile.conf \
/opt/etc/asterisk/res_mysql.conf \
/opt/etc/asterisk/ooh323.conf \
/opt/etc/asterisk/cdr_mysql.conf

#
# ASTERISK16_ADDONS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ASTERISK16_ADDONS_PATCHES=$(ASTERISK16_ADDONS_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASTERISK16_ADDONS_CPPFLAGS=-fsigned-char -I$(STAGING_INCLUDE_DIR)
ASTERISK16_ADDONS_LDFLAGS=

#
# ASTERISK16_ADDONS_BUILD_DIR is the directory in which the build is done.
# ASTERISK16_ADDONS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASTERISK16_ADDONS_IPK_DIR is the directory in which the ipk is built.
# ASTERISK16_ADDONS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK16_ADDONS_BUILD_DIR=$(BUILD_DIR)/asterisk16-addons
ASTERISK16_ADDONS_SOURCE_DIR=$(SOURCE_DIR)/asterisk16-addons
ASTERISK16_ADDONS_IPK_DIR=$(BUILD_DIR)/asterisk16-addons-$(ASTERISK16_ADDONS_VERSION)-ipk
ASTERISK16_ADDONS_IPK=$(BUILD_DIR)/asterisk16-addons_$(ASTERISK16_ADDONS_VERSION)-$(ASTERISK16_ADDONS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: asterisk16-addons-source asterisk16-addons-unpack asterisk16-addons asterisk16-addons-stage asterisk16-addons-ipk asterisk16-addons-clean asterisk16-addons-dirclean asterisk16-addons-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASTERISK16_ADDONS_SOURCE):
	$(WGET) -P $(DL_DIR) $(ASTERISK16_ADDONS_SITE)/$(ASTERISK16_ADDONS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
asterisk16-addons-source: $(DL_DIR)/$(ASTERISK16_ADDONS_SOURCE) $(ASTERISK16_ADDONS_PATCHES)

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
$(ASTERISK16_ADDONS_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK16_ADDONS_SOURCE) $(ASTERISK16_ADDONS_PATCHES) make/asterisk16-addons.mk
	$(MAKE) asterisk16-stage sqlite-stage mysql-stage
	rm -rf $(BUILD_DIR)/$(ASTERISK16_ADDONS_DIR) $(ASTERISK16_ADDONS_BUILD_DIR)
	$(ASTERISK16_ADDONS_UNZIP) $(DL_DIR)/$(ASTERISK16_ADDONS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASTERISK16_ADDONS_PATCHES)" ; \
		then cat $(ASTERISK16_ADDONS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ASTERISK16_ADDONS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK16_ADDONS_DIR)" != "$(ASTERISK16_ADDONS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK16_ADDONS_DIR) $(ASTERISK16_ADDONS_BUILD_DIR) ; \
	fi
	#(cd $(ASTERISK16_BUILD_DIR)/menuselect; \
	#	./configure \
	#)
	#$(MAKE) -C $(ASTERISK16_ADDONS_BUILD_DIR)/menuselect
	(cd $(ASTERISK16_ADDONS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK16_ADDONS_CPPFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK16_ADDONS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK16_ADDONS_LDFLAGS)" \
		PATH="$(STAGING_PREFIX)/bin:$(PATH)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--includedir=$(STAGING_PREFIX) \
		--with-sqlite=$(STAGING_PREFIX) \
		--localstatedir=/opt/var \
		--sysconfdir=/opt/etc \
	)
	touch $(ASTERISK16_ADDONS_BUILD_DIR)/.configured

asterisk16-addons-unpack: $(ASTERISK16_ADDONS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK16_ADDONS_BUILD_DIR)/.built: $(ASTERISK16_ADDONS_BUILD_DIR)/.configured
	rm -f $(ASTERISK16_ADDONS_BUILD_DIR)/.built
	$(MAKE) -C $(ASTERISK16_ADDONS_BUILD_DIR)/menuselect
	ASTCFLAGS="$(ASTERISK16_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK16_LDFLAGS)" \
	CFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK16_ADDONS_CPPFLAGS)" \
	$(MAKE) -C $(ASTERISK16_ADDONS_BUILD_DIR)
	touch $(ASTERISK16_ADDONS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
asterisk16-addons: $(ASTERISK16_ADDONS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK16_ADDONS_BUILD_DIR)/.staged: $(ASTERISK16_ADDONS_BUILD_DIR)/.built
	rm -f $(ASTERISK16_ADDONS_BUILD_DIR)/.staged
	ASTCFLAGS="$(ASTERISK16_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK16_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK16_ADDONS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ASTERISK16_ADDONS_BUILD_DIR)/.staged

asterisk16-addons-stage: $(ASTERISK16_ADDONS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk16-addons
#
$(ASTERISK16_ADDONS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: asterisk16-addons" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASTERISK16_ADDONS_PRIORITY)" >>$@
	@echo "Section: $(ASTERISK16_ADDONS_SECTION)" >>$@
	@echo "Version: $(ASTERISK16_ADDONS_VERSION)-$(ASTERISK16_ADDONS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASTERISK16_ADDONS_MAINTAINER)" >>$@
	@echo "Source: $(ASTERISK16_ADDONS_SITE)/$(ASTERISK16_ADDONS_SOURCE)" >>$@
	@echo "Description: $(ASTERISK16_ADDONS_DESCRIPTION)" >>$@
	@echo "Depends: $(ASTERISK16_ADDONS_DEPENDS)" >>$@
	@echo "Suggests: $(ASTERISK16_ADDONS_SUGGESTS)" >>$@
	@echo "Conflicts: $(ASTERISK16_ADDONS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK16_ADDONS_IPK_DIR)/opt/sbin or $(ASTERISK16_ADDONS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK16_ADDONS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ASTERISK16_ADDONS_IPK_DIR)/opt/etc/asterisk16-addons/...
# Documentation files should be installed in $(ASTERISK16_ADDONS_IPK_DIR)/opt/doc/asterisk16-addons/...
# Daemon startup scripts should be installed in $(ASTERISK16_ADDONS_IPK_DIR)/opt/etc/init.d/S??asterisk16-addons
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK16_ADDONS_IPK): $(ASTERISK16_ADDONS_BUILD_DIR)/.built
	rm -rf $(ASTERISK16_ADDONS_IPK_DIR) $(BUILD_DIR)/asterisk16-addons_*_$(TARGET_ARCH).ipk
	ASTCFLAGS="$(ASTERISK16_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK16_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK16_ADDONS_BUILD_DIR) DESTDIR=$(ASTERISK16_ADDONS_IPK_DIR) install
	ASTCFLAGS="$(ASTERISK16_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK16_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK16_ADDONS_BUILD_DIR) DESTDIR=$(ASTERISK16_ADDONS_IPK_DIR) samples

	$(MAKE) $(ASTERISK16_ADDONS_IPK_DIR)/CONTROL/control

	echo $(ASTERISK16_ADDONS_CONFFILES) | sed -e 's/ /\n/g' > $(ASTERISK16_ADDONS_IPK_DIR)/CONTROL/conffiles

	for filetostrip in $(ASTERISK16_ADDONS_IPK_DIR)/opt/lib/asterisk/modules/*.so ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done

	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK16_ADDONS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk16-addons-ipk: $(ASTERISK16_ADDONS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk16-addons-clean:
	rm -f $(ASTERISK16_ADDONS_BUILD_DIR)/.built
	-$(MAKE) -C $(ASTERISK16_ADDONS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk16-addons-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK16_ADDONS_DIR) $(ASTERISK16_ADDONS_BUILD_DIR) $(ASTERISK16_ADDONS_IPK_DIR) $(ASTERISK16_ADDONS_IPK)
#
#
# Some sanity check for the package.
#
asterisk16-addons-check: $(ASTERISK16_ADDONS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ASTERISK16_ADDONS_IPK)
