###########################################################
#
# Lumikki
#
###########################################################

# NOTE: LUA must be installed on the build host for this 
#       package to be buildt.

# LUMIKKI_VERSION, LUMIKKI_SITE and LUMIKKI_SOURCE define
# the upstream location of the source code for the package.
# LUMIKKI_DIR is the directory which is created when the source
# archive is unpacked.
# LUMIKKI_UNZIP is the command used to unzip the source.
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
LUMIKKI_SITE=http://luaforge.net/frs/download.php/1376
LUMIKKI_VERSION=0.20c
LUMIKKI_SOURCE=lumikki-$(LUMIKKI_VERSION).tgz
LUMIKKI_DIR=lumikki-$(LUMIKKI_VERSION)
LUMIKKI_UNZIP=zcat
LUMIKKI_MAINTAINER=Asko Kauppi <askok@dnainternet.net>
LUMIKKI_DESCRIPTION=XML/XHTML preprocessor using Lua scripting language.
LUMIKKI_SECTION=extras
LUMIKKI_PRIORITY=optional
LUMIKKI_DEPENDS=lua
LUMIKKI_SUGGESTS=imagemagick
LUMIKKI_CONFLICTS=

#
# LUMIKKI_IPK_VERSION should be incremented when the ipk changes.
#
LUMIKKI_IPK_VERSION=3

#
# LUMIKKI_CONFFILES should be a list of user-editable files
#LUMIKKI_CONFFILES=/opt/etc/lumikki.conf /opt/etc/init.d/SXXlumikki

#
# LUMIKKI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LUMIKKI_PATCHES=$(LUMIKKI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
#LUMIKKI_CPPFLAGS=
#LUMIKKI_LDFLAGS=

#
# LUMIKKI_BUILD_DIR is the directory in which the build is done.
# LUMIKKI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LUMIKKI_IPK_DIR is the directory in which the ipk is built.
# LUMIKKI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LUMIKKI_BUILD_DIR=$(BUILD_DIR)/lumikki
LUMIKKI_SOURCE_DIR=$(SOURCE_DIR)/lumikki
LUMIKKI_IPK_DIR=$(BUILD_DIR)/lumikki-$(LUMIKKI_VERSION)-ipk
LUMIKKI_IPK=$(BUILD_DIR)/lumikki_$(LUMIKKI_VERSION)-$(LUMIKKI_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LUMIKKI_SOURCE):
	$(WGET) -P $(DL_DIR) $(LUMIKKI_SITE)/$(LUMIKKI_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lumikki-source: $(DL_DIR)/$(LUMIKKI_SOURCE) $(LUMIKKI_PATCHES)

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
$(LUMIKKI_BUILD_DIR)/.configured: $(DL_DIR)/$(LUMIKKI_SOURCE) $(LUMIKKI_PATCHES)
	# $(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LUMIKKI_DIR) $(LUMIKKI_BUILD_DIR)
	$(LUMIKKI_UNZIP) $(DL_DIR)/$(LUMIKKI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LUMIKKI_PATCHES)" ; \
		then cat $(LUMIKKI_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LUMIKKI_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LUMIKKI_DIR)" != "$(LUMIKKI_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LUMIKKI_DIR) $(LUMIKKI_BUILD_DIR) ; \
	fi
#	(cd $(LUMIKKI_BUILD_DIR); \
#		$(TARGET_CONFIGURE_OPTS) \
#		CPPFLAGS="$(STAGING_CPPFLAGS) $(LUMIKKI_CPPFLAGS)" \
#		LDFLAGS="$(STAGING_LDFLAGS) $(LUMIKKI_LDFLAGS)" \
#		./configure \
#		--build=$(GNU_HOST_NAME) \
#		--host=$(GNU_TARGET_NAME) \
#		--target=$(GNU_TARGET_NAME) \
#		--prefix=/opt \
#		--disable-nls \
#		--disable-static \
#	)
#	$(PATCH_LIBTOOL) $(LUMIKKI_BUILD_DIR)/libtool
	touch $(LUMIKKI_BUILD_DIR)/.configured

lumikki-unpack: $(LUMIKKI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LUMIKKI_BUILD_DIR)/.built: $(LUMIKKI_BUILD_DIR)/.configured
	rm -f $(LUMIKKI_BUILD_DIR)/.built
	$(MAKE) -C $(LUMIKKI_BUILD_DIR) \
		manual.html
	touch $(LUMIKKI_BUILD_DIR)/.built

#
# This is the build convenience target.
#
lumikki: $(LUMIKKI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LUMIKKI_BUILD_DIR)/.staged: $(LUMIKKI_BUILD_DIR)/.built
	rm -f $(LUMIKKI_BUILD_DIR)/.staged
	$(MAKE) -C $(LUMIKKI_BUILD_DIR) DESTDIR=$(STAGING_DIR) \
		TRUE_DESTDIR=/opt MANDIR=$(DESTDIR)/man/man1 \
		DOCDIR=$(STAGING_DIR)/shared/docs \
		install
	touch $(LUMIKKI_BUILD_DIR)/.staged

lumikki-stage: $(LUMIKKI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lumikki
#
$(LUMIKKI_IPK_DIR)/CONTROL/control:
	@install -d $(LUMIKKI_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: lumikki" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LUMIKKI_PRIORITY)" >>$@
	@echo "Section: $(LUMIKKI_SECTION)" >>$@
	@echo "Version: $(LUMIKKI_VERSION)-$(LUMIKKI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LUMIKKI_MAINTAINER)" >>$@
	@echo "Source: $(LUMIKKI_SITE)/$(LUMIKKI_SOURCE)" >>$@
	@echo "Description: $(LUMIKKI_DESCRIPTION)" >>$@
	@echo "Depends: $(LUMIKKI_DEPENDS)" >>$@
	@echo "Suggests: $(LUMIKKI_SUGGESTS)" >>$@
	@echo "Conflicts: $(LUMIKKI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LUMIKKI_IPK_DIR)/opt/sbin or $(LUMIKKI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LUMIKKI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LUMIKKI_IPK_DIR)/opt/etc/lumikki/...
# Documentation files should be installed in $(LUMIKKI_IPK_DIR)/opt/doc/lumikki/...
# Daemon startup scripts should be installed in $(LUMIKKI_IPK_DIR)/opt/etc/init.d/S??lumikki
#
# You may need to patch your application to make it use these locations.
#
$(LUMIKKI_IPK): $(LUMIKKI_BUILD_DIR)/.built
	rm -rf $(LUMIKKI_IPK_DIR) $(BUILD_DIR)/lumikki_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LUMIKKI_BUILD_DIR) DESTDIR=$(LUMIKKI_IPK_DIR) \
		TRUE_DESTDIR=/opt MANDIR=$(LUMIKKI_IPK_DIR)/man/man1 \
		DOCDIR=$(LUMIKKI_IPK_DIR)/share/docs install-strip
	#install -d $(LUMIKKI_IPK_DIR)/opt/etc/
	#install -m 644 $(LUMIKKI_SOURCE_DIR)/lumikki.conf $(LUMIKKI_IPK_DIR)/opt/etc/lumikki.conf
	#install -d $(LUMIKKI_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(LUMIKKI_SOURCE_DIR)/rc.lumikki $(LUMIKKI_IPK_DIR)/opt/etc/init.d/SXXlumikki
	$(MAKE) $(LUMIKKI_IPK_DIR)/CONTROL/control
	#install -m 755 $(LUMIKKI_SOURCE_DIR)/postinst $(LUMIKKI_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(LUMIKKI_SOURCE_DIR)/prerm $(LUMIKKI_IPK_DIR)/CONTROL/prerm
	#echo $(LUMIKKI_CONFFILES) | sed -e 's/ /\n/g' > $(LUMIKKI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LUMIKKI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lumikki-ipk: $(LUMIKKI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lumikki-clean:
	rm -f $(LUMIKKI_BUILD_DIR)/.built
	-$(MAKE) -C $(LUMIKKI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lumikki-dirclean:
	rm -rf $(BUILD_DIR)/$(LUMIKKI_DIR) $(LUMIKKI_BUILD_DIR) $(LUMIKKI_IPK_DIR) $(LUMIKKI_IPK)
