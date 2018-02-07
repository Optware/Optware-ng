###########################################################
#
# busybox
#
###########################################################

# You must replace "busybox" and "BUSYBOX" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# BUSYBOX_VERSION, BUSYBOX_SITE and BUSYBOX_SOURCE define
# the upstream location of the source code for the package.
# BUSYBOX_DIR is the directory which is created when the source
# archive is unpacked.
# BUSYBOX_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
ifndef BUSYBOX_SITE
BUSYBOX_SITE=http://www.busybox.net/downloads
# If you change this version, you must check the adduser package as well.
BUSYBOX_VERSION=1.25.0
BUSYBOX_SOURCE=busybox-$(BUSYBOX_VERSION).tar.bz2
BUSYBOX_DIR=busybox-$(BUSYBOX_VERSION)
BUSYBOX_UNZIP=bzcat
BUSYBOX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BUSYBOX_DESCRIPTION=A userland replacement for embedded systems.
BUSYBOX_SECTION=core
BUSYBOX_PRIORITY=optional
ifeq (uclibc, $(LIBC_STYLE))
BUSYBOX_DEPENDS=librpc-uclibc
else
BUSYBOX_DEPENDS=
endif
BUSYBOX_CONFLICTS=

#
# BUSYBOX_IPK_VERSION should be incremented when the ipk changes.
#
BUSYBOX_IPK_VERSION=4

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BUSYBOX_CPPFLAGS=
BUSYBOX_LDFLAGS=
BUSYBOX_LDLIBS=
ifeq (uclibc, $(LIBC_STYLE))
BUSYBOX_CPPFLAGS += -D__UCLIBC_HAS_RPC__ -I$(STAGING_INCLUDE_DIR)/rpc-uclibc
BUSYBOX_LDLIBS += rpc-uclibc
endif

BUSYBOX_PATCHES=\
$(BUSYBOX_SOURCE_DIR)/nsenter.c.patch \

#
# USHARE_BUILD_DIR is the directory in which the build is done.
# USHARE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# USHARE_IPK_DIR is the directory in which the ipk is built.
# USHARE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BUSYBOX_BUILD_DIR=$(BUILD_DIR)/busybox
BUSYBOX_SOURCE_DIR=$(SOURCE_DIR)/busybox
BUSYBOX_IPK_DIR=$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)-ipk
BUSYBOX_IPK=$(BUILD_DIR)/busybox_$(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)_$(TARGET_ARCH).ipk
BUSYBOX-BASE_IPK=$(BUILD_DIR)/busybox-base_$(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)_$(TARGET_ARCH).ipk
BUSYBOX-LINKS_IPK=$(BUILD_DIR)/busybox-links_$(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: busybox-source busybox-unpack busybox busybox-stage busybox-ipk busybox-clean busybox-dirclean busybox-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BUSYBOX_SOURCE):
	$(WGET) -P $(@D) $(BUSYBOX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
busybox-source: $(DL_DIR)/$(BUSYBOX_SOURCE) $(BUSYBOX_PATCHES)

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
## first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(BUSYBOX_BUILD_DIR)/.configured: $(DL_DIR)/$(BUSYBOX_SOURCE) $(BUSYBOX_PATCHES) $(BUSYBOX_SOURCE_DIR)/defconfig make/busybox.mk
ifeq (uclibc, $(LIBC_STYLE))
	$(MAKE) librpc-uclibc-stage
endif
	rm -rf $(BUILD_DIR)/$(BUSYBOX_DIR) $(@D)
	$(BUSYBOX_UNZIP) $(DL_DIR)/$(BUSYBOX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BUSYBOX_PATCHES)" ; \
		then cat $(BUSYBOX_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(BUSYBOX_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(BUSYBOX_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(BUSYBOX_DIR) $(@D) ; \
	fi
	$(INSTALL) -m 644 $(BUSYBOX_SOURCE_DIR)/defconfig $(@D)/.config
### FEATURE_SYNC_FANCY requires syncfs syscall
	if (echo "#include <sys/syscall.h>"; \
		echo "#include <stdio.h>"; \
		echo "int main() {"; \
		echo "#ifndef __NR_syncfs"; \
		echo 'printf("no"\n);'; \
		echo "#else"; \
		echo 'printf("yes"\n);'; \
		echo "#endif"; \
		echo "}") | $(TARGET_CC) -E -P - | grep -xq 'printf("no"\\n);'; then \
			sed -i -e "s/^.*CONFIG_FEATURE_SYNC_FANCY.*/# CONFIG_FEATURE_SYNC_FANCY is not set/" $(@D)/.config; \
		fi
### I2CSET requires I2C_SMBUS_I2C_BLOCK_BROKEN support in the kernel
	if (echo "#include <linux/i2c.h>"; \
		echo "#include <stdio.h>"; \
		echo "int main() {"; \
		echo "#ifndef I2C_SMBUS_I2C_BLOCK_BROKEN"; \
		echo 'printf("no"\n);'; \
		echo "#else"; \
		echo 'printf("yes"\n);'; \
		echo "#endif"; \
		echo "}") | $(TARGET_CC) -E -P - | grep -xq 'printf("no"\\n);'; then \
			sed -i -e "s/^.*CONFIG_I2CSET.*/# CONFIG_I2CSET is not set/" $(@D)/.config; \
		fi
### I2CGET||I2CSET||I2CDUMP||I2CDETECT require I2C_FUNC_SMBUS_PEC support in the kernel
	if (echo "#include <linux/i2c.h>"; \
		echo "#include <stdio.h>"; \
		echo "int main() {"; \
		echo "#ifndef I2C_FUNC_SMBUS_PEC"; \
		echo 'printf("no"\n);'; \
		echo "#else"; \
		echo 'printf("yes"\n);'; \
		echo "#endif"; \
		echo "}") | $(TARGET_CC) -E -P - | grep -xq 'printf("no"\\n);'; then \
			sed -i -e "s/^.*CONFIG_\(I2CGET\|I2CSET\|I2CDUMP\|I2CDETECT\).*/# CONFIG_\1 is not set/" $(@D)/.config; \
		fi
### BLKDISCARD requires support in the kernel
	if (echo "#include <linux/fs.h>"; \
		echo "#include <stdio.h>"; \
		echo "int main() {"; \
		echo "#ifndef BLKSECDISCARD"; \
		echo 'printf("no"\n);'; \
		echo "#else"; \
		echo 'printf("yes"\n);'; \
		echo "#endif"; \
		echo "}") | $(TARGET_CC) -E -P - | grep -xq 'printf("no"\\n);'; then \
			sed -i -e "s/^.*CONFIG_BLKDISCARD.*/# CONFIG_BLKDISCARD is not set/" $(@D)/.config; \
		fi
ifneq ($(BUSYBOX_LDLIBS),)
	sed -i -e '/^CONFIG_EXTRA_LDLIBS=/s/"$$/ $(BUSYBOX_LDLIBS)"/' $(@D)/.config
endif
	$(MAKE) HOSTCC=$(HOSTCC) CC=$(TARGET_CC) CROSS="$(TARGET_CROSS)" \
		-C $(@D) oldconfig
#		-C $(@D) menuconfig
	touch $@

busybox-unpack: $(BUSYBOX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BUSYBOX_BUILD_DIR)/.built: $(BUSYBOX_BUILD_DIR)/.configured
	rm -f $@
	CPPFLAGS="$(STAGING_CPPFLAGS) $(BUSYBOX_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(BUSYBOX_LDFLAGS)" \
	$(BUSYBOX_BUILD_EXTRA_ENV) \
	$(MAKE) CROSS="$(TARGET_CROSS)" \
		HOSTCC=$(HOSTCC) CC=$(TARGET_CC) STRIP=$(TARGET_STRIP) \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) -fomit-frame-pointer" \
		-C $(@D)
	touch $@

#
# This is the build convenience target.
#
busybox: $(BUSYBOX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BUSYBOX_BUILD_DIR)/.staged: $(BUSYBOX_BUILD_DIR)/.built
	rm -f $@
	CPPFLAGS="$(STAGING_CPPFLAGS) $(BUSYBOX_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(BUSYBOX_LDFLAGS)" \
	$(BUSYBOX_BUILD_EXTRA_ENV) \
	$(MAKE) CROSS="$(TARGET_CROSS)" CONFIG_PREFIX="$(STAGING_PREFIX)" \
		HOSTCC=$(HOSTCC) CC=$(TARGET_CC) STRIP=$(TARGET_STRIP) \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" -C $(BUSYBOX_BUILD_DIR) install
	touch $@

busybox-stage: $(BUSYBOX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources
#
$(BUSYBOX_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: busybox" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BUSYBOX_PRIORITY)" >>$@
	@echo "Section: $(BUSYBOX_SECTION)" >>$@
	@echo "Version: $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUSYBOX_MAINTAINER)" >>$@
	@echo "Source: $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)" >>$@
	@echo "Description: $(BUSYBOX_DESCRIPTION)" >>$@
	@echo "Depends: busybox-base (= $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)), busybox-links (= $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION))" >>$@
	@echo "Conflicts: $(BUSYBOX_CONFLICTS)" >>$@

$(BUSYBOX_IPK_DIR)-base/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: busybox-base" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BUSYBOX_PRIORITY)" >>$@
	@echo "Section: $(BUSYBOX_SECTION)" >>$@
	@echo "Version: $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUSYBOX_MAINTAINER)" >>$@
	@echo "Source: $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)" >>$@
	@echo "Description: $(BUSYBOX_DESCRIPTION)" >>$@
	@echo "Depends: $(BUSYBOX_DEPENDS)" >>$@
	@echo "Conflicts: $(BUSYBOX_CONFLICTS)" >>$@

$(BUSYBOX_IPK_DIR)-links/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: busybox-links" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BUSYBOX_PRIORITY)" >>$@
	@echo "Section: $(BUSYBOX_SECTION)" >>$@
	@echo "Version: $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUSYBOX_MAINTAINER)" >>$@
	@echo "Source: $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)" >>$@
	@echo "Description: $(BUSYBOX_DESCRIPTION)" >>$@
	@echo "Depends: busybox-base (= $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION))" >>$@
	@echo "Conflicts: $(BUSYBOX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BUSYBOX_IPK_DIR)$(TARGET_PREFIX)/sbin or $(BUSYBOX_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BUSYBOX_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(BUSYBOX_IPK_DIR)$(TARGET_PREFIX)/etc/busybox/...
# Documentation files should be installed in $(BUSYBOX_IPK_DIR)$(TARGET_PREFIX)/doc/busybox/...
# Daemon startup scripts should be installed in $(BUSYBOX_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??busybox
#
# You may need to patch your application to make it use these locations.
#
$(BUSYBOX_IPK) $(BUSYBOX-BASE_IPK) $(BUSYBOX-LINKS_IPK): $(BUSYBOX_BUILD_DIR)/.built
	rm -rf $(BUSYBOX_IPK_DIR) $(BUILD_DIR)/busybox{,-base,-links}_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(BUSYBOX_IPK_DIR)$(TARGET_PREFIX)
	CPPFLAGS="$(STAGING_CPPFLAGS) $(BUSYBOX_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(BUSYBOX_LDFLAGS)" \
	$(BUSYBOX_BUILD_EXTRA_ENV) \
	$(MAKE) CROSS="$(TARGET_CROSS)" CONFIG_PREFIX="$(BUSYBOX_IPK_DIR)$(TARGET_PREFIX)" \
		HOSTCC=$(HOSTCC) CC=$(TARGET_CC) STRIP=$(TARGET_STRIP) \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" -C $(BUSYBOX_BUILD_DIR) install
	rm -rf $(BUSYBOX_IPK_DIR)-base
	$(INSTALL) -d $(BUSYBOX_IPK_DIR)-base$(TARGET_PREFIX)/bin
	mv $(BUSYBOX_IPK_DIR)$(TARGET_PREFIX)/bin/busybox $(BUSYBOX_IPK_DIR)-base$(TARGET_PREFIX)/bin
	$(MAKE) $(BUSYBOX_IPK_DIR)-base/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUSYBOX_IPK_DIR)-base
	rm -rf $(BUSYBOX_IPK_DIR)-links
	$(INSTALL) -d $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/bin
	$(INSTALL) -d $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/libexec
	$(INSTALL) -d $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/sbin
	mv $(BUSYBOX_IPK_DIR)$(TARGET_PREFIX)/bin/* $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/bin
	mv $(BUSYBOX_IPK_DIR)$(TARGET_PREFIX)/sbin/* $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/sbin
	mv $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/sbin/chroot $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/bin/
	if [ -f $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/sbin/ifconfig ] ; then \
		mv $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/sbin/ifconfig $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/bin/; \
	fi
	mv $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/sbin/syslogd $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/libexec/
	$(MAKE) $(BUSYBOX_IPK_DIR)-links/CONTROL/control
	echo "#!/bin/sh" > $(BUSYBOX_IPK_DIR)-links/CONTROL/postinst
	echo "#!/bin/sh" > $(BUSYBOX_IPK_DIR)-links/CONTROL/prerm
	for d in bin libexec sbin; do \
	    cd $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/$$d; \
	    for l in *; do \
		echo "update-alternatives --install '$(TARGET_PREFIX)/$$d/$$l' '$$l' $(TARGET_PREFIX)/bin/busybox 30" \
		    >> $(BUSYBOX_IPK_DIR)-links/CONTROL/postinst; \
		echo "update-alternatives --remove '$$l' $(TARGET_PREFIX)/bin/busybox" \
		    >> $(BUSYBOX_IPK_DIR)-links/CONTROL/prerm; \
	    done; \
	done
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(BUSYBOX_IPK_DIR)-links/CONTROL/postinst $(BUSYBOX_IPK_DIR)-links/CONTROL/prerm; \
	fi
	rm -rf $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)
	$(INSTALL) -d $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/bin
	$(INSTALL) -d $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/libexec
	$(INSTALL) -d $(BUSYBOX_IPK_DIR)-links$(TARGET_PREFIX)/sbin
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUSYBOX_IPK_DIR)-links
	rm -rf $(BUSYBOX_IPK_DIR)$(TARGET_PREFIX)
	$(MAKE) $(BUSYBOX_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUSYBOX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
busybox-ipk: $(BUSYBOX_IPK) $(BUSYBOX-BASE_IPK) $(BUSYBOX-LINKS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
busybox-clean:
	-$(MAKE) -C $(BUSYBOX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
busybox-dirclean:
	rm -rf $(BUILD_DIR)/$(BUSYBOX_DIR) $(BUSYBOX_BUILD_DIR)
	rm -rf $(BUSYBOX_IPK_DIR) $(BUSYBOX_IPK)
	rm -rf $(BUSYBOX_IPK_DIR)-base $(BUSYBOX-BASE_IPK)
	rm -rf $(BUSYBOX_IPK_DIR)-links $(BUSYBOX-LINKS_IPK)

#
# Some sanity check for the package.
#
busybox-check: $(BUSYBOX_IPK) $(BUSYBOX-BASE_IPK) $(BUSYBOX-LINKS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
endif
