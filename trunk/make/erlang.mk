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
ERLANG_UPSTREAM_VERSION=R15B
ERLANG_VERSION=R15B
ERLANG_SOURCE=otp_src_$(ERLANG_UPSTREAM_VERSION).tar.gz
ERLANG_DIR=otp_src_$(ERLANG_UPSTREAM_VERSION)
ERLANG_UNZIP=zcat
ERLANG_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
ERLANG_DESCRIPTION=A dynamic programming language and runtime environment, with built-in support for concurrency, distribution and fault tolerance
ERLANG_SECTION=misc
ERLANG_PRIORITY=optional
ERLANG_DEPENDS=ncurses
ERLANG_SUGGESTS=
ERLANG_CONFLICTS=

ERLANG_DOC_MAN_SOURCE=otp_doc_man_$(ERLANG_UPSTREAM_VERSION).tar.gz
ERLANG_DOC_HTML_SOURCE=otp_doc_html_$(ERLANG_UPSTREAM_VERSION).tar.gz

ERLANG_MAKE_OPTION=
#"OTP_SMALL_BUILD=true"

#
# ERLANG_IPK_VERSION should be incremented when the ipk changes.
#
ERLANG_IPK_VERSION=1

ERLANG_TARGET=$(shell $(SOURCE_DIR)/common/config.sub $(GNU_TARGET_NAME))


ERLANG_HIPE=$(strip \
	$(if $(filter none, $(TARGET_ARCH)), --enable-hipe, \
	--disable-hipe))
ERLANG_SMP ?= --disable-smp-support

#
# ERLANG_CONFFILES should be a list of user-editable files
#ERLANG_CONFFILES=/opt/etc/erlang.conf /opt/etc/init.d/SXXerlang

#
# ERLANG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ERLANG_PATCHES=\
	$(ERLANG_SOURCE_DIR)/erts-configure.in.patch \
	$(ERLANG_SOURCE_DIR)/lib-odbc-c_src-Makefile.in.patch \

ERLANG_CROSS_PATCHES=$(ERLANG_PATCHES)

ifeq ($(HOSTCC), $(TARGET_CC))
ERLANG_HOST_BUILT=
else
ERLANG_HOST_BUILT=$(ERLANG_HOST_BUILD_DIR)/.built
ERLANG_CROSS_PATCHES += $(ERLANG_SOURCE_DIR)/cross-hipe_mkliterals.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ERLANG_CPPFLAGS=
ifdef NO_BUILTIN_MATH
ifeq ($(OPTWARE_TARGET), $(filter openwrt-brcm24 openwrt-ixp4xx, $(OPTWARE_TARGET)))
ERLANG_CPPFLAGS+=-DNO_ACOSH -DNO_ASINH -DNO_ATANH -DNO_ERF -DNO_ERFC
endif
endif
ERLANG_LDFLAGS=

ERLANG_CONFIG_ENVS ?= erl_cv_time_correction=$(strip \
	$(if $(filter syno-x07 wdtv, $(OPTWARE_TARGET)), times, \
	$(if $(filter module-init-tools, $(PACKAGES)), clock_gettime, times)))

ERLANG_CONFIG_ARGS=$(ERLANG_SMP) --enable-threads \
--enable-dynamic-ssl-lib --with-ssl-zlib=$(STAGING_LIB_DIR)
ERLANG_CONFIG_ARGS+=$(ERLANG_HIPE)

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
ERLANG_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/erlang
ERLANG_SOURCE_DIR=$(SOURCE_DIR)/erlang

ERLANG_IPK_DIR=$(BUILD_DIR)/erlang-$(ERLANG_VERSION)-ipk
ERLANG_IPK=$(BUILD_DIR)/erlang_$(ERLANG_VERSION)-$(ERLANG_IPK_VERSION)_$(TARGET_ARCH).ipk

ERLANG-LIBS_IPK_DIR=$(BUILD_DIR)/erlang-libs-$(ERLANG_VERSION)-ipk
ERLANG-LIBS_IPK=$(BUILD_DIR)/erlang-libs_$(ERLANG_VERSION)-$(ERLANG_IPK_VERSION)_$(TARGET_ARCH).ipk

ERLANG-MANPAGES_IPK_DIR=$(BUILD_DIR)/erlang-manpages-$(ERLANG_VERSION)-ipk
ERLANG-MANPAGES_IPK=$(BUILD_DIR)/erlang-manpages_$(ERLANG_VERSION)-$(ERLANG_IPK_VERSION)_$(TARGET_ARCH).ipk

ERLANG-DOC-HTML_IPK_DIR=$(BUILD_DIR)/erlang-doc-html-$(ERLANG_VERSION)-ipk
ERLANG-DOC-HTML_IPK=$(BUILD_DIR)/erlang-doc-html_$(ERLANG_VERSION)-$(ERLANG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: erlang-source erlang-unpack erlang-config erlang erlang-stage erlang-ipk erlang-clean erlang-dirclean erlang-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ERLANG_SOURCE) $(DL_DIR)/$(ERLANG_DOC_MAN_SOURCE) $(DL_DIR)/$(ERLANG_DOC_HTML_SOURCE):
	$(WGET) -N -P $(DL_DIR) \
		$(ERLANG_SITE)/$(ERLANG_SOURCE) \
		$(ERLANG_SITE)/$(ERLANG_DOC_MAN_SOURCE) \
		$(ERLANG_SITE)/$(ERLANG_DOC_HTML_SOURCE) \

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
erlang-source: $(DL_DIR)/$(ERLANG_SOURCE) $(DL_DIR)/$(ERLANG_DOC_MAN_SOURCE) $(DL_DIR)/$(ERLANG_DOC_HTML_SOURCE) $(ERLANG_PATCHES)

$(ERLANG_HOST_BUILD_DIR)/.configured: host/.configured \
		$(DL_DIR)/$(ERLANG_SOURCE) \
		$(DL_DIR)/$(ERLANG_DOC_MAN_SOURCE) \
		$(DL_DIR)/$(ERLANG_DOC_HTML_SOURCE) \
		$(ERLANG_PATCHES) make/erlang.mk
	rm -rf $(HOST_BUILD_DIR)/$(ERLANG_DIR) $(@D)
	$(ERLANG_UNZIP) $(DL_DIR)/$(ERLANG_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	cat $(ERLANG_PATCHES) | patch -d $(HOST_BUILD_DIR)/$(ERLANG_DIR) -p1
	mv $(HOST_BUILD_DIR)/$(ERLANG_DIR) $(@D)
#	hack to reduce build host dependency on ncurses-dev
	$(MAKE) termcap-source
	$(TERMCAP_UNZIP) $(DL_DIR)/$(TERMCAP_SOURCE) | tar -C $(@D) -xvf -
	mv $(@D)/termcap-$(TERMCAP_VERSION) $(@D)/termcap
	(cd $(@D)/termcap; \
		./configure; \
		make; \
	)
#	configure erlang (host version)
	(cd $(@D); \
		CPPFLAGS="-I$(ERLANG_HOST_BUILD_DIR)/termcap" \
		LDFLAGS="-L$(ERLANG_HOST_BUILD_DIR)/termcap" \
		./configure \
		--prefix=/opt \
		--without-ssl \
		--disable-smp-support \
		--disable-hipe \
		--disable-nls \
	)
	touch $@

$(ERLANG_HOST_BUILD_DIR)/.built: $(ERLANG_HOST_BUILD_DIR)/.configured
	rm -f $@
	# build host erlang
	CPPFLAGS="-I$(@D)/termcap" \
	LDFLAGS="-L$(@D)/termcap" \
	$(MAKE) -C $(@D) $(ERLANG_MAKE_OPTION)
#	cp -fp $(@D)/bin/*/hipe_mkliterals $(@D)/bin/
	touch $@

erlang-host: $(ERLANG_HOST_BUILD_DIR)/.built

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
$(ERLANG_BUILD_DIR)/.unpacked: \
		$(DL_DIR)/$(ERLANG_SOURCE) \
		$(DL_DIR)/$(ERLANG_DOC_MAN_SOURCE) \
		$(DL_DIR)/$(ERLANG_DOC_HTML_SOURCE) \
		$(ERLANG_CROSS_PATCHES) \
		make/erlang.mk
	$(MAKE) ncurses-stage openssl-stage unixodbc-stage
	rm -rf $(BUILD_DIR)/$(ERLANG_DIR) $(@D)
	$(ERLANG_UNZIP) $(DL_DIR)/$(ERLANG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(ERLANG_CROSS_PATCHES) | patch -bd $(BUILD_DIR)/$(ERLANG_DIR) -p1
	mv $(BUILD_DIR)/$(ERLANG_DIR) $(@D)
	sed -i -e "s:HOST_HIPE_MKLITERAL_PATH:$(ERLANG_HOST_BUILD_DIR)/bin/`sources/common/config.guess`:" $(@D)/erts/emulator/Makefile.in
	touch $@

erlang-unpack: $(ERLANG_BUILD_DIR)/.unpacked

$(ERLANG_BUILD_DIR)/erl-xcomp.conf: $(ERLANG_BUILD_DIR)/.unpacked
	touch $@

ifeq ($(HOSTCC), $(TARGET_CC))
$(ERLANG_BUILD_DIR)/.configured: $(ERLANG_BUILD_DIR)/.unpacked
else
$(ERLANG_BUILD_DIR)/.configured: $(ERLANG_BUILD_DIR)/erl-xcomp.conf
endif
	rm -f $@
	sed -i -e '/^std_ssl_locations=/s|=.*|=/opt|' $(@D)/erts/configure
ifeq ($(HOSTCC), $(TARGET_CC))
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERLANG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
                --with-ssl=$(STAGING_DIR)/opt \
		$(ERLANG_CONFIG_ARGS) \
		--disable-nls \
	)
else
	sed -i -e '/^LDFLAGS/s|$$| $(STAGING_LDFLAGS)|' $(@D)/lib/crypto/c_src/Makefile.in
	(cd $(@D); \
		PATH="$(ERLANG_HOST_BUILD_DIR)/bin:$$PATH" \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERLANG_LDFLAGS)" \
		$(ERLANG_CONFIG_ENVS) \
		ac_cv_sizeof_size_t=4 \
		ac_cv_sizeof_off_t=4 \
		ac_cv_func_mmap_fixed_mapped=yes \
		erl_xcomp_sysroot="$(STAGING_DIR)" \
		ERL_TOP=$(@D) \
		OVERRIDE_TARGET=$(ERLANG_TARGET) \
		./otp_build configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-ssl=$(STAGING_PREFIX) \
		--with-odbc=$(STAGING_PREFIX) \
		--disable-hipe \
		$(ERLANG_CONFIG_ARGS) \
		--disable-nls \
		; \
	)
endif
	touch $@

erlang-config: $(ERLANG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ERLANG_BUILD_DIR)/.built: $(ERLANG_BUILD_DIR)/.configured $(ERLANG_HOST_BUILT)
	rm -f $@
	(cd $(@D); \
		PATH="$(ERLANG_HOST_BUILD_DIR)/bin:$$PATH" \
		$(TARGET_CONFIGURE_OPTS) \
		ERL_TOP=$(@D) \
		OVERRIDE_TARGET=$(ERLANG_TARGET) \
		./otp_build release; \
	)
	touch $@

#
# This is the build convenience target.
#
erlang: $(ERLANG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ERLANG_BUILD_DIR)/.staged: $(ERLANG_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_LIB_DIR)/erlang
	PATH="$(ERLANG_HOST_BUILD_DIR)/bin:$$PATH" \
		TARGET=$(ERLANG_TARGET) \
		OVERRIDE_TARGET=$(ERLANG_TARGET) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERLANG_LDFLAGS)" \
		$(MAKE) -C $(@D) INSTALL_PREFIX=$(STAGING_DIR) $(ERLANG_MAKE_OPTION) install
	touch $@

erlang-stage: $(ERLANG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/erlang
#
$(ERLANG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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

$(ERLANG-LIBS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: erlang-libs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ERLANG_PRIORITY)" >>$@
	@echo "Section: $(ERLANG_SECTION)" >>$@
	@echo "Version: $(ERLANG_VERSION)-$(ERLANG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ERLANG_MAINTAINER)" >>$@
	@echo "Source: $(ERLANG_SITE)/$(ERLANG_SOURCE)" >>$@
	@echo "Description: full libs for erlang" >>$@
	@echo "Depends: erlang (= $(ERLANG_VERSION)-$(ERLANG_IPK_VERSION))" >>$@
	@echo "Suggests: openssl, unixodbc" >>$@
	@echo "Conflicts: $(ERLANG_CONFLICTS)" >>$@

$(ERLANG-MANPAGES_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: erlang-manpages" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ERLANG_PRIORITY)" >>$@
	@echo "Section: $(ERLANG_SECTION)" >>$@
	@echo "Version: $(ERLANG_VERSION)-$(ERLANG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ERLANG_MAINTAINER)" >>$@
	@echo "Source: $(ERLANG_SITE)/$(ERLANG_SOURCE)" >>$@
	@echo "Description: man pages for erlang" >>$@
	@echo "Depends: " >>$@
	@echo "Suggests: $(ERLANG_SUGGESTS)" >>$@
	@echo "Conflicts: $(ERLANG_CONFLICTS)" >>$@

$(ERLANG-DOC-HTML_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: erlang-doc-html" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ERLANG_PRIORITY)" >>$@
	@echo "Section: $(ERLANG_SECTION)" >>$@
	@echo "Version: $(ERLANG_VERSION)-$(ERLANG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ERLANG_MAINTAINER)" >>$@
	@echo "Source: $(ERLANG_SITE)/$(ERLANG_SOURCE)" >>$@
	@echo "Description: HTML doc for erlang" >>$@
	@echo "Depends: " >>$@
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
$(ERLANG_IPK) $(ERLANG-LIBS_IPK) $(ERLANG-MANPAGES_IPK) $(ERLANG-DOC-HTML_IPK): $(ERLANG_BUILD_DIR)/.built
	rm -rf $(ERLANG_IPK_DIR) $(BUILD_DIR)/erlang_*_$(TARGET_ARCH).ipk
	rm -rf $(ERLANG-LIBS_IPK_DIR) $(BUILD_DIR)/erlang-libs_*_$(TARGET_ARCH).ipk
	rm -rf $(ERLANG-MANPAGES_IPK_DIR) $(BUILD_DIR)/erlang-manpages_*_$(TARGET_ARCH).ipk
	rm -rf $(ERLANG-DOC-HTML_IPK_DIR) $(BUILD_DIR)/erlang-doc-html_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ERLANG_HOST_BUILD_DIR) \
		INSTALL_PREFIX=$(ERLANG_HOST_BUILD_DIR) $(ERLANG_MAKE_OPTION) install
	install -d $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/
ifeq ($(HOSTCC), $(TARGET_CC))
	TARGET=$(ERLANG_TARGET) \
		OVERRIDE_TARGET=$(ERLANG_TARGET) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERLANG_LDFLAGS)" \
		$(MAKE) -C $(ERLANG_BUILD_DIR) INSTALL_PREFIX=$(ERLANG_IPK_DIR) $(ERLANG_MAKE_OPTION) install
	# 
	for f in erl start; do \
        	sed -i -e 's:ROOTDIR=.*:ROOTDIR=/opt/lib/erlang:' $(ERLANG_IPK_DIR)/opt/lib/erlang/erts*/bin/$$f; \
        done
else
	cp -r `find $(ERLANG_HOST_BUILD_DIR)/bin -mindepth 1 -type d` $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/
	cp -p $(ERLANG_HOST_BUILD_DIR)/bin/erl $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/erl-host
	sed -i -e 's:ROOTDIR=.*:ROOTDIR=$(ERLANG_IPK_DIR)/opt/lib/erlang:' $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/erl-host
	PATH="$(ERLANG_HOST_BUILD_DIR)/bin:$$PATH" \
		TARGET=$(ERLANG_TARGET) \
		OVERRIDE_TARGET=$(ERLANG_TARGET) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERLANG_LDFLAGS)" \
		$(MAKE) -C $(ERLANG_BUILD_DIR) INSTALL_PREFIX=$(ERLANG_IPK_DIR) $(ERLANG_MAKE_OPTION) install
	rm -f $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/erl-host
	rm -rf `find $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/ -mindepth 1 -type d`
	#
	for f in erl start; do \
        	sed -i -e 's:ROOTDIR=.*:ROOTDIR=/opt/lib/erlang:' $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/$$f; \
        done
endif
	# strip binaries
	for f in \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/bin/erlc \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/bin/escript \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/bin/dialyzer \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/bin/run_erl \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/bin/run_test \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/bin/typer \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/bin/to_erl \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/beam* \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/child_setup* \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/ct_run \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/dyn_erl \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/epmd \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/erlc \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/erlexec \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/escript \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/heart \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/inet_gethost \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/run_erl \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/run_test \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/to_erl \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/typer \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/dialyzer \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/lib/tools-*/bin/emem \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/lib/erl_interface-*/bin/erl_call \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/lib/odbc-*/priv/bin/odbcserver \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/lib/orber-*/priv/bin/obj_init_port \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/lib/os_mon-*/priv/bin/memsup \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/lib/os_mon-*/priv/bin/cpu_sup \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/lib/ssl-*/priv/bin/ssl_esock \
	; do \
		[ -f $$f ] && $(STRIP_COMMAND) $$f || true; \
        done
	for f in `find $(ERLANG_IPK_DIR)/opt/lib -name '*.so'`; do $(STRIP_COMMAND) $$f; done
	# symlinks in /opt/bin
#	cd $(ERLANG_IPK_DIR)/opt/bin; \
        for f in erl erlc; do \
        	ln -s ../lib/erlang/bin/$$f .; \
        done

	install -d $(ERLANG-LIBS_IPK_DIR)/opt/lib/erlang/lib
	for d in `ls $(ERLANG_IPK_DIR)/opt/lib/erlang/lib | egrep -v '^compiler-|^kernel-|^sasl-|^stdlib-|^tools-|^hipe-'`; \
		do mv $(ERLANG_IPK_DIR)/opt/lib/erlang/lib/$$d $(ERLANG-LIBS_IPK_DIR)/opt/lib/erlang/lib; done
	install -d $(ERLANG-LIBS_IPK_DIR)/opt/lib/erlang/bin
	mv $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/dialyzer $(ERLANG-LIBS_IPK_DIR)/opt/lib/erlang/bin/dialyzer
	install -d $(ERLANG-LIBS_IPK_DIR)/opt/bin
	mv $(ERLANG_IPK_DIR)/opt/bin/dialyzer $(ERLANG-LIBS_IPK_DIR)/opt/bin/

	$(MAKE) $(ERLANG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ERLANG_IPK_DIR)

	$(MAKE) $(ERLANG-LIBS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ERLANG-LIBS_IPK_DIR)

	install -d $(ERLANG-MANPAGES_IPK_DIR)/opt/share/
	$(ERLANG_UNZIP) $(DL_DIR)/$(ERLANG_DOC_MAN_SOURCE) | \
		tar -C $(ERLANG-MANPAGES_IPK_DIR)/opt/share/ -xvf -
	$(MAKE) $(ERLANG-MANPAGES_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ERLANG-MANPAGES_IPK_DIR)

	install -d $(ERLANG-DOC-HTML_IPK_DIR)/opt/share/doc/erlang-doc-html
	$(ERLANG_UNZIP) $(DL_DIR)/$(ERLANG_DOC_HTML_SOURCE) | \
		tar -C $(ERLANG-DOC-HTML_IPK_DIR)/opt/share/doc/erlang-doc-html -xvf -
	$(MAKE) $(ERLANG-DOC-HTML_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ERLANG-DOC-HTML_IPK_DIR)

	$(WHAT_TO_DO_WITH_IPK_DIR) $(ERLANG_IPK_DIR) $(ERLANG-LIBS_IPK_DIR) $(ERLANG-MANPAGES_IPK_DIR) $(ERLANG-DOC-HTML_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
erlang-ipk: $(ERLANG_IPK) $(ERLANG-LIBS_IPK) $(ERLANG-MANPAGES_IPK) $(ERLANG-DOC-HTML_IPK)

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
	rm -rf $(BUILD_DIR)/$(ERLANG_DIR) $(ERLANG_BUILD_DIR) \
		$(ERLANG_IPK_DIR) $(ERLANG_IPK) \
		$(ERLANG-LIBS_IPK_DIR) $(ERLANG-LIBS_IPK) \
		$(ERLANG-MANPAGES_IPK_DIR) $(ERLANG-MANPAGES_IPK) \
		$(ERLANG-DOC-HTML_IPK_DIR) $(ERLANG-DOC-HTML_IPK) \

#
# Some sanity check for the package.
#
erlang-check: $(ERLANG_IPK) $(ERLANG-LIBS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
