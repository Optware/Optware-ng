###########################################################
#
# hping
#
###########################################################
#
# HPING_VERSION, HPING_SITE and HPING_SOURCE define
# the upstream location of the source code for the package.
# HPING_DIR is the directory which is created when the source
# archive is unpacked.
# HPING_UNZIP is the command used to unzip the source.
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
HPING_SITE=http://www.hping.org
HPING_VERSION=20051105
HPING_SOURCE=hping3-$(HPING_VERSION).tar.gz
HPING_DIR=hping3-$(HPING_VERSION)
HPING_UNZIP=zcat
HPING_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HPING_DESCRIPTION=A command-line oriented TCP/IP packet assembler/analyzer.
HPING_SECTION=net
HPING_PRIORITY=optional
HPING_DEPENDS=
HPING_SUGGESTS=
HPING_CONFLICTS=

#
# HPING_IPK_VERSION should be incremented when the ipk changes.
#
HPING_IPK_VERSION=1

#
# HPING_CONFFILES should be a list of user-editable files
#HPING_CONFFILES=/opt/etc/hping.conf /opt/etc/init.d/SXXhping

#
# HPING_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#HPING_PATCHES=$(HPING_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HPING_CPPFLAGS=
HPING_LDFLAGS=

#
# HPING_BUILD_DIR is the directory in which the build is done.
# HPING_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HPING_IPK_DIR is the directory in which the ipk is built.
# HPING_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HPING_BUILD_DIR=$(BUILD_DIR)/hping
HPING_SOURCE_DIR=$(SOURCE_DIR)/hping
HPING_IPK_DIR=$(BUILD_DIR)/hping-$(HPING_VERSION)-ipk
HPING_IPK=$(BUILD_DIR)/hping_$(HPING_VERSION)-$(HPING_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: hping-source hping-unpack hping hping-stage hping-ipk hping-clean hping-dirclean hping-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HPING_SOURCE):
	$(WGET) -P $(DL_DIR) $(HPING_SITE)/$(HPING_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hping-source: $(DL_DIR)/$(HPING_SOURCE) $(HPING_PATCHES)

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
$(HPING_BUILD_DIR)/.configured: $(DL_DIR)/$(HPING_SOURCE) $(HPING_PATCHES) make/hping.mk
	$(MAKE) libpcap-stage
	rm -rf $(BUILD_DIR)/$(HPING_DIR) $(HPING_BUILD_DIR)
	$(HPING_UNZIP) $(DL_DIR)/$(HPING_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HPING_PATCHES)" ; \
		then cat $(HPING_PATCHES) | \
		patch -d $(BUILD_DIR)/$(HPING_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HPING_DIR)" != "$(HPING_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(HPING_DIR) $(HPING_BUILD_DIR) ; \
	fi
	cd $(HPING_BUILD_DIR); \
        sed -i \
        	-e 's|-L/usr/local/lib|$(STAGING_LDFLAGS)|' \
        	-e 's|/usr/sbin|$(HPING_IPK_DIR)/opt/sbin|g' \
        	-e '/ln -s/d' \
        	Makefile.in; \
	sed -ie '/# error/s|^.*$$|#define BYTE_ORDER_BIG_ENDIAN|' bytesex.h; \
	sed -ie 's|<net/bpf.h>|<pcap-bpf.h>|' libpcap_stuff.c script.c;
	(cd $(HPING_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HPING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HPING_LDFLAGS)" \
		PCAP_INCLUDE=$(STAGING_INCLUDE_DIR) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--no-tcl \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(HPING_BUILD_DIR)/libtool
	touch $@

hping-unpack: $(HPING_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HPING_BUILD_DIR)/.built: $(HPING_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(HPING_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HPING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HPING_LDFLAGS)" \
                CCOPT="$(STAGING_CPPFLAGS) $(HPING_CPPFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
hping: $(HPING_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HPING_BUILD_DIR)/.staged: $(HPING_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(HPING_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

hping-stage: $(HPING_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hping
#
$(HPING_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: hping" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HPING_PRIORITY)" >>$@
	@echo "Section: $(HPING_SECTION)" >>$@
	@echo "Version: $(HPING_VERSION)-$(HPING_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HPING_MAINTAINER)" >>$@
	@echo "Source: $(HPING_SITE)/$(HPING_SOURCE)" >>$@
	@echo "Description: $(HPING_DESCRIPTION)" >>$@
	@echo "Depends: $(HPING_DEPENDS)" >>$@
	@echo "Suggests: $(HPING_SUGGESTS)" >>$@
	@echo "Conflicts: $(HPING_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HPING_IPK_DIR)/opt/sbin or $(HPING_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HPING_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HPING_IPK_DIR)/opt/etc/hping/...
# Documentation files should be installed in $(HPING_IPK_DIR)/opt/doc/hping/...
# Daemon startup scripts should be installed in $(HPING_IPK_DIR)/opt/etc/init.d/S??hping
#
# You may need to patch your application to make it use these locations.
#
$(HPING_IPK): $(HPING_BUILD_DIR)/.built
	rm -rf $(HPING_IPK_DIR) $(BUILD_DIR)/hping_*_$(TARGET_ARCH).ipk
	install -d $(HPING_IPK_DIR)/opt/share/man/man8
	install -d $(HPING_IPK_DIR)/opt/sbin
	$(MAKE) -C $(HPING_BUILD_DIR) \
        	DESTDIR=$(HPING_IPK_DIR) \
        	INSTALL_MANPATH=$(HPING_IPK_DIR)/opt/share/man \
        	install
	$(STRIP_COMMAND) $(HPING_IPK_DIR)/opt/sbin/hping3
	cd $(HPING_IPK_DIR)/opt/sbin; \
        	ln -s hping3 hping; \
        	ln -s hping3 hping2;
#	install -d $(HPING_IPK_DIR)/opt/etc/
#	install -m 644 $(HPING_SOURCE_DIR)/hping.conf $(HPING_IPK_DIR)/opt/etc/hping.conf
#	install -d $(HPING_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(HPING_SOURCE_DIR)/rc.hping $(HPING_IPK_DIR)/opt/etc/init.d/SXXhping
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXhping
	$(MAKE) $(HPING_IPK_DIR)/CONTROL/control
#	install -m 755 $(HPING_SOURCE_DIR)/postinst $(HPING_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(HPING_SOURCE_DIR)/prerm $(HPING_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
#	echo $(HPING_CONFFILES) | sed -e 's/ /\n/g' > $(HPING_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HPING_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
hping-ipk: $(HPING_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hping-clean:
	rm -f $(HPING_BUILD_DIR)/.built
	-$(MAKE) -C $(HPING_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hping-dirclean:
	rm -rf $(BUILD_DIR)/$(HPING_DIR) $(HPING_BUILD_DIR) $(HPING_IPK_DIR) $(HPING_IPK)
#
#
# Some sanity check for the package.
#
hping-check: $(HPING_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(HPING_IPK)
