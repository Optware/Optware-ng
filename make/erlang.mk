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
ERLANG_UPSTREAM_VERSION=R11B-4
ERLANG_VERSION=R11B4
ERLANG_SOURCE=otp_src_$(ERLANG_UPSTREAM_VERSION).tar.gz
ERLANG_DIR=otp_src_$(ERLANG_UPSTREAM_VERSION)
ERLANG_UNZIP=zcat
ERLANG_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
ERLANG_DESCRIPTION=A dynamic programming language and runtime environment, with built-in support for concurrency, distribution and fault tolerance
ERLANG_SECTION=misc
ERLANG_PRIORITY=optional
ERLANG_DEPENDS=ncurses, openssl
ERLANG_SUGGESTS=
ERLANG_CONFLICTS=

ERLANG_DOC_MAN_SOURCE=otp_doc_man_$(ERLANG_UPSTREAM_VERSION).tar.gz
ERLANG_DOC_HTML_SOURCE=otp_doc_html_$(ERLANG_UPSTREAM_VERSION).tar.gz

ERLANG_MAKE_OPTION=
#"OTP_SMALL_BUILD=true"
ERLANG_WITH_SAE=no

#
# ERLANG_IPK_VERSION should be incremented when the ipk changes.
#
ERLANG_IPK_VERSION=3

ERLANG_TARGET=$(strip $(shell echo $(GNU_TARGET_NAME) | sed '/^[^-]*-linux$$/s|-linux|-unknown-linux|'))-gnu

ERLANG_HIPE=$(strip \
	$(if $(filter arm armeb powerpc, $(TARGET_ARCH)), --enable-hipe, \
	--disable-hipe))

#
# ERLANG_CONFFILES should be a list of user-editable files
#ERLANG_CONFFILES=/opt/etc/erlang.conf /opt/etc/init.d/SXXerlang

#
# ERLANG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ERLANG_PATCHES=\
	$(ERLANG_SOURCE_DIR)/Makefile.in.patch \
	$(ERLANG_SOURCE_DIR)/erts-etc-unix-Install.src.patch \
	$(ERLANG_SOURCE_DIR)/erts-configure.in.patch \
	$(ERLANG_SOURCE_DIR)/lib-crypto-c_src-Makefile.in.patch \
	$(ERLANG_SOURCE_DIR)/lib-erl_interface-src-Makefile.in.patch \
	$(ERLANG_SOURCE_DIR)/lib-orber-c_src-Makefile.in.patch \
	$(ERLANG_SOURCE_DIR)/lib-ssl-c_src-Makefile.in.patch

ifeq ($(HOSTCC), $(TARGET_CC))
ERLANG_HOST_BUILT=
else
ERLANG_HOST_BUILT=$(ERLANG_HOST_BUILD_DIR)/.built
ERLANG_PATCHES+=\
	$(ERLANG_SOURCE_DIR)/erts-boot-src-Makefile.patch \
	$(ERLANG_SOURCE_DIR)/cross-hipe_mkliterals.patch
endif

ifeq ($(ERLANG_WITH_SAE), yes)
ERLANG_PATCHES+=$(ERLANG_SOURCE_DIR)/erts-emulator-build-sae.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ERLANG_CPPFLAGS=
ERLANG_LDFLAGS=
ERLANG_CONFIG_ARGS=--disable-smp-support --enable-threads
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

.PHONY: erlang-source erlang-unpack erlang erlang-stage erlang-ipk erlang-clean erlang-dirclean erlang-check

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
	rm -rf $(HOST_BUILD_DIR)/$(ERLANG_DIR) $(ERLANG_HOST_BUILD_DIR)
	$(ERLANG_UNZIP) $(DL_DIR)/$(ERLANG_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	cat $(ERLANG_PATCHES) | patch -d $(HOST_BUILD_DIR)/$(ERLANG_DIR) -p1
	mv $(HOST_BUILD_DIR)/$(ERLANG_DIR) $(ERLANG_HOST_BUILD_DIR)
#	hack to reduce build host dependency on ncurses-dev
	$(TERMCAP_UNZIP) $(DL_DIR)/$(TERMCAP_SOURCE) | tar -C $(ERLANG_HOST_BUILD_DIR) -xvf -
	mv $(ERLANG_HOST_BUILD_DIR)/termcap-$(TERMCAP_VERSION) $(ERLANG_HOST_BUILD_DIR)/termcap
	(cd $(ERLANG_HOST_BUILD_DIR)/termcap; \
		./configure; \
		make; \
	)
#	configure erlang (host version)
	(cd $(ERLANG_HOST_BUILD_DIR); \
		ac_cv_prog_javac_ver_1_2=no \
		CPPFLAGS="-I$(ERLANG_HOST_BUILD_DIR)/termcap" \
		LDFLAGS="-L$(ERLANG_HOST_BUILD_DIR)/termcap" \
		./configure \
		--prefix=/opt \
                --without-ssl \
		--disable-smp-support \
                --disable-hipe \
		--disable-nls \
	)
	touch $(ERLANG_HOST_BUILD_DIR)/.configured

$(ERLANG_HOST_BUILD_DIR)/.built: $(ERLANG_HOST_BUILD_DIR)/.configured
	# build host erlang
	CPPFLAGS="-I$(ERLANG_HOST_BUILD_DIR)/termcap" \
	LDFLAGS="-L$(ERLANG_HOST_BUILD_DIR)/termcap" \
	$(MAKE) -C $(ERLANG_HOST_BUILD_DIR) $(ERLANG_MAKE_OPTION)
ifeq ($(ERLANG_WITH_SAE), yes)
	# build host SAE (StandAlone Erlang)
	ERL_TOP=$(ERLANG_HOST_BUILD_DIR) \
	PATH="$(ERLANG_HOST_BUILD_DIR)/bin:$(ERLANG_HOST_BUILD_DIR)/erts/boot/src:$$PATH" \
		$(MAKE) -C $(ERLANG_HOST_BUILD_DIR)/erts/boot/src
endif
	touch $(ERLANG_HOST_BUILD_DIR)/.built

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
$(ERLANG_BUILD_DIR)/.configured: make/erlang.mk \
		$(ERLANG_HOST_BUILT) \
		$(DL_DIR)/$(ERLANG_SOURCE) \
		$(DL_DIR)/$(ERLANG_DOC_MAN_SOURCE) \
		$(DL_DIR)/$(ERLANG_DOC_HTML_SOURCE) \
		$(ERLANG_PATCHES)
	$(MAKE) ncurses-stage openssl-stage termcap-source
	rm -rf $(BUILD_DIR)/$(ERLANG_DIR) $(ERLANG_BUILD_DIR)
	$(ERLANG_UNZIP) $(DL_DIR)/$(ERLANG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(ERLANG_PATCHES) | patch -d $(BUILD_DIR)/$(ERLANG_DIR) -p1
	mv $(BUILD_DIR)/$(ERLANG_DIR) $(ERLANG_BUILD_DIR)
ifeq ($(HOSTCC), $(TARGET_CC))
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
		$(ERLANG_CONFIG_ARGS) \
		--disable-nls \
	)
else
#	configure erlang (cross version)
	(cd $(ERLANG_BUILD_DIR)/erts; \
		autoconf configure.in > configure; \
	)
	(cd $(ERLANG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERLANG_LDFLAGS)" \
		SHLIB_LD=$(TARGET_CC) \
		TARGET_ARCH=$(TARGET_ARCH) \
		ac_cv_prog_javac_ver_1_2=no \
		ac_cv_func_setvbuf_reversed=no \
		ac_cv_func_mmap_fixed_mapped=yes \
		ac_cv_sizeof_long_long=8 \
		ac_cv_sizeof_off_t=8 \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
                --with-ssl=$(STAGING_DIR)/opt \
		$(ERLANG_CONFIG_ARGS) \
		--disable-nls \
		; \
	    sed -i -e '/$$(ERL_TOP)\/bin\/dialyzer/s!$$(ERL_TOP).*!-$(ERLANG_HOST_BUILD_DIR)/bin/dialyzer --output_plt $$@ -pa $(ERLANG_BUILD_DIR)/lib/kernel/ebin -pa $(ERLANG_BUILD_DIR)/lib/mnesia/ebin -pa $(ERLANG_BUILD_DIR)/lib/stdlib/ebin -I /home/slug/optware/nslu2/builds/erlang/lib/hipe/icode --command-line ../ebin!' $(ERLANG_BUILD_DIR)/lib/dialyzer/src/Makefile; \
	)
endif
	touch $(ERLANG_BUILD_DIR)/.configured

erlang-unpack: $(ERLANG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ERLANG_BUILD_DIR)/.built: $(ERLANG_BUILD_DIR)/.configured
	rm -f $(ERLANG_BUILD_DIR)/.built
ifeq ($(HOSTCC), $(TARGET_CC))
	# build erlang
	TARGET=$(ERLANG_TARGET) \
		OVERRIDE_TARGET=$(ERLANG_TARGET) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERLANG_LDFLAGS)" \
		$(MAKE) -C $(ERLANG_BUILD_DIR) $(ERLANG_MAKE_OPTION)
  ifeq ($(ERLANG_WITH_SAE), yes)
	# build SAE (StandAlone Erlang)
	ERL_TOP=$(ERLANG_BUILD_DIR) PATH="$(ERLANG_BUILD_DIR)/bin:$$PATH" \
		TARGET=$(ERLANG_TARGET) \
		OVERRIDE_TARGET=$(ERLANG_TARGET) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERLANG_LDFLAGS)" \
		$(MAKE) -C $(ERLANG_BUILD_DIR)/erts/boot/src $(ERLANG_MAKE_OPTION)
  endif
else
	# build target erlang
	PATH="$(ERLANG_HOST_BUILD_DIR)/bin:$$PATH" \
		TARGET=$(ERLANG_TARGET) \
		OVERRIDE_TARGET=$(ERLANG_TARGET) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERLANG_LDFLAGS)" \
		$(MAKE) -C $(ERLANG_BUILD_DIR) noboot $(ERLANG_MAKE_OPTION)
  ifeq ($(ERLANG_WITH_SAE), yes)
	# build target SAE (StandAlone Erlang)
	ERL_TOP=$(ERLANG_BUILD_DIR) \
	PATH="$(ERLANG_HOST_BUILD_DIR)/bin:$(ERLANG_HOST_BUILD_DIR)/erts/boot/src:$$PATH" \
		TARGET=$(ERLANG_TARGET) \
		OVERRIDE_TARGET=$(ERLANG_TARGET) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ERLANG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ERLANG_LDFLAGS)" \
		$(MAKE) -C $(ERLANG_BUILD_DIR)/erts/boot/src $(ERLANG_MAKE_OPTION)
  endif
endif
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

$(ERLANG-LIBS_IPK_DIR)/CONTROL/control:
	@install -d $(ERLANG-LIBS_IPK_DIR)/CONTROL
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
	@echo "Suggests: $(ERLANG_SUGGESTS)" >>$@
	@echo "Conflicts: $(ERLANG_CONFLICTS)" >>$@

$(ERLANG-MANPAGES_IPK_DIR)/CONTROL/control:
	@install -d $(ERLANG-MANPAGES_IPK_DIR)/CONTROL
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
	@install -d $(ERLANG-DOC-HTML_IPK_DIR)/CONTROL
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
  ifeq ($(ERLANG_WITH_SAE), yes)
	# SAE related scripts
	install $(ERLANG_BUILD_DIR)/bin/$(ERLANG_TARGET)/beam_evm $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/
	ERTS_VERSION=`cd $(ERLANG_IPK_DIR)/opt/lib/erlang; ls -d erts-*`; \
	install $(ERLANG_BUILD_DIR)/erts/boot/src/erlang.ear $(ERLANG_IPK_DIR)/opt/lib/erlang/$$ERTS_VERSION; \
	for f in ear ecc elink escript esh; do \
        	install $(ERLANG_BUILD_DIR)/erts/boot/src/$$f $(ERLANG_IPK_DIR)/opt/lib/erlang/bin; \
		sed -i -e "s:ERLANG_EARS=.*:ERLANG_EARS=/opt/lib/erlang/$$ERTS_VERSION:" $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/$$f; \
	done
	for f in ecc elink; do \
		sed -i -e 's:exec .*beam_evm:exec /opt/bin/beam_evm:' $(ERLANG_IPK_DIR)/opt/lib/erlang/bin/$$f; \
	done
	for f in "lib/erlang/bin/beam_evm"; \
		do $(STRIP_COMMAND) $(ERLANG_IPK_DIR)/opt/$$f; done
  endif
	# strip binaries
	for f in \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/bin/erlc \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/bin/escript \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/bin/dialyzer \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/bin/run_erl \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/bin/typer \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/bin/to_erl \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/beam* \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/child_setup* \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/epmd \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/erlc \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/erlexec \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/escript \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/heart \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/inet_gethost \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/run_erl \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/to_erl \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/typer \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/erts-*/bin/dialyzer \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/lib/tools-*/bin/emem \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/lib/erl_interface-*/bin/erl_call \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/lib/orber-*/priv/bin/obj_init_port \
		$(ERLANG_IPK_DIR)/opt/lib/erlang/lib/os_mon-*/priv/bin/memsup \
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
  ifeq ($(ERLANG_WITH_SAE), yes)
#	cd $(ERLANG_IPK_DIR)/opt/bin; \
        for f in beam_evm ear ecc elink escript esh; do \
        	ln -s ../lib/erlang/bin/$$f .; \
        done
  endif

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
erlang-check: $(ERLANG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) \
		$(ERLANG_IPK) $(ERLANG-LIBS_IPK) $(ERLANG-MANPAGES_IPK) $(ERLANG-DOC-HTML_IPK)
