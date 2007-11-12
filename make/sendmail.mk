###########################################################
#
# sendmail
#
###########################################################

SENDMAIL_SITE=ftp://ftp.sendmail.org/pub/sendmail
SENDMAIL_VERSION=8.14.2
SENDMAIL_SOURCE=sendmail.$(SENDMAIL_VERSION).tar.gz
SENDMAIL_DIR=sendmail-$(SENDMAIL_VERSION)
SENDMAIL_UNZIP=zcat
SENDMAIL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SENDMAIL_DESCRIPTION=The most classic SMTP server.
SENDMAIL_SECTION=network
SENDMAIL_PRIORITY=optional
SENDMAIL_DEPENDS=procmail, openssl, libdb
SENDMAIL_SUGGESTS=
SENDMAIL_CONFLICTS=postfix

#
# SENDMAIL_IPK_VERSION should be incremented when the ipk changes.
#
SENDMAIL_IPK_VERSION=1

#
# SENDMAIL_CONFFILES should be a list of user-editable files
SENDMAIL_CONFFILES=\
	/opt/etc/mail/aliases \
	/opt/etc/mail/local-host-names \
	/opt/etc/mail/helpfile \
	/opt/etc/mail/relay-domains \
	/opt/etc/mail/sendmail.cf \
	/opt/etc/mail/submit.cf \
	/opt/etc/init.d/S69sendmail

#
# SENDMAIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# uClibc 0.9.28 is missing dn_skipname and other resolver functions
# Alternatively this could be solved by using bind-stage
ifeq ($(LIBC_STYLE), uclibc)
SENDMAIL_PATCHES=$(SENDMAIL_SOURCE_DIR)/config-uClibc.patch
else
SENDMAIL_PATCHES=$(SENDMAIL_SOURCE_DIR)/config.patch
endif
SENDMAIL_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/openssl
#SENDMAIL_LDFLAGS=

#
# SENDMAIL_BUILD_DIR is the directory in which the build is done.
# SENDMAIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SENDMAIL_IPK_DIR is the directory in which the ipk is built.
# SENDMAIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SENDMAIL_BUILD_DIR=$(BUILD_DIR)/sendmail
SENDMAIL_SOURCE_DIR=$(SOURCE_DIR)/sendmail
SENDMAIL_IPK_DIR=$(BUILD_DIR)/sendmail-$(SENDMAIL_VERSION)-ipk
SENDMAIL_IPK=$(BUILD_DIR)/sendmail_$(SENDMAIL_VERSION)-$(SENDMAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SENDMAIL_SOURCE):
	$(WGET) -P $(DL_DIR) $(SENDMAIL_SITE)/$(SENDMAIL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sendmail-source: $(DL_DIR)/$(SENDMAIL_SOURCE) $(SENDMAIL_PATCHES)

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
$(SENDMAIL_BUILD_DIR)/.configured: $(DL_DIR)/$(SENDMAIL_SOURCE) $(SENDMAIL_PATCHES) make/sendmail.mk
	$(MAKE) openssl-stage
	$(MAKE) libdb-stage
	rm -rf $(BUILD_DIR)/$(SENDMAIL_DIR) $(SENDMAIL_BUILD_DIR)
	$(SENDMAIL_UNZIP) $(DL_DIR)/$(SENDMAIL_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(SENDMAIL_PATCHES)" ; then  \
		cat $(SENDMAIL_PATCHES) |\
		patch -d "$(BUILD_DIR)/$(SENDMAIL_DIR)"  -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SENDMAIL_DIR)" != "$(SENDMAIL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SENDMAIL_DIR) $(SENDMAIL_BUILD_DIR) ; \
	fi
	touch $(SENDMAIL_BUILD_DIR)/.configured

sendmail-unpack: $(SENDMAIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SENDMAIL_BUILD_DIR)/.built: $(SENDMAIL_BUILD_DIR)/.configured
	rm -f $(SENDMAIL_BUILD_DIR)/.built
	$(MAKE) -C $(SENDMAIL_BUILD_DIR) \
		CC=$(TARGET_CC)	CCLINK=$(TARGET_CC) \
	CCOPTS="-D_PATH_SENDMAILCF=\\\"/opt/etc/mail/sendmail.cf\\\" -I$(STAGING_INCLUDE_DIR) $(SENDMAIL_CPPFLAGS)" \
		LIBDIRS="-L$(STAGING_LIB_DIR) -Wl,--rpath=/opt/lib"
	touch $(SENDMAIL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
sendmail: $(SENDMAIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SENDMAIL_BUILD_DIR)/.staged: $(SENDMAIL_BUILD_DIR)/.built
	rm -f $(SENDMAIL_BUILD_DIR)/.staged
	$(MAKE) -C $(SENDMAIL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SENDMAIL_BUILD_DIR)/.staged

sendmail-stage: $(SENDMAIL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sendmail
#
$(SENDMAIL_IPK_DIR)/CONTROL/control:
	@install -d $(SENDMAIL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: sendmail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SENDMAIL_PRIORITY)" >>$@
	@echo "Section: $(SENDMAIL_SECTION)" >>$@
	@echo "Version: $(SENDMAIL_VERSION)-$(SENDMAIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SENDMAIL_MAINTAINER)" >>$@
	@echo "Source: $(SENDMAIL_SITE)/$(SENDMAIL_SOURCE)" >>$@
	@echo "Description: $(SENDMAIL_DESCRIPTION)" >>$@
	@echo "Depends: $(SENDMAIL_DEPENDS)" >>$@
	@echo "Suggests: $(SENDMAIL_SUGGESTS)" >>$@
	@echo "Conflicts: $(SENDMAIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SENDMAIL_IPK_DIR)/opt/sbin or $(SENDMAIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SENDMAIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SENDMAIL_IPK_DIR)/opt/etc/sendmail/...
# Documentation files should be installed in $(SENDMAIL_IPK_DIR)/opt/doc/sendmail/...
# Daemon startup scripts should be installed in $(SENDMAIL_IPK_DIR)/opt/etc/init.d/S??sendmail
#
# You may need to patch your application to make it use these locations.
#
$(SENDMAIL_IPK): $(SENDMAIL_BUILD_DIR)/.built
	rm -rf $(SENDMAIL_IPK_DIR) $(BUILD_DIR)/sendmail_*_$(TARGET_ARCH).ipk
	install -d $(SENDMAIL_IPK_DIR)/opt/etc/mail
	install -d $(SENDMAIL_IPK_DIR)/opt/bin
	install -d $(SENDMAIL_IPK_DIR)/opt/sbin
	install -d $(SENDMAIL_IPK_DIR)/opt/man/man{1,5,8}
	install -d $(SENDMAIL_IPK_DIR)/opt/var/spool/mqueue
	$(MAKE) -C $(SENDMAIL_BUILD_DIR) DESTDIR=$(SENDMAIL_IPK_DIR) \
		UBINGRP=$(LOGNAME) UBINOWN=$(LOGNAME) \
		SBINGRP=$(LOGNAME) SBINOWN=$(LOGNAME) \
		GBINGRP=$(LOGNAME) GBINOWN=$(LOGNAME) \
		MBINGRP=$(LOGNAME) MBINOWN=$(LOGNAME) \
		MANOWN=$(LOGNAME) MANGRP=$(LOGNAME) \
		CFGRP=$(LOGNAME)   CFOWN=$(LOGNAME) \
		MSPQOWN=$(LOGNAME) \
		MAILDIR=/opt/etc/mail \
		install
	$(MAKE) -C $(SENDMAIL_BUILD_DIR)/cf/cf DESTDIR=$(SENDMAIL_IPK_DIR) \
		CFGRP=$(LOGNAME)   CFOWN=$(LOGNAME) \
		MAILDIR=/opt/etc/mail \
		CF=generic-linux install-sendmail-cf
	for i in $(SENDMAIL_IPK_DIR)/opt/{bin/vacation,sbin/*}; do chmod u+w $$i; $(STRIP_COMMAND) $$i; chmod a-w $$i; done
	( umask 022;\
	echo "# local-host-names - include all aliases for your machine here."\
        > $(SENDMAIL_IPK_DIR)/opt/etc/mail/local-host-names;\
	echo "# relay-domains - include all hosts you want to relay mail for."\
	> $(SENDMAIL_IPK_DIR)/opt/etc/mail/relay-domains ;\
	echo "# aliases - define mail aliases here." \
	> $(SENDMAIL_IPK_DIR)/opt/etc/mail/aliases )
	install -d $(SENDMAIL_IPK_DIR)/opt/etc/
	install -d $(SENDMAIL_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SENDMAIL_SOURCE_DIR)/rc.sendmail $(SENDMAIL_IPK_DIR)/opt/etc/init.d/S69sendmail
	$(MAKE) $(SENDMAIL_IPK_DIR)/CONTROL/control
	install -m 755 $(SENDMAIL_SOURCE_DIR)/postinst $(SENDMAIL_IPK_DIR)/CONTROL/postinst
	echo $(SENDMAIL_CONFFILES) | sed -e 's/ /\n/g' > $(SENDMAIL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SENDMAIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sendmail-ipk: $(SENDMAIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sendmail-clean:
	rm -f $(SENDMAIL_BUILD_DIR)/.built
	-$(MAKE) -C $(SENDMAIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sendmail-dirclean:
	rm -rf $(BUILD_DIR)/$(SENDMAIL_DIR) $(SENDMAIL_BUILD_DIR) $(SENDMAIL_IPK_DIR) $(SENDMAIL_IPK)
#
#
# Some sanity check for the package.
#
sendmail-check: $(SENDMAIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SENDMAIL_IPK)
