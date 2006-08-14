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
ifneq (,$(findstring :$(OPTWARE_TARGET):,$(PERL_CROSS_TARGETS)))
include $(SOURCE_DIR)/perl/Cross/perl.mk
else
PERL_SITE=http://ftp.funet.fi/pub/CPAN/src
PERL_VERSION=5.8.6
PERL_SOURCE=perl-$(PERL_VERSION).tar.gz
PERL_DIR=perl-$(PERL_VERSION)
PERL_UNZIP=zcat
PERL_PRIORITY=optional
PERL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL_SECTION=interpreters
PERL_DESCRIPTION=perl language interpreter

#
# PERL_IPK_VERSION should be incremented when the ipk changes.
#
PERL_IPK_VERSION=7

#
# PERL_CONFFILES should be a list of user-editable files
#PERL_CONFFILES=/opt/etc/perl.conf /opt/etc/init.d/SXXperl

#
# PERL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PERL_PATCHES=$(PERL_SOURCE_DIR)/Makefile-pp_hot.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PERL_CPPFLAGS=
PERL_LDFLAGS=

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
PERL_SOURCE_DIR=$(SOURCE_DIR)/perl
PERL_IPK_DIR=$(BUILD_DIR)/perl-$(PERL_VERSION)-ipk
PERL_IPK=$(BUILD_DIR)/perl_$(PERL_VERSION)-$(PERL_IPK_VERSION)_$(TARGET_ARCH).ipk

MICROPERL_BUILD_DIR=$(BUILD_DIR)/microperl
MICROPERL_SOURCE_DIR=$(SOURCE_DIR)/microperl
MICROPERL_IPK_DIR=$(BUILD_DIR)/microperl-$(PERL_VERSION)-ipk
MICROPERL_IPK=$(BUILD_DIR)/microperl_$(PERL_VERSION)-$(PERL_IPK_VERSION)_$(TARGET_ARCH).ipk

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
$(PERL_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL_SOURCE) $(PERL_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage # maybe add bdb here at some point
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR)
	$(PERL_UNZIP) $(DL_DIR)/$(PERL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR)
	# Errno.PL is stupidly hardwired to only look for errno.h in /usr/include
	cp $(PERL_BUILD_DIR)/ext/Errno/Errno_pm.PL $(PERL_BUILD_DIR)/ext/Errno/Errno_pm.PL.bak
	cat $(PERL_BUILD_DIR)/ext/Errno/Errno_pm.PL | \
	sed -e 's:/usr/include/errno.h:/opt/$(TARGET_ARCH)/$(GNU_TARGET_NAME)/include/errno.h:g'\
	> $(PERL_BUILD_DIR)/ext/Errno/tmp
	mv -f $(PERL_BUILD_DIR)/ext/Errno/tmp $(PERL_BUILD_DIR)/ext/Errno/Errno_pm.PL
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
	cat $(PERL_PATCHES) | patch -d $(PERL_BUILD_DIR) -p0
	touch $(PERL_BUILD_DIR)/.configured

perl-unpack: $(PERL_BUILD_DIR)/.configured

# the same for microperl

$(MICROPERL_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL_SOURCE) $(MICROPERL_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(MICROPERL_BUILD_DIR)
	$(PERL_UNZIP) $(DL_DIR)/$(PERL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL_DIR) $(MICROPERL_BUILD_DIR)
	touch $(MICROPERL_BUILD_DIR)/.configured

microperl-unpack: $(MICROPERL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PERL_BUILD_DIR)/.built: $(PERL_BUILD_DIR)/.configured
	rm -f $(PERL_BUILD_DIR)/.built
	$(MAKE) -C $(PERL_BUILD_DIR)
	touch $(PERL_BUILD_DIR)/.built

$(MICROPERL_BUILD_DIR)/.built: $(MICROPERL_BUILD_DIR)/.configured
	rm -f $(MICROPERL_BUILD_DIR)/.built
	$(MAKE) -C $(MICROPERL_BUILD_DIR) -f Makefile.micro CC=$(TARGET_CC) OPTIMIZE="$(TARGET_CFLAGS)"
	touch $(MICROPERL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
perl: $(PERL_BUILD_DIR)/.built
microperl: $(MICROPERL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PERL_BUILD_DIR)/.staged: $(PERL_BUILD_DIR)/.built
	rm -f $(PERL_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
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
	@echo "Conflicts: $(PERL_CONFLICTS)" >>$@

$(MICROPERL_IPK_DIR)/CONTROL/control:
	@install -d $(MICROPERL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: microperl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL_PRIORITY)" >>$@
	@echo "Section: $(PERL_SECTION)" >>$@
	@echo "Version: $(PERL_VERSION)-$(PERL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL_MAINTAINER)" >>$@
	@echo "Source: $(PERL_SITE)/$(PERL_SOURCE)" >>$@
	@echo "Description: $(PERL_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL_DEPENDS)" >>$@
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
	$(MAKE) -C $(PERL_BUILD_DIR) DESTDIR=$(PERL_IPK_DIR) install.perl
	rm -f $(PERL_IPK_DIR)/opt/bin/perl
	ln -s /opt/bin/perl$(PERL_VERSION) $(PERL_IPK_DIR)/opt/bin/perl
	install -d $(PERL_IPK_DIR)/usr/bin
	ln -s /opt/bin/perl $(PERL_IPK_DIR)/usr/bin/perl
	$(MAKE) $(PERL_IPK_DIR)/CONTROL/control
	echo $(PERL_CONFFILES) | sed -e 's/ /\n/g' > $(PERL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL_IPK_DIR)

$(MICROPERL_IPK): $(MICROPERL_BUILD_DIR)/.built
	rm -rf $(MICROPERL_IPK_DIR) $(BUILD_DIR)/microperl_*_$(TARGET_ARCH).ipk
	install -d $(MICROPERL_IPK_DIR)/opt/bin
	install -m 755 $(MICROPERL_BUILD_DIR)/microperl $(MICROPERL_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(MICROPERL_IPK_DIR)/opt/bin/*
	$(MAKE) $(MICROPERL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MICROPERL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
perl-ipk: $(PERL_IPK)

microperl-ipk: $(MICROPERL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
perl-clean:
	-$(MAKE) -C $(PERL_BUILD_DIR) clean

microperl-clean:
	-$(MAKE) -C $(MICROPERL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
perl-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR) $(PERL_IPK_DIR) $(PERL_IPK)

microperl-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(MICROPERL_BUILD_DIR) $(MICROPERL_IPK_DIR) $(MICROPERL_IPK)
endif
