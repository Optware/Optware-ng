###########################################################
#
# qpopper
#
###########################################################

#
# QPOPPER_VERSION, QPOPPER_SITE and QPOPPER_SOURCE define
# the upstream location of the source code for the package.
# QPOPPER_DIR is the directory which is created when the source
# archive is unpacked.
# QPOPPER_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
QPOPPER_SITE=ftp://ftp.qualcomm.com/eudora/servers/unix/popper
QPOPPER_VERSION=4.0.19
QPOPPER_SOURCE=qpopper$(QPOPPER_VERSION).tar.gz
QPOPPER_DIR=qpopper$(QPOPPER_VERSION)
QPOPPER_UNZIP=zcat

QPOPPER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
QPOPPER_DESCRIPTION=qpopper is a pop3 server
QPOPPER_SECTION=mail
QPOPPER_PRIORITY=optional
QPOPPER_DEPENDS=openssl, sendmail
ifeq (uclibc, $(LIBC_STYLE))
QPOPPER_DEPENDS +=, librpc-uclibc
endif
QPOPPER_SUGGESTS=
QPOPPER_CONFLICTS=


#
# QPOPPER_IPK_VERSION should be incremented when the ipk changes.
#
QPOPPER_IPK_VERSION=4

#
# QPOPPER_CONFFILES should be a list of user-editable files
#QPOPPER_CONFFILES=$(TARGET_PREFIX)/etc/qpopper.conf $(TARGET_PREFIX)/etc/init.d/SXXqpopper

#
# QPOPPER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
QPOPPER_PATCHES=$(QPOPPER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
QPOPPER_CPPFLAGS=
QPOPPER_LDFLAGS=
ifeq (uclibc, $(LIBC_STYLE))
QPOPPER_CPPFLAGS += -I$(STAGING_INCLUDE_DIR)/rpc-uclibc
QPOPPER_LDFLAGS += -lrpc-uclibc
endif

#
# QPOPPER_BUILD_DIR is the directory in which the build is done.
# QPOPPER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# QPOPPER_IPK_DIR is the directory in which the ipk is built.
# QPOPPER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
QPOPPER_BUILD_DIR=$(BUILD_DIR)/qpopper
QPOPPER_SOURCE_DIR=$(SOURCE_DIR)/qpopper
QPOPPER_IPK_DIR=$(BUILD_DIR)/qpopper-$(QPOPPER_VERSION)-ipk
QPOPPER_IPK=$(BUILD_DIR)/qpopper_$(QPOPPER_VERSION)-$(QPOPPER_IPK_VERSION)_${TARGET_ARCH}.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(QPOPPER_SOURCE):
	$(WGET) -P $(@D) $(QPOPPER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
qpopper-source: $(DL_DIR)/$(QPOPPER_SOURCE) $(QPOPPER_PATCHES)

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
$(QPOPPER_BUILD_DIR)/.configured: $(DL_DIR)/$(QPOPPER_SOURCE) $(QPOPPER_PATCHES) make/qpopper.mk
	$(MAKE) openssl-stage
ifeq (uclibc, $(LIBC_STYLE))
	$(MAKE) librpc-uclibc-stage
endif
	rm -rf $(BUILD_DIR)/$(QPOPPER_DIR) $(@D)
	$(QPOPPER_UNZIP) $(DL_DIR)/$(QPOPPER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(QPOPPER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(QPOPPER_DIR) -p0
	mv $(BUILD_DIR)/$(QPOPPER_DIR) $(@D)
	find $(@D) -type f -name '*.[ch]' -exec sed -i -e 's/sys_errlist/&_qpopper/' {} \;
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(QPOPPER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(QPOPPER_LDFLAGS)" \
		./configure \
		--enable-spool-dir="$(TARGET_PREFIX)/var/spool/mail" \
		--enable-standalone \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-openssl=$(STAGING_PREFIX) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
	)
	touch $@

qpopper-unpack: $(QPOPPER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(QPOPPER_BUILD_DIR)/.built: $(QPOPPER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
qpopper: $(QPOPPER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(QPOPPER_BUILD_DIR)/.staged: $(QPOPPER_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#qpopper-stage: $(QPOPPER_BUILD_DIR)/.staged

$(QPOPPER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: qpopper" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(QPOPPER_PRIORITY)" >>$@
	@echo "Section: $(QPOPPER_SECTION)" >>$@
	@echo "Version: $(QPOPPER_VERSION)-$(QPOPPER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(QPOPPER_MAINTAINER)" >>$@
	@echo "Source: $(QPOPPER_SITE)/$(QPOPPER_SOURCE)" >>$@
	@echo "Description: $(QPOPPER_DESCRIPTION)" >>$@
	@echo "Depends: $(QPOPPER_DEPENDS)" >>$@
	@echo "Suggests: $(QPOPPER_SUGGESTS)" >>$@
	@echo "Conflicts: $(QPOPPER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/sbin or $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/etc/qpopper/...
# Documentation files should be installed in $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/doc/qpopper/...
# Daemon startup scripts should be installed in $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??qpopper
#
# You may need to patch your application to make it use these locations.
#
$(QPOPPER_IPK): $(QPOPPER_BUILD_DIR)/.built
	rm -rf $(QPOPPER_IPK_DIR) $(BUILD_DIR)/qpopper_*_${TARGET_ARCH}.ipk
	$(INSTALL) -d $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/man/man8
	$(INSTALL) -m 644 $(QPOPPER_BUILD_DIR)/man/popper.8 $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/man/man8
	$(INSTALL) -d $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(STRIP_COMMAND) $(QPOPPER_BUILD_DIR)/popper/popper -o $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/sbin/popper
	$(INSTALL) -d $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(QPOPPER_SOURCE_DIR)/rc.qpopper $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S70qpopper
	( cd $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d ; ln -s S70qpopper K30qpopper)
	$(INSTALL) -d $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/doc/qpopper
	$(INSTALL) -m 644 $(QPOPPER_BUILD_DIR)/README  $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/doc/qpopper
	$(INSTALL) -m 644 $(QPOPPER_BUILD_DIR)/License.txt  $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/doc/qpopper
	$(INSTALL) -m 644 $(QPOPPER_BUILD_DIR)/GUIDE.pdf  $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/doc/qpopper
#	$(MAKE) -C $(QPOPPER_BUILD_DIR) prefix=$(QPOPPER_IPK_DIR)$(TARGET_PREFIX) install
#	$(INSTALL) -d $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(QPOPPER_SOURCE_DIR)/qpopper.conf $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/etc/qpopper.conf
#	$(INSTALL) -d $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(QPOPPER_SOURCE_DIR)/rc.qpopper $(QPOPPER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXqpopper
	$(MAKE) $(QPOPPER_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(QPOPPER_SOURCE_DIR)/postinst $(QPOPPER_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(QPOPPER_SOURCE_DIR)/prerm $(QPOPPER_IPK_DIR)/CONTROL/prerm
#	echo $(QPOPPER_CONFFILES) | sed -e 's/ /\n/g' > $(QPOPPER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(QPOPPER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
qpopper-ipk: $(QPOPPER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
qpopper-clean:
	-$(MAKE) -C $(QPOPPER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
qpopper-dirclean:
	rm -rf $(BUILD_DIR)/$(QPOPPER_DIR) $(QPOPPER_BUILD_DIR) $(QPOPPER_IPK_DIR) $(QPOPPER_IPK)

#
# Some sanity check for the package.
#
qpopper-check: $(QPOPPER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
