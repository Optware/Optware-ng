###########################################################
#
# ipkg-opt
#
###########################################################

#
# IPKG-OPT_REPOSITORY defines the upstream location of the source code
# for the package.  IPKG-OPT_DIR is the directory which is created when
# this cvs module is checked out.
#
IPKG-OPT_REPOSITORY=:pserver:anoncvs@anoncvs.handhelds.org
IPKG-OPT_DIR=ipkg-opt
IPKG-OPT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IPKG-OPT_DESCRIPTION=The Itsy Package Manager
IPKG-OPT_SECTION=base
IPKG-OPT_PRIORITY=optional
IPKG-OPT_DEPENDS=
ifeq ($(LIBC_STYLE), uclibc)
IPKG-OPT_SUGGESTS=uclibc-opt
else
IPKG-OPT_SUGGESTS=
endif
IPKG-OPT_CONFLICTS=

#
# Software downloaded from CVS repositories must either use a tag or a
# date to ensure that the same sources can be downloaded later.
#
IPKG-OPT_CVS_TAG=v0-99-163
IPKG-OPT_VERSION=0.99.163
IPKG-OPT_CVS_OPTS=-r $(IPKG-OPT_CVS_TAG)

#
# IPKG-OPT_IPK_VERSION should be incremented when the ipk changes.
#
IPKG-OPT_IPK_VERSION=5

#
# IPKG-OPT_CONFFILES should be a list of user-editable files
IPKG-OPT_CONFFILES=/opt/etc/ipkg.conf

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IPKG-OPT_CPPFLAGS=
IPKG-OPT_LDFLAGS=

#
# IPKG-OPT_BUILD_DIR is the directory in which the build is done.
# IPKG-OPT_SOURCE_DIR is the directory which holds all the
# patches and ipkg-opt control files.
# IPKG-OPT_IPK_DIR is the directory in which the ipk is built.
# IPKG-OPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPKG-OPT_BUILD_DIR=$(BUILD_DIR)/ipkg-opt
IPKG-OPT_SOURCE_DIR=$(SOURCE_DIR)/ipkg-opt
IPKG-OPT_IPK_DIR=$(BUILD_DIR)/ipkg-opt-$(IPKG-OPT_VERSION)-ipk
IPKG-OPT_IPK=$(BUILD_DIR)/ipkg-opt_$(IPKG-OPT_VERSION)-$(IPKG-OPT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ipkg-opt-source ipkg-opt-unpack ipkg-opt ipkg-opt-stage ipkg-opt-ipk ipkg-opt-clean ipkg-opt-dirclean ipkg-opt-check

#
# IPKG-OPT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IPKG-OPT_PATCHES=$(IPKG-OPT_SOURCE_DIR)/args.h.patch \
	$(IPKG-OPT_SOURCE_DIR)/ipkg_conf.c.patch \
	$(IPKG-OPT_SOURCE_DIR)/update-alternatives.patch \
	$(IPKG-OPT_SOURCE_DIR)/ipkg-va_start_segfault.diff \
	$(IPKG-OPT_SOURCE_DIR)/list_installed.patch
ifeq ($(LIBC_STYLE), uclibc)
IPKG-OPT_PATCHES += $(IPKG-OPT_SOURCE_DIR)/ipkg_download.c.patch
endif
#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/ipkg-$(IPKG-OPT_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(IPKG-OPT_DIR) && \
		echo  "/1 $(IPKG-OPT_REPOSITORY):2401/cvs Ay=0=h<Z" \
			> ipkg.cvspass && \
		CVS_PASSFILE=ipkg.cvspass \
		cvs -d $(IPKG-OPT_REPOSITORY):/cvs -z3 co $(IPKG-OPT_CVS_OPTS) \
			-d $(IPKG-OPT_DIR) familiar/dist/ipkg/C && \
		tar -czf $@ $(IPKG-OPT_DIR) && \
		rm -rf $(IPKG-OPT_DIR) \
	)

ipkg-opt-source: $(DL_DIR)/ipkg-$(IPKG-OPT_VERSION).tar.gz

#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) ipkg-opt-stage <baz>-stage").
#
$(IPKG-OPT_BUILD_DIR)/.configured: $(DL_DIR)/ipkg-$(IPKG-OPT_VERSION).tar.gz
	rm -rf $(BUILD_DIR)/$(IPKG-OPT_DIR) $(IPKG-OPT_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/ipkg-$(IPKG-OPT_VERSION).tar.gz
	if test -n "$(IPKG-OPT_PATCHES)" ; \
		then cat $(IPKG-OPT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(IPKG-OPT_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(IPKG-OPT_DIR)" != "$(IPKG-OPT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(IPKG-OPT_DIR) $(IPKG-OPT_BUILD_DIR) ; \
	fi
	(cd $(IPKG-OPT_BUILD_DIR); \
		rm -f etc/Makefile; \
		rm -f aclocal.m4; \
		libtoolize --force --copy; \
		aclocal-1.9; \
		autoconf; \
		autoheader; \
		automake-1.9 -a -c; \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IPKG-OPT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IPKG-OPT_LDFLAGS)" \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-ipkglibdir=/opt/lib \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(IPKG-OPT_BUILD_DIR)/.configured

#		PATH="$(PATH):$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/" \

ipkg-opt-unpack: $(IPKG-OPT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IPKG-OPT_BUILD_DIR)/.built: $(IPKG-OPT_BUILD_DIR)/.configured
	rm -f $(IPKG-OPT_BUILD_DIR)/.built
	$(MAKE) -C $(IPKG-OPT_BUILD_DIR)
	touch $(IPKG-OPT_BUILD_DIR)/.built

#	PATH="$(PATH):$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/" 

#
# This is the build convenience target.
#
ipkg-opt: $(IPKG-OPT_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg-opt.  It is no longer
# necessary to create a seperate control file under sources/ipkg-opt
#
$(IPKG-OPT_IPK_DIR)/CONTROL/control:
	@install -d $(IPKG-OPT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ipkg-opt" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPKG-OPT_PRIORITY)" >>$@
	@echo "Section: $(IPKG-OPT_SECTION)" >>$@
	@echo "Version: $(IPKG-OPT_VERSION)-$(IPKG-OPT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPKG-OPT_MAINTAINER)" >>$@
	@echo "Source: $(IPKG-OPT_REPOSITORY)" >>$@
	@echo "Description: $(IPKG-OPT_DESCRIPTION)" >>$@
	@echo "Depends: $(IPKG-OPT_DEPENDS)" >>$@
	@echo "Suggests: $(IPKG-OPT_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPKG-OPT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IPKG-OPT_IPK_DIR)/opt/sbin or $(IPKG-OPT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IPKG-OPT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IPKG-OPT_IPK_DIR)/opt/etc/ipkg/...
# Documentation files should be installed in $(IPKG-OPT_IPK_DIR)/opt/doc/ipkg-opt/...
# Daemon startup scripts should be installed in $(IPKG-OPT_IPK_DIR)/opt/etc/init.d/S??ipkg
#
# You may need to patch your application to make it use these locations.
#
$(IPKG-OPT_IPK): $(IPKG-OPT_BUILD_DIR)/.built
	echo "This target may only be used for the uclibc, FSG-3, DS-101* or NAS100d boxen!"
	rm -rf $(IPKG-OPT_IPK_DIR) $(BUILD_DIR)/ipkg-opt_*_$(TARGET_ARCH).ipk
	PATH="$(PATH):$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/" \
		$(MAKE) -C $(IPKG-OPT_BUILD_DIR) DESTDIR=$(IPKG-OPT_IPK_DIR) install-strip
	install -d $(IPKG-OPT_IPK_DIR)/opt/etc/
	install -m 644 $(IPKG-OPT_SOURCE_DIR)/ipkg.conf $(IPKG-OPT_IPK_DIR)/opt/etc/ipkg.conf
	rm $(IPKG-OPT_IPK_DIR)/opt/lib/*.a
	rm $(IPKG-OPT_IPK_DIR)/opt/lib/*.la
	rm -rf $(IPKG-OPT_IPK_DIR)/opt/include
	mv $(IPKG-OPT_IPK_DIR)/opt/bin/ipkg-cl $(IPKG-OPT_IPK_DIR)/opt/bin/ipkg
	$(MAKE) $(IPKG-OPT_IPK_DIR)/CONTROL/control
	echo $(IPKG-OPT_CONFFILES) | sed -e 's/ /\n/g' > $(IPKG-OPT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPKG-OPT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ipkg-opt-ipk: $(IPKG-OPT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ipkg-opt-clean:
	rm -f $(IPKG-OPT_BUILD_DIR)/.built
	-$(MAKE) -C $(IPKG-OPT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ipkg-opt-dirclean:
	rm -rf $(BUILD_DIR)/$(IPKG-OPT_DIR) $(IPKG-OPT_BUILD_DIR) $(IPKG-OPT_IPK_DIR) $(IPKG-OPT_IPK)

#
#
# Some sanity check for the package.
#
ipkg-opt-check: $(IPKG-OPT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IPKG-OPT_IPK)
