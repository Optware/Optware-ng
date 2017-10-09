###########################################################
#
# ruby
#
###########################################################

# You must replace "ruby" and "RUBY" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# RUBY_VERSION, RUBY_SITE and RUBY_SOURCE define
# the upstream location of the source code for the package.
# RUBY_DIR is the directory which is created when the source
# archive is unpacked.
# RUBY_UNZIP is the command used to unzip the source.
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
RUBY_SITE=ftp://ftp.ruby-lang.org/pub/ruby
RUBY_UPSTREAM_VERSION=2.3.1
RUBY_VERSION=2.3.1
RUBY_LIB_VERSION=2.3.0
RUBY_IPK_VERSION=7
RUBY_SOURCE=ruby-$(RUBY_UPSTREAM_VERSION).tar.gz
RUBY_DIR=ruby-$(RUBY_UPSTREAM_VERSION)
RUBY_UNZIP=zcat
RUBY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RUBY_DESCRIPTION=An interpreted scripting language for quick and easy object-oriented programming.
RUBY_SECTION=misc
RUBY_PRIORITY=optional
RUBY_DEPENDS=zlib, readline, openssl, ncurses, libgmp, libffi, gdbm

RUBY_ARCH?=$(TARGET_ARCH)-linux-gnu


#
# RUBY_CONFFILES should be a list of user-editable files
#RUBY_CONFFILES=$(TARGET_PREFIX)/etc/ruby.conf $(TARGET_PREFIX)/etc/init.d/SXXruby

#
# RUBY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
RUBY_PATCHES=#$(RUBY_SOURCE_DIR)/ext-socket.patch $(RUBY_SOURCE_DIR)/lib-mkmf.rb.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RUBY_CPPFLAGS=
RUBY_LDFLAGS=

#
# RUBY_BUILD_DIR is the directory in which the build is done.
# RUBY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RUBY_IPK_DIR is the directory in which the ipk is built.
# RUBY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RUBY_SOURCE_DIR=$(SOURCE_DIR)/ruby
RUBY_BUILD_DIR=$(BUILD_DIR)/ruby
RUBY_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/ruby
ifeq ($(HOSTCC), $(TARGET_CC))
RUBY_HOST_RUBY=ruby
else
RUBY_HOST_RUBY=$(HOST_STAGING_PREFIX)/bin/ruby
endif

RUBY_IPK_DIR=$(BUILD_DIR)/ruby-$(RUBY_VERSION)-ipk
RUBY_IPK=$(BUILD_DIR)/ruby_$(RUBY_VERSION)-$(RUBY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ruby-source ruby-unpack ruby ruby-stage ruby-ipk ruby-clean ruby-dirclean ruby-check ruby-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RUBY_SOURCE):
	$(WGET) -P $(@D) $(RUBY_SITE)/$(shell echo $(RUBY_VERSION) | sed 's/\([0-9]*\.[0-9]*\)\..*/\1/')/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ruby-source: $(DL_DIR)/$(RUBY_SOURCE) $(RUBY_PATCHES)

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
# http://www.ruby-talk.org/cgi-bin/scat.rb/ruby/ruby-talk/159766
$(RUBY_BUILD_DIR)/.configured: $(DL_DIR)/$(RUBY_SOURCE) $(RUBY_PATCHES) make/ruby.mk
	$(MAKE) zlib-stage readline-stage openssl-stage ncurses-stage libgmp-stage \
		gdbm-stage libffi-stage
	rm -rf $(BUILD_DIR)/$(RUBY_DIR) $(@D)
	$(RUBY_UNZIP) $(DL_DIR)/$(RUBY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RUBY_PATCHES)" ; \
		then cat $(RUBY_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(RUBY_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(RUBY_DIR) $(@D)
# $(RUBY_SOURCE_DIR)/lib-mkmf.rb.patch:
	sed -i -e 's/libpath = libpathflag(libpath)/libpath = "-L \$$(topdir)"/' $(@D)/lib/mkmf.rb
# $(RUBY_SOURCE_DIR)/ext-socket.patch (not needed in 2.2):
ifeq (wl500g, $(OPTWARE_TARGET))
	sed -i -e 's/#if defined __UCLIBC__/#if 1/' $(@D)/ext/socket/addrinfo.h
endif
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RUBY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RUBY_LDFLAGS)" \
		DLDFLAGS="$(STAGING_LDFLAGS) $(RUBY_LDFLAGS)" \
		ac_cv_func_setpgrp_void=yes \
		ac_cv_path_BASERUBY=$(RUBY_HOST_RUBY) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--with-sitedir=$(TARGET_PREFIX)/local/lib/ruby/site_ruby \
		--disable-nls \
                --with-opt-dir=$(STAGING_PREFIX) \
                --with-target-dir=$(STAGING_PREFIX) \
		--enable-shared \
		--disable-ipv6 \
		--disable-install-doc \
	)
	find $(@D) -type f -name Makefile -exec sed -i -e 's|-Wl,-R$(STAGING_LIB_DIR)||g' {} \;
	touch $@

ruby-unpack: $(RUBY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RUBY_BUILD_DIR)/.built: $(RUBY_BUILD_DIR)/.configured
	$(MAKE) ruby-host-stage
	rm -f $@
	PATH=`dirname $(RUBY_HOST_RUBY)`:$$PATH \
	LD_LIBRARY_PATH=$(HOST_STAGING_LIB_DIR) \
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ruby: $(RUBY_BUILD_DIR)/.built

$(RUBY_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(RUBY_SOURCE) #make/ruby.mk
	rm -rf $(HOST_BUILD_DIR)/$(RUBY_DIR) $(@D)
	$(RUBY_UNZIP) $(DL_DIR)/$(RUBY_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
#	cat $(RUBY_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(RUBY_DIR) -p1
	mv $(HOST_BUILD_DIR)/$(RUBY_DIR) $(@D)
	(cd $(@D); \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX) \
		--disable-nls \
		--enable-shared \
		--disable-ipv6 \
		--disable-install-doc \
	)
	$(MAKE) -C $(@D)
	rm -f $(HOST_STAGING_PREFIX)/bin/rake
	$(MAKE) -C $(@D) install
	rm -f $(HOST_STAGING_LIB_DIR)/ruby/ruby.h
	cd $(HOST_STAGING_LIB_DIR)/ruby && ln -sf $(RUBY_LIB_VERSION)/*-linux/ruby.h .
	touch $@

ifneq ($(HOSTCC), $(TARGET_CC))
ruby-host-stage: $(RUBY_HOST_BUILD_DIR)/.staged
else
ruby-host-stage:
endif

#
# If you are building a library, then you need to stage it too.
#
$(RUBY_BUILD_DIR)/.staged: $(RUBY_BUILD_DIR)/.built
	rm -f $@
	rm -f $(STAGING_PREFIX)/bin/rake
	PATH=`dirname $(RUBY_HOST_RUBY)`:$$PATH \
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	-cp -f $(STAGING_INCLUDE_DIR)/ruby-$(RUBY_LIB_VERSION)/*/ruby/config.h $(STAGING_INCLUDE_DIR)/ruby-$(RUBY_LIB_VERSION)/ruby
	touch $@

ruby-stage: $(RUBY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ruby
#
$(RUBY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ruby" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RUBY_PRIORITY)" >>$@
	@echo "Section: $(RUBY_SECTION)" >>$@
	@echo "Version: $(RUBY_VERSION)-$(RUBY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RUBY_MAINTAINER)" >>$@
	@echo "Source: $(RUBY_SITE)/$(RUBY_SOURCE)" >>$@
	@echo "Description: $(RUBY_DESCRIPTION)" >>$@
	@echo "Depends: $(RUBY_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RUBY_IPK_DIR)$(TARGET_PREFIX)/sbin or $(RUBY_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RUBY_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(RUBY_IPK_DIR)$(TARGET_PREFIX)/etc/ruby/...
# Documentation files should be installed in $(RUBY_IPK_DIR)$(TARGET_PREFIX)/doc/ruby/...
# Daemon startup scripts should be installed in $(RUBY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??ruby
#
# You may need to patch your application to make it use these locations.
#
$(RUBY_IPK): $(RUBY_BUILD_DIR)/.built
	rm -rf $(RUBY_IPK_DIR) $(BUILD_DIR)/ruby_*_$(TARGET_ARCH).ipk
	PATH=`dirname $(RUBY_HOST_RUBY)`:$$PATH \
	$(MAKE) -C $(RUBY_BUILD_DIR) DESTDIR=$(RUBY_IPK_DIR) install
	for so in $(RUBY_IPK_DIR)$(TARGET_PREFIX)/bin/ruby \
	    $(RUBY_IPK_DIR)$(TARGET_PREFIX)/lib/libruby.so.[0-9]*.[0-9]*.[0-9]* \
	    `find $(RUBY_IPK_DIR)$(TARGET_PREFIX)/lib/ruby/$(RUBY_LIB_VERSION)/ -name '*.so'`; \
	do $(STRIP_COMMAND) $$so; \
	done
	sed -i -e 's|$(TARGET_CROSS)|$(TARGET_PREFIX)/bin/|g' -e 's|$(STAGING_PREFIX)|$(TARGET_PREFIX)|g' \
		-e '/CONFIG\["INSTALL"\]/d' -e 's|/usr|$(TARGET_PREFIX)|' \
		$(RUBY_IPK_DIR)$(TARGET_PREFIX)/lib/ruby/$(RUBY_LIB_VERSION)/$(RUBY_ARCH)/rbconfig.rb
	$(INSTALL) -d $(RUBY_IPK_DIR)$(TARGET_PREFIX)/etc
	$(MAKE) $(RUBY_IPK_DIR)/CONTROL/control
	if [ -f $(RUBY_IPK_DIR)$(TARGET_PREFIX)/bin/gem ] ; then \
		mv -f $(RUBY_IPK_DIR)$(TARGET_PREFIX)/bin/gem $(RUBY_IPK_DIR)$(TARGET_PREFIX)/bin/ruby-gem; \
		echo -e "#!/bin/sh\nupdate-alternatives --install '$(TARGET_PREFIX)/bin/gem' 'gem' $(TARGET_PREFIX)/bin/ruby-gem 30" > \
								$(RUBY_IPK_DIR)/CONTROL/postinst; \
		echo -e "#!/bin/sh\nupdate-alternatives --remove 'gem' $(TARGET_PREFIX)/bin/ruby-gem" > \
								$(RUBY_IPK_DIR)/CONTROL/prerm; \
		chmod 755 $(RUBY_IPK_DIR)/CONTROL/postinst; \
		chmod 755 $(RUBY_IPK_DIR)/CONTROL/prerm; \
		if test -n "$(UPD-ALT_PREFIX)"; then \
			sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
				$(RUBY_IPK_DIR)/CONTROL/postinst $(RUBY_IPK_DIR)/CONTROL/prerm; \
		fi; \
	fi
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RUBY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ruby-ipk: $(RUBY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ruby-clean:
	-$(MAKE) -C $(RUBY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ruby-dirclean:
	rm -rf $(BUILD_DIR)/$(RUBY_DIR) $(RUBY_BUILD_DIR) $(RUBY_IPK_DIR) $(RUBY_IPK)

#
# Some sanity check for the package.
#
ruby-check: $(RUBY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
