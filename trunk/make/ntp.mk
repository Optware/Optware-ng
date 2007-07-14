###########################################################
#
# ntp
#
###########################################################

# You must replace "ntp" and "NTP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NTP_VERSION, NTP_SITE and NTP_SOURCE define
# the upstream location of the source code for the package.
# NTP_DIR is the directory which is created when the source
# archive is unpacked.
# NTP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
NTP_SITE=http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2
NTP_VERSION=4.2.4p3
NTP_SOURCE=ntp-$(NTP_VERSION).tar.gz
NTP_DIR=ntp-$(NTP_VERSION)
NTP_UNZIP=zcat
NTP_MAINTAINER=Christopher <edmondsc@onid.ors.edu>
NTP_DESCRIPTION=A time synchronization daemon
NTP_SECTION=net
NTP_PRIORITY=optional
NTP_DEPENDS=
NTP_SUGGESTS=
NTP_CONFLICTS=


#
# NTP_IPK_VERSION should be incremented when the ipk changes.
#
NTP_IPK_VERSION=2

NTP_CONFFILES=/opt/etc/ntp/ntp.conf /opt/etc/init.d/S77ntp

#
# NTP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NTP_PATCHES=$(NTP_SOURCE_DIR)/ntpdc-Makefile.in.patch $(NTP_SOURCE_DIR)/ntpd-ifupdate2.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NTP_CPPFLAGS=
NTP_LDFLAGS=

#
# NTP_BUILD_DIR is the directory in which the build is done.
# NTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NTP_IPK_DIR is the directory in which the ipk is built.
# NTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NTP_BUILD_DIR=$(BUILD_DIR)/ntp
NTP_SOURCE_DIR=$(SOURCE_DIR)/ntp
NTP_IPK_DIR=$(BUILD_DIR)/ntp-$(NTP_VERSION)-ipk
NTP_IPK=$(BUILD_DIR)/ntp_$(NTP_VERSION)-$(NTP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ntp-source ntp-unpack ntp ntp-stage ntp-ipk ntp-clean ntp-dirclean ntp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NTP_SOURCE):
	$(WGET) -P $(DL_DIR) $(NTP_SITE)/$(NTP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ntp-source: $(DL_DIR)/$(NTP_SOURCE) $(NTP_PATCHES)

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
$(NTP_BUILD_DIR)/.configured: $(DL_DIR)/$(NTP_SOURCE) $(NTP_PATCHES)
	rm -rf $(BUILD_DIR)/$(NTP_DIR) $(NTP_BUILD_DIR)
	$(NTP_UNZIP) $(DL_DIR)/$(NTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(NTP_PATCHES) | patch -d $(BUILD_DIR)/$(NTP_DIR) -p1
	mv $(BUILD_DIR)/$(NTP_DIR) $(NTP_BUILD_DIR)
	(cd $(NTP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		STRIP="$(STRIP_COMMAND)" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NTP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NTP_LDFLAGS)" \
		./configure --without-crypto \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt\
	)
	touch $(NTP_BUILD_DIR)/.configured

ntp-unpack: $(NTP_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(NTP_BUILD_DIR)/ntpd/ntpd: $(NTP_BUILD_DIR)/.configured
	$(MAKE) -C $(NTP_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
ntp: $(NTP_BUILD_DIR)/ntpd/ntpd

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ntp
#
$(NTP_IPK_DIR)/CONTROL/control:
	@install -d $(NTP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ntp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NTP_PRIORITY)" >>$@
	@echo "Section: $(NTP_SECTION)" >>$@
	@echo "Version: $(NTP_VERSION)-$(NTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NTP_MAINTAINER)" >>$@
	@echo "Source: $(NTP_SITE)/$(NTP_SOURCE)" >>$@
	@echo "Description: $(NTP_DESCRIPTION)" >>$@
	@echo "Depends: $(NTP_DEPENDS)" >>$@
	@echo "Suggests: $(NTP_SUGGESTS)" >>$@
	@echo "Conflicts: $(NTP_CONFLICTS)" >>$@


#
# This builds the IPK file.
#
# Binaries should be installed into $(NTP_IPK_DIR)/opt/sbin or $(NTP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NTP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NTP_IPK_DIR)/opt/etc/ntp/...
# Documentation files should be installed in $(NTP_IPK_DIR)/opt/doc/ntp/...
# Daemon startup scripts should be installed in $(NTP_IPK_DIR)/opt/etc/init.d/S??ntp
#
# You may need to patch your application to make it use these locations.
#
$(NTP_IPK): $(NTP_BUILD_DIR)/ntpd/ntpd
	rm -rf $(NTP_IPK_DIR) $(NTP_IPK)
	install -d $(NTP_IPK_DIR)/opt/bin
	install -d $(NTP_IPK_DIR)/opt/etc/ntp/keys
	install -d $(NTP_IPK_DIR)/var/spool/ntp
	$(STRIP_COMMAND) $(NTP_BUILD_DIR)/ntpd/ntpd -o $(NTP_IPK_DIR)/opt/bin/ntpd
	$(STRIP_COMMAND) $(NTP_BUILD_DIR)/ntpq/ntpq -o $(NTP_IPK_DIR)/opt/bin/ntpq
	$(STRIP_COMMAND) $(NTP_BUILD_DIR)/ntpdc/ntpdc -o $(NTP_IPK_DIR)/opt/bin/ntpdc
	$(STRIP_COMMAND) $(NTP_BUILD_DIR)/util/ntptime -o $(NTP_IPK_DIR)/opt/bin/ntptime
	$(STRIP_COMMAND) $(NTP_BUILD_DIR)/util/tickadj -o $(NTP_IPK_DIR)/opt/bin/tickadj
	$(STRIP_COMMAND) $(NTP_BUILD_DIR)/ntpdate/ntpdate -o $(NTP_IPK_DIR)/opt/bin/ntpdate
	install -m 644 $(NTP_SOURCE_DIR)/ntp.conf $(NTP_IPK_DIR)/opt/etc/ntp/ntp.conf
	install -d $(NTP_IPK_DIR)/opt/etc/init.d
	install -m 755 $(NTP_SOURCE_DIR)/rc.ntpd $(NTP_IPK_DIR)/opt/etc/init.d/S77ntp
	$(MAKE) $(NTP_IPK_DIR)/CONTROL/control
	install -m 644 $(NTP_SOURCE_DIR)/postinst $(NTP_IPK_DIR)/CONTROL/postinst
	echo $(NTP_CONFFILES) | sed -e 's/ /\n/g' > $(NTP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ntp-ipk: $(NTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ntp-clean:
	-$(MAKE) -C $(NTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ntp-dirclean:
	rm -rf $(BUILD_DIR)/$(NTP_DIR) $(NTP_BUILD_DIR) $(NTP_IPK_DIR) $(NTP_IPK)

#
# Some sanity check for the package.
#
ntp-check: $(NTP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NTP_IPK)
