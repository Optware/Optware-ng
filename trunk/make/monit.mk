###########################################################
#
# monit
#
###########################################################

MONIT_SITE=http://www.tildeslash.com/monit/dist/
MONIT_VERSION=4.9
MONIT_SOURCE=monit-$(MONIT_VERSION).tar.gz
MONIT_DIR=monit-$(MONIT_VERSION)
MONIT_UNZIP=zcat
MONIT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MONIT_DESCRIPTION=monit is a utility for managing and monitoring, processes, files, directories and devices on a UNIX system. monit conducts automatic maintenance and repair and can execute meaningful causal actions in error situations.
MONIT_SECTION=misc
MONIT_PRIORITY=optional
MONIT_DEPENDS=openssl
MONIT_SUGGESTS=
MONIT_CONFLICTS=

#
# MONIT_IPK_VERSION should be incremented when the ipk changes.
#
MONIT_IPK_VERSION=1

#
# MONIT_CONFFILES should be a list of user-editable files
MONIT_CONFFILES=/opt/etc/monitrc /opt/etc/init.d/S99monit

#
# MONIT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MONIT_PATCHES=\
  $(MONIT_SOURCE_DIR)/Makefile.patch \
#  $(MONIT_SOURCE_DIR)/configure.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MONIT_CPPFLAGS=
MONIT_LDFLAGS=

#
# MONIT_BUILD_DIR is the directory in which the build is done.
# MONIT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MONIT_IPK_DIR is the directory in which the ipk is built.
# MONIT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MONIT_BUILD_DIR=$(BUILD_DIR)/monit
MONIT_SOURCE_DIR=$(SOURCE_DIR)/monit
MONIT_IPK_DIR=$(BUILD_DIR)/monit-$(MONIT_VERSION)-ipk
MONIT_IPK=$(BUILD_DIR)/monit_$(MONIT_VERSION)-$(MONIT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: monit-source monit-unpack monit monit-stage monit-ipk monit-clean monit-dirclean monit-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MONIT_SOURCE):
	$(WGET) -P $(DL_DIR) $(MONIT_SITE)/$(MONIT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
monit-source: $(DL_DIR)/$(MONIT_SOURCE) $(MONIT_PATCHES)

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
$(MONIT_BUILD_DIR)/.configured: $(DL_DIR)/$(MONIT_SOURCE) $(MONIT_PATCHES)
	$(MAKE) openssl-stage 
	rm -rf $(BUILD_DIR)/$(MONIT_DIR) $(MONIT_BUILD_DIR)
	$(MONIT_UNZIP) $(DL_DIR)/$(MONIT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MONIT_PATCHES)" ; \
		then cat $(MONIT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MONIT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MONIT_DIR)" != "$(MONIT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MONIT_DIR) $(MONIT_BUILD_DIR) ; \
	fi
	(cd $(MONIT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MONIT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MONIT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-ssl-incl-dir=$(STAGING_PREFIX)/include \
		--with-ssl-lib-dir=$(STAGING_PREFIX)/lib \
	)
	touch $(MONIT_BUILD_DIR)/.configured

monit-unpack: $(MONIT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MONIT_BUILD_DIR)/.built: $(MONIT_BUILD_DIR)/.configured
	rm -f $(MONIT_BUILD_DIR)/.built
	$(MAKE) -C $(MONIT_BUILD_DIR)
	touch $(MONIT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
monit: $(MONIT_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/monit
#
$(MONIT_IPK_DIR)/CONTROL/control:
	@install -d $(MONIT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: monit" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MONIT_PRIORITY)" >>$@
	@echo "Section: $(MONIT_SECTION)" >>$@
	@echo "Version: $(MONIT_VERSION)-$(MONIT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MONIT_MAINTAINER)" >>$@
	@echo "Source: $(MONIT_SITE)/$(MONIT_SOURCE)" >>$@
	@echo "Description: $(MONIT_DESCRIPTION)" >>$@
	@echo "Depends: $(MONIT_DEPENDS)" >>$@
	@echo "Suggests: $(MONIT_SUGGESTS)" >>$@
	@echo "Conflicts: $(MONIT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
$(MONIT_IPK): $(MONIT_BUILD_DIR)/.built
	rm -rf $(MONIT_IPK_DIR) $(BUILD_DIR)/monit_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MONIT_BUILD_DIR) DESTDIR=$(MONIT_IPK_DIR) install
	chmod 755 $(MONIT_IPK_DIR)/opt/bin/monit
	$(STRIP_COMMAND) $(MONIT_IPK_DIR)/opt/bin/monit
	rm -rf $(MONIT_IPK_DIR)/opt/man
	install -d $(MONIT_IPK_DIR)/opt/etc/
	install -d $(MONIT_IPK_DIR)/opt/var/run
	install -d $(MONIT_IPK_DIR)/opt/etc/init.d
	install -m 700 $(MONIT_BUILD_DIR)/monitrc $(MONIT_IPK_DIR)/opt/etc/monitrc
	install -m 755 $(MONIT_SOURCE_DIR)/rc.monit $(MONIT_IPK_DIR)/opt/etc/init.d/S99monit
	$(MAKE) $(MONIT_IPK_DIR)/CONTROL/control
	install -m 755 $(MONIT_SOURCE_DIR)/postinst $(MONIT_IPK_DIR)/CONTROL/postinst
	install -m 755 $(MONIT_SOURCE_DIR)/prerm $(MONIT_IPK_DIR)/CONTROL/prerm
	echo $(MONIT_CONFFILES) | sed -e 's/ /\n/g' > $(MONIT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MONIT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
monit-ipk: $(MONIT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
monit-clean:
	rm -f $(MONIT_BUILD_DIR)/.built
	-$(MAKE) -C $(MONIT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
monit-dirclean:
	rm -rf $(BUILD_DIR)/$(MONIT_DIR) $(MONIT_BUILD_DIR) $(MONIT_IPK_DIR) $(MONIT_IPK)

#
# Some sanity check for the package.
#
monit-check: $(MONIT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MONIT_IPK)
