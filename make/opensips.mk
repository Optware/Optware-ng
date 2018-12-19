###########################################################
#
# opensips
#
###########################################################
#
# OPENSIPS_VERSION, OPENSIPS_SITE and OPENSIPS_SOURCE define
# the upstream location of the source code for the package.
# OPENSIPS_DIR is the directory which is created when the source
# archive is unpacked.
# OPENSIPS_UNZIP is the command used to unzip the source.
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
OPENSIPS_SOURCE_TYPE=tarball
#OPENSIPS_SOURCE_TYPE=svn

OPENSIPS_BASE_VERSION=1.10.0

ifeq ($(OPENSIPS_SOURCE_TYPE), tarball)
OPENSIPS_VERSION=$(OPENSIPS_BASE_VERSION)
OPENSIPS_SITE=http://opensips.org/pub/opensips/$(OPENSIPS_VERSION)/src/
OPENSIPS_DIR=opensips-$(OPENSIPS_VERSION)
else
OPENSIPS_SVN=http://opensips.svn.sourceforge.net/svnroot/opensips/branches/1.7
#OPENSIPS_SVN=http://opensips.svn.sourceforge.net/svnroot/opensips/trunk
OPENSIPS_SVN_REV=8275
OPENSIPS_VERSION=$(OPENSIPS_BASE_VERSION)svn-r$(OPENSIPS_SVN_REV)
OPENSIPS_DIR=opensips
endif

OPENSIPS_SOURCE=opensips-$(OPENSIPS_VERSION)_src.tar.gz

OPENSIPS_UNZIP=zcat
OPENSIPS_MAINTAINER=Ovidiu Sas <osas@voipembedded.com>
OPENSIPS_DESCRIPTION=OpenSIPS Express Router
OPENSIPS_SECTION=util
OPENSIPS_PRIORITY=optional
OPENSIPS_DEPENDS=coreutils,openssl
OPENSIPS_BASE_SUGGESTS=radiusclient-ng,libxml2,unixodbc,postgresql,expat,net-snmp,confuse,openldap,libmicrohttpd
ifeq (mysql, $(filter mysql, $(PACKAGES)))
OPENSIPS_SUGGESTS=$(OPENSIPS_BASE_SUGGESTS),mysql
endif
OPENSIPS_CONFLICTS=

#
# OPENSIPS_IPK_VERSION should be incremented when the ipk changes.
#
ifeq ($(OPENSIPS_SOURCE_TYPE), tarball)
OPENSIPS_IPK_VERSION=4
else
OPENSIPS_IPK_VERSION=4
endif

#
# OPENSIPS_CONFFILES should be a list of user-editable files
OPENSIPS_CONFFILES=\
$(TARGET_PREFIX)/etc/opensips/opensips.cfg \
$(TARGET_PREFIX)/etc/opensips/opensipsctlrc

#
# OPENSIPS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#OPENSIPS_PATCHES=$(OPENSIPS_SOURCE_DIR)/

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OPENSIPS_CPPFLAGS=-fexpensive-optimizations -fomit-frame-pointer -fsigned-char

OPENSIPS_MAKEFLAGS=$(strip \
        $(if $(filter powerpc, $(TARGET_ARCH)), ARCH=ppc OS=linux, \
        $(if $(filter ts101, $(OPTWARE_TARGET)), ARCH=ppc OS=linux, \
        $(if $(filter slugosbe, $(OPTWARE_TARGET)), ARCH=arm OS=linux OSREL=2.6.16, \
        $(if $(filter mipsel, $(TARGET_ARCH)), ARCH=mips OS=linux OSREL=2.4.20, \
        $(if $(filter i386 i686, $(TARGET_ARCH)), ARCH=i386 OS=linux, \
        ARCH=$(TARGET_ARCH) OS=linux))))))

#
# Excluded modules:
# osp       - require "-losptk" or "-losp"
# mi_xmlrpc - requite xmlrpc
# seas      - it is not quite free ...
# perl      - issues on some platforms
# jabber    - moved to jabberd ???
# snmpstats - issues on tx72xx
# pua       - issues on mss, ddwrt, oleg (uclibc issues)
#
OPENSIPS_INCLUDE_PUA_MODULES=pua pua_mi pua_usrloc pua_bla pua_xmpp
OPENSIPS_INCLUDE_AAA_MODULES=auth_aaa aaa_radius
#OPENSIPS_INCLUDE_LDAP_MODULES=ldap h350
OPENSIPS_INCLUDE_LDAP_MODULES=ldap
OPENSIPS_INCLUDE_BASE_MODULES=presence presence_dialoginfo presence_mwi $(OPENSIPS_INCLUDE_PUA_MODULES) xmpp cpl-c db_http db_unixodbc db_postgres carrierroute b2b_logic rls xcap_client identity regex $(OPENSIPS_INCLUDE_AAA_MODULES) $(OPENSIPS_INCLUDE_LDAP_MODULES)
 
ifeq (mysql, $(filter mysql, $(PACKAGES)))
OPENSIPS_INCLUDE_MODULES=$(OPENSIPS_INCLUDE_BASE_MODULES) db_mysql
else
OPENSIPS_INCLUDE_MODULES=$(OPENSIPS_INCLUDE_BASE_MODULES)
endif

ifeq (geoip, $(filter geoip, $(PACKAGES)))
OPENSIPS_INCLUDE_MODULES=$(OPENSIPS_INCLUDE_BASE_MODULES) mmgeoip
else
OPENSIPS_INCLUDE_MODULES=$(OPENSIPS_INCLUDE_BASE_MODULES)
endif

OPENSIPS_EXCLUDE_MODULES=siptrace sipcapture cachedb_couchbase cachedb_memcached cachedb_cassandra cachedb_redis cachedb_mongodb db_berkeley db_oracle db_perlvdb event_rabbitmq identity jabber json ldap lua mi_xmlrpc osp perl perlvdb python h350 snmpstats sngtc
OPENSIPS_DEBUG_MODE=mode=debug

#
# OPENSIPS_BUILD_DIR is the directory in which the build is done.
# OPENSIPS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OPENSIPS_IPK_DIR is the directory in which the ipk is built.
# OPENSIPS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OPENSIPS_BUILD_DIR=$(BUILD_DIR)/opensips
OPENSIPS_SOURCE_DIR=$(SOURCE_DIR)/opensips
OPENSIPS_IPK_DIR=$(BUILD_DIR)/opensips-$(OPENSIPS_VERSION)-ipk
OPENSIPS_IPK=$(BUILD_DIR)/opensips_$(OPENSIPS_VERSION)-$(OPENSIPS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: opensips-source opensips-unpack opensips opensips-stage opensips-ipk opensips-clean opensips-dirclean opensips-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OPENSIPS_SOURCE):
ifeq ($(OPENSIPS_SOURCE_TYPE), tarball)
	$(WGET) -P $(@D) $(OPENSIPS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
else
	( cd $(BUILD_DIR) ; \
		rm -rf $(OPENSIPS_DIR) && \
		svn co -r $(OPENSIPS_SVN_REV) $(OPENSIPS_SVN) $(OPENSIPS_DIR) && \
		tar -czf $@ $(OPENSIPS_DIR) --exclude=.svn && \
		rm -rf $(OPENSIPS_DIR) \
	)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
opensips-source: $(DL_DIR)/$(OPENSIPS_SOURCE) $(OPENSIPS_PATCHES)

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
$(OPENSIPS_BUILD_DIR)/.configured: $(DL_DIR)/$(OPENSIPS_SOURCE) $(OPENSIPS_PATCHES) make/opensips.mk
	$(MAKE) openssl-stage radiusclient-ng-stage expat-stage libxml2-stage unixodbc-stage
	$(MAKE) postgresql-stage net-snmp-stage confuse-stage openldap-stage pcre-stage
	$(MAKE) libmicrohttpd-stage
ifeq (mysql, $(filter mysql, $(PACKAGES)))
	$(MAKE) mysql-stage
endif
ifeq (geoip, $(filter mysql, $(PACKAGES)))
	$(MAKE) geoip-stage
endif
	rm -rf $(BUILD_DIR)/$(OPENSIPS_DIR) $(OPENSIPS_BUILD_DIR)
	$(OPENSIPS_UNZIP) $(DL_DIR)/$(OPENSIPS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
ifeq ($(OPENSIPS_SOURCE_TYPE), tarball)
	if test -n "$(OPENSIPS_PATCHES)" ; \
		then cat $(OPENSIPS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(OPENSIPS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(OPENSIPS_DIR)-tls" != "$(OPENSIPS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(OPENSIPS_DIR)-tls $(OPENSIPS_BUILD_DIR) ; \
	fi
else
	if test -n "$(OPENSIPS_PATCHES)" ; \
		then cat $(OPENSIPS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(OPENSIPS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(OPENSIPS_DIR)" != "$(OPENSIPS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(OPENSIPS_DIR) $(OPENSIPS_BUILD_DIR) ; \
	fi
endif
	#####################
	# FIX for constants #
	#####################
	sed -i -e 's/LLONG_MIN/-9223372036854775807LL - 1LL/' \
           -e 's/LLONG_MAX/9223372036854775807LL/' $(@D)/db/db_ut.c
	#################################
	# FIX for ncurses in menuconfig #
	#################################
	sed -i -e 's/-lcurses/-lncurses/' $(@D)/menuconfig/Makefile

	touch $@

opensips-unpack: $(OPENSIPS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OPENSIPS_BUILD_DIR)/.built: $(OPENSIPS_BUILD_DIR)/.configured
	rm -f $@

	CC_EXTRA_OPTS="$(OPENSIPS_CPPFLAGS) $(STAGING_CPPFLAGS) -I$(TARGET_INCDIR)" \
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS)" \
	CROSS_COMPILE="$(TARGET_CROSS)" NICER=0\
	TLS=1 LOCALBASE=$(STAGING_PREFIX) SYSBASE=$(STAGING_PREFIX) CC="$(TARGET_CC) -std=gnu89" \
	$(MAKE) -C $(OPENSIPS_BUILD_DIR) $(OPENSIPS_MAKEFLAGS) $(OPENSIPS_DEBUG_MODE) \
	include_modules="$(OPENSIPS_INCLUDE_MODULES)" exclude_modules="$(OPENSIPS_EXCLUDE_MODULES)" prefix=$(TARGET_PREFIX) all
	touch $@

#
# This is the build convenience target.
#
opensips: $(OPENSIPS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OPENSIPS_BUILD_DIR)/.staged: $(OPENSIPS_BUILD_DIR)/.built
	rm -f $@
	touch $@

opensips-stage: $(OPENSIPS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/opensips
#
$(OPENSIPS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: opensips" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENSIPS_PRIORITY)" >>$@
	@echo "Section: $(OPENSIPS_SECTION)" >>$@
	@echo "Version: $(OPENSIPS_VERSION)-$(OPENSIPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENSIPS_MAINTAINER)" >>$@
	@echo "Source: $(OPENSIPS_SITE)/$(OPENSIPS_SOURCE)" >>$@
	@echo "Description: $(OPENSIPS_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENSIPS_DEPENDS)" >>$@
	@echo "Suggests: $(OPENSIPS_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENSIPS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/etc/opensips/...
# Documentation files should be installed in $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/doc/opensips/...
# Daemon startup scripts should be installed in $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??opensips
#
# You may need to patch your application to make it use these locations.
#
$(OPENSIPS_IPK): $(OPENSIPS_BUILD_DIR)/.built
	rm -rf $(OPENSIPS_IPK_DIR) $(BUILD_DIR)/opensips_*_$(TARGET_ARCH).ipk

	CC_EXTRA_OPTS="$(OPENSIPS_CPPFLAGS) $(STAGING_CPPFLAGS)" \
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	TLS=1 LOCALBASE=$(STAGING_PREFIX) SYSBASE=$(STAGING_PREFIX) CC="$(TARGET_CC)" \
	$(MAKE) -C $(OPENSIPS_BUILD_DIR) -j1 $(OPENSIPS_MAKEFLAGS) DESTDIR=$(OPENSIPS_IPK_DIR) \
	prefix=$(OPENSIPS_IPK_DIR)$(TARGET_PREFIX) cfg-prefix=$(OPENSIPS_IPK_DIR)$(TARGET_PREFIX) $(OPENSIPS_DEBUG_MODE) \
	include_modules="$(OPENSIPS_INCLUDE_MODULES)" exclude_modules="$(OPENSIPS_EXCLUDE_MODULES)" install

	$(MAKE) $(OPENSIPS_IPK_DIR)/CONTROL/control
	echo $(OPENSIPS_CONFFILES) | sed -e 's/ /\n/g' > $(OPENSIPS_IPK_DIR)/CONTROL/conffiles

	$(STRIP_COMMAND) $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/sbin/opensips
	$(STRIP_COMMAND) $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/sbin/opensipsunix
	$(STRIP_COMMAND) $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/sbin/osipsconfig

	if test -d $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/lib/opensips ; then \
		for f in `find $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/lib/opensips/modules -name '*.so'`; \
			do $(STRIP_COMMAND) $$f; done; \
		sed -i -e 's#$(OPENSIPS_IPK_DIR)##g' \
			$(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/lib/opensips/opensipsctl/opensipsctl.base; \
		sed -i -e 's#PATH=$$PATH:$(TARGET_PREFIX)/sbin/#PATH=$$PATH:$(TARGET_PREFIX)/sbin/:$(TARGET_PREFIX)/bin/#' \
			$(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/lib/opensips/opensipsctl/opensipsctl.base; \
		sed -i -e 's#$(OPENSIPS_IPK_DIR)##g' \
			$(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/lib/opensips/opensipsctl/opensipsdbctl.dbtext; \
		sed -i -e 's#$(OPENSIPS_IPK_DIR)##g' \
			$(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/lib/opensips/opensipsctl/opensipsdbctl.base; \
		sed -i -e 's#PATH=$$PATH:$(TARGET_PREFIX)/sbin/#PATH=$$PATH:$(TARGET_PREFIX)/sbin/:$(TARGET_PREFIX)/bin/#' \
			$(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/lib/opensips/opensipsctl/opensipsdbctl.base; \
	fi
	if test -d $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/lib64/opensips ; then \
		for f in `find $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/lib64/opensips/modules -name '*.so'`; \
			do $(STRIP_COMMAND) $$f; done; \
		sed -i -e 's#$(OPENSIPS_IPK_DIR)##g' \
			$(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/lib64/opensips/opensipsctl/opensipsctl.base; \
		sed -i -e 's#PATH=$$PATH:$(TARGET_PREFIX)/sbin/#PATH=$$PATH:$(TARGET_PREFIX)/sbin/:$(TARGET_PREFIX)/bin/#' \
			$(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/lib64/opensips/opensipsctl/opensipsctl.base; \
		sed -i -e 's#$(OPENSIPS_IPK_DIR)##g' \
			$(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/lib64/opensips/opensipsctl/opensipsdbctl.dbtext; \
		sed -i -e 's#$(OPENSIPS_IPK_DIR)##g' \
			$(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/lib64/opensips/opensipsctl/opensipsdbctl.base; \
		sed -i -e 's#PATH=$$PATH:$(TARGET_PREFIX)/sbin/#PATH=$$PATH:$(TARGET_PREFIX)/sbin/:$(TARGET_PREFIX)/bin/#' \
			$(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/lib64/opensips/opensipsctl/opensipsdbctl.base; \
	fi

	sed -i -e 's#$(OPENSIPS_IPK_DIR)##g' $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/sbin/opensipsdbctl
	sed -i -e 's#PATH=$$PATH:$(TARGET_PREFIX)/sbin/#PATH=$$PATH:$(TARGET_PREFIX)/sbin/:$(TARGET_PREFIX)/bin/#' $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/sbin/opensipsdbctl

	sed -i -e 's#$(OPENSIPS_IPK_DIR)##g' $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/sbin/opensipsctl
	sed -i -e 's#PATH=$$PATH:$(TARGET_PREFIX)/sbin/#PATH=$$PATH:$(TARGET_PREFIX)/sbin/:$(TARGET_PREFIX)/bin/#' $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/sbin/opensipsctl


	############################
	# $(INSTALL)ing example files #
	############################
	sed -i -e 's#$(OPENSIPS_IPK_DIR)##g' -e 's#/usr/local#$(TARGET_PREFIX)#g' $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/etc/opensips/opensips.cfg
	cp -r $(OPENSIPS_BUILD_DIR)/examples $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/etc/opensips/
	for f in $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/etc/opensips/*cfg ; do sed -i -e 's#$(OPENSIPS_IPK_DIR)##g' -e 's#/usr/local#$(TARGET_PREFIX)#g' $$f; done
	cp $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/etc/opensips/opensips.cfg $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/etc/opensips/examples
	cp $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/etc/opensips/opensipsctlrc $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/etc/opensips/examples

	####################
	# fixing man files #
	####################
	sed -i -e 's#$(OPENSIPS_IPK_DIR)##g' -e 's#/usr/local#$(TARGET_PREFIX)#g' $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/share/man/man8/opensips.8
	sed -i -e 's#$(OPENSIPS_IPK_DIR)##g' -e 's#/usr/local#$(TARGET_PREFIX)#g' $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/share/man/man8/opensipsunix.8
	sed -i -e 's#$(OPENSIPS_IPK_DIR)##g' -e 's#/usr/local#$(TARGET_PREFIX)#g' $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/share/man/man5/opensips.cfg.5
	for f in $(OPENSIPS_IPK_DIR)$(TARGET_PREFIX)/share/doc/opensips/README* ; do sed -i -e 's#$(OPENSIPS_IPK_DIR)##g' -e 's#/usr/local#$(TARGET_PREFIX)#g' $$f; done
	
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENSIPS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(OPENSIPS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
opensips-ipk: $(OPENSIPS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
opensips-clean:
	rm -f $(OPENSIPS_BUILD_DIR)/.built
	-$(MAKE) -C $(OPENSIPS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
opensips-dirclean:
	rm -rf $(BUILD_DIR)/$(OPENSIPS_DIR) $(OPENSIPS_BUILD_DIR) $(OPENSIPS_IPK_DIR) $(OPENSIPS_IPK)
#
#
# Some sanity check for the package.
#
opensips-check: $(OPENSIPS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OPENSIPS_IPK)
