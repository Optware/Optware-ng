###########################################################
#
# svn
#
###########################################################

# You must replace "svn" and "SVN" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SVN_VERSION, SVN_SITE and SVN_SOURCE define
# the upstream location of the source code for the package.
# SVN_DIR is the directory which is created when the source
# archive is unpacked.
# SVN_UNZIP is the command used to unzip the source.
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
SVN_SITE=http://subversion.tigris.org/downloads
SVN_VERSION=1.4.5
SVN_SOURCE=subversion-$(SVN_VERSION).tar.bz2
SVN_DIR=subversion-$(SVN_VERSION)
SVN_UNZIP=bzcat
SVN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SVN_DESCRIPTION=a compelling replacement for CVS
SVN_SECTION=net
SVN_PRIORITY=optional
SVN_DEPENDS=neon, apr, apr-util, zlib, expat, libxml2
ifeq (openldap, $(filter openldap, $(PACKAGES)))
SVN_DEPENDS +=, openldap-libs
endif
ifeq ($(OPTWARE_TARGET),ts101)
SVN_DEPENDS +=, gettext
endif
SVN_SUGGESTS=
SVN_CONFLICTS=

SVN-PY_DESCRIPTION=python SWIG binding for subversion
SVN-PY_DEPENDS=python25, svn
SVN-PY_SUGGESTS=
SVN-PY_CONFLICTS=

SVN-PL_DESCRIPTION=perl SWIG binding for subversion
SVN-PL_DEPENDS=perl, svn
SVN-PL_SUGGESTS=
SVN-PL_CONFLICTS=

#
# SVN_IPK_VERSION should be incremented when the ipk changes.
#
SVN_IPK_VERSION=2

#
# SVN_CONFFILES should be a list of user-editable files
SVN_CONFFILES=

#
# SVN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SVN_PATCHES=$(SVN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SVN_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/neon -D_LARGEFILE64_SOURCE
SVN_LDFLAGS=
ifeq ($(TARGET_CC), $(HOSTCC))
SVN_CONFIG_ENV=
else
SVN_CONFIG_ENV=ac_cv_func_memcmp_working=yes
endif

#
# SVN_BUILD_DIR is the directory in which the build is done.
# SVN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SVN_IPK_DIR is the directory in which the ipk is built.
# SVN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SVN_BUILD_DIR=$(BUILD_DIR)/svn
SVN_SOURCE_DIR=$(SOURCE_DIR)/svn

SVN_IPK_DIR=$(BUILD_DIR)/svn-$(SVN_VERSION)-ipk
SVN_IPK=$(BUILD_DIR)/svn_$(SVN_VERSION)-$(SVN_IPK_VERSION)_$(TARGET_ARCH).ipk

SVN-PY_IPK_DIR=$(BUILD_DIR)/svn-py-$(SVN_VERSION)-ipk
SVN-PY_IPK=$(BUILD_DIR)/svn-py_$(SVN_VERSION)-$(SVN_IPK_VERSION)_$(TARGET_ARCH).ipk
SVN_INSTALL_SWIG_TARGETS=install-swig-py

ifneq (,$(filter perl, $(PACKAGES)))
SVN_CONFIG_ENV+=PERL=$(PERL_HOSTPERL)
SVN-PL_IPK_DIR=$(BUILD_DIR)/svn-pl-$(SVN_VERSION)-ipk
SVN-PL_IPK=$(BUILD_DIR)/svn-pl_$(SVN_VERSION)-$(SVN_IPK_VERSION)_$(TARGET_ARCH).ipk
SVN_INSTALL_SWIG_TARGETS+=install-swig-pl
else
SVN_CONFIG_ENV+=ac_cv_path_PERL=none
endif

.PHONY: svn-source svn-unpack svn svn-stage svn-ipk svn-clean svn-dirclean svn-check
#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SVN_SOURCE):
	$(WGET) -P $(DL_DIR) $(SVN_SITE)/$(SVN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
svn-source: $(DL_DIR)/$(SVN_SOURCE) $(SVN_PATCHES)

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
$(SVN_BUILD_DIR)/.configured: $(DL_DIR)/$(SVN_SOURCE) $(SVN_PATCHES)
	$(MAKE) apr-stage
	$(MAKE) apr-util-stage
	$(MAKE) apache-stage
	$(MAKE) expat-stage
	$(MAKE) libxml2-stage
	$(MAKE) neon-stage
	$(MAKE) zlib-stage
ifeq (openldap, $(filter openldap, $(PACKAGES)))
	$(MAKE) openldap-stage
endif
	$(MAKE) python25-stage python25-host-stage
ifneq (,$(filter perl, $(PACKAGES)))
	$(MAKE) perl-stage
endif
	rm -rf $(BUILD_DIR)/$(SVN_DIR) $(SVN_BUILD_DIR)
	$(SVN_UNZIP) $(DL_DIR)/$(SVN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(SVN_PATCHES) | patch -d $(BUILD_DIR)/$(SVN_DIR) -p1
	mv $(BUILD_DIR)/$(SVN_DIR) $(SVN_BUILD_DIR)
	(cd $(SVN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SVN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SVN_LDFLAGS)" \
		PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.5 \
		$(SVN_CONFIG_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-neon=$(STAGING_DIR)/opt \
		--with-apr=$(STAGING_DIR)/opt \
		--with-apr=$(STAGING_DIR)/opt \
		--with-apr-util=$(STAGING_DIR)/opt \
		--with-apxs=$(STAGING_DIR)/opt/sbin/apxs \
		--without-swig \
		--enable-shared \
		--disable-static \
	)
#	sed -i -e 's/ --silent//' $(SVN_BUILD_DIR)/Makefile
	sed -i \
	    -e '/^SWIG_PY/s|= *gcc|= $(TARGET_CC)|' \
	    -e '/^SWIG_PY_INCLUDES/s|/host||' \
	    -e '/^SWIG_PY_LIBS/s|$$| $(STAGING_LDFLAGS) $(SVN_LDFLAGS)|' \
	    $(SVN_BUILD_DIR)/Makefile
	$(PATCH_LIBTOOL) $(SVN_BUILD_DIR)/libtool
#	sed -i -e '/^runpath_var=/s/LD_RUN_PATH//' $(SVN_BUILD_DIR)/libtool
	sed -i -e '/export $$runpath_var/'"s|'.*'|'/opt/lib'|" $(SVN_BUILD_DIR)/libtool
	touch $(SVN_BUILD_DIR)/.configured

svn-unpack: $(SVN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SVN_BUILD_DIR)/.built: $(SVN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SVN_BUILD_DIR)
	touch $@

$(SVN_BUILD_DIR)/.py-built: $(SVN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SVN_BUILD_DIR) swig-py
	touch $@

$(SVN_BUILD_DIR)/.pl-built: $(SVN_BUILD_DIR)/.built
	rm -f $@
	cd $(SVN_BUILD_DIR)/subversion/bindings/swig/perl/native; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SVN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SVN_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		;
	sed -i -e '/^INSTALL.*=.*staging-install/s|= *$(PERL_HOST_BUILD_DIR)/staging-install|= /opt|' $(SVN_BUILD_DIR)/subversion/bindings/swig/perl/native/Makefile
	$(MAKE) -C $(SVN_BUILD_DIR) swig-pl \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SVN_CPPFLAGS)" \
		PASTHRU_INC="$(STAGING_CPPFLAGS) $(SVN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SVN_LDFLAGS)" \
		LDDLFLAGS="-shared -L$(STAGING_LIB_DIR) -rpath /opt/lib -rpath-link $(STAGING_LIB_DIR)" \
		OTHERLDFLAGS="-L$(SVN_BUILD_DIR)/subversion/bindings/swig/perl/libsvn_swig_perl/.libs" \
		$(PERL_INC) \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		;
	touch $@

#
# This is the build convenience target.
#
svn-py: $(SVN_BUILD_DIR)/.py-built
svn-pl: $(SVN_BUILD_DIR)/.pl-built
svn: $(SVN_BUILD_DIR)/.built $(SVN_BUILD_DIR)/.py-built $(SVN_BUILD_DIR)/.pl-built

#
# If you are building a library, then you need to stage it too.
#
$(SVN_BUILD_DIR)/.staged: $(SVN_BUILD_DIR)/.built
	rm -f $(SVN_BUILD_DIR)/.staged
	$(MAKE) -C $(SVN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SVN_BUILD_DIR)/.staged

svn-stage: $(SVN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/svn
#
$(SVN_IPK_DIR)/CONTROL/control:
	@install -d $(SVN_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: svn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SVN_PRIORITY)" >>$@
	@echo "Section: $(SVN_SECTION)" >>$@
	@echo "Version: $(SVN_VERSION)-$(SVN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SVN_MAINTAINER)" >>$@
	@echo "Source: $(SVN_SITE)/$(SVN_SOURCE)" >>$@
	@echo "Description: $(SVN_DESCRIPTION)" >>$@
	@echo "Depends: $(SVN_DEPENDS)" >>$@
	@echo "Suggests: $(SVN_SUGGESTS)" >>$@
	@echo "Conflicts: $(SVN_CONFLICTS)" >>$@

$(SVN-PY_IPK_DIR)/CONTROL/control:
	@install -d $(SVN-PY_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: svn-py" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SVN_PRIORITY)" >>$@
	@echo "Section: $(SVN_SECTION)" >>$@
	@echo "Version: $(SVN_VERSION)-$(SVN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SVN_MAINTAINER)" >>$@
	@echo "Source: $(SVN_SITE)/$(SVN_SOURCE)" >>$@
	@echo "Description: $(SVN-PY_DESCRIPTION)" >>$@
	@echo "Depends: $(SVN-PY_DEPENDS)" >>$@
	@echo "Suggests: $(SVN-PY_SUGGESTS)" >>$@
	@echo "Conflicts: $(SVN-PY_CONFLICTS)" >>$@

ifneq (,$(filter perl, $(PACKAGES)))
$(SVN-PL_IPK_DIR)/CONTROL/control:
	@install -d $(SVN-PL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: svn-pl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SVN_PRIORITY)" >>$@
	@echo "Section: $(SVN_SECTION)" >>$@
	@echo "Version: $(SVN_VERSION)-$(SVN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SVN_MAINTAINER)" >>$@
	@echo "Source: $(SVN_SITE)/$(SVN_SOURCE)" >>$@
	@echo "Description: $(SVN-PL_DESCRIPTION)" >>$@
	@echo "Depends: $(SVN-PL_DEPENDS)" >>$@
	@echo "Suggests: $(SVN-PL_SUGGESTS)" >>$@
	@echo "Conflicts: $(SVN-PL_CONFLICTS)" >>$@
endif

#
# This builds the IPK file.
#
# Binaries should be installed into $(SVN_IPK_DIR)/opt/sbin or $(SVN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SVN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SVN_IPK_DIR)/opt/etc/svn/...
# Documentation files should be installed in $(SVN_IPK_DIR)/opt/doc/svn/...
# Daemon startup scripts should be installed in $(SVN_IPK_DIR)/opt/etc/init.d/S??svn
#
# You may need to patch your application to make it use these locations.
#
ifneq (,$(filter perl, $(PACKAGES)))
$(SVN_IPK) $(SVN-PY_IPK) $(SVN_PL_IPK): $(SVN_BUILD_DIR)/.built $(SVN_BUILD_DIR)/.py-built $(SVN_BUILD_DIR)/.pl-built
else
$(SVN_IPK) $(SVN-PY_IPK): $(SVN_BUILD_DIR)/.built $(SVN_BUILD_DIR)/.py-built
endif
	rm -rf $(SVN_IPK_DIR) $(BUILD_DIR)/svn_*_$(TARGET_ARCH).ipk
	install -d $(SVN_IPK_DIR)/opt/lib/svn-python/libsvn
	$(MAKE) -C $(SVN_BUILD_DIR) DESTDIR=$(SVN_IPK_DIR) \
		external-install local-install $(SVN_INSTALL_SWIG_TARGETS)
	rm -f	$(SVN_IPK_DIR)/opt/lib/*.la \
		$(SVN_IPK_DIR)/opt/lib/svn-python/libsvn/*.la
	$(TARGET_STRIP) $(SVN_IPK_DIR)/opt/bin/*
	$(TARGET_STRIP) $(SVN_IPK_DIR)/opt/lib/*.so
	$(TARGET_STRIP) $(SVN_IPK_DIR)/opt/libexec/*.so
	$(TARGET_STRIP) $(SVN_IPK_DIR)/opt/lib/svn-python/libsvn/*.so
ifneq (,$(filter perl, $(PACKAGES)))
	for f in `find $(SVN_IPK_DIR)/opt/lib/perl5/ -type f -name '*.so'`; do \
		chmod +w $$f; \
		$(TARGET_STRIP) $$f; \
		chmod -w $$f; \
	done
	# mv to svn-pl
	rm -rf $(SVN-PL_IPK_DIR) $(BUILD_DIR)/svn-pl_*_$(TARGET_ARCH).ipk
	install -d $(SVN-PL_IPK_DIR)/opt/lib
	mv $(SVN_IPK_DIR)/opt/lib/perl5 $(SVN-PL_IPK_DIR)/opt/lib/
	mv $(SVN_IPK_DIR)/opt/lib/libsvn_swig_perl* $(SVN-PL_IPK_DIR)/opt/lib/
	install -d $(SVN-PL_IPK_DIR)/opt/man
	mv $(SVN_IPK_DIR)/opt/man/man3 $(SVN-PL_IPK_DIR)/opt/man/
	rm -f `find $(SVN-PL_IPK_DIR)/opt/lib/perl5/ -name perllocal.pod`
	# svn-pl ipk
	$(MAKE) $(SVN-PL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SVN-PL_IPK_DIR)
endif
	# mv to svn-py
	rm -rf $(SVN-PY_IPK_DIR) $(BUILD_DIR)/svn-py_*_$(TARGET_ARCH).ipk
	install -d $(SVN-PY_IPK_DIR)/opt/lib
	mv $(SVN_IPK_DIR)/opt/lib/svn-python $(SVN-PY_IPK_DIR)/opt/lib/
	mv $(SVN_IPK_DIR)/opt/lib/libsvn_swig_py* $(SVN-PY_IPK_DIR)/opt/lib/
	# svn ipk
	install -d $(SVN_IPK_DIR)/opt/etc/apache2/conf.d
	install -m 644 $(SVN_SOURCE_DIR)/mod_dav_svn.conf $(SVN_IPK_DIR)/opt/etc/apache2/conf.d/mod_dav_svn.conf
	$(MAKE) $(SVN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SVN_IPK_DIR)
	# svn-py ipk
	install -d $(SVN-PY_IPK_DIR)/opt/lib/python2.5/site-packages
	echo /opt/lib/svn-python > $(SVN-PY_IPK_DIR)/opt/lib/python2.5/site-packages/subversion.pth
	$(MAKE) $(SVN-PY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SVN-PY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
svn-ipk: $(SVN_IPK) $(SVN-PY_IPK) $(SVN-PL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
svn-clean:
	-$(MAKE) -C $(SVN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
svn-dirclean:
	rm -rf $(BUILD_DIR)/$(SVN_DIR) $(SVN_BUILD_DIR)
	rm -rf $(SVN_IPK_DIR) $(SVN_IPK)
	rm -rf $(SVN-PY_IPK_DIR) $(SVN-PY_IPK)
ifneq (,$(filter perl, $(PACKAGES)))
	rm -rf $(SVN-PL_IPK_DIR) $(SVN-PL_IPK)
endif

#
# Some sanity check for the package.
#
svn-check: $(SVN_IPK) $(SVN-PY_IPK) $(SVN_PL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) \
		$(SVN_IPK) $(SVN-PY_IPK) $(SVN-PL_IPK)
