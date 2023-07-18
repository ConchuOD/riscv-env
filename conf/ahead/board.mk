UBOOT_VERSION = 2021.04
linux_defconfig := $(confdir)/defconfig
linux_dtb := $(riscv_dtbdir)/thead/th1520-lichee-pi-4a.dtb
its_file := $(confdir)/$(DEVKIT)/fit-image.its
buildroot_initramfs_config := $(confdir)/buildroot_initramfs_config
tftp_boot_scr := ahead-boot.scr