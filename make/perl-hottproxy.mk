###########################################################
#
# perl-hottproxy
#
###########################################################
#
# PERL_HOTTPROXY_VERSION, PERL_HOTTPROXY_SITE and PERL_HOTTPROXY_SOURCE define
# the upstream location of the source code for the package.
# PERL_HOTTPROXY_DIR is the directory which is created when the source
# archive is unpacked.
# PERL_HOTTPROXY_UNZIP is the command used to unzip the source.
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
PERL_HOTTPROXY_SITE=http://www.hottproxy.org/downloads/
PERL_HOTTPROXY_VERSION=0.24.0.0
PERL_HOTTPROXY_SOURCE=HoTTProxy-Source-$(PERL_HOTTPROXY_VERSION).tar.gz
PERL_HOTTPROXY_DIR=perl-hottproxy-$(PERL_HOTTPROXY_VERSION)
PERL_HOTTPROXY_UNZIP=zcat
PERL_HOTTPROXY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL_HOTTPROXY_DESCRIPTION=HTTP proxy targeted specifically toward serving the needs of wireless Internet devices (cell phones, PDAs, etc.).
PERL_HOTTPROXY_SECTION=net
PERL_HOTTPROXY_PRIORITY=optional
PERL_HOTTPROXY_DEPENDS=perl
PERL_HOTTPROXY_SUGGESTS=
PERL_HOTTPROXY_CONFLICTS=

#
# PERL_HOTTPROXY_IPK_VERSION should be incremented when the ipk changes.
#
PERL_HOTTPROXY_IPK_VERSION=1

#
# PERL_HOTTPROXY_CONFFILES should be a list of user-editable files
PERL_HOTTPROXY_CONFFILES=/opt/share/hottproxy/HoTTProxy_Admin.conf /opt/share/hottproxy/HoTTProxy.conf
#/init.d/SXXperl-hottproxy

#
# PERL_HOTTPROXY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PERL_HOTTPROXY_PATCHES=$(PERL_HOTTPROXY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PERL_HOTTPROXY_CPPFLAGS=
PERL_HOTTPROXY_LDFLAGS=

#
# PERL_HOTTPROXY_BUILD_DIR is the directory in which the build is done.
# PERL_HOTTPROXY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PERL_HOTTPROXY_IPK_DIR is the directory in which the ipk is built.
# PERL_HOTTPROXY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PERL_HOTTPROXY_BUILD_DIR=$(BUILD_DIR)/perl-hottproxy
PERL_HOTTPROXY_SOURCE_DIR=$(SOURCE_DIR)/perl-hottproxy
PERL_HOTTPROXY_IPK_DIR=$(BUILD_DIR)/perl-hottproxy-$(PERL_HOTTPROXY_VERSION)-ipk
PERL_HOTTPROXY_IPK=$(BUILD_DIR)/perl-hottproxy_$(PERL_HOTTPROXY_VERSION)-$(PERL_HOTTPROXY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: perl-hottproxy-source perl-hottproxy-unpack perl-hottproxy perl-hottproxy-stage perl-hottproxy-ipk perl-hottproxy-clean perl-hottproxy-dirclean perl-hottproxy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PERL_HOTTPROXY_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL_HOTTPROXY_SITE)/$(PERL_HOTTPROXY_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PERL_HOTTPROXY_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
perl-hottproxy-source: $(DL_DIR)/$(PERL_HOTTPROXY_SOURCE) $(PERL_HOTTPROXY_PATCHES)

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
$(PERL_HOTTPROXY_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL_HOTTPROXY_SOURCE) $(PERL_HOTTPROXY_PATCHES) make/perl-hottproxy.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PERL_HOTTPROXY_DIR) $(PERL_HOTTPROXY_BUILD_DIR)
	install -d $(BUILD_DIR)/$(PERL_HOTTPROXY_DIR)
	$(PERL_HOTTPROXY_UNZIP) $(DL_DIR)/$(PERL_HOTTPROXY_SOURCE) | tar -C $(BUILD_DIR)/$(PERL_HOTTPROXY_DIR) -xvf -
	if test -n "$(PERL_HOTTPROXY_PATCHES)" ; \
		then cat $(PERL_HOTTPROXY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PERL_HOTTPROXY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PERL_HOTTPROXY_DIR)" != "$(PERL_HOTTPROXY_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(PERL_HOTTPROXY_DIR) $(PERL_HOTTPROXY_BUILD_DIR) ; \
	fi
#	(cd $(PERL_HOTTPROXY_BUILD_DIR); \
#		sed -i -e 's|HoTTProxy.conf|/opt/etc/HoTTProxy.conf|' \
#		HoTTProxy.pl HoTTProxy/UI.pm ; \
#		sed -i -e 's|HoTTProxy_Admin.conf|/opt/etc/HoTTProxy_Admin.conf|' \
#		HoTTProxy_Admin.pl ; \
#		sed -i -e 's|src=\\"/|src=\\"/HoTTProxy/|g' HoTTProxy/UI.pm ;\
#	)
#	$(PATCH_LIBTOOL) $(PERL_HOTTPROXY_BUILD_DIR)/libtool
	touch $@

perl-hottproxy-unpack: $(PERL_HOTTPROXY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PERL_HOTTPROXY_BUILD_DIR)/.built: $(PERL_HOTTPROXY_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(PERL_HOTTPROXY_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
perl-hottproxy: $(PERL_HOTTPROXY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PERL_HOTTPROXY_BUILD_DIR)/.staged: $(PERL_HOTTPROXY_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PERL_HOTTPROXY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-hottproxy-stage: $(PERL_HOTTPROXY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/perl-hottproxy
#
$(PERL_HOTTPROXY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-hottproxy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL_HOTTPROXY_PRIORITY)" >>$@
	@echo "Section: $(PERL_HOTTPROXY_SECTION)" >>$@
	@echo "Version: $(PERL_HOTTPROXY_VERSION)-$(PERL_HOTTPROXY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL_HOTTPROXY_MAINTAINER)" >>$@
	@echo "Source: $(PERL_HOTTPROXY_SITE)/$(PERL_HOTTPROXY_SOURCE)" >>$@
	@echo "Description: $(PERL_HOTTPROXY_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL_HOTTPROXY_DEPENDS)" >>$@
	@echo "Suggests: $(PERL_HOTTPROXY_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL_HOTTPROXY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PERL_HOTTPROXY_IPK_DIR)/opt/sbin or $(PERL_HOTTPROXY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PERL_HOTTPROXY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PERL_HOTTPROXY_IPK_DIR)/opt/etc/perl-hottproxy/...
# Documentation files should be installed in $(PERL_HOTTPROXY_IPK_DIR)/opt/doc/perl-hottproxy/...
# Daemon startup scripts should be installed in $(PERL_HOTTPROXY_IPK_DIR)/opt/etc/init.d/S??perl-hottproxy
#
# You may need to patch your application to make it use these locations.
#
$(PERL_HOTTPROXY_IPK): $(PERL_HOTTPROXY_BUILD_DIR)/.built
	rm -rf $(PERL_HOTTPROXY_IPK_DIR) $(BUILD_DIR)/perl-hottproxy_*_$(TARGET_ARCH).ipk
	install -d $(PERL_HOTTPROXY_IPK_DIR)/opt/share/hottproxy
	tar -c -C $(PERL_HOTTPROXY_BUILD_DIR) -f - . | tar -xv -C $(PERL_HOTTPROXY_IPK_DIR)/opt/share/hottproxy -f -
#	install -m 644 $(PERL_HOTTPROXY_SOURCE_DIR)/perl-hottproxy.conf $(PERL_HOTTPROXY_IPK_DIR)/opt/etc/perl-hottproxy.conf
#	install -d $(PERL_HOTTPROXY_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PERL_HOTTPROXY_SOURCE_DIR)/rc.perl-hottproxy $(PERL_HOTTPROXY_IPK_DIR)/opt/etc/init.d/SXXperl-hottproxy
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PERL_HOTTPROXY_IPK_DIR)/opt/etc/init.d/SXXperl-hottproxy
	$(MAKE) $(PERL_HOTTPROXY_IPK_DIR)/CONTROL/control
#	install -m 755 $(PERL_HOTTPROXY_SOURCE_DIR)/postinst $(PERL_HOTTPROXY_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PERL_HOTTPROXY_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PERL_HOTTPROXY_SOURCE_DIR)/prerm $(PERL_HOTTPROXY_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PERL_HOTTPROXY_IPK_DIR)/CONTROL/prerm
	echo $(PERL_HOTTPROXY_CONFFILES) | sed -e 's/ /\n/g' > $(PERL_HOTTPROXY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL_HOTTPROXY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
perl-hottproxy-ipk: $(PERL_HOTTPROXY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
perl-hottproxy-clean:
	rm -f $(PERL_HOTTPROXY_BUILD_DIR)/.built
	-$(MAKE) -C $(PERL_HOTTPROXY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
perl-hottproxy-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL_HOTTPROXY_DIR) $(PERL_HOTTPROXY_BUILD_DIR) $(PERL_HOTTPROXY_IPK_DIR) $(PERL_HOTTPROXY_IPK)
#
#
# Some sanity check for the package.
#
perl-hottproxy-check: $(PERL_HOTTPROXY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL_HOTTPROXY_IPK)
