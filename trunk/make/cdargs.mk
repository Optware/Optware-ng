###########################################################
#
# cdargs
# 
###########################################################
#
CDARGS_SITE=http://www.skamphausen.de/software/cdargs
CDARGS_VERSION=1.33
CDARGS_SOURCE=cdargs-$(CDARGS_VERSION).tar.gz
CDARGS_DIR=cdargs-$(CDARGS_VERSION)
CDARGS_UNZIP=zcat
CDARGS_MAINTAINER=Don Lubinski <nlsu2@shine-hs.com>
CDARGS_DESCRIPTION= CDargs heavily enhances the navigation of the common linux file-system inside the shell. It plugs into the shell built-in cd-command (via a shell function or an alias) and thus adds bookmarks and a browser to it. It enables you to move to a very distant place in the file-system with just a few keystrokes. This is the kind of thing that power shell users invent when even the almighty and wonderful TAB-completion is too much typing. (Just as a side-note: there exists TAB-completion for cdargs).
CDARGS_SECTION= Utility
CDARGS_DEPENDS=bash
CDARGS_PRIORITY=optional

#
# CDARGS_IPK_VERSION should be incremented when the ipk changes.
#
CDARGS_IPK_VERSION=1

#
# CDARGS_CONFFILES should be a list of user-editable files
# 


#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CDARGS_CPPFLAGS=
CDARGS_LDFLAGS=
CDARGS_CFLAGS=$(TARGET_CFLAGS) 

#
# CDARGS_BUILD_DIR is the directory in which the build is done.
# CDARGS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CDARGS_IPK_DIR is the directory in which the ipk is built.
# CDARGS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CDARGS_BUILD_DIR=$(BUILD_DIR)/cdargs
CDARGS_SOURCE_DIR=$(SOURCE_DIR)/cdargs
CDARGS_IPK_DIR=$(BUILD_DIR)/cdargs-$(CDARGS_VERSION)-ipk
CDARGS_IPK=$(BUILD_DIR)/cdargs_$(CDARGS_VERSION)-$(CDARGS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CDARGS_SOURCE):
	$(WGET) -P $(DL_DIR) $(CDARGS_SITE)/$(CDARGS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cdargs-source: $(DL_DIR)/$(CDARGS_SOURCE) 

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
$(CDARGS_BUILD_DIR)/.configured: $(DL_DIR)/$(CDARGS_SOURCE) 
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(CDARGS_DIR) $(CDARGS_BUILD_DIR)
	$(CDARGS_UNZIP) $(DL_DIR)/$(CDARGS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test "$(BUILD_DIR)/$(CDARGS_DIR)" != "$(CDARGS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CDARGS_DIR) $(CDARGS_BUILD_DIR) ; \
	fi
	(cd $(CDARGS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS)" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CDARGS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CDARGS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $(CDARGS_BUILD_DIR)/.configured

cdargs-unpack: $(CDARGS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CDARGS_BUILD_DIR)/.built: $(CDARGS_BUILD_DIR)/.configured
	rm -f $(CDARGS_BUILD_DIR)/.built
	$(MAKE) -C $(CDARGS_BUILD_DIR)
	touch $(CDARGS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
cdargs: $(CDARGS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CDARGS_BUILD_DIR)/.staged: $(CDARGS_BUILD_DIR)/.built
	rm -f $(CDARGS_BUILD_DIR)/.staged
	$(MAKE) -C $(CDARGS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CDARGS_BUILD_DIR)/.staged

cdargs-stage: $(CDARGS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cdargs
#
$(CDARGS_IPK_DIR)/CONTROL/control:
	@install -d $(CDARGS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: cdargs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CDARGS_PRIORITY)" >>$@
	@echo "Section: $(CDARGS_SECTION)" >>$@
	@echo "Version: $(CDARGS_VERSION)-$(CDARGS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CDARGS_MAINTAINER)" >>$@
	@echo "Source: $(CDARGS_SITE)/$(CDARGS_SOURCE)" >>$@
	@echo "Description: $(CDARGS_DESCRIPTION)" >>$@
#
#
# This builds the IPK file.
#
# Binaries should be installed into $(CDARGS_IPK_DIR)/opt/sbin or $(CDARGS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CDARGS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CDARGS_IPK_DIR)/opt/etc/cdargs/...
# Documentation files should be installed in $(CDARGS_IPK_DIR)/opt/doc/cdargs/...
# Daemon startup scripts should be installed in $(CDARGS_IPK_DIR)/opt/etc/init.d/S??cdargs
#
# You may need to patch your application to make it use these locations.
#
$(CDARGS_IPK): $(CDARGS_BUILD_DIR)/.built
	rm -rf $(CDARGS_IPK_DIR) $(BUILD_DIR)/cdargs_*_$(TARGET_ARCH).ipk
	install -d $(CDARGS_IPK_DIR)/opt/var/lib/cdargs
	install -m 755 $(CDARGS_BUILD_DIR)/contrib/cdargs-bash.sh $(CDARGS_IPK_DIR)/opt/var/lib/cdargs	
	install -d $(CDARGS_IPK_DIR)/opt/bin
	install -m 755 $(CDARGS_BUILD_DIR)/src/cdargs $(CDARGS_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(CDARGS_IPK_DIR)/opt/bin/*
	install -d $(CDARGS_IPK_DIR)/opt/man/man1
	install -m 644 $(CDARGS_BUILD_DIR)/doc/cdargs.1 $(CDARGS_IPK_DIR)/opt/man/man1
	$(MAKE) $(CDARGS_IPK_DIR)/CONTROL/control
	echo $(CDARGS_CONFFILES) | sed -e 's/ /\n/g' > $(CDARGS_IPK_DIR)/CONTROL/conffiles
	install -m 644 $(CDARGS_SOURCE_DIR)/postinst $(CDARGS_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CDARGS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cdargs-ipk: $(CDARGS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cdargs-clean:
	rm -f $(CDARGS_BUILD_DIR)/.built
	-$(MAKE) -C $(CDARGS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cdargs-dirclean:
	rm -rf $(BUILD_DIR)/$(CDARGS_DIR) $(CDARGS_BUILD_DIR) $(CDARGS_IPK_DIR) $(CDARGS_IPK)
