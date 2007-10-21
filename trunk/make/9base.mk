###########################################################
#
# 9base
#
###########################################################
#
# 9BASE_VERSION, 9BASE_SITE and 9BASE_SOURCE define
# the upstream location of the source code for the package.
# 9BASE_DIR is the directory which is created when the source
# archive is unpacked.
# 9BASE_UNZIP is the command used to unzip the source.
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
9BASE_SITE=http://daniel.debian.net/packages/9base/upstream
9BASE_VERSION=2+20070601
9BASE_SOURCE=9base_$(9BASE_VERSION).orig.tar.gz
9BASE_DIR=9base-$(9BASE_VERSION)
9BASE_UNZIP=zcat
9BASE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
9BASE_DESCRIPTION=9base is a port of a few original Plan 9 userland tools to Unix.
9BASE_SECTION=utils
9BASE_PRIORITY=optional
9BASE_DEPENDS=
9BASE_SUGGESTS=
9BASE_CONFLICTS=

9BASE_IPK_VERSION=1

#9BASE_CONFFILES=/opt/etc/9base.conf /opt/etc/init.d/SXX9base

#9BASE_PATCHES=$(9BASE_SOURCE_DIR)/configure.patch

9BASE_CPPFLAGS=
ifeq (uclibc,$(LIBC_STYLE))
9BASE_LDFLAGS=-lm
endif

9BASE_SOURCE_DIR=$(SOURCE_DIR)/9base
9BASE_BUILD_DIR=$(BUILD_DIR)/9base
9BASE_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/9base
9BASE_IPK_DIR=$(BUILD_DIR)/9base-$(9BASE_VERSION)-ipk
9BASE_IPK=$(BUILD_DIR)/9base_$(9BASE_VERSION)-$(9BASE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: 9base-source 9base-unpack 9base 9base-stage 9base-ipk 9base-clean 9base-dirclean 9base-check

$(DL_DIR)/$(9BASE_SOURCE):
	$(WGET) -P $(DL_DIR) $(9BASE_SITE)/$(9BASE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(9BASE_SOURCE)

9base-source: $(DL_DIR)/$(9BASE_SOURCE) $(9BASE_PATCHES)

$(9BASE_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(9BASE_SOURCE) make/9base.mk
	rm -rf $(HOST_BUILD_DIR)/$(9BASE_DIR) $(@D)
	$(9BASE_UNZIP) $(DL_DIR)/$(9BASE_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(9BASE_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(9BASE_DIR) $(@D) ; \
	fi
	$(MAKE) -C $(@D) \
		PREFIX=/opt/lib/9base \
		SUBDIRS="lib9 yacc" \
		;
	touch $@

$(9BASE_HOST_BUILD_DIR)/.staged: $(9BASE_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install \
		DESTDIR=$(HOST_STAGING_DIR) \
		PREFIX=/opt/lib/9base \
		SUBDIRS="yacc" \
		;
	touch $@

9base-host: $(9BASE_HOST_BUILD_DIR)/.built
9base-host-stage: $(9BASE_HOST_BUILD_DIR)/.staged

$(9BASE_BUILD_DIR)/.configured: $(9BASE_HOST_BUILD_DIR)/.staged $(9BASE_PATCHES)
	rm -rf $(BUILD_DIR)/$(9BASE_DIR) $(@D)
	$(9BASE_UNZIP) $(DL_DIR)/$(9BASE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(9BASE_PATCHES)" ; \
		then cat $(9BASE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(9BASE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(9BASE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(9BASE_DIR) $(@D) ; \
	fi
	sed -i -e '/yacc $$\*/s|^.*yacc |$(HOST_STAGING_LIB_DIR)/9base/bin/yacc |' $(@D)/yacc/9yacc
	touch $@

9base-unpack: $(9BASE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(9BASE_BUILD_DIR)/.built: $(9BASE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(9BASE_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(9BASE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(9BASE_LDFLAGS)" \
		AR="$(TARGET_AR) rc" \
		PREFIX=/opt/lib/9base \
		;
	touch $@

#
# This is the build convenience target.
#
9base: $(9BASE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(9BASE_BUILD_DIR)/.staged: $(9BASE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(9BASE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

9base-stage: $(9BASE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/9base
#
$(9BASE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: 9base" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(9BASE_PRIORITY)" >>$@
	@echo "Section: $(9BASE_SECTION)" >>$@
	@echo "Version: $(9BASE_VERSION)-$(9BASE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(9BASE_MAINTAINER)" >>$@
	@echo "Source: $(9BASE_SITE)/$(9BASE_SOURCE)" >>$@
	@echo "Description: $(9BASE_DESCRIPTION)" >>$@
	@echo "Depends: $(9BASE_DEPENDS)" >>$@
	@echo "Suggests: $(9BASE_SUGGESTS)" >>$@
	@echo "Conflicts: $(9BASE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(9BASE_IPK_DIR)/opt/sbin or $(9BASE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(9BASE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(9BASE_IPK_DIR)/opt/etc/9base/...
# Documentation files should be installed in $(9BASE_IPK_DIR)/opt/doc/9base/...
# Daemon startup scripts should be installed in $(9BASE_IPK_DIR)/opt/etc/init.d/S??9base
#
# You may need to patch your application to make it use these locations.
#
$(9BASE_IPK): $(9BASE_BUILD_DIR)/.built
	rm -rf $(9BASE_IPK_DIR) $(BUILD_DIR)/9base_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(9BASE_BUILD_DIR) install \
		DESTDIR=$(9BASE_IPK_DIR) \
		PREFIX=/opt/lib/9base \
		;
	$(STRIP_COMMAND) $(9BASE_IPK_DIR)/opt/lib/9base/bin/*
	install -d $(9BASE_IPK_DIR)/opt/share
	mv $(9BASE_IPK_DIR)/opt/lib/9base/share/man $(9BASE_IPK_DIR)/opt/share/
	rmdir $(9BASE_IPK_DIR)/opt/lib/9base/share
	for d in man1 man7; do \
		cd $(9BASE_IPK_DIR)/opt/share/man/$$d; \
		for f in *; do mv $$f 9base-$$f; done; \
	done
	$(MAKE) $(9BASE_IPK_DIR)/CONTROL/control
	echo $(9BASE_CONFFILES) | sed -e 's/ /\n/g' > $(9BASE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(9BASE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
9base-ipk: $(9BASE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
9base-clean:
	rm -f $(9BASE_BUILD_DIR)/.built
	-$(MAKE) -C $(9BASE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
9base-dirclean:
	rm -rf $(BUILD_DIR)/$(9BASE_DIR) $(9BASE_BUILD_DIR) $(9BASE_IPK_DIR) $(9BASE_IPK)
#
#
# Some sanity check for the package.
#
9base-check: $(9BASE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(9BASE_IPK)
