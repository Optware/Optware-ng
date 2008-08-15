###########################################################
#
# simh
#
###########################################################
#
# SIMH_VERSION, SIMH_SITE and SIMH_SOURCE define
# the upstream location of the source code for the package.
# SIMH_DIR is the directory which is created when the source
# archive is unpacked.
# SIMH_UNZIP is the command used to unzip the source.
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
SIMH_SITE=http://simh.trailing-edge.com/sources
SIMH_UPSTREAM_VERSION=37-3
SIMH_VERSION=37.3
SIMH_SOURCE=simhv$(SIMH_UPSTREAM_VERSION).zip
SIMH_DIR=simh-$(SIMH_VERSION)
SIMH_UNZIP=unzip
SIMH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SIMH_DESCRIPTION=A highly portable, multi-system emulators.
SIMH_SECTION=misc
SIMH_PRIORITY=optional
SIMH_DEPENDS=
SIMH_SUGGESTS=
SIMH_CONFLICTS=

#
# SIMH_IPK_VERSION should be incremented when the ipk changes.
#
SIMH_IPK_VERSION=2

#
# SIMH_CONFFILES should be a list of user-editable files
#SIMH_CONFFILES=/opt/etc/simh.conf /opt/etc/init.d/SXXsimh

#
# SIMH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SIMH_PATCHES=$(SIMH_SOURCE_DIR)/makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SIMH_CPPFLAGS=
SIMH_LDFLAGS=
ifneq ($(LIBC_STYLE), uclibc)
SIMH_LDFLAGS+=-lrt
endif

#
# SIMH_BUILD_DIR is the directory in which the build is done.
# SIMH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SIMH_IPK_DIR is the directory in which the ipk is built.
# SIMH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SIMH_BUILD_DIR=$(BUILD_DIR)/simh
SIMH_SOURCE_DIR=$(SOURCE_DIR)/simh
SIMH_IPK_DIR=$(BUILD_DIR)/simh-$(SIMH_VERSION)-ipk
SIMH_IPK=$(BUILD_DIR)/simh_$(SIMH_VERSION)-$(SIMH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: simh-source simh-unpack simh simh-stage simh-ipk simh-clean simh-dirclean simh-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SIMH_SOURCE):
	$(WGET) -P $(@D) $(SIMH_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
simh-source: $(DL_DIR)/$(SIMH_SOURCE) $(SIMH_PATCHES)

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
$(SIMH_BUILD_DIR)/.configured: $(DL_DIR)/$(SIMH_SOURCE) $(SIMH_PATCHES) make/simh.mk
	$(MAKE) libpcap-stage
	rm -rf $(BUILD_DIR)/$(SIMH_DIR) $(@D)
	mkdir -p $(BUILD_DIR)/$(SIMH_DIR)/BIN && \
	cd $(BUILD_DIR)/$(SIMH_DIR) && \
	$(SIMH_UNZIP) -a $(DL_DIR)/$(SIMH_SOURCE)
	if test -n "$(SIMH_PATCHES)" ; \
		then cat $(SIMH_PATCHES) | patch -bd $(BUILD_DIR)/$(SIMH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SIMH_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SIMH_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SIMH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SIMH_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
ifeq ($(OPTWARE_TARGET), $(filter ts101 wl500g, $(OPTWARE_TARGET)))
	sed -i -e 's/-lrt//' $(@D)/makefile
	sed -i -e 's/#if defined (_POSIX_SOURCE)/#if 0/' $(@D)/sim_timer.c
endif
	touch $@

simh-unpack: $(SIMH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SIMH_BUILD_DIR)/.built: $(SIMH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		USE_NETWORK=1 \
		TARGET_CC=$(TARGET_CC) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SIMH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SIMH_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
simh: $(SIMH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(SIMH_BUILD_DIR)/.staged: $(SIMH_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(SIMH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#simh-stage: $(SIMH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/simh
#
$(SIMH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: simh" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SIMH_PRIORITY)" >>$@
	@echo "Section: $(SIMH_SECTION)" >>$@
	@echo "Version: $(SIMH_VERSION)-$(SIMH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SIMH_MAINTAINER)" >>$@
	@echo "Source: $(SIMH_SITE)/$(SIMH_SOURCE)" >>$@
	@echo "Description: $(SIMH_DESCRIPTION)" >>$@
	@echo "Depends: $(SIMH_DEPENDS)" >>$@
	@echo "Suggests: $(SIMH_SUGGESTS)" >>$@
	@echo "Conflicts: $(SIMH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SIMH_IPK_DIR)/opt/sbin or $(SIMH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SIMH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SIMH_IPK_DIR)/opt/etc/simh/...
# Documentation files should be installed in $(SIMH_IPK_DIR)/opt/doc/simh/...
# Daemon startup scripts should be installed in $(SIMH_IPK_DIR)/opt/etc/init.d/S??simh
#
# You may need to patch your application to make it use these locations.
#
$(SIMH_IPK): $(SIMH_BUILD_DIR)/.built
	rm -rf $(SIMH_IPK_DIR) $(BUILD_DIR)/simh_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(SIMH_BUILD_DIR) DESTDIR=$(SIMH_IPK_DIR) install-strip
	install -d $(SIMH_IPK_DIR)/opt/bin/
	install $(SIMH_BUILD_DIR)/BIN/* $(SIMH_IPK_DIR)/opt/bin/
	mv $(SIMH_IPK_DIR)/opt/bin/eclipse $(SIMH_IPK_DIR)/opt/bin/eclipseemu
	$(STRIP_COMMAND) $(SIMH_IPK_DIR)/opt/bin/*
	install -d $(SIMH_IPK_DIR)/opt/share/doc/simh/
	for f in `find $(SIMH_BUILD_DIR) -name '*.txt'`; do \
		install $$f $(SIMH_IPK_DIR)/opt/share/doc/simh/; \
	done
	$(MAKE) $(SIMH_IPK_DIR)/CONTROL/control
#	echo $(SIMH_CONFFILES) | sed -e 's/ /\n/g' > $(SIMH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SIMH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
simh-ipk: $(SIMH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
simh-clean:
	rm -f $(SIMH_BUILD_DIR)/.built
	-$(MAKE) -C $(SIMH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
simh-dirclean:
	rm -rf $(BUILD_DIR)/$(SIMH_DIR) $(SIMH_BUILD_DIR) $(SIMH_IPK_DIR) $(SIMH_IPK)
#
#
# Some sanity check for the package.
#
simh-check: $(SIMH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SIMH_IPK)
