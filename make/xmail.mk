###########################################################
#
# xmail
#
###########################################################

# You must replace "xmail" and "XMAIL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

# paulhar NOTES
# 1) When the package is removed, I can't understand why it doesn't remove
#    everything it installed. e.g /opt/var/MailRoot
# 2) For any form of logging to work syslogd needs replacing; the native one
#    doesn't appear to write any logs. This should be double-checked by someone
#    other than me since I've just replaced mine :)

#
# XMAIL_VERSION, XMAIL_SITE and XMAIL_SOURCE define
# the upstream location of the source code for the package.
# XMAIL_DIR is the directory which is created when the source
# archive is unpacked.
# XMAIL_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
XMAIL_SITE=http://www.xmailserver.org
XMAIL_VERSION=1.25
XMAIL_SOURCE=xmail-$(XMAIL_VERSION).tar.gz
XMAIL_DIR=xmail-$(XMAIL_VERSION)
XMAIL_UNZIP=zcat
XMAIL_MAINTAINER=Paul Hargreaves <paulhar@harg.ath.cx>
XMAIL_DESCRIPTION=A combined easy to configure SMTP, POP3 and Finger server.
XMAIL_SECTION=mail
XMAIL_PRIORITY=optional
XMAIL_DEPENDS=libstdc++, openssl
XMAIL_SUGGESTS=syslogd-ng
XMAIL_CONFLICTS=

#
# XMAIL_IPK_VERSION should be incremented when the ipk changes.
#
XMAIL_IPK_VERSION=4

#
# XMAIL_CONFFILES should be a list of user-editable files
#XMAIL_CONFFILES=/opt/etc/xmail.conf /opt/etc/init.d/S70xmail

#
# XMAIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# xmail.patch 
# 1. Lower the ulimit
# 2. Reduce the number of threads xmail uses
# 3. Change the hard-coded directory to MailRoot
XMAIL_PATCHES=\
	$(XMAIL_SOURCE_DIR)/xmail.patch \
	$(XMAIL_SOURCE_DIR)/conditionally-disable-ipv6.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XMAIL_CPPFLAGS=
ifeq ($(OPTWARE_TARGET), $(filter gumstix1151, $(OPTWARE_TARGET)))
XMAIL_CPPFLAGS += -DDISABLE_IPV6
endif
XMAIL_LDFLAGS=

#
# XMAIL_BUILD_DIR is the directory in which the build is done.
# XMAIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XMAIL_IPK_DIR is the directory in which the ipk is built.
# XMAIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XMAIL_BUILD_DIR=$(BUILD_DIR)/xmail
XMAIL_SOURCE_DIR=$(SOURCE_DIR)/xmail
XMAIL_IPK_DIR=$(BUILD_DIR)/xmail-$(XMAIL_VERSION)-ipk
XMAIL_IPK=$(BUILD_DIR)/xmail_$(XMAIL_VERSION)-$(XMAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XMAIL_SOURCE):
	$(WGET) -P $(@D) $(XMAIL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xmail-source: $(DL_DIR)/$(XMAIL_SOURCE) $(XMAIL_PATCHES)

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
$(XMAIL_BUILD_DIR)/.configured: $(DL_DIR)/$(XMAIL_SOURCE) $(XMAIL_PATCHES) make/xmail.mk
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(XMAIL_DIR) $(@D)
	$(XMAIL_UNZIP) $(DL_DIR)/$(XMAIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(XMAIL_PATCHES) | patch -d $(BUILD_DIR)/$(XMAIL_DIR) -p1
	mv $(BUILD_DIR)/$(XMAIL_DIR) $(@D)
	sed -i -e '/^LDFLAGS/s|$$(LDFLAGS) $$(SSLLIBS)|& $(STAGING_LDFLAGS) $(XMAIL_LDFLAGS)|' $(@D)/Makefile.lnx
	touch $@

xmail-unpack: $(XMAIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XMAIL_BUILD_DIR)/.built: $(XMAIL_BUILD_DIR)/.configured
	rm -f $@
ifneq ($(HOSTCC), $(TARGET_CC))
	$(MAKE) -C $(@D) -f Makefile.lnx CC=g++ LDFLAGS="" \
		bin bin/MkMachDep SysMachine.h
	cp $(XMAIL_SOURCE_DIR)/SysMachine.h $(@D)/
	if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/endianness.c | grep -q puts.*BIG_ENDIAN; \
	then sed -i -e 's/.*MACH_BIG_ENDIAN/#define MACH_BIG_ENDIAN/' $(@D)/SysMachine.h; \
	else sed -i -e 's/.*MACH_BIG_ENDIAN/#undef MACH_BIG_ENDIAN/' $(@D)/SysMachine.h; \
	fi
endif
	$(MAKE) -C $(@D) -f Makefile.lnx \
		$(TARGET_CONFIGURE_OPTS) \
		CC=$(TARGET_CXX) \
		LD=$(TARGET_CXX) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XMAIL_CPPFLAGS)" \
		WITH_SSL_INCLUDE=$(STAGING_INCLUDE_DIR)/openssl \
		WITH_SSL_LIB=$(STAGING_LIB_DIR) \
		;
	touch $@

#
# This is the build convenience target.
#
xmail: $(XMAIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(XMAIL_BUILD_DIR)/.staged: $(XMAIL_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#xmail-stage: $(XMAIL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/xmail
#
$(XMAIL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: xmail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XMAIL_PRIORITY)" >>$@
	@echo "Section: $(XMAIL_SECTION)" >>$@
	@echo "Version: $(XMAIL_VERSION)-$(XMAIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XMAIL_MAINTAINER)" >>$@
	@echo "Source: $(XMAIL_SITE)/$(XMAIL_SOURCE)" >>$@
	@echo "Description: $(XMAIL_DESCRIPTION)" >>$@
	@echo "Depends: $(XMAIL_DEPENDS)" >>$@
	@echo "Conflicts: $(XMAIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(XMAIL_IPK_DIR)/opt/sbin or $(XMAIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XMAIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XMAIL_IPK_DIR)/opt/etc/xmail/...
# Documentation files should be installed in $(XMAIL_IPK_DIR)/opt/doc/xmail/...
# Daemon startup scripts should be installed in $(XMAIL_IPK_DIR)/opt/etc/init.d/S??xmail
#
# You may need to patch your application to make it use these locations.
#
$(XMAIL_IPK): $(XMAIL_BUILD_DIR)/.built
	rm -rf $(XMAIL_IPK_DIR) $(BUILD_DIR)/xmail_*_$(TARGET_ARCH).ipk
	#$(MAKE) -C $(XMAIL_BUILD_DIR) DESTDIR=$(XMAIL_IPK_DIR) install
	# Main configuration and temporary stores - the MailRoot folder
	install -d $(XMAIL_IPK_DIR)/opt/var/MailRoot
	cp -R $(XMAIL_BUILD_DIR)/MailRoot/* $(XMAIL_IPK_DIR)/opt/var/MailRoot
	#chown root $(XMAIL_IPK_DIR)/opt/var/MailRoot
	#chgrp root $(XMAIL_IPK_DIR)/opt/var/MailRoot
	install -m 755 $(XMAIL_BUILD_DIR)/xmail $(XMAIL_IPK_DIR)/opt/var/MailRoot
	chmod 700 $(XMAIL_IPK_DIR)/opt/var/MailRoot
	# The binaries (/opt/bin)
	install -d $(XMAIL_IPK_DIR)/opt/bin
	install -m 755 $(XMAIL_BUILD_DIR)/bin/CtrlClnt $(XMAIL_IPK_DIR)/opt/bin
	install -m 700 $(XMAIL_BUILD_DIR)/bin/MkUsers $(XMAIL_IPK_DIR)/opt/bin
	install -m 700 $(XMAIL_BUILD_DIR)/bin/sendmail $(XMAIL_IPK_DIR)/opt/bin
	install -m 700 $(XMAIL_BUILD_DIR)/bin/XMail $(XMAIL_IPK_DIR)/opt/bin
	install -m 700 $(XMAIL_BUILD_DIR)/bin/XMCrypt $(XMAIL_IPK_DIR)/opt/bin
	# The docs (/opt/doc)
	install -d $(XMAIL_IPK_DIR)/opt/doc/xmail
	install -m 755 $(XMAIL_BUILD_DIR)/docs/Readme.txt $(XMAIL_IPK_DIR)/opt/doc/xmail
	install -m 755 $(XMAIL_BUILD_DIR)/docs/Readme.html $(XMAIL_IPK_DIR)/opt/doc/xmail
	# rc  (/opt/etc/init.d)
	# This is handled by the postinst script
	# Rest of the stuff
	$(MAKE) $(XMAIL_IPK_DIR)/CONTROL/control
	install -d $(XMAIL_IPK_DIR)/opt/etc/init.d
	install -m 644 $(XMAIL_SOURCE_DIR)/postinst $(XMAIL_IPK_DIR)/CONTROL/postinst
	install -m 644 $(XMAIL_SOURCE_DIR)/prerm $(XMAIL_IPK_DIR)/CONTROL/prerm
	# conf
	(cd $(XMAIL_BUILD_DIR)/MailRoot && \
	 find . -type f | \
	 grep -v xmailserver.test | \
	 sed 's|^\.|/opt/var/MailRoot|') > $(XMAIL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XMAIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xmail-ipk: $(XMAIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xmail-clean:
	-$(MAKE) -C $(XMAIL_BUILD_DIR) -f Makefile.lnx clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xmail-dirclean:
	rm -rf $(BUILD_DIR)/$(XMAIL_DIR) $(XMAIL_BUILD_DIR) $(XMAIL_IPK_DIR) $(XMAIL_IPK)

#
# Some sanity check for the package.
#
xmail-check: $(XMAIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(XMAIL_IPK)
