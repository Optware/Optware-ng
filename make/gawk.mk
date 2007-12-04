###########################################################
#
# gawk
#
###########################################################

# You must replace "gawk" and "GAWK" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GAWK_VERSION, GAWK_SITE and GAWK_SOURCE define
# the upstream location of the source code for the package.
# GAWK_DIR is the directory which is created when the source
# archive is unpacked.
# GAWK_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GAWK_SITE=http://ftp.gnu.org/gnu/gawk
GAWK_VERSION=3.1.5
GAWK_SOURCE=gawk-$(GAWK_VERSION).tar.gz
GAWK_DIR=gawk-$(GAWK_VERSION)
GAWK_UNZIP=zcat
GAWK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GAWK_DESCRIPTION=Gnu AWK interpreter
GAWK_SECTION=util
GAWK_PRIORITY=optional
GAWK_DEPENDS=
GAWK_SUGGESTS=
GAWK_CONFLICTS=

#
# GAWK_IPK_VERSION should be incremented when the ipk changes.
#
GAWK_IPK_VERSION=4

#
# GAWK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GAWK_PATCHES=$(GAWK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GAWK_CPPFLAGS=
GAWK_LDFLAGS=

#
# GAWK_BUILD_DIR is the directory in which the build is done.
# GAWK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GAWK_IPK_DIR is the directory in which the ipk is built.
# GAWK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GAWK_BUILD_DIR=$(BUILD_DIR)/gawk
GAWK_SOURCE_DIR=$(SOURCE_DIR)/gawk
GAWK_IPK_DIR=$(BUILD_DIR)/gawk-$(GAWK_VERSION)-ipk
GAWK_IPK=$(BUILD_DIR)/gawk_$(GAWK_VERSION)-$(GAWK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gawk-source gawk-unpack gawk gawk-stage gawk-ipk gawk-clean gawk-dirclean gawk-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GAWK_SOURCE):
	$(WGET) -P $(DL_DIR) $(GAWK_SITE)/$(GAWK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gawk-source: $(DL_DIR)/$(GAWK_SOURCE) $(GAWK_PATCHES)

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
$(GAWK_BUILD_DIR)/.configured: $(DL_DIR)/$(GAWK_SOURCE) $(GAWK_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(GAWK_DIR) $(GAWK_BUILD_DIR)
	$(GAWK_UNZIP) $(DL_DIR)/$(GAWK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(GAWK_PATCHES) | patch -d $(BUILD_DIR)/$(GAWK_DIR) -p1
	mv $(BUILD_DIR)/$(GAWK_DIR) $(GAWK_BUILD_DIR)
	(cd $(GAWK_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GAWK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GAWK_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
ifeq ($(HOST_MACHINE),armv5b)
	echo "#define NGROUPS_MAX 32" >> $(GAWK_BUILD_DIR)/config.h
else
ifneq (, $(filter slugosbe slugosle, $(OPTWARE_TARGET)))
	echo "#define NGROUPS_MAX 32" >> $(GAWK_BUILD_DIR)/config.h
endif
endif
	touch $@

gawk-unpack: $(GAWK_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(GAWK_BUILD_DIR)/.built: $(GAWK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(GAWK_BUILD_DIR)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
gawk: $(GAWK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libgawk.so.$(GAWK_VERSION): $(GAWK_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(GAWK_BUILD_DIR)/gawk.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(GAWK_BUILD_DIR)/libgawk.a $(STAGING_DIR)/opt/lib
	install -m 644 $(GAWK_BUILD_DIR)/libgawk.so.$(GAWK_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libgawk.so.$(GAWK_VERSION) libgawk.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libgawk.so.$(GAWK_VERSION) libgawk.so

gawk-stage: $(STAGING_DIR)/opt/lib/libgawk.so.$(GAWK_VERSION)

$(GAWK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gawk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GAWK_PRIORITY)" >>$@
	@echo "Section: $(GAWK_SECTION)" >>$@
	@echo "Version: $(GAWK_VERSION)-$(GAWK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GAWK_MAINTAINER)" >>$@
	@echo "Source: $(GAWK_SITE)/$(GAWK_SOURCE)" >>$@
	@echo "Description: $(GAWK_DESCRIPTION)" >>$@
	@echo "Depends: $(GAWK_DEPENDS)" >>$@
	@echo "Suggests: $(GAWK_SUGGESTS)" >>$@
	@echo "Conflicts: $(GAWK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GAWK_IPK_DIR)/opt/sbin or $(GAWK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GAWK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GAWK_IPK_DIR)/opt/etc/gawk/...
# Documentation files should be installed in $(GAWK_IPK_DIR)/opt/doc/gawk/...
# Daemon startup scripts should be installed in $(GAWK_IPK_DIR)/opt/etc/init.d/S??gawk
#
# You may need to patch your application to make it use these locations.
#
$(GAWK_IPK): $(GAWK_BUILD_DIR)/.built
	rm -rf $(GAWK_IPK_DIR) $(BUILD_DIR)/gawk_*_$(TARGET_ARCH).ipk
	install -d $(GAWK_IPK_DIR)/opt/bin
	$(MAKE) -C $(GAWK_BUILD_DIR) DESTDIR=$(GAWK_IPK_DIR) install
	rm -rf $(GAWK_IPK_DIR)/opt/{man,info}
	rm -f $(GAWK_IPK_DIR)/opt/bin/gawk-3.1.5
	rm -f $(GAWK_IPK_DIR)/opt/bin/pgawk-3.1.5
	$(STRIP_COMMAND) $(GAWK_IPK_DIR)/opt/bin/gawk
	$(STRIP_COMMAND) $(GAWK_IPK_DIR)/opt/bin/pgawk
	$(STRIP_COMMAND) $(GAWK_IPK_DIR)/opt/libexec/awk/grcat
	$(STRIP_COMMAND) $(GAWK_IPK_DIR)/opt/libexec/awk/pwcat
	$(MAKE) $(GAWK_IPK_DIR)/CONTROL/control
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --install /opt/bin/awk awk /opt/bin/gawk 80"; \
	) > $(GAWK_IPK_DIR)/CONTROL/postinst
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --remove awk /opt/bin/gawk"; \
	) > $(GAWK_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GAWK_IPK_DIR)/CONTROL/postinst $(GAWK_IPK_DIR)/CONTROL/prerm; \
	fi
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GAWK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gawk-ipk: $(GAWK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gawk-clean:
	-$(MAKE) -C $(GAWK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gawk-dirclean:
	rm -rf $(BUILD_DIR)/$(GAWK_DIR) $(GAWK_BUILD_DIR) $(GAWK_IPK_DIR) $(GAWK_IPK)

#
# Some sanity check for the package.
#
gawk-check: $(GAWK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GAWK_IPK)
