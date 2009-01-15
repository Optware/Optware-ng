###########################################################
#
# nostromo
#
###########################################################
#
# NOSTROMO_VERSION, NOSTROMO_SITE and NOSTROMO_SOURCE define
# the upstream location of the source code for the package.
# NOSTROMO_DIR is the directory which is created when the source
# archive is unpacked.
# NOSTROMO_UNZIP is the command used to unzip the source.
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
NOSTROMO_SITE=http://www.nazgul.ch/dev
NOSTROMO_VERSION=1.9
NOSTROMO_SOURCE=nostromo-$(NOSTROMO_VERSION).tar.gz
NOSTROMO_DIR=nostromo-$(NOSTROMO_VERSION)
NOSTROMO_UNZIP=zcat
NOSTROMO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NOSTROMO_DESCRIPTION=nhttpd is a simple, fast and secure HTTP server.
NOSTROMO_SECTION=web
NOSTROMO_PRIORITY=optional
NOSTROMO_DEPENDS=openssl
NOSTROMO_SUGGESTS=
NOSTROMO_CONFLICTS=

#
# NOSTROMO_IPK_VERSION should be incremented when the ipk changes.
#
NOSTROMO_IPK_VERSION=1

#
# NOSTROMO_CONFFILES should be a list of user-editable files
#NOSTROMO_CONFFILES=/opt/etc/nostromo.conf /opt/etc/init.d/SXXnostromo

#
# NOSTROMO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NOSTROMO_PATCHES=$(NOSTROMO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NOSTROMO_CPPFLAGS=
NOSTROMO_LDFLAGS=

#
# NOSTROMO_BUILD_DIR is the directory in which the build is done.
# NOSTROMO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NOSTROMO_IPK_DIR is the directory in which the ipk is built.
# NOSTROMO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NOSTROMO_BUILD_DIR=$(BUILD_DIR)/nostromo
NOSTROMO_SOURCE_DIR=$(SOURCE_DIR)/nostromo
NOSTROMO_IPK_DIR=$(BUILD_DIR)/nostromo-$(NOSTROMO_VERSION)-ipk
NOSTROMO_IPK=$(BUILD_DIR)/nostromo_$(NOSTROMO_VERSION)-$(NOSTROMO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nostromo-source nostromo-unpack nostromo nostromo-stage nostromo-ipk nostromo-clean nostromo-dirclean nostromo-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NOSTROMO_SOURCE):
	$(WGET) -P $(@D) $(NOSTROMO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nostromo-source: $(DL_DIR)/$(NOSTROMO_SOURCE) $(NOSTROMO_PATCHES)

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
$(NOSTROMO_BUILD_DIR)/.configured: $(DL_DIR)/$(NOSTROMO_SOURCE) $(NOSTROMO_PATCHES) make/nostromo.mk
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(NOSTROMO_DIR) $(@D)
	$(NOSTROMO_UNZIP) $(DL_DIR)/$(NOSTROMO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NOSTROMO_PATCHES)" ; \
		then cat $(NOSTROMO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NOSTROMO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NOSTROMO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(NOSTROMO_DIR) $(@D) ; \
	fi
	sed -i.orig \
		-e 's|	ar |	$$(AR) |' \
		-e 's|	cc |	$$(CC) |' \
		-e 's|	ranlib |	$$(RANLIB) |' \
		-e 's|	strip |	$$(STRIP) |' \
		-e 's|$${CCFLAGS} |& $$(CPPFLAGS) |' \
		-e 's|-Werror ||' \
		-e '/$$(CC) .* -l/s| -l| $$(LDFLAGS)&|' \
		$(@D)/src/*/GNUmakefile
	sed -i.orig \
		-e 's| -o root||' \
		-e 's| -g bin||' \
		-e 's| -g daemon||' \
		-e 's|/usr/local/|$$(DESTDIR)/opt/|' \
		-e 's|/usr/share/|$$(DESTDIR)/opt/share/|' \
		-e 's|/var/|$$(DESTDIR)/opt/var/|' \
		$(@D)/GNUmakefile
	sed -i.orig -e 's|/var/nostromo|/opt&|' \
		$(@D)/conf/nhttpd.conf-dist \
		$(@D)/src/nhttpd/main.c
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NOSTROMO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NOSTROMO_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

nostromo-unpack: $(NOSTROMO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NOSTROMO_BUILD_DIR)/.built: $(NOSTROMO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NOSTROMO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NOSTROMO_LDFLAGS)" \
;
	touch $@

#
# This is the build convenience target.
#
nostromo: $(NOSTROMO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NOSTROMO_BUILD_DIR)/.staged: $(NOSTROMO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

nostromo-stage: $(NOSTROMO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nostromo
#
$(NOSTROMO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nostromo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NOSTROMO_PRIORITY)" >>$@
	@echo "Section: $(NOSTROMO_SECTION)" >>$@
	@echo "Version: $(NOSTROMO_VERSION)-$(NOSTROMO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NOSTROMO_MAINTAINER)" >>$@
	@echo "Source: $(NOSTROMO_SITE)/$(NOSTROMO_SOURCE)" >>$@
	@echo "Description: $(NOSTROMO_DESCRIPTION)" >>$@
	@echo "Depends: $(NOSTROMO_DEPENDS)" >>$@
	@echo "Suggests: $(NOSTROMO_SUGGESTS)" >>$@
	@echo "Conflicts: $(NOSTROMO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NOSTROMO_IPK_DIR)/opt/sbin or $(NOSTROMO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NOSTROMO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NOSTROMO_IPK_DIR)/opt/etc/nostromo/...
# Documentation files should be installed in $(NOSTROMO_IPK_DIR)/opt/doc/nostromo/...
# Daemon startup scripts should be installed in $(NOSTROMO_IPK_DIR)/opt/etc/init.d/S??nostromo
#
# You may need to patch your application to make it use these locations.
#
$(NOSTROMO_IPK): $(NOSTROMO_BUILD_DIR)/.built
	rm -rf $(NOSTROMO_IPK_DIR) $(BUILD_DIR)/nostromo_*_$(TARGET_ARCH).ipk
	install -d $(NOSTROMO_IPK_DIR)/opt/sbin
	install -d $(NOSTROMO_IPK_DIR)/opt/share/man/man8
	$(MAKE) -C $(NOSTROMO_BUILD_DIR) DESTDIR=$(NOSTROMO_IPK_DIR) install
#	install -d $(NOSTROMO_IPK_DIR)/opt/etc/
#	install -m 644 $(NOSTROMO_SOURCE_DIR)/nostromo.conf $(NOSTROMO_IPK_DIR)/opt/etc/nostromo.conf
#	install -d $(NOSTROMO_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NOSTROMO_SOURCE_DIR)/rc.nostromo $(NOSTROMO_IPK_DIR)/opt/etc/init.d/SXXnostromo
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NOSTROMO_IPK_DIR)/opt/etc/init.d/SXXnostromo
	$(MAKE) $(NOSTROMO_IPK_DIR)/CONTROL/control
#	install -m 755 $(NOSTROMO_SOURCE_DIR)/postinst $(NOSTROMO_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NOSTROMO_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NOSTROMO_SOURCE_DIR)/prerm $(NOSTROMO_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NOSTROMO_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(NOSTROMO_IPK_DIR)/CONTROL/postinst $(NOSTROMO_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(NOSTROMO_CONFFILES) | sed -e 's/ /\n/g' > $(NOSTROMO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NOSTROMO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nostromo-ipk: $(NOSTROMO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nostromo-clean:
	rm -f $(NOSTROMO_BUILD_DIR)/.built
	-$(MAKE) -C $(NOSTROMO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nostromo-dirclean:
	rm -rf $(BUILD_DIR)/$(NOSTROMO_DIR) $(NOSTROMO_BUILD_DIR) $(NOSTROMO_IPK_DIR) $(NOSTROMO_IPK)
#
#
# Some sanity check for the package.
#
nostromo-check: $(NOSTROMO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
