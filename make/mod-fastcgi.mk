###########################################################
#
# mod-fastcgi
#
###########################################################

#
# MOD_FASTCGI_VERSION, MOD_FASTCGI_SITE and MOD_FASTCGI_SOURCE define
# the upstream location of the source code for the package.
# MOD_FASTCGI_DIR is the directory which is created when the source
# archive is unpacked.
# MOD_FASTCGI_UNZIP is the command used to unzip the source.
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
MOD_FASTCGI_SITE=http://www.fastcgi.com/dist
MOD_FASTCGI_VERSION=2.4.2
MOD_FASTCGI_SOURCE=mod_fastcgi-$(MOD_FASTCGI_VERSION).tar.gz
MOD_FASTCGI_DIR=mod_fastcgi-$(MOD_FASTCGI_VERSION)
MOD_FASTCGI_UNZIP=zcat
MOD_FASTCGI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MOD_FASTCGI_DESCRIPTION=mod_fastcgi is an Apache module providing language independent, scalable, open extension to CGI.
MOD_FASTCGI_SECTION=web
MOD_FASTCGI_PRIORITY=optional
MOD_FASTCGI_DEPENDS=apache
MOD_FASTCGI_SUGGESTS=
MOD_FASTCGI_CONFLICTS=

#
# MOD_FASTCGI_IPK_VERSION should be incremented when the ipk changes.
#
MOD_FASTCGI_IPK_VERSION=3

#
# MOD_FASTCGI_CONFFILES should be a list of user-editable files
MOD_FASTCGI_CONFFILES=/opt/etc/apache2/conf.d/mod_fastcgi.conf

#
# MOD_FASTCGI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MOD_FASTCGI_PATCHES=$(MOD_FASTCGI_SOURCE_DIR)/mod_fastcgi-apache-2.x.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MOD_FASTCGI_CPPFLAGS=
MOD_FASTCGI_LDFLAGS=

#
# MOD_FASTCGI_BUILD_DIR is the directory in which the build is done.
# MOD_FASTCGI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MOD_FASTCGI_IPK_DIR is the directory in which the ipk is built.
# MOD_FASTCGI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MOD_FASTCGI_BUILD_DIR=$(BUILD_DIR)/mod-fastcgi
MOD_FASTCGI_SOURCE_DIR=$(SOURCE_DIR)/mod-fastcgi
MOD_FASTCGI_IPK_DIR=$(BUILD_DIR)/mod-fastcgi-$(MOD_FASTCGI_VERSION)-ipk
MOD_FASTCGI_IPK=$(BUILD_DIR)/mod-fastcgi_$(MOD_FASTCGI_VERSION)-$(MOD_FASTCGI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mod-fastcgi-source mod-fastcgi-unpack mod-fastcgi mod-fastcgi-stage mod-fastcgi-ipk mod-fastcgi-clean mod-fastcgi-dirclean mod-fastcgi-check


#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MOD_FASTCGI_SOURCE):
	$(WGET) -P $(DL_DIR) $(MOD_FASTCGI_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mod-fastcgi-source: $(DL_DIR)/$(MOD_FASTCGI_SOURCE) $(MOD_FASTCGI_PATCHES)

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
$(MOD_FASTCGI_BUILD_DIR)/.configured: $(DL_DIR)/$(MOD_FASTCGI_SOURCE) $(MOD_FASTCGI_PATCHES)
	$(MAKE) apache-stage
	rm -rf $(BUILD_DIR)/$(MOD_FASTCGI_DIR) $(MOD_FASTCGI_BUILD_DIR)
	$(MOD_FASTCGI_UNZIP) $(DL_DIR)/$(MOD_FASTCGI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(MOD_FASTCGI_PATCHES) | patch -d $(BUILD_DIR)/$(MOD_FASTCGI_DIR) -p1
	mv $(BUILD_DIR)/$(MOD_FASTCGI_DIR) $(MOD_FASTCGI_BUILD_DIR)
	(cd $(MOD_FASTCGI_BUILD_DIR); \
		cp Makefile.AP2 Makefile \
	)
	touch $(MOD_FASTCGI_BUILD_DIR)/.configured

mod-fastcgi-unpack: $(MOD_FASTCGI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MOD_FASTCGI_BUILD_DIR)/.built: $(MOD_FASTCGI_BUILD_DIR)/.configured
	rm -f $(MOD_FASTCGI_BUILD_DIR)/.built
	$(MAKE) -C $(MOD_FASTCGI_BUILD_DIR) \
	    top_dir=$(STAGING_DIR)/opt/share/apache2 \
	    LIBTOOL="/bin/sh $(STAGING_DIR)/opt/share/apache2/build-1/libtool --silent" \
	    SH_LIBTOOL="/bin/sh $(STAGING_DIR)/opt/share/apache2/build-1/libtool --silent"
	touch $(MOD_FASTCGI_BUILD_DIR)/.built

#
# This is the build convenience target.
#
mod-fastcgi: $(MOD_FASTCGI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MOD_FASTCGI_BUILD_DIR)/.staged: $(MOD_FASTCGI_BUILD_DIR)/.built
	rm -f $(MOD_FASTCGI_BUILD_DIR)/.staged
	touch $(MOD_FASTCGI_BUILD_DIR)/.staged

mod-fastcgi-stage: $(MOD_FASTCGI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mod-fastcgi
#
$(MOD_FASTCGI_IPK_DIR)/CONTROL/control:
	@install -d $(MOD_FASTCGI_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: mod-fastcgi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MOD_FASTCGI_PRIORITY)" >>$@
	@echo "Section: $(MOD_FASTCGI_SECTION)" >>$@
	@echo "Version: $(MOD_FASTCGI_VERSION)-$(MOD_FASTCGI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MOD_FASTCGI_MAINTAINER)" >>$@
	@echo "Source: $(MOD_FASTCGI_SITE)/$(MOD_FASTCGI_SOURCE)" >>$@
	@echo "Description: $(MOD_FASTCGI_DESCRIPTION)" >>$@
	@echo "Depends: $(MOD_FASTCGI_DEPENDS)" >>$@
	@echo "Suggests: $(MOD_FASTCGI_SUGGESTS)" >>$@
	@echo "Conflicts: $(MOD_FASTCGI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MOD_FASTCGI_IPK_DIR)/opt/sbin or $(MOD_FASTCGI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MOD_FASTCGI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MOD_FASTCGI_IPK_DIR)/opt/etc/mod-fastcgi/...
# Documentation files should be installed in $(MOD_FASTCGI_IPK_DIR)/opt/doc/mod-fastcgi/...
# Daemon startup scripts should be installed in $(MOD_FASTCGI_IPK_DIR)/opt/etc/init.d/S??mod-fastcgi
#
# You may need to patch your application to make it use these locations.
#
$(MOD_FASTCGI_IPK): $(MOD_FASTCGI_BUILD_DIR)/.built
	rm -rf $(MOD_FASTCGI_IPK_DIR) $(BUILD_DIR)/mod-fastcgi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MOD_FASTCGI_BUILD_DIR) \
	    DESTDIR=$(MOD_FASTCGI_IPK_DIR) \
	    top_dir=$(STAGING_DIR)/opt/share/apache2 \
	    LIBTOOL="/bin/sh $(STAGING_DIR)/opt/share/apache2/build-1/libtool --silent" \
	    SH_LIBTOOL="/bin/sh $(STAGING_DIR)/opt/share/apache2/build-1/libtool --silent" \
	    install
	$(STRIP_COMMAND) $(MOD_FASTCGI_IPK_DIR)/opt/libexec/mod_fastcgi.so
	install -d $(MOD_FASTCGI_IPK_DIR)/opt/etc/apache2/conf.d/
	install -m 644 $(MOD_FASTCGI_SOURCE_DIR)/mod_fastcgi.conf $(MOD_FASTCGI_IPK_DIR)/opt/etc/apache2/conf.d/mod_fastcgi.conf
	$(MAKE) $(MOD_FASTCGI_IPK_DIR)/CONTROL/control
	echo $(MOD_FASTCGI_CONFFILES) | sed -e 's/ /\n/g' > $(MOD_FASTCGI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MOD_FASTCGI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mod-fastcgi-ipk: $(MOD_FASTCGI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mod-fastcgi-clean:
	-$(MAKE) -C $(MOD_FASTCGI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mod-fastcgi-dirclean:
	rm -rf $(BUILD_DIR)/$(MOD_FASTCGI_DIR) $(MOD_FASTCGI_BUILD_DIR) $(MOD_FASTCGI_IPK_DIR) $(MOD_FASTCGI_IPK)

#
#
# Some sanity check for the package.
#
mod-fastcgi-check: $(MOD_FASTCGI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MOD_FASTCGI_IPK)
