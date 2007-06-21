###########################################################
#
# perl-device-serialport
#
###########################################################
#
# PERL-DEVICE-SERIALPORT_VERSION, PERL-DEVICE-SERIALPORT_SITE and PERL-DEVICE-SERIALPORT_SOURCE define
# the upstream location of the source code for the package.
# PERL-DEVICE-SERIALPORT_DIR is the directory which is created when the source
# archive is unpacked.
# PERL-DEVICE-SERIALPORT_UNZIP is the command used to unzip the source.
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
PERL-DEVICE-SERIALPORT_SITE=http://search.cpan.org/CPAN/authors/id/C/CO/COOK
PERL-DEVICE-SERIALPORT_VERSION=1.002001
PERL-DEVICE-SERIALPORT_SOURCE=Device-SerialPort-$(PERL-DEVICE-SERIALPORT_VERSION).tar.gz
PERL-DEVICE-SERIALPORT_DIR=Device-SerialPort-$(PERL-DEVICE-SERIALPORT_VERSION)
PERL-DEVICE-SERIALPORT_UNZIP=zcat
PERL-DEVICE-SERIALPORT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-DEVICE-SERIALPORT_DESCRIPTION=Device::SerialPort for serial port users.
PERL-DEVICE-SERIALPORT_SECTION=util
PERL-DEVICE-SERIALPORT_PRIORITY=optional
PERL-DEVICE-SERIALPORT_DEPENDS=perl
PERL-DEVICE-SERIALPORT_SUGGESTS=
PERL-DEVICE-SERIALPORT_CONFLICTS=

#
# PERL-DEVICE-SERIALPORT_IPK_VERSION should be incremented when the ipk changes.
#
PERL-DEVICE-SERIALPORT_IPK_VERSION=1

#
# PERL-DEVICE-SERIALPORT_CONFFILES should be a list of user-editable files
# PERL-DEVICE-SERIALPORT_CONFFILES=/opt/etc/perl-device-serialport.conf /opt/etc/init.d/SXXperl-device-serialport

#
# PERL-DEVICE-SERIALPORT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# PERL-DEVICE-SERIALPORT_PATCHES=$(PERL-DEVICE-SERIALPORT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PERL-DEVICE-SERIALPORT_CPPFLAGS=
PERL-DEVICE-SERIALPORT_LDFLAGS=

#
# PERL-DEVICE-SERIALPORT_BUILD_DIR is the directory in which the build is done.
# PERL-DEVICE-SERIALPORT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PERL-DEVICE-SERIALPORT_IPK_DIR is the directory in which the ipk is built.
# PERL-DEVICE-SERIALPORT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PERL-DEVICE-SERIALPORT_BUILD_DIR=$(BUILD_DIR)/perl-device-serialport
PERL-DEVICE-SERIALPORT_SOURCE_DIR=$(SOURCE_DIR)/perl-device-serialport
PERL-DEVICE-SERIALPORT_IPK_DIR=$(BUILD_DIR)/perl-device-serialport-$(PERL-DEVICE-SERIALPORT_VERSION)-ipk
PERL-DEVICE-SERIALPORT_IPK=$(BUILD_DIR)/perl-device-serialport_$(PERL-DEVICE-SERIALPORT_VERSION)-$(PERL-DEVICE-SERIALPORT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: perl-device-serialport-source perl-device-serialport-unpack perl-device-serialport perl-device-serialport-stage perl-device-serialport-ipk perl-device-serialport-clean perl-device-serialport-dirclean perl-device-serialport-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PERL-DEVICE-SERIALPORT_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-DEVICE-SERIALPORT_SITE)/$(PERL-DEVICE-SERIALPORT_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PERL-DEVICE-SERIALPORT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
perl-device-serialport-source: $(DL_DIR)/$(PERL-DEVICE-SERIALPORT_SOURCE) $(PERL-DEVICE-SERIALPORT_PATCHES)

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
$(PERL-DEVICE-SERIALPORT_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DEVICE-SERIALPORT_SOURCE) $(PERL-DEVICE-SERIALPORT_PATCHES) make/perl-device-serialport.mk
	rm -rf $(BUILD_DIR)/$(PERL-DEVICE-SERIALPORT_DIR) $(PERL-DEVICE-SERIALPORT_BUILD_DIR)
	$(PERL-DEVICE-SERIALPORT_UNZIP) $(DL_DIR)/$(PERL-DEVICE-SERIALPORT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PERL-DEVICE-SERIALPORT_PATCHES)" ; \
		then cat $(PERL-DEVICE-SERIALPORT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PERL-DEVICE-SERIALPORT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PERL-DEVICE-SERIALPORT_DIR)" != "$(PERL-DEVICE-SERIALPORT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(PERL-DEVICE-SERIALPORT_DIR) $(PERL-DEVICE-SERIALPORT_BUILD_DIR) ; \
	fi
	(cd $(PERL-DEVICE-SERIALPORT_BUILD_DIR); \
		echo '$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PERL-DEVICE-SERIALPORT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL-DEVICE-SERIALPORT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static ;' > configure.sh ; \
		chmod +x configure.sh ; \
		sed -i -e 's|./configure|./configure.sh|' Makefile.PL ;\
		$(TARGET_CONFIGURE_OPTS) \
                CPPFLAGS="$(STAGING_CPPFLAGS)" \
                LDFLAGS="$(STAGING_LDFLAGS)" \
                PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
                $(PERL_HOSTPERL) Makefile.PL -d \
                PREFIX=/opt \
	)
#	$(PATCH_LIBTOOL) $(PERL-DEVICE-SERIALPORT_BUILD_DIR)/libtool
	touch $@

perl-device-serialport-unpack: $(PERL-DEVICE-SERIALPORT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PERL-DEVICE-SERIALPORT_BUILD_DIR)/.built: $(PERL-DEVICE-SERIALPORT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PERL-DEVICE-SERIALPORT_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

#
# This is the build convenience target.
#
perl-device-serialport: $(PERL-DEVICE-SERIALPORT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PERL-DEVICE-SERIALPORT_BUILD_DIR)/.staged: $(PERL-DEVICE-SERIALPORT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PERL-DEVICE-SERIALPORT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-device-serialport-stage: $(PERL-DEVICE-SERIALPORT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/perl-device-serialport
#
$(PERL-DEVICE-SERIALPORT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-device-serialport" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-DEVICE-SERIALPORT_PRIORITY)" >>$@
	@echo "Section: $(PERL-DEVICE-SERIALPORT_SECTION)" >>$@
	@echo "Version: $(PERL-DEVICE-SERIALPORT_VERSION)-$(PERL-DEVICE-SERIALPORT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-DEVICE-SERIALPORT_MAINTAINER)" >>$@
	@echo "Source: $(PERL-DEVICE-SERIALPORT_SITE)/$(PERL-DEVICE-SERIALPORT_SOURCE)" >>$@
	@echo "Description: $(PERL-DEVICE-SERIALPORT_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-DEVICE-SERIALPORT_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-DEVICE-SERIALPORT_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-DEVICE-SERIALPORT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PERL-DEVICE-SERIALPORT_IPK_DIR)/opt/sbin or $(PERL-DEVICE-SERIALPORT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PERL-DEVICE-SERIALPORT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PERL-DEVICE-SERIALPORT_IPK_DIR)/opt/etc/perl-device-serialport/...
# Documentation files should be installed in $(PERL-DEVICE-SERIALPORT_IPK_DIR)/opt/doc/perl-device-serialport/...
# Daemon startup scripts should be installed in $(PERL-DEVICE-SERIALPORT_IPK_DIR)/opt/etc/init.d/S??perl-device-serialport
#
# You may need to patch your application to make it use these locations.
#
$(PERL-DEVICE-SERIALPORT_IPK): $(PERL-DEVICE-SERIALPORT_BUILD_DIR)/.built
	rm -rf $(PERL-DEVICE-SERIALPORT_IPK_DIR) $(BUILD_DIR)/perl-device-serialport_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DEVICE-SERIALPORT_BUILD_DIR) DESTDIR=$(PERL-DEVICE-SERIALPORT_IPK_DIR) install
	find $(PERL-DEVICE-SERIALPORT_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DEVICE-SERIALPORT_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DEVICE-SERIALPORT_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-DEVICE-SERIALPORT_IPK_DIR)/CONTROL/control
	echo $(PERL-DEVICE-SERIALPORT_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DEVICE-SERIALPORT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DEVICE-SERIALPORT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
perl-device-serialport-ipk: $(PERL-DEVICE-SERIALPORT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
perl-device-serialport-clean:
	rm -f $(PERL-DEVICE-SERIALPORT_BUILD_DIR)/.built
	-$(MAKE) -C $(PERL-DEVICE-SERIALPORT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
perl-device-serialport-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DEVICE-SERIALPORT_DIR) $(PERL-DEVICE-SERIALPORT_BUILD_DIR) $(PERL-DEVICE-SERIALPORT_IPK_DIR) $(PERL-DEVICE-SERIALPORT_IPK)
#
#
# Some sanity check for the package.
#
perl-device-serialport-check: $(PERL-DEVICE-SERIALPORT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-DEVICE-SERIALPORT_IPK)
