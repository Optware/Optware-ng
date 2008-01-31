OPTWARE-BOOTSTRAP_TARGETS=\
	dt2 \
	vt4 \
	fsg3v4 \
	lspro \
	mssii \
	teraprov2 \

OPTWARE-BOOTSTRAP_REAL_OPT_DIR=$(strip \
	$(if $(filter ds101 ds101g, $(OPTWARE_TARGET)), /volume1/opt, \
	$(if $(filter fsg3 fsg3v4 dt2 vt4, $(OPTWARE_TARGET)), /home/.optware, \
	$(if $(filter mssii, $(OPTWARE-BOOTSTRAP_TARGET)), /share/.optware, \
	$(if $(filter lspro, $(OPTWARE-BOOTSTRAP_TARGET)), /mnt/disk1/.optware, \
	$(if $(filter teraprov2, $(OPTWARE-BOOTSTRAP_TARGET)), /mnt/array1/.optware, \
	))))))

OPTWARE-BOOTSTRAP_RC=$(strip \
	$(if $(filter cs05q3armel mssii, $(OPTWARE_TARGET)), /etc/init.d/rc.optware, \
	/etc/init.d/optware))

OPTWARE-BOOTSTRAP_CONTAINS=$(strip \
	$(if $(filter fsg3 fsg3v4 dt2 vt4, $(OPTWARE-BOOTSTRAP_TARGET)), coreutils diffutils, \
	ipkg-opt openssl wget-ssl))

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

lspro-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=lspro
lspro-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=lspro

mssii-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=mssii
mssii-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=mssii

teraprov2-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=teraprov2
teraprov2-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=teraprov2
