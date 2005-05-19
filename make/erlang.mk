###########################################################
#
# erlang
#
###########################################################

#
# ERLANG_VERSION, ERLANG_SITE and ERLANG_SOURCE define
# the upstream location of the source code for the package.
# ERLANG_DIR is the directory which is created when the source
# archive is unpacked.
# ERLANG_UNZIP is the command used to unzip the source.
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
ERLANG_SITE=http://erlang.org/download
ERLANG_TARBALL_VERSION=R10B-5
ERLANG_VERSION=R10B5
ERLANG_SOURCE=otp_src_$(ERLANG_TARBALL_VERSION).tar.gz
ERLANG_DIR=otp_src_$(ERLANG_TARBALL_VERSION)
ERLANG_UNZIP=zcat
ERLANG_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
ERLANG_DESCRIPTION=Erlang is a general-purpose programming language and runtime environment, with built-in support for concurrency, distribution and fault tolerance.
ERLANG_SECTION=misc
ERLANG_PRIORITY=optional
ERLANG_DEPENDS=ncurses openssl
ERLANG_SUGGESTS=
ERLANG_CONFLICTS=

ERLANG_MAKE_OPTION="OTP_SMALL_BUILD=true"

#
# ERLANG_IPK_VERSION should be incremented when the ipk changes.
#
ERLANG_IPK_VERSION=3

#
# ERLANG_CONFFILES should be a list of user-editable files
#ERLANG_CONFFILES=/opt/etc/erlang.conf /opt/etc/init.d/SXXerlang

#
# ERLANG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ERLANG_PATCHES=\
	$(ERLANG_SOURCE_DIR)/Makefile.in.patch \
	$(ERLANG_SOURCE_DIR)/erts-emulator-Makefile.in.patch \
	$(ERLANG_SOURCE_DIR)/erts-etc-unix-Install.src.patch \
	$(ERLANG_SOURCE_DIR)/lib-crypto-c_src-Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ERLANG_CPPFLAGS=
ERLANG_LDFLAGS=

#
# ERLANG_BUILD_DIR is the directory in which the build is done.
# ERLANG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ERLANG_IPK_DIR is the directory in which the ipk is built.
# ERLANG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ERLANG_BUILD_DIR=$(BUILD_DIR)/erlang
ERLANG_SOURCE_DIR=$(SOURCE_DIR)/erlang
ERLANG_IPK_DIR=$(BUILD_DIR)/erlang-$(ERLANG_VERSION)-ipk
ERLANG_IPK=$(BUILD_DIR)/erlang_$(ERLANG_VERSION)-$(ERLANG_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ERLANG_SOURCE):
	$(WGET) -P $(DL_DIR) $(ERLANG_SITE)/$(ERLANG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
erlang-source: $(DL_DIR)/$(ERLANG_SOURCE) $(ERLANG_PATCHES)

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
$(ERLANG_BUILD_DIR)/.configured: $(DL_DIR)/$(ERLANG_SOURCE) $(ERLANG_PATCHES)
	$(MAKE) ncurses-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(ERLANG_DIR) $(ERLANG_BUILD_DIR)
	$(ERLANG_UNZIP) $(DL_DIR)/$(ERLANG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(ERLANG_PATCHES) | patch -d $(BUILD_DIR)/$(ERLANG_DIR) -p1
	mv $(BUILD_DIR)/$(ERLANG_DIR) $(ERLANG_BUILD_DIR)
	(cd $(ERLANG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERLANG_LDFLAGS)" \
		ac_cv_prog_javac_ver_1_2=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
                --with-ssl=$(STAGING_DIR)/opt \
                --disable-hipe \
		--disable-nls \
	)
	touch $(ERLANG_BUILD_DIR)/.configured

erlang-unpack: $(ERLANG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ERLANG_BUILD_DIR)/.built: $(ERLANG_BUILD_DIR)/.configured
	rm -f $(ERLANG_BUILD_DIR)/.built
	TARGET=$(GNU_TARGET_NAME)-gnu \
		OVERRIDE_TARGET=$(GNU_TARGET_NAME)-gnu \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERLANG_LDFLAGS)" \
		$(MAKE) -C $(ERLANG_BUILD_DIR) $(ERLANG_MAKE_OPTION)
	ERL_TOP=$(ERLANG_BUILD_DIR) PATH="$(ERLANG_BUILD_DIR)/bin:$$PATH" \
		TARGET=$(GNU_TARGET_NAME)-gnu \
		OVERRIDE_TARGET=$(GNU_TARGET_NAME)-gnu \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERLANG_LDFLAGS)" \
		$(MAKE) -C $(ERLANG_BUILD_DIR)/erts/boot/src $(ERLANG_MAKE_OPTION)
	touch $(ERLANG_BUILD_DIR)/.built

#
# This is the build convenience target.
#
erlang: $(ERLANG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ERLANG_BUILD_DIR)/.staged: $(ERLANG_BUILD_DIR)/.built
	rm -f $(ERLANG_BUILD_DIR)/.staged
	$(MAKE) -C $(ERLANG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ERLANG_BUILD_DIR)/.staged

erlang-stage: $(ERLANG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/erlang
#
$(ERLANG_IPK_DIR)/CONTROL/control:
	@install -d $(ERLANG_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: erlang" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ERLANG_PRIORITY)" >>$@
	@echo "Section: $(ERLANG_SECTION)" >>$@
	@echo "Version: $(ERLANG_VERSION)-$(ERLANG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ERLANG_MAINTAINER)" >>$@
	@echo "Source: $(ERLANG_SITE)/$(ERLANG_SOURCE)" >>$@
	@echo "Description: $(ERLANG_DESCRIPTION)" >>$@
	@echo "Depends: $(ERLANG_DEPENDS)" >>$@
	@echo "Suggests: $(ERLANG_SUGGESTS)" >>$@
	@echo "Conflicts: $(ERLANG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ERLANG_IPK_DIR)/opt/sbin or $(ERLANG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ERLANG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ERLANG_IPK_DIR)/opt/etc/erlang/...
# Documentation files should be installed in $(ERLANG_IPK_DIR)/opt/doc/erlang/...
# Daemon startup scripts should be installed in $(ERLANG_IPK_DIR)/opt/etc/init.d/S??erlang
#
# You may need to patch your application to make it use these locations.
#
$(ERLANG_IPK): $(ERLANG_BUILD_DIR)/.built
	rm -rf $(ERLANG_IPK_DIR) $(BUILD_DIR)/erlang_*_$(TARGET_ARCH).ipk
	TARGET=$(GNU_TARGET_NAME)-gnu \
		OVERRIDE_TARGET=$(GNU_TARGET_NAME)-gnu \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERLANG_LDFLAGS)" \
		$(MAKE) -C $(ERLANG_BUILD_DIR) INSTALL_PREFIX=$(ERLANG_IPK_DIR) $(ERLANG_MAKE_OPTION) install
	# 
	for f in erl start; do \
        	sed -i -e 's:ROOTDIR=.*:ROOTDIR=/opt/lib/erlang:' $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/$$f; \
        done
	# SAE related scripts
	install $(ERLANG_BUILD_DIR)/bin/$(GNU_TARGET_NAME)-gnu/beam_evm $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/
	ERTS_VERSION=`cd $(ERLANG_IPK_DIR)/opt/lib/erlang; ls -d erts-*`; \
	install $(ERLANG_BUILD_DIR)/erts/boot/src/erlang.ear $(ERLANG_IPK_DIR)/opt/lib/erlang/$$ERTS_VERSION; \
	for f in ear ecc elink escript esh; do \
        	install $(ERLANG_BUILD_DIR)/erts/boot/src/$$f $(ERLANG_IPK_DIR)/opt/lib/erlang/bin; \
		sed -i -e "s:ERLANG_EARS=.*:ERLANG_EARS=/opt/lib/erlang/$$ERTS_VERSION:" $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/$$f; \
	done
	for f in ecc elink; do \
		sed -i -e 's:exec .*beam_evm:exec /opt/bin/beam_evm:' $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/$$f; \
	done
	# strip binaries
	for f in \
		"lib/erlang/bin/beam_evm" \
		"lib/erlang/bin/erlc" \
		"lib/erlang/bin/run_erl" \
		"lib/erlang/bin/to_erl" \
		"lib/erlang/erts-*/bin/beam*" \
		"lib/erlang/erts-*/bin/child_setup*" \
		"lib/erlang/erts-*/bin/epmd" \
		"lib/erlang/erts-*/bin/erlc" \
		"lib/erlang/erts-*/bin/erlexec" \
		"lib/erlang/erts-*/bin/heart" \
		"lib/erlang/erts-*/bin/inet_gethost" \
		"lib/erlang/erts-*/bin/run_erl" \
		"lib/erlang/erts-*/bin/to_erl" \
	; do \
		$(STRIP_COMMAND) $(ERLANG_IPK_DIR)/opt/$$f; \
        done
	# symlinks in /opt/bin
	cd $(ERLANG_IPK_DIR)/opt/bin; \
        for f in beam_evm erl erlc ear ecc elink escript esh; do \
        	ln -s ../lib/erlang/bin/$$f .; \
        done
	$(MAKE) $(ERLANG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ERLANG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
erlang-ipk: $(ERLANG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
erlang-clean:
	-$(MAKE) -C $(ERLANG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
erlang-dirclean:
	rm -rf $(BUILD_DIR)/$(ERLANG_DIR) $(ERLANG_BUILD_DIR) $(ERLANG_IPK_DIR) $(ERLANG_IPK)
