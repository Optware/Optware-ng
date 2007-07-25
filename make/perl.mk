###########################################################
#
# perl
#
###########################################################

#
# PERL_VERSION, PERL_SITE and PERL_SOURCE define
# the upstream location of the source code for the package.
# PERL_DIR is the directory which is created when the source
# archive is unpacked.
# PERL_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
PERL_SITE=http://ftp.funet.fi/pub/CPAN/src
PERL_VERSION=5.8.8
PERL_SOURCE=perl-$(PERL_VERSION).tar.gz
PERL_DIR=perl-$(PERL_VERSION)
PERL_UNZIP=zcat
PERL_PRIORITY=optional
PERL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL_SECTION=interpreters
PERL_DESCRIPTION=Practical Extraction and Report Language.
PERL_DEPENDS=libdb, gdbm
PERL_SUGGESTS=
PERL_CONFLICTS=

#
# PERL_IPK_VERSION should be incremented when the ipk changes.
#
PERL_IPK_VERSION=17

#
# PERL_CONFFILES should be a list of user-editable files
#PERL_CONFFILES=/opt/etc/perl.conf /opt/etc/init.d/SXXperl

#
# PERL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PERL_PATCHES=$(PERL_SOURCE_DIR)/Cross/Configure.patch
PERL_POST_CONFIGURE_PATCHES=$(PERL_SOURCE_DIR)/Makefile-pp_hot.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PERL_CPPFLAGS=
PERL_ARCH=$(strip \
    $(if $(filter openwrt-ixp4xx, $(OPTWARE_TARGET)), armv5teb-linux, \
    $(if $(filter armeb, $(TARGET_ARCH)), armv5b-linux, \
    $(if $(filter powerpc, $(TARGET_ARCH)), ppc-linux, \
    $(TARGET_ARCH)-linux))))
PERL_LDFLAGS="-Wl,-rpath,/opt/lib/perl5/$(PERL_VERSION)/$(PERL_ARCH)/CORE"

#
# PERL_BUILD_DIR is the directory in which the build is done.
# PERL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PERL_IPK_DIR is the directory in which the ipk is built.
# PERL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PERL_BUILD_DIR=$(BUILD_DIR)/perl
ifneq ($(HOSTCC), $(TARGET_CC))
PERL_HOST_BUILD_DIR=$(BUILD_DIR)/perl-host
PERL_HOST_MINIPERL=$(PERL_HOST_BUILD_DIR)/miniperl
PERL_HOSTPERL=$(PERL_HOST_BUILD_DIR)/perl
PERL_INC=PERL_INC=$(STAGING_LIB_DIR)/perl5/5.8.8/$(PERL_ARCH)/CORE
else
PERL_HOSTPERL=perl
PERL_INC=
endif
PERL_SOURCE_DIR=$(SOURCE_DIR)/perl
PERL_IPK_DIR=$(BUILD_DIR)/perl-$(PERL_VERSION)-ipk
PERL_IPK=$(BUILD_DIR)/perl_$(PERL_VERSION)-$(PERL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: perl-source perl-unpack perl perl-stage perl-ipk perl-clean perl-dirclean perl-check perl-hostperl

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PERL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL_SITE)/$(PERL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
perl-source: $(DL_DIR)/$(PERL_SOURCE) $(PERL_PATCHES)

ifneq ($(HOSTCC), $(TARGET_CC))
$(PERL_HOST_BUILD_DIR)/.hostbuilt: $(DL_DIR)/$(PERL_SOURCE) $(PERL_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(PERL_HOST_BUILD_DIR)
	$(PERL_UNZIP) $(DL_DIR)/$(PERL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PERL_PATCHES)" ; then \
		cat $(PERL_PATCHES) | patch -d $(BUILD_DIR)/$(PERL_DIR) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(PERL_DIR) $(PERL_HOST_BUILD_DIR) ; \
	(cd $(PERL_HOST_BUILD_DIR); \
		rm -f config.sh Policy.sh; \
		sh ./Configure -des \
			-Dinstallstyle='lib/perl5' \
			-Darchname=$(PERL_ARCH) \
			-Dstartperl='#!/opt/bin/perl' \
			-Dprefix=$(PERL_HOST_BUILD_DIR)/staging-install; \
		make install.perl; \
	)
	touch $(PERL_HOST_BUILD_DIR)/.hostbuilt

perl-hostperl: $(PERL_HOST_BUILD_DIR)/.hostbuilt
endif

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
ifeq ($(HOSTCC), $(TARGET_CC))
$(PERL_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL_SOURCE) $(PERL_PATCHES)
else
$(PERL_BUILD_DIR)/.configured: $(PERL_HOST_BUILD_DIR)/.hostbuilt
endif
	$(MAKE) libdb-stage gdbm-stage
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR)
	$(PERL_UNZIP) $(DL_DIR)/$(PERL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PERL_PATCHES)" ; then \
		cat $(PERL_PATCHES) | patch -d $(BUILD_DIR)/$(PERL_DIR) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR)
	sed -i -e '/LIBS/s|-L/usr/local/lib|-L$(STAGING_LIB_DIR)|' $(PERL_BUILD_DIR)/ext/*/Makefile.PL
	# Errno.PL is stupidly hardwired to only look for errno.h in /usr/include
	sed -i.orig \
		-e 's:/usr/include/errno.h:$(TARGET_INCDIR)/errno.h:g' \
		-e '/^# *warn/s:^#::' \
		-e 's:= $$Config{cppstdin}:= $(TARGET_CPP):' \
		$(PERL_BUILD_DIR)/ext/Errno/Errno_pm.PL
ifeq ($(HOSTCC), $(TARGET_CC))
	(cd $(PERL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PERL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_LDFLAGS)" \
		./Configure \
		-Dcc=gcc \
		-Dprefix=/opt \
		-de \
		-A clear:ignore_versioned_solibs \
	)
else
	ln -s $(PERL_HOST_MINIPERL) $(PERL_BUILD_DIR)/hostperl
	(cd $(PERL_BUILD_DIR)/Cross; \
		rm -f config; \
		printf "### Target Arch\nARCH = `echo $(GNU_TARGET_NAME) | sed s/-linux.*//`\n" > config; \
		printf "### Target OS\nOS = `echo $(GNU_TARGET_NAME) | sed s/.*-linux/linux/`\n" >> config; \
		( [ -e $(PERL_SOURCE_DIR)/Cross/config.sh-$(OPTWARE_TARGET) ] && \
		cp -f $(PERL_SOURCE_DIR)/Cross/config.sh-$(OPTWARE_TARGET) config.sh-$(GNU_TARGET_NAME) ) || \
		( [ -e $(PERL_SOURCE_DIR)/Cross/config.sh-$(GNU_TARGET_NAME) ] && \
		cp -f $(PERL_SOURCE_DIR)/Cross/config.sh-$(GNU_TARGET_NAME) . ) ; \
		cp -f $(PERL_SOURCE_DIR)/Cross/Makefile . ; \
		cp -f $(PERL_SOURCE_DIR)/Cross/Makefile.SH.patch . ; \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PERL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_LDFLAGS)" \
		PATH="`dirname $(TARGET_CC)`:$$PATH" \
		$(MAKE) patch perl_Configure; \
	)
endif
	if test -n "$(PERL_POST_CONFIGURE_PATCHES)" ; then \
		cat $(PERL_POST_CONFIGURE_PATCHES) | patch -d $(PERL_BUILD_DIR) -p0 ; \
	fi
	touch $(PERL_BUILD_DIR)/.configured

perl-unpack: $(PERL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PERL_BUILD_DIR)/.built: $(PERL_BUILD_DIR)/.configured
	rm -f $(PERL_BUILD_DIR)/.built
ifeq ($(HOSTCC), $(TARGET_CC))
	$(MAKE) -C $(PERL_BUILD_DIR)
else
	$(TARGET_CONFIGURE_OPTS) \
	CPPFLAGS="$(STAGING_CPPFLAGS) $(PERL_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(PERL_LDFLAGS)" \
	PATH="`dirname $(TARGET_CC)`:$(PERL_BUILD_DIR):$$PATH" \
		$(MAKE) -C $(PERL_BUILD_DIR)/Cross perl \
	PASTHRU_INC="$(STAGING_CPPFLAGS) $(PERL_CPPFLAGS)" \
	OTHERLDFLAGS="-L$(STAGING_LIB_DIR) -rpath /opt/lib" \

endif
	touch $(PERL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
perl: $(PERL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PERL_BUILD_DIR)/.staged: $(PERL_BUILD_DIR)/.built
	rm -f $(PERL_BUILD_DIR)/.staged
ifeq ($(HOSTCC), $(TARGET_CC))
	$(MAKE) -C $(PERL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install.perl
else
	PATH="`dirname $(TARGET_CC)`:$(PERL_BUILD_DIR):$$PATH" \
		$(MAKE) -C $(PERL_BUILD_DIR) DESTDIR=$(STAGING_DIR) INSTALL_DEPENDENCE="" install-strip
	for so in `find $(STAGING_DIR)/opt/lib/perl5/ -name '*.so'`; do \
		chmod u+w $$so; $(STRIP_COMMAND) $$so; done
endif
	(cd $(STAGING_DIR)/opt/bin; \
		rm -f perl; \
		ln -s perl$(PERL_VERSION) perl; \
	)
	touch $(PERL_BUILD_DIR)/.staged

perl-stage: $(PERL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/perl
#
$(PERL_IPK_DIR)/CONTROL/control:
	@install -d $(PERL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL_PRIORITY)" >>$@
	@echo "Section: $(PERL_SECTION)" >>$@
	@echo "Version: $(PERL_VERSION)-$(PERL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL_MAINTAINER)" >>$@
	@echo "Source: $(PERL_SITE)/$(PERL_SOURCE)" >>$@
	@echo "Description: $(PERL_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL_DEPENDS)" >>$@
	@echo "Suggests: $(PERL_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PERL_IPK_DIR)/opt/sbin or $(PERL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PERL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PERL_IPK_DIR)/opt/etc/perl/...
# Documentation files should be installed in $(PERL_IPK_DIR)/opt/doc/perl/...
# Daemon startup scripts should be installed in $(PERL_IPK_DIR)/opt/etc/init.d/S??perl
#
# You may need to patch your application to make it use these locations.
#
$(PERL_IPK): $(PERL_BUILD_DIR)/.built
	rm -rf $(PERL_IPK_DIR) $(BUILD_DIR)/perl_*_$(TARGET_ARCH).ipk
ifeq ($(HOSTCC), $(TARGET_CC))
	$(MAKE) -C $(PERL_BUILD_DIR) DESTDIR=$(PERL_IPK_DIR) install.perl
else
	PATH="`dirname $(TARGET_CC)`:$(PERL_BUILD_DIR):$$PATH" \
		$(MAKE) -C $(PERL_BUILD_DIR) DESTDIR=$(PERL_IPK_DIR) INSTALL_DEPENDENCE="" install-strip
	for so in `find $(PERL_IPK_DIR)/opt/lib/perl5/ -name '*.so'`; do \
		chmod u+w $$so; $(STRIP_COMMAND) $$so; done
endif
	(cd $(PERL_IPK_DIR)/opt/bin; \
		rm -f perl; \
		ln -s perl$(PERL_VERSION) perl; \
	)
ifeq ($(OPTWARE_WRITE_OUTSIDE_OPT_ALLOWED),true)
	install -d $(PERL_IPK_DIR)/usr/bin
	ln -s /opt/bin/perl $(PERL_IPK_DIR)/usr/bin/perl
endif
	$(MAKE) $(PERL_IPK_DIR)/CONTROL/control
	echo $(PERL_CONFFILES) | sed -e 's/ /\n/g' > $(PERL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
perl-ipk: $(PERL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
perl-clean:
	rm -f $(PERL_BUILD_DIR)/.built
	-$(MAKE) -C $(PERL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
perl-dirclean:
ifeq ($(HOSTCC), $(TARGET_CC))
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR) $(PERL_IPK_DIR) $(PERL_IPK)
else
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR) $(PERL_HOST_BUILD_DIR) $(PERL_IPK_DIR) $(PERL_IPK)
endif

#
#
# Some sanity check for the package.
#
perl-check: $(PERL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL_IPK)
