###########################################################
#
# ipkg-fw
#
###########################################################

#
# IPKG-FW_REPOSITORY defines the upstream location of the source code
# for the package.  IPKG-FW_DIR is the directory which is created when
# this cvs module is checked out.
#
IPKG-FW_REPOSITORY=:pserver:anoncvs@anoncvs.handhelds.org
IPKG-FW_DIR=ipkg-opt
IPKG-FW_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IPKG-FW_DESCRIPTION=Static Itsy Package Manager for bootstraping
IPKG-FW_SECTION=base
IPKG-FW_PRIORITY=optional
IPKG-FW_DEPENDS=
IPKG-FW_SUGGESTS=
IPKG-FW_CONFLICTS=ipkg-opt

#
# Software downloaded from CVS repositories must either use a tag or a
# date to ensure that the same sources can be downloaded later.
#
IPKG-FW_CVS_TAG=v0-99-163
IPKG-FW_VERSION=0.99.163
IPKG-FW_CVS_OPTS=-r $(IPKG-FW_CVS_TAG)

#
# IPKG-FW_IPK_VERSION should be incremented when the ipk changes.
#
IPKG-FW_IPK_VERSION=2

#
# IPKG-FW_CONFFILES should be a list of user-editable files
IPKG-FW_CONFFILES=/opt/etc/ipkg.conf

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IPKG-FW_CPPFLAGS=
IPKG-FW_LDFLAGS=

#
# IPKG-FW_BUILD_DIR is the directory in which the build is done.
# IPKG-FW_SOURCE_DIR is the directory which holds all the
# patches and ipkg-fw control files.
# IPKG-FW_IPK_DIR is the directory in which the ipk is built.
# IPKG-FW_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPKG-FW_BUILD_DIR=$(BUILD_DIR)/ipkg-fw
IPKG-FW_SOURCE_DIR=$(SOURCE_DIR)/ipkg-opt
IPKG-FW_IPK_DIR=$(BUILD_DIR)/ipkg-fw-$(IPKG-FW_VERSION)-ipk
IPKG-FW_IPK=$(BUILD_DIR)/ipkg-fw_$(IPKG-FW_VERSION)-$(IPKG-FW_IPK_VERSION)_$(TARGET_ARCH).ipk
IPKG-FW_FEEDS=http://ipkg.nslu2-linux.org/feeds/optware

.PHONY: ipkg-fw-source ipkg-fw-unpack ipkg-fw ipkg-fw-stage ipkg-fw-ipk ipkg-fw-clean ipkg-fw-dirclean ipkg-fw-check

#
# IPKG-FW_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IPKG-FW_PATCHES=$(IPKG-FW_SOURCE_DIR)/args.h.patch \
	$(IPKG-FW_SOURCE_DIR)/ipkg_conf.h.patch \
	$(IPKG-FW_SOURCE_DIR)/ipkg_conf.c.patch \
	$(IPKG-FW_SOURCE_DIR)/update-alternatives.patch \
	$(IPKG-FW_SOURCE_DIR)/ipkg-va_start_segfault.diff \
	$(IPKG-FW_SOURCE_DIR)/list_installed.patch \
	$(IPKG-FW_SOURCE_DIR)/ipkg_install.c.patch

ifeq ($(LIBC_STYLE), uclibc)
IPKG-FW_PATCHES += $(IPKG-FW_SOURCE_DIR)/ipkg_download.c.patch
endif
ifeq ($(TARGET_OS), darwin)
IPKG-FW_PATCHES += $(IPKG-FW_SOURCE_DIR)/darwin.patch
endif
ifeq ($(OPTWARE_TARGET), tsx09)
IPKG-FW_PATCHES += $(IPKG-FW_SOURCE_DIR)/use-optware-wget.patch
endif

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
#$(DL_DIR)/ipkg-fw-$(IPKG-FW_VERSION).tar.gz:
#	( cd $(BUILD_DIR) ; \
		rm -rf $(IPKG-FW_DIR) && \
		echo  "/1 $(IPKG-FW_REPOSITORY):2401/cvs Ay=0=h<Z" \
			> ipkg.cvspass && \
		CVS_PASSFILE=ipkg.cvspass \
		cvs -d $(IPKG-FW_REPOSITORY):/cvs -z3 co $(IPKG-FW_CVS_OPTS) \
			-d $(IPKG-FW_DIR) familiar/dist/ipkg/C && \
		tar -czf $@ $(IPKG-FW_DIR) && \
		rm -rf $(IPKG-FW_DIR) \
	)

ipkg-fw-source: #$(DL_DIR)/ipkg-fw-$(IPKG-FW_VERSION).tar.gz
	$(MAKE) ipkg-opt-source

#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) ipkg-fw-stage <baz>-stage").
#
$(IPKG-FW_BUILD_DIR)/.configured: make/ipkg-fw.mk #$(DL_DIR)/ipkg-fw-$(IPKG-FW_VERSION).tar.gz
	$(MAKE) ipkg-opt-source
	rm -rf $(BUILD_DIR)/$(IPKG-FW_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/ipkg-opt-$(IPKG-FW_VERSION).tar.gz
	if test -n "$(IPKG-FW_PATCHES)" ; \
		then cat $(IPKG-FW_PATCHES) | \
		patch -d $(BUILD_DIR)/$(IPKG-FW_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(IPKG-FW_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(IPKG-FW_DIR) $(@D) ; \
	fi
	rm -f $(@D)/etc/Makefile aclocal.m4
	autoreconf -vif $(@D)
	(cd $(@D); \
		CPPFLAGS="$(TARGET_CFLAGS) $(IPKG-FW_CPPFLAGS)" \
		LDFLAGS="-Wl,--gc-sections --static $(IPKG-FW_LDFLAGS)" \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-ipkglibdir=/opt/lib \
		--prefix=/opt \
		--disable-nls \
		--disable-shared \
	)
	touch $@

#		PATH="$(PATH):$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/" \

ipkg-fw-unpack: $(IPKG-FW_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IPKG-FW_BUILD_DIR)/.built: $(IPKG-FW_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#	PATH="$(PATH):$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/" 

#
# This is the build convenience target.
#
ipkg-fw: $(IPKG-FW_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg-fw.  It is no longer
# necessary to create a seperate control file under sources/ipkg-fw
#
$(IPKG-FW_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ipkg-fw" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPKG-FW_PRIORITY)" >>$@
	@echo "Section: $(IPKG-FW_SECTION)" >>$@
	@echo "Version: $(IPKG-FW_VERSION)-$(IPKG-FW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPKG-FW_MAINTAINER)" >>$@
	@echo "Source: $(IPKG-FW_REPOSITORY)" >>$@
	@echo "Description: $(IPKG-FW_DESCRIPTION)" >>$@
	@echo "Depends: $(IPKG-FW_DEPENDS)" >>$@
	@echo "Suggests: $(IPKG-FW_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPKG-FW_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IPKG-FW_IPK_DIR)/opt/sbin or $(IPKG-FW_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IPKG-FW_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IPKG-FW_IPK_DIR)/opt/etc/ipkg/...
# Documentation files should be installed in $(IPKG-FW_IPK_DIR)/opt/doc/ipkg-fw/...
# Daemon startup scripts should be installed in $(IPKG-FW_IPK_DIR)/opt/etc/init.d/S??ipkg
#
# You may need to patch your application to make it use these locations.
#

$(IPKG-FW_IPK): $(IPKG-FW_BUILD_DIR)/.built
	rm -rf $(IPKG-FW_IPK_DIR) $(BUILD_DIR)/ipkg-fw_*_$(TARGET_ARCH).ipk
	PATH="$(PATH):$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/" \
		$(MAKE) -C $(IPKG-FW_BUILD_DIR) DESTDIR=$(IPKG-FW_IPK_DIR) install-strip
	install -d $(IPKG-FW_IPK_DIR)/opt/etc/
ifneq (, $(filter ddwrt ds101 ds101g fsg3 gumstix1151 mss nas100d nslu2 oleg slugosbe slugosle ts72xx wl500g, $(OPTWARE_TARGET)))
	echo "#Uncomment the following line for native packages feed (if any)" \
		> $(IPKG-FW_IPK_DIR)/opt/etc/ipkg.conf
	echo "#src/gz native $(IPKG-FW_FEEDS)/$(OPTWARE_TARGET)/native/stable"\
			>> $(IPKG-FW_IPK_DIR)/opt/etc/ipkg.conf
	echo "src/gz optware $(IPKG-FW_FEEDS)/$(OPTWARE_TARGET)/cross/stable" \
			>> $(IPKG-FW_IPK_DIR)/opt/etc/ipkg.conf
	echo "dest /opt/ /" >> $(IPKG-FW_IPK_DIR)/opt/etc/ipkg.conf
	echo "#option verbose-wget" >> $(IPKG-FW_IPK_DIR)/opt/etc/ipkg.conf
else
	install -m 644 $(IPKG-FW_SOURCE_DIR)/ipkg.conf \
		$(IPKG-FW_IPK_DIR)/opt/etc/ipkg.conf
endif
	rm -f $(IPKG-FW_IPK_DIR)/opt/lib/*.a $(IPKG-FW_IPK_DIR)/opt/lib/*.la
	rm -rf $(IPKG-FW_IPK_DIR)/opt/include
	mv $(IPKG-FW_IPK_DIR)/opt/bin/ipkg-cl $(IPKG-FW_IPK_DIR)/opt/bin/ipkg
	ln -s ipkg $(IPKG-FW_IPK_DIR)/opt/bin/ipkg-fw
	$(MAKE) $(IPKG-FW_IPK_DIR)/CONTROL/control
	echo $(IPKG-FW_CONFFILES) | sed -e 's/ /\n/g' > $(IPKG-FW_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPKG-FW_IPK_DIR)

$(IPKG-FW_BUILD_DIR)/.ipk: $(IPKG-FW_IPK)
	rm -f $@
	touch $@

#
# This is called from the top level makefile to create the IPK file.
#
ipkg-fw-ipk: $(IPKG-FW_BUILD_DIR)/.ipk

#
# This is called from the top level makefile to clean all of the built files.
#
ipkg-fw-clean:
	rm -f $(IPKG-FW_BUILD_DIR)/.built
	-$(MAKE) -C $(IPKG-FW_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ipkg-fw-dirclean:
	rm -rf $(BUILD_DIR)/$(IPKG-FW_DIR) $(IPKG-FW_BUILD_DIR) $(IPKG-FW_IPK_DIR) $(IPKG-FW_IPK)

#
#
# Some sanity check for the package.
#
ipkg-fw-check: $(IPKG-FW_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IPKG-FW_IPK)
