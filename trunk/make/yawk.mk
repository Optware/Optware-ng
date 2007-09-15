###########################################################
#
# yawk
#
###########################################################
#
# YAWK_VERSION, YAWK_SITE and YAWK_SOURCE define
# the upstream location of the source code for the package.
# YAWK_DIR is the directory which is created when the source
# archive is unpacked.
# YAWK_UNZIP is the command used to unzip the source.
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
YAWK_SITE=http://www.awk-scripting.de/download
YAWK_VERSION=2.0.0-beta5
YAWK_SOURCE=yawk-$(YAWK_VERSION).tar.gz
YAWK_DIR=yawk-$(YAWK_VERSION)
YAWK_UNZIP=zcat
YAWK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
YAWK_DESCRIPTION=yawk is a wiki clone written in gawk. \
It supports the usual text styles, lists, and tables. Additional and optional features are formatting with stylesheet classes, file uploads, and a framed user interface mode. It works on plain text files and does not require a database.
YAWK_SECTION=web
YAWK_PRIORITY=optional
YAWK_DEPENDS=gawk
YAWK_SUGGESTS=minihttpd
YAWK_CONFLICTS=

#
# YAWK_IPK_VERSION should be incremented when the ipk changes.
#
YAWK_IPK_VERSION=1

#
# YAWK_CONFFILES should be a list of user-editable files
YAWK_CONFFILES=/opt/etc/yawk/yawk.conf /opt/etc/yawk/wiki-wiki.conf

#
# YAWK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#YAWK_PATCHES=$(YAWK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
YAWK_CPPFLAGS=
YAWK_LDFLAGS=

#
# YAWK_BUILD_DIR is the directory in which the build is done.
# YAWK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# YAWK_IPK_DIR is the directory in which the ipk is built.
# YAWK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
YAWK_BUILD_DIR=$(BUILD_DIR)/yawk
YAWK_SOURCE_DIR=$(SOURCE_DIR)/yawk
YAWK_IPK_DIR=$(BUILD_DIR)/yawk-$(YAWK_VERSION)-ipk
YAWK_IPK=$(BUILD_DIR)/yawk_$(YAWK_VERSION)-$(YAWK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: yawk-source yawk-unpack yawk yawk-stage yawk-ipk yawk-clean yawk-dirclean yawk-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(YAWK_SOURCE):
	$(WGET) -P $(DL_DIR) $(YAWK_SITE)/$(YAWK_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(YAWK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
yawk-source: $(DL_DIR)/$(YAWK_SOURCE) $(YAWK_PATCHES)

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
$(YAWK_BUILD_DIR)/.configured: $(DL_DIR)/$(YAWK_SOURCE) $(YAWK_PATCHES) make/yawk.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(YAWK_DIR) $(YAWK_BUILD_DIR)
	$(YAWK_UNZIP) $(DL_DIR)/$(YAWK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(YAWK_PATCHES)" ; \
		then cat $(YAWK_PATCHES) | \
		patch -d $(BUILD_DIR)/$(YAWK_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(YAWK_DIR)" != "$(YAWK_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(YAWK_DIR) $(YAWK_BUILD_DIR) ; \
	fi
#	sed -i.orig \
	    -e 's|strip |$(STRIP_COMMAND) |' \
	    -e 's|/usr/local/bin/|$$(DESTDIR)/opt/bin/|' \
	    -e 's|/usr/httpd/|$$(DESTDIR)/opt/share/www/|' \
	    $(YAWK_BUILD_DIR)/makefile
	sed -i \
	    -e 's|#! */usr/bin/gawk|#!/opt/bin/gawk|' \
	    `grep -Il '#! */usr/bin/gawk' $(YAWK_BUILD_DIR)/*`
	sed -i \
	    -e '/configdir[ 	]*\/etc\/yawk/s|/etc/yawk|/opt/etc/yawk|' \
	    -e '/bindir[ 	]*\/usr\/lib\/yawk/s|/usr/lib/yawk|/opt/lib/yawk|' \
	    $(YAWK_BUILD_DIR)/yawk.conf
	sed -i \
	    -e '/configdir *=/s|"[^"]*"|"/opt/etc/yawk"|' \
	    -e '/bindir *=/s|"[^"]*"|"/opt/lib/yawk"|' \
	    -e '/yawkconf *=/s|"[^"]*"|"/opt/etc/yawk/yawk.conf"|' \
	    $(YAWK_BUILD_DIR)/wiki.cgi
#	(cd $(YAWK_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(YAWK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(YAWK_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

yawk-unpack: $(YAWK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(YAWK_BUILD_DIR)/.built: $(YAWK_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(YAWK_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(YAWK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(YAWK_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
yawk: $(YAWK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(YAWK_BUILD_DIR)/.staged: $(YAWK_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(YAWK_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

yawk-stage: $(YAWK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/yawk
#
$(YAWK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: yawk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(YAWK_PRIORITY)" >>$@
	@echo "Section: $(YAWK_SECTION)" >>$@
	@echo "Version: $(YAWK_VERSION)-$(YAWK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(YAWK_MAINTAINER)" >>$@
	@echo "Source: $(YAWK_SITE)/$(YAWK_SOURCE)" >>$@
	@echo "Description: $(YAWK_DESCRIPTION)" >>$@
	@echo "Depends: $(YAWK_DEPENDS)" >>$@
	@echo "Suggests: $(YAWK_SUGGESTS)" >>$@
	@echo "Conflicts: $(YAWK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(YAWK_IPK_DIR)/opt/sbin or $(YAWK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(YAWK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(YAWK_IPK_DIR)/opt/etc/yawk/...
# Documentation files should be installed in $(YAWK_IPK_DIR)/opt/doc/yawk/...
# Daemon startup scripts should be installed in $(YAWK_IPK_DIR)/opt/etc/init.d/S??yawk
#
# You may need to patch your application to make it use these locations.
#
$(YAWK_IPK): $(YAWK_BUILD_DIR)/.built
	rm -rf $(YAWK_IPK_DIR) $(BUILD_DIR)/yawk_*_$(TARGET_ARCH).ipk
	install -d \
		$(YAWK_IPK_DIR)/opt/etc/yawk \
		$(YAWK_IPK_DIR)/opt/share/www/cgi-bin \
		$(YAWK_IPK_DIR)/opt/lib/yawk \
		;
	install $(YAWK_BUILD_DIR)/yawk.conf \
		$(YAWK_IPK_DIR)/opt/etc/yawk
	install $(YAWK_BUILD_DIR)/wiki.cgi \
		$(YAWK_IPK_DIR)/opt/share/www/cgi-bin/
	install $(YAWK_BUILD_DIR)/wiki-parser \
		$(YAWK_BUILD_DIR)/wiki-receiver \
		$(YAWK_BUILD_DIR)/wiki-relsearch \
		$(YAWK_IPK_DIR)/opt/lib/yawk/
	install -d $(YAWK_IPK_DIR)/opt/share/yawk-wikispace/wiki-wiki
	echo "dir	/opt/share/yawk-wikispace/wiki-wiki" \
		> $(YAWK_IPK_DIR)/opt/etc/yawk/wiki-wiki.conf
	chmod -R 777 $(YAWK_IPK_DIR)/opt/share/yawk-wikispace
	$(MAKE) $(YAWK_IPK_DIR)/CONTROL/control
	echo $(YAWK_CONFFILES) | sed -e 's/ /\n/g' > $(YAWK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(YAWK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
yawk-ipk: $(YAWK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
yawk-clean:
	rm -f $(YAWK_BUILD_DIR)/.built
	-$(MAKE) -C $(YAWK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
yawk-dirclean:
	rm -rf $(BUILD_DIR)/$(YAWK_DIR) $(YAWK_BUILD_DIR) $(YAWK_IPK_DIR) $(YAWK_IPK)
#
#
# Some sanity check for the package.
#
yawk-check: $(YAWK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(YAWK_IPK)
