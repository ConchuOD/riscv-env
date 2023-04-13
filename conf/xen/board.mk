linux_defconfig := $(confdir)/defconfig
linux_fragment := $(confdir)/$(DEVKIT)/xen.config
linux_dtb := $(riscv_dtbdir)/microchip/mpfs-icicle-kit.dtb
buildroot_initramfs_config := $(confdir)/buildroot_initramfs_config_us_ub
its_file := $(confdir)/32-bit-fit-image.its
tftp_boot_scr ?= lowmem-boot.scr
UBOOT_DEFCONFIG := "microchip_mpfs_icicle"
export UBOOT_DEFCONFIG 
