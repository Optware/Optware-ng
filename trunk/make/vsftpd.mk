###########################################################
#
# vsftpd
#
###########################################################

# You must replace "vsftpd" and "VSFTPD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# VSFTPD_VERSION, VSFTPD_SITE and VSFTPD_SOURCE define
# the upstream location of the source code for the package.
# VSFTPD_DIR is the directory which is created when the source
# archive is unpacked.
# VSFTPD_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
VSFTPD_SITE=ftp://vsftpd.beasts.org/users/cevans
VSFTPD_VERSION=2.0.6
VSFTPD_SOURCE=vsftpd-$(VSFTPD_VERSION).tar.gz
VSFTPD_DIR=vsftpd-$(VSFTPD_VERSION)
VSFTPD_UNZIP=zcat

#
# VSFTPD_IPK_VERSION should be incremented when the ipk changes.
#
VSFTPD_IPK_VERSION=1


# VSFTPD_CONFFILES should be a list of user-editable files
VSFTPD_CONFFILES=/opt/etc/vsftpd.conf

#
# VSFTPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
VSFTPD_PATCHES=$(VSFTPD_SOURCE_DIR)/uclibc-prctl.patch $(VSFTPD_SOURCE_DIR)/syscall.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
VSFTPD_CPPFLAGS=
VSFTPD_LDFLAGS=

#
# VSFTPD_BUILD_DIR is the directory in which the build is done.
# VSFTPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# VSFTPD_IPK_DIR is the directory in which the ipk is built.
# VSFTPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
VSFTPD_BUILD_DIR=$(BUILD_DIR)/vsftpd
VSFTPD_SOURCE_DIR=$(SOURCE_DIR)/vsftpd
VSFTPD_IPK_DIR=$(BUILD_DIR)/vsftpd-$(VSFTPD_VERSION)-ipk
VSFTPD_IPK=$(BUILD_DIR)/vsftpd_$(VSFTPD_VERSION)-$(VSFTPD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: vsftpd-source vsftpd-unpack vsftpd vsftpd-stage vsftpd-ipk vsftpd-clean vsftpd-dirclean vsftpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(VSFTPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(VSFTPD_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)
#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
vsftpd-source: $(DL_DIR)/$(VSFTPD_SOURCE) $(VSFTPD_PATCHES)

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
$(VSFTPD_BUILD_DIR)/.configured: $(DL_DIR)/$(VSFTPD_SOURCE) $(VSFTPD_PATCHES)
#	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(VSFTPD_DIR) $(VSFTPD_BUILD_DIR)
	$(VSFTPD_UNZIP) $(DL_DIR)/$(VSFTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(VSFTPD_PATCHES) | patch -d $(BUILD_DIR)/$(VSFTPD_DIR) -p1
	mv $(BUILD_DIR)/$(VSFTPD_DIR) $(VSFTPD_BUILD_DIR)
ifeq ($(OPTWARE_TARGET), $(filter slugosbe slugosle, $(OPTWARE_TARGET)))
	sed -i -e '/pam_start/s/.*/if false; then/' $(@D)/vsf_findlibs.sh
	sed -i -e '/VSF_BUILD_PAM/s/#define/#undef/' $(@D)/builddefs.h
endif
#	(cd $(VSFTPD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(VSFTPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(VSFTPD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $@

vsftpd-unpack: $(VSFTPD_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(VSFTPD_BUILD_DIR)/.built: $(VSFTPD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(VSFTPD_BUILD_DIR) $(TARGET_CONFIGURE_OPTS) LIBS="$(STAGING_LDFLAGS) -lcrypt"
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
vsftpd: $(VSFTPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(VSFTPD_BUILD_DIR)/.staged: $(VSFTPD_BUILD_DIR)/.built
#	install -d $(STAGING_DIR)/opt/include
#	install -m 644 $(VSFTPD_BUILD_DIR)/vsftpd.h $(STAGING_DIR)/opt/include
#	install -d $(STAGING_DIR)/opt/lib
#	install -m 644 $(VSFTPD_BUILD_DIR)/libvsftpd.a $(STAGING_DIR)/opt/lib
#	install -m 644 $(VSFTPD_BUILD_DIR)/libvsftpd.so.$(VSFTPD_VERSION) $(STAGING_DIR)/opt/lib
#	cd $(STAGING_DIR)/opt/lib && ln -fs libvsftpd.so.$(VSFTPD_VERSION) libvsftpd.so.1
#	cd $(STAGING_DIR)/opt/lib && ln -fs libvsftpd.so.$(VSFTPD_VERSION) libvsftpd.so

vsftpd-stage: $(VSFTPD_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(VSFTPD_IPK_DIR)/opt/sbin or $(VSFTPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(VSFTPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(VSFTPD_IPK_DIR)/opt/etc/vsftpd/...
# Documentation files should be installed in $(VSFTPD_IPK_DIR)/opt/doc/vsftpd/...
# Daemon startup scripts should be installed in $(VSFTPD_IPK_DIR)/opt/etc/init.d/S??vsftpd
#
# You may need to patch your application to make it use these locations.
#
$(VSFTPD_IPK): $(VSFTPD_BUILD_DIR)/.built
	rm -rf $(VSFTPD_IPK_DIR) $(BUILD_DIR)/vsftpd_*_$(TARGET_ARCH).ipk
	install -d $(VSFTPD_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(VSFTPD_BUILD_DIR)/vsftpd -o $(VSFTPD_IPK_DIR)/opt/sbin/vsftpd
	install -d $(VSFTPD_IPK_DIR)/opt/etc
	install -m 644 $(VSFTPD_SOURCE_DIR)/vsftpd.conf $(VSFTPD_IPK_DIR)/opt/etc/vsftpd.conf
	install -d $(VSFTPD_IPK_DIR)/CONTROL
	sed -e "s/@ARCH@/$(TARGET_ARCH)/" -e "s/@VERSION@/$(VSFTPD_VERSION)/" \
		-e "s/@RELEASE@/$(VSFTPD_IPK_VERSION)/" $(VSFTPD_SOURCE_DIR)/control > $(VSFTPD_IPK_DIR)/CONTROL/control
	install -m 644 $(VSFTPD_SOURCE_DIR)/postinst $(VSFTPD_IPK_DIR)/CONTROL/postinst
	echo $(VSFTPD_CONFFILES) | sed -e 's/ /\n/g' > $(VSFTPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(VSFTPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
vsftpd-ipk: $(VSFTPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
vsftpd-clean:
	-$(MAKE) -C $(VSFTPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
vsftpd-dirclean:
	rm -rf $(BUILD_DIR)/$(VSFTPD_DIR) $(VSFTPD_BUILD_DIR) $(VSFTPD_IPK_DIR) $(VSFTPD_IPK)

#
## Some sanity check for the package.
#
vsftpd-check: $(VSFTPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(VSFTPD_IPK)

