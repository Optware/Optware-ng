###########################################################
#
# mod-wsgi
#
###########################################################
#
# MOD_WSGI_VERSION, MOD_WSGI_SITE and MOD_WSGI_SOURCE define
# the upstream location of the source code for the package.
# MOD_WSGI_DIR is the directory which is created when the source
# archive is unpacked.
# MOD_WSGI_UNZIP is the command used to unzip the source.
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
MOD_WSGI_SITE=http://modwsgi.googlecode.com/files
MOD_WSGI_VERSION=2.1
MOD_WSGI_SOURCE=mod_wsgi-$(MOD_WSGI_VERSION).tar.gz
MOD_WSGI_DIR=mod_wsgi-$(MOD_WSGI_VERSION)
MOD_WSGI_UNZIP=zcat
MOD_WSGI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MOD_WSGI_DESCRIPTION=An Apache module that provides a WSGI compliant interface for hosting Python based web applications within Apache.
MOD_WSGI_SECTION=web
MOD_WSGI_PRIORITY=optional
MOD_WSGI_DEPENDS=apache, python25
MOD_WSGI_SUGGESTS=
MOD_WSGI_CONFLICTS=

#
# MOD_WSGI_IPK_VERSION should be incremented when the ipk changes.
#
MOD_WSGI_IPK_VERSION=1

#
# MOD_WSGI_CONFFILES should be a list of user-editable files
MOD_WSGI_CONFFILES=/opt/etc/apache2/conf.d/mod_wsgi.conf

#
# MOD_WSGI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MOD_WSGI_PATCHES=$(MOD_WSGI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MOD_WSGI_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/python2.5
MOD_WSGI_LDFLAGS=

#
# MOD_WSGI_BUILD_DIR is the directory in which the build is done.
# MOD_WSGI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MOD_WSGI_IPK_DIR is the directory in which the ipk is built.
# MOD_WSGI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MOD_WSGI_BUILD_DIR=$(BUILD_DIR)/mod-wsgi
MOD_WSGI_SOURCE_DIR=$(SOURCE_DIR)/mod-wsgi
MOD_WSGI_IPK_DIR=$(BUILD_DIR)/mod-wsgi-$(MOD_WSGI_VERSION)-ipk
MOD_WSGI_IPK=$(BUILD_DIR)/mod-wsgi_$(MOD_WSGI_VERSION)-$(MOD_WSGI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mod-wsgi-source mod-wsgi-unpack mod-wsgi mod-wsgi-stage mod-wsgi-ipk mod-wsgi-clean mod-wsgi-dirclean mod-wsgi-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MOD_WSGI_SOURCE):
	$(WGET) -P $(@D) $(MOD_WSGI_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mod-wsgi-source: $(DL_DIR)/$(MOD_WSGI_SOURCE) $(MOD_WSGI_PATCHES)

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
$(MOD_WSGI_BUILD_DIR)/.configured: $(DL_DIR)/$(MOD_WSGI_SOURCE) $(MOD_WSGI_PATCHES) make/mod-wsgi.mk
	$(MAKE) python25-stage apache-stage
	rm -rf $(BUILD_DIR)/$(MOD_WSGI_DIR) $(@D)
	$(MOD_WSGI_UNZIP) $(DL_DIR)/$(MOD_WSGI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MOD_WSGI_PATCHES)" ; \
		then cat $(MOD_WSGI_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MOD_WSGI_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MOD_WSGI_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MOD_WSGI_DIR) $(@D) ; \
	fi
	sed -i -e '/^HTTPD_VERSION=/s/=.*/=$(APACHE_VERSION)/' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MOD_WSGI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MOD_WSGI_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-apxs=$(STAGING_PREFIX)/sbin/apxs \
		--with-python=$(HOST_STAGING_PREFIX)/bin/python2.5 \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mod-wsgi-unpack: $(MOD_WSGI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MOD_WSGI_BUILD_DIR)/.built: $(MOD_WSGI_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		CPPFLAGS="$(MOD_WSGI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MOD_WSGI_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
mod-wsgi: $(MOD_WSGI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MOD_WSGI_BUILD_DIR)/.staged: $(MOD_WSGI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

mod-wsgi-stage: $(MOD_WSGI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mod-wsgi
#
$(MOD_WSGI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mod-wsgi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MOD_WSGI_PRIORITY)" >>$@
	@echo "Section: $(MOD_WSGI_SECTION)" >>$@
	@echo "Version: $(MOD_WSGI_VERSION)-$(MOD_WSGI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MOD_WSGI_MAINTAINER)" >>$@
	@echo "Source: $(MOD_WSGI_SITE)/$(MOD_WSGI_SOURCE)" >>$@
	@echo "Description: $(MOD_WSGI_DESCRIPTION)" >>$@
	@echo "Depends: $(MOD_WSGI_DEPENDS)" >>$@
	@echo "Suggests: $(MOD_WSGI_SUGGESTS)" >>$@
	@echo "Conflicts: $(MOD_WSGI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MOD_WSGI_IPK_DIR)/opt/sbin or $(MOD_WSGI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MOD_WSGI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MOD_WSGI_IPK_DIR)/opt/etc/mod-wsgi/...
# Documentation files should be installed in $(MOD_WSGI_IPK_DIR)/opt/doc/mod-wsgi/...
# Daemon startup scripts should be installed in $(MOD_WSGI_IPK_DIR)/opt/etc/init.d/S??mod-wsgi
#
# You may need to patch your application to make it use these locations.
#
$(MOD_WSGI_IPK): $(MOD_WSGI_BUILD_DIR)/.built
	rm -rf $(MOD_WSGI_IPK_DIR) $(BUILD_DIR)/mod-wsgi_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(MOD_WSGI_BUILD_DIR) DESTDIR=$(MOD_WSGI_IPK_DIR) install
	install -d $(MOD_WSGI_IPK_DIR)/opt/libexec
	cd $(MOD_WSGI_BUILD_DIR); \
	install -m 755 $(MOD_WSGI_BUILD_DIR)/.libs/mod_wsgi.so $(MOD_WSGI_IPK_DIR)/opt/libexec
	$(STRIP_COMMAND) $(MOD_WSGI_IPK_DIR)/opt/libexec/mod_wsgi.so
	install -d $(MOD_WSGI_IPK_DIR)/opt/etc/apache2/conf.d/
	echo "LoadModule wsgi_module libexec/mod_wsgi.so" > $(MOD_WSGI_IPK_DIR)/opt/etc/apache2/conf.d/mod_wsgi.conf
#	install -d $(MOD_WSGI_IPK_DIR)/opt/etc/
#	install -m 644 $(MOD_WSGI_SOURCE_DIR)/mod-wsgi.conf $(MOD_WSGI_IPK_DIR)/opt/etc/mod-wsgi.conf
#	install -d $(MOD_WSGI_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MOD_WSGI_SOURCE_DIR)/rc.mod-wsgi $(MOD_WSGI_IPK_DIR)/opt/etc/init.d/SXXmod-wsgi
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOD_WSGI_IPK_DIR)/opt/etc/init.d/SXXmod-wsgi
	$(MAKE) $(MOD_WSGI_IPK_DIR)/CONTROL/control
#	install -m 755 $(MOD_WSGI_SOURCE_DIR)/postinst $(MOD_WSGI_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOD_WSGI_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MOD_WSGI_SOURCE_DIR)/prerm $(MOD_WSGI_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOD_WSGI_IPK_DIR)/CONTROL/prerm
	echo $(MOD_WSGI_CONFFILES) | sed -e 's/ /\n/g' > $(MOD_WSGI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MOD_WSGI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mod-wsgi-ipk: $(MOD_WSGI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mod-wsgi-clean:
	rm -f $(MOD_WSGI_BUILD_DIR)/.built
	-$(MAKE) -C $(MOD_WSGI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mod-wsgi-dirclean:
	rm -rf $(BUILD_DIR)/$(MOD_WSGI_DIR) $(MOD_WSGI_BUILD_DIR) $(MOD_WSGI_IPK_DIR) $(MOD_WSGI_IPK)
#
#
# Some sanity check for the package.
#
mod-wsgi-check: $(MOD_WSGI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MOD_WSGI_IPK)
