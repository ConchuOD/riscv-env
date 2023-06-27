HSS_SUPPORT ?= y
linux_defconfig := $(confdir)/defconfig
linux_dtb := $(riscv_dtbdir)/microchip/mpfs-video-kit.dtb
buildroot_initramfs_config := $(confdir)/$(DEVKIT)/buildroot_initramfs_config
its_file := $(confdir)/38-bit-fit-image.its
tftp_boot_scr ?= sevkit-boot.scr
