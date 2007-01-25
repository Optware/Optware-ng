###########################################################
#
# spamassassin
#
###########################################################

SPAMASSASSIN_SITE=http://www.artfiles.org/apache.org/spamassassin/source
SPAMASSASSIN_VERSION=3.1.7
SPAMASSASSIN_SOURCE=Mail-SpamAssassin-$(SPAMASSASSIN_VERSION).tar.bz2
SPAMASSASSIN_DIR=Mail-SpamAssassin-$(SPAMASSASSIN_VERSION)
SPAMASSASSIN_UNZIP=bzcat
SPAMASSASSIN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SPAMASSASSIN_DESCRIPTION=a spam filter for email which can be invoked from mail delivery agents
SPAMASSASSIN_SECTION=mail
SPAMASSASSIN_PRIORITY=optional
SPAMASSASSIN_DEPENDS=perl-digest-sha1, perl-html-parser, perl-libwww, gnupg
SPAMASSASSIN_SUGGESTS=
SPAMASSASSIN_CONFLICTS=

#
# SPAMASSASSIN_IPK_VERSION should be incremented when the ipk changes.
#
SPAMASSASSIN_IPK_VERSION=3

#
# SPAMASSASSIN_CONFFILES should be a list of user-editable files

#
# SPAMASSASSIN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SPAMASSASSIN_PATCHES=$(SPAMASSASSIN_SOURCE_DIR)/Makefile.PL.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SPAMASSASSIN_CPPFLAGS=
SPAMASSASSIN_LDFLAGS=

SPAMASSASSIN_BUILD_DIR=$(BUILD_DIR)/Mail-SpamAssassin
SPAMASSASSIN_SOURCE_DIR=$(SOURCE_DIR)/spamassassin
SPAMASSASSIN_IPK_DIR=$(BUILD_DIR)/spamassassin-$(SPAMASSASSIN_VERSION)-ipk
SPAMASSASSIN_IPK=$(BUILD_DIR)/spamassassin_$(SPAMASSASSIN_VERSION)-$(SPAMASSASSIN_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SPAMASSASSIN_SOURCE):
	$(WGET) -P $(DL_DIR) $(SPAMASSASSIN_SITE)/$(SPAMASSASSIN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
spamassassin-source: $(DL_DIR)/$(SPAMASSASSIN_SOURCE) $(SPAMASSASSIN_PATCHES)

$(SPAMASSASSIN_BUILD_DIR)/.configured: $(DL_DIR)/$(SPAMASSASSIN_SOURCE) $(SPAMASSASSIN_PATCHES) make/spamassassin.mk
	$(MAKE) perl-stage perl-html-parser-stage perl-digest-sha1-stage
	rm -rf $(BUILD_DIR)/$(SPAMASSASSIN_DIR) $(SPAMASSASSIN_BUILD_DIR)
	$(SPAMASSASSIN_UNZIP) $(DL_DIR)/$(SPAMASSASSIN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SPAMASSASSIN_PATCHES)" ; \
		then cat $(SPAMASSASSIN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SPAMASSASSIN_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(SPAMASSASSIN_DIR)" != "$(SPAMASSASSIN_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SPAMASSASSIN_DIR) $(SPAMASSASSIN_BUILD_DIR) ; \
	fi
	(cd $(SPAMASSASSIN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SPAMASSASSIN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SPAMASSASSIN_LDFLAGS)" \
                $(PERL_HOSTPERL) Makefile.PL \
                LD_RUN_PATH=/opt/lib \
                PREFIX=/opt \
 		SYSCONFDIR=/opt/etc \
		CONFDIR=/opt/etc/spamassassin \
		CONTACT_ADDRESS="postmaster@local.domain" \
		LOCALSTATEDIR=/opt/share \
		< /dev/null && \
		(cd spamc; \
		  $(TARGET_CONFIGURE_OPTS) \
                  ./configure --prefix=/opt \
                    --sysconfdir=/opt/etc/spamassassin \
                    --datadir=/opt/share/spamassassin \
                    --enable-ssl=no \
                    --host=$(GNU_TARGET_NAME); \
                  echo "#define VERSION_STRING \"$(SPAMASSASSIN_VERSION)\"" \
		    >version.h \
		) \
	)
	touch $(SPAMASSASSIN_BUILD_DIR)/.configured

spamassassin-unpack: $(SPAMASSASSIN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SPAMASSASSIN_BUILD_DIR)/.built: $(SPAMASSASSIN_BUILD_DIR)/.configured
	rm -f $(SPAMASSASSIN_BUILD_DIR)/.built
	$(MAKE) -C $(SPAMASSASSIN_BUILD_DIR)
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		LD_RUN_PATH=/opt/lib \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(SPAMASSASSIN_BUILD_DIR)/.built

#
# This is the build convenience target.
#
spamassassin: $(SPAMASSASSIN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SPAMASSASSIN_BUILD_DIR)/.staged: $(SPAMASSASSIN_BUILD_DIR)/.built
	rm -f $(SPAMASSASSIN_BUILD_DIR)/.staged
	$(MAKE) -C $(SPAMASSASSIN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SPAMASSASSIN_BUILD_DIR)/.staged

spamassassin-stage: $(SPAMASSASSIN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/spamassassin
#
$(SPAMASSASSIN_IPK_DIR)/CONTROL/control:
	@install -d $(SPAMASSASSIN_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: spamassassin" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SPAMASSASSIN_PRIORITY)" >>$@
	@echo "Section: $(SPAMASSASSIN_SECTION)" >>$@
	@echo "Version: $(SPAMASSASSIN_VERSION)-$(SPAMASSASSIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SPAMASSASSIN_MAINTAINER)" >>$@
	@echo "Source: $(SPAMASSASSIN_SITE)/$(SPAMASSASSIN_SOURCE)" >>$@
	@echo "Description: $(SPAMASSASSIN_DESCRIPTION)" >>$@
	@echo "Depends: $(SPAMASSASSIN_DEPENDS)" >>$@
	@echo "Suggests: $(SPAMASSASSIN_SUGGESTS)" >>$@
	@echo "Conflicts: $(SPAMASSASSIN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SPAMASSASSIN_IPK_DIR)/opt/sbin or $(SPAMASSASSIN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SPAMASSASSIN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SPAMASSASSIN_IPK_DIR)/opt/etc/spamassassin/...
# Documentation files should be installed in $(SPAMASSASSIN_IPK_DIR)/opt/doc/spamassassin/...
# Daemon startup scripts should be installed in $(SPAMASSASSIN_IPK_DIR)/opt/etc/init.d/S??spamassassin
#
# You may need to patch your application to make it use these locations.
#
$(SPAMASSASSIN_IPK): $(SPAMASSASSIN_BUILD_DIR)/.built
	rm -rf $(SPAMASSASSIN_IPK_DIR) $(BUILD_DIR)/spamassassin_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SPAMASSASSIN_BUILD_DIR) DESTDIR=$(SPAMASSASSIN_IPK_DIR) install
	perl -pi -e 's|$(PERL_HOSTPERL)|/opt/bin/perl|g' $(SPAMASSASSIN_IPK_DIR)/*
	install -d $(SPAMASSASSIN_IPK_DIR)/opt/etc/
	$(MAKE) $(SPAMASSASSIN_IPK_DIR)/CONTROL/control
	echo $(SPAMASSASSIN_CONFFILES) | sed -e 's/ /\n/g' > $(SPAMASSASSIN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SPAMASSASSIN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
spamassassin-ipk: $(SPAMASSASSIN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
spamassassin-clean:
	rm -f $(SPAMASSASSIN_BUILD_DIR)/.built
	-$(MAKE) -C $(SPAMASSASSIN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
spamassassin-dirclean:
	rm -rf $(BUILD_DIR)/$(SPAMASSASSIN_DIR) $(SPAMASSASSIN_BUILD_DIR) $(SPAMASSASSIN_IPK_DIR) $(SPAMASSASSIN_IPK)
