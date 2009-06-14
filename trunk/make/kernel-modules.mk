#KERNEL_RECIPE_DIR=sources/kernel-modules/$(strip \
$(if $(filter sheevaplug, $(OPTWARE_TARGET)), kirkwood, \
$(if $(filter syno0844mv6281, $(OPTWARE_TARGET)), syno0844/mv6281, \
$(if $(filter syno0844ppc854x, $(OPTWARE_TARGET)), syno0844/ppc854x, \
))))

ifdef KERNEL_RECIPE_DIR
include $(KERNEL_RECIPE_DIR)/Makefile
endif
