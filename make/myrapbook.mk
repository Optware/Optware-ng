###########################################################
#
# myrapbook
#
###########################################################

# You must replace "myrapbook" and "MYRAPBOOK" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MYRAPBOOK_VERSION, MYRAPBOOK_SITE and MYRAPBOOK_SOURCE define
# the upstream location of the source code for the package.
# MYRAPBOOK_DIR is the directory which is created when the source
# archive is unpacked.
# MYRAPBOOK_UNZIP is the command used to unzip the source.
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
MYRAPBOOK_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/myrapbook
MYRAPBOOK_VERSION=0.1b
MYRAPBOOK_SOURCE=myrapbook-$(MYRAPBOOK_VERSION).tar.gz
MYRAPBOOK_DIR=myrapbook-$(MYRAPBOOK_VERSION)
MYRAPBOOK_UNZIP=zcat
MYRAPBOOK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MYRAPBOOK_DESCRIPTION=A daemon originally written for WD My Book World disk drives, that implements a downloader for rapidshare.com premium users. Is based on libcurl and runs multiple threads for downloading multiple files. The daemon is controlled remotelly from any web browser.
MYRAPBOOK_SECTION=net
MYRAPBOOK_PRIORITY=optional
MYRAPBOOK_DEPENDS=php-curl,php-fcgi,openssl
MYRAPBOOK_SUGGESTS=
MYRAPBOOK_CONFLICTS=

#
# MYRAPBOOK_IPK_VERSION should be incremented when the ipk changes.
#
MYRAPBOOK_IPK_VERSION=2

#
# MYRAPBOOK_CONFFILES should be a list of user-editable files
MYRAPBOOK_CONFFILES=/opt/etc/myrapbook.conf /opt/etc/init.d/myrapbookd

#
# MYRAPBOOK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MYRAPBOOK_PATCHES=$(MYRAPBOOK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MYRAPBOOK_CPPFLAGS=
MYRAPBOOK_LDFLAGS=

#
# MYRAPBOOK_BUILD_DIR is the directory in which the build is done.
# MYRAPBOOK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MYRAPBOOK_IPK_DIR is the directory in which the ipk is built.
# MYRAPBOOK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MYRAPBOOK_BUILD_DIR=$(BUILD_DIR)/myrapbook
MYRAPBOOK_SOURCE_DIR=$(SOURCE_DIR)/myrapbook
MYRAPBOOK_IPK_DIR=$(BUILD_DIR)/myrapbook-$(MYRAPBOOK_VERSION)-ipk
MYRAPBOOK_IPK=$(BUILD_DIR)/myrapbook_$(MYRAPBOOK_VERSION)-$(MYRAPBOOK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: myrapbook-source myrapbook-unpack myrapbook myrapbook-stage myrapbook-ipk myrapbook-clean myrapbook-dirclean myrapbook-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MYRAPBOOK_SOURCE):
	$(WGET) -P $(@D) $(MYRAPBOOK_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
myrapbook-source: $(DL_DIR)/$(MYRAPBOOK_SOURCE) $(MYRAPBOOK_PATCHES)

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
$(MYRAPBOOK_BUILD_DIR)/.configured: $(DL_DIR)/$(MYRAPBOOK_SOURCE) $(MYRAPBOOK_PATCHES) make/myrapbook.mk
	$(MAKE) libcurl-stage
	rm -rf $(BUILD_DIR)/$(MYRAPBOOK_DIR) $(@D)
	$(MYRAPBOOK_UNZIP) $(DL_DIR)/$(MYRAPBOOK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MYRAPBOOK_PATCHES)" ; \
		then cat $(MYRAPBOOK_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MYRAPBOOK_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MYRAPBOOK_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MYRAPBOOK_DIR) $(@D) ; \
	fi
	sed -i -e '/^CC =/s|^.*|CC = "$(TARGET_CC)"|' \
	-e '/^CFLAGS=/s|^.*|CFLAGS=$(STAGING_CPPFLAGS) $(MYRAPBOOK_CPPFLAGS)|' \
	-e 's|^LIBS =.*|LIBS=$(STAGING_LDFLAGS) $(MYRAPBOOK_LDFLAGS) \\|' $(@D)/makefile
	sed -i -e 's|/tmp/myrapbook|/opt/tmp/myrapbook|' \
		-e 's|\./myrapbook\.conf|/opt/etc/myrapbook.conf|' \
		-e '/curl\/types.h/d' \
		$(@D)/myrapbook.c
	###fix by andrew_sh@mybookworld.wikidot.com
	sed -i -e "s/SOL_TCP/getprotobyname('tcp')/" $(@D)/web_interface/daemoncntrl.php
	touch $@

myrapbook-unpack: $(MYRAPBOOK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MYRAPBOOK_BUILD_DIR)/.built: $(MYRAPBOOK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) make-myrapbook
	touch $@

#
# This is the build convenience target.
#
myrapbook: $(MYRAPBOOK_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/myrapbook
#
$(MYRAPBOOK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: myrapbook" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MYRAPBOOK_PRIORITY)" >>$@
	@echo "Section: $(MYRAPBOOK_SECTION)" >>$@
	@echo "Version: $(MYRAPBOOK_VERSION)-$(MYRAPBOOK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MYRAPBOOK_MAINTAINER)" >>$@
	@echo "Source: $(MYRAPBOOK_SITE)/$(MYRAPBOOK_SOURCE)" >>$@
	@echo "Description: $(MYRAPBOOK_DESCRIPTION)" >>$@
	@echo "Depends: $(MYRAPBOOK_DEPENDS)" >>$@
	@echo "Suggests: $(MYRAPBOOK_SUGGESTS)" >>$@
	@echo "Conflicts: $(MYRAPBOOK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MYRAPBOOK_IPK_DIR)/opt/sbin or $(MYRAPBOOK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MYRAPBOOK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MYRAPBOOK_IPK_DIR)/opt/etc/myrapbook/...
# Documentation files should be installed in $(MYRAPBOOK_IPK_DIR)/opt/doc/myrapbook/...
# Daemon startup scripts should be installed in $(MYRAPBOOK_IPK_DIR)/opt/etc/init.d/S??myrapbook
#
# You may need to patch your application to make it use these locations.
#
$(MYRAPBOOK_IPK): $(MYRAPBOOK_BUILD_DIR)/.built
	rm -rf $(MYRAPBOOK_IPK_DIR) $(BUILD_DIR)/myrapbook_*_$(TARGET_ARCH).ipk
	mkdir -p $(MYRAPBOOK_IPK_DIR)/opt/bin $(MYRAPBOOK_IPK_DIR)/opt/share/myrapbook
	cp -f $(MYRAPBOOK_BUILD_DIR)/web_interface/* $(MYRAPBOOK_IPK_DIR)/opt/share/myrapbook
	$(STRIP_COMMAND) $(MYRAPBOOK_BUILD_DIR)/myrapbook-daemon -o $(MYRAPBOOK_IPK_DIR)/opt/bin/myrapbook-daemon
	install -d $(MYRAPBOOK_IPK_DIR)/opt/etc/
	install -m 644 $(MYRAPBOOK_SOURCE_DIR)/myrapbook.conf $(MYRAPBOOK_IPK_DIR)/opt/etc/myrapbook.conf
	install -d $(MYRAPBOOK_IPK_DIR)/opt/etc/init.d
	install -m 755 $(MYRAPBOOK_SOURCE_DIR)/myrapbookd $(MYRAPBOOK_IPK_DIR)/opt/etc/init.d/myrapbookd
	ln -s myrapbookd $(MYRAPBOOK_IPK_DIR)/opt/etc/init.d/S92myrapbookd
	ln -s myrapbookd $(MYRAPBOOK_IPK_DIR)/opt/etc/init.d/K12myrapbookd
	install -d $(MYRAPBOOK_IPK_DIR)/opt/tmp/myrapbook
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MYRAPBOOK_IPK_DIR)/opt/etc/init.d/SXXmyrapbook
	$(MAKE) $(MYRAPBOOK_IPK_DIR)/CONTROL/control
#	install -m 755 $(MYRAPBOOK_SOURCE_DIR)/postinst $(MYRAPBOOK_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MYRAPBOOK_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MYRAPBOOK_SOURCE_DIR)/prerm $(MYRAPBOOK_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MYRAPBOOK_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MYRAPBOOK_IPK_DIR)/CONTROL/postinst $(MYRAPBOOK_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MYRAPBOOK_CONFFILES) | sed -e 's/ /\n/g' > $(MYRAPBOOK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MYRAPBOOK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
myrapbook-ipk: $(MYRAPBOOK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
myrapbook-clean:
	rm -f $(MYRAPBOOK_BUILD_DIR)/.built
	-$(MAKE) -C $(MYRAPBOOK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
myrapbook-dirclean:
	rm -rf $(BUILD_DIR)/$(MYRAPBOOK_DIR) $(MYRAPBOOK_BUILD_DIR) $(MYRAPBOOK_IPK_DIR) $(MYRAPBOOK_IPK)
#
#
# Some sanity check for the package.
#
myrapbook-check: $(MYRAPBOOK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
