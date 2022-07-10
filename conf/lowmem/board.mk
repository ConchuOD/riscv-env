HSS_SUPPORT ?= y
HSS_TARGET ?= mpfs-icicle-kit-es
UBOOT_VERSION = 2022.01
linux_defconfig := $(confdir)/$(DEVKIT)/defconfig
linux_dtb := $(riscv_dtbdir)/microchip/mpfs-icicle-kit.dtb
buildroot_defconfig := $(confdir)/buildroot_initramfs_config
its_file := $(confdir)/32-bit-fit-image.its
tftp_boot_scr ?= lowmem-boot.scr
