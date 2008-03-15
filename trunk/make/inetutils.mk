###########################################################
#
# inetutils
#
###########################################################

# You must replace "inetutils" and "INETUTILS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# INETUTILS_VERSION, INETUTILS_SITE and INETUTILS_SOURCE define
# the upstream location of the source code for the package.
# INETUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# INETUTILS_UNZIP is the command used to unzip the source.
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
INETUTILS_NAME=inetutils
INETUTILS_SITE=ftp://ftp.gnu.org/pub/gnu/inetutils
ifneq ($(OPTWARE_TARGET), wl500g)
INETUTILS_VERSION=1.5
INETUTILS_IPK_VERSION=5
else
INETUTILS_VERSION=1.4.2
INETUTILS_IPK_VERSION=10
endif
INETUTILS_SOURCE=$(INETUTILS_NAME)-$(INETUTILS_VERSION).tar.gz
INETUTILS_DIR=$(INETUTILS_NAME)-$(INETUTILS_VERSION)
INETUTILS_UNZIP=zcat
INETUTILS_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
INETUTILS_DESCRIPTION=A set of common daemons and clients found on commercial UNIX systems.
INETUTILS_SECTION=net
INETUTILS_PRIORITY=optional
INETUTILS_DEPENDS=ncurses, zlib, readline


#
# INETUTILS_CONFFILES should be a list of user-editable files
INETUTILS_CONFFILES=

#
# INETUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
INETUTILS_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
INETUTILS_CPPFLAGS=
INETUTILS_LDFLAGS=

#
# INETUTILS_BUILD_DIR is the directory in which the build is done.
# INETUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# INETUTILS_IPK_DIR is the directory in which the ipk is built.
# INETUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
INETUTILS_BUILD_DIR=$(BUILD_DIR)/inetutils
INETUTILS_SOURCE_DIR=$(SOURCE_DIR)/inetutils
INETUTILS_IPK_DIR=$(BUILD_DIR)/inetutils-$(INETUTILS_VERSION)-ipk
INETUTILS_IPK=$(BUILD_DIR)/inetutils_$(INETUTILS_VERSION)-$(INETUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: inetutils-source inetutils-unpack inetutils inetutils-stage inetutils-ipk inetutils-clean inetutils-dirclean inetutils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(INETUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(INETUTILS_SITE)/$(INETUTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
inetutils-source: $(DL_DIR)/$(INETUTILS_SOURCE) $(INETUTILS_PATCHES)

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
$(INETUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(INETUTILS_SOURCE) $(INETUTILS_PATCHES) make/inetutils.mk
	$(MAKE) ncurses-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(INETUTILS_DIR) $(INETUTILS_BUILD_DIR)
	$(INETUTILS_UNZIP) $(DL_DIR)/$(INETUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(INETUTILS_DIR) $(INETUTILS_BUILD_DIR)
	(cd $(INETUTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(INETUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(INETUTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--infodir=/opt/doc/inetutils \
		--mandir=/opt/share/man \
		--with-ncurses \
		--with-ncurses-include-dir=$(STAGING_INCLUDE_DIR)/ncurses \
		--program-prefix="" \
	)
	touch $@

inetutils-unpack: $(INETUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(INETUTILS_BUILD_DIR)/.built: $(INETUTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(INETUTILS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
inetutils: $(INETUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(INETUTILS_BUILD_DIR)/.staged: $(INETUTILS_BUILD_DIR)/.built
	rm -f $@
	touch $@

inetutils-stage: $(INETUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/inetutils
#
$(INETUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: $(INETUTILS_NAME)" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(INETUTILS_PRIORITY)" >>$@
	@echo "Section: $(INETUTILS_SECTION)" >>$@
	@echo "Version: $(INETUTILS_VERSION)-$(INETUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(INETUTILS_MAINTAINER)" >>$@
	@echo "Source: $(INETUTILS_SITE)/$(INETUTILS_SOURCE)" >>$@
	@echo "Description: $(INETUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(INETUTILS_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(INETUTILS_IPK_DIR)/opt/sbin or $(INETUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(INETUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(INETUTILS_IPK_DIR)/opt/etc/inetutils/...
# Documentation files should be installed in $(INETUTILS_IPK_DIR)/opt/doc/inetutils/...
# Daemon startup scripts should be installed in $(INETUTILS_IPK_DIR)/opt/etc/init.d/S??inetutils
#
# You may need to patch your application to make it use these locations.
#
$(INETUTILS_IPK): $(INETUTILS_BUILD_DIR)/.built
	rm -rf $(INETUTILS_IPK_DIR) $(BUILD_DIR)/inetutils_*_$(TARGET_ARCH).ipk
	# Install everything
	$(MAKE) -C $(INETUTILS_BUILD_DIR) DESTDIR=$(INETUTILS_IPK_DIR) install
	# Remove the stuff we don't want: inetd, whois, ftpd
	rm -f $(INETUTILS_IPK_DIR)/opt/libexec/inetd
	rm -f $(INETUTILS_IPK_DIR)/opt/share/man/man8/inetd.8
	rm -f $(INETUTILS_IPK_DIR)/opt/bin/whois
	rm -f $(INETUTILS_IPK_DIR)/opt/share/man/man8/ftpd.8
	rm -f $(INETUTILS_IPK_DIR)/opt/libexec/ftpd
	$(STRIP_COMMAND) $(INETUTILS_IPK_DIR)/opt/bin/* $(INETUTILS_IPK_DIR)/opt/libexec/*
#	install -d $(INETUTILS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(INETUTILS_SOURCE_DIR)/rc.inetutils $(INETUTILS_IPK_DIR)/opt/etc/init.d/S52inetd
	$(MAKE) $(INETUTILS_IPK_DIR)/CONTROL/control
	# Setuid stuff doesn't work as non-root, but we fix it in the postinst script.
	install -m 644 $(INETUTILS_SOURCE_DIR)/postinst  $(INETUTILS_IPK_DIR)/CONTROL/postinst 
	echo "#!/bin/sh" > $(INETUTILS_IPK_DIR)/CONTROL/prerm
	for d in /opt/bin /opt/libexec /opt/share/man/man1 /opt/share/man/man8; do \
	    cd $(INETUTILS_IPK_DIR)/$$d; \
	    for f in *; do \
		mv $$f inetutils-$$f; \
		echo "update-alternatives --install $$d/$$f $$f $$d/inetutils-$$f 70" \
		    >> $(INETUTILS_IPK_DIR)/CONTROL/postinst; \
		echo "update-alternatives --remove $$f $$d/inetutils-$$f" \
		    >> $(INETUTILS_IPK_DIR)/CONTROL/prerm; \
	    done; \
	done
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(INETUTILS_IPK_DIR)/CONTROL/postinst $(INETUTILS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(INETUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(INETUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(INETUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
inetutils-ipk: $(INETUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
inetutils-clean:
	-$(MAKE) -C $(INETUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
inetutils-dirclean:
	rm -rf $(BUILD_DIR)/$(INETUTILS_DIR) $(INETUTILS_BUILD_DIR) $(INETUTILS_IPK_DIR) $(INETUTILS_IPK)
#
#
# Some sanity check for the package.
#
inetutils-check: $(INETUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(INETUTILS_IPK)
