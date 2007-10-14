OPTWARE-BOOTSTRAP_REAL_OPT_DIR=$(strip \
	$(if $(filter ds101 ds101g, $(OPTWARE_TARGET)), /volume1/opt, \
	$(if $(filter fsg3 fsg3v4, $(OPTWARE_TARGET)), /home/.optware, \
	$(if $(filter mssii, $(OPTWARE-BOOTSTRAP_TARGET)), /share/.optware, \
	$(if $(filter lspro, $(OPTWARE-BOOTSTRAP_TARGET)), /mnt/disk1/.optware, \
	$(if $(filter teraprov2, $(OPTWARE-BOOTSTRAP_TARGET)), /mnt/array1/.optware, \
	))))))

OPTWARE-BOOTSTRAP_RC=$(strip \
	$(if $(filter mssii, $(OPTWARE_TARGET)), /etc/init.d/rc.optware, \
	/etc/init.d/optware))

# Ideally the following stanza would work
# unfortunately it has some conflict with optware/Makefile

# %-optware-bootstrap-ipk:
# 	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=$*
# %-optware-bootstrap-dirclean:
# 	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=$*

mssii-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=mssii
mssii-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=mssii

lspro-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=lspro
lspro-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=lspro

teraprov2-optware-bootstrap-ipk:
	$(MAKE) optware-bootstrap-ipk OPTWARE-BOOTSTRAP_TARGET=teraprov2
teraprov2-optware-bootstrap-dirclean:
	$(MAKE) optware-bootstrap-dirclean OPTWARE-BOOTSTRAP_TARGET=teraprov2
