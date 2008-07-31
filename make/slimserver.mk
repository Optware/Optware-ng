###########################################################
#
# slimserver
#
###########################################################

# You must replace "slimserver" and "SLIMSERVER" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SLIMSERVER_VERSION, SLIMSERVER_SITE and SLIMSERVER_SOURCE define
# the upstream location of the source code for the package.
# SLIMSERVER_DIR is the directory which is created when the source
# archive is unpacked.
# SLIMSERVER_UNZIP is the command used to unzip the source.
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
SLIMSERVER_VERSION=6.5.4
SLIMSERVER_SITE=http://www.slimdevices.com/downloads/SlimServer_v$(SLIMSERVER_VERSION)
SLIMSERVER_SOURCE=SlimServer_v$(SLIMSERVER_VERSION).no-cpan-arch.tar.gz
SLIMSERVER_DIR=SlimServer_v$(SLIMSERVER_VERSION)
SLIMSERVER_UNZIP=zcat
SLIMSERVER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SLIMSERVER_DESCRIPTION=Streaming Audio Server
SLIMSERVER_SECTION=sound
SLIMSERVER_PRIORITY=optional
SLIMSERVER_DEPENDS=perl, expat, adduser
SLIMSERVER_SUGGESTS=
SLIMSERVER_CONFLICTS=

ifneq ($(OPTWARE_TARGET),fsg3)
SLIMSERVER_DEPENDS+=, mysql
endif

#
# SLIMSERVER_IPK_VERSION should be incremented when the ipk changes.
#
SLIMSERVER_IPK_VERSION=12

#
# SLIMSERVER_CONFFILES should be a list of user-editable files
SLIMSERVER_CONFFILES=/opt/etc/slimserver.conf /opt/etc/init.d/S99slimserver \
	/opt/share/slimserver/MySQL/my.tt

#
# SLIMSERVER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SLIMSERVER_PATCHES=$(SLIMSERVER_SOURCE_DIR)/slimserver.pl.patch \
             $(SLIMSERVER_SOURCE_DIR)/scanner.pl.patch \
             $(SLIMSERVER_SOURCE_DIR)/build-perl-modules.pl.patch


#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
#SLIMSERVER_CPPFLAGS=
#SLIMSERVER_LDFLAGS=

#
# SLIMSERVER_BUILD_DIR is the directory in which the build is done.
# SLIMSERVER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SLIMSERVER_IPK_DIR is the directory in which the ipk is built.
# SLIMSERVER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SLIMSERVER_BUILD_DIR=$(BUILD_DIR)/slimserver
SLIMSERVER_SOURCE_DIR=$(SOURCE_DIR)/slimserver
SLIMSERVER_IPK_DIR=$(BUILD_DIR)/slimserver-$(SLIMSERVER_VERSION)-ipk
SLIMSERVER_IPK=$(BUILD_DIR)/slimserver_$(SLIMSERVER_VERSION)-$(SLIMSERVER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: slimserver-source slimserver-unpack slimserver slimserver-stage slimserver-ipk slimserver-clean slimserver-dirclean slimserver-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SLIMSERVER_SOURCE):
	$(WGET) -P $(@D) $(SLIMSERVER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
#slimserver-source: $(DL_DIR)/$(SLIMSERVER_SOURCE) $(SLIMSERVER_PATCHES)
slimserver-source: $(DL_DIR)/$(SLIMSERVER_SOURCE)

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
#
$(SLIMSERVER_BUILD_DIR)/.configured: $(DL_DIR)/$(SLIMSERVER_SOURCE) $(SLIMSERVER_PATCHES)  make/slimserver.mk
	$(MAKE) perl-stage expat-stage mysql-stage
	rm -rf $(BUILD_DIR)/$(SLIMSERVER_DIR) $(@D)
	$(SLIMSERVER_UNZIP) $(DL_DIR)/$(SLIMSERVER_SOURCE) | tar -C $(BUILD_DIR) -xvf -	
	if test -n "$(SLIMSERVER_PATCHES)" ; \
		then cat $(SLIMSERVER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SLIMSERVER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SLIMSERVER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SLIMSERVER_DIR) $(@D) ; \
	fi
	cp $(SLIMSERVER_SOURCE_DIR)/DBD-mysql-Makefile.PL $(@D)/
	sed -i  -e "s|^DBI_INSTARCH_DIR=.*|DBI_INSTARCH_DIR=$(@D)/temp/DBI-1.50/blib/arch/auto/DBI|" \
		-e "s|^DBI_DRIVER_XST=.*|DBI_DRIVER_XST=$(@D)/temp/DBI-1.50/blib/arch/auto/DBI/Driver.xst|" \
		$(@D)/DBD-mysql-Makefile.PL
	cp $(SLIMSERVER_SOURCE_DIR)/Time-HiRes-Makefile.PL $(@D)/
	sed -i -e "s|\$$Config{'ccflags'}|'$(STAGING_CPPFLAGS)'|" \
		-e "s|\$$Config{'cc'}|$(TARGET_CC)|" \
		$(@D)/Time-HiRes-Makefile.PL
	sed -i  -e "s|perlBinary = <STDIN>|perlBinary = \"$(PERL_HOSTPERL)\"|" \
		-e "s|slimServerPath = <STDIN>|slimServerPath = \"$(@D)\"|" \
		-e "s|downloadPath = <STDIN>|downloadPath = \"$(@D)\/temp\"|" \
		-e "s|downloadPath = <STDIN>|downloadPath = \"$(@D)\/temp\"|" \
		-e "/EXPAT.*PATH=/s|=/opt|$$ENV{STAGING_DIR}&|" \
		-e '/archname = $$2/a         $$archname =~ s|-uclibc||;' \
		-e 's/?view=auto/?view=co/g' \
		$(@D)/Bin/build-perl-modules.pl
	sed -i -e 's/^innodb_fast_shutdown/#innodb_fast_shutdown/' \
		$(@D)/MySQL/my.tt
	touch $@

slimserver-unpack: $(SLIMSERVER_BUILD_DIR)/.configured
#		-e "s|DBI-1.50|DBI-$(PERL-DBI_VERSION)|g" \

#
# This builds the actual binary.
#
$(SLIMSERVER_BUILD_DIR)/.built: $(SLIMSERVER_BUILD_DIR)/.configured
	rm -f $@
	( mkdir $(@D)/temp; cd $(@D)/Bin; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_INC) \
		STAGINGDIR="${STAGING_DIR}" \
		$(PERL_HOSTPERL) build-perl-modules.pl \
		PREFIX=/opt \
	)
	touch $@

#
# This is the build convenience target.
#
.PHONY: slimserver
slimserver: $(SLIMSERVER_BUILD_DIR)/.built
	touch $(@D)/.built


#
# If you are building a library, then you need to stage it too.
#
#$(SLIMSERVER_BUILD_DIR)/.staged: $(SLIMSERVER_BUILD_DIR)/.built
#	rm -f $(SLIMSERVER_BUILD_DIR)/.staged
#	$(MAKE) -C $(SLIMSERVER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $(SLIMSERVER_BUILD_DIR)/.staged
#
#slimserver-stage: $(SLIMSERVER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/slimserver
#
$(SLIMSERVER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: slimserver" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SLIMSERVER_PRIORITY)" >>$@
	@echo "Section: $(SLIMSERVER_SECTION)" >>$@
	@echo "Version: $(SLIMSERVER_VERSION)-$(SLIMSERVER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SLIMSERVER_MAINTAINER)" >>$@
	@echo "Source: $(SLIMSERVER_SITE)/$(SLIMSERVER_SOURCE)" >>$@
	@echo "Description: $(SLIMSERVER_DESCRIPTION)" >>$@
	@echo "Depends: $(SLIMSERVER_DEPENDS)" >>$@
	@echo "Suggests: $(SLIMSERVER_SUGGESTS)" >>$@
	@echo "Conflicts: $(SLIMSERVER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SLIMSERVER_IPK_DIR)/opt/sbin or $(SLIMSERVER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SLIMSERVER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SLIMSERVER_IPK_DIR)/opt/etc/slimserver/...
# Documentation files should be installed in $(SLIMSERVER_IPK_DIR)/opt/doc/slimserver/...
# Daemon startup scripts should be installed in $(SLIMSERVER_IPK_DIR)/opt/etc/init.d/S??slimserver
#
# You may need to patch your application to make it use these locations.
#
$(SLIMSERVER_IPK): $(SLIMSERVER_BUILD_DIR)/.built
	rm -rf $(SLIMSERVER_IPK_DIR) $(BUILD_DIR)/slimserver_*_$(TARGET_ARCH).ipk
	install -d $(SLIMSERVER_IPK_DIR)/opt/etc/
	install -d $(SLIMSERVER_IPK_DIR)/opt/bin/ $(SLIMSERVER_IPK_DIR)/opt/share/slimserver
#	install -m 755 $(SLIMSERVER_BUILD_DIR)/slimserver.pl $(SLIMSERVER_IPK_DIR)/opt/bin/slimserver
	cp -r $(SLIMSERVER_BUILD_DIR)/ $(SLIMSERVER_IPK_DIR)/opt/share
	rm -rf	$(SLIMSERVER_IPK_DIR)/opt/share/slimserver/.configured \
		$(SLIMSERVER_IPK_DIR)/opt/share/slimserver/.built
	rm -rf $(SLIMSERVER_IPK_DIR)/opt/share/slimserver/temp
	rm -rf $(SLIMSERVER_IPK_DIR)/opt/share/slimserver/Bin/i386-linux
# To comply with Licence - only Logitech/Slimdevices can include the firmware bin files
# in distribution. Slimserver will download bin files at startup.
	rm  $(SLIMSERVER_IPK_DIR)/opt/share/slimserver/Firmware/*.bin
	(cd  $(SLIMSERVER_IPK_DIR)/opt/share/slimserver/CPAN ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	install -m 755 $(SLIMSERVER_SOURCE_DIR)/slimserver.conf $(SLIMSERVER_IPK_DIR)/opt/etc/slimserver.conf
	install -d $(SLIMSERVER_IPK_DIR)/opt/etc/init.d
ifeq ($(OPTWARE_TARGET),fsg3)
	install -m 755 $(SLIMSERVER_SOURCE_DIR)/rc.slimserver.fsg3 $(SLIMSERVER_IPK_DIR)/opt/etc/init.d/S99slimserver
else
	install -m 755 $(SLIMSERVER_SOURCE_DIR)/rc.slimserver $(SLIMSERVER_IPK_DIR)/opt/etc/init.d/S99slimserver

endif
	ln -sf ../etc/init.d/S99slimserver $(SLIMSERVER_IPK_DIR)/opt/bin/slimserver
	$(MAKE) $(SLIMSERVER_IPK_DIR)/CONTROL/control
	install -m 755 $(SLIMSERVER_SOURCE_DIR)/slimserver.postinst $(SLIMSERVER_IPK_DIR)/CONTROL/postinst
	install -m 755 $(SLIMSERVER_SOURCE_DIR)/slimserver.prerm $(SLIMSERVER_IPK_DIR)/CONTROL/prerm
	install -m 755 $(SLIMSERVER_SOURCE_DIR)/slimserver.postrm $(SLIMSERVER_IPK_DIR)/CONTROL/postrm
	echo $(SLIMSERVER_CONFFILES) | sed -e 's/ /\n/g' > $(SLIMSERVER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SLIMSERVER_IPK_DIR)



#
# This is called from the top level makefile to create the IPK file.
#
slimserver-ipk: $(SLIMSERVER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
slimserver-clean:
	rm -f $(SLIMSERVER_BUILD_DIR)/.built
#	-$(MAKE) -C $(SLIMSERVER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
slimserver-dirclean:
	rm -rf $(BUILD_DIR)/$(SLIMSERVER_DIR) $(SLIMSERVER_BUILD_DIR) $(SLIMSERVER_IPK_DIR) $(SLIMSERVER_IPK)
#
#
# Some sanity check for the package.
#
slimserver-check: $(SLIMSERVER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SLIMSERVER_IPK)
