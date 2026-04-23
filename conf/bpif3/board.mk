linux_defconfig := $(confdir)/defconfig
linux_dtb := $(riscv_dtbdir)/spacemit/k1-bananapi-f3.dtb
buildroot_initramfs_config := $(confdir)/buildroot_initramfs_config_no_ub
its_file := $(confdir)/$(DEVKIT)/fit-image.its
OSBI_SUPPORT ?= y #hack to let it build, not actually needed cos u-boot not replaced
