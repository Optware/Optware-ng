###########################################################
#
# ipkg
#
###########################################################

#
# IPKG_REPOSITORY defines the upstream location of the source code
# for the package.  IPKG_DIR is the directory which is created when
# this cvs module is checked out.
#
IPKG_REPOSITORY=:pserver:anoncvs@anoncvs.handhelds.org
IPKG_DIR=ipkg
IPKG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IPKG_DESCRIPTION=The Itsy Package Manager
IPKG_SECTION=base
IPKG_PRIORITY=optional
IPKG_DEPENDS=
IPKG_SUGGESTS=
IPKG_CONFLICTS=

#
# Software downloaded from CVS repositories must either use a tag or a
# date to ensure that the same sources can be downloaded later.
#
IPKG_CVS_TAG=v0-99-163
IPKG_VERSION=0.99-163
IPKG_CVS_OPTS=-r $(IPKG_CVS_TAG)

#
# IPKG_IPK_VERSION should be incremented when the ipk changes.
#
IPKG_IPK_VERSION=1

#
# IPKG_CONFFILES should be a list of user-editable files
IPKG_CONFFILES=/opt/etc/ipkg.conf

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IPKG_CPPFLAGS=
IPKG_LDFLAGS=

#
# IPKG_BUILD_DIR is the directory in which the build is done.
# IPKG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IPKG_IPK_DIR is the directory in which the ipk is built.
# IPKG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPKG_BUILD_DIR=$(BUILD_DIR)/ipkg
IPKG_SOURCE_DIR=$(SOURCE_DIR)/ipkg
IPKG_IPK_DIR=$(BUILD_DIR)/ipkg-$(IPKG_VERSION)-ipk
IPKG_IPK=$(BUILD_DIR)/ipkg_$(IPKG_VERSION)-$(IPKG_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# IPKG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IPKG_PATCHES=$(IPKG_SOURCE_DIR)/args.h.patch $(IPKG_SOURCE_DIR)/ipkg_conf.c.patch $(IPKG_SOURCE_DIR)/update-alternatives.patch
ifeq ($(LIBC_STYLE), uclibc)
IPKG_PATCHES += $(IPKG_SOURCE_DIR)/ipkg_download.c.patch
endif
#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/ipkg-$(IPKG_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(IPKG_DIR) && \
		echo  "/1 $(IPKG_REPOSITORY):2401/cvs Ay=0=h<Z" \
			> ipkg.cvspass && \
		CVS_PASSFILE=ipkg.cvspass \
		cvs -d $(IPKG_REPOSITORY):/cvs -z3 co $(IPKG_CVS_OPTS) \
			-d $(IPKG_DIR) familiar/dist/ipkg/C && \
		tar -czf $@ $(IPKG_DIR) && \
		rm -rf $(IPKG_DIR) \
	)

ipkg-source: $(DL_DIR)/ipkg-$(IPKG_VERSION).tar.gz

#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <foo>-stage <baz>-stage").
#
$(IPKG_BUILD_DIR)/.configured: $(DL_DIR)/ipkg-$(IPKG_VERSION).tar.gz
	rm -rf $(BUILD_DIR)/$(IPKG_DIR) $(IPKG_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/ipkg-$(IPKG_VERSION).tar.gz
	if test -n "$(IPKG_PATCHES)" ; \
		then cat $(IPKG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(IPKG_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(IPKG_DIR)" != "$(IPKG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(IPKG_DIR) $(IPKG_BUILD_DIR) ; \
	fi
	(cd $(IPKG_BUILD_DIR); \
		rm -f etc/Makefile; \
		rm -f aclocal.m4; \
		libtoolize --force --copy; \
		aclocal-1.9; \
		autoconf; \
		autoheader; \
		automake-1.9 -a -c; \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IPKG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IPKG_LDFLAGS)" \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-ipkglibdir=/opt/lib \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(IPKG_BUILD_DIR)/.configured

#		PATH="$(PATH):$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/" \

ipkg-unpack: $(IPKG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IPKG_BUILD_DIR)/.built: $(IPKG_BUILD_DIR)/.configured
	rm -f $(IPKG_BUILD_DIR)/.built
	$(MAKE) -C $(IPKG_BUILD_DIR)
	touch $(IPKG_BUILD_DIR)/.built

#	PATH="$(PATH):$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/" 

#
# This is the build convenience target.
#
ipkg: $(IPKG_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ipkg
#
$(IPKG_IPK_DIR)/CONTROL/control:
	@install -d $(IPKG_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ipkg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPKG_PRIORITY)" >>$@
	@echo "Section: $(IPKG_SECTION)" >>$@
	@echo "Version: $(IPKG_VERSION)-$(IPKG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPKG_MAINTAINER)" >>$@
	@echo "Source: $(IPKG_REPOSITORY)" >>$@
	@echo "Description: $(IPKG_DESCRIPTION)" >>$@
	@echo "Depends: $(IPKG_DEPENDS)" >>$@
	@echo "Suggests: $(IPKG_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPKG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IPKG_IPK_DIR)/opt/sbin or $(IPKG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IPKG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IPKG_IPK_DIR)/opt/etc/ipkg/...
# Documentation files should be installed in $(IPKG_IPK_DIR)/opt/doc/ipkg/...
# Daemon startup scripts should be installed in $(IPKG_IPK_DIR)/opt/etc/init.d/S??ipkg
#
# You may need to patch your application to make it use these locations.
#
$(IPKG_IPK): $(IPKG_BUILD_DIR)/.built
	echo "This target may only be used for the uclibc, FSG-3, DS-101* or NAS100d boxen!"
	rm -rf $(IPKG_IPK_DIR) $(BUILD_DIR)/ipkg_*_$(TARGET_ARCH).ipk
	PATH="$(PATH):$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/" \
		$(MAKE) -C $(IPKG_BUILD_DIR) DESTDIR=$(IPKG_IPK_DIR) install-strip
	install -d $(IPKG_IPK_DIR)/opt/etc/
	install -m 644 $(IPKG_SOURCE_DIR)/ipkg.conf $(IPKG_IPK_DIR)/opt/etc/ipkg.conf
ifneq ($(LIBC_STYLE), uclibc)
	echo "lists_dir ext /opt/var/lib/ipkg" >> $(IPKG_IPK_DIR)/opt/etc/ipkg.conf
endif
	rm $(IPKG_IPK_DIR)/opt/lib/*.a
	rm $(IPKG_IPK_DIR)/opt/lib/*.la
	rm -rf $(IPKG_IPK_DIR)/opt/include
	mv $(IPKG_IPK_DIR)/opt/bin/ipkg-cl $(IPKG_IPK_DIR)/opt/bin/ipkg
	$(MAKE) $(IPKG_IPK_DIR)/CONTROL/control
	echo $(IPKG_CONFFILES) | sed -e 's/ /\n/g' > $(IPKG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPKG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ipkg-ipk: $(IPKG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ipkg-clean:
	rm -f $(IPKG_BUILD_DIR)/.built
	-$(MAKE) -C $(IPKG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ipkg-dirclean:
	rm -rf $(BUILD_DIR)/$(IPKG_DIR) $(IPKG_BUILD_DIR) $(IPKG_IPK_DIR) $(IPKG_IPK)
