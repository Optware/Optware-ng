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
#
PERL_SITE=http://ftp.funet.fi/pub/CPAN/src
PERL_VERSION=5.8.3
PERL_SOURCE=perl-$(PERL_VERSION).tar.gz
PERL_DIR=perl-$(PERL_VERSION)
PERL_UNZIP=zcat

#
# PERL_IPK_VERSION should be incremented when the ipk changes.
#
PERL_IPK_VERSION=1

#
# PERL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PERL_PATCHES=$(PERL_SOURCE_DIR)/configure.patch

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
PERL_IPK=$(BUILD_DIR)/perl_$(PERL_VERSION)-$(PERL_IPK_VERSION)_armeb.ipk

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
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR)
	$(PERL_UNZIP) $(DL_DIR)/$(PERL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL_PATCHES) | patch -d $(BUILD_DIR)/$(PERL_DIR) -p1
# Add that weird config stuff here
#
	mv $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR)
	cp -f $(PERL_SOURCE_DIR)/config $(PERL_BUILD_DIR)/Cross
	cp -f $(PERL_SOURCE_DIR)/config.sh-$(GNU_TARGET_NAME) $(PERL_BUILD_DIR)/Cross
	$(MAKE) -C $(PERL_BUILD_DIR)/Cross patch
#	(cd $(PERL_BUILD_DIR); \
#		$(TARGET_CONFIGURE_OPTS) \
#		CPPFLAGS="$(STAGING_CPPFLAGS) $(PERL_CPPFLAGS)" \
#		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_LDFLAGS)" \
#		./configure \
#		--build=$(GNU_HOST_NAME) \
#		--host=$(GNU_TARGET_NAME) \
#		--target=$(GNU_TARGET_NAME) \
#		--prefix=/opt \
#	)
	touch $(PERL_BUILD_DIR)/.configured

perl-unpack: $(PERL_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PERL_BUILD_DIR)/perl: $(PERL_BUILD_DIR)/.configured
	$(MAKE) -C $(PERL_BUILD_DIR)/Cross perl

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
perl: $(PERL_BUILD_DIR)/perl

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libperl.so.$(PERL_VERSION): $(PERL_BUILD_DIR)/libperl.so.$(PERL_VERSION)
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(PERL_BUILD_DIR)/perl.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(PERL_BUILD_DIR)/libperl.a $(STAGING_DIR)/opt/lib
	install -m 644 $(PERL_BUILD_DIR)/libperl.so.$(PERL_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libperl.so.$(PERL_VERSION) libperl.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libperl.so.$(PERL_VERSION) libperl.so

perl-stage: $(STAGING_DIR)/opt/lib/libperl.so.$(PERL_VERSION)

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
$(PERL_IPK): $(PERL_BUILD_DIR)/perl
	rm -rf $(PERL_IPK_DIR) $(PERL_IPK)
	install -d $(PERL_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(PERL_BUILD_DIR)/perl -o $(PERL_IPK_DIR)/opt/bin/perl
	install -d $(PERL_IPK_DIR)/opt/etc/init.d
	install -m 755 $(PERL_SOURCE_DIR)/rc.perl $(PERL_IPK_DIR)/opt/etc/init.d/SXXperl
	install -d $(PERL_IPK_DIR)/CONTROL
	install -m 644 $(PERL_SOURCE_DIR)/control $(PERL_IPK_DIR)/CONTROL/control
	install -m 644 $(PERL_SOURCE_DIR)/postinst $(PERL_IPK_DIR)/CONTROL/postinst
	install -m 644 $(PERL_SOURCE_DIR)/prerm $(PERL_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
perl-ipk: $(PERL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
perl-clean:
	-$(MAKE) -C $(PERL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
perl-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(PERL_BUILD_DIR) $(PERL_IPK_DIR) $(PERL_IPK)
