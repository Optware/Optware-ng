###########################################################
#
# nail
#
###########################################################

# You must replace "nail" and "NAIL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NAIL_VERSION, NAIL_SITE and NAIL_SOURCE define
# the upstream location of the source code for the package.
# NAIL_DIR is the directory which is created when the source
# archive is unpacked.
# NAIL_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
NAIL_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/nail/
NAIL_VERSION=11.25
NAIL_SOURCE=nail-$(NAIL_VERSION).tar.bz2
NAIL_DIR=nail-$(NAIL_VERSION)
NAIL_UNZIP=bzcat
NAIL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NAIL_DESCRIPTION=command-line email-client supporting POP3, IMAP, SMTP, ...
NAIL_SECTION=net
NAIL_PRIORITY=optional
NAIL_DEPENDS=openssl
NAIL_SUGGESTS=
NAIL_CONFLICTS=


#
# NAIL_IPK_VERSION should be incremented when the ipk changes.
#
NAIL_IPK_VERSION=1

#
# NAIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NAIL_PATCHES=$(NAIL_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq ($(OPTWARE_TARGET),wl500g)
  NAIL_CPPFLAGS=-DMB_CUR_MAX=1
else
  NAIL_CPPFLAGS=
endif
NAIL_LDFLAGS=

#
# NAIL_BUILD_DIR is the directory in which the build is done.
# NAIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NAIL_IPK_DIR is the directory in which the ipk is built.
# NAIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NAIL_BUILD_DIR=$(BUILD_DIR)/nail
NAIL_SOURCE_DIR=$(SOURCE_DIR)/nail
NAIL_IPK_DIR=$(BUILD_DIR)/nail-$(NAIL_VERSION)-ipk
NAIL_IPK=$(BUILD_DIR)/nail_$(NAIL_VERSION)-$(NAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NAIL_SOURCE):
	$(WGET) -P $(DL_DIR) $(NAIL_SITE)/$(NAIL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nail-source: $(DL_DIR)/$(NAIL_SOURCE) $(NAIL_PATCHES)

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
$(NAIL_BUILD_DIR)/.configured: $(DL_DIR)/$(NAIL_SOURCE) $(NAIL_PATCHES)
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(NAIL_DIR) $(NAIL_BUILD_DIR)
	$(NAIL_UNZIP) $(DL_DIR)/$(NAIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(NAIL_PATCHES) | patch -d $(BUILD_DIR)/$(NAIL_DIR) -p1
	mv $(BUILD_DIR)/$(NAIL_DIR) $(NAIL_BUILD_DIR)
	(cd $(NAIL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NAIL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NAIL_LDFLAGS)" \
		/bin/sh ./makeconfig \
	)
	touch $(NAIL_BUILD_DIR)/.configured

nail-unpack: $(NAIL_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(NAIL_BUILD_DIR)/.built: $(NAIL_BUILD_DIR)/.configured
	rm -f $(NAIL_BUILD_DIR)/.built
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(NAIL_BUILD_DIR) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NAIL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NAIL_LDFLAGS)"
	touch $(NAIL_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
nail: $(NAIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(STAGING_DIR)/opt/lib/libnail.so.$(NAIL_VERSION): $(NAIL_BUILD_DIR)/.built
#	install -d $(STAGING_DIR)/opt/include
#	install -m 644 $(NAIL_BUILD_DIR)/nail.h $(STAGING_DIR)/opt/include
#	install -d $(STAGING_DIR)/opt/lib
#	install -m 644 $(NAIL_BUILD_DIR)/libnail.a $(STAGING_DIR)/opt/lib
#	install -m 644 $(NAIL_BUILD_DIR)/libnail.so.$(NAIL_VERSION) $(STAGING_DIR)/opt/lib
#	cd $(STAGING_DIR)/opt/lib && ln -fs libnail.so.$(NAIL_VERSION) libnail.so.1
#	cd $(STAGING_DIR)/opt/lib && ln -fs libnail.so.$(NAIL_VERSION) libnail.so

#nail-stage: $(STAGING_DIR)/opt/lib/libnail.so.$(NAIL_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nail
#
$(NAIL_IPK_DIR)/CONTROL/control:
	@install -d $(NAIL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: nail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NAIL_PRIORITY)" >>$@
	@echo "Section: $(NAIL_SECTION)" >>$@
	@echo "Version: $(NAIL_VERSION)-$(NAIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NAIL_MAINTAINER)" >>$@
	@echo "Source: $(NAIL_SITE)/$(NAIL_SOURCE)" >>$@
	@echo "Description: $(NAIL_DESCRIPTION)" >>$@
	@echo "Depends: $(NAIL_DEPENDS)" >>$@
	@echo "Suggests: $(NAIL_SUGGESTS)" >>$@
	@echo "Conflicts: $(NAIL_CONFLICTS)" >>$@


#
# This builds the IPK file.
#
# Binaries should be installed into $(NAIL_IPK_DIR)/opt/sbin or $(NAIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NAIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NAIL_IPK_DIR)/opt/etc/nail/...
# Documentation files should be installed in $(NAIL_IPK_DIR)/opt/doc/nail/...
# Daemon startup scripts should be installed in $(NAIL_IPK_DIR)/opt/etc/init.d/S??nail
#
# You may need to patch your application to make it use these locations.
#
$(NAIL_IPK): $(NAIL_BUILD_DIR)/.built
	rm -rf $(NAIL_IPK_DIR) $(BUILD_DIR)/nail_*_$(TARGET_ARCH).ipk
	install -d $(NAIL_IPK_DIR)/opt/bin
	install -d $(NAIL_IPK_DIR)/opt/doc/nail
	$(STRIP_COMMAND) $(NAIL_BUILD_DIR)/nail -o $(NAIL_IPK_DIR)/opt/bin/nail
	install -m 644 $(NAIL_BUILD_DIR)/nail.rc $(NAIL_IPK_DIR)/opt/doc/nail/nail.rc
#	install -d $(NAIL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NAIL_SOURCE_DIR)/rc.nail $(NAIL_IPK_DIR)/opt/etc/init.d/SXXnail
	$(MAKE) $(NAIL_IPK_DIR)/CONTROL/control
	install -m 644 $(NAIL_SOURCE_DIR)/postinst $(NAIL_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(NAIL_SOURCE_DIR)/prerm $(NAIL_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NAIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nail-ipk: $(NAIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nail-clean:
	-$(MAKE) -C $(NAIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nail-dirclean:
	rm -rf $(BUILD_DIR)/$(NAIL_DIR) $(NAIL_BUILD_DIR) $(NAIL_IPK_DIR) $(NAIL_IPK)
