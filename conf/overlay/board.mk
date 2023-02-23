HSS_SUPPORT ?= y
HSS_TARGET ?= mpfs-icicle-kit-es
linux_defconfig := $(confdir)/$(DEVKIT)/defconfig
linux_dtb := $(riscv_dtbdir)/microchip/mpfs-icicle-kit.dtb
buildroot_initramfs_config := $(confdir)/$(DEVKIT)/buildroot_initramfs_config
its_file := $(confdir)/38-bit-fit-image.its
tftp_boot_scr ?= lowmem-boot.scr
