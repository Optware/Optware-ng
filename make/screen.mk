##########################################################
#
# screen
#
###########################################################

# You must replace "screen" and "SCREEN" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SCREEN_VERSION, SCREEN_SITE and SCREEN_SOURCE define
# the upstream location of the source code for the package.
# SCREEN_DIR is the directory which is created when the source
# archive is unpacked.
# SCREEN_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
SCREEN_SITE=ftp://ftp.uni-erlangen.de/pub/utilities/screen
# ftp://ftp.ibiblio.org/pub/mirrors/gnu/ftp/gnu/screen/
SCREEN_VERSION=4.0.3
SCREEN_SOURCE=screen-$(SCREEN_VERSION).tar.gz
SCREEN_DIR=screen-$(SCREEN_VERSION)
SCREEN_UNZIP=zcat
SCREEN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SCREEN_DESCRIPTION=A screen manager that supports multiple logins on single terminal
SCREEN_SECTION=term
SCREEN_PRIORITY=optional
SCREEN_DEPENDS=termcap
SCREEN_SUGGESTS=
SCREEN_CONFLICTS=

#
# SCREEN_IPK_VERSION should be incremented when the ipk changes.
#
SCREEN_IPK_VERSION=2

#
# SCREEN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SCREEN_PATCHES=$(SCREEN_SOURCE_DIR)/configure.patch 

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SCREEN_CPPFLAGS=
SCREEN_LDFLAGS=

#
# SCREEN_BUILD_DIR is the directory in which the build is done.
# SCREEN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SCREEN_IPK_DIR is the directory in which the ipk is built.
# SCREEN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SCREEN_BUILD_DIR=$(BUILD_DIR)/screen
SCREEN_SOURCE_DIR=$(SOURCE_DIR)/screen
SCREEN_IPK_DIR=$(BUILD_DIR)/screen-$(SCREEN_VERSION)-ipk
SCREEN_IPK=$(BUILD_DIR)/screen_$(SCREEN_VERSION)-$(SCREEN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: screen-source screen-unpack screen screen-stage screen-ipk screen-clean screen-dirclean screen-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SCREEN_SOURCE):
	$(WGET) -P $(DL_DIR) $(SCREEN_SITE)/$(SCREEN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
screen-source: $(DL_DIR)/$(SCREEN_SOURCE) $(SCREEN_PATCHES)

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
$(SCREEN_BUILD_DIR)/.configured: $(DL_DIR)/$(SCREEN_SOURCE) $(SCREEN_PATCHES)
	$(MAKE) termcap-stage
	rm -rf $(BUILD_DIR)/$(SCREEN_DIR) $(SCREEN_BUILD_DIR)
	$(SCREEN_UNZIP) $(DL_DIR)/$(SCREEN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(SCREEN_PATCHES) | patch -d $(BUILD_DIR)/$(SCREEN_DIR) 
	mv $(BUILD_DIR)/$(SCREEN_DIR) $(SCREEN_BUILD_DIR)
	(cd $(SCREEN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SCREEN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SCREEN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-pam \
		--prefix=/opt \
	)
ifeq ($(LIBC_STYLE),uclibc)
		sed -i -e '/stropts.h/d' $(SCREEN_BUILD_DIR)/pty.c
endif
ifeq ($(OPTWARE_TARGET), $(filter openwrt-brcm24 openwrt-ixp4xx ts101, $(OPTWARE_TARGET)))
	sed -i -e 's/sched.h/screen_sched.h/g' \
		$(SCREEN_BUILD_DIR)/Makefile \
		$(SCREEN_BUILD_DIR)/screen.h
	mv $(SCREEN_BUILD_DIR)/sched.h $(SCREEN_BUILD_DIR)/screen_sched.h
endif
	touch $(SCREEN_BUILD_DIR)/.configured

screen-unpack: $(SCREEN_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(SCREEN_BUILD_DIR)/screen: $(SCREEN_BUILD_DIR)/.configured
	$(MAKE) -C $(SCREEN_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
screen: $(SCREEN_BUILD_DIR)/screen

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libscreen.so.$(SCREEN_VERSION): $(SCREEN_BUILD_DIR)/libscreen.so.$(SCREEN_VERSION)
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(SCREEN_BUILD_DIR)/screen.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(SCREEN_BUILD_DIR)/libscreen.a $(STAGING_DIR)/opt/lib
	install -m 644 $(SCREEN_BUILD_DIR)/libscreen.so.$(SCREEN_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libscreen.so.$(SCREEN_VERSION) libscreen.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libscreen.so.$(SCREEN_VERSION) libscreen.so

screen-stage: $(STAGING_DIR)/opt/lib/libscreen.so.$(SCREEN_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/screen
#
$(SCREEN_IPK_DIR)/CONTROL/control:
	@install -d $(SCREEN_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: screen" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SCREEN_PRIORITY)" >>$@
	@echo "Section: $(SCREEN_SECTION)" >>$@
	@echo "Version: $(SCREEN_VERSION)-$(SCREEN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SCREEN_MAINTAINER)" >>$@
	@echo "Source: $(SCREEN_SITE)/$(SCREEN_SOURCE)" >>$@
	@echo "Description: $(SCREEN_DESCRIPTION)" >>$@
	@echo "Depends: $(SCREEN_DEPENDS)" >>$@
	@echo "Suggests: $(SCREEN_SUGGESTS)" >>$@
	@echo "Conflicts: $(SCREEN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SCREEN_IPK_DIR)/opt/sbin or $(SCREEN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SCREEN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SCREEN_IPK_DIR)/opt/etc/screen/...
# Documentation files should be installed in $(SCREEN_IPK_DIR)/opt/doc/screen/...
# Daemon startup scripts should be installed in $(SCREEN_IPK_DIR)/opt/etc/init.d/S??screen
#
# You may need to patch your application to make it use these locations.
#
$(SCREEN_IPK): $(SCREEN_BUILD_DIR)/screen
	rm -rf $(SCREEN_IPK_DIR) $(BUILD_DIR)/screen_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SCREEN_BUILD_DIR) DESTDIR=$(SCREEN_IPK_DIR) install
	$(STRIP_COMMAND) $(SCREEN_IPK_DIR)/opt/bin/screen-$(SCREEN_VERSION)
	rm -f $(SCREEN_IPK_DIR)/opt/info/dir{,.old}
#	install -d $(SCREEN_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SCREEN_SOURCE_DIR)/rc.screen $(SCREEN_IPK_DIR)/opt/etc/init.d/SXXscreen
	$(MAKE) $(SCREEN_IPK_DIR)/CONTROL/control
	install -m 644 $(SCREEN_SOURCE_DIR)/postinst $(SCREEN_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(SCREEN_SOURCE_DIR)/prerm $(SCREEN_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SCREEN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
screen-ipk: $(SCREEN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
screen-clean:
	-$(MAKE) -C $(SCREEN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
screen-dirclean:
	rm -rf $(BUILD_DIR)/$(SCREEN_DIR) $(SCREEN_BUILD_DIR) $(SCREEN_IPK_DIR) $(SCREEN_IPK)

#
# Some sanity check for the package.
#
screen-check: $(SCREEN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SCREEN_IPK)
