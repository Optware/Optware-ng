###########################################################
#
# mzscheme
#
###########################################################

# You must replace "mzscheme" and "MZSCHEME" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MZSCHEME_VERSION, MZSCHEME_SITE and MZSCHEME_SOURCE define
# the upstream location of the source code for the package.
# MZSCHEME_DIR is the directory which is created when the source
# archive is unpacked.
# MZSCHEME_UNZIP is the command used to unzip the source.
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
MZSCHEME_VERSION=209
MZSCHEME_SITE=http://download.plt-scheme.org/bundles/$(MZSCHEME_VERSION)/mz/
MZSCHEME_SOURCE=mz-$(MZSCHEME_VERSION)-src-unix.tgz
MZSCHEME_DIR=plt
MZSCHEME_UNZIP=zcat
MZSCHEME_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
MZSCHEME_DESCRIPTION=MzScheme is the lightweight, embeddable, scripting-friendly PLT Scheme implementation.
MZSCHEME_SECTION=misc
MZSCHEME_PRIORITY=optional
MZSCHEME_DEPENDS=

#
# MZSCHEME_IPK_VERSION should be incremented when the ipk changes.
#
MZSCHEME_IPK_VERSION=1

#
# MZSCHEME_CONFFILES should be a list of user-editable files
# MZSCHEME_CONFFILES=/opt/etc/mzscheme.conf /opt/etc/init.d/SXXmzscheme

#
# MZSCHEME_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MZSCHEME_PATCHES=$(MZSCHEME_SOURCE_DIR)/configure.patch
	#$(MZSCHEME_SOURCE_DIR)/install-script.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MZSCHEME_CPPFLAGS=
MZSCHEME_LDFLAGS=

#
# MZSCHEME_BUILD_DIR is the directory in which the build is done.
# MZSCHEME_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MZSCHEME_IPK_DIR is the directory in which the ipk is built.
# MZSCHEME_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MZSCHEME_BUILD_DIR=$(BUILD_DIR)/mzscheme
MZSCHEME_SOURCE_DIR=$(SOURCE_DIR)/mzscheme
MZSCHEME_IPK_DIR=$(BUILD_DIR)/mzscheme-$(MZSCHEME_VERSION)-ipk
MZSCHEME_IPK=$(BUILD_DIR)/mzscheme_$(MZSCHEME_VERSION)-$(MZSCHEME_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MZSCHEME_SOURCE):
	$(WGET) -P $(DL_DIR) $(MZSCHEME_SITE)/$(MZSCHEME_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mzscheme-source: $(DL_DIR)/$(MZSCHEME_SOURCE) $(MZSCHEME_PATCHES)

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
$(MZSCHEME_BUILD_DIR)/.configured: $(DL_DIR)/$(MZSCHEME_SOURCE) $(MZSCHEME_PATCHES)
	# $(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MZSCHEME_DIR) $(MZSCHEME_BUILD_DIR)
	$(MZSCHEME_UNZIP) $(DL_DIR)/$(MZSCHEME_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(MZSCHEME_PATCHES) | patch -d $(BUILD_DIR)/$(MZSCHEME_DIR) -p1
	mv $(BUILD_DIR)/$(MZSCHEME_DIR) $(MZSCHEME_BUILD_DIR)
	(cd $(MZSCHEME_BUILD_DIR)/src; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MZSCHEME_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MZSCHEME_LDFLAGS)" \
		CC_FOR_BUILD="$(HOSTCC)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(MZSCHEME_BUILD_DIR)/.configured

mzscheme-unpack: $(MZSCHEME_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MZSCHEME_BUILD_DIR)/.built: $(MZSCHEME_BUILD_DIR)/.configured
	rm -f $(MZSCHEME_BUILD_DIR)/.built
	$(MAKE) -C $(MZSCHEME_BUILD_DIR)/src
	touch $(MZSCHEME_BUILD_DIR)/.built

#
# This is the build convenience target.
#
mzscheme: $(MZSCHEME_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MZSCHEME_BUILD_DIR)/.staged: $(MZSCHEME_BUILD_DIR)/.built
	rm -f $(MZSCHEME_BUILD_DIR)/.staged
	$(MAKE) -C $(MZSCHEME_BUILD_DIR)/src prefix=$(STAGING_DIR) install
	touch $(MZSCHEME_BUILD_DIR)/.staged

mzscheme-stage: $(MZSCHEME_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mzscheme
#
$(MZSCHEME_IPK_DIR)/CONTROL/control:
	@install -d $(MZSCHEME_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: mzscheme" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MZSCHEME_PRIORITY)" >>$@
	@echo "Section: $(MZSCHEME_SECTION)" >>$@
	@echo "Version: $(MZSCHEME_VERSION)-$(MZSCHEME_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MZSCHEME_MAINTAINER)" >>$@
	@echo "Source: $(MZSCHEME_SITE)/$(MZSCHEME_SOURCE)" >>$@
	@echo "Description: $(MZSCHEME_DESCRIPTION)" >>$@
	@echo "Depends: $(MZSCHEME_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MZSCHEME_IPK_DIR)/opt/sbin or $(MZSCHEME_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MZSCHEME_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MZSCHEME_IPK_DIR)/opt/etc/mzscheme/...
# Documentation files should be installed in $(MZSCHEME_IPK_DIR)/opt/doc/mzscheme/...
# Daemon startup scripts should be installed in $(MZSCHEME_IPK_DIR)/opt/etc/init.d/S??mzscheme
#
# You may need to patch your application to make it use these locations.
#
$(MZSCHEME_IPK): $(MZSCHEME_BUILD_DIR)/.built
	rm -rf $(MZSCHEME_IPK_DIR) $(BUILD_DIR)/mzscheme_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MZSCHEME_BUILD_DIR)/src prefix=$(MZSCHEME_IPK_DIR)/opt install
	sed -i \
	    -e '/^CC=/s:^.*$$:CC=/opt/bin/gcc:' \
	    -e 's:$(STAGING_DIR)::' \
	    $(MZSCHEME_IPK_DIR)/opt/lib/buildinfo
	# a hack to work around POSIX tar 100 character limitation
	cd $(MZSCHEME_IPK_DIR)/opt/mzscheme; \
	    mv collects/web-server/default-web-root .
	$(MAKE) $(MZSCHEME_IPK_DIR)/CONTROL/control
	install -m 755 $(MZSCHEME_SOURCE_DIR)/postinst $(MZSCHEME_IPK_DIR)/CONTROL/postinst
	install -m 755 $(MZSCHEME_SOURCE_DIR)/prerm $(MZSCHEME_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MZSCHEME_IPK_DIR)


#
# This is called from the top level makefile to create the IPK file.
#
mzscheme-ipk: $(MZSCHEME_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mzscheme-clean:
	-$(MAKE) -C $(MZSCHEME_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mzscheme-dirclean:
	rm -rf $(BUILD_DIR)/$(MZSCHEME_DIR) $(MZSCHEME_BUILD_DIR) $(MZSCHEME_IPK_DIR) $(MZSCHEME_IPK)
