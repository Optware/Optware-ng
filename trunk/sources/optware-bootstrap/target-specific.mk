OPTWARE-BOOTSTRAP_TARGETS=\
	dt2 \
	fsg3v4 \
	hpmv2 \
	lspro \
	mssii \
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

# Ideally the following stanza would work
# unfortunately it has some conflict with optware/Makefile

# %-optware-bootstrap-ipk:
# 	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=$*
# %-optware-bootstrap-dirclean:
# 	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=$*

fsg3v4-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=fsg3v4
fsg3v4-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=fsg3v4

dt2-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=dt2
dt2-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=dt2

vt4-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=vt4
vt4-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=vt4

hpmv2-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=hpmv2
hpmv2-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=hpmv2

lspro-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=lspro
lspro-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=lspro

mssii-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=mssii
mssii-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=mssii

syno-e500-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=syno-e500
syno-e500-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=syno-e500

syno-x07-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=syno-x07
syno-x07-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=syno-x07

teraprov2-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=teraprov2
teraprov2-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=teraprov2

tsx09-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=tsx09
tsx09-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=tsx09
