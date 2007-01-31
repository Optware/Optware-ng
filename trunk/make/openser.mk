###########################################################
#
# openser
#
###########################################################
#
# OPENSER_VERSION, OPENSER_SITE and OPENSER_SOURCE define
# the upstream location of the source code for the package.
# OPENSER_DIR is the directory which is created when the source
# archive is unpacked.
# OPENSER_UNZIP is the command used to unzip the source.
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
OPENSER_SITE=http://openser.org/pub/openser/1.1.1/src/
OPENSER_VERSION=1.1.1
OPENSER_SOURCE=openser-$(OPENSER_VERSION)-tls_src.tar.gz
OPENSER_DIR=openser-$(OPENSER_VERSION)
OPENSER_UNZIP=zcat
OPENSER_MAINTAINER=Ovidiu Sas <sip.nslu@gmail.com>
OPENSER_DESCRIPTION=openSIP Express Router
OPENSER_SECTION=util
OPENSER_PRIORITY=optional
OPENSER_DEPENDS=coreutils,flex,openssl
ifeq (mysql, $(filter mysql, $(PACKAGES)))
OPENSER_SUGGESTS=radiusclient-ng,libxml2,postgresql,mysql
else
OPENSER_SUGGESTS=radiusclient-ng,libxml2,postgresql
endif
OPENSER_CONFLICTS=

#
# OPENSER_IPK_VERSION should be incremented when the ipk changes.
#
OPENSER_IPK_VERSION=5

#
# OPENSER_CONFFILES should be a list of user-editable files
OPENSER_CONFFILES=/opt/etc/openser/openser.cfg /opt/etc/openser/openserctlrc

#
# OPENSER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
OPENSER_PATCHES=$(OPENSER_SOURCE_DIR)/openser-1.1.1.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OPENSER_CPPFLAGS=-fsigned-char

ifeq ($(TARGET_ARCH),mipsel)
OPENSER_MAKEFLAGS=ARCH=mips OS=linux OSREL=2.4.20
else
OPENSER_MAKEFLAGS=ARCH=arm OS=linux OSREL=2.4.22
endif

#
# Excluded modules:
# osp      - require "-losptk" or "-losp"
# unixodbc - no unixodbc in optware 
#
ifeq (mysql, $(filter mysql, $(PACKAGES)))
OPENSER_INCLUDE_MODULES=pa jabber auth_radius avp_radius group_radius uri_radius cpl-c postgres mysql
else
OPENSER_INCLUDE_MODULES=pa jabber auth_radius avp_radius group_radius uri_radius cpl-c postgres
endif

OPENSER_DEBUG_MODE=mode=debug

#
# OPENSER_BUILD_DIR is the directory in which the build is done.
# OPENSER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OPENSER_IPK_DIR is the directory in which the ipk is built.
# OPENSER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OPENSER_BUILD_DIR=$(BUILD_DIR)/openser
OPENSER_SOURCE_DIR=$(SOURCE_DIR)/openser
OPENSER_IPK_DIR=$(BUILD_DIR)/openser-$(OPENSER_VERSION)-ipk
OPENSER_IPK=$(BUILD_DIR)/openser_$(OPENSER_VERSION)-$(OPENSER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: openser-source openser-unpack openser openser-stage openser-ipk openser-clean openser-dirclean openser-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OPENSER_SOURCE):
	$(WGET) -P $(DL_DIR) $(OPENSER_SITE)/$(OPENSER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
openser-source: $(DL_DIR)/$(OPENSER_SOURCE) $(OPENSER_PATCHES)

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
$(OPENSER_BUILD_DIR)/.configured: $(DL_DIR)/$(OPENSER_SOURCE) $(OPENSER_PATCHES) make/openser.mk
	$(MAKE) flex-stage openssl-stage radiusclient-ng-stage libxml2-stage postgresql-stage
ifeq (mysql, $(filter mysql, $(PACKAGES)))
	$(MAKE) mysql-stage
endif
	rm -rf $(BUILD_DIR)/$(OPENSER_DIR) $(OPENSER_BUILD_DIR)
	$(OPENSER_UNZIP) $(DL_DIR)/$(OPENSER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(OPENSER_PATCHES)" ; \
		then cat $(OPENSER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(OPENSER_DIR)-tls -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(OPENSER_DIR)" != "$(OPENSER_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(OPENSER_DIR)-tls $(OPENSER_BUILD_DIR) ; \
	fi
	touch $(OPENSER_BUILD_DIR)/.configured

openser-unpack: $(OPENSER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OPENSER_BUILD_DIR)/.built: $(OPENSER_BUILD_DIR)/.configured
	rm -f $(OPENSER_BUILD_DIR)/.built
	CC_EXTRA_OPTS="$(OPENSER_CPPFLAGS) $(STAGING_CPPFLAGS)" \
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS)" \
	TLS=1 LOCALBASE=$(STAGING_DIR)/opt CC="$(TARGET_CC)" \
	$(MAKE) -C $(OPENSER_BUILD_DIR) $(OPENSER_MAKEFLAGS) $(OPENSER_DEBUG_MODE) \
	include_modules="$(OPENSER_INCLUDE_MODULES)" prefix=/opt all
	touch $(OPENSER_BUILD_DIR)/.built

#
# This is the build convenience target.
#
openser: $(OPENSER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OPENSER_BUILD_DIR)/.staged: $(OPENSER_BUILD_DIR)/.built
	rm -f $(OPENSER_BUILD_DIR)/.staged
	CC_EXTRA_OPTS="$(OPENSER_CPPFLAGS) $(STAGING_CPPFLAGS)" \
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS)" \
	TLS=1 LOCALBASE=$(STAGING_DIR)/opt CC="$(TARGET_CC)" \
	$(MAKE) -C $(OPENSER_BUILD_DIR) $(OPENSER_MAKEFLAGS) DESTDIR=$(STAGING_DIR) \
	prefix=$(STAGING_DIR)/opt cfg-prefix=$(STAGING_DIR)/opt $(OPENSER_DEBUG_MODE) \
	include_modules="$(OPENSER_INCLUDE_MODULES)" prefix=/opt modules
	CC_EXTRA_OPTS="$(OPENSER_CPPFLAGS) $(STAGING_CPPFLAGS)" \
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS)" \
	TLS=1 LOCALBASE=$(STAGING_DIR)/opt CC="$(TARGET_CC)" \
	$(MAKE) -C $(OPENSER_BUILD_DIR) $(OPENSER_MAKEFLAGS) DESTDIR=$(STAGING_DIR) \
	prefix=$(STAGING_DIR)/opt cfg-prefix=$(STAGING_DIR)/opt $(OPENSER_DEBUG_MODE) \
	include_modules="$(OPENSER_INCLUDE_MODULES)" prefix=/opt install
	touch $(OPENSER_BUILD_DIR)/.staged

openser-stage: $(OPENSER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/openser
#
$(OPENSER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: openser" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENSER_PRIORITY)" >>$@
	@echo "Section: $(OPENSER_SECTION)" >>$@
	@echo "Version: $(OPENSER_VERSION)-$(OPENSER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENSER_MAINTAINER)" >>$@
	@echo "Source: $(OPENSER_SITE)/$(OPENSER_SOURCE)" >>$@
	@echo "Description: $(OPENSER_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENSER_DEPENDS)" >>$@
	@echo "Suggests: $(OPENSER_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENSER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OPENSER_IPK_DIR)/opt/sbin or $(OPENSER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OPENSER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OPENSER_IPK_DIR)/opt/etc/openser/...
# Documentation files should be installed in $(OPENSER_IPK_DIR)/opt/doc/openser/...
# Daemon startup scripts should be installed in $(OPENSER_IPK_DIR)/opt/etc/init.d/S??openser
#
# You may need to patch your application to make it use these locations.
#
$(OPENSER_IPK): $(OPENSER_BUILD_DIR)/.built
	rm -rf $(OPENSER_IPK_DIR) $(BUILD_DIR)/openser_*_$(TARGET_ARCH).ipk
	CC_EXTRA_OPTS="$(OPENSER_CPPFLAGS) $(STAGING_CPPFLAGS)" \
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS)" \
	TLS=1 LOCALBASE=$(STAGING_DIR)/opt CC="$(TARGET_CC)" \
	$(MAKE) -C $(OPENSER_BUILD_DIR) $(OPENSER_MAKEFLAGS) DESTDIR=$(OPENSER_IPK_DIR) \
	prefix=$(OPENSER_IPK_DIR)/opt cfg-prefix=$(OPENSER_IPK_DIR)/opt $(OPENSER_DEBUG_MODE) \
	include_modules="$(OPENSER_INCLUDE_MODULES)" install-modules
	CC_EXTRA_OPTS="$(OPENSER_CPPFLAGS) $(STAGING_CPPFLAGS)" \
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS)" \
	TLS=1 LOCALBASE=$(STAGING_DIR)/opt CC="$(TARGET_CC)" \
	$(MAKE) -C $(OPENSER_BUILD_DIR) $(OPENSER_MAKEFLAGS) DESTDIR=$(OPENSER_IPK_DIR) \
	prefix=$(OPENSER_IPK_DIR)/opt cfg-prefix=$(OPENSER_IPK_DIR)/opt $(OPENSER_DEBUG_MODE) \
	include_modules="$(OPENSER_INCLUDE_MODULES)" install

	$(MAKE) $(OPENSER_IPK_DIR)/CONTROL/control
	echo $(OPENSER_CONFFILES) | sed -e 's/ /\n/g' > $(OPENSER_IPK_DIR)/CONTROL/conffiles

	for f in `find $(OPENSER_IPK_DIR)/opt/lib/openser/modules -name '*.so'`; do $(STRIP_COMMAND) $$f; done
	$(STRIP_COMMAND) $(OPENSER_IPK_DIR)/opt/sbin/openser
	$(STRIP_COMMAND) $(OPENSER_IPK_DIR)/opt/sbin/openserunix
	cp $(OPENSER_BUILD_DIR)/etc/openser.init $(OPENSER_IPK_DIR)/opt/etc/openser
	install -m 755 $(OPENSER_BUILD_DIR)/scripts/sc.dbtext $(OPENSER_IPK_DIR)/opt/sbin/openser_dbtext_ctl
	echo "DBTEXT_PATH=/opt/etc/openser/dbtext" > $(OPENSER_IPK_DIR)/opt/etc/openser/.openscdbtextrc
	sed -i -e 's#/usr/local#/opt#g' $(OPENSER_IPK_DIR)/opt/sbin/openser_dbtext_ctl
	sed -i -e 's#$(OPENSER_IPK_DIR)##g' $(OPENSER_IPK_DIR)/opt/sbin/openserctl
	sed -i -e 's#$(OPENSER_IPK_DIR)##g' -e 's#/usr/local#/opt#g' $(OPENSER_IPK_DIR)/opt/etc/openser/openser.cfg
	
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENSER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
openser-ipk: $(OPENSER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
openser-clean:
	rm -f $(OPENSER_BUILD_DIR)/.built
	-$(MAKE) -C $(OPENSER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
openser-dirclean:
	rm -rf $(BUILD_DIR)/$(OPENSER_DIR) $(OPENSER_BUILD_DIR) $(OPENSER_IPK_DIR) $(OPENSER_IPK)
#
#
# Some sanity check for the package.
#
openser-check: $(OPENSER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OPENSER_IPK)
