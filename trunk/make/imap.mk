###########################################################
#
# imap
#
###########################################################

# You must replace "imap" and "IMAP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# IMAP_VERSION, IMAP_SITE and IMAP_SOURCE define
# the upstream location of the source code for the package.
# IMAP_DIR is the directory which is created when the source
# archive is unpacked.
# IMAP_UNZIP is the command used to unzip the source.
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
IMAP_SITE=ftp://ftp.cac.washington.edu/imap
IMAP_VERSION=2007a1
IMAP_SOURCE=imap-$(IMAP_VERSION).tar.Z
IMAP_DIR=imap-$(IMAP_VERSION)
IMAP_DIR=imap-2007a
IMAP_UNZIP=zcat
IMAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IMAP_DESCRIPTION=University of Washington IMAP package
IMAP_SECTION=net
IMAP_PRIORITY=optional
IMAP_DEPENDS=openssl
IMAP_SUGGESTS=
IMAP_CONFLICTS=

#
# IMAP_IPK_VERSION should be incremented when the ipk changes.
#
IMAP_IPK_VERSION=1

#
# IMAP_CONFFILES should be a list of user-editable files
IMAP_CONFFILES=

#
# IMAP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IMAP_PATCHES=$(IMAP_SOURCE_DIR)/shared-c-client.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IMAP_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/openssl
IMAP_LDFLAGS=

#
# IMAP_BUILD_DIR is the directory in which the build is done.
# IMAP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IMAP_IPK_DIR is the directory in which the ipk is built.
# IMAP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IMAP_BUILD_DIR=$(BUILD_DIR)/imap
IMAP_SOURCE_DIR=$(SOURCE_DIR)/imap
IMAP_IPK_DIR=$(BUILD_DIR)/imap-$(IMAP_VERSION)-ipk
IMAP_IPK=$(BUILD_DIR)/imap_$(IMAP_VERSION)-$(IMAP_IPK_VERSION)_$(TARGET_ARCH).ipk

IMAP_LIBS_IPK_DIR=$(BUILD_DIR)/imap-libs-$(IMAP_VERSION)-ipk
IMAP_LIBS_IPK=$(BUILD_DIR)/imap-libs_$(IMAP_VERSION)-$(IMAP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: imap-source imap-unpack imap imap-stage imap-ipk imap-clean imap-dirclean imap-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IMAP_SOURCE):
	$(WGET) -P $(DL_DIR) $(IMAP_SITE)/$(IMAP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
imap-source: $(DL_DIR)/$(IMAP_SOURCE) $(IMAP_PATCHES)

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
$(IMAP_BUILD_DIR)/.configured: $(DL_DIR)/$(IMAP_SOURCE) $(IMAP_PATCHES)
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(IMAP_DIR) $(IMAP_BUILD_DIR)
	$(IMAP_UNZIP) $(DL_DIR)/$(IMAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(IMAP_DIR) $(IMAP_BUILD_DIR)
	cat $(IMAP_PATCHES) | patch -d $(IMAP_BUILD_DIR) -p1
	sed -i -e 's!/usr!/opt!g' $(IMAP_BUILD_DIR)/src/osdep/unix/Makefile
	sed -i -e 's!/var!/opt/var!g' $(IMAP_BUILD_DIR)/src/osdep/unix/Makefile
	touch $(IMAP_BUILD_DIR)/.configured

imap-unpack: $(IMAP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IMAP_BUILD_DIR)/.built: $(IMAP_BUILD_DIR)/.configured
	rm -f $(IMAP_BUILD_DIR)/.built
	$(MAKE) -C $(IMAP_BUILD_DIR) slx CC=$(TARGET_CC) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB) EXTRACFLAGS="$(STAGING_CPPFLAGS) $(IMAP_CPPFLAGS)" EXTRALDFLAGS="$(STAGING_LDFLAGS) $(IMAP_LDFLAGS)" SSLDIR=/opt SSLINCLUDE=$(STAGING_INCLUDE_DIR)/openssl SHLIBBASE=c-client SHLIBNAME=libc-client.so.0
	touch $(IMAP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
imap: $(IMAP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(IMAP_BUILD_DIR)/.staged: $(IMAP_BUILD_DIR)/.built
	rm -f $(IMAP_BUILD_DIR)/.staged
	install -d $(STAGING_INCLUDE_DIR)/imap
	cp $(IMAP_BUILD_DIR)/c-client/*.h $(STAGING_INCLUDE_DIR)/imap
	rm -f $(STAGING_LIB_DIR)/libc-client.so*
	cp -a $(IMAP_BUILD_DIR)/c-client/libc-client.so* $(STAGING_LIB_DIR)
	touch $(IMAP_BUILD_DIR)/.staged

imap-stage: $(IMAP_BUILD_DIR)/.staged

$(IMAP_IPK_DIR)/CONTROL/control:
	@install -d $(IMAP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: imap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IMAP_PRIORITY)" >>$@
	@echo "Section: $(IMAP_SECTION)" >>$@
	@echo "Version: $(IMAP_VERSION)-$(IMAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IMAP_MAINTAINER)" >>$@
	@echo "Source: $(IMAP_SITE)/$(IMAP_SOURCE)" >>$@
	@echo "Description: $(IMAP_DESCRIPTION)" >>$@
	@echo "Depends: $(IMAP_DEPENDS)" >>$@
	@echo "Suggests: $(IMAP_SUGGESTS)" >>$@
	@echo "Conflicts: $(IMAP_CONFLICTS)" >>$@

$(IMAP_LIBS_IPK_DIR)/CONTROL/control:
	@install -d $(IMAP_LIBS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: imap-libs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IMAP_PRIORITY)" >>$@
	@echo "Section: $(IMAP_SECTION)" >>$@
	@echo "Version: $(IMAP_VERSION)-$(IMAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IMAP_MAINTAINER)" >>$@
	@echo "Source: $(IMAP_SITE)/$(IMAP_SOURCE)" >>$@
	@echo "Description: $(IMAP_DESCRIPTION)" >>$@
	@echo "Depends: $(IMAP_DEPENDS)" >>$@
	@echo "Suggests: $(IMAP_SUGGESTS)" >>$@
	@echo "Conflicts: $(IMAP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IMAP_IPK_DIR)/opt/sbin or $(IMAP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IMAP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IMAP_IPK_DIR)/opt/etc/imap/...
# Documentation files should be installed in $(IMAP_IPK_DIR)/opt/doc/imap/...
# Daemon startup scripts should be installed in $(IMAP_IPK_DIR)/opt/etc/init.d/S??imap
#
# You may need to patch your application to make it use these locations.
#
$(IMAP_IPK): $(IMAP_BUILD_DIR)/.built
	# make imap-libs ipk
	rm -rf $(IMAP_LIBS_IPK_DIR) $(BUILD_DIR)/imap-libs_*_$(TARGET_ARCH).ipk
	$(MAKE) $(IMAP_LIBS_IPK_DIR)/CONTROL/control
	install -d $(IMAP_LIBS_IPK_DIR)/opt/lib
	cp -a $(IMAP_BUILD_DIR)/c-client/libc-client.so* $(IMAP_LIBS_IPK_DIR)/opt/lib
	chmod a+rx $(IMAP_LIBS_IPK_DIR)/opt/lib/*
	$(TARGET_STRIP) $(IMAP_LIBS_IPK_DIR)/opt/lib/libc-client.so.0
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IMAP_LIBS_IPK_DIR)
	# make main ipk
	rm -rf $(IMAP_IPK_DIR) $(BUILD_DIR)/imap_*_$(TARGET_ARCH).ipk
	$(MAKE) $(IMAP_IPK_DIR)/CONTROL/control
	install -d $(IMAP_IPK_DIR)/opt/bin
	install -m 755 $(IMAP_BUILD_DIR)/tmail/tmail $(IMAP_IPK_DIR)/opt/bin
	install -m 755 $(IMAP_BUILD_DIR)/dmail/dmail $(IMAP_IPK_DIR)/opt/bin
	install -d $(IMAP_IPK_DIR)/opt/sbin
	install -m 755 $(IMAP_BUILD_DIR)/imapd/imapd $(IMAP_IPK_DIR)/opt/sbin
	install -m 755 $(IMAP_BUILD_DIR)/ipopd/ipop2d $(IMAP_IPK_DIR)/opt/sbin
	install -m 755 $(IMAP_BUILD_DIR)/ipopd/ipop3d $(IMAP_IPK_DIR)/opt/sbin
	$(TARGET_STRIP) $(IMAP_IPK_DIR)/opt/sbin/* $(IMAP_IPK_DIR)/opt/bin/*
	### FIXME: could do with some setting up of the daemons here
	#install -d $(IMAP_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(IMAP_SOURCE_DIR)/rc.imap $(IMAP_IPK_DIR)/opt/etc/init.d/SXXimap
	#install -m 755 $(IMAP_SOURCE_DIR)/postinst $(IMAP_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(IMAP_SOURCE_DIR)/prerm $(IMAP_IPK_DIR)/CONTROL/prerm
	#echo $(IMAP_CONFFILES) | sed -e 's/ /\n/g' > $(IMAP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IMAP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
imap-ipk: $(IMAP_IPK) $(IMAP_LIBS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
imap-clean:
	rm -f $(IMAP_BUILD_DIR)/.built
	-$(MAKE) -C $(IMAP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
imap-dirclean:
	rm -rf $(BUILD_DIR)/$(IMAP_DIR) $(IMAP_BUILD_DIR)
	rm -rf $(IMAP_IPK_DIR) $(IMAP_IPK)
	rm -rf $(IMAP_LIBS_IPK_DIR) $(IMAP_LIBS_IPK)


#
# Some sanity check for the package.
#
imap-check: $(IMAP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IMAP_IPK) $(IMAP_LIBS_IPK)
