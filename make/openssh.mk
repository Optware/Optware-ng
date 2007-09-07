#########################################################
#
# openssh
#
#########################################################

OPENSSH_SITE=ftp://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable
OPENSSH_VERSION=4.7p1
OPENSSH_SOURCE=openssh-$(OPENSSH_VERSION).tar.gz
OPENSSH_DIR=openssh-$(OPENSSH_VERSION)
OPENSSH_UNZIP=zcat

OPENSSH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OPENSSH_DESCRIPTION=a FREE version of the SSH protocol suite of network connectivity tools.
OPENSSH_SECTION=net
OPENSSH_PRIORITY=optional
OPENSSH_DEPENDS=openssl, zlib
OPENSSH_SUGGESTS=
OPENSSH_CONFLICTS=

OPENSSH_IPK_VERSION=1

OPENSSH_CONFFILES=/opt/etc/openssh/ssh_config /opt/etc/openssh/sshd_config \
	/opt/etc/openssh/moduli /opt/etc/init.d/S40sshd

OPENSSH_PATCHES=\
	$(OPENSSH_SOURCE_DIR)/Makefile.patch 

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OPENSSH_CPPFLAGS=
OPENSSH_LDFLAGS=

#
# OPENSSH_BUILD_DIR is the directory in which the build is done.
# OPENSSH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OPENSSH_IPK_DIR is the directory in which the ipk is built.
# OPENSSH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OPENSSH_BUILD_DIR=$(BUILD_DIR)/openssh
OPENSSH_SOURCE_DIR=$(SOURCE_DIR)/openssh
OPENSSH_IPK_DIR=$(BUILD_DIR)/openssh-$(OPENSSH_VERSION)-ipk
OPENSSH_IPK=$(BUILD_DIR)/openssh_$(OPENSSH_VERSION)-$(OPENSSH_IPK_VERSION)_$(TARGET_ARCH).ipk


.PHONY: openssh-source openssh-unpack openssh openssh-stage openssh-ipk openssh-clean openssh-dirclean openssh-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OPENSSH_SOURCE):
	$(WGET) -P $(DL_DIR) $(OPENSSH_SITE)/$(OPENSSH_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
openssh-source: $(DL_DIR)/$(OPENSSH_SOURCE) $(OPENSSH_PATCHES)

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
$(OPENSSH_BUILD_DIR)/.configured: $(DL_DIR)/$(OPENSSH_SOURCE) $(OPENSSH_PATCHES) make/openssh.mk
	$(MAKE) zlib-stage openssl-stage tcpwrappers-stage
	rm -rf $(BUILD_DIR)/$(OPENSSH_DIR) $(OPENSSH_BUILD_DIR)
	$(OPENSSH_UNZIP) $(DL_DIR)/$(OPENSSH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(OPENSSH_PATCHES)" ; \
		then cat $(OPENSSH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(OPENSSH_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(OPENSSH_DIR)" != "$(OPENSSH_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(OPENSSH_DIR) $(OPENSSH_BUILD_DIR) ; \
	fi
	(cd $(OPENSSH_BUILD_DIR); \
		rm -rf config.cache; autoconf; \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OPENSSH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OPENSSH_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-pid-dir=/opt/var/run \
		--with-prngd-socket=/opt/var/run/egd-pool \
		--with-privsep-path=/opt/var/empty \
		--sysconfdir=/opt/etc/openssh \
		--with-zlib=$(STAGING_DIR)/opt \
		--with-ssl-dir=$(STAGING_DIR)/opt \
		--with-md5-passwords \
		--disable-etc-default-login \
		--with-default-path="/opt/sbin:/opt/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
		--with-privsep-user=nobody \
		--disable-lastlog --disable-utmp \
		--disable-utmpx --disable-wtmp --disable-wtmpx \
		--without-x \
		--with-tcp-wrappers=$(STAGING_DIR)/opt \
		--with-xauth=/opt/bin/xauth \
	)
	touch $(OPENSSH_BUILD_DIR)/.configured

openssh-unpack: $(OPENSSH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OPENSSH_BUILD_DIR)/.built: $(OPENSSH_BUILD_DIR)/.configured
	rm -f $(OPENSSH_BUILD_DIR)/.built
	$(MAKE) -C $(OPENSSH_BUILD_DIR)
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/scp
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/sftp
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/sftp-server
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/ssh
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/ssh-add
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/ssh-agent
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/ssh-keygen
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/ssh-keyscan
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/ssh-keysign
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/ssh-rand-helper
	-$(STRIP_COMMAND)  $(OPENSSH_BUILD_DIR)/sshd
	touch $(OPENSSH_BUILD_DIR)/.built

#
# This is the build convenience target.
#
openssh: $(OPENSSH_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/openssh
#
$(OPENSSH_IPK_DIR)/CONTROL/control:
	@install -d $(OPENSSH_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: openssh" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENSSH_PRIORITY)" >>$@
	@echo "Section: $(OPENSSH_SECTION)" >>$@
	@echo "Version: $(OPENSSH_VERSION)-$(OPENSSH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENSSH_MAINTAINER)" >>$@
	@echo "Source: $(OPENSSH_SITE)/$(OPENSSH_SOURCE)" >>$@
	@echo "Description: $(OPENSSH_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENSSH_DEPENDS)" >>$@
	@echo "Suggests: $(OPENSSH_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENSSH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
$(OPENSSH_IPK): $(OPENSSH_BUILD_DIR)/.built
	rm -rf $(OPENSSH_IPK_DIR) $(BUILD_DIR)/openssh_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(OPENSSH_BUILD_DIR) DESTDIR=$(OPENSSH_IPK_DIR) install-nokeys
	rm -rf $(OPENSSH_IPK_DIR)/opt/share
	rm -rf $(OPENSSH_IPK_DIR)/opt/man
	install -d $(OPENSSH_IPK_DIR)/opt/etc/init.d/
	install -d $(OPENSSH_IPK_DIR)/opt/var/run/
	install -m 755 $(OPENSSH_SOURCE_DIR)/rc.openssh $(OPENSSH_IPK_DIR)/opt/etc/init.d/S40sshd
	$(MAKE) $(OPENSSH_IPK_DIR)/CONTROL/control
	install -m 755 $(OPENSSH_SOURCE_DIR)/postinst $(OPENSSH_IPK_DIR)/CONTROL/postinst
	install -m 755 $(OPENSSH_SOURCE_DIR)/prerm $(OPENSSH_IPK_DIR)/CONTROL/prerm
	echo $(OPENSSH_CONFFILES) | sed -e 's/ /\n/g' > $(OPENSSH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENSSH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
openssh-ipk: $(OPENSSH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
openssh-clean:
	rm -f $(OPENSSH_BUILD_DIR)/.built
	-$(MAKE) -C $(OPENSSH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
openssh-dirclean:
	rm -rf $(BUILD_DIR)/$(OPENSSH_DIR) $(OPENSSH_BUILD_DIR) $(OPENSSH_IPK_DIR) $(OPENSSH_IPK)
#
#
# Some sanity check for the package.
#
openssh-check: $(OPENSSH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OPENSSH_IPK)
