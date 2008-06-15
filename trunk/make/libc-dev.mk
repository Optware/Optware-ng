###########################################################
#
# libc-dev
#
###########################################################
#
# LIBC-DEV_VERSION, LIBC-DEV_SITE and LIBC-DEV_SOURCE define
# the upstream location of the source code for the package.
# LIBC-DEV_DIR is the directory which is created when the source
# archive is unpacked.
# LIBC-DEV_UNZIP is the command used to unzip the source.
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
#LIBC-DEV_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libc-dev
LIBC-DEV_VERSION=$(LIBNSL_VERSION)
#LIBC-DEV_SOURCE=libc-dev-$(LIBC-DEV_VERSION).tar.gz
#LIBC-DEV_DIR=libc-dev-$(LIBC-DEV_VERSION)
#LIBC-DEV_UNZIP=zcat
LIBC-DEV_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBC-DEV_DESCRIPTION=libc development files.
LIBC-DEV_SECTION=devel
LIBC-DEV_PRIORITY=optional
LIBC-DEV_DEPENDS=libnsl
LIBC-DEV_SUGGESTS=
LIBC-DEV_CONFLICTS=

LIBC-DEV_IPK_VERSION=1

ifdef LIBNSL_VERSION
LIBC-DEV_VERSION=$(LIBNSL_VERSION)
else
LIBC-DEV_VERSION ?= 0.9.28
endif

ifdef TARGET_USRLIBDIR
LIBC-DEV_USRLIBDIR=$(TARGET_USRLIBDIR)
else
LIBC-DEV_USRLIBDIR=$(TARGET_LIBDIR)
endif

ifdef TARGET_LIBC_LIBDIR
LIBC-DEV_LIBDIR=$(TARGET_LIBC_LIBDIR)
else
LIBC-DEV_LIBDIR=$(TARGET_LIBDIR)
endif

#
# LIBC-DEV_CONFFILES should be a list of user-editable files
#LIBC-DEV_CONFFILES=/opt/etc/libc-dev.conf /opt/etc/init.d/SXXlibc-dev

#
# LIBC-DEV_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBC-DEV_PATCHES=$(LIBC-DEV_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBC-DEV_CPPFLAGS=
LIBC-DEV_LDFLAGS=

#
# LIBC-DEV_BUILD_DIR is the directory in which the build is done.
# LIBC-DEV_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBC-DEV_IPK_DIR is the directory in which the ipk is built.
# LIBC-DEV_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBC-DEV_BUILD_DIR=$(BUILD_DIR)/libc-dev
LIBC-DEV_SOURCE_DIR=$(SOURCE_DIR)/libc-dev
LIBC-DEV_IPK_DIR=$(BUILD_DIR)/libc-dev-$(LIBC-DEV_VERSION)-ipk
LIBC-DEV_IPK=$(BUILD_DIR)/libc-dev_$(LIBC-DEV_VERSION)-$(LIBC-DEV_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libc-dev-source libc-dev-unpack libc-dev libc-dev-stage libc-dev-ipk libc-dev-clean libc-dev-dirclean libc-dev-check

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libc-dev
#
$(LIBC-DEV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libc-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBC-DEV_PRIORITY)" >>$@
	@echo "Section: $(LIBC-DEV_SECTION)" >>$@
	@echo "Version: $(LIBC-DEV_VERSION)-$(LIBC-DEV_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBC-DEV_MAINTAINER)" >>$@
	@echo "Source: $(LIBC-DEV_SITE)/$(LIBC-DEV_SOURCE)" >>$@
	@echo "Description: $(LIBC-DEV_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBC-DEV_DEPENDS)" >>$@
	@echo "Suggests: $(LIBC-DEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBC-DEV_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBC-DEV_IPK_DIR)/opt/sbin or $(LIBC-DEV_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBC-DEV_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBC-DEV_IPK_DIR)/opt/etc/libc-dev/...
# Documentation files should be installed in $(LIBC-DEV_IPK_DIR)/opt/doc/libc-dev/...
# Daemon startup scripts should be installed in $(LIBC-DEV_IPK_DIR)/opt/etc/init.d/S??libc-dev
#
# You may need to patch your application to make it use these locations.
#
$(LIBC-DEV_IPK): make/libc-dev.mk
	rm -rf $(LIBC-DEV_IPK_DIR) $(BUILD_DIR)/libc-dev_*_$(TARGET_ARCH).ipk
	install -d $(LIBC-DEV_IPK_DIR)/opt/lib/
	cp -a $(TARGET_INCDIR) $(LIBC-DEV_IPK_DIR)/opt/
	rsync -l $(LIBC-DEV_USRLIBDIR)/*crt*.o $(LIBC-DEV_IPK_DIR)/opt/lib/
	rsync -l \
		$(if $(filter uclibc, $(LIBC_STYLE)),$(TARGET_LIBDIR)/libuClibc-$(LIBC-DEV_VERSION).so,) \
		$(LIBC-DEV_USRLIBDIR)/libc.so* \
		$(LIBC-DEV_IPK_DIR)/opt/lib/
	for f in libcrypt libdl libm libpthread libresolv librt libutil \
		$(if $(filter uclibc, $(LIBC_STYLE)), ld-uClibc, ) \
		; \
	do rsync -l \
		$(LIBC-DEV_LIBDIR)/$${f}-$(LIBC-DEV_VERSION).so \
		$(LIBC-DEV_LIBDIR)/$${f}.so* \
		$(LIBC-DEV_IPK_DIR)/opt/lib/; \
	done
ifneq (uclibc, $(LIBC_STYLE))
	install -d $(LIBC-DEV_IPK_DIR)/usr/lib/
	for f in libc_nonshared.a libpthread_nonshared.a; \
	do rsync -l $(TARGET_USRLIBDIR)/$${f} $(LIBC-DEV_IPK_DIR)/usr/lib/; done
endif
	$(MAKE) $(LIBC-DEV_IPK_DIR)/CONTROL/control
	echo $(LIBC-DEV_CONFFILES) | sed -e 's/ /\n/g' > $(LIBC-DEV_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBC-DEV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libc-dev-ipk: $(LIBC-DEV_IPK)

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libc-dev-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBC-DEV_DIR) $(LIBC-DEV_BUILD_DIR) $(LIBC-DEV_IPK_DIR) $(LIBC-DEV_IPK)
#
#
# Some sanity check for the package.
#
libc-dev-check: $(LIBC-DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBC-DEV_IPK)
