###########################################################
#
# amavisd-new
#
###########################################################

AMAVISD-NEW_SITE=http://www.ijs.si/software/amavisd
AMAVISD-NEW_VERSION=2.4.4
AMAVISD-NEW_SOURCE=amavisd-new-$(AMAVISD-NEW_VERSION).tar.gz
AMAVISD-NEW_DIR=amavisd-new-$(AMAVISD-NEW_VERSION)
AMAVISD-NEW_UNZIP=zcat
AMAVISD-NEW_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AMAVISD-NEW_DESCRIPTION=amavisd-new is a high-performance interface between mailer (MTA) and content checkers
AMAVISD-NEW_SECTION=mail
AMAVISD-NEW_PRIORITY=optional
AMAVISD-NEW_DEPENDS=perl-archive-tar, perl-archive-zip, perl-compress-zlib, \
  perl-convert-tnef, perl-convert-uulib, perl-digest-perl-md5, \
  perl-io-multiplex, perl-io-socket-ssl, perl-io-stringy, perl-io-zlib, \
  perl-mailtools, perl-mime-tools, perl-net-server, perl-unix-syslog, \
  perl-berkeleydb, perl-uri, spamassassin, bzip2, file, net-tools
AMAVISD-NEW_SUGGESTS=perl-net-cidr-lite, perl-net-dns, perl-sys-hostname-long, \
  perl-mail-spf-query, cpio, unrar, gzip, tnef, zoo, lha, arc, unarj
AMAVISD-NEW_CONFLICTS=

#
# AMAVISD-NEW_IPK_VERSION should be incremented when the ipk changes.
#
AMAVISD-NEW_IPK_VERSION=2

#
# AMAVISD-NEW_CONFFILES should be a list of user-editable files
AMAVISD-NEW_CONFFILES=/opt/etc/amavisd.conf /opt/etc/init.d/S60amavisd

#
# AMAVISD-NEW_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#AMAVISD-NEW_PATCHES=$(AMAVISD-NEW_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
AMAVISD-NEW_CPPFLAGS=
AMAVISD-NEW_LDFLAGS=

#
# AMAVISD-NEW_BUILD_DIR is the directory in which the build is done.
# AMAVISD-NEW_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# AMAVISD-NEW_IPK_DIR is the directory in which the ipk is built.
# AMAVISD-NEW_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
AMAVISD-NEW_BUILD_DIR=$(BUILD_DIR)/amavisd-new
AMAVISD-NEW_SOURCE_DIR=$(SOURCE_DIR)/amavisd-new
AMAVISD-NEW_IPK_DIR=$(BUILD_DIR)/amavisd-new-$(AMAVISD-NEW_VERSION)-ipk
AMAVISD-NEW_IPK=$(BUILD_DIR)/amavisd-new_$(AMAVISD-NEW_VERSION)-$(AMAVISD-NEW_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: amavisd-new-source amavisd-new-unpack amavisd-new amavisd-new-stage amavisd-new-ipk amavisd-new-clean amavisd-new-dirclean amavisd-new-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(AMAVISD-NEW_SOURCE):
	$(WGET) -P $(DL_DIR) $(AMAVISD-NEW_SITE)/$(AMAVISD-NEW_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
amavisd-new-source: $(DL_DIR)/$(AMAVISD-NEW_SOURCE) $(AMAVISD-NEW_PATCHES)

$(AMAVISD-NEW_BUILD_DIR)/.configured: $(DL_DIR)/$(AMAVISD-NEW_SOURCE) $(AMAVISD-NEW_PATCHES) make/amavisd-new.mk
	rm -rf $(BUILD_DIR)/$(AMAVISD-NEW_DIR) $(AMAVISD-NEW_BUILD_DIR)
	$(AMAVISD-NEW_UNZIP) $(DL_DIR)/$(AMAVISD-NEW_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(AMAVISD-NEW_PATCHES)" ; \
		then cat $(AMAVISD-NEW_PATCHES) | \
		patch -d $(BUILD_DIR)/$(AMAVISD-NEW_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(AMAVISD-NEW_DIR)" != "$(AMAVISD-NEW_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(AMAVISD-NEW_DIR) $(AMAVISD-NEW_BUILD_DIR) ; \
	fi
	touch $(AMAVISD-NEW_BUILD_DIR)/.configured

amavisd-new-unpack: $(AMAVISD-NEW_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(AMAVISD-NEW_BUILD_DIR)/.built: $(AMAVISD-NEW_BUILD_DIR)/.configured
	rm -f $(AMAVISD-NEW_BUILD_DIR)/.built
	(cd $(AMAVISD-NEW_BUILD_DIR); \
	  perl -pi -e 's|/usr/bin/perl|/opt/bin/perl|' amavisd; \
	  perl -pi -e 's|/var/amavis|/opt/var/spool/amavis|' amavisd; \
	  perl -pi -e 's|/etc/amavisd.conf|/opt/etc/amavisd.conf|' amavisd \
	)
	touch $(AMAVISD-NEW_BUILD_DIR)/.built

#
# This is the build convenience target.
#
amavisd-new: $(AMAVISD-NEW_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(AMAVISD-NEW_BUILD_DIR)/.staged: $(AMAVISD-NEW_BUILD_DIR)/.built
	rm -f $(AMAVISD-NEW_BUILD_DIR)/.staged
	$(MAKE) -C $(AMAVISD-NEW_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(AMAVISD-NEW_BUILD_DIR)/.staged

amavisd-new-stage: $(AMAVISD-NEW_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/amavisd-new
#
$(AMAVISD-NEW_IPK_DIR)/CONTROL/control:
	@install -d $(AMAVISD-NEW_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: amavisd-new" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AMAVISD-NEW_PRIORITY)" >>$@
	@echo "Section: $(AMAVISD-NEW_SECTION)" >>$@
	@echo "Version: $(AMAVISD-NEW_VERSION)-$(AMAVISD-NEW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AMAVISD-NEW_MAINTAINER)" >>$@
	@echo "Source: $(AMAVISD-NEW_SITE)/$(AMAVISD-NEW_SOURCE)" >>$@
	@echo "Description: $(AMAVISD-NEW_DESCRIPTION)" >>$@
	@echo "Depends: $(AMAVISD-NEW_DEPENDS)" >>$@
	@echo "Suggests: $(AMAVISD-NEW_SUGGESTS)" >>$@
	@echo "Conflicts: $(AMAVISD-NEW_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(AMAVISD-NEW_IPK_DIR)/opt/sbin or $(AMAVISD-NEW_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(AMAVISD-NEW_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(AMAVISD-NEW_IPK_DIR)/opt/etc/amavisd-new/...
# Documentation files should be installed in $(AMAVISD-NEW_IPK_DIR)/opt/doc/amavisd-new/...
# Daemon startup scripts should be installed in $(AMAVISD-NEW_IPK_DIR)/opt/etc/init.d/S??amavisd-new
#
# You may need to patch your application to make it use these locations.
#
$(AMAVISD-NEW_IPK): $(AMAVISD-NEW_BUILD_DIR)/.built
	rm -rf $(AMAVISD-NEW_IPK_DIR) $(BUILD_DIR)/amavisd-new_*_$(TARGET_ARCH).ipk
	install -d $(AMAVISD-NEW_IPK_DIR)/opt/sbin/
	install -m 755 $(AMAVISD-NEW_BUILD_DIR)/amavisd $(AMAVISD-NEW_IPK_DIR)/opt/sbin/amavisd
	install -d $(AMAVISD-NEW_IPK_DIR)/opt/etc/
	install -m 644 $(AMAVISD-NEW_SOURCE_DIR)/amavisd.conf $(AMAVISD-NEW_IPK_DIR)/opt/etc/amavisd.conf
	install -d \
	  $(AMAVISD-NEW_IPK_DIR)/opt/lib/perl5/site_perl/$(PERL_VERSION)
	install -m 755 $(AMAVISD-NEW_BUILD_DIR)/JpegTester.pm \
	  $(AMAVISD-NEW_IPK_DIR)/opt/lib/perl5/site_perl/$(PERL_VERSION)
	install -d $(AMAVISD-NEW_IPK_DIR)/opt/etc/init.d
	install -d -m 0755 $(AMAVISD-NEW_IPK_DIR)/opt/var/spool
	install -d -m 0700 $(AMAVISD-NEW_IPK_DIR)/opt/var/spool/amavis
	install -d -m 0700 $(AMAVISD-NEW_IPK_DIR)/opt/var/spool/amavis/db
	install -d -m 0700 $(AMAVISD-NEW_IPK_DIR)/opt/var/spool/amavis/virusmails

	install -m 755 $(AMAVISD-NEW_SOURCE_DIR)/rc.amavisd $(AMAVISD-NEW_IPK_DIR)/opt/etc/init.d/S60amavisd
	rm -rf $(AMAVISD-NEW_IPK_DIR)/opt/doc/amavisd-new/
	install -d -m 755 $(AMAVISD-NEW_IPK_DIR)/opt/doc/amavisd-new/
	install -d -m 755 $(AMAVISD-NEW_IPK_DIR)/opt/doc/amavisd-new/helper-prog
	install -d -m 755 $(AMAVISD-NEW_IPK_DIR)/opt/doc/amavisd-new/README_FILES
	install -d -m 755 $(AMAVISD-NEW_IPK_DIR)/opt/doc/amavisd-new/test-messages
	(cd $(AMAVISD-NEW_BUILD_DIR); \
	  install -m 644 amavisd.conf* \
	    $(AMAVISD-NEW_IPK_DIR)/opt/doc/amavisd-new/; \
	  install -m 644 LICENSE $(AMAVISD-NEW_IPK_DIR)/opt/doc/amavisd-new/; \
	  install -m 644 MANIFEST $(AMAVISD-NEW_IPK_DIR)/opt/doc/amavisd-new/; \
	  install -m 644 RELEASE_NOTES \
             $(AMAVISD-NEW_IPK_DIR)/opt/doc/amavisd-new/; \
	  install -m 644 TODO $(AMAVISD-NEW_IPK_DIR)/opt/doc/amavisd-new/; \
	  install -m 644 helper-progs/* \
	    $(AMAVISD-NEW_IPK_DIR)/opt/doc/amavisd-new/helper-progs/; \
	  install -m 644 README_FILES/* \
	    $(AMAVISD-NEW_IPK_DIR)/opt/doc/amavisd-new/README_FILES/; \
	  install -m 644 test-messages/* \
	    $(AMAVISD-NEW_IPK_DIR)/opt/doc/amavisd-new/test-messages/; \
        )
	$(MAKE) $(AMAVISD-NEW_IPK_DIR)/CONTROL/control
	install -m 755 $(AMAVISD-NEW_SOURCE_DIR)/postinst $(AMAVISD-NEW_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(AMAVISD-NEW_SOURCE_DIR)/prerm $(AMAVISD-NEW_IPK_DIR)/CONTROL/prerm
	echo $(AMAVISD-NEW_CONFFILES) | sed -e 's/ /\n/g' > $(AMAVISD-NEW_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AMAVISD-NEW_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
amavisd-new-ipk: $(AMAVISD-NEW_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
amavisd-new-clean:
	rm -f $(AMAVISD-NEW_BUILD_DIR)/.built
	-$(MAKE) -C $(AMAVISD-NEW_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
amavisd-new-dirclean:
	rm -rf $(BUILD_DIR)/$(AMAVISD-NEW_DIR) $(AMAVISD-NEW_BUILD_DIR) $(AMAVISD-NEW_IPK_DIR) $(AMAVISD-NEW_IPK)

#
#
# Some sanity check for the package.
#
#
amavisd-new-check: $(AMAVISD-NEW_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(AMAVISD-NEW_IPK)

