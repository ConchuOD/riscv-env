HSS_SUPPORT ?= y
HSS_TARGET ?= mpfs-icicle-kit-es
UBOOT_VERSION = 2022.01
linux_defconfig := $(confdir)/defconfig
# UBOOT_VERSION := 9444f05240cb03000174e5e9510e926cb3a12e05
linux_dtb := $(riscv_dtbdir)/microchip/mpfs-icicle-kit.dtb
buildroot_initramfs_config := $(confdir)/buildroot_initramfs_config_us_ub
# buildroot_initramfs_config := $(confdir)/$(DEVKIT)/buildroot_initramfs_config
its_file := $(confdir)/32-bit-fit-image.its
tftp_boot_scr ?= lowmem-boot.scr
UBOOT_DEFCONFIG := "microchip_mpfs_icicle"
export UBOOT_DEFCONFIG 
