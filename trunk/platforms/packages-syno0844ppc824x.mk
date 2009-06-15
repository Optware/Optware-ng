PACKAGES = \
	kernel-modules \
	module-init-tools \

KERNEL_RECIPE_DIR=sources/kernel-modules/syno0844/ppc824x

MODULE_INIT_TOOLS_CONFIGURE_OPTIONS := --with-moddir=/opt/lib/modules
