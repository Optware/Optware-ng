###########################################################
#
# kamailio
#
###########################################################
#
# KAMAILIO_VERSION, KAMAILIO_SITE and KAMAILIO_SOURCE define
# the upstream location of the source code for the package.
# KAMAILIO_DIR is the directory which is created when the source
# archive is unpacked.
# KAMAILIO_UNZIP is the command used to unzip the source.
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


KAMAILIO_VERSION=4.1.1
KAMAILIO_SITE=http://kamailio.org/pub/kamailio/$(KAMAILIO_VERSION)/src/
KAMAILIO_DIR=kamailio-$(KAMAILIO_VERSION)

KAMAILIO_SOURCE=kamailio-$(KAMAILIO_VERSION)_src.tar.gz

KAMAILIO_UNZIP=zcat
KAMAILIO_MAINTAINER=Ovidiu Sas <osas@voipembedded.com>
KAMAILIO_DESCRIPTION=Kamailio SIP Express Router
KAMAILIO_SECTION=util
KAMAILIO_PRIORITY=optional
KAMAILIO_DEPENDS=coreutils,openssl,gawk
KAMAILIO_BASE_SUGGESTS=radiusclient-ng,libxml2,unixodbc,postgresql,expat,net-snmp,confuse,openldap
ifeq (mysql, $(filter mysql, $(PACKAGES)))
KAMAILIO_SUGGESTS=$(KAMAILIO_BASE_SUGGESTS),mysql
endif
ifeq (libunistring, $(filter libunistring, $(PACKAGES)))
KAMAILIO_SUGGESTS+=,libunistring
endif
KAMAILIO_CONFLICTS=

#
# KAMAILIO_IPK_VERSION should be incremented when the ipk changes.
#
KAMAILIO_IPK_VERSION=4

#
# KAMAILIO_CONFFILES should be a list of user-editable files
KAMAILIO_CONFFILES=\
$(TARGET_PREFIX)/etc/kamailio/kamailio.cfg \
$(TARGET_PREFIX)/etc/kamailio/kamctlrc \
$(TARGET_PREFIX)/etc/kamailio/dictionary.kamailio \
$(TARGET_PREFIX)/etc/kamailio/kamailio-selfsigned.key \
$(TARGET_PREFIX)/etc/kamailio/kamailio-selfsigned.pem \
$(TARGET_PREFIX)/etc/kamailio/pi_framework.xml \
$(TARGET_PREFIX)/etc/kamailio/tls.cfg

#
# KAMAILIO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#KAMAILIO_PATCHES=$(KAMAILIO_SOURCE_DIR)/

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
KAMAILIO_CPPFLAGS=-fexpensive-optimizations -fomit-frame-pointer -fsigned-char

KAMAILIO_MAKEFLAGS=$(strip \
        $(if $(filter powerpc, $(TARGET_ARCH)), ARCH=ppc OS=linux, \
        $(if $(filter ts101, $(OPTWARE_TARGET)), ARCH=ppc OS=linux, \
        $(if $(filter slugosbe, $(OPTWARE_TARGET)), ARCH=arm OS=linux OSREL=2.6.16, \
        $(if $(filter mipsel, $(TARGET_ARCH)), ARCH=mips OS=linux OSREL=2.4.20, \
        $(if $(filter i386 i686, $(TARGET_ARCH)), ARCH=i386 OS=linux, \
        $(if $(filter x86_64, $(TARGET_ARCH)), ARCH=x86_64 OS=linux, \
        ARCH=arm OS=linux OSREL=2.4.22)))))))
# disable IPV6 support
KAMAILIO_MAKEFLAGS+=DEFS_RM=-DUSE_IPV6

#KAMAILIO_NOISY_BUILD=Q=0

KAMAILIO_INCLUDE_PUA_MODULES=pua pua_bla pua_dialoginfo pua_mi pua_reginfo pua_usrloc pua_xmpp
KAMAILIO_INCLUDE_PRESENCE_MODULES=presence presence_conference presence_dialoginfo presence_mwi presence_profile presence_reginfo presence_xml presence_b2b
KAMAILIO_INCLUDE_AAA_MODULES=auth auth_ims auth_identity auth_db auth_diameter auth_radius auth_db auth_radius
KAMAILIO_INCLUDE_LDAP_MODULES=ldap
KAMAILIO_INCLUDE_BASE_MODULES=$(KAMAILIO_INCLUDE_PUA_MODULES) \
$(KAMAILIO_INCLUDE_PRESENCE_MODULES) \
$(KAMAILIO_INCLUDE_AAA_MODULES) \
$(KAMAILIO_INCLUDE_LDAP_MODULES) \
xmpp cpl-c db_unixodbc db_postgres carrierroute rls identity regex xmlops xcap_server tls xhttp_pi
KAMAILIO_EXCLUDE_APP_MODULES=app_lua app_mono app_perl app_python app_java
KAMAILIO_EXCLUDE_DB_MODULES=db_berkeley db_cassandra db_oracle db_perlvdb
# cdp: AI_ADDRCONFIG not defined
KAMAILIO_EXCLUDE_MODULES=$(KAMAILIO_EXCLUDE_APP_MODULES) $(KAMAILIO_EXCLUDE_DB_MODULES) bdb cdp siptrace sipcapture identity iptrtpproxy jabber json jsonrpc-c memcached ndb_redis osp h350 purple seas mi_xmlrpc dnssec sctp

ifeq (mysql, $(filter mysql, $(PACKAGES)))
KAMAILIO_INCLUDE_MODULES+=db_mysql
endif

ifeq (geoip, $(filter geoip, $(PACKAGES)))
KAMAILIO_INCLUDE_MODULES+=geoip
endif

KAMAILIO_INCLUDE_MODULES += $(KAMAILIO_INCLUDE_BASE_MODULES)

ifneq (libunistring, $(filter libunistring, $(PACKAGES)))
KAMAILIO_EXCLUDE_MODULES += websocket
endif

#
# KAMAILIO_BUILD_DIR is the directory in which the build is done.
# KAMAILIO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# KAMAILIO_IPK_DIR is the directory in which the ipk is built.
# KAMAILIO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
KAMAILIO_BUILD_DIR=$(BUILD_DIR)/kamailio
KAMAILIO_SOURCE_DIR=$(SOURCE_DIR)/kamailio
KAMAILIO_IPK_DIR=$(BUILD_DIR)/kamailio-$(KAMAILIO_VERSION)-ipk
KAMAILIO_IPK=$(BUILD_DIR)/kamailio_$(KAMAILIO_VERSION)-$(KAMAILIO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: kamailio-source kamailio-unpack kamailio kamailio-stage kamailio-ipk kamailio-clean kamailio-dirclean kamailio-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(KAMAILIO_SOURCE):
	$(WGET) -P $(@D) $(KAMAILIO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
kamailio-source: $(DL_DIR)/$(KAMAILIO_SOURCE) $(KAMAILIO_PATCHES)

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
$(KAMAILIO_BUILD_DIR)/.configured: $(DL_DIR)/$(KAMAILIO_SOURCE) $(KAMAILIO_PATCHES) make/kamailio.mk
	$(MAKE) openssl-stage radiusclient-ng-stage expat-stage libxml2-stage unixodbc-stage
	$(MAKE) postgresql-stage net-snmp-stage confuse-stage libcurl-stage openldap-stage pcre-stage
	$(MAKE) sqlite-stage
ifeq (mysql, $(filter mysql, $(PACKAGES)))
	$(MAKE) mysql-stage
endif
ifeq (geoip, $(filter geoip, $(PACKAGES)))
	$(MAKE) geoip-stage
endif
ifeq (libunistring, $(filter libunistring, $(PACKAGES)))
	$(MAKE) libunistring-stage
endif
	rm -rf $(BUILD_DIR)/$(KAMAILIO_DIR) $(KAMAILIO_BUILD_DIR)
	$(KAMAILIO_UNZIP) $(DL_DIR)/$(KAMAILIO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(KAMAILIO_PATCHES)" ; \
		then cat $(KAMAILIO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(KAMAILIO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(KAMAILIO_DIR)" != "$(KAMAILIO_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(KAMAILIO_DIR) $(KAMAILIO_BUILD_DIR) ; \
	fi
	case "$(GCC_VERSION)" in \
		4.0*|4.1*) \
			sed -i -e 's/-minline-all-stringops //' $(@D)/ccopts.sh $(@D)/Makefile.defs;; \
	esac
	sed -i -e 's/IPV6_TCLASS/67/' $(@D)/tcp_main.c
	sed -i -e 's/IPV6_TCLASS/67/' $(@D)/udp_server.c
	CC_EXTRA_OPTS="$(KAMAILIO_CPPFLAGS) $(STAGING_CPPFLAGS) -I$(TARGET_INCDIR)" \
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS)" CROSS_COMPILE="$(TARGET_CROSS)" \
	LOCALBASE=$(STAGING_PREFIX) SYSBASE=$(STAGING_PREFIX) CC="$(TARGET_CC)" \
	$(MAKE) $(KAMAILIO_NOISY_BUILD) -C $(KAMAILIO_BUILD_DIR) FLAVOUR=kamailio cfg $(KAMAILIO_MAKEFLAGS) \
	include_modules="$(KAMAILIO_INCLUDE_MODULES)" exclude_modules="$(KAMAILIO_EXCLUDE_MODULES)" prefix=$(TARGET_PREFIX) \
	modules_dirs="modules"
ifeq ($(OPTWARE_TARGET), $(filter buildroot-mipsel buildroot-mipsel-ng, $(OPTWARE_TARGET)))
	sed -i -e 's/-minline-all-stringops//' $(@D)/Makefile.defs
endif
	touch $@

kamailio-unpack: $(KAMAILIO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(KAMAILIO_BUILD_DIR)/.built: $(KAMAILIO_BUILD_DIR)/.configured
	rm -f $@

	CC_EXTRA_OPTS="$(KAMAILIO_CPPFLAGS) $(STAGING_CPPFLAGS) -I$(TARGET_INCDIR)" \
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS)" CROSS_COMPILE="$(TARGET_CROSS)" \
	LOCALBASE=$(STAGING_PREFIX) SYSBASE=$(STAGING_PREFIX) CC="$(TARGET_CC)" \
	$(MAKE) $(KAMAILIO_NOISY_BUILD) -C $(KAMAILIO_BUILD_DIR) $(KAMAILIO_MAKEFLAGS) \
	include_modules="$(KAMAILIO_INCLUDE_MODULES)" exclude_modules="$(KAMAILIO_EXCLUDE_MODULES)" prefix=$(TARGET_PREFIX) all \
	modules_dirs="modules"

	touch $@

#
# This is the build convenience target.
#
kamailio: $(KAMAILIO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(KAMAILIO_BUILD_DIR)/.staged: $(KAMAILIO_BUILD_DIR)/.built
	rm -f $@
	touch $@

kamailio-stage: $(KAMAILIO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/kamailio
#
$(KAMAILIO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: kamailio" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(KAMAILIO_PRIORITY)" >>$@
	@echo "Section: $(KAMAILIO_SECTION)" >>$@
	@echo "Version: $(KAMAILIO_VERSION)-$(KAMAILIO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(KAMAILIO_MAINTAINER)" >>$@
	@echo "Source: $(KAMAILIO_SITE)/$(KAMAILIO_SOURCE)" >>$@
	@echo "Description: $(KAMAILIO_DESCRIPTION)" >>$@
	@echo "Depends: $(KAMAILIO_DEPENDS)" >>$@
	@echo "Suggests: $(KAMAILIO_SUGGESTS)" >>$@
	@echo "Conflicts: $(KAMAILIO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/etc/kamailio/...
# Documentation files should be installed in $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/doc/kamailio/...
# Daemon startup scripts should be installed in $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??kamailio
#
# You may need to patch your application to make it use these locations.
#
$(KAMAILIO_IPK): $(KAMAILIO_BUILD_DIR)/.built
	rm -rf $(KAMAILIO_IPK_DIR) $(BUILD_DIR)/kamailio_*_$(TARGET_ARCH).ipk

	CC_EXTRA_OPTS="$(KAMAILIO_CPPFLAGS) $(STAGING_CPPFLAGS)" \
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS)" CROSS_COMPILE="$(TARGET_CROSS)" \
	LOCALBASE=$(STAGING_PREFIX) SYSBASE=$(STAGING_PREFIX) CC="$(TARGET_CC)" \
	$(MAKE) $(KAMAILIO_NOISY_BUILD) -C $(KAMAILIO_BUILD_DIR) $(KAMAILIO_MAKEFLAGS) -j1 \
	prefix=$(KAMAILIO_IPK_DIR)$(TARGET_PREFIX) cfg-prefix=$(KAMAILIO_IPK_DIR)$(TARGET_PREFIX) install

	if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/bits.c | grep -q puts.*64-bit; then \
		cd $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX) && \
		mv -f lib64 lib; \
	fi

	$(MAKE) $(KAMAILIO_IPK_DIR)/CONTROL/control
	echo $(KAMAILIO_CONFFILES) | sed -e 's/ /\n/g' > $(KAMAILIO_IPK_DIR)/CONTROL/conffiles

	for f in `find $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/lib/kamailio/modules -name '*.so'`; do $(STRIP_COMMAND) $$f; done
	for f in `find $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/lib/kamailio/modules_k -name '*.so'`; do $(STRIP_COMMAND) $$f; done
	for f in `find $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/lib/kamailio -name '*.so'`; do $(STRIP_COMMAND) $$f; done
	$(STRIP_COMMAND) $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/sbin/kamailio
	$(STRIP_COMMAND) $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/sbin/kamcmd

	sed -i -e 's#$(KAMAILIO_IPK_DIR)##g' $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/sbin/kamdbctl
	sed -i -e 's#PATH=$$PATH:$(TARGET_PREFIX)/sbin/#PATH=$$PATH:$(TARGET_PREFIX)/sbin/:$(TARGET_PREFIX)/bin/#' $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/sbin/kamdbctl

	sed -i -e 's#$(KAMAILIO_IPK_DIR)##g' $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/sbin/kamctl
	sed -i -e 's#PATH=$$PATH:$(TARGET_PREFIX)/sbin/#PATH=$$PATH:$(TARGET_PREFIX)/sbin/:$(TARGET_PREFIX)/bin/#' $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/sbin/kamctl

	sed -i -e 's#$(KAMAILIO_IPK_DIR)##g' $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/lib/kamailio/kamctl/kamctl.base
	sed -i -e 's#PATH=$$PATH:$(TARGET_PREFIX)/sbin/#PATH=$$PATH:$(TARGET_PREFIX)/sbin/:$(TARGET_PREFIX)/bin/#' $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/lib/kamailio/kamctl/kamctl.base

	sed -i -e 's#$(KAMAILIO_IPK_DIR)##g' $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/lib/kamailio/kamctl/kamdbctl.base
	sed -i -e 's#PATH=$$PATH:$(TARGET_PREFIX)/sbin/#PATH=$$PATH:$(TARGET_PREFIX)/sbin/:$(TARGET_PREFIX)/bin/#' $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/lib/kamailio/kamctl/kamdbctl.base

	############################
	# $(INSTALL)ing example files #
	############################
	sed -i -e 's#$(KAMAILIO_IPK_DIR)##g' -e 's#/usr/local#$(TARGET_PREFIX)#g' $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/etc/kamailio/kamailio.cfg
	cp -r $(KAMAILIO_BUILD_DIR)/examples $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/etc/kamailio/
	for f in $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/etc/kamailio/*cfg ; do sed -i -e 's#$(KAMAILIO_IPK_DIR)##g' -e 's#/usr/local#$(TARGET_PREFIX)#g' $$f; done
	cp $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/etc/kamailio/kamailio.cfg $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/etc/kamailio/examples
	cp $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/etc/kamailio/kamctlrc $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/etc/kamailio/examples

	####################
	# fixing man files #
	####################
	sed -i -e 's#$(KAMAILIO_IPK_DIR)##g' -e 's#/usr/local#$(TARGET_PREFIX)#g' $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/share/man/man8/kamailio.8
	sed -i -e 's#$(KAMAILIO_IPK_DIR)##g' -e 's#/usr/local#$(TARGET_PREFIX)#g' $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/share/man/man8/kamctl.8
	sed -i -e 's#$(KAMAILIO_IPK_DIR)##g' -e 's#/usr/local#$(TARGET_PREFIX)#g' $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/share/man/man8/kamdbctl.8
	sed -i -e 's#$(KAMAILIO_IPK_DIR)##g' -e 's#/usr/local#$(TARGET_PREFIX)#g' $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/share/man/man5/kamailio.cfg.5
	for f in $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/share/doc/kamailio/README* ; do sed -i -e 's#$(KAMAILIO_IPK_DIR)##g' -e 's#/usr/local#$(TARGET_PREFIX)#g' $$f; done
	sed -i -e 's#$(KAMAILIO_IPK_DIR)##g' -e 's#/usr/local#$(TARGET_PREFIX)#g' $(KAMAILIO_IPK_DIR)$(TARGET_PREFIX)/share/doc/kamailio/INSTALL

	cd $(BUILD_DIR); $(IPKG_BUILD) $(KAMAILIO_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(KAMAILIO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
kamailio-ipk: $(KAMAILIO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
kamailio-clean:
	rm -f $(KAMAILIO_BUILD_DIR)/.built
	-$(MAKE) -C $(KAMAILIO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
kamailio-dirclean:
	rm -rf $(BUILD_DIR)/$(KAMAILIO_DIR) $(KAMAILIO_BUILD_DIR) $(KAMAILIO_IPK_DIR) $(KAMAILIO_IPK)
#
#
# Some sanity check for the package.
#
kamailio-check: $(KAMAILIO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(KAMAILIO_IPK)
