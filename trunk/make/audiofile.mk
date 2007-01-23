###########################################################
#
# audiofile
#
###########################################################

# You must replace "audiofile" and "AUDIOFILE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# AUDIOFILE_VERSION, AUDIOFILE_SITE and AUDIOFILE_SOURCE define
# the upstream location of the source code for the package.
# AUDIOFILE_DIR is the directory which is created when the source
# archive is unpacked.
# AUDIOFILE_UNZIP is the command used to unzip the source.
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
#http://ftp.acc.umu.se/pub/GNOME/sources/audiofile/0.2/audiofile-0.2.6.tar.gz
AUDIOFILE_SITE=http://ftp.acc.umu.se/pub/GNOME/sources/audiofile/0.2
AUDIOFILE_VERSION=0.2.6
AUDIOFILE_SOURCE=audiofile-$(AUDIOFILE_VERSION).tar.gz
AUDIOFILE_DIR=audiofile-$(AUDIOFILE_VERSION)
AUDIOFILE_UNZIP=zcat
AUDIOFILE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AUDIOFILE_DESCRIPTION=Misc Audio Libraries.
AUDIOFILE_SECTION=misc
AUDIOFILE_PRIORITY=optional
AUDIOFILE_DEPENDS=
AUDIOFILE_CONFLICTS=

#
# AUDIOFILE_IPK_VERSION should be incremented when the ipk changes.
#
AUDIOFILE_IPK_VERSION=6

#
# AUDIOFILE_CONFFILES should be a list of user-editable files
AUDIOFILE_CONFFILES=#/opt/etc/audiofile.conf /opt/etc/init.d/SXXaudiofile

#
# AUDIOFILE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
AUDIOFILE_PATCHES=#$(AUDIOFILE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
AUDIOFILE_CPPFLAGS=
AUDIOFILE_LDFLAGS=

#
# AUDIOFILE_BUILD_DIR is the directory in which the build is done.
# AUDIOFILE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# AUDIOFILE_IPK_DIR is the directory in which the ipk is built.
# AUDIOFILE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
AUDIOFILE_BUILD_DIR=$(BUILD_DIR)/audiofile
AUDIOFILE_SOURCE_DIR=$(SOURCE_DIR)/audiofile
AUDIOFILE_IPK_DIR=$(BUILD_DIR)/audiofile-$(AUDIOFILE_VERSION)-ipk
AUDIOFILE_IPK=$(BUILD_DIR)/audiofile_$(AUDIOFILE_VERSION)-$(AUDIOFILE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(AUDIOFILE_SOURCE):
	$(WGET) -P $(DL_DIR) $(AUDIOFILE_SITE)/$(AUDIOFILE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
audiofile-source: $(DL_DIR)/$(AUDIOFILE_SOURCE) $(AUDIOFILE_PATCHES)

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
$(AUDIOFILE_BUILD_DIR)/.configured: $(DL_DIR)/$(AUDIOFILE_SOURCE) $(AUDIOFILE_PATCHES)
	rm -rf $(BUILD_DIR)/$(AUDIOFILE_DIR) $(AUDIOFILE_BUILD_DIR)
	$(AUDIOFILE_UNZIP) $(DL_DIR)/$(AUDIOFILE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(AUDIOFILE_PATCHES)" ; \
		then cat $(AUDIOFILE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(AUDIOFILE_DIR) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(AUDIOFILE_DIR) $(AUDIOFILE_BUILD_DIR)
#	ACLOCAL=aclocal-1.9 AUTOMAKE=automake-1.9 \
#		autoreconf -vif $(AUDIOFILE_BUILD_DIR)
	(cd $(AUDIOFILE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AUDIOFILE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AUDIOFILE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(AUDIOFILE_BUILD_DIR)/libtool
	touch $(AUDIOFILE_BUILD_DIR)/.configured

audiofile-unpack: $(AUDIOFILE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(AUDIOFILE_BUILD_DIR)/.built: $(AUDIOFILE_BUILD_DIR)/.configured
	rm -f $(AUDIOFILE_BUILD_DIR)/.built
	$(MAKE) -C $(AUDIOFILE_BUILD_DIR)
	touch $(AUDIOFILE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
audiofile: $(AUDIOFILE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(AUDIOFILE_BUILD_DIR)/.staged: $(AUDIOFILE_BUILD_DIR)/.built
	rm -f $(AUDIOFILE_BUILD_DIR)/.staged
	$(MAKE) -C $(AUDIOFILE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|echo $$includes|echo -I$(STAGING_INCLUDE_DIR)|' $(STAGING_PREFIX)/bin/audiofile-config
	cp $(STAGING_DIR)/opt/bin/audiofile-config $(STAGING_DIR)/bin/audiofile-config
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/audiofile.pc
	rm -f $(STAGING_LIB_DIR)/libaudiofile.la
	touch $(AUDIOFILE_BUILD_DIR)/.staged

audiofile-stage: $(AUDIOFILE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/audiofile
#
$(AUDIOFILE_IPK_DIR)/CONTROL/control:
	@install -d $(AUDIOFILE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: audiofile" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AUDIOFILE_PRIORITY)" >>$@
	@echo "Section: $(AUDIOFILE_SECTION)" >>$@
	@echo "Version: $(AUDIOFILE_VERSION)-$(AUDIOFILE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AUDIOFILE_MAINTAINER)" >>$@
	@echo "Source: $(AUDIOFILE_SITE)/$(AUDIOFILE_SOURCE)" >>$@
	@echo "Description: $(AUDIOFILE_DESCRIPTION)" >>$@
	@echo "Depends: $(AUDIOFILE_DEPENDS)" >>$@
	@echo "Conflicts: $(AUDIOFILE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(AUDIOFILE_IPK_DIR)/opt/sbin or $(AUDIOFILE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(AUDIOFILE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(AUDIOFILE_IPK_DIR)/opt/etc/audiofile/...
# Documentation files should be installed in $(AUDIOFILE_IPK_DIR)/opt/doc/audiofile/...
# Daemon startup scripts should be installed in $(AUDIOFILE_IPK_DIR)/opt/etc/init.d/S??audiofile
#
# You may need to patch your application to make it use these locations.
#
$(AUDIOFILE_IPK): $(AUDIOFILE_BUILD_DIR)/.built
	rm -rf $(AUDIOFILE_IPK_DIR) $(BUILD_DIR)/audiofile_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(AUDIOFILE_BUILD_DIR) DESTDIR=$(AUDIOFILE_IPK_DIR) install-strip
	$(MAKE) $(AUDIOFILE_IPK_DIR)/CONTROL/control
	echo $(AUDIOFILE_CONFFILES) | sed -e 's/ /\n/g' > $(AUDIOFILE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AUDIOFILE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
audiofile-ipk: $(AUDIOFILE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
audiofile-clean:
	-$(MAKE) -C $(AUDIOFILE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
audiofile-dirclean:
	rm -rf $(BUILD_DIR)/$(AUDIOFILE_DIR) $(AUDIOFILE_BUILD_DIR) $(AUDIOFILE_IPK_DIR) $(AUDIOFILE_IPK)
