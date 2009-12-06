###########################################################
#
# cpufrequtils
#
###########################################################

# You must replace "cpufrequtils" and "CPUFREQUTILS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# CPUFREQUTILS_VERSION, CPUFREQUTILS_SITE and CPUFREQUTILS_SOURCE define
# the upstream location of the source code for the package.
# CPUFREQUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# CPUFREQUTILS_UNZIP is the command used to unzip the source.
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
CPUFREQUTILS_SITE=http://www.kernel.org/pub/linux/utils/kernel/cpufreq/
CPUFREQUTILS_VERSION=006
CPUFREQUTILS_SOURCE=cpufrequtils-$(CPUFREQUTILS_VERSION).tar.gz
CPUFREQUTILS_DIR=cpufrequtils-$(CPUFREQUTILS_VERSION)
CPUFREQUTILS_UNZIP=zcat
CPUFREQUTILS_MAINTAINER=WebOS Internals <support@webos-internals.org>
CPUFREQUTILS_DESCRIPTION=To make access to the Linux kernel cpufreq subsystem easier for users and cpufreq userspace tools, a cpufrequtils package was created. It contains a library used by other programs (libcpufreq), command line tools to determine current CPUfreq settings and to modify them (cpufreq-info and cpufreq-set), and debug tools.
CPUFREQUTILS_SECTION=util
CPUFREQUTILS_PRIORITY=optional
ifeq (enable, $(GETTEXT_NLS))
CPUFREQUTILS_DEPENDS=gettext
endif
CPUFREQUTILS_SUGGESTS=
CPUFREQUTILS_CONFLICTS=

#
# CPUFREQUTILS_IPK_VERSION should be incremented when the ipk changes.
#
CPUFREQUTILS_IPK_VERSION=2

#
# CPUFREQUTILS_CONFFILES should be a list of user-editable files
#CPUFREQUTILS_CONFFILES=/opt/etc/cpufrequtils.conf /opt/etc/init.d/SXXcpufrequtils

#
# CPUFREQUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CPUFREQUTILS_PATCHES=$(CPUFREQUTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CPUFREQUTILS_CPPFLAGS=
ifeq (uclibc, $(LIBC_STYLE))
CPUFREQUTILS_LDFLAGS=-lintl
endif

#
# CPUFREQUTILS_BUILD_DIR is the directory in which the build is done.
# CPUFREQUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CPUFREQUTILS_IPK_DIR is the directory in which the ipk is built.
# CPUFREQUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CPUFREQUTILS_BUILD_DIR=$(BUILD_DIR)/cpufrequtils
CPUFREQUTILS_SOURCE_DIR=$(SOURCE_DIR)/cpufrequtils
CPUFREQUTILS_IPK_DIR=$(BUILD_DIR)/cpufrequtils-$(CPUFREQUTILS_VERSION)-ipk
CPUFREQUTILS_IPK=$(BUILD_DIR)/cpufrequtils_$(CPUFREQUTILS_VERSION)-$(CPUFREQUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cpufrequtils-source cpufrequtils-unpack cpufrequtils cpufrequtils-stage cpufrequtils-ipk cpufrequtils-clean cpufrequtils-dirclean cpufrequtils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CPUFREQUTILS_SOURCE):
	$(WGET) -P $(@D) $(CPUFREQUTILS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cpufrequtils-source: $(DL_DIR)/$(CPUFREQUTILS_SOURCE) $(CPUFREQUTILS_PATCHES)

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
$(CPUFREQUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(CPUFREQUTILS_SOURCE) $(CPUFREQUTILS_PATCHES) make/cpufrequtils.mk
	$(MAKE) libtool-stage
ifeq (enable, $(GETTEXT_NLS))
	$(MAKE) gettext-stage
endif
	rm -rf $(BUILD_DIR)/$(CPUFREQUTILS_DIR) $(@D)
	$(CPUFREQUTILS_UNZIP) $(DL_DIR)/$(CPUFREQUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CPUFREQUTILS_PATCHES)" ; \
		then cat $(CPUFREQUTILS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CPUFREQUTILS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CPUFREQUTILS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CPUFREQUTILS_DIR) $(@D) ; \
	fi
	sed -i -e '/-lcpufreq -o/s|$$(CFLAGS) |&$$(LDFLAGS) |' \
	    -i -e '/-o utils\/$$@.o/s|$$(CFLAGS) |&$$(CPPFLAGS) |' $(@D)/Makefile
	touch $@

cpufrequtils-unpack: $(CPUFREQUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CPUFREQUTILS_BUILD_DIR)/.built: $(CPUFREQUTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) V=true CROSS=${TARGET_CROSS} NLS=false \
		LIBTOOL=$(STAGING_PREFIX)/bin/libtool \
		bindir=$(STAGING_PREFIX)/bin libdir=$(STAGING_PREFIX)/lib \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CPUFREQUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CPUFREQUTILS_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
cpufrequtils: $(CPUFREQUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CPUFREQUTILS_BUILD_DIR)/.staged: $(CPUFREQUTILS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) CROSS=${TARGET_CROSS} NLS=false LIBTOOL=$(STAGING_PREFIX)/bin/libtool bindir=/opt/bin includedir=/opt/include libdir=/opt/lib install-lib
	touch $@

cpufrequtils-stage: $(CPUFREQUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cpufrequtils
#
$(CPUFREQUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: cpufrequtils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CPUFREQUTILS_PRIORITY)" >>$@
	@echo "Section: $(CPUFREQUTILS_SECTION)" >>$@
	@echo "Version: $(CPUFREQUTILS_VERSION)-$(CPUFREQUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CPUFREQUTILS_MAINTAINER)" >>$@
	@echo "Source: $(CPUFREQUTILS_SITE)/$(CPUFREQUTILS_SOURCE)" >>$@
	@echo "Description: $(CPUFREQUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(CPUFREQUTILS_DEPENDS)" >>$@
	@echo "Suggests: $(CPUFREQUTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(CPUFREQUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CPUFREQUTILS_IPK_DIR)/opt/sbin or $(CPUFREQUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CPUFREQUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CPUFREQUTILS_IPK_DIR)/opt/etc/cpufrequtils/...
# Documentation files should be installed in $(CPUFREQUTILS_IPK_DIR)/opt/doc/cpufrequtils/...
# Daemon startup scripts should be installed in $(CPUFREQUTILS_IPK_DIR)/opt/etc/init.d/S??cpufrequtils
#
# You may need to patch your application to make it use these locations.
#
$(CPUFREQUTILS_IPK): $(CPUFREQUTILS_BUILD_DIR)/.built
	rm -rf $(CPUFREQUTILS_IPK_DIR) $(BUILD_DIR)/cpufrequtils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CPUFREQUTILS_BUILD_DIR) DESTDIR=$(CPUFREQUTILS_IPK_DIR) CROSS=${TARGET_CROSS} NLS=false LIBTOOL=$(STAGING_PREFIX)/bin/libtool bindir=/opt/bin libdir=/opt/lib includedir=/opt/include install-lib install-tools
	rm -f $(CPUFREQUTILS_IPK_DIR)/opt/lib/libcpufreq.a
	$(STRIP_COMMAND) $(CPUFREQUTILS_IPK_DIR)/opt/lib/libcpufreq.so.0.0.0
#	install -d $(CPUFREQUTILS_IPK_DIR)/opt/etc/
#	install -m 644 $(CPUFREQUTILS_SOURCE_DIR)/cpufrequtils.conf $(CPUFREQUTILS_IPK_DIR)/opt/etc/cpufrequtils.conf
#	install -d $(CPUFREQUTILS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CPUFREQUTILS_SOURCE_DIR)/rc.cpufrequtils $(CPUFREQUTILS_IPK_DIR)/opt/etc/init.d/SXXcpufrequtils
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CPUFREQUTILS_IPK_DIR)/opt/etc/init.d/SXXcpufrequtils
	$(MAKE) $(CPUFREQUTILS_IPK_DIR)/CONTROL/control
#	install -m 755 $(CPUFREQUTILS_SOURCE_DIR)/postinst $(CPUFREQUTILS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CPUFREQUTILS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CPUFREQUTILS_SOURCE_DIR)/prerm $(CPUFREQUTILS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CPUFREQUTILS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(CPUFREQUTILS_IPK_DIR)/CONTROL/postinst $(CPUFREQUTILS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(CPUFREQUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(CPUFREQUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CPUFREQUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cpufrequtils-ipk: $(CPUFREQUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cpufrequtils-clean:
	rm -f $(CPUFREQUTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(CPUFREQUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cpufrequtils-dirclean:
	rm -rf $(BUILD_DIR)/$(CPUFREQUTILS_DIR) $(CPUFREQUTILS_BUILD_DIR) $(CPUFREQUTILS_IPK_DIR) $(CPUFREQUTILS_IPK)
#
#
# Some sanity check for the package.
#
cpufrequtils-check: $(CPUFREQUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
