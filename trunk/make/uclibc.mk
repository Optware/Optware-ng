##########################################################
#
# uclibc
#
###########################################################
#
# Provides uclibc only packaging for package buildroot
#

UCLIBC_VERSION ?= 0.9.28
UCLIBC_DESCRIPTION=micro C library for embedded Linux systems
UCLIBC_SECTION=base
UCLIBC_PRIORITY=required
UCLIBC_DEPENDS=
UCLIBC_SUGGESTS=
UCLIBC_CONFLICTS=buildroot

#
# UCLIBC_IPK_VERSION should be incremented when the ipk changes.
# Not necessarily the same as $(BUILDROOT_IPK_VERSION)
#
UCLIBC_IPK_VERSION=$(BUILDROOT_IPK_VERSION)

# UCLIBC_IPK_DIR is the directory in which the ipk is built.
# UCLIBC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UCLIBC_IPK_DIR=$(BUILD_DIR)/uclibc-$(UCLIBC_VERSION)-ipk
UCLIBC_IPK=$(BUILD_DIR)/uclibc_$(UCLIBC_VERSION)-$(UCLIBC_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# For building/cleaning targets see buildroot package
#

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/buildroot
#
$(UCLIBC_IPK_DIR)/CONTROL/control:
	@install -d $(UCLIBC_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: uclibc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UCLIBC_PRIORITY)" >>$@
	@echo "Section: $(UCLIBC_SECTION)" >>$@
	@echo "Version: $(UCLIBC_VERSION)-$(UCLIBC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUILDROOT_MAINTAINER)" >>$@
	@echo "Source: $(BUILDROOT_SITE)/$(BUILDROOT_SOURCE)" >>$@
	@echo "Description: $(UCLIBC_DESCRIPTION)" >>$@
	@echo "Depends: $(UCLIBC_DEPENDS)" >>$@
	@echo "Suggests: $(UCLIBC_SUGGESTS)" >>$@
	@echo "Conflicts: $(UCLIBC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UCLIBC_IPK_DIR)/opt/sbin or $(UCLIBC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UCLIBC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UCLIBC_IPK_DIR)/opt/etc/uclibc/...
# Documentation files should be installed in $(UCLIBC_IPK_DIR)/opt/doc/uclibc/...
# Daemon startup scripts should be installed in $(UCLIBC_IPK_DIR)/opt/etc/init.d/S??uclibc
#
# You may need to patch your application to make it use these locations.
#
UCLIBC_LIBS=ld-uClibc libc libdl libgcc_s libm libintl libnsl libpthread \
	libresolv  librt libutil libuClibc
UCLIBC_LIBS_PATTERN=$(patsubst %,\
	$(BUILDROOT_BUILD_DIR)/build_$(TARGET_ARCH)/root/opt/lib/%*so*,$(UCLIBC_LIBS))

$(UCLIBC_IPK): $(BUILDROOT_BUILD_DIR)/.built
	rm -rf $(UCLIBC_IPK_DIR) $(BUILD_DIR)/uclibc_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(BUILDROOT_BUILD_DIR) DESTDIR=$(UCLIBC_IPK_DIR) install-strip
	install -d $(UCLIBC_IPK_DIR)
#	tar -xv -C $(UCLIBC_IPK_DIR) -f $(BUILDROOT_BUILD_DIR)/rootfs.$(TARGET_ARCH).tar \
#		--wildcards $(UCLIBC_LIBS_PATTERN) ./opt/sbin/ldconfig
	install -d $(UCLIBC_IPK_DIR)/opt/lib
	cp -d $(UCLIBC_LIBS_PATTERN) $(UCLIBC_IPK_DIR)/opt/lib
	install -d $(UCLIBC_IPK_DIR)/opt/sbin
	install -m 755 $(BUILDROOT_BUILD_DIR)/build_$(TARGET_ARCH)/root/opt/sbin/ldconfig \
		$(UCLIBC_IPK_DIR)/opt/sbin
	$(MAKE) $(UCLIBC_IPK_DIR)/CONTROL/control
	install -m 755 $(BUILDROOT_SOURCE_DIR)/postinst $(UCLIBC_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(BUILDROOT_SOURCE_DIR)/prerm $(UCLIBC_IPK_DIR)/CONTROL/prerm
#	echo $(UCLIBC_CONFFILES) | sed -e 's/ /\n/g' > $(UCLIBC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UCLIBC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
uclibc-ipk: $(UCLIBC_IPK)
