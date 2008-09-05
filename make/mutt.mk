###########################################################
#
# mutt
#
###########################################################

#
# MUTT_VERSION, MUTT_SITE and MUTT_SOURCE define
# the upstream location of the source code for the package.
# MUTT_DIR is the directory which is created when the source
# archive is unpacked.
# MUTT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
MUTT_SITE=ftp://ftp.mutt.org/mutt/devel
MUTT_VERSION=1.5.16
MUTT_SOURCE=mutt-$(MUTT_VERSION).tar.gz
MUTT_DIR=mutt-$(MUTT_VERSION)
MUTT_UNZIP=zcat
MUTT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MUTT_DESCRIPTION=text mode mail client
MUTT_SECTION=mail
MUTT_PRIORITY=optional
MUTT_DEPENDS=$(NCURSES_FOR_OPTWARE_TARGET), openssl, cyrus-sasl, libdb, libidn
MUTT_SUGGESTS=
MUTT_CONFLICTS=

#
# MUTT_IPK_VERSION should be incremented when the ipk changes.
#
MUTT_IPK_VERSION=1

#
# MUTT_CONFFILES should be a list of user-editable files
#MUTT_CONFFILES=/opt/etc/mutt.conf /opt/etc/init.d/SXXmutt

#
# MUTT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MUTT_PATCHES=$(MUTT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MUTT_CPPFLAGS=
MUTT_LDFLAGS=-lsasl2 -ldl

#
# MUTT_BUILD_DIR is the directory in which the build is done.
# MUTT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MUTT_IPK_DIR is the directory in which the ipk is built.
# MUTT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MUTT_BUILD_DIR=$(BUILD_DIR)/mutt
MUTT_SOURCE_DIR=$(SOURCE_DIR)/mutt
MUTT_IPK_DIR=$(BUILD_DIR)/mutt-$(MUTT_VERSION)-ipk
MUTT_IPK=$(BUILD_DIR)/mutt_$(MUTT_VERSION)-$(MUTT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MUTT_SOURCE):
	$(WGET) -P $(@D) $(MUTT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

.PHONY: mutt-source mutt-unpack mutt mutt-stage mutt-ipk mutt-clean mutt-dirclean mutt-check

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mutt-source: $(DL_DIR)/$(MUTT_SOURCE) $(MUTT_PATCHES)

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
$(MUTT_BUILD_DIR)/.configured: $(DL_DIR)/$(MUTT_SOURCE) $(MUTT_PATCHES)
	$(MAKE) $(NCURSES_FOR_OPTWARE_TARGET)-stage openssl-stage cyrus-sasl-stage libdb-stage
	$(MAKE) libidn-stage
	rm -rf $(BUILD_DIR)/$(MUTT_DIR) $(@D)
	$(MUTT_UNZIP) $(DL_DIR)/$(MUTT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(MUTT_PATCHES) | patch -d $(BUILD_DIR)/$(MUTT_DIR) -p1
	mv $(BUILD_DIR)/$(MUTT_DIR) $(@D)
	# change mutt.h and lib.h to find posix1_lim.h in <bits/...>
	sed -i -e 's:posix1_lim.h:bits/posix1_lim.h:g' $(@D)/mutt.h
	sed -i -e 's:posix1_lim.h:bits/posix1_lim.h:g' $(@D)/lib.h
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MUTT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MUTT_LDFLAGS)" \
		ac_cv_path_SENDMAIL=/opt/sbin/sendmail \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--with-mailpath=/opt/var/spool/mail \
		--enable-imap \
		--with-ssl \
		--with-sasl2 \
		--with-bdb \
	)
	sed -i -e 's|-I$$(includedir)|-I$(STAGING_INCLUDE_DIR)|' $(@D)/Makefile
	touch $@

mutt-unpack: $(MUTT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MUTT_BUILD_DIR)/.built: $(MUTT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) makedoc CC=$(HOSTCC) LDFLAGS="" LIBS=""
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
mutt: $(MUTT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(MUTT_BUILD_DIR)/.staged: $(MUTT_BUILD_DIR)/.built
#	rm -f $(MUTT_BUILD_DIR)/.staged
#	$(MAKE) -C $(MUTT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $(MUTT_BUILD_DIR)/.staged
#
#mutt-stage: $(MUTT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mutt
#
$(MUTT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mutt" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MUTT_PRIORITY)" >>$@
	@echo "Section: $(MUTT_SECTION)" >>$@
	@echo "Version: $(MUTT_VERSION)-$(MUTT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MUTT_MAINTAINER)" >>$@
	@echo "Source: $(MUTT_SITE)/$(MUTT_SOURCE)" >>$@
	@echo "Description: $(MUTT_DESCRIPTION)" >>$@
	@echo "Depends: $(MUTT_DEPENDS)" >>$@
	@echo "Suggests: $(MUTT_SUGGESTS)" >>$@
	@echo "Conflicts: $(MUTT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MUTT_IPK_DIR)/opt/sbin or $(MUTT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MUTT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MUTT_IPK_DIR)/opt/etc/mutt/...
# Documentation files should be installed in $(MUTT_IPK_DIR)/opt/doc/mutt/...
# Daemon startup scripts should be installed in $(MUTT_IPK_DIR)/opt/etc/init.d/S??mutt
#
# You may need to patch your application to make it use these locations.
#
$(MUTT_IPK): $(MUTT_BUILD_DIR)/.built
	rm -rf $(MUTT_IPK_DIR) $(BUILD_DIR)/mutt_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MUTT_BUILD_DIR) DESTDIR=$(MUTT_IPK_DIR) install
	# install-strip doesn't work for some reason
	$(STRIP_COMMAND) $(MUTT_IPK_DIR)/opt/bin/mutt $(MUTT_IPK_DIR)/opt/bin/pgpewrap $(MUTT_IPK_DIR)/opt/bin/pgpring
#	install -d $(MUTT_IPK_DIR)/opt/etc/
#	install -m 755 $(MUTT_SOURCE_DIR)/mutt.conf $(MUTT_IPK_DIR)/opt/etc/mutt.conf
#	install -d $(MUTT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MUTT_SOURCE_DIR)/rc.mutt $(MUTT_IPK_DIR)/opt/etc/init.d/SXXmutt
	$(MAKE) $(MUTT_IPK_DIR)/CONTROL/control
#	install -m 644 $(MUTT_SOURCE_DIR)/postinst $(MUTT_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(MUTT_SOURCE_DIR)/prerm $(MUTT_IPK_DIR)/CONTROL/prerm
#	echo $(MUTT_CONFFILES) | sed -e 's/ /\n/g' > $(MUTT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MUTT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mutt-ipk: $(MUTT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mutt-clean:
	-$(MAKE) -C $(MUTT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mutt-dirclean:
	rm -rf $(BUILD_DIR)/$(MUTT_DIR) $(MUTT_BUILD_DIR) $(MUTT_IPK_DIR) $(MUTT_IPK)

#
# Some sanity check for the package.
#
mutt-check: $(MUTT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MUTT_IPK)
