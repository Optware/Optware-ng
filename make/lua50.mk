###########################################################
#
# lua50
#
###########################################################

# You must replace "lua50" and "LUA50" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LUA50_VERSION, LUA50_SITE and LUA50_SOURCE define
# the upstream location of the source code for the package.
# LUA50_DIR is the directory which is created when the source
# archive is unpacked.
# LUA50_UNZIP is the command used to unzip the source.
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
LUA50_SITE=http://www.lua.org/ftp
LUA50_VERSION=5.0.3
LUA50_SOURCE=lua-$(LUA50_VERSION).tar.gz
LUA50_DIR=lua-$(LUA50_VERSION)
LUA50_UNZIP=zcat
LUA50_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LUA50_DESCRIPTION=Lua is a powerful light-weight programming language designed for extending applications.
LUA50_SECTION=misc
LUA50_PRIORITY=optional
LUA50_DEPENDS=

#
# LUA50_IPK_VERSION should be incremented when the ipk changes.
#
LUA50_IPK_VERSION=1

#
# LUA50_CONFFILES should be a list of user-editable files
# LUA50_CONFFILES=/opt/etc/lua50.conf /opt/etc/init.d/SXXlua50

#
# LUA50_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LUA50_PATCHES=$(LUA50_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LUA50_CPPFLAGS=
LUA50_LDFLAGS=

#
# LUA50_BUILD_DIR is the directory in which the build is done.
# LUA50_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LUA50_IPK_DIR is the directory in which the ipk is built.
# LUA50_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LUA50_BUILD_DIR=$(BUILD_DIR)/lua50
LUA50_SOURCE_DIR=$(SOURCE_DIR)/lua50
LUA50_IPK_DIR=$(BUILD_DIR)/lua50-$(LUA50_VERSION)-ipk
LUA50_IPK=$(BUILD_DIR)/lua50_$(LUA50_VERSION)-$(LUA50_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lua50-source lua50-unpack lua50 lua50-stage lua50-ipk lua50-clean lua50-dirclean lua50-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LUA50_SOURCE):
	$(WGET) -P $(DL_DIR) $(LUA50_SITE)/$(LUA50_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lua50-source: $(DL_DIR)/$(LUA50_SOURCE) $(LUA50_PATCHES)

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
$(LUA50_BUILD_DIR)/.configured: $(DL_DIR)/$(LUA50_SOURCE) $(LUA50_PATCHES)
	rm -rf $(BUILD_DIR)/$(LUA50_DIR) $(LUA50_BUILD_DIR)
	$(LUA50_UNZIP) $(DL_DIR)/$(LUA50_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LUA50_DIR) $(LUA50_BUILD_DIR)
	(cd $(LUA50_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS); export CC GCC LD STRIP RANLIB AR; \
		sed -i \
		    -e 's:/usr/local:/opt:g' \
		    -e "s:^CC=.*$$:CC=$$CC:g" \
		    -e "s:^AR=.*$$:AR=$$AR rcu:g" \
		    -e "s:^RANLIB=.*$$:RANLIB=$$RANLIB:g" \
		    -e "s:^STRIP=.*$$:STRIP=$$STRIP:g" \
		    config; \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LUA50_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LUA50_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(LUA50_BUILD_DIR)/.configured

lua50-unpack: $(LUA50_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LUA50_BUILD_DIR)/.built: $(LUA50_BUILD_DIR)/.configured
	rm -f $(LUA50_BUILD_DIR)/.built
	$(MAKE) -C $(LUA50_BUILD_DIR)
	touch $(LUA50_BUILD_DIR)/.built

#
# This is the build convenience target.
#
lua50: $(LUA50_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LUA50_BUILD_DIR)/.staged: $(LUA50_BUILD_DIR)/.built
	rm -f $(LUA50_BUILD_DIR)/.staged
	(cd $(LUA50_BUILD_DIR); \
		install -m 0644 include/*.h $(STAGING_DIR)/opt/include; \
		install -m 0644 lib/*.a $(STAGING_DIR)/opt/lib; \
	)
	touch $(LUA50_BUILD_DIR)/.staged

lua50-stage: $(LUA50_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lua50
#
$(LUA50_IPK_DIR)/CONTROL/control:
	@install -d $(LUA50_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: lua50" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LUA50_PRIORITY)" >>$@
	@echo "Section: $(LUA50_SECTION)" >>$@
	@echo "Version: $(LUA50_VERSION)-$(LUA50_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LUA50_MAINTAINER)" >>$@
	@echo "Source: $(LUA50_SITE)/$(LUA50_SOURCE)" >>$@
	@echo "Description: $(LUA50_DESCRIPTION)" >>$@
	@echo "Depends: $(LUA50_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LUA50_IPK_DIR)/opt/sbin or $(LUA50_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LUA50_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LUA50_IPK_DIR)/opt/etc/lua50/...
# Documentation files should be installed in $(LUA50_IPK_DIR)/opt/doc/lua50/...
# Daemon startup scripts should be installed in $(LUA50_IPK_DIR)/opt/etc/init.d/S??lua50
#
# You may need to patch your application to make it use these locations.
#
$(LUA50_IPK): $(LUA50_BUILD_DIR)/.built
	rm -rf $(LUA50_IPK_DIR) $(BUILD_DIR)/lua50_*_$(TARGET_ARCH).ipk
	(cd $(LUA50_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS); export STRIP; \
		$${STRIP} bin/*; \
		install -d $(LUA50_IPK_DIR)/opt/bin \
			$(LUA50_IPK_DIR)/opt/include \
			$(LUA50_IPK_DIR)/opt/lib \
			$(LUA50_IPK_DIR)/opt/man/man1; \
		install -m 0755 bin/* $(LUA50_IPK_DIR)/opt/bin; \
		install -m 0644 include/*.h $(LUA50_IPK_DIR)/opt/include; \
		install -m 0644 lib/*.a $(LUA50_IPK_DIR)/opt/lib; \
		install -m 0644 doc/*.1 $(LUA50_IPK_DIR)/opt/man/man1; \
	)
	for f in `find $(LUA50_IPK_DIR)/opt -type f`; do \
		d=`dirname $$f`; \
		b=`basename $$f`.; \
		newb=`echo $$b | sed -e 's/\./50./; s/\.$$//'`; \
		mv $$f $$d/$$newb; \
	done
	$(MAKE) $(LUA50_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LUA50_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lua50-ipk: $(LUA50_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lua50-clean:
	-$(MAKE) -C $(LUA50_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lua50-dirclean:
	rm -rf $(BUILD_DIR)/$(LUA50_DIR) $(LUA50_BUILD_DIR) $(LUA50_IPK_DIR) $(LUA50_IPK)

#
# Some sanity check for the package.
#
lua50-check: $(LUA50_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LUA50_IPK)
