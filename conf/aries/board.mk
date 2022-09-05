HSS_SUPPORT ?= y
HSS_TARGET ?= aries-m100pfsevp
UBOOT_VERSION = 2022.01
linux_defconfig := $(confdir)/$(DEVKIT)/defconfig
linux_dtb := $(riscv_dtbdir)/microchip/mpfs-m100pfsevp.dtb
buildroot_initramfs_config := $(confdir)/$(DEVKIT)/buildroot_initramfs_config
its_file := $(confdir)/32-bit-fit-image.its
tftp_boot_scr ?= 32b-boot.scr
