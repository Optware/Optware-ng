###########################################################
#
# collectd
#
###########################################################
#
# COLLECTD_VERSION, COLLECTD_SITE and COLLECTD_SOURCE define
# the upstream location of the source code for the package.
# COLLECTD_DIR is the directory which is created when the source
# archive is unpacked.
# COLLECTD_UNZIP is the command used to unzip the source.
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
COLLECTD_SITE=http://collectd.org/files
COLLECTD_VERSION=5.2.1
COLLECTD_SOURCE=collectd-$(COLLECTD_VERSION).tar.bz2
COLLECTD_DIR=collectd-$(COLLECTD_VERSION)
COLLECTD_UNZIP=bzcat
COLLECTD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
COLLECTD_DESCRIPTION=statistics collection and monitoring daemon
COLLECTD_SECTION=utils
COLLECTD_PRIORITY=optional
COLLECTD_DEPENDS=
COLLECTD_SUGGESTS=libcurl, libesmtp, libgcrypt, libpcap, libxml2, lm-sensors, mysql, net-snmp, perl, postgresql, python, rrdtool
COLLECTD_CONFLICTS=

#
# COLLECTD_IPK_VERSION should be incremented when the ipk changes.
#
COLLECTD_IPK_VERSION=1

#
# COLLECTD_CONFFILES should be a list of user-editable files
COLLECTD_CONFFILES=/opt/etc/collectd.conf /opt/etc/init.d/S70collectd

#
# COLLECTD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
COLLECTD_PATCHES=$(COLLECTD_SOURCE_DIR)/tcpconns.c.patch
#COLLECTD_PATCHES+=$(COLLECTD_SOURCE_DIR)/configure.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
COLLECTD_CPPFLAGS=-Wno-error
COLLECTD_LDFLAGS=

#
# COLLECTD_BUILD_DIR is the directory in which the build is done.
# COLLECTD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# COLLECTD_IPK_DIR is the directory in which the ipk is built.
# COLLECTD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
COLLECTD_BUILD_DIR=$(BUILD_DIR)/collectd
COLLECTD_SOURCE_DIR=$(SOURCE_DIR)/collectd
COLLECTD_IPK_DIR=$(BUILD_DIR)/collectd-$(COLLECTD_VERSION)-ipk
COLLECTD_IPK=$(BUILD_DIR)/collectd_$(COLLECTD_VERSION)-$(COLLECTD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: collectd-source collectd-unpack collectd collectd-stage collectd-ipk collectd-clean collectd-dirclean collectd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(COLLECTD_SOURCE):
	$(WGET) -P $(@D) $(COLLECTD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
collectd-source: $(DL_DIR)/$(COLLECTD_SOURCE) $(COLLECTD_PATCHES)

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
$(COLLECTD_BUILD_DIR)/.configured: $(DL_DIR)/$(COLLECTD_SOURCE) $(COLLECTD_PATCHES) make/collectd.mk
	$(MAKE) libcurl-stage libgcrypt-stage libxml2-stage
	$(MAKE) net-snmp-stage mysql-stage postgresql-stage
	$(MAKE) libesmtp-stage libpcap-stage 
	$(MAKE) lm-sensors-stage perl-stage python-stage rrdtool-stage
	rm -rf $(BUILD_DIR)/$(COLLECTD_DIR) $(@D)
	$(COLLECTD_UNZIP) $(DL_DIR)/$(COLLECTD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(COLLECTD_PATCHES)" ; \
		then cat $(COLLECTD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(COLLECTD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(COLLECTD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(COLLECTD_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/endianness.c | grep -q puts.*BIG_ENDIAN; \
		then WITH_FP_LAYOUT="--with-fp-layout=endianflip"; \
		else WITH_FP_LAYOUT="--with-fp-layout=nothing"; fi; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(COLLECTD_CPPFLAGS)" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(COLLECTD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(COLLECTD_LDFLAGS)" \
		PATH="$(STAGING_PREFIX)/bin:$$PATH" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-libgcrypt-prefix=$(STAGING_PREFIX) \
		--with-nan-emulation \
		$$WITH_FP_LAYOUT \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

collectd-unpack: $(COLLECTD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(COLLECTD_BUILD_DIR)/.built: $(COLLECTD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
collectd: $(COLLECTD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(COLLECTD_BUILD_DIR)/.staged: $(COLLECTD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

collectd-stage: $(COLLECTD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/collectd
#
$(COLLECTD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: collectd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(COLLECTD_PRIORITY)" >>$@
	@echo "Section: $(COLLECTD_SECTION)" >>$@
	@echo "Version: $(COLLECTD_VERSION)-$(COLLECTD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(COLLECTD_MAINTAINER)" >>$@
	@echo "Source: $(COLLECTD_SITE)/$(COLLECTD_SOURCE)" >>$@
	@echo "Description: $(COLLECTD_DESCRIPTION)" >>$@
	@echo "Depends: $(COLLECTD_DEPENDS)" >>$@
	@echo "Suggests: $(COLLECTD_SUGGESTS)" >>$@
	@echo "Conflicts: $(COLLECTD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(COLLECTD_IPK_DIR)/opt/sbin or $(COLLECTD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(COLLECTD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(COLLECTD_IPK_DIR)/opt/etc/collectd/...
# Documentation files should be installed in $(COLLECTD_IPK_DIR)/opt/doc/collectd/...
# Daemon startup scripts should be installed in $(COLLECTD_IPK_DIR)/opt/etc/init.d/S??collectd
#
# You may need to patch your application to make it use these locations.
#
$(COLLECTD_IPK): $(COLLECTD_BUILD_DIR)/.built
	rm -rf $(COLLECTD_IPK_DIR) $(BUILD_DIR)/collectd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(COLLECTD_BUILD_DIR) DESTDIR=$(COLLECTD_IPK_DIR) install-strip
	install -d $(COLLECTD_IPK_DIR)/opt/etc/
	install -m 644 $(COLLECTD_SOURCE_DIR)/collectd.conf $(COLLECTD_IPK_DIR)/opt/etc/collectd.conf
	install -d $(COLLECTD_IPK_DIR)/opt/etc/init.d
	install -m 755 $(COLLECTD_SOURCE_DIR)/rc.collectd $(COLLECTD_IPK_DIR)/opt/etc/init.d/S70collectd
	$(MAKE) $(COLLECTD_IPK_DIR)/CONTROL/control
	install -m 755 $(COLLECTD_SOURCE_DIR)/postinst $(COLLECTD_IPK_DIR)/CONTROL/postinst
	echo $(COLLECTD_CONFFILES) | sed -e 's/ /\n/g' > $(COLLECTD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(COLLECTD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(COLLECTD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
collectd-ipk: $(COLLECTD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
collectd-clean:
	rm -f $(COLLECTD_BUILD_DIR)/.built
	-$(MAKE) -C $(COLLECTD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
collectd-dirclean:
	rm -rf $(BUILD_DIR)/$(COLLECTD_DIR) $(COLLECTD_BUILD_DIR) $(COLLECTD_IPK_DIR) $(COLLECTD_IPK)
#
#
# Some sanity check for the package.
#
collectd-check: $(COLLECTD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
