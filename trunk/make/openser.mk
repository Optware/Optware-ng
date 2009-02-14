###########################################################
#
# openser
#
###########################################################
#
# OPENSER_VERSION, OPENSER_SITE and OPENSER_SOURCE define
# the upstream location of the source code for the package.
# OPENSER_DIR is the directory which is created when the source
# archive is unpacked.
# OPENSER_UNZIP is the command used to unzip the source.
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
OPENSER_SOURCE_TYPE=tarball
#OPENSER_SOURCE_TYPE=svn

OPENSER_BASE_VERSION=1.3.4

ifeq ($(OPENSER_SOURCE_TYPE), tarball)
OPENSER_VERSION=$(OPENSER_BASE_VERSION)
OPENSER_SITE=http://www.kamailio.org/pub/kamailio/$(OPENSER_VERSION)/src/
OPENSER_DIR=openser-$(OPENSER_VERSION)
else
OPENSER_SVN=http://openser.svn.sourceforge.net/svnroot/openser/branches/1.3
#OPENSER_SVN=http://openser.svn.sourceforge.net/svnroot/openser/trunk
OPENSER_SVN_REV=3104
OPENSER_VERSION=$(OPENSER_BASE_VERSION)svn-r$(OPENSER_SVN_REV)
OPENSER_DIR=openser
endif

OPENSER_SOURCE=openser-$(OPENSER_VERSION)-tls_src.tar.gz

OPENSER_UNZIP=zcat
OPENSER_MAINTAINER=Ovidiu Sas <osas@voipembedded.com>
OPENSER_DESCRIPTION=OpenSIP Express Router
OPENSER_SECTION=util
OPENSER_PRIORITY=optional
OPENSER_DEPENDS=coreutils,openssl
OPENSER_BASE_SUGGESTS=radiusclient-ng,libxml2,unixodbc,postgresql,expat,net-snmp,perl,confuse
ifeq (mysql, $(filter mysql, $(PACKAGES)))
OPENSER_SUGGESTS=$(OPENSER_BASE_SUGGESTS),mysql
endif
OPENSER_CONFLICTS=

#
# OPENSER_IPK_VERSION should be incremented when the ipk changes.
#
ifeq ($(OPENSER_SOURCE_TYPE), tarball)
OPENSER_IPK_VERSION=1
else
OPENSER_IPK_VERSION=1
endif

#
# OPENSER_CONFFILES should be a list of user-editable files
OPENSER_CONFFILES=\
/opt/etc/openser/openser.cfg \
/opt/etc/openser/openserctlrc

#
# OPENSER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#OPENSER_PATCHES=$(OPENSER_SOURCE_DIR)/

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OPENSER_CPPFLAGS=-fexpensive-optimizations -fomit-frame-pointer -fsigned-char -DSTATS

# perl stuff
#
#PERLLDOPTS should be set to the output of
#perl -MExtUtils::Embed -e ldopts
#on the destination machine;
#
#PERLCCOPTS should be set to the output of
#perl -MExtUtils::Embed -e ccopts
#on the destination machine;
#
#TYPEMAP should be set to the full file name including path of your
#ExtUtils/typemap file.

OPENSER_MAKEFLAGS=$(strip \
        $(if $(filter powerpc, $(TARGET_ARCH)), ARCH=ppc OS=linux, \
        $(if $(filter ts101, $(OPTWARE_TARGET)), ARCH=ppc OS=linux, \
        $(if $(filter slugosbe, $(OPTWARE_TARGET)), ARCH=arm OS=linux OSREL=2.6.16, \
        $(if $(filter mipsel, $(TARGET_ARCH)), ARCH=mips OS=linux OSREL=2.4.20, \
        $(if $(filter i386 i686, $(TARGET_ARCH)), ARCH=i386 OS=linux, \
        ARCH=arm OS=linux OSREL=2.4.22))))))

#
# Excluded modules:
# pa        - unstable
# osp       - require "-losptk" or "-losp"
# mi_xmlrpc - requite xmlrpc
# seas      - it is not quite free ...
# perl      - issues on some platforms
# jabber    - moved to jabberd ???
# snmpstats - issues on tx72xx
# pua       - issues on mss, ddwrt, oleg (uclibc issues)
#
OPENSER_INCLUDE_BASE_MODULES=presence pua_mi pua_usrloc xmpp unixodbc auth_radius avp_radius group_radius uri_radius cpl-c postgres carrierroute

ifneq (, $(filter perl, $(PACKAGES)))
OPENSER_PERLLDOPTS=-fexpensive-optimizations -fomit-frame-pointer $(PERL_LDFLAGS) -L$(STAGING_LIB_DIR)/$(PERL_LIB_CORE_DIR) -lperl -lnsl -ldl -lm -lcrypt -lutil -lc -lgcc_s
OPENSER_PERLCCOPTS=-fexpensive-optimizations -fomit-frame-pointer -I$(STAGING_LIB_DIR)/$(PERL_LIB_CORE_DIR)
OPENSER_TYPEMAP=$(STAGING_LIB_DIR)/perl5/$(PERL_VERSION)/ExtUtils/typemap
OPENSER_INCLUDE_BASE_MODULES+= perl pua
endif

ifeq (mysql, $(filter mysql, $(PACKAGES)))
OPENSER_INCLUDE_MODULES=$(OPENSER_INCLUDE_BASE_MODULES) mysql
else
OPENSER_INCLUDE_MODULES=$(OPENSER_INCLUDE_BASE_MODULES)
endif

#OPENSER_EXCLUDE_MODULES=exclude_modules="seas mi_xmlrpc osp pa"
OPENSER_DEBUG_MODE=mode=debug

#
# OPENSER_BUILD_DIR is the directory in which the build is done.
# OPENSER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OPENSER_IPK_DIR is the directory in which the ipk is built.
# OPENSER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OPENSER_BUILD_DIR=$(BUILD_DIR)/openser
OPENSER_SOURCE_DIR=$(SOURCE_DIR)/openser
OPENSER_IPK_DIR=$(BUILD_DIR)/openser-$(OPENSER_VERSION)-ipk
OPENSER_IPK=$(BUILD_DIR)/openser_$(OPENSER_VERSION)-$(OPENSER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: openser-source openser-unpack openser openser-stage openser-ipk openser-clean openser-dirclean openser-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OPENSER_SOURCE):
ifeq ($(OPENSER_SOURCE_TYPE), tarball)
	$(WGET) -P $(@D) $(OPENSER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
else
	( cd $(BUILD_DIR) ; \
		rm -rf $(OPENSER_DIR) && \
		svn co -r $(OPENSER_SVN_REV) $(OPENSER_SVN) $(OPENSER_DIR) && \
		tar -czf $@ $(OPENSER_DIR) && \
		rm -rf $(OPENSER_DIR) \
	)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
openser-source: $(DL_DIR)/$(OPENSER_SOURCE) $(OPENSER_PATCHES)

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
$(OPENSER_BUILD_DIR)/.configured: $(DL_DIR)/$(OPENSER_SOURCE) $(OPENSER_PATCHES) make/openser.mk
	$(MAKE) openssl-stage radiusclient-ng-stage expat-stage libxml2-stage unixodbc-stage
	$(MAKE) postgresql-stage net-snmp-stage perl-stage confuse-stage
ifeq (mysql, $(filter mysql, $(PACKAGES)))
	$(MAKE) mysql-stage
endif
	rm -rf $(BUILD_DIR)/$(OPENSER_DIR) $(OPENSER_BUILD_DIR)
	$(OPENSER_UNZIP) $(DL_DIR)/$(OPENSER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
ifeq ($(OPENSER_SOURCE_TYPE), tarball)
	if test -n "$(OPENSER_PATCHES)" ; \
		then cat $(OPENSER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(OPENSER_DIR)-tls -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(OPENSER_DIR)" != "$(OPENSER_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(OPENSER_DIR)-tls $(OPENSER_BUILD_DIR) ; \
	fi
else
	if test -n "$(OPENSER_PATCHES)" ; \
		then cat $(OPENSER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(OPENSER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(OPENSER_DIR)" != "$(OPENSER_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(OPENSER_DIR) $(OPENSER_BUILD_DIR) ; \
	fi
endif
	touch $@

openser-unpack: $(OPENSER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OPENSER_BUILD_DIR)/.built: $(OPENSER_BUILD_DIR)/.configured
	rm -f $@

	CC_EXTRA_OPTS="$(OPENSER_CPPFLAGS) $(STAGING_CPPFLAGS)" \
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS)" \
	PERLLDOPTS="$(OPENSER_PERLLDOPTS)" PERLCCOPTS="$(OPENSER_PERLCCOPTS)" TYPEMAP="$(OPENSER_TYPEMAP)" \
	CROSS_COMPILE="true" \
	TLS=1 LOCALBASE=$(STAGING_DIR)/opt SYSBASE=$(STAGING_DIR)/opt CC="$(TARGET_CC)" \
	$(MAKE) -C $(OPENSER_BUILD_DIR) $(OPENSER_MAKEFLAGS) $(OPENSER_DEBUG_MODE) \
	include_modules="$(OPENSER_INCLUDE_MODULES)" $(OPENSER_EXCLUDE_MODULES) prefix=/opt all
	touch $@

#
# This is the build convenience target.
#
openser: $(OPENSER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OPENSER_BUILD_DIR)/.staged: $(OPENSER_BUILD_DIR)/.built
	rm -f $@
	touch $@

openser-stage: $(OPENSER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/openser
#
$(OPENSER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: openser" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENSER_PRIORITY)" >>$@
	@echo "Section: $(OPENSER_SECTION)" >>$@
	@echo "Version: $(OPENSER_VERSION)-$(OPENSER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENSER_MAINTAINER)" >>$@
	@echo "Source: $(OPENSER_SITE)/$(OPENSER_SOURCE)" >>$@
	@echo "Description: $(OPENSER_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENSER_DEPENDS)" >>$@
	@echo "Suggests: $(OPENSER_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENSER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OPENSER_IPK_DIR)/opt/sbin or $(OPENSER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OPENSER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OPENSER_IPK_DIR)/opt/etc/openser/...
# Documentation files should be installed in $(OPENSER_IPK_DIR)/opt/doc/openser/...
# Daemon startup scripts should be installed in $(OPENSER_IPK_DIR)/opt/etc/init.d/S??openser
#
# You may need to patch your application to make it use these locations.
#
$(OPENSER_IPK): $(OPENSER_BUILD_DIR)/.built
	rm -rf $(OPENSER_IPK_DIR) $(BUILD_DIR)/openser_*_$(TARGET_ARCH).ipk

	CC_EXTRA_OPTS="$(OPENSER_CPPFLAGS) $(STAGING_CPPFLAGS)" \
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS)" \
	PERLLDOPTS="$(OPENSER_PERLLDOPTS)" PERLCCOPTS="$(OPENSER_PERLCCOPTS)" TYPEMAP="$(OPENSER_TYPEMAP)" \
	CROSS_COMPILE="true" \
	TLS=1 LOCALBASE=$(STAGING_DIR)/opt SYSBASE=$(STAGING_DIR)/opt CC="$(TARGET_CC)" \
	$(MAKE) -C $(OPENSER_BUILD_DIR) $(OPENSER_MAKEFLAGS) DESTDIR=$(OPENSER_IPK_DIR) \
	prefix=$(OPENSER_IPK_DIR)/opt cfg-prefix=$(OPENSER_IPK_DIR)/opt $(OPENSER_DEBUG_MODE) \
	include_modules="$(OPENSER_INCLUDE_MODULES)" $(OPENSER_EXCLUDE_MODULES) install

	$(MAKE) $(OPENSER_IPK_DIR)/CONTROL/control
	echo $(OPENSER_CONFFILES) | sed -e 's/ /\n/g' > $(OPENSER_IPK_DIR)/CONTROL/conffiles

	for f in `find $(OPENSER_IPK_DIR)/opt/lib/openser/modules -name '*.so'`; do $(STRIP_COMMAND) $$f; done
	$(STRIP_COMMAND) $(OPENSER_IPK_DIR)/opt/sbin/openser
	$(STRIP_COMMAND) $(OPENSER_IPK_DIR)/opt/sbin/openserunix

	sed -i -e 's#$(OPENSER_IPK_DIR)##g' $(OPENSER_IPK_DIR)/opt/sbin/openserdbctl
	sed -i -e 's#PATH=$$PATH:/opt/sbin/#PATH=$$PATH:/opt/sbin/:/opt/bin/#' $(OPENSER_IPK_DIR)/opt/sbin/openserdbctl

	sed -i -e 's#$(OPENSER_IPK_DIR)##g' $(OPENSER_IPK_DIR)/opt/sbin/openserctl
	sed -i -e 's#PATH=$$PATH:/opt/sbin/#PATH=$$PATH:/opt/sbin/:/opt/bin/#' $(OPENSER_IPK_DIR)/opt/sbin/openserctl

	sed -i -e 's#$(OPENSER_IPK_DIR)##g' $(OPENSER_IPK_DIR)/opt/lib/openser/openserctl/openserctl.base
	sed -i -e 's#PATH=$$PATH:/opt/sbin/#PATH=$$PATH:/opt/sbin/:/opt/bin/#' $(OPENSER_IPK_DIR)/opt/lib/openser/openserctl/openserctl.base

	sed -i -e 's#$(OPENSER_IPK_DIR)##g' $(OPENSER_IPK_DIR)/opt/lib/openser/openserctl/openserdbctl.base
	sed -i -e 's#PATH=$$PATH:/opt/sbin/#PATH=$$PATH:/opt/sbin/:/opt/bin/#' $(OPENSER_IPK_DIR)/opt/lib/openser/openserctl/openserdbctl.base

	############################
	# installing example files #
	############################
	sed -i -e 's#$(OPENSER_IPK_DIR)##g' -e 's#/usr/local#/opt#g' $(OPENSER_IPK_DIR)/opt/etc/openser/openser.cfg
	cp -r $(OPENSER_BUILD_DIR)/examples $(OPENSER_IPK_DIR)/opt/etc/openser/
	for f in $(OPENSER_IPK_DIR)/opt/etc/openser/*cfg ; do sed -i -e 's#$(OPENSER_IPK_DIR)##g' -e 's#/usr/local#/opt#g' $$f; done
	cp $(OPENSER_IPK_DIR)/opt/etc/openser/openser.cfg $(OPENSER_IPK_DIR)/opt/etc/openser/examples
	cp $(OPENSER_IPK_DIR)/opt/etc/openser/openserctlrc $(OPENSER_IPK_DIR)/opt/etc/openser/examples

	############################
	# installing perl examples #
	############################
	mkdir $(OPENSER_IPK_DIR)/opt/etc/openser/examples/perl
	cp -r $(OPENSER_BUILD_DIR)/modules/perl/doc/samples/* $(OPENSER_IPK_DIR)/opt/etc/openser/examples/perl

	####################
	# fixing man files #
	####################
	sed -i -e 's#$(OPENSER_IPK_DIR)##g' -e 's#/usr/local#/opt#g' $(OPENSER_IPK_DIR)/opt/share/man/man8/openser.8
	sed -i -e 's#$(OPENSER_IPK_DIR)##g' -e 's#/usr/local#/opt#g' $(OPENSER_IPK_DIR)/opt/share/man/man8/openserunix.8
	sed -i -e 's#$(OPENSER_IPK_DIR)##g' -e 's#/usr/local#/opt#g' $(OPENSER_IPK_DIR)/opt/share/man/man5/openser.cfg.5
	for f in $(OPENSER_IPK_DIR)/opt/share/doc/openser/README* ; do sed -i -e 's#$(OPENSER_IPK_DIR)##g' -e 's#/usr/local#/opt#g' $$f; done
	
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENSER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
openser-ipk: $(OPENSER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
openser-clean:
	rm -f $(OPENSER_BUILD_DIR)/.built
	-$(MAKE) -C $(OPENSER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
openser-dirclean:
	rm -rf $(BUILD_DIR)/$(OPENSER_DIR) $(OPENSER_BUILD_DIR) $(OPENSER_IPK_DIR) $(OPENSER_IPK)
#
#
# Some sanity check for the package.
#
openser-check: $(OPENSER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OPENSER_IPK)
