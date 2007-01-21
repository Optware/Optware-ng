###########################################################
#
# perl-assp
#
###########################################################
#
# PERL_ASSP_VERSION, PERL_ASSP_SITE and PERL_ASSP_SOURCE define
# the upstream location of the source code for the package.
# PERL_ASSP_DIR is the directory which is created when the source
# archive is unpacked.
# PERL_ASSP_UNZIP is the command used to unzip the source.
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
PERL_ASSP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/assp
PERL_ASSP_VERSION=1.2.6
PERL_ASSP_SOURCE=ASSP_$(PERL_ASSP_VERSION)-Install.zip
PERL_ASSP_DIR=ASSP
PERL_ASSP_UNZIP=unzip
PERL_ASSP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL_ASSP_DESCRIPTION=Anti-Spam SMTP Proxy Server
PERL_ASSP_SECTION=net
PERL_ASSP_PRIORITY=optional
PERL_ASSP_DEPENDS=perl, perl-compress-zlib, perl-digest-perl-md5, perl-time-hires
PERL_ASSP_SUGGESTS=
PERL_ASSP_CONFLICTS=

#
# PERL_ASSP_IPK_VERSION should be incremented when the ipk changes.
#
PERL_ASSP_IPK_VERSION=1

#
# PERL_ASSP_CONFFILES should be a list of user-editable files
# PERL_ASSP_CONFFILES=/opt/etc/perl-assp.conf /opt/etc/init.d/SXXperl-assp

#
# PERL_ASSP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# PERL_ASSP_PATCHES=$(PERL_ASSP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PERL_ASSP_CPPFLAGS=
PERL_ASSP_LDFLAGS=

#
# PERL_ASSP_BUILD_DIR is the directory in which the build is done.
# PERL_ASSP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PERL_ASSP_IPK_DIR is the directory in which the ipk is built.
# PERL_ASSP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PERL_ASSP_BUILD_DIR=$(BUILD_DIR)/perl-assp
PERL_ASSP_SOURCE_DIR=$(SOURCE_DIR)/perl-assp
PERL_ASSP_IPK_DIR=$(BUILD_DIR)/perl-assp-$(PERL_ASSP_VERSION)-ipk
PERL_ASSP_IPK=$(BUILD_DIR)/perl-assp_$(PERL_ASSP_VERSION)-$(PERL_ASSP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: perl-assp-source perl-assp-unpack perl-assp perl-assp-stage perl-assp-ipk perl-assp-clean perl-assp-dirclean perl-assp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PERL_ASSP_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL_ASSP_SITE)/$(PERL_ASSP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
perl-assp-source: $(DL_DIR)/$(PERL_ASSP_SOURCE) $(PERL_ASSP_PATCHES)



PERL_ASSP_USE_DOS2UNIX=   addservice.pl \
                assp.pl \
                changelog.txt \
                helpreport.txt \
                move2num.pl \
                nodelay.txt \
                notspamreport.txt \
                rebuildspamdb.pl \
                redre.txt \
                redremovereport.txt \
                redreport.txt \
                repair.pl \
                spamreport.txt \
                stat.pl \
                stats.sh \
                whiteremovereport.txt \
                whitereport.txt

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
$(PERL_ASSP_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL_ASSP_SOURCE) $(PERL_ASSP_PATCHES) make/perl-assp.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PERL_ASSP_DIR) $(PERL_ASSP_BUILD_DIR)
	cd $(BUILD_DIR) && $(PERL_ASSP_UNZIP) $(DL_DIR)/$(PERL_ASSP_SOURCE) ASSP/\*
#	| tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PERL_ASSP_PATCHES)" ; \
		then cat $(PERL_ASSP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PERL_ASSP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PERL_ASSP_DIR)" != "$(PERL_ASSP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(PERL_ASSP_DIR) $(PERL_ASSP_BUILD_DIR) ; \
	fi
	(cd $(PERL_ASSP_BUILD_DIR); \
		for f in $(PERL_ASSP_USE_DOS2UNIX); \
		  do sed -i -e 's/\r//g' -e 's|/usr/|/opt/|g' $${f} ;\
		done \
	)
	touch $(PERL_ASSP_BUILD_DIR)/.configured

perl-assp-unpack: $(PERL_ASSP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PERL_ASSP_BUILD_DIR)/.built: $(PERL_ASSP_BUILD_DIR)/.configured
	rm -f $(PERL_ASSP_BUILD_DIR)/.built
#	$(MAKE) -C $(PERL_ASSP_BUILD_DIR)
	touch $(PERL_ASSP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
perl-assp: $(PERL_ASSP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PERL_ASSP_BUILD_DIR)/.staged: $(PERL_ASSP_BUILD_DIR)/.built
	rm -f $(PERL_ASSP_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL_ASSP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL_ASSP_BUILD_DIR)/.staged

perl-assp-stage: $(PERL_ASSP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/perl-assp
#
$(PERL_ASSP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-assp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL_ASSP_PRIORITY)" >>$@
	@echo "Section: $(PERL_ASSP_SECTION)" >>$@
	@echo "Version: $(PERL_ASSP_VERSION)-$(PERL_ASSP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL_ASSP_MAINTAINER)" >>$@
	@echo "Source: $(PERL_ASSP_SITE)/$(PERL_ASSP_SOURCE)" >>$@
	@echo "Description: $(PERL_ASSP_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL_ASSP_DEPENDS)" >>$@
	@echo "Suggests: $(PERL_ASSP_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL_ASSP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PERL_ASSP_IPK_DIR)/opt/sbin or $(PERL_ASSP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PERL_ASSP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PERL_ASSP_IPK_DIR)/opt/etc/perl-assp/...
# Documentation files should be installed in $(PERL_ASSP_IPK_DIR)/opt/doc/perl-assp/...
# Daemon startup scripts should be installed in $(PERL_ASSP_IPK_DIR)/opt/etc/init.d/S??perl-assp
#
# You may need to patch your application to make it use these locations.
#
$(PERL_ASSP_IPK): $(PERL_ASSP_BUILD_DIR)/.built
	rm -rf $(PERL_ASSP_IPK_DIR) $(BUILD_DIR)/perl-assp_*_$(TARGET_ARCH).ipk
	install -d $(PERL_ASSP_IPK_DIR)/opt/lib/assp
	install -d $(PERL_ASSP_IPK_DIR)/opt/sbin
	install -m 755 $(PERL_ASSP_BUILD_DIR)/*.pl $(PERL_ASSP_IPK_DIR)/opt/lib/assp
	install -m 755 $(PERL_ASSP_BUILD_DIR)/stats.sh $(PERL_ASSP_IPK_DIR)/opt/lib/assp
	install -d $(PERL_ASSP_IPK_DIR)/opt/lib/assp
	install -m 755 $(PERL_ASSP_BUILD_DIR)/*.pl $(PERL_ASSP_IPK_DIR)/opt/lib/assp
	install -m 755 $(PERL_ASSP_BUILD_DIR)/stats.sh $(PERL_ASSP_IPK_DIR)/opt/lib/assp
	install -m 644 $(PERL_ASSP_BUILD_DIR)/nodelay.txt $(PERL_ASSP_IPK_DIR)/opt/lib/assp
	install -m 644 $(PERL_ASSP_BUILD_DIR)/redre.txt $(PERL_ASSP_IPK_DIR)/opt/lib/assp
	install -d $(PERL_ASSP_IPK_DIR)/opt/lib/assp/reports
	install -m 644 $(PERL_ASSP_BUILD_DIR)/*report.txt $(PERL_ASSP_IPK_DIR)/opt/lib/assp/reports
	install -d $(PERL_ASSP_IPK_DIR)/opt/lib/assp/images
	install -m 644 $(PERL_ASSP_BUILD_DIR)/images/* $(PERL_ASSP_IPK_DIR)/opt/lib/assp/images
	ln -s $(PERL_ASSP_IPK_DIR)/opt/lib/assp/assp.pl $(PERL_ASSP_IPK_DIR)/opt/sbin/assp
	ln -s $(PERL_ASSP_IPK_DIR)/opt/lib/assp/stats.sh $(PERL_ASSP_IPK_DIR)/opt/sbin/assplog
#	install -d $(PERL_ASSP_IPK_DIR)/opt/man/man8
#	install -m 644 $(PERL_ASSP_BUILD_DIR)/assp.8 $(PERL_ASSP_IPK_DIR)/opt/man/man8
#	install -m 644 $(PERL_ASSP_BUILD_DIR)/assplog.8 $(PERL_ASSP_IPK_DIR)/opt/man/man8
#	install -d $(PERL_ASSP_IPK_DIR)/opt/etc/
#	install -m 644 $(PERL_ASSP_SOURCE_DIR)/perl-assp.conf $(PERL_ASSP_IPK_DIR)/opt/etc/perl-assp.conf
#	install -d $(PERL_ASSP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PERL_ASSP_SOURCE_DIR)/rc.perl-assp $(PERL_ASSP_IPK_DIR)/opt/etc/init.d/SXXperl-assp
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXperl-assp
	$(MAKE) $(PERL_ASSP_IPK_DIR)/CONTROL/control
#	install -m 755 $(PERL_ASSP_SOURCE_DIR)/postinst $(PERL_ASSP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PERL_ASSP_SOURCE_DIR)/prerm $(PERL_ASSP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(PERL_ASSP_CONFFILES) | sed -e 's/ /\n/g' > $(PERL_ASSP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL_ASSP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
perl-assp-ipk: $(PERL_ASSP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
perl-assp-clean:
	rm -f $(PERL_ASSP_BUILD_DIR)/.built
	-$(MAKE) -C $(PERL_ASSP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
perl-assp-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL_ASSP_DIR) $(PERL_ASSP_BUILD_DIR) $(PERL_ASSP_IPK_DIR) $(PERL_ASSP_IPK)
#
#
# Some sanity check for the package.
#
perl-assp-check: $(PERL_ASSP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL_ASSP_IPK)
