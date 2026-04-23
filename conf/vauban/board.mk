UBOOT_VERSION = 2022.01
HSS_SUPPORT ?= y
linux_defconfig := $(confdir)/defconfig
linux_dtb := $(riscv_dtbdir)/microchip/mpfs-beaglev-fire.dtb
# linux_dtb := $(riscv_dtbdir)/microchip/mpfs-vauban.dtb
buildroot_initramfs_config := $(confdir)/buildroot_initramfs_config_us_ub
its_file := $(confdir)/32-bit-fit-image.its
tftp_boot_scr ?= $(DEVKIT)-boot.scr
UBOOT_DEFCONFIG := "microchip_mpfs_vauban"
HSS_SUPPORT ?= y
export UBOOT_DEFCONFIG
