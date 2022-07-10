HSS_SUPPORT ?= y
UBOOT_VERSION = 2021.04
linux_defconfig := $(confdir)/$(DEVKIT)/defconfig
linux_dtb := $(riscv_dtbdir)/allwinner/sun20i-d1-nezha.dtb
its_file := $(confdir)/d1-fit-image.its
buildroot_defconfig := $(confdir)/$(DEVKIT)/buildroot_initramfs_config
tftp_boot_scr := d1-boot.scr