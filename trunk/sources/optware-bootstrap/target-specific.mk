OPTWARE-BOOTSTRAP_TARGETS=\
	dt2 \
	fsg3v4 \
	hpmv2 \
	lspro \
	mssii \
	slugos5be \
	slugos5le \
	syno-e500 \
	syno-x07 \
	teraprov2 \
	tsx09 \
	vt4 \

OPTWARE-BOOTSTRAP_REAL_OPT_DIR=$(strip \
	$(if $(filter ds101 ds101g, $(OPTWARE_TARGET)), /volume1/opt, \
	$(if $(filter syno-e500 syno-x07, $(OPTWARE_TARGET)), /volume1/@optware, \
	$(if $(filter fsg3 fsg3v4 dt2 vt4, $(OPTWARE_TARGET)), /home/.optware, \
	$(if $(filter mssii, $(OPTWARE-BOOTSTRAP_TARGET)), /share/.optware, \
	$(if $(filter hpmv2, $(OPTWARE-BOOTSTRAP_TARGET)), /share/1000/.optware, \
	$(if $(filter lspro, $(OPTWARE-BOOTSTRAP_TARGET)), /mnt/disk1/.optware, \
	$(if $(filter teraprov2, $(OPTWARE-BOOTSTRAP_TARGET)), /mnt/array1/.optware, \
	$(if $(filter tsx09, $(OPTWARE-BOOTSTRAP_TARGET)), /share/MD0_DATA/.@optware, \
	)))))))))

OPTWARE-BOOTSTRAP_RC=$(strip \
	$(if $(filter cs05q3armel mssii, $(OPTWARE_TARGET)), /etc/init.d/rc.optware, \
	$(if $(filter syno-x07 syno-e500, $(OPTWARE_TARGET)), /etc/rc.optware, \
	/etc/init.d/optware)))

OPTWARE-BOOTSTRAP_CONTAINS=$(strip \
	ipkg-opt wget \
	$(if $(filter fsg3 fsg3v4 dt2 vt4 tsx09, $(OPTWARE-BOOTSTRAP_TARGET)), coreutils diffutils) \
	)

OPTWARE-BOOTSTRAP_LIBS=$(strip \
	$(if $(filter tsx09, $(OPTWARE-BOOTSTRAP_TARGET)), \
		$(TARGET_LIBDIR)/libgcc_s.so.1 $(TARGET_LIBDIR)/libgcc_s.so ) \
	)

define OPTWARE-BOOTSTRAP_RULE_TEMPLATE
$(1)-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=$(1)
$(1)-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=$(1)
endef

$(foreach target,$(OPTWARE-BOOTSTRAP_TARGETS),$(eval $(call OPTWARE-BOOTSTRAP_RULE_TEMPLATE,$(target))))
