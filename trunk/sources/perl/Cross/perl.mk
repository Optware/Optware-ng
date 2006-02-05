###########################################################
#
# perl
#
###########################################################

# You must replace "perl" and "PERL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PERL_VERSION, PERL_SITE and PERL_SOURCE define
# the upstream location of the source code for the package.
# PERL_DIR is the directory which is created when the source
# archive is unpacked.
# PERL_UNZIP is the command used to unzip the source.
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
PERL_SITE=http://ftp.funet.fi/pub/CPAN/src
PERL_VERSION=5.8.7
PERL_SOURCE=perl-$(PERL_VERSION).tar.gz
PERL_DIR=perl-$(PERL_VERSION)
PERL_UNZIP=zcat
PERL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL_DESCRIPTION=Practical Extraction and Report Language.
PERL_SECTION=lang
PERL_PRIORITY=optional
PERL_DEPENDS=
PERL_SUGGESTS=
PERL_CONFLICTS=

#
# PERL_IPK_VERSION should be incremented when the ipk changes.
#
PERL_IPK_VERSION=1

#
# PERL_CONFFILES should be a list of user-editable files
#PERL_CONFFILES=/opt/etc/perl.conf /opt/etc/init.d/SXXperl

#
# PERL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PERL_PATCHES=$(PERL_SOURCE_DIR)/Cross/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PERL_CPPFLAGS=
PERL_LDFLAGS=-lm

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
PERL_HOST_BUILD_DIR=$(BUILD_DIR)/perl-host
PERL_HOSTPERL=$(PERL_HOST_BUILD_DIR)/staging-install/bin/perl
PERL_SOURCE_DIR=$(SOURCE_DIR)/perl
PERL_IPK_DIR=$(BUILD_DIR)/perl-$(PERL_VERSION)-ipk
PERL_IPK=$(BUILD_DIR)/perl_$(PERL_VERSION)-$(PERL_IPK_VERSION)_$(TARGET_ARCH).ipk

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

$(PERL_HOST_BUILD_DIR)/.hostbuilt: $(DL_DIR)/$(PERL_SOURCE)
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(PERL_HOST_BUILD_DIR)
	$(PERL_UNZIP) $(DL_DIR)/$(PERL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL_DIR) $(PERL_HOST_BUILD_DIR) ; \
	(cd $(PERL_HOST_BUILD_DIR); \
		rm -f config.sh Policy.sh; \
		sh ./Configure -des -Dprefix=$(PERL_HOST_BUILD_DIR)/staging-install; \
		make; \
		make install.perl; \
	)
	touch $(PERL_HOST_BUILD_DIR)/.hostbuilt

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
$(PERL_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL_SOURCE) $(PERL_PATCHES) $(PERL_HOST_BUILD_DIR)/.hostbuilt
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR)
	$(PERL_UNZIP) $(DL_DIR)/$(PERL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PERL_PATCHES)" ; then \
		cat $(PERL_PATCHES) | patch -d $(BUILD_DIR)/$(PERL_DIR) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR)
	ln -s $(PERL_HOSTPERL) $(PERL_BUILD_DIR)/hostperl
	(cd $(PERL_BUILD_DIR)/Cross; \
		cp -f $(PERL_SOURCE_DIR)/Cross/{config,config.sh-*-linux,Makefile.SH.patch} . ; \
		make patch; \
	)
#	$(PATCH_LIBTOOL) $(PERL_BUILD_DIR)/libtool
	touch $(PERL_BUILD_DIR)/.configured

perl-unpack: $(PERL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PERL_BUILD_DIR)/.built: $(PERL_BUILD_DIR)/.configured
	rm -f $(PERL_BUILD_DIR)/.built
	$(TARGET_CONFIGURE_OPTS) \
	CPPFLAGS="$(STAGING_CPPFLAGS) $(PERL_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(PERL_LDFLAGS)" \
	PATH="`dirname $(TARGET_CC)`:$(PERL_BUILD_DIR):$$PATH" \
		$(MAKE) -C $(PERL_BUILD_DIR)/Cross perl
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
	PATH="`dirname $(TARGET_CC)`:$(PERL_BUILD_DIR):$$PATH" \
		$(MAKE) -C $(PERL_BUILD_DIR) DESTDIR=$(PERL_IPK_DIR) INSTALL_DEPENDENCE="" install-strip
	(cd $(PERL_IPK_DIR)/opt/bin; \
		rm -f perl; \
		ln -s perl$(PERL_VERSION) perl; \
	)
	install -d $(PERL_IPK_DIR)/usr/bin
	ln -s /opt/bin/perl $(PERL_IPK_DIR)/usr/bin/perl
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
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR) $(PERL_HOST_BUILD_DIR) $(PERL_IPK_DIR) $(PERL_IPK)
