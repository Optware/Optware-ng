#############################################################
#
# libevent
#
#############################################################

LIBEVENT_SITE=http://www.monkey.org/~provos/
LIBEVENT_VERSION=1.3c
LIBEVENT_SOURCE=libevent-$(LIBEVENT_VERSION).tar.gz
LIBEVENT_DIR=libevent-$(LIBEVENT_VERSION)
LIBEVENT_UNZIP=zcat
LIBEVENT_MAINTAINER=Jean-Fabrice <jeanfabrice@users.sourceforge.net>
LIBEVENT_DESCRIPTION=libevent to implement an event loop
LIBEVENT_SECTION=libs
LIBEVENT_PRIORITY=optional
LIBEVENT_DEPENDS=
LIBEVENT_CONFLICTS=

LIBEVENT_IPK_VERSION=2

ifeq ($(LIBC_STYLE), uclibc)
LIBEVENT_CPPFLAGS= -fPIC -DCLOCK_MONOTONIC=1 -DCLOCK_REALTIME=0
else
LIBEVENT_CPPFLAGS= -fPIC
endif
LIBEVENT_LDFLAGS=

LIBEVENT_BUILD_DIR=$(BUILD_DIR)/libevent
LIBEVENT_SOURCE_DIR=$(SOURCE_DIR)/libevent
LIBEVENT_IPK_DIR=$(BUILD_DIR)/libevent-$(LIBEVENT_VERSION)-ipk
LIBEVENT_IPK=$(BUILD_DIR)/libevent_$(LIBEVENT_VERSION)-$(LIBEVENT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libevent-source libevent-unpack libevent libevent-stage libevent-ipk libevent-clean libevent-dirclean libevent-check

$(DL_DIR)/$(LIBEVENT_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBEVENT_SITE)/$(LIBEVENT_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBEVENT_SOURCE)

libevent-source: $(DL_DIR)/$(LIBEVENT_SOURCE)

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
$(LIBEVENT_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBEVENT_SOURCE)
	rm -rf $(BUILD_DIR)/$(LIBEVENT_DIR) $(LIBEVENT_BUILD_DIR)
	$(LIBEVENT_UNZIP) $(DL_DIR)/$(LIBEVENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/libevent-$(LIBEVENT_VERSION) $(LIBEVENT_BUILD_DIR)
	(cd $(LIBEVENT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBEVENT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBEVENT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	);
	$(PATCH_LIBTOOL) $(LIBEVENT_BUILD_DIR)/libtool
	sed -i.orig -e '/^library_names_spec=/s|\\$${shared_ext}|.so|g' $(LIBEVENT_BUILD_DIR)/libtool
	touch $(LIBEVENT_BUILD_DIR)/.configured

libevent-unpack: $(LIBEVENT_BUILD_DIR)/.configured

$(LIBEVENT_BUILD_DIR)/.built: $(LIBEVENT_BUILD_DIR)/.configured
	rm -f $(LIBEVENT_BUILD_DIR)/.built
	$(MAKE) -C $(LIBEVENT_BUILD_DIR)
	touch $(LIBEVENT_BUILD_DIR)/.built

libevent: $(LIBEVENT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBEVENT_BUILD_DIR)/.staged: $(LIBEVENT_BUILD_DIR)/.built
	rm -f $(LIBEVENT_BUILD_DIR)/.staged
	rm -f $(STAGING_LIB_DIR)/libevent*
	$(MAKE) -C $(LIBEVENT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(LIBEVENT_BUILD_DIR)/.staged

libevent-stage: $(LIBEVENT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libevent
#
$(LIBEVENT_IPK_DIR)/CONTROL/control:
	@install -d $(LIBEVENT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libevent" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBEVENT_PRIORITY)" >>$@
	@echo "Section: $(LIBEVENT_SECTION)" >>$@
	@echo "Version: $(LIBEVENT_VERSION)-$(LIBEVENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBEVENT_MAINTAINER)" >>$@
	@echo "Source: $(LIBEVENT_SITE)/$(LIBEVENT_SOURCE)" >>$@
	@echo "Description: $(LIBEVENT_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBEVENT_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBEVENT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
$(LIBEVENT_IPK): $(LIBEVENT_BUILD_DIR)/.built
	rm -rf $(LIBEVENT_IPK_DIR) $(BUILD_DIR)/libevent_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBEVENT_BUILD_DIR) DESTDIR=$(LIBEVENT_IPK_DIR) install-strip
	rm -f $(LIBEVENT_IPK_DIR)/opt/lib/libevent*.la $(LIBEVENT_IPK_DIR)/opt/lib/libevent*.a
	$(MAKE) $(LIBEVENT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBEVENT_IPK_DIR)

libevent-ipk: $(LIBEVENT_IPK)

libevent-clean:
	-$(MAKE) -C $(LIBEVENT_BUILD_DIR) clean

libevent-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBEVENT_DIR) $(LIBEVENT_BUILD_DIR) $(LIBEVENT_IPK_DIR) $(LIBEVENT_IPK)

libevent-check: $(LIBEVENT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBEVENT_IPK)
